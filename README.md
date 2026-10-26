# Mindo Kids 🧠✨
*Little Minds. Infinite Worlds.*

Multilingual early-learning app for children (≈1.5–6 years), built with
**Flutter + Firebase**. Every piece of content — onboarding, learning worlds,
lessons and activities, badges, avatars, subscription plans, paywall copy,
legal pages and even UI labels — is read from **Cloud Firestore**, so an admin
panel can manage the whole app without releasing updates.

Premium lessons are unlocked by a **subscription** (Google Play Billing),
verified server-side by Cloud Functions.

---

## What's inside

| Area | Screens / features |
|---|---|
| Onboarding | Slides from `onboarding/*` (UI demo layout), Let's Get Started, Sign in |
| Parent account | Sign up, sign in, reset password, try as guest (upgrades in place) |
| Child profiles | Create / edit / delete, avatars from Firestore, "Who's learning today?" |
| Dashboard | Greeting, weekly streak, learning-world grid, Today's Brain Spark, Continue Learning, badges |
| Explore | All worlds with progress, lesson search |
| World | Lesson journey with stars, PRO locks |
| Lesson player | 7 data-driven activity types: story (demo "Let's Read!"), quiz, count, letter, finger tracing, matching, memory · narration (uploaded audio or text-to-speech per language) · RTL support · resume where left off |
| Rewards | Stars, lessons, best streak, badge collection |
| Parent Zone (behind parent gate) | Subscription status, children & per-world progress, daily screen-time limit, help/privacy/terms pages, sign out, delete account |
| Subscription | Plans from Firestore, store prices, purchase, restore, manage |
| Safety | Parent gate before purchases/settings, no ads/chat/external links for kids, minimal child data |
| Offline | Firestore on-device cache + offline-safe progress writes; images cached |

Architecture follows the SalesysX conventions: **Riverpod 3** (Notifier +
immutable state classes), **go_router**, feature-first folders
(`features/<feature>/data/repositories`, `presentation/{controllers,states,screens,widgets}`).

```
lib/
  core/        constants, theme, session, screen time, widgets, services
  features/    auth, children, home, explore, world, lesson, rewards, profile,
               parent_zone, subscription, content, progress, pages, …
  routes/      go_router + redirects
functions/     Cloud Functions (purchase verification, RTDN, clean-up, admin)
tools/seed/    sample content + admin bootstrap
docs/          FIRESTORE_SCHEMA.md ← use this to build the admin panel
```

---

## Setup

### 1. Flutter project
```bash
flutter create . --org com.amisysx --project-name mindo_kids --platforms=android,ios
# (keeps the existing lib/ and android/ files; only adds what's missing, e.g. ios/)
flutter pub get
dart run flutter_launcher_icons
```
Package name: `com.amisysx.mindokids` (change in `android/app/build.gradle.kts`
and `functions` param `ANDROID_PACKAGE_NAME` if you use another).

### 2. Firebase
1. Create a Firebase project, then:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure        # writes lib/firebase_options.dart + google-services.json
   ```
2. **Authentication** → enable **Email/Password** and **Anonymous**.
3. **Firestore** (production mode) and **Storage**.
4. Deploy rules and functions (Blaze plan needed for Functions):
   ```bash
   npm i -g firebase-tools && firebase login && firebase use <project-id>
   cd functions && npm install && cd ..
   firebase deploy --only firestore,storage,functions
   ```

### 3. Sample content
```bash
cd tools/seed && npm install
# Firebase console → Project settings → Service accounts → Generate new private key
# save as tools/seed/serviceAccount.json (git-ignored)
node seed.js                       # 5 worlds, 13 lessons, 44 activities, badges, plans …
node make_admin.js you@example.com # first admin for the admin panel
```

### 4. Run
```bash
flutter run
# against emulators:
firebase emulators:start
flutter run --dart-define=USE_EMULATORS=true --dart-define=EMULATOR_HOST=10.0.2.2
```

---

## Subscriptions

1. **Play Console → Monetize → Subscriptions**: create `mindo_plus_monthly`
   and `mindo_plus_yearly` (each with a base plan). Ids must match
   `plans/*.productIdAndroid`.
2. **Google Cloud** (same project as Firebase): enable *Google Play Android
   Developer API*.
3. **Play Console → Users & permissions**: invite the Cloud Functions service
   account (`<project-number>-compute@developer.gserviceaccount.com`) with
   *View financial data* and *Manage orders and subscriptions*.
4. **Real-time notifications**: create Pub/Sub topic `play-billing`, give
   `google-play-developer-notifications@system.gserviceaccount.com` the
   *Pub/Sub Publisher* role, and set the topic in Play Console →
   Monetization setup. Renewals, cancellations and refunds then update
   `subscriptions/{uid}` automatically.
5. Upload a signed build to an internal testing track and add license
   testers to try purchases.

Flow: app buys → `verifyPurchase` checks the token with Google Play,
acknowledges it and writes `subscriptions/{uid}` → app unlocks.
Firestore rules refuse premium lesson steps without an active subscription,
so a modified app can't bypass it. Admins can also grant access manually
(`grantSubscription`) for schools/promotions.

> iOS: purchase UI works through `in_app_purchase`, but server verification
> for the App Store is not implemented yet (`verifyPurchase` returns
> *unimplemented* for `ios`). Add App Store Server API verification before
> shipping on iOS.

---

## Notes

* Uses `package:flutter/material.dart` (same as SalesysX). `google_fonts` is
  kept below 9.0 because 9.x switched to the new standalone `material_ui`
  package.
* Before release: replace the template privacy policy/terms in `pages/*`,
  review COPPA/GDPR-K for your launch markets, and check current Google Play
  Families policy.
* The concept doc's ZIP-pack pipeline is replaced by direct Firestore
  documents + Storage URLs, which is what a simple admin panel can edit; the
  offline cache keeps opened lessons available.
