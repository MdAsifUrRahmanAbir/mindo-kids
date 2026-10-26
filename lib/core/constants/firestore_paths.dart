/// Every Firestore path the app touches, in one place.
/// The full schema (fields per document) is documented in
/// docs/FIRESTORE_SCHEMA.md — use it when building the admin panel.
class FirestorePaths {
  FirestorePaths._();

  // ---- Content (admin panel writes, app reads) ----
  static const String config = 'config';
  static const String appConfig = 'config/app';
  static const String strings = 'config/strings';
  static const String paywall = 'config/paywall';

  static const String onboarding = 'onboarding';
  static const String worlds = 'worlds';
  static const String lessons = 'lessons';
  static const String badges = 'badges';
  static const String avatars = 'avatars';
  static const String plans = 'plans';
  static const String pages = 'pages';
  static const String announcements = 'announcements';

  static String lesson(String lessonId) => '$lessons/$lessonId';
  static String steps(String lessonId) => '$lessons/$lessonId/steps';
  static String page(String pageId) => '$pages/$pageId';

  // ---- Commerce (Cloud Functions write) ----
  static String subscription(String uid) => 'subscriptions/$uid';

  // ---- Family data (app writes) ----
  static String user(String uid) => 'users/$uid';
  static String children(String uid) => 'users/$uid/children';
  static String child(String uid, String childId) => 'users/$uid/children/$childId';
  static String progress(String uid, String childId) => 'users/$uid/children/$childId/progress';
  static String progressDoc(String uid, String childId, String lessonId) =>
      'users/$uid/children/$childId/progress/$lessonId';
  static String earnedBadges(String uid, String childId) => 'users/$uid/children/$childId/badges';
}
