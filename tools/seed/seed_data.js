/**
 * Sample content for Mindo Kids — mirrors the UI demo and the concept doc.
 * Every field here is what the admin panel will later create/edit.
 * Images: emoji are used so the app works before any upload; add
 * imageUrl / iconUrl / thumbnailUrl (Firebase Storage download URLs) later
 * and they automatically take priority.
 */

// ---------------------------------------------------------------- config
const config = {
  app: {
    appName: 'Mindo Kids',
    tagline: 'Little Minds. Infinite Worlds.',
    supportEmail: '',
    maintenanceMode: false,
    maintenanceMessage: '',
    ageBands: ['1.5–3', '3–4', '4–5', '5–6'],
    defaultDailyLimitMinutes: 0,
    correctSoundUrl: '',
    wrongSoundUrl: '',
    completeSoundUrl: '',
    praiseMessages: ['Great job! 🌟', 'Super! 🎉', 'You did it! 💪', 'Awesome! ✨', 'Brilliant! 🧠'],
    retryMessages: ['Almost! Try again 🙂', "Let's try once more 💜", 'Good try! Look again 👀'],
  },
  paywall: {
    title: 'Unlock every world',
    subtitle: 'One family subscription for all lessons, stories and brain games.',
    benefits: [
      'All learning worlds: English, Bangla, Numbers & more',
      'Story Worlds and Brain Power games',
      'New lessons added every month',
      'Up to 5 child profiles, no ads ever',
    ],
    ctaText: 'Start Mindo Plus',
    restoreText: 'Restore purchases',
    footerNote:
      'Payment is charged to your Google Play account. The subscription renews automatically unless cancelled at least 24 hours before the end of the period. Manage or cancel anytime in Google Play.',
    emoji: '🚀',
    imageUrl: '',
  },
  // config/strings is filled from strings.json (every UI label + default).
};

// ------------------------------------------------------------ onboarding
const onboarding = {
  welcome: {
    order: 1,
    isActive: true,
    title: 'Big Dreams Start Here',
    subtitle: 'A fun and personalized learning app that helps kids build skills, confidence and a brighter future.',
    emoji: '👧🏽',
    imageUrl: '',
    sideNote: 'Curious Minds Brighter Futures',
    accentColor: '#FFD6E4',
  },
  worlds: {
    order: 2,
    isActive: true,
    title: 'Learn in Many Languages',
    subtitle: 'English, Bangla, numbers, stories and brain games — in short, calm sessions.',
    emoji: '🌍',
    imageUrl: '',
    sideNote: 'Little Minds Infinite Worlds',
    accentColor: '#D7F5E3',
  },
  parents: {
    order: 3,
    isActive: true,
    title: 'Grown-ups Stay in Control',
    subtitle: 'Follow progress, set screen time and keep purchases behind a parent gate.',
    emoji: '👨‍👩‍👧',
    imageUrl: '',
    sideNote: 'Safe & Happy Learning',
    accentColor: '#E2DAFF',
  },
};

// ---------------------------------------------------------------- worlds
const worlds = {
  english: {
    order: 1,
    isActive: true,
    title: 'English World',
    subtitle: 'Letters, sounds & first words',
    description: 'A–Z, uppercase and lowercase, picture words and pronunciation.',
    emoji: '📖',
    iconUrl: '',
    color: '#8E7CF8',
    language: 'en',
    ttsLocale: 'en-US',
    isRtl: false,
  },
  numbers: {
    order: 2,
    isActive: true,
    title: 'Number World',
    subtitle: 'Count, play and grow',
    description: 'Counting, number recognition, quantities and simple sequences.',
    emoji: '🔢',
    iconUrl: '',
    color: '#5FCF97',
    language: 'en',
    ttsLocale: 'en-US',
    isRtl: false,
  },
  brain: {
    order: 3,
    isActive: true,
    title: 'Brain Power',
    subtitle: 'Memory, patterns & puzzles',
    description: 'Memory cards, patterns, matching and attention games.',
    emoji: '🧠',
    iconUrl: '',
    color: '#FF8E8E',
    language: 'en',
    ttsLocale: 'en-US',
    isRtl: false,
  },
  stories: {
    order: 4,
    isActive: true,
    title: 'Story World',
    subtitle: 'Read, listen & imagine',
    description: 'Interactive stories with friendly characters and little questions.',
    emoji: '🦁',
    iconUrl: '',
    color: '#FFC24B',
    language: 'en',
    ttsLocale: 'en-US',
    isRtl: false,
  },
  bangla: {
    order: 5,
    isActive: true,
    title: 'Bangla World',
    subtitle: 'বাংলা বর্ণ ও শব্দ',
    description: 'স্বরবর্ণ, ব্যঞ্জনবর্ণ আর ছবির সাথে নতুন শব্দ।',
    emoji: 'অ',
    iconUrl: '',
    color: '#6CB8FF',
    language: 'bn',
    ttsLocale: 'bn-BD',
    isRtl: false,
  },
};

// ---------------------------------------------------------------- lessons
// Each lesson: metadata + `steps` (written to lessons/{id}/steps/{stepId}).
const A_STROKES = [
  { points: [0.5, 0.2, 0.29, 0.8] },
  { points: [0.5, 0.2, 0.71, 0.8] },
  { points: [0.37, 0.58, 0.63, 0.58] },
];

const lessons = {
  // ---------------- English World
  en_letter_a: {
    worldId: 'english', order: 1, isActive: true, isPremium: false, isDailySpark: false,
    title: 'Letter A', subtitle: 'A is for Apple', emoji: '🍎', thumbnailUrl: '', durationMinutes: 3,
    steps: [
      { type: 'letter', letter: 'A', word: 'Apple', text: 'A is for Apple', emoji: '🍎', color: '#FF7A7A', instruction: 'Meet the letter A!' },
      { type: 'trace', letter: 'A', instruction: 'Trace the letter A', color: '#8E7CF8', strokes: A_STROKES },
      {
        type: 'quiz', question: 'Which one starts with A?', hint: 'Say it out loud: A… A…',
        options: [{ text: 'Apple', emoji: '🍎' }, { text: 'Dog', emoji: '🐶' }, { text: 'Sun', emoji: '☀️' }],
        correctIndex: 0,
      },
      {
        type: 'match', instruction: 'Match big and small letters',
        pairs: [
          { left: { text: 'A' }, right: { text: 'a' } },
          { left: { text: 'B' }, right: { text: 'b' } },
          { left: { text: 'C' }, right: { text: 'c' } },
        ],
      },
    ],
  },
  en_letter_b: {
    worldId: 'english', order: 2, isActive: true, isPremium: false, isDailySpark: false,
    title: 'Letter B', subtitle: 'B is for Ball', emoji: '⚽', thumbnailUrl: '', durationMinutes: 3,
    steps: [
      { type: 'letter', letter: 'B', word: 'Ball', text: 'B is for Ball', emoji: '⚽', color: '#6CB8FF' },
      { type: 'trace', letter: 'B', instruction: 'Trace the letter B', color: '#6CB8FF' },
      {
        type: 'quiz', question: 'Which one starts with B?', hint: 'B… B… Ball!',
        options: [{ text: 'Cat', emoji: '🐱' }, { text: 'Banana', emoji: '🍌' }, { text: 'Fish', emoji: '🐟' }],
        correctIndex: 1,
      },
    ],
  },
  en_cat_story: {
    worldId: 'english', order: 3, isActive: true, isPremium: false, isDailySpark: true,
    title: 'The Cat on the Mat', subtitle: 'Read with Kitty', emoji: '🐱', thumbnailUrl: '', durationMinutes: 4,
    steps: [
      {
        type: 'story', title: "Let's Read!", text: 'The cat sits on the mat. It is a sunny day.',
        highlights: ['cat', 'mat'], emoji: '🐱', bgColor: '#CDEBFF',
        question: 'What is the cat sitting on?', options: ['A bed', 'A mat', 'A table'], correctIndex: 1,
      },
      {
        type: 'story', title: "Let's Read!", text: 'The cat sees a red ball.',
        highlights: ['red', 'ball'], emoji: '🔴', bgColor: '#D9F5E4',
        question: 'What colour is the ball?', options: ['Blue', 'Red', 'Green'], correctIndex: 1,
      },
      {
        type: 'story', title: "Let's Read!", text: 'The cat plays and plays. Then the cat takes a nap!',
        highlights: ['plays', 'nap'], emoji: '😴', bgColor: '#E9E2FF',
      },
      {
        type: 'quiz', question: 'Who takes a nap on the mat?',
        options: [{ text: 'Dog', emoji: '🐶' }, { text: 'Cat', emoji: '🐱' }, { text: 'Bird', emoji: '🐦' }],
        correctIndex: 1,
      },
      {
        type: 'match', instruction: 'Match the word to the picture',
        pairs: [
          { left: { text: 'cat' }, right: { emoji: '🐱' } },
          { left: { text: 'sun' }, right: { emoji: '☀️' } },
          { left: { text: 'ball' }, right: { emoji: '⚽' } },
        ],
      },
    ],
  },
  en_animals: {
    worldId: 'english', order: 4, isActive: true, isPremium: true, isDailySpark: false,
    title: 'Animals Around Us', subtitle: 'Farm friends and what they give', emoji: '🦁', thumbnailUrl: '', durationMinutes: 4,
    steps: [
      {
        type: 'story', text: 'On the farm the cow says moo and the hen says cluck.',
        highlights: ['cow', 'hen'], emoji: '🐄', bgColor: '#E6F7D9',
      },
      {
        type: 'quiz', question: 'Which animal says “Moo”?',
        options: [{ text: 'Cow', emoji: '🐄' }, { text: 'Sheep', emoji: '🐑' }, { text: 'Rooster', emoji: '🐓' }],
        correctIndex: 0,
      },
      {
        type: 'match', instruction: 'What do they give us?',
        pairs: [
          { left: { text: 'Cow', emoji: '🐄' }, right: { text: 'Milk', emoji: '🥛' } },
          { left: { text: 'Hen', emoji: '🐔' }, right: { text: 'Egg', emoji: '🥚' } },
          { left: { text: 'Bee', emoji: '🐝' }, right: { text: 'Honey', emoji: '🍯' } },
        ],
      },
      { type: 'memory', instruction: 'Find the animal pairs', cards: [{ emoji: '🦁' }, { emoji: '🐘' }, { emoji: '🦒' }] },
    ],
  },

  // ---------------- Number World
  num_count_5: {
    worldId: 'numbers', order: 1, isActive: true, isPremium: false, isDailySpark: false,
    title: 'Count to 5', subtitle: 'One, two, three, four, five!', emoji: '🖐️', thumbnailUrl: '', durationMinutes: 3,
    steps: [
      { type: 'letter', letter: '3', word: 'Three', text: 'Three. One, two, three!', emoji: '🍎🍎🍎', color: '#5FCF97' },
      { type: 'count', question: 'How many apples?', emoji: '🍎', count: 3, options: ['2', '3', '4'], correctIndex: 1, hint: 'Touch each apple and count.' },
      { type: 'count', question: 'How many stars?', emoji: '⭐', count: 5, options: ['4', '5', '6'], correctIndex: 1 },
      { type: 'trace', letter: '5', instruction: 'Trace the number 5', color: '#5FCF97' },
    ],
  },
  num_more_less: {
    worldId: 'numbers', order: 2, isActive: true, isPremium: false, isDailySpark: false,
    title: 'More or Less', subtitle: 'Which group has more?', emoji: '⚖️', thumbnailUrl: '', durationMinutes: 3,
    steps: [
      {
        type: 'quiz', question: 'Which basket has MORE strawberries?',
        options: [{ text: '🍓🍓🍓🍓' }, { text: '🍓🍓' }], correctIndex: 0,
      },
      {
        type: 'quiz', question: 'Which has LESS balloons?',
        options: [{ text: '🎈🎈🎈' }, { text: '🎈' }, { text: '🎈🎈🎈🎈' }], correctIndex: 1,
      },
      { type: 'count', question: 'How many ducks?', emoji: '🦆', count: 4, options: ['3', '4', '5'], correctIndex: 1 },
    ],
  },
  num_sequence: {
    worldId: 'numbers', order: 3, isActive: true, isPremium: true, isDailySpark: false,
    title: 'Number Train', subtitle: 'What comes next?', emoji: '🚂', thumbnailUrl: '', durationMinutes: 3,
    steps: [
      { type: 'quiz', question: '1, 2, 3, … what comes next?', options: ['5', '4', '2'], correctIndex: 1 },
      { type: 'quiz', question: '5, 6, 7, … what comes next?', options: ['8', '9', '6'], correctIndex: 0 },
      {
        type: 'match', instruction: 'Match the number to the dots',
        pairs: [
          { left: { text: '1' }, right: { text: '●' } },
          { left: { text: '2' }, right: { text: '●●' } },
          { left: { text: '3' }, right: { text: '●●●' } },
        ],
      },
    ],
  },

  // ---------------- Brain Power
  brain_memory: {
    worldId: 'brain', order: 1, isActive: true, isPremium: false, isDailySpark: true,
    title: 'Memory Match', subtitle: 'Flip and find the pairs', emoji: '🃏', thumbnailUrl: '', durationMinutes: 3,
    steps: [
      { type: 'memory', instruction: 'Find the pets', cards: [{ emoji: '🐶' }, { emoji: '🐱' }, { emoji: '🐰' }] },
      { type: 'memory', instruction: 'Find the fruits', cards: [{ emoji: '🍎' }, { emoji: '🍌' }, { emoji: '🍇' }, { emoji: '🍓' }] },
    ],
  },
  brain_patterns: {
    worldId: 'brain', order: 2, isActive: true, isPremium: true, isDailySpark: false,
    title: 'What Comes Next?', subtitle: 'Spot the pattern', emoji: '🔷', thumbnailUrl: '', durationMinutes: 3,
    steps: [
      {
        type: 'quiz', question: '🔴 🔵 🔴 🔵 🔴 … what comes next?',
        options: [{ emoji: '🔵' }, { emoji: '🟢' }, { emoji: '🟡' }], correctIndex: 0,
      },
      {
        type: 'quiz', question: '⭐ 🌙 ⭐ 🌙 ⭐ … what comes next?',
        options: [{ emoji: '⭐' }, { emoji: '🌙' }, { emoji: '☀️' }], correctIndex: 1,
      },
      {
        type: 'quiz', question: 'Which one is different?',
        options: [{ emoji: '🍎' }, { emoji: '🍎' }, { emoji: '🍌' }, { emoji: '🍎' }], correctIndex: 2,
      },
    ],
  },

  // ---------------- Story World
  story_lion: {
    worldId: 'stories', order: 1, isActive: true, isPremium: false, isDailySpark: false,
    title: 'Leo the Brave Lion', subtitle: 'A story about being brave', emoji: '🦁', thumbnailUrl: '', durationMinutes: 4,
    steps: [
      {
        type: 'story', title: 'Once upon a time…', text: 'Leo was a little lion. He was afraid of the dark.',
        highlights: ['Leo', 'dark'], emoji: '🦁', bgColor: '#FFF1CC',
      },
      {
        type: 'story', title: 'One night…', text: 'His friend Owl said, "Look up, Leo! The stars are bright."',
        highlights: ['Owl', 'stars'], emoji: '🦉', bgColor: '#DCD6FF',
        question: 'Who helped Leo?', options: ['Owl', 'Fish', 'Frog'], correctIndex: 0,
      },
      {
        type: 'story', title: 'The end', text: 'Leo smiled. The dark was not scary any more!',
        highlights: ['smiled'], emoji: '✨', bgColor: '#E3F6FF',
        question: 'How does Leo feel now?', options: ['Scared', 'Happy', 'Angry'], correctIndex: 1,
      },
    ],
  },
  story_star: {
    worldId: 'stories', order: 2, isActive: true, isPremium: true, isDailySpark: false,
    title: "Little Star's Night Trip", subtitle: 'Travel across the sky', emoji: '🌟', thumbnailUrl: '', durationMinutes: 4,
    steps: [
      {
        type: 'story', text: 'Little Star wanted to visit the Moon.', highlights: ['Star', 'Moon'], emoji: '🌙', bgColor: '#D8D4FF',
      },
      {
        type: 'story', text: 'She passed a red planet and a big blue planet.', highlights: ['red', 'blue'], emoji: '🪐', bgColor: '#CFE8FF',
        question: 'What colour was the big planet?', options: ['Blue', 'Yellow', 'Pink'], correctIndex: 0,
      },
      { type: 'memory', instruction: 'Find the space pairs', cards: [{ emoji: '🚀' }, { emoji: '🌍' }, { emoji: '🌙' }] },
    ],
  },

  // ---------------- Bangla World
  bn_vowels_1: {
    worldId: 'bangla', order: 1, isActive: true, isPremium: false, isDailySpark: false,
    title: 'স্বরবর্ণ অ আ', subtitle: 'অ-তে অজগর, আ-তে আম', emoji: 'অ', thumbnailUrl: '', durationMinutes: 3,
    steps: [
      { type: 'letter', letter: 'অ', word: 'অজগর', text: 'অ-তে অজগর', emoji: '🐍', color: '#6CB8FF', instruction: 'চলো বর্ণ শিখি!' },
      { type: 'letter', letter: 'আ', word: 'আম', text: 'আ-তে আম', emoji: '🥭', color: '#FFB547' },
      { type: 'trace', letter: 'অ', instruction: 'অ লেখো', color: '#6CB8FF' },
      {
        type: 'quiz', question: 'কোনটি আম?', hint: 'আ-তে আম!',
        options: [{ text: 'আম', emoji: '🥭' }, { text: 'কলা', emoji: '🍌' }, { text: 'আপেল', emoji: '🍎' }],
        correctIndex: 0,
      },
    ],
  },
  bn_vowels_2: {
    worldId: 'bangla', order: 2, isActive: true, isPremium: true, isDailySpark: false,
    title: 'স্বরবর্ণ ই ঈ', subtitle: 'ই-তে ইঁদুর', emoji: 'ই', thumbnailUrl: '', durationMinutes: 3,
    steps: [
      { type: 'letter', letter: 'ই', word: 'ইঁদুর', text: 'ই-তে ইঁদুর', emoji: '🐭', color: '#5FCF97' },
      { type: 'letter', letter: 'ঈ', word: 'ঈগল', text: 'ঈ-তে ঈগল', emoji: '🦅', color: '#8E7CF8' },
      {
        type: 'match', instruction: 'বর্ণের সাথে ছবি মেলাও',
        pairs: [
          { left: { text: 'অ' }, right: { emoji: '🐍' } },
          { left: { text: 'আ' }, right: { emoji: '🥭' } },
          { left: { text: 'ই' }, right: { emoji: '🐭' } },
        ],
      },
    ],
  },
};

// ---------------------------------------------------------------- badges
const badges = {
  first_lesson: {
    order: 1, isActive: true, title: 'First Lesson', description: 'Finish your very first lesson.',
    emoji: '⭐', iconUrl: '', color: '#FFE7B3', rule: { type: 'lessons_completed', value: 1 },
  },
  streak_5: {
    order: 2, isActive: true, title: '5 Day Streak', description: 'Learn on 5 days in a row.',
    emoji: '🔥', iconUrl: '', color: '#FFD9C7', rule: { type: 'streak', value: 5 },
  },
  math_star: {
    order: 3, isActive: true, title: 'Math Star', description: 'Finish 2 lessons in Number World.',
    emoji: '🎖️', iconUrl: '', color: '#E2DAFF', rule: { type: 'world_lessons', value: 2, worldId: 'numbers' },
  },
  curious_mind: {
    order: 4, isActive: true, title: 'Curious Mind', description: 'Finish 5 lessons in any world.',
    emoji: '💡', iconUrl: '', color: '#FFF3B0', rule: { type: 'lessons_completed', value: 5 },
  },
  streak_3: {
    order: 5, isActive: true, title: '3 Day Streak', description: 'Learn on 3 days in a row.',
    emoji: '🌈', iconUrl: '', color: '#D7F5E3', rule: { type: 'streak', value: 3 },
  },
  bookworm: {
    order: 6, isActive: true, title: 'Bookworm', description: 'Finish 3 lessons in English World.',
    emoji: '📚', iconUrl: '', color: '#DDEBFF', rule: { type: 'world_lessons', value: 3, worldId: 'english' },
  },
  storyteller: {
    order: 7, isActive: true, title: 'Storyteller', description: 'Finish a story in Story World.',
    emoji: '🦁', iconUrl: '', color: '#FFE7B3', rule: { type: 'world_lessons', value: 1, worldId: 'stories' },
  },
  star_collector: {
    order: 8, isActive: true, title: 'Star Collector', description: 'Collect 15 stars.',
    emoji: '🌟', iconUrl: '', color: '#FFF3B0', rule: { type: 'stars', value: 15 },
  },
  brain_champ: {
    order: 9, isActive: true, title: 'Brain Champ', description: 'Finish 2 Brain Power games.',
    emoji: '🧩', iconUrl: '', color: '#FFE0E0', rule: { type: 'world_lessons', value: 2, worldId: 'brain' },
  },
};

// ---------------------------------------------------------------- avatars
const avatars = {
  girl: { order: 1, isActive: true, emoji: '👧🏽', imageUrl: '', bgColor: '#FFE3EC' },
  boy: { order: 2, isActive: true, emoji: '👦🏻', imageUrl: '', bgColor: '#DDEBFF' },
  kid: { order: 3, isActive: true, emoji: '🧒🏾', imageUrl: '', bgColor: '#E2DAFF' },
  baby: { order: 4, isActive: true, emoji: '👶', imageUrl: '', bgColor: '#FFF3C4' },
  lion: { order: 5, isActive: true, emoji: '🦁', imageUrl: '', bgColor: '#FFE7B3' },
  panda: { order: 6, isActive: true, emoji: '🐼', imageUrl: '', bgColor: '#E8F5E9' },
  fox: { order: 7, isActive: true, emoji: '🦊', imageUrl: '', bgColor: '#FFE0CC' },
  bunny: { order: 8, isActive: true, emoji: '🐰', imageUrl: '', bgColor: '#FDE2F3' },
  unicorn: { order: 9, isActive: true, emoji: '🦄', imageUrl: '', bgColor: '#EDE3FF' },
  tiger: { order: 10, isActive: true, emoji: '🐯', imageUrl: '', bgColor: '#FFEBC2' },
};

// ---------------------------------------------------------------- plans
// Create the same product ids as SUBSCRIPTIONS in Google Play Console
// (Monetize → Products → Subscriptions), each with one base plan.
const plans = {
  monthly: {
    order: 1, isActive: true, title: 'Monthly', subtitle: 'Flexible — cancel anytime',
    productIdAndroid: 'mindo_plus_monthly', productIdIos: 'mindo_plus_monthly',
    priceLabel: '৳299', periodLabel: 'per month', badgeText: '', isHighlighted: false,
    features: ['All worlds & lessons', 'New content every month'],
  },
  yearly: {
    order: 2, isActive: true, title: 'Yearly', subtitle: 'Best for families',
    productIdAndroid: 'mindo_plus_yearly', productIdIos: 'mindo_plus_yearly',
    priceLabel: '৳1,999', periodLabel: 'per year', badgeText: 'SAVE 44%', isHighlighted: true,
    features: ['Everything in Monthly', 'Over 5 months free vs monthly'],
  },
};

// ---------------------------------------------------------------- pages
const TEMPLATE_NOTE = '(Template text — review with a legal adviser and edit it in the admin panel before publishing.)';
const pages = {
  help: {
    order: 1, showInParentZone: true, title: 'Help & FAQ',
    body: [
      '# How do I add another child?',
      'Open Profile → Parent Zone → Add a child.',
      '',
      '# How do I set screen time?',
      'Parent Zone → tap your child → Daily screen time.',
      '',
      '# I paid but lessons are still locked',
      'Open the subscription screen and tap "Restore purchases" while signed in with the same Google Play account.',
      '',
      '# Does the app work offline?',
      'Yes. Lessons you have opened before stay on the device, and progress syncs when you are back online.',
    ].join('\n'),
  },
  privacy: {
    order: 2, showInParentZone: true, title: 'Privacy Policy',
    body: [
      TEMPLATE_NOTE,
      '',
      '# What we collect',
      '- Parent account: name and e-mail address.',
      '- Child profiles: a first name or nickname, an avatar and an age band. No photos, birth dates or location.',
      '- Learning progress: lessons completed, stars, badges and streaks.',
      '- Subscription status from Google Play / App Store.',
      '',
      '# What we never do',
      '- No ads and no selling of data.',
      '- No chat, public profiles or social features for children.',
      '',
      '# Your choices',
      '- You can delete a child profile or your whole account at any time in the Parent Zone.',
    ].join('\n'),
  },
  terms: {
    order: 3, showInParentZone: true, title: 'Terms of Use',
    body: [
      TEMPLATE_NOTE,
      '',
      '# Accounts',
      'Accounts are created and managed by a parent or guardian.',
      '',
      '# Subscriptions',
      'Mindo Plus is billed through Google Play or the App Store and renews automatically until cancelled in the store.',
    ].join('\n'),
  },
  about: {
    order: 4, showInParentZone: true, title: 'About Mindo Kids',
    body: 'Mindo Kids helps young children build language, number, memory and problem-solving skills through short, calm, play-based activities.\n\nLittle Minds. Infinite Worlds.',
  },
};

// ---------------------------------------------------------------- announcements
const announcements = {
  welcome: {
    isActive: true,
    title: 'Welcome to Mindo Kids! 🎉',
    body: 'Try today\'s Brain Spark on the home screen — a new mini challenge every day.',
    emoji: '🎈',
    imageUrl: '',
    createdAt: new Date(),
  },
};

module.exports = { config, onboarding, worlds, lessons, badges, avatars, plans, pages, announcements };
