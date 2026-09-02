import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/states/placeholder_screen.dart';
import 'route_paths.dart';

/// Centralized Nawa router configuration.
///
/// Every route currently points to [PlaceholderScreen]. The next phase
/// replaces these with the real feature screens.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RoutePaths.welcome,
    routes: [
      GoRoute(
        path: RoutePaths.welcome,
        builder: (context, state) => const PlaceholderScreen(label: 'Welcome'),
      ),
      GoRoute(
        path: RoutePaths.onboarding,
        builder: (context, state) => const PlaceholderScreen(label: 'Onboarding'),
      ),
      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) => const PlaceholderScreen(label: 'Login'),
      ),
      GoRoute(
        path: RoutePaths.signup,
        builder: (context, state) => const PlaceholderScreen(label: 'Sign Up'),
      ),
      GoRoute(
        path: RoutePaths.home,
        builder: (context, state) => const PlaceholderScreen(label: 'Home'),
      ),
      GoRoute(
        path: RoutePaths.explore,
        builder: (context, state) => const PlaceholderScreen(label: 'Explore'),
      ),
      GoRoute(
        path: RoutePaths.categoryDetail,
        builder: (context, state) {
          final categoryId = state.pathParameters['categoryId'] ?? '';
          return PlaceholderScreen(label: 'Category: $categoryId');
        },
      ),
      GoRoute(
        path: RoutePaths.experienceDetail,
        builder: (context, state) {
          final experienceId = state.pathParameters['experienceId'] ?? '';
          return PlaceholderScreen(label: 'Experience: $experienceId');
        },
      ),
      GoRoute(
        path: RoutePaths.experienceSession,
        builder: (context, state) => const PlaceholderScreen(label: 'Experience Session'),
      ),
      GoRoute(
        path: RoutePaths.experienceComplete,
        builder: (context, state) => const PlaceholderScreen(label: 'Experience Complete'),
      ),
      GoRoute(
        path: RoutePaths.interests,
        builder: (context, state) => const PlaceholderScreen(label: 'Interests'),
      ),
      GoRoute(
        path: RoutePaths.interestDetail,
        builder: (context, state) {
          final interestId = state.pathParameters['interestId'] ?? '';
          return PlaceholderScreen(label: 'Interest: $interestId');
        },
      ),
      GoRoute(
        path: RoutePaths.discover,
        builder: (context, state) => const PlaceholderScreen(label: 'Discover'),
      ),
      GoRoute(
        path: RoutePaths.profile,
        builder: (context, state) => const PlaceholderScreen(label: 'Profile'),
      ),
      GoRoute(
        path: RoutePaths.parent,
        builder: (context, state) => const PlaceholderScreen(label: 'Parent Dashboard'),
      ),
      GoRoute(
        path: RoutePaths.parentInterests,
        builder: (context, state) => const PlaceholderScreen(label: 'Parent: Interests'),
      ),
      GoRoute(
        path: RoutePaths.settings,
        builder: (context, state) => const PlaceholderScreen(label: 'Settings'),
      ),
    ],
  );
});
