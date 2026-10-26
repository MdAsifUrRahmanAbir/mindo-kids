class RouteNames {
  RouteNames._();

  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String forgotPassword = '/forgot-password';

  static const String childNew = '/child/new';
  static const String childSelect = '/child/select';
  static String childEdit(String id) => '/child/edit/$id';

  // Bottom-nav tabs
  static const String home = '/home';
  static const String explore = '/explore';
  static const String rewards = '/rewards';
  static const String profile = '/profile';

  static String world(String id) => '/world/$id';
  static String lesson(String id) => '/lesson/$id';

  static const String paywall = '/paywall';
  static const String parentZone = '/parent';
  static String parentChild(String id) => '/parent/child/$id';
  static String page(String id) => '/page/$id';
  static const String announcements = '/announcements';

  static const Set<String> authRoutes = {onboarding, signIn, signUp, forgotPassword};
}
