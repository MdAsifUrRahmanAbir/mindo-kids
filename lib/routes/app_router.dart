import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mindo_kids/core/session/session_controller.dart';
import 'package:mindo_kids/features/announcements/presentation/screens/announcements_screen.dart';
import 'package:mindo_kids/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:mindo_kids/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:mindo_kids/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:mindo_kids/features/children/presentation/screens/child_form_screen.dart';
import 'package:mindo_kids/features/children/presentation/screens/select_child_screen.dart';
import 'package:mindo_kids/features/explore/presentation/screens/explore_screen.dart';
import 'package:mindo_kids/features/home/presentation/screens/home_screen.dart';
import 'package:mindo_kids/features/lesson/presentation/screens/lesson_player_screen.dart';
import 'package:mindo_kids/features/main_shell/presentation/screens/main_shell_screen.dart';
import 'package:mindo_kids/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:mindo_kids/features/pages/presentation/screens/content_page_screen.dart';
import 'package:mindo_kids/features/parent_zone/presentation/screens/parent_child_screen.dart';
import 'package:mindo_kids/features/parent_zone/presentation/screens/parent_zone_screen.dart';
import 'package:mindo_kids/features/profile/presentation/screens/profile_screen.dart';
import 'package:mindo_kids/features/rewards/presentation/screens/rewards_screen.dart';
import 'package:mindo_kids/features/splash/presentation/screens/splash_screen.dart';
import 'package:mindo_kids/features/subscription/presentation/screens/paywall_screen.dart';
import 'package:mindo_kids/features/system/presentation/screens/not_found_screen.dart';
import 'package:mindo_kids/features/world/presentation/screens/world_screen.dart';
import 'package:mindo_kids/routes/route_names.dart';

class _RouterRefresh extends ChangeNotifier {
  void ping() => notifyListeners();
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh();
  ref.listen<SessionState>(sessionControllerProvider, (_, _) => refresh.ping());
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: RouteNames.splash,
    refreshListenable: refresh,
    errorBuilder: (context, state) => const NotFoundScreen(),
    redirect: (context, state) {
      final s = ref.read(sessionControllerProvider);
      final loc = state.matchedLocation;
      final isPage = loc.startsWith('/page/');
      final isAuthRoute = RouteNames.authRoutes.contains(loc);

      // Wait for Firebase Auth + the children list.
      if (!s.isReady) return loc == RouteNames.splash ? null : RouteNames.splash;

      if (s.status == SessionStatus.signedOut) {
        return (isAuthRoute || isPage) ? null : RouteNames.onboarding;
      }

      // Signed in: a child profile is required before learning.
      if (s.children.isEmpty) {
        return (loc == RouteNames.childNew || isPage) ? null : RouteNames.childNew;
      }
      if (s.activeChildId == null) {
        return (loc == RouteNames.childSelect || loc == RouteNames.childNew) ? null : RouteNames.childSelect;
      }

      // Guests may open sign-up / sign-in to create or switch account.
      final guestAuth = s.isGuest && (loc == RouteNames.signUp || loc == RouteNames.signIn);
      if (loc == RouteNames.splash || (isAuthRoute && !guestAuth)) return RouteNames.home;
      return null;
    },
    routes: [
      GoRoute(path: RouteNames.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: RouteNames.onboarding, builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: RouteNames.signIn, builder: (_, _) => const SignInScreen()),
      GoRoute(path: RouteNames.signUp, builder: (_, _) => const SignUpScreen()),
      GoRoute(path: RouteNames.forgotPassword, builder: (_, _) => const ForgotPasswordScreen()),

      GoRoute(path: RouteNames.childNew, builder: (_, _) => const ChildFormScreen()),
      GoRoute(path: RouteNames.childSelect, builder: (_, _) => const SelectChildScreen()),
      GoRoute(
        path: '/child/edit/:id',
        builder: (_, state) => ChildFormScreen(childId: state.pathParameters['id']),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MainShellScreen(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: RouteNames.home, builder: (_, _) => const HomeScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: RouteNames.explore, builder: (_, _) => const ExploreScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: RouteNames.rewards, builder: (_, _) => const RewardsScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: RouteNames.profile, builder: (_, _) => const ProfileScreen())],
          ),
        ],
      ),

      GoRoute(
        path: '/world/:id',
        builder: (_, state) => WorldScreen(worldId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/lesson/:id',
        builder: (_, state) => LessonPlayerScreen(lessonId: state.pathParameters['id']!),
      ),
      GoRoute(path: RouteNames.paywall, builder: (_, _) => const PaywallScreen()),
      GoRoute(path: RouteNames.parentZone, builder: (_, _) => const ParentZoneScreen()),
      GoRoute(
        path: '/parent/child/:id',
        builder: (_, state) => ParentChildScreen(childId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/page/:id',
        builder: (_, state) => ContentPageScreen(pageId: state.pathParameters['id']!),
      ),
      GoRoute(path: RouteNames.announcements, builder: (_, _) => const AnnouncementsScreen()),
    ],
  );
});
