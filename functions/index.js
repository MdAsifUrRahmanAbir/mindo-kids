/**
 * Mindo Kids — Cloud Functions
 *
 *  verifyPurchase            (callable)  Verifies a Google Play subscription token and grants
 *                                        the entitlement in subscriptions/{uid}.
 *  playBillingNotifications  (Pub/Sub)   Google Play Real-time Developer Notifications:
 *                                        renewals, cancellations, expiry, refunds …
 *  onUserDeleted             (Auth)      Removes users/{uid} (children, progress, badges).
 *  setAdminRole              (callable)  Admin-only: grant/revoke the `admin` custom claim.
 *  grantSubscription         (callable)  Admin-only: manual / promotional access.
 *
 * Setup (see README.md → "Subscriptions"):
 *  1. Play Console → Users & permissions → invite the Functions service account
 *     (<project-id>@appspot.gserviceaccount.com or the compute default SA) with
 *     "View financial data" + "Manage orders and subscriptions".
 *  2. Enable the "Google Play Android Developer API" in Google Cloud.
 *  3. Create Pub/Sub topic `play-billing`, grant google-play-developer-notifications@system.gserviceaccount.com
 *     the Publisher role, and set it in Play Console → Monetization setup → RTDN.
 */
const crypto = require('crypto');
const { setGlobalOptions } = require('firebase-functions/v2');
const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { onMessagePublished } = require('firebase-functions/v2/pubsub');
const { defineString } = require('firebase-functions/params');
const { logger } = require('firebase-functions');
const functionsV1 = require('firebase-functions/v1');
const { initializeApp } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');
const { getFirestore, Timestamp, FieldValue } = require('firebase-admin/firestore');
const { androidpublisher, auth: googleAuth } = require('@googleapis/androidpublisher');

const REGION = 'us-central1'; // keep in sync with AppConstants.functionsRegion
const RTDN_TOPIC = 'play-billing';
const ANDROID_PACKAGE = defineString('ANDROID_PACKAGE_NAME', { default: 'com.amisysx.mindokids' });

setGlobalOptions({ region: REGION, maxInstances: 10 });
initializeApp();
const db = getFirestore();

const ACTIVE_STATES = new Set(['SUBSCRIPTION_STATE_ACTIVE', 'SUBSCRIPTION_STATE_IN_GRACE_PERIOD']);

const tokenId = (token) => crypto.createHash('sha256').update(token).digest('hex');

let _play;
function playApi() {
  if (!_play) {
    const auth = new googleAuth.GoogleAuth({
      scopes: ['https://www.googleapis.com/auth/androidpublisher'],
    });
    _play = androidpublisher({ version: 'v3', auth });
  }
  return _play;
}

async function fetchPlaySubscription(token) {
  const res = await playApi().purchases.subscriptionsv2.get({
    packageName: ANDROID_PACKAGE.value(),
    token,
  });
  return res.data;
}

async function findPlanIdForProduct(productId) {
  if (!productId) return '';
  const snap = await db.collection('plans').where('productIdAndroid', '==', productId).limit(1).get();
  return snap.empty ? '' : snap.docs[0].id;
}

/** Writes subscriptions/{uid} from a Play SubscriptionPurchaseV2 resource. */
async function applyPlayState(uid, token, data) {
  const line = (data.lineItems || [])[0] || {};
  const productId = line.productId || '';
  const expiryMs = line.expiryTime ? Date.parse(line.expiryTime) : 0;
  const status = data.subscriptionState || 'UNKNOWN';
  const active = ACTIVE_STATES.has(status) && expiryMs > Date.now();
  const autoRenewing = Boolean(line.autoRenewingPlan && line.autoRenewingPlan.autoRenewEnabled);

  const doc = {
    active,
    status,
    productId,
    planId: await findPlanIdForProduct(productId),
    platform: 'android',
    source: 'google_play',
    autoRenewing,
    expiresAt: Timestamp.fromMillis(expiryMs || Date.now()),
    latestOrderId: data.latestOrderId || '',
    purchaseTokenHash: tokenId(token),
    updatedAt: FieldValue.serverTimestamp(),
  };
  await db.doc(`subscriptions/${uid}`).set(doc, { merge: true });
  return doc;
}

function requireAdmin(request) {
  if (!request.auth || request.auth.token.admin !== true) {
    throw new HttpsError('permission-denied', 'Admins only.');
  }
}

// ---------------------------------------------------------------------------
// verifyPurchase — called by the app after the store reports a purchase/restore
// ---------------------------------------------------------------------------
exports.verifyPurchase = onCall(async (request) => {
  const uid = request.auth && request.auth.uid;
  if (!uid) throw new HttpsError('unauthenticated', 'Please sign in first.');

  const { platform, productId, purchaseToken } = request.data || {};
  if (typeof purchaseToken !== 'string' || purchaseToken.length < 10) {
    throw new HttpsError('invalid-argument', 'purchaseToken is required.');
  }
  if (platform !== 'android') {
    // App Store: implement with the App Store Server API (verify the
    // transaction JWS, then write subscriptions/{uid} the same way).
    throw new HttpsError('unimplemented', 'App Store purchases are not enabled yet.');
  }

  let data;
  try {
    data = await fetchPlaySubscription(purchaseToken);
  } catch (err) {
    logger.error('Play verification failed', { uid, productId, message: err.message });
    throw new HttpsError('failed-precondition', 'We could not confirm this purchase with Google Play. Please try again.');
  }

  const line = (data.lineItems || [])[0] || {};
  const verifiedProductId = line.productId || productId || '';

  // Ledger: one document per purchase token (hash), remembering its owner.
  // If the same Google Play purchase is restored on a different account,
  // the entitlement moves to the new account.
  const ledgerRef = db.doc(`purchases/${tokenId(purchaseToken)}`);
  const ledger = await ledgerRef.get();
  const previousUid = ledger.exists ? ledger.get('uid') : null;
  if (previousUid && previousUid !== uid) {
    await db.doc(`subscriptions/${previousUid}`).set(
      { active: false, status: 'TRANSFERRED', transferredTo: uid, updatedAt: FieldValue.serverTimestamp() },
      { merge: true },
    );
    logger.info('Subscription transferred', { from: previousUid, to: uid });
  }
  await ledgerRef.set(
    {
      uid,
      platform: 'android',
      productId: verifiedProductId,
      purchaseToken,
      linkedPurchaseToken: data.linkedPurchaseToken || '',
      updatedAt: FieldValue.serverTimestamp(),
      ...(ledger.exists ? {} : { createdAt: FieldValue.serverTimestamp() }),
    },
    { merge: true },
  );

  // Acknowledge within 3 days or Google refunds automatically.
  if (data.acknowledgementState === 'ACKNOWLEDGEMENT_STATE_PENDING' && verifiedProductId) {
    try {
      await playApi().purchases.subscriptions.acknowledge({
        packageName: ANDROID_PACKAGE.value(),
        subscriptionId: verifiedProductId,
        token: purchaseToken,
        requestBody: {},
      });
    } catch (err) {
      logger.warn('Acknowledge failed (client completePurchase also acknowledges)', { message: err.message });
    }
  }

  const doc = await applyPlayState(uid, purchaseToken, data);
  if (!doc.active) {
    throw new HttpsError('failed-precondition', 'This subscription is no longer active.');
  }
  return { active: true, planId: doc.planId, expiresAt: doc.expiresAt.toMillis() };
});

// ---------------------------------------------------------------------------
// Google Play Real-time Developer Notifications
// ---------------------------------------------------------------------------
exports.playBillingNotifications = onMessagePublished(RTDN_TOPIC, async (event) => {
  let payload;
  try {
    payload = event.data.message.json;
  } catch (err) {
    logger.warn('RTDN: unreadable message', { message: err.message });
    return;
  }
  const n = payload && payload.subscriptionNotification;
  if (!n || !n.purchaseToken) {
    logger.info('RTDN: ignored (test or non-subscription notification)');
    return;
  }

  const ledgerRef = db.doc(`purchases/${tokenId(n.purchaseToken)}`);
  const ledger = await ledgerRef.get();
  if (!ledger.exists) {
    // Not verified yet — verifyPurchase will create the entitlement.
    logger.info('RTDN: unknown token', { type: n.notificationType });
    return;
  }

  const uid = ledger.get('uid');
  const data = await fetchPlaySubscription(n.purchaseToken);
  await applyPlayState(uid, n.purchaseToken, data);
  await ledgerRef.set(
    { lastNotificationType: n.notificationType, updatedAt: FieldValue.serverTimestamp() },
    { merge: true },
  );
});

// ---------------------------------------------------------------------------
// Account deletion clean-up (user.delete() from the Parent Zone)
// ---------------------------------------------------------------------------
exports.onUserDeleted = functionsV1
  .region(REGION)
  .auth.user()
  .onDelete(async (user) => {
    await db.recursiveDelete(db.doc(`users/${user.uid}`));
    await db.doc(`subscriptions/${user.uid}`).delete().catch(() => undefined);
    logger.info('Deleted family data', { uid: user.uid });
  });

// ---------------------------------------------------------------------------
// Admin helpers for the admin panel
// ---------------------------------------------------------------------------
exports.setAdminRole = onCall(async (request) => {
  requireAdmin(request);
  const { email, admin } = request.data || {};
  if (typeof email !== 'string' || !email) throw new HttpsError('invalid-argument', 'email is required.');
  const user = await getAuth().getUserByEmail(email);
  await getAuth().setCustomUserClaims(user.uid, { ...(user.customClaims || {}), admin: Boolean(admin) });
  return { uid: user.uid, admin: Boolean(admin) };
});

exports.grantSubscription = onCall(async (request) => {
  requireAdmin(request);
  const { uid, days, planId, note } = request.data || {};
  const d = Number(days);
  if (typeof uid !== 'string' || !uid) throw new HttpsError('invalid-argument', 'uid is required.');
  if (!Number.isFinite(d)) throw new HttpsError('invalid-argument', 'days must be a number (0 revokes).');

  const expiresAt = Timestamp.fromMillis(Date.now() + Math.max(0, d) * 24 * 60 * 60 * 1000);
  await db.doc(`subscriptions/${uid}`).set(
    {
      active: d > 0,
      status: d > 0 ? 'MANUAL_GRANT' : 'MANUAL_REVOKED',
      planId: planId || '',
      productId: '',
      platform: 'manual',
      source: 'manual',
      autoRenewing: false,
      expiresAt,
      note: note || '',
      grantedBy: request.auth.uid,
      updatedAt: FieldValue.serverTimestamp(),
    },
    { merge: true },
  );
  return { uid, active: d > 0, expiresAt: expiresAt.toMillis() };
});
