/**
 * Alphabet (বর্ণমালা) course — full letter tracks for English, Bangla,
 * Hindi, Arabic, Urdu and number symbols for Math.
 *
 * Lessons are GENERATED from the letter tables below: every group of
 * letters becomes one lesson with
 *   letter card (per letter) → trace → "where is the …?" quiz → match.
 * To add/fix a letter just edit its row and re-run `node seed.js`.
 *
 * Row format: [letter, word, emoji, customText?]
 *   customText is used when the letter is not at the start of the word
 *   (e.g. ঙ — ব্যাঙ), otherwise the language template is used.
 */

const COLORS = ['#FF7A7A', '#6CB8FF', '#5FCF97', '#FFB547', '#8E7CF8', '#FF8EC7', '#2EC4B6', '#FF9F43'];
const START_ORDER = 10; // after the hand-made lessons of each world

// ---------------------------------------------------------------- languages
const LANG = {
  en: {
    letterText: (l, w) => `${l} is for ${w}`,
    trace: (l) => `Trace the letter ${l}`,
    quiz: (w) => `Where is the ${w}?`,
    match: 'Match the letter to the picture',
    title: (ls) => `Letters ${ls.join(' ')}`,
    reviewTitle: 'ABC Review',
    reviewMemory: 'Find the pairs',
    hello: 'Meet the new letters!',
  },
  bn: {
    letterText: (l, w) => `${l}-তে ${w}`,
    trace: (l) => `${l} লেখো`,
    quiz: (w) => `${w} কোনটি?`,
    match: 'বর্ণের সাথে ছবি মেলাও',
    title: (ls) => `বর্ণ ${ls.join(' ')}`,
    reviewTitle: 'বর্ণমালা রিভিউ',
    reviewMemory: 'একই ছবি খুঁজে বের করো',
    hello: 'চলো নতুন বর্ণ শিখি!',
  },
  hi: {
    letterText: (l, w) => `${l} से ${w}`,
    trace: (l) => `${l} लिखो`,
    quiz: (w) => `${w} कौन सा है?`,
    match: 'अक्षर को चित्र से मिलाओ',
    title: (ls) => `अक्षर ${ls.join(' ')}`,
    reviewTitle: 'वर्णमाला दोहराओ',
    reviewMemory: 'जोड़ी ढूँढो',
    hello: 'चलो नए अक्षर सीखें!',
  },
  ar: {
    letterText: (l, w) => `${l} — ${w}`,
    trace: (l) => `اكتب الحرف ${l}`,
    quiz: (w) => `أشِر إلى: ${w}`,
    match: 'صِل الحرف بالصورة',
    title: (ls) => `حروف ${ls.join(' ')}`,
    reviewTitle: 'مراجعة الحروف',
    reviewMemory: 'ابحث عن الأزواج',
    hello: 'هيا نتعلم حروفًا جديدة!',
  },
  ur: {
    letterText: (l, w) => `${l} سے ${w}`,
    trace: (l) => `${l} لکھو`,
    quiz: (w) => `${w} کہاں ہے؟`,
    match: 'حرف کو تصویر سے ملاؤ',
    title: (ls) => `حروف ${ls.join(' ')}`,
    reviewTitle: 'حروفِ تہجی دہرائیں',
    reviewMemory: 'جوڑے تلاش کرو',
    hello: 'آؤ نئے حروف سیکھیں!',
  },
};

// ---------------------------------------------------------------- letter tables
// Each inner array is one lesson.
const TRACKS = {
  english: {
    lang: 'en', prefix: 'en_abc',
    groups: [
      [['D', 'Dog', '🐶'], ['E', 'Elephant', '🐘'], ['F', 'Fish', '🐟']],
      [['G', 'Grapes', '🍇'], ['H', 'Hat', '🎩'], ['I', 'Ice cream', '🍦']],
      [['J', 'Juice', '🧃'], ['K', 'Kite', '🪁'], ['L', 'Lion', '🦁']],
      [['M', 'Moon', '🌙'], ['N', 'Nest', '🪺'], ['O', 'Orange', '🍊']],
      [['P', 'Pig', '🐷'], ['Q', 'Queen', '👸'], ['R', 'Rabbit', '🐰']],
      [['S', 'Sun', '☀️'], ['T', 'Tiger', '🐯'], ['U', 'Umbrella', '☂️']],
      [['V', 'Van', '🚐'], ['W', 'Watch', '⌚'], ['X', 'Fox', '🦊', 'X is at the end of Fox']],
      [['Y', 'Yo-yo', '🪀'], ['Z', 'Zebra', '🦓']],
    ],
  },
  bangla: {
    lang: 'bn', prefix: 'bn_abc',
    groups: [
      // স্বরবর্ণ (অ–ঊ are in the hand-made lessons)
      [['ঋ', 'ঋষি', '🧘'], ['এ', 'একতারা', '🪕'], ['ঐ', 'ঐরাবত', '🐘']],
      [['ও', 'ওল', '🥔'], ['ঔ', 'ঔষধ', '💊']],
      // ব্যঞ্জনবর্ণ (ক খ গ are in the hand-made lessons)
      [['ঘ', 'ঘড়ি', '⏰'], ['ঙ', 'ব্যাঙ', '🐸', 'ঙ — ব্যাঙ'], ['চ', 'চাঁদ', '🌙']],
      [['ছ', 'ছাতা', '☂️'], ['জ', 'জাহাজ', '🚢'], ['ঝ', 'ঝিনুক', '🐚']],
      [['ঞ', 'মিঞা', '🧔', 'ঞ — মিঞা'], ['ট', 'টমেটো', '🍅'], ['ঠ', 'ঠোঁট', '👄']],
      [['ড', 'ডাব', '🥥'], ['ঢ', 'ঢোল', '🥁'], ['ণ', 'হরিণ', '🦌', 'ণ — হরিণ']],
      [['ত', 'তালা', '🔒'], ['থ', 'থালা', '🍽️'], ['দ', 'দরজা', '🚪']],
      [['ধ', 'ধান', '🌾'], ['ন', 'নৌকা', '⛵'], ['প', 'পাখি', '🐦']],
      [['ফ', 'ফুল', '🌸'], ['ব', 'বই', '📖'], ['ভ', 'ভালুক', '🐻']],
      [['ম', 'মাছ', '🐟'], ['য', 'যান', '🚗'], ['র', 'রাজা', '🤴']],
      [['ল', 'লাটিম', '🪀'], ['শ', 'শাপলা', '🪷'], ['ষ', 'ষাঁড়', '🐂']],
      [['স', 'সাপ', '🐍'], ['হ', 'হাঁস', '🦆'], ['ড়', 'পাহাড়', '⛰️', 'ড় — পাহাড়']],
      [['ঢ়', 'আষাঢ়', '🌧️', 'ঢ় — আষাঢ়'], ['য়', 'ময়ূর', '🦚', 'য় — ময়ূর'], ['ৎ', 'উৎসব', '🎉', 'ৎ — উৎসব']],
      [['ং', 'রং', '🎨', 'ং — রং'], ['ঃ', 'দুঃখ', '😢', 'ঃ — দুঃখ'], ['ঁ', 'চাঁদ', '🌙', 'ঁ — চাঁদ']],
    ],
  },
  hindi: {
    lang: 'hi', prefix: 'hi_abc',
    groups: [
      // स्वर (अ–उ are in the hand-made lessons)
      [['ऊ', 'ऊन', '🧶'], ['ऋ', 'ऋषि', '🧘'], ['ए', 'एड़ी', '🦶']],
      [['ऐ', 'ऐनक', '👓'], ['ओ', 'ओस', '💧'], ['औ', 'औरत', '👩'], ['अं', 'अंगूर', '🍇']],
      // व्यंजन (क ख ग are in the hand-made lessons)
      [['घ', 'घड़ी', '⏰'], ['ङ', 'पंख', '🪶', 'ङ — नासिक ध्वनि'], ['च', 'चम्मच', '🥄']],
      [['छ', 'छाता', '☂️'], ['ज', 'जहाज़', '🚢'], ['झ', 'झंडा', '🚩']],
      [['ञ', 'मंजन', '🪥', 'ञ — नासिक ध्वनि'], ['ट', 'टमाटर', '🍅'], ['ठ', 'ठेला', '🛒']],
      [['ड', 'डमरू', '🪘'], ['ढ', 'ढोल', '🥁'], ['ण', 'बाण', '🏹', 'ण — बाण']],
      [['त', 'तरबूज़', '🍉'], ['थ', 'थाली', '🍽️'], ['द', 'दरवाज़ा', '🚪']],
      [['ध', 'धागा', '🧵'], ['न', 'नल', '🚰'], ['प', 'पतंग', '🪁']],
      [['फ', 'फल', '🍎'], ['ब', 'बकरी', '🐐'], ['भ', 'भालू', '🐻']],
      [['म', 'मछली', '🐟'], ['य', 'यात्री', '🧳'], ['र', 'रस्सी', '🪢']],
      [['ल', 'लट्टू', '🪀'], ['व', 'वन', '🌳'], ['श', 'शेर', '🦁']],
      [['ष', 'षट्कोण', '⬢'], ['स', 'सेब', '🍏'], ['ह', 'हाथी', '🐘']],
      [['क्ष', 'क्षत्रिय', '🤺'], ['त्र', 'त्रिभुज', '🔺'], ['ज्ञ', 'ज्ञानी', '🧙']],
    ],
  },
  arabic: {
    lang: 'ar', prefix: 'ar_abc',
    groups: [
      // أ – خ are in the hand-made lessons
      [['د', 'ديك', '🐓'], ['ذ', 'ذرة', '🌽'], ['ر', 'ريشة', '🪶']],
      [['ز', 'زرافة', '🦒'], ['س', 'سمكة', '🐟'], ['ش', 'شمس', '☀️']],
      [['ص', 'صقر', '🦅'], ['ض', 'ضفدع', '🐸'], ['ط', 'طائرة', '✈️']],
      [['ظ', 'ظرف', '✉️'], ['ع', 'عين', '👁️'], ['غ', 'غيمة', '☁️']],
      [['ف', 'فيل', '🐘'], ['ق', 'قمر', '🌙'], ['ك', 'كتاب', '📖']],
      [['ل', 'ليمون', '🍋'], ['م', 'موز', '🍌'], ['ن', 'نحلة', '🐝']],
      [['ه', 'هدية', '🎁'], ['و', 'وردة', '🌹'], ['ي', 'يد', '✋']],
    ],
  },
  urdu: {
    lang: 'ur', prefix: 'ur_abc', startOrder: 1,
    groups: [
      [['ا', 'اونٹ', '🐪'], ['ب', 'بکری', '🐐'], ['پ', 'پتنگ', '🪁']],
      [['ت', 'تتلی', '🦋'], ['ٹ', 'ٹماٹر', '🍅'], ['ث', 'ثمر', '🍒']],
      [['ج', 'جہاز', '🚢'], ['چ', 'چاند', '🌙'], ['ح', 'حلوہ', '🍮']],
      [['خ', 'خرگوش', '🐰'], ['د', 'دروازہ', '🚪'], ['ڈ', 'ڈبہ', '📦']],
      [['ذ', 'ذائقہ', '👅'], ['ر', 'رسی', '🪢'], ['ڑ', 'پہاڑ', '⛰️', 'ڑ — پہاڑ']],
      [['ز', 'زرافہ', '🦒'], ['ژ', 'ژالہ', '🌨️'], ['س', 'سیب', '🍎']],
      [['ش', 'شیر', '🦁'], ['ص', 'صابن', '🧼'], ['ض', 'ضعیف', '👴']],
      [['ط', 'طوطا', '🦜'], ['ظ', 'ظرف', '✉️'], ['ع', 'عینک', '👓']],
      [['غ', 'غبارہ', '🎈'], ['ف', 'فوارہ', '⛲'], ['ق', 'قلم', '🖊️']],
      [['ک', 'کتاب', '📖'], ['گ', 'گائے', '🐄'], ['ل', 'لڑکا', '👦']],
      [['م', 'مچھلی', '🐟'], ['ن', 'ناک', '👃'], ['و', 'وقت', '⏰']],
      [['ہ', 'ہاتھی', '🐘'], ['ی', 'یاقوت', '💎'], ['ے', 'پتے', '🍃', 'ے — پتے']],
    ],
  },
};

// ---------------------------------------------------------------- generator
function rotate(arr, n) {
  const k = ((n % arr.length) + arr.length) % arr.length;
  return arr.slice(k).concat(arr.slice(0, k));
}

function buildAlphabetLessons() {
  const lessons = {};
  let color = 0;

  for (const [worldId, track] of Object.entries(TRACKS)) {
    const L = LANG[track.lang];
    const start = track.startOrder ?? START_ORDER;
    const all = [];

    track.groups.forEach((group, gi) => {
      const rows = group.map(([letter, word, emoji, custom]) => ({ letter, word, emoji, text: custom || L.letterText(letter, word) }));
      all.push(...rows);
      const steps = [];

      rows.forEach((r, i) => {
        steps.push({
          type: 'letter', letter: r.letter, word: r.word, text: r.text, emoji: r.emoji,
          color: COLORS[color++ % COLORS.length], ...(i === 0 ? { instruction: L.hello } : {}),
        });
      });

      steps.push({ type: 'trace', letter: rows[0].letter, instruction: L.trace(rows[0].letter), color: COLORS[gi % COLORS.length] });

      // Quiz: find one word of this group among its neighbours.
      const target = rows[gi % rows.length];
      let pool = rows.slice();
      if (pool.length < 3 && all.length > pool.length) pool = all.slice(-3);
      pool = rotate(pool, gi);
      steps.push({
        type: 'quiz', question: L.quiz(target.word), hint: target.text,
        options: pool.map((r) => ({ text: r.word, emoji: r.emoji })),
        correctIndex: pool.indexOf(target),
      });

      // Match letter → picture (pad small groups with the previous letters).
      const matchRows = rows.length >= 3 ? rows : all.slice(-3);
      steps.push({
        type: 'match', instruction: L.match,
        pairs: matchRows.map((r) => ({ left: { text: r.letter }, right: { emoji: r.emoji } })),
      });

      const id = `${track.prefix}_${String(gi + 1).padStart(2, '0')}`;
      lessons[id] = {
        worldId, order: start + gi, isActive: true, isPremium: false, isDailySpark: false,
        title: L.title(rows.map((r) => r.letter)),
        subtitle: rows.map((r) => `${r.letter} ${r.word}`).join(' · '),
        emoji: rows[0].letter, thumbnailUrl: '', durationMinutes: 3,
        steps,
      };
    });

    // Review lesson at the end of each track: memory game + mixed match.
    const pick = (n, off) => Array.from({ length: n }, (_, i) => all[(off + i * Math.max(1, Math.floor(all.length / n))) % all.length]);
    const mem = pick(4, 0);
    const mix = pick(3, 1);
    lessons[`${track.prefix}_review`] = {
      worldId, order: start + track.groups.length, isActive: true, isPremium: false, isDailySpark: false,
      title: L.reviewTitle, subtitle: all.map((r) => r.letter).join(' '),
      emoji: '🔤', thumbnailUrl: '', durationMinutes: 4,
      steps: [
        { type: 'memory', instruction: L.reviewMemory, cards: mem.map((r) => ({ emoji: r.emoji })) },
        { type: 'match', instruction: L.match, pairs: mix.map((r) => ({ left: { text: r.letter }, right: { emoji: r.emoji } })) },
      ],
    };
  }
  return lessons;
}

// ---------------------------------------------------------------- math: number symbols 0–20
const NUMBERS = [
  [0, 'Zero', '⭕', 'Zero — nothing at all!'],
  [1, 'One', '🍎'], [2, 'Two', '🍎'], [3, 'Three', '🍎'], [4, 'Four', '⭐'], [5, 'Five', '⭐'],
  [6, 'Six', '🐟'], [7, 'Seven', '🐟'], [8, 'Eight', '🎈'], [9, 'Nine', '🎈'], [10, 'Ten', '🌸'],
  [11, 'Eleven'], [12, 'Twelve'], [13, 'Thirteen'], [14, 'Fourteen'], [15, 'Fifteen'],
  [16, 'Sixteen'], [17, 'Seventeen'], [18, 'Eighteen'], [19, 'Nineteen'], [20, 'Twenty'],
];
const NUM_GROUPS = [[0, 1, 2], [3, 4, 5], [6, 7, 8], [9, 10], [11, 12, 13], [14, 15, 16], [17, 18, 19, 20]];

function buildNumberLessons() {
  const lessons = {};
  NUM_GROUPS.forEach((group, gi) => {
    const rows = group.map((n) => {
      const [, word, emoji, custom] = NUMBERS[n];
      const pic = n === 0 ? '⭕' : n <= 10 ? emoji.repeat(n) : '🔟' + '⭐'.repeat(n - 10);
      const text = custom || (n <= 10 ? `${word}. Count them: ${word.toLowerCase()}!` : `${word} is ten and ${n - 10} more.`);
      return { n, word, pic, text, emoji: emoji || '⭐' };
    });
    const steps = rows.map((r, i) => ({
      type: 'letter', letter: String(r.n), word: r.word, text: r.text, emoji: r.pic,
      color: COLORS[(gi + i) % COLORS.length], ...(i === 0 ? { instruction: 'Meet the numbers!' } : {}),
    }));
    steps.push({ type: 'trace', letter: String(rows[rows.length - 1].n), instruction: `Trace the number ${rows[rows.length - 1].n}`, color: COLORS[gi % COLORS.length] });

    // Find the number symbol
    const target = rows[gi % rows.length];
    const opts = rotate(rows.map((r) => String(r.n)), gi + 1);
    steps.push({ type: 'quiz', question: `Which one is ${target.word}?`, hint: `Look for ${target.n}`, options: opts, correctIndex: opts.indexOf(String(target.n)) });

    // Counting (only meaningful up to 10)
    const countable = rows.filter((r) => r.n >= 1 && r.n <= 10);
    if (countable.length) {
      const c = countable[countable.length - 1];
      const choices = [c.n - 1, c.n, c.n + 1].map(String);
      const rot = rotate(choices, gi);
      steps.push({ type: 'count', question: 'How many do you see?', emoji: c.emoji, count: c.n, options: rot, correctIndex: rot.indexOf(String(c.n)), hint: 'Touch each one and count.' });
    }

    steps.push({
      type: 'match', instruction: 'Match the number to its name',
      pairs: rows.slice(0, 3).map((r) => ({ left: { text: String(r.n) }, right: { text: r.word } })),
    });

    lessons[`num_abc_${String(gi + 1).padStart(2, '0')}`] = {
      worldId: 'numbers', order: START_ORDER + gi, isActive: true, isPremium: false, isDailySpark: false,
      title: `Numbers ${group[0]}–${group[group.length - 1]}`,
      subtitle: rows.map((r) => r.word).join(', '),
      emoji: String(group[0]), thumbnailUrl: '', durationMinutes: 3,
      steps,
    };
  });
  return lessons;
}

const lessons = { ...buildAlphabetLessons(), ...buildNumberLessons() };

const badges = {
  urdu_star: {
    order: 13, isActive: true, title: 'Urdu Star', description: 'Finish 2 lessons in Urdu World.',
    emoji: '🌟', iconUrl: '', color: '#E3F6E8', rule: { type: 'world_lessons', value: 2, worldId: 'urdu' },
  },
  alphabet_hero: {
    order: 14, isActive: true, title: 'Alphabet Hero', description: 'Finish 20 lessons in any world.',
    emoji: '🔤', iconUrl: '', color: '#E2DAFF', rule: { type: 'lessons_completed', value: 20 },
  },
};

module.exports = { lessons, badges };
