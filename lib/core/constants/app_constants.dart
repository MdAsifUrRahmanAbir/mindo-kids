class AppConstants {
  AppConstants._();

  static const String appName = 'Mindo Kids';

  /// Region your Cloud Functions are deployed to (functions/index.js).
  static const String functionsRegion = 'us-central1';

  /// Callable function names (functions/index.js).
  static const String fnVerifyPurchase = 'verifyPurchase';

  // SharedPreferences keys
  static String prefActiveChild(String uid) => 'active_child_$uid';
  static String prefScreenTimeUsed(String childId, String day) => 'st_used_${childId}_$day';
  static String prefScreenTimeExtra(String childId, String day) => 'st_extra_${childId}_$day';

  /// Minutes a parent grants with "a little more time" on the break screen.
  static const int screenTimeExtensionMinutes = 15;
}
