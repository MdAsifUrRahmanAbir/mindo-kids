/**
 * Beginner course — extra lessons for the five core subjects
 * (English, Bangla, Math, Arabic, Hindi) plus their badges.
 * Merged into `lessons` / `badges` by seed_data.js.
 *
 * Rule of thumb for demo content: the first lessons of every world are
 * free, the last one is premium so the paywall can be shown.
 */

const lessons = {
  // ---------------- English World (more)
  en_letter_c: {
    worldId: 'english', order: 3, isActive: true, isPremium: false, isDailySpark: false,
    title: 'Letter C', subtitle: 'C is for Cat', emoji: '🐱', thumbnailUrl: '', durationMinutes: 3,
    steps: [
      { type: 'letter', letter: 'C', word: 'Cat', text: 'C is for Cat', emoji: '🐱', color: '#FFB547' },
      { type: 'trace', letter: 'C', instruction: 'Trace the letter C', color: '#FFB547' },
      {
        type: 'quiz', question: 'Which one starts with C?', hint: 'C… C… Car!',
        options: [{ text: 'Car', emoji: '🚗' }, { text: 'Fish', emoji: '🐟' }, { text: 'Ball', emoji: '⚽' }],
        correctIndex: 0,
      },
      {
        type: 'match', instruction: 'Match the letter to the picture',
        pairs: [
          { left: { text: 'A' }, right: { emoji: '🍎' } },
          { left: { text: 'B' }, right: { emoji: '⚽' } },
          { left: { text: 'C' }, right: { emoji: '🐱' } },
        ],
      },
    ],
  },
  en_colors: {
    worldId: 'english', order: 4, isActive: true, isPremium: false, isDailySpark: false,
    title: 'Colours', subtitle: 'Red, blue, green & yellow', emoji: '🎨', thumbnailUrl: '', durationMinutes: 3,
    steps: [
      {
        type: 'story', title: 'Colours everywhere!', text: 'The apple is red. The sky is blue. The grass is green.',
        highlights: ['red', 'blue', 'green'], emoji: '🌈', bgColor: '#FFF1CC',
      },
      { type: 'quiz', question: 'Which one is RED?', options: [{ emoji: '🔵' }, { emoji: '🔴' }, { emoji: '🟢' }], correctIndex: 1 },
      { type: 'quiz', question: 'Which one is YELLOW?', options: [{ emoji: '🟡' }, { emoji: '🟣' }, { emoji: '🔵' }], correctIndex: 0 },
      {
        type: 'match', instruction: 'Match the colour name',
        pairs: [
          { left: { text: 'red' }, right: { emoji: '🔴' } },
          { left: { text: 'blue' }, right: { emoji: '🔵' } },
          { left: { text: 'green' }, right: { emoji: '🟢' } },
        ],
      },
    ],
  },

  // ---------------- Bangla World (more)
  bn_vowels_3: {
    worldId: 'bangla', order: 3, isActive: true, isPremium: false, isDailySpark: false,
    title: 'স্বরবর্ণ উ ঊ', subtitle: 'উ-তে উট', emoji: 'উ', thumbnailUrl: '', durationMinutes: 3,
    steps: [
      { type: 'letter', letter: 'উ', word: 'উট', text: 'উ-তে উট', emoji: '🐪', color: '#FFB547', instruction: 'চলো বর্ণ শিখি!' },
      { type: 'letter', letter: 'ঊ', word: 'ঊষা', text: 'ঊ-তে ঊষা', emoji: '🌅', color: '#FF7A7A' },
      { type: 'trace', letter: 'উ', instruction: 'উ লেখো', color: '#FFB547' },
      {
        type: 'quiz', question: 'কোনটি উট?', hint: 'উ-তে উট!',
        options: [{ text: 'গরু', emoji: '🐄' }, { text: 'উট', emoji: '🐪' }, { text: 'হাতি', emoji: '🐘' }],
        correctIndex: 1,
      },
    ],
  },
  bn_consonants_1: {
    worldId: 'bangla', order: 4, isActive: true, isPremium: false, isDailySpark: false,
    title: 'ব্যঞ্জনবর্ণ ক খ গ', subtitle: 'ক-তে কলা', emoji: 'ক', thumbnailUrl: '', durationMinutes: 4,
    steps: [
      { type: 'letter', letter: 'ক', word: 'কলা', text: 'ক-তে কলা', emoji: '🍌', color: '#FFC24B' },
      { type: 'letter', letter: 'খ', word: 'খরগোশ', text: 'খ-তে খরগোশ', emoji: '🐰', color: '#FF8EC7' },
      { type: 'letter', letter: 'গ', word: 'গরু', text: 'গ-তে গরু', emoji: '🐄', color: '#5FCF97' },
      { type: 'trace', letter: 'ক', instruction: 'ক লেখো', color: '#FFC24B' },
      {
        type: 'match', instruction: 'বর্ণের সাথে ছবি মেলাও',
        pairs: [
          { left: { text: 'ক' }, right: { emoji: '🍌' } },
          { left: { text: 'খ' }, right: { emoji: '🐰' } },
          { left: { text: 'গ' }, right: { emoji: '🐄' } },
        ],
      },
    ],
  },
  bn_numbers: {
    worldId: 'bangla', order: 5, isActive: true, isPremium: false, isDailySpark: false,
    title: 'বাংলা সংখ্যা ১–৫', subtitle: 'এক, দুই, তিন…', emoji: '৫', thumbnailUrl: '', durationMinutes: 3,
    steps: [
      { type: 'letter', letter: '১', word: 'এক', text: 'এক', emoji: '🍎', color: '#6CB8FF', instruction: 'চলো গুনি!' },
      { type: 'letter', letter: '২', word: 'দুই', text: 'দুই', emoji: '🍎🍎', color: '#5FCF97' },
      { type: 'letter', letter: '৩', word: 'তিন', text: 'তিন', emoji: '🍎🍎🍎', color: '#FFB547' },
      { type: 'count', question: 'কয়টি আম আছে?', emoji: '🥭', count: 4, options: ['৩', '৪', '৫'], correctIndex: 1, hint: 'একটি একটি করে গোনো।' },
      {
        type: 'match', instruction: 'সংখ্যার সাথে নাম মেলাও',
        pairs: [
          { left: { text: '১' }, right: { text: 'এক' } },
          { left: { text: '২' }, right: { text: 'দুই' } },
          { left: { text: '৫' }, right: { text: 'পাঁচ' } },
        ],
      },
    ],
  },
  bn_fruits: {
    worldId: 'bangla', order: 6, isActive: true, isPremium: true, isDailySpark: false,
    title: 'ফলের নাম', subtitle: 'আম, কলা, তরমুজ', emoji: '🍉', thumbnailUrl: '', durationMinutes: 3,
    steps: [
      {
        type: 'story', title: 'চলো পড়ি!', text: 'মিনা বাজারে গেল। সে আম আর কলা কিনল।',
        highlights: ['আম', 'কলা'], emoji: '🧺', bgColor: '#FFF1CC',
        question: 'মিনা কী কিনল?', options: ['আম আর কলা', 'মাছ', 'বই'], correctIndex: 0,
      },
      {
        type: 'match', instruction: 'নামের সাথে ফল মেলাও',
        pairs: [
          { left: { text: 'আম' }, right: { emoji: '🥭' } },
          { left: { text: 'কলা' }, right: { emoji: '🍌' } },
          { left: { text: 'তরমুজ' }, right: { emoji: '🍉' } },
        ],
      },
      { type: 'memory', instruction: 'একই ফল খুঁজে বের করো', cards: [{ emoji: '🥭' }, { emoji: '🍌' }, { emoji: '🍉' }] },
    ],
  },

  // ---------------- Math World (more)
  num_count_10: {
    worldId: 'numbers', order: 3, isActive: true, isPremium: false, isDailySpark: false,
    title: 'Count to 10', subtitle: 'Six, seven, eight, nine, ten!', emoji: '🔟', thumbnailUrl: '', durationMinutes: 3,
    steps: [
      { type: 'letter', letter: '7', word: 'Seven', text: 'Seven. Count the fish!', emoji: '🐟', color: '#6CB8FF' },
      { type: 'count', question: 'How many fish?', emoji: '🐟', count: 7, options: ['6', '7', '8'], correctIndex: 1, hint: 'Touch each fish and count.' },
      { type: 'count', question: 'How many flowers?', emoji: '🌸', count: 10, options: ['9', '10', '8'], correctIndex: 1 },
      { type: 'quiz', question: '8, 9, … what comes next?', options: ['10', '7', '6'], correctIndex: 0 },
    ],
  },
  num_shapes: {
    worldId: 'numbers', order: 4, isActive: true, isPremium: false, isDailySpark: false,
    title: 'Shapes', subtitle: 'Circle, square, triangle', emoji: '🔺', thumbnailUrl: '', durationMinutes: 3,
    steps: [
      { type: 'letter', letter: '●', word: 'Circle', text: 'A circle is round, like a ball.', emoji: '⚽', color: '#FF7A7A' },
      { type: 'letter', letter: '▲', word: 'Triangle', text: 'A triangle has three sides.', emoji: '🍕', color: '#FFB547' },
      { type: 'quiz', question: 'Which one is a circle?', options: [{ emoji: '🟥' }, { emoji: '🔺' }, { emoji: '🔵' }], correctIndex: 2 },
      { type: 'quiz', question: 'Which one is a square?', options: [{ emoji: '🟩' }, { emoji: '🔴' }, { emoji: '🔻' }], correctIndex: 0 },
      {
        type: 'match', instruction: 'Match the shape name',
        pairs: [
          { left: { text: 'circle' }, right: { emoji: '🔵' } },
          { left: { text: 'square' }, right: { emoji: '🟨' } },
          { left: { text: 'triangle' }, right: { emoji: '🔺' } },
        ],
      },
    ],
  },
  num_add: {
    worldId: 'numbers', order: 5, isActive: true, isPremium: false, isDailySpark: true,
    title: 'Let’s Add!', subtitle: 'Put them together', emoji: '➕', thumbnailUrl: '', durationMinutes: 3,
    steps: [
      {
        type: 'story', title: 'Adding is fun!', text: 'One apple and one more apple make two apples.',
        highlights: ['One', 'two'], emoji: '🍎➕🍎', bgColor: '#D9F5E4',
      },
      { type: 'quiz', question: '🍎 + 🍎 = ?', options: ['1', '2', '3'], correctIndex: 1 },
      { type: 'quiz', question: '🐥🐥 + 🐥 = ?', options: ['3', '2', '4'], correctIndex: 0 },
      { type: 'quiz', question: '2 + 2 = ?', hint: 'Count on your fingers!', options: ['3', '5', '4'], correctIndex: 2 },
    ],
  },

  // ---------------- Arabic World (RTL)
  ar_alif_ba: {
    worldId: 'arabic', order: 1, isActive: true, isPremium: false, isDailySpark: true,
    title: 'أ ب — Alif & Ba', subtitle: 'أ أرنب، ب بطة', emoji: 'أ', thumbnailUrl: '', durationMinutes: 3,
    steps: [
      { type: 'letter', letter: 'أ', word: 'أرنب', text: 'أ — أرنب', emoji: '🐰', color: '#2EC4B6', instruction: 'هيا نتعلم الحروف!' },
      { type: 'letter', letter: 'ب', word: 'بطة', text: 'ب — بطة', emoji: '🦆', color: '#FFB547' },
      { type: 'trace', letter: 'ب', instruction: 'اكتب حرف الباء', color: '#FFB547' },
      {
        type: 'quiz', question: 'أين البطة؟', hint: 'ب — بطة',
        options: [{ text: 'أرنب', emoji: '🐰' }, { text: 'بطة', emoji: '🦆' }, { text: 'جمل', emoji: '🐪' }],
        correctIndex: 1,
      },
    ],
  },
  ar_ta_tha: {
    worldId: 'arabic', order: 2, isActive: true, isPremium: false, isDailySpark: false,
    title: 'ت ث — Ta & Tha', subtitle: 'ت تفاحة، ث ثعلب', emoji: 'ت', thumbnailUrl: '', durationMinutes: 3,
    steps: [
      { type: 'letter', letter: 'ت', word: 'تفاحة', text: 'ت — تفاحة', emoji: '🍎', color: '#FF7A7A' },
      { type: 'letter', letter: 'ث', word: 'ثعلب', text: 'ث — ثعلب', emoji: '🦊', color: '#FF9F43' },
      { type: 'trace', letter: 'ت', instruction: 'اكتب حرف التاء', color: '#FF7A7A' },
      {
        type: 'match', instruction: 'صِل الحرف بالصورة',
        pairs: [
          { left: { text: 'أ' }, right: { emoji: '🐰' } },
          { left: { text: 'ب' }, right: { emoji: '🦆' } },
          { left: { text: 'ت' }, right: { emoji: '🍎' } },
        ],
      },
    ],
  },
  ar_jeem_ha_kha: {
    worldId: 'arabic', order: 3, isActive: true, isPremium: false, isDailySpark: false,
    title: 'ج ح خ — Jeem, Ha, Kha', subtitle: 'ج جمل، ح حصان، خ خروف', emoji: 'ج', thumbnailUrl: '', durationMinutes: 4,
    steps: [
      { type: 'letter', letter: 'ج', word: 'جمل', text: 'ج — جمل', emoji: '🐪', color: '#FFC24B' },
      { type: 'letter', letter: 'ح', word: 'حصان', text: 'ح — حصان', emoji: '🐴', color: '#8E7CF8' },
      { type: 'letter', letter: 'خ', word: 'خروف', text: 'خ — خروف', emoji: '🐑', color: '#5FCF97' },
      {
        type: 'quiz', question: 'أين الجمل؟', hint: 'ج — جمل',
        options: [{ text: 'حصان', emoji: '🐴' }, { text: 'خروف', emoji: '🐑' }, { text: 'جمل', emoji: '🐪' }],
        correctIndex: 2,
      },
      { type: 'memory', instruction: 'ابحث عن الأزواج', cards: [{ emoji: '🐪' }, { emoji: '🐴' }, { emoji: '🐑' }] },
    ],
  },
  ar_numbers: {
    worldId: 'arabic', order: 4, isActive: true, isPremium: false, isDailySpark: false,
    title: 'الأرقام ١–٣', subtitle: 'واحد، اثنان، ثلاثة', emoji: '٣', thumbnailUrl: '', durationMinutes: 3,
    steps: [
      { type: 'letter', letter: '١', word: 'واحد', text: 'واحد', emoji: '⭐', color: '#2EC4B6', instruction: 'هيا نعد!' },
      { type: 'letter', letter: '٢', word: 'اثنان', text: 'اثنان', emoji: '⭐⭐', color: '#FFB547' },
      { type: 'letter', letter: '٣', word: 'ثلاثة', text: 'ثلاثة', emoji: '⭐⭐⭐', color: '#FF7A7A' },
      { type: 'count', question: 'كم تفاحة؟', emoji: '🍎', count: 3, options: ['٢', '٣', '٤'], correctIndex: 1 },
      {
        type: 'match', instruction: 'صِل الرقم بالنقاط',
        pairs: [
          { left: { text: '١' }, right: { text: '●' } },
          { left: { text: '٢' }, right: { text: '●●' } },
          { left: { text: '٣' }, right: { text: '●●●' } },
        ],
      },
    ],
  },
  ar_colors: {
    worldId: 'arabic', order: 5, isActive: true, isPremium: true, isDailySpark: false,
    title: 'الألوان', subtitle: 'أحمر، أزرق، أصفر', emoji: '🎨', thumbnailUrl: '', durationMinutes: 3,
    steps: [
      {
        type: 'quiz', question: 'ما لون التفاحة؟', hint: '🍎',
        options: [{ text: 'أحمر', emoji: '🔴' }, { text: 'أزرق', emoji: '🔵' }, { text: 'أخضر', emoji: '🟢' }],
        correctIndex: 0,
      },
      {
        type: 'match', instruction: 'صِل اللون باسمه',
        pairs: [
          { left: { text: 'أحمر' }, right: { emoji: '🔴' } },
          { left: { text: 'أزرق' }, right: { emoji: '🔵' } },
          { left: { text: 'أصفر' }, right: { emoji: '🟡' } },
        ],
      },
    ],
  },

  // ---------------- Hindi World
  hi_vowels_1: {
    worldId: 'hindi', order: 1, isActive: true, isPremium: false, isDailySpark: true,
    title: 'स्वर अ आ', subtitle: 'अ से अनानास, आ से आम', emoji: 'अ', thumbnailUrl: '', durationMinutes: 3,
    steps: [
      { type: 'letter', letter: 'अ', word: 'अनानास', text: 'अ से अनानास', emoji: '🍍', color: '#FF9F43', instruction: 'चलो अक्षर सीखें!' },
      { type: 'letter', letter: 'आ', word: 'आम', text: 'आ से आम', emoji: '🥭', color: '#FFC24B' },
      { type: 'trace', letter: 'अ', instruction: 'अ लिखो', color: '#FF9F43' },
      {
        type: 'quiz', question: 'आम कौन सा है?', hint: 'आ से आम!',
        options: [{ text: 'केला', emoji: '🍌' }, { text: 'आम', emoji: '🥭' }, { text: 'सेब', emoji: '🍎' }],
        correctIndex: 1,
      },
    ],
  },
  hi_vowels_2: {
    worldId: 'hindi', order: 2, isActive: true, isPremium: false, isDailySpark: false,
    title: 'स्वर इ ई उ', subtitle: 'इ से इंजन, उ से उल्लू', emoji: 'इ', thumbnailUrl: '', durationMinutes: 3,
    steps: [
      { type: 'letter', letter: 'इ', word: 'इंजन', text: 'इ से इंजन', emoji: '🚂', color: '#6CB8FF' },
      { type: 'letter', letter: 'ई', word: 'ईंट', text: 'ई से ईंट', emoji: '🧱', color: '#FF7A7A' },
      { type: 'letter', letter: 'उ', word: 'उल्लू', text: 'उ से उल्लू', emoji: '🦉', color: '#8E7CF8' },
      {
        type: 'match', instruction: 'अक्षर को चित्र से मिलाओ',
        pairs: [
          { left: { text: 'इ' }, right: { emoji: '🚂' } },
          { left: { text: 'ई' }, right: { emoji: '🧱' } },
          { left: { text: 'उ' }, right: { emoji: '🦉' } },
        ],
      },
    ],
  },
  hi_consonants_1: {
    worldId: 'hindi', order: 3, isActive: true, isPremium: false, isDailySpark: false,
    title: 'व्यंजन क ख ग', subtitle: 'क से कबूतर', emoji: 'क', thumbnailUrl: '', durationMinutes: 4,
    steps: [
      { type: 'letter', letter: 'क', word: 'कबूतर', text: 'क से कबूतर', emoji: '🕊️', color: '#6CB8FF' },
      { type: 'letter', letter: 'ख', word: 'खरगोश', text: 'ख से खरगोश', emoji: '🐰', color: '#FF8EC7' },
      { type: 'letter', letter: 'ग', word: 'गाय', text: 'ग से गाय', emoji: '🐄', color: '#5FCF97' },
      { type: 'trace', letter: 'क', instruction: 'क लिखो', color: '#6CB8FF' },
      {
        type: 'quiz', question: 'खरगोश कौन सा है?', hint: 'ख से खरगोश!',
        options: [{ text: 'गाय', emoji: '🐄' }, { text: 'कबूतर', emoji: '🕊️' }, { text: 'खरगोश', emoji: '🐰' }],
        correctIndex: 2,
      },
    ],
  },
  hi_numbers: {
    worldId: 'hindi', order: 4, isActive: true, isPremium: false, isDailySpark: false,
    title: 'गिनती १–५', subtitle: 'एक, दो, तीन…', emoji: '५', thumbnailUrl: '', durationMinutes: 3,
    steps: [
      { type: 'letter', letter: '१', word: 'एक', text: 'एक', emoji: '🎈', color: '#FF7A7A', instruction: 'चलो गिनें!' },
      { type: 'letter', letter: '२', word: 'दो', text: 'दो', emoji: '🎈🎈', color: '#6CB8FF' },
      { type: 'letter', letter: '३', word: 'तीन', text: 'तीन', emoji: '🎈🎈🎈', color: '#5FCF97' },
      { type: 'count', question: 'कितने सेब हैं?', emoji: '🍎', count: 4, options: ['३', '४', '५'], correctIndex: 1, hint: 'एक-एक करके गिनो।' },
      {
        type: 'match', instruction: 'अंक को नाम से मिलाओ',
        pairs: [
          { left: { text: '१' }, right: { text: 'एक' } },
          { left: { text: '२' }, right: { text: 'दो' } },
          { left: { text: '५' }, right: { text: 'पाँच' } },
        ],
      },
    ],
  },
  hi_fruits: {
    worldId: 'hindi', order: 5, isActive: true, isPremium: true, isDailySpark: false,
    title: 'फलों के नाम', subtitle: 'सेब, केला, अंगूर', emoji: '🍇', thumbnailUrl: '', durationMinutes: 3,
    steps: [
      {
        type: 'story', title: 'चलो पढ़ें!', text: 'राजू को केला पसंद है। मीना को अंगूर पसंद हैं।',
        highlights: ['केला', 'अंगूर'], emoji: '🧺', bgColor: '#FFF1CC',
        question: 'राजू को क्या पसंद है?', options: ['केला', 'अंगूर', 'सेब'], correctIndex: 0,
      },
      {
        type: 'match', instruction: 'नाम को फल से मिलाओ',
        pairs: [
          { left: { text: 'सेब' }, right: { emoji: '🍎' } },
          { left: { text: 'केला' }, right: { emoji: '🍌' } },
          { left: { text: 'अंगूर' }, right: { emoji: '🍇' } },
        ],
      },
      { type: 'memory', instruction: 'जोड़ी ढूँढो', cards: [{ emoji: '🍎' }, { emoji: '🍌' }, { emoji: '🍇' }] },
    ],
  },
};

const badges = {
  bangla_star: {
    order: 10, isActive: true, title: 'Bangla Star', description: 'Finish 2 lessons in Bangla World.',
    emoji: '🌸', iconUrl: '', color: '#DDEBFF', rule: { type: 'world_lessons', value: 2, worldId: 'bangla' },
  },
  arabic_star: {
    order: 11, isActive: true, title: 'Arabic Star', description: 'Finish 2 lessons in Arabic World.',
    emoji: '🌙', iconUrl: '', color: '#D4F5F1', rule: { type: 'world_lessons', value: 2, worldId: 'arabic' },
  },
  hindi_star: {
    order: 12, isActive: true, title: 'Hindi Star', description: 'Finish 2 lessons in Hindi World.',
    emoji: '🪔', iconUrl: '', color: '#FFE6CC', rule: { type: 'world_lessons', value: 2, worldId: 'hindi' },
  },
};

module.exports = { lessons, badges };
