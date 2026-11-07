/**
 * Next-step beginner content (after the alphabet):
 *   1. Vowel signs — Bangla কার, Hindi मात्रा, Arabic حركات, Urdu اعراب
 *   2. Everyday words by theme in every language (animals, fruits, …)
 *   3. English first words (CVC)
 *   4. Math: take away, big & small, missing number, add to 10, compare, shapes
 *   5. Good-habit stories
 *
 * Everything is generated from the tables below — edit a row and re-run
 * `node seed.js`.
 */

const COLORS = ['#FF7A7A', '#6CB8FF', '#5FCF97', '#FFB547', '#8E7CF8', '#FF8EC7', '#2EC4B6', '#FF9F43'];
const color = (i) => COLORS[i % COLORS.length];
const rotate = (arr, n) => {
  const k = ((n % arr.length) + arr.length) % arr.length;
  return arr.slice(k).concat(arr.slice(0, k));
};
const lesson = (worldId, order, title, subtitle, emoji, steps, extra = {}) => ({
  worldId, order, isActive: true, isPremium: false, isDailySpark: false,
  title, subtitle, emoji, thumbnailUrl: '', durationMinutes: 3, steps, ...extra,
});

const WORLD_OF = { en: 'english', bn: 'bangla', hi: 'hindi', ar: 'arabic', ur: 'urdu' };

const UI = {
  en: { say: (w) => `Say it with me: ${w}!`, where: (w) => `Where is the ${w}?`, match: 'Match the word to the picture', memory: 'Find the pairs', hello: "Let's learn new words!" },
  bn: { say: (w) => `বলো: ${w}!`, where: (w) => `${w} কোনটি?`, match: 'শব্দের সাথে ছবি মেলাও', memory: 'একই ছবি খুঁজে বের করো', hello: 'চলো নতুন শব্দ শিখি!' },
  hi: { say: (w) => `बोलो: ${w}!`, where: (w) => `${w} कौन सा है?`, match: 'शब्द को चित्र से मिलाओ', memory: 'जोड़ी ढूँढो', hello: 'चलो नए शब्द सीखें!' },
  ar: { say: (w) => `قُل معي: ${w}!`, where: (w) => `أشِر إلى: ${w}`, match: 'صِل الكلمة بالصورة', memory: 'ابحث عن الأزواج', hello: 'هيا نتعلم كلمات جديدة!' },
  ur: { say: (w) => `بولو: ${w}!`, where: (w) => `${w} کہاں ہے؟`, match: 'لفظ کو تصویر سے ملاؤ', memory: 'جوڑے تلاش کرو', hello: 'آؤ نئے الفاظ سیکھیں!' },
};

// ====================================================================== 1. vowel signs
// Row: [syllable, word, emoji, explanation]
const SIGNS = {
  bn: {
    prefix: 'bn_kar', titlePrefix: 'কার চিহ্ন', order: 30,
    quiz: (s) => `কোনটি “${s}”?`, match: 'ছবির সাথে মেলাও',
    groups: [
      [['বা', 'বাবা', '👨', 'আ-কার (া): ব + া = বা'], ['পি', 'পিঠা', '🥮', 'ই-কার (ি): প + ি = পি'], ['নী', 'নীল', '🔵', 'ঈ-কার (ী): ন + ী = নী']],
      [['ফু', 'ফুল', '🌸', 'উ-কার (ু): ফ + ু = ফু'], ['সূ', 'সূর্য', '☀️', 'ঊ-কার (ূ): স + ূ = সূ'], ['কৃ', 'কৃষক', '👨‍🌾', 'ঋ-কার (ৃ): ক + ৃ = কৃ']],
      [['বে', 'বেলুন', '🎈', 'এ-কার (ে): ব + ে = বে'], ['বৈ', 'বৈঠা', '🛶', 'ঐ-কার (ৈ): ব + ৈ = বৈ'], ['মো', 'মোমবাতি', '🕯️', 'ও-কার (ো): ম + ো = মো'], ['নৌ', 'নৌকা', '⛵', 'ঔ-কার (ৌ): ন + ৌ = নৌ']],
    ],
  },
  hi: {
    prefix: 'hi_matra', titlePrefix: 'मात्रा', order: 30,
    quiz: (s) => `“${s}” कौन सा है?`, match: 'चित्र से मिलाओ',
    groups: [
      [['ना', 'नाव', '⛵', 'आ की मात्रा (ा): न + ा = ना'], ['कि', 'किताब', '📖', 'इ की मात्रा (ि): क + ि = कि'], ['ची', 'चील', '🦅', 'ई की मात्रा (ी): च + ी = ची']],
      [['गु', 'गुब्बारा', '🎈', 'उ की मात्रा (ु): ग + ु = गु'], ['फू', 'फूल', '🌸', 'ऊ की मात्रा (ू): फ + ू = फू'], ['मृ', 'मृग', '🦌', 'ऋ की मात्रा (ृ): म + ृ = मृ']],
      [['से', 'सेब', '🍎', 'ए की मात्रा (े): स + े = से'], ['बै', 'बैल', '🐂', 'ऐ की मात्रा (ै): ब + ै = बै'], ['मो', 'मोर', '🦚', 'ओ की मात्रा (ो): म + ो = मो'], ['कौ', 'कौआ', '🐦', 'औ की मात्रा (ौ): क + ौ = कौ']],
    ],
  },
  ar: {
    prefix: 'ar_haraka', titlePrefix: 'الحركات', order: 30,
    quiz: (s) => `أين «${s}»؟`, match: 'صِل بالصورة',
    groups: [
      [['بَ', 'بَطّة', '🦆', 'الفتحة: بَ'], ['بِ', 'بِنت', '👧', 'الكسرة: بِ'], ['بُ', 'بُرتقال', '🍊', 'الضمة: بُ']],
      [['مَ', 'مَوز', '🍌', 'الفتحة: مَ'], ['مِ', 'مِلعقة', '🥄', 'الكسرة: مِ'], ['مُ', 'مُعلِّم', '👨‍🏫', 'الضمة: مُ']],
    ],
  },
  ur: {
    prefix: 'ur_aerab', titlePrefix: 'اعراب', order: 30,
    quiz: (s) => `«${s}» کہاں ہے؟`, match: 'تصویر سے ملاؤ',
    groups: [
      [['بَ', 'بَطخ', '🦆', 'زبر: بَ'], ['بِ', 'بِلّی', '🐱', 'زیر: بِ'], ['بُ', 'بُلبُل', '🐦', 'پیش: بُ']],
      [['مَ', 'مَچھلی', '🐟', 'زبر: مَ'], ['مِ', 'مِرچ', '🌶️', 'زیر: مِ'], ['مُ', 'مُرغی', '🐔', 'پیش: مُ']],
    ],
  },
};

function buildSigns() {
  const out = {};
  for (const [lang, cfg] of Object.entries(SIGNS)) {
    cfg.groups.forEach((rows, gi) => {
      const steps = rows.map(([syl, word, emoji, expl], i) => ({
        type: 'letter', letter: syl, word, emoji, text: `${expl} — ${word}`, color: color(gi * 4 + i),
      }));
      steps.push({ type: 'trace', letter: rows[0][0], instruction: rows[0][3], color: color(gi) });
      const target = rows[(gi + 1) % rows.length];
      const opts = rotate(rows.map((r) => r[0]), gi);
      steps.push({ type: 'quiz', question: cfg.quiz(target[0]), hint: target[3], options: opts, correctIndex: opts.indexOf(target[0]) });
      steps.push({ type: 'match', instruction: cfg.match, pairs: rows.slice(0, 4).map((r) => ({ left: { text: r[0] }, right: { emoji: r[2] } })) });
      const signs = rows.map((r) => r[3].split(':')[0].trim()).join(' · ');
      out[`${cfg.prefix}_${String(gi + 1).padStart(2, '0')}`] = lesson(
        WORLD_OF[lang], cfg.order + gi, `${cfg.titlePrefix} ${rows.map((r) => r[0]).join(' ')}`, signs, rows[0][0], steps,
      );
    });
  }
  return out;
}

// ====================================================================== 2. everyday words
// Row: [emoji, en, bn, hi, ar, ur]
const THEMES = [
  {
    key: 'animals', emoji: '🐾',
    title: { en: 'Animal Words', bn: 'প্রাণীর নাম', hi: 'जानवरों के नाम', ar: 'الحيوانات', ur: 'جانوروں کے نام' },
    items: [
      ['🐱', 'cat', 'বিড়াল', 'बिल्ली', 'قطة', 'بلی'],
      ['🐶', 'dog', 'কুকুর', 'कुत्ता', 'كلب', 'کتا'],
      ['🐄', 'cow', 'গরু', 'गाय', 'بقرة', 'گائے'],
      ['🐘', 'elephant', 'হাতি', 'हाथी', 'فيل', 'ہاتھی'],
    ],
  },
  {
    key: 'fruits', emoji: '🍎', skip: ['bn', 'hi'], // bn_fruits / hi_fruits already exist
    title: { en: 'Fruit Words', bn: 'ফল', hi: 'फल', ar: 'الفواكه', ur: 'پھل' },
    items: [
      ['🍎', 'apple', 'আপেল', 'सेब', 'تفاحة', 'سیب'],
      ['🍌', 'banana', 'কলা', 'केला', 'موز', 'کیلا'],
      ['🥭', 'mango', 'আম', 'आम', 'مانجو', 'آم'],
      ['🍇', 'grapes', 'আঙুর', 'अंगूर', 'عنب', 'انگور'],
    ],
  },
  {
    key: 'colours', emoji: '🎨', skip: ['en', 'ar'], // en_colors / ar_colors already exist
    title: { en: 'Colours', bn: 'রং', hi: 'रंग', ar: 'الألوان', ur: 'رنگ' },
    items: [
      ['🔴', 'red', 'লাল', 'लाल', 'أحمر', 'لال'],
      ['🔵', 'blue', 'নীল', 'नीला', 'أزرق', 'نیلا'],
      ['🟢', 'green', 'সবুজ', 'हरा', 'أخضر', 'ہرا'],
      ['🟡', 'yellow', 'হলুদ', 'पीला', 'أصفر', 'پیلا'],
    ],
  },
  {
    key: 'body', emoji: '🧒',
    title: { en: 'My Body', bn: 'আমার শরীর', hi: 'मेरा शरीर', ar: 'جسمي', ur: 'میرا جسم' },
    items: [
      ['👁️', 'eye', 'চোখ', 'आँख', 'عين', 'آنکھ'],
      ['👃', 'nose', 'নাক', 'नाक', 'أنف', 'ناک'],
      ['👂', 'ear', 'কান', 'कान', 'أذن', 'کان'],
      ['✋', 'hand', 'হাত', 'हाथ', 'يد', 'ہاتھ'],
    ],
  },
  {
    key: 'family', emoji: '👨‍👩‍👧',
    title: { en: 'My Family', bn: 'আমার পরিবার', hi: 'मेरा परिवार', ar: 'عائلتي', ur: 'میرا خاندان' },
    items: [
      ['👩', 'mother', 'মা', 'माँ', 'أم', 'امی'],
      ['👨', 'father', 'বাবা', 'पापा', 'أب', 'ابو'],
      ['👵', 'grandmother', 'দাদি', 'दादी', 'جدة', 'دادی'],
      ['👦', 'brother', 'ভাই', 'भाई', 'أخ', 'بھائی'],
    ],
  },
  {
    key: 'vehicles', emoji: '🚗',
    title: { en: 'Vehicles', bn: 'যানবাহন', hi: 'वाहन', ar: 'المواصلات', ur: 'سواریاں' },
    items: [
      ['🚗', 'car', 'গাড়ি', 'गाड़ी', 'سيارة', 'گاڑی'],
      ['🚌', 'bus', 'বাস', 'बस', 'حافلة', 'بس'],
      ['✈️', 'aeroplane', 'বিমান', 'हवाई जहाज़', 'طائرة', 'ہوائی جہاز'],
      ['🚲', 'bicycle', 'সাইকেল', 'साइकिल', 'دراجة', 'سائیکل'],
    ],
  },
  {
    key: 'nature', emoji: '🌤️',
    title: { en: 'Sky & Nature', bn: 'আকাশ ও প্রকৃতি', hi: 'आसमान और प्रकृति', ar: 'السماء والطبيعة', ur: 'آسمان اور قدرت' },
    items: [
      ['☀️', 'sun', 'সূর্য', 'सूरज', 'شمس', 'سورج'],
      ['🌙', 'moon', 'চাঁদ', 'चाँद', 'قمر', 'چاند'],
      ['⭐', 'star', 'তারা', 'तारा', 'نجمة', 'ستارہ'],
      ['🌳', 'tree', 'গাছ', 'पेड़', 'شجرة', 'درخت'],
    ],
  },
  {
    key: 'home', emoji: '🏠',
    title: { en: 'At Home', bn: 'আমার ঘর', hi: 'मेरा घर', ar: 'في البيت', ur: 'میرا گھر' },
    items: [
      ['🛏️', 'bed', 'বিছানা', 'बिस्तर', 'سرير', 'بستر'],
      ['🪑', 'chair', 'চেয়ার', 'कुर्सी', 'كرسي', 'کرسی'],
      ['🚪', 'door', 'দরজা', 'दरवाज़ा', 'باب', 'دروازہ'],
      ['📖', 'book', 'বই', 'किताब', 'كتاب', 'کتاب'],
    ],
  },
];
const LANG_COL = { en: 1, bn: 2, hi: 3, ar: 4, ur: 5 };

function buildWords() {
  const out = {};
  for (const lang of Object.keys(LANG_COL)) {
    const t = UI[lang];
    let order = 40;
    THEMES.forEach((theme, ti) => {
      if (theme.skip?.includes(lang)) return;
      const rows = theme.items.map((it) => ({ emoji: it[0], word: it[LANG_COL[lang]] }));
      const steps = rows.map((r, i) => ({
        type: 'letter', letter: r.word, word: r.word, emoji: r.emoji, text: t.say(r.word), color: color(ti + i),
        ...(i === 0 ? { instruction: t.hello } : {}),
      }));
      const target = rows[ti % rows.length];
      const opts = rotate(rows.slice(0, 3).includes(target) ? rows.slice(0, 3) : [target, rows[0], rows[1]], ti);
      steps.push({ type: 'quiz', question: t.where(target.word), options: opts.map((r) => ({ emoji: r.emoji })), correctIndex: opts.indexOf(target) });
      steps.push({ type: 'match', instruction: t.match, pairs: rows.map((r) => ({ left: { text: r.word }, right: { emoji: r.emoji } })) });
      steps.push({ type: 'memory', instruction: t.memory, cards: rows.map((r) => ({ emoji: r.emoji })) });
      out[`${lang}_words_${theme.key}`] = lesson(
        WORLD_OF[lang], order++, theme.title[lang], rows.map((r) => r.word).join(', '), theme.emoji, steps,
      );
    });
  }
  return out;
}

// ====================================================================== 3. English first words (CVC)
const CVC = [
  [['cat', '🐱'], ['hat', '🎩'], ['bat', '🦇']],
  [['dog', '🐶'], ['sun', '☀️'], ['bus', '🚌']],
  [['pen', '🖊️'], ['hen', '🐔'], ['pig', '🐷']],
];

function buildCvc() {
  const out = {};
  CVC.forEach((rows, gi) => {
    const steps = rows.map(([w, e], i) => ({
      type: 'letter', letter: w, word: w, emoji: e, text: `${w.split('').join(' - ')}. ${w}!`, color: color(gi + i),
      ...(i === 0 ? { instruction: 'Sound it out!' } : {}),
    }));
    const [tw] = rows[(gi + 2) % 3];
    const opts = rotate(rows.map(([w, e]) => ({ emoji: e, text: w })), gi);
    steps.push({ type: 'quiz', question: `Which picture says “${tw}”?`, options: opts.map((o) => ({ emoji: o.emoji })), correctIndex: opts.findIndex((o) => o.text === tw), hint: tw.split('').join(' - ') });
    steps.push({ type: 'match', instruction: 'Read and match', pairs: rows.map(([w, e]) => ({ left: { text: w }, right: { emoji: e } })) });
    out[`en_cvc_${String(gi + 1).padStart(2, '0')}`] = lesson('english', 30 + gi, `First Words ${gi + 1}`, rows.map(([w]) => w).join(', '), rows[0][1], steps);
  });
  return out;
}

// ====================================================================== 4. math
const math = {
  num_take_away: lesson('numbers', 30, 'Take Away', 'Simple subtraction', '➖', [
    { type: 'story', title: 'Take away!', text: 'You have three apples. You eat one. Now you have two apples.', highlights: ['three', 'one', 'two'], emoji: '🍎🍎🍎', bgColor: '#FFE0E0' },
    { type: 'quiz', question: '🍎🍎🍎 take away 🍎 = ?', options: ['2', '3', '1'], correctIndex: 0 },
    { type: 'quiz', question: '🎈🎈🎈🎈 — 2 balloons fly away. How many are left?', options: ['1', '2', '3'], correctIndex: 1 },
    { type: 'quiz', question: '5 − 1 = ?', hint: 'Count back one: 5… 4!', options: ['6', '3', '4'], correctIndex: 2 },
  ]),
  num_big_small: lesson('numbers', 31, 'Big & Small', 'Bigger, smaller, taller', '🐘', [
    { type: 'quiz', question: 'Which one is BIG?', options: [{ emoji: '🐭' }, { emoji: '🐘' }, { emoji: '🐜' }], correctIndex: 1 },
    { type: 'quiz', question: 'Which one is SMALL?', options: [{ emoji: '🦒' }, { emoji: '🐋' }, { emoji: '🐞' }], correctIndex: 2 },
    { type: 'quiz', question: 'Which is TALLER?', options: [{ emoji: '🌳', text: 'tree' }, { emoji: '🌷', text: 'flower' }], correctIndex: 0 },
    { type: 'match', instruction: 'Match big with small', pairs: [{ left: { emoji: '🐘' }, right: { emoji: '🐭' } }, { left: { emoji: '🌳' }, right: { emoji: '🌱' } }, { left: { emoji: '🐋' }, right: { emoji: '🐟' } }] },
  ]),
  num_missing: lesson('numbers', 32, 'Missing Number', 'Find the hiding number', '❓', [
    { type: 'quiz', question: '1, 2, _, 4 — which number is missing?', options: ['3', '5', '2'], correctIndex: 0 },
    { type: 'quiz', question: '4, 5, 6, _ — which number is missing?', options: ['8', '7', '3'], correctIndex: 1 },
    { type: 'quiz', question: '_, 9, 10 — which number is missing?', options: ['7', '11', '8'], correctIndex: 2 },
    { type: 'quiz', question: '2, 4, 6, _ — count by twos!', hint: 'Skip one each time.', options: ['8', '7', '10'], correctIndex: 0 },
  ]),
  num_add_10: lesson('numbers', 33, 'Add to 10', 'Bigger sums', '🔟', [
    { type: 'quiz', question: '3 + 2 = ?', options: ['4', '5', '6'], correctIndex: 1 },
    { type: 'quiz', question: '⭐⭐⭐⭐ + ⭐⭐ = ?', options: ['6', '5', '7'], correctIndex: 0 },
    { type: 'quiz', question: '5 + 5 = ?', hint: 'Show five fingers on each hand!', options: ['9', '11', '10'], correctIndex: 2 },
    { type: 'match', instruction: 'Match the sum to the answer', pairs: [{ left: { text: '1 + 1' }, right: { text: '2' } }, { left: { text: '2 + 2' }, right: { text: '4' } }, { left: { text: '3 + 3' }, right: { text: '6' } }] },
  ]),
  num_compare: lesson('numbers', 34, 'Which Is More?', 'Compare numbers', '⚖️', [
    { type: 'quiz', question: 'Which number is BIGGER?', options: ['3', '7'], correctIndex: 1 },
    { type: 'quiz', question: 'Which number is SMALLER?', options: ['9', '2', '6'], correctIndex: 1 },
    { type: 'count', question: 'How many cars?', emoji: '🚗', count: 6, options: ['5', '6', '7'], correctIndex: 1 },
    { type: 'quiz', question: 'Which number is the BIGGEST?', options: ['10', '4', '8'], correctIndex: 0 },
  ]),
  num_shapes_2: lesson('numbers', 35, 'More Shapes', 'Star, heart, rectangle, oval', '⭐', [
    { type: 'letter', letter: '★', word: 'Star', text: 'A star has five points.', emoji: '⭐', color: '#FFB547' },
    { type: 'letter', letter: '♥', word: 'Heart', text: 'A heart means love.', emoji: '❤️', color: '#FF7A7A' },
    { type: 'letter', letter: '▭', word: 'Rectangle', text: 'A rectangle has two long sides and two short sides.', emoji: '📱', color: '#6CB8FF' },
    { type: 'quiz', question: 'Which one is a heart?', options: [{ emoji: '⭐' }, { emoji: '❤️' }, { emoji: '🔵' }], correctIndex: 1 },
    { type: 'match', instruction: 'Match the shape name', pairs: [{ left: { text: 'star' }, right: { emoji: '⭐' } }, { left: { text: 'heart' }, right: { emoji: '❤️' } }, { left: { text: 'circle' }, right: { emoji: '🔵' } }] },
  ]),
};

// ====================================================================== 5. good-habit stories
const habits = {
  story_wash_hands: lesson('stories', 3, 'Wash Your Hands', 'Clean hands, happy tummy', '🧼', [
    { type: 'story', title: 'Time to eat!', text: 'Mia wants to eat lunch. But first she washes her hands.', highlights: ['washes', 'hands'], emoji: '👧', bgColor: '#DDF3FF' },
    { type: 'story', text: 'She uses soap and water and counts to twenty.', highlights: ['soap', 'water'], emoji: '🧼', bgColor: '#E6F7D9', question: 'What does Mia use?', options: ['Soap and water', 'Sand', 'Juice'], correctIndex: 0 },
    { type: 'quiz', question: 'When should we wash our hands?', options: [{ text: 'Before eating', emoji: '🍽️' }, { text: 'Never', emoji: '🙅' }], correctIndex: 0 },
  ]),
  story_brush_teeth: lesson('stories', 4, 'Brush Your Teeth', 'Shiny smile every day', '🪥', [
    { type: 'story', title: 'Good morning!', text: 'Sam wakes up and brushes his teeth.', highlights: ['brushes', 'teeth'], emoji: '🪥', bgColor: '#FFF1CC' },
    { type: 'story', text: 'He brushes in the morning and at night. His smile is shiny!', highlights: ['morning', 'night'], emoji: '😁', bgColor: '#E9E2FF', question: 'When does Sam brush?', options: ['Morning and night', 'Only on Sunday', 'Never'], correctIndex: 0 },
    { type: 'match', instruction: 'What do we need?', pairs: [{ left: { text: 'toothbrush' }, right: { emoji: '🪥' } }, { left: { text: 'water' }, right: { emoji: '💧' } }, { left: { text: 'smile' }, right: { emoji: '😁' } }] },
  ]),
  bn_story_salam: lesson('bangla', 60, 'ভালো অভ্যাস', 'সালাম ও ধন্যবাদ', '🤝', [
    { type: 'story', title: 'চলো পড়ি!', text: 'রিয়া স্কুলে গিয়ে সবাইকে সালাম দিল।', highlights: ['সালাম'], emoji: '👧', bgColor: '#DDF3FF' },
    { type: 'story', text: 'বন্ধু তাকে পেন্সিল দিল। রিয়া বলল, ধন্যবাদ!', highlights: ['ধন্যবাদ'], emoji: '✏️', bgColor: '#E6F7D9', question: 'রিয়া কী বলল?', options: ['ধন্যবাদ', 'চলে যাও', 'কিছুই না'], correctIndex: 0 },
    { type: 'quiz', question: 'কেউ সাহায্য করলে কী বলি?', options: [{ text: 'ধন্যবাদ', emoji: '🙏' }, { text: 'না', emoji: '🙅' }], correctIndex: 0 },
  ]),
};

const lessons = { ...buildSigns(), ...buildWords(), ...buildCvc(), ...math, ...habits };

const badges = {
  word_explorer: {
    order: 15, isActive: true, title: 'Word Explorer', description: 'Finish 30 lessons in any world.',
    emoji: '🗺️', iconUrl: '', color: '#D7F5E3', rule: { type: 'lessons_completed', value: 30 },
  },
  good_habits: {
    order: 16, isActive: true, title: 'Good Habits', description: 'Finish 3 stories in Story World.',
    emoji: '🧼', iconUrl: '', color: '#DDF3FF', rule: { type: 'world_lessons', value: 3, worldId: 'stories' },
  },
};

module.exports = { lessons, badges };
