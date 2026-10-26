#!/usr/bin/env node
/**
 * Gives an existing Firebase Auth user the `admin: true` custom claim so they
 * can write content (see firestore.rules) from the admin panel.
 *
 *   node make_admin.js you@example.com          # grant
 *   node make_admin.js you@example.com --revoke # revoke
 *
 * The user must sign out and back in (or refresh their ID token) for the
 * claim to take effect. After the first admin exists, further admins can be
 * managed from the admin panel via the `setAdminRole` Cloud Function.
 */
const fs = require('fs');
const path = require('path');
const { initializeApp, cert } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');

async function main() {
  const email = process.argv[2];
  const revoke = process.argv.includes('--revoke');
  if (!email) {
    console.error('Usage: node make_admin.js <email> [--revoke]');
    process.exit(1);
  }
  const keyPath = process.env.GOOGLE_APPLICATION_CREDENTIALS || path.join(__dirname, 'serviceAccount.json');
  initializeApp({ credential: cert(JSON.parse(fs.readFileSync(keyPath, 'utf8'))) });

  const user = await getAuth().getUserByEmail(email);
  await getAuth().setCustomUserClaims(user.uid, { ...(user.customClaims || {}), admin: !revoke });
  console.log(`✔ ${email} (${user.uid}) admin = ${!revoke}`);
}

main().catch((err) => {
  console.error(err.message);
  process.exit(1);
});
