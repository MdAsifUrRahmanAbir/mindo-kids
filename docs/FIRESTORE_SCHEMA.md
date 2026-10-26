# Mindo Kids — Firestore schema (admin panel reference)

Everything the app shows comes from these documents. The admin panel only
needs to create/update/delete them — no app release required.

**Conventions**

* `order` (number) sorts lists ascending. `isActive: false` hides a document.
* Pictures are a pair of fields: an uploaded image URL **or** an `emoji`
  fallback. If both are set, the image wins. Upload files to Firebase Storage
  under `content/…` (only admins can write there) and store the download URL.
* Colours are hex strings: `#RRGGBB`.
* Doc ids are free text; use readable slugs (`english`, `en_letter_a`).
* Admin access = Firebase Auth user with custom claim `admin: true`
  (`tools/seed/make_admin.js`, then the `setAdminRole` function).

---

## Content collections (admin writes, app reads)

### `config/app`
| field | type | notes |
|---|---|---|
| appName | string | |
| tagline | string | |
| supportEmail | string | shows "Contact support" in Parent Zone when set |
| maintenanceMode | bool | `true` replaces the whole app with a maintenance screen |
| maintenanceMessage | string | |
| ageBands | string[] | choices on the child profile form, e.g. `["1.5–3","3–4","4–5","5–6"]` |
| defaultDailyLimitMinutes | number | screen-time limit given to new child profiles (0 = none) |
| correctSoundUrl / wrongSoundUrl / completeSoundUrl | string | short audio effects (optional) |
| praiseMessages / retryMessages | string[] | feedback bubbles in lessons |

### `config/paywall`
`title`, `subtitle`, `benefits` (string[]), `ctaText`, `restoreText`,
`footerNote` (auto-renew disclosure), `imageUrl` / `emoji` (hero picture).

### `config/strings`
Map of **every UI label** → text. Keys and default English values are in
`tools/seed/strings.json` (seeded). Placeholders such as `{name}`, `{count}`
must be kept. Leave a key empty to use the built-in default.

### `onboarding/{id}`
`title`, `subtitle`, `imageUrl` / `emoji`, `sideNote` (hand-written note),
`accentColor` (blob behind the picture), `order`, `isActive`.

### `worlds/{worldId}`
| field | type | notes |
|---|---|---|
| title, subtitle, description | string | |
| iconUrl / emoji | string | |
| color | string | card colour |
| language | string | `en`, `bn`, `hi`, `ur`, `ar` … |
| ttsLocale | string | voice for narration when no audio file: `en-US`, `bn-BD`, `hi-IN`, `ur-PK`, `ar-SA` |
| isRtl | bool | right-to-left content (Urdu, Arabic) |
| order, isActive | | |

### `lessons/{lessonId}`
| field | type | notes |
|---|---|---|
| worldId | string | **required** — id of the world |
| title, subtitle | string | |
| thumbnailUrl / emoji | string | |
| isPremium | bool | `true` = subscribers only (enforced by security rules on `steps`) |
| isDailySpark | bool | rotates as "Today's Brain Spark" on the dashboard |
| durationMinutes | number | |
| ttsLocale | string | optional override of the world's voice |
| stepCount | number | informational (seed sets it) |
| order, isActive | | |

### `lessons/{lessonId}/steps/{stepId}` — the activities
Common fields: `type`, `order`, `title`, `instruction`, `imageUrl` / `emoji`,
`audioUrl` (recorded narration; otherwise TTS reads the text), `bgColor`.

| `type` | extra fields | finished when |
|---|---|---|
| `story` | `text`, `highlights` (words to mark), optional `question`, `options`, `correctIndex`, `hint` | immediately, or when the question is answered |
| `quiz` | `question`, `options`, `correctIndex`, `hint` | correct answer chosen |
| `count` | `question`, `count` (how many copies of the picture), `options`, `correctIndex` | correct answer chosen |
| `letter` | `letter`, `word`, `text` (spoken sentence, e.g. "অ-তে অজগর"), `color` | immediately |
| `trace` | `letter`, `color`, optional `strokes` | child traces the guide |
| `match` | `pairs`: `[{left:{text,emoji,imageUrl}, right:{…}}]` | all pairs matched |
| `memory` | `cards`: `[{emoji|imageUrl|text}]` (each appears twice) | all pairs found |

`options` may be plain strings (`["A bed","A mat"]`) or objects
`{text, emoji, imageUrl, audioUrl}`. `correctIndex` is 0-based.

`strokes` (tracing guide) = `[{points:[x1,y1,x2,y2,…]}, …]` with coordinates
from 0 to 1 inside the square canvas (0,0 = top-left). The letter glyph is drawn
centred at ~78 % of the canvas height. Without strokes, any confident tracing
over the faded letter counts.

Stars: 3 ★ ≥ 90 % first-try correct, 2 ★ ≥ 60 %, otherwise 1 ★.

### `badges/{badgeId}`
`title`, `description`, `iconUrl` / `emoji`, `color`, `order`, `isActive`,
`rule: { type, value, worldId? }` where `type` is one of
`lessons_completed`, `streak`, `stars`, `world_lessons` (needs `worldId`).

### `avatars/{id}`
`imageUrl` / `emoji`, `bgColor`, `order`, `isActive`.

### `plans/{planId}` — subscription plans
| field | notes |
|---|---|
| title, subtitle, features (string[]), badgeText ("SAVE 44%") | |
| productIdAndroid / productIdIos | **must equal** the subscription product id in Play Console / App Store Connect |
| priceLabel, periodLabel | fallback text; the real localized price comes from the store |
| isHighlighted | pre-selected plan |
| order, isActive | |

### `pages/{pageId}`
`title`, `body` (plain text; lines starting `# ` are headings, `- ` bullets),
`order`, `showInParentZone`. The app links `terms` and `privacy` by id.

### `announcements/{id}`
`title`, `body`, `imageUrl` / `emoji`, `createdAt` (timestamp), `isActive`.

---

## Commerce (Cloud Functions write)

### `subscriptions/{uid}` — the entitlement
`active`, `status` (Play state / `MANUAL_GRANT` / `TRANSFERRED`),
`planId`, `productId`, `platform`, `source` (`google_play` | `manual`),
`autoRenewing`, `expiresAt` (timestamp), `updatedAt`.
The app unlocks premium when `active == true && expiresAt > now`.
Admins may edit it directly or call `grantSubscription({uid, days, planId, note})`
(days = 0 revokes).

### `purchases/{sha256(token)}` — token ledger (admin read only)
`uid`, `platform`, `productId`, `purchaseToken`, `lastNotificationType`, timestamps.

---

## Family data (the app writes; admin may read for support)

* `users/{uid}`: `displayName`, `email`, `isGuest`, `createdAt`.
* `users/{uid}/children/{childId}`: `name`, `ageBand`, `avatarId`,
  `avatarUrl`, `avatarEmoji`, `streak`, `bestStreak`, `lastActiveDate`
  (`yyyy-MM-dd`), `activeDates` (last 60 days), `lessonsCompleted`, `stars`,
  `dailyLimitMinutes`, `createdAt`.
* `…/children/{childId}/progress/{lessonId}`: `lessonId`, `worldId`,
  `completed`, `stars`, `bestScore`, `currentStep`, `totalSteps`, `attempts`,
  `updatedAt`, `completedAt`.
* `…/children/{childId}/badges/{badgeId}`: `badgeId`, `title`, `earnedAt`.

## Admin panel checklist

1. Sign in with an admin account (custom claim) — rules allow writes.
2. CRUD screens for: config (app, paywall, strings), onboarding, worlds,
   lessons + steps editor (per `type` form), badges, avatars, plans, pages,
   announcements.
3. Storage uploads to `content/<collection>/<id>/<file>`; save the download URL.
4. Users & subscriptions: read `users`, `subscriptions`; grant/revoke with
   `grantSubscription`; manage admins with `setAdminRole`.
5. Useful dashboard counts: users, children, active subscriptions, lesson
   completions (collection-group query on `progress`).
