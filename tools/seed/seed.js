#!/usr/bin/env node
/**
 * Seeds Firestore with Mindo Kids sample content.
 *
 *   cd tools/seed && npm install
 *   # Firebase console → Project settings → Service accounts → Generate new private key
 *   # save it as tools/seed/serviceAccount.json (git-ignored), then:
 *   node seed.js            # write everything
 *   node seed.js --dry-run  # print what would be written
 *
 * Against the emulator:  FIRESTORE_EMULATOR_HOST=localhost:8080 GCLOUD_PROJECT=demo-mindo node seed.js
 *
 * Safe to re-run: documents are overwritten by id; each seeded lesson's
 * steps sub-collection is replaced. Family data (users/…) is never touched.
 */
const fs = require('fs');
const path = require('path');
const data = require('./seed_data');

const DRY = process.argv.includes('--dry-run');
const strings = JSON.parse(fs.readFileSync(path.join(__dirname, 'strings.json'), 'utf8'));

function plan() {
  const writes = [];
  const set = (docPath, value) => writes.push({ docPath, value });

  set('config/app', data.config.app);
  set('config/paywall', data.config.paywall);
  set('config/strings', strings);

  const simple = ['onboarding', 'worlds', 'badges', 'avatars', 'plans', 'pages', 'announcements'];
  for (const col of simple) {
    for (const [id, doc] of Object.entries(data[col])) set(`${col}/${id}`, doc);
  }

  const lessonIds = [];
  for (const [id, lesson] of Object.entries(data.lessons)) {
    const { steps = [], ...meta } = lesson;
    set(`lessons/${id}`, { ...meta, stepCount: steps.length });
    lessonIds.push(id);
    steps.forEach((step, i) => {
      const stepId = `s${String(i + 1).padStart(2, '0')}`;
      set(`lessons/${id}/steps/${stepId}`, { order: i + 1, ...step });
    });
  }
  return { writes, lessonIds };
}

async function main() {
  const { writes, lessonIds } = plan();

  if (DRY) {
    const byCol = {};
    for (const w of writes) {
      const key = w.docPath.split('/').filter((_, i) => i % 2 === 0).join('/');
      byCol[key] = (byCol[key] || 0) + 1;
    }
    console.log('Dry run — documents per collection:', byCol);
    console.log('Total documents:', writes.length);
    return;
  }

  const { initializeApp, cert } = require('firebase-admin/app');
  const { getFirestore } = require('firebase-admin/firestore');

  if (process.env.FIRESTORE_EMULATOR_HOST) {
    initializeApp({ projectId: process.env.GCLOUD_PROJECT || 'demo-mindo' });
  } else {
    const keyPath = process.env.GOOGLE_APPLICATION_CREDENTIALS || path.join(__dirname, 'serviceAccount.json');
    if (!fs.existsSync(keyPath)) {
      console.error(`Service account key not found at ${keyPath}`);
      process.exit(1);
    }
    initializeApp({ credential: cert(JSON.parse(fs.readFileSync(keyPath, 'utf8'))) });
  }
  const db = getFirestore();

  // Replace steps of seeded lessons so removed steps don't linger.
  for (const id of lessonIds) {
    await db.recursiveDelete(db.collection(`lessons/${id}/steps`));
  }

  const writer = db.bulkWriter();
  for (const w of writes) writer.set(db.doc(w.docPath), w.value);
  await writer.close();
  console.log(`✔ Seeded ${writes.length} documents.`);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
