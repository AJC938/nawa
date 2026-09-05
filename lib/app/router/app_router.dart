import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/account_created_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/explore/presentation/screens/category_screen.dart';
import '../../features/explore/presentation/screens/discover_screen.dart';
import '../../features/explore/presentation/screens/explore_screen.dart';
import '../../features/experiences/presentation/screens/experience_complete_screen.dart';
import '../../features/experiences/presentation/screens/experience_details_screen.dart';
import '../../features/experiences/presentation/screens/experience_session_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/interests/presentation/screens/interest_detail_screen.dart';
import '../../features/interests/presentation/screens/my_interests_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_age_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_complete_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_interests_intro_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_interests_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_intro_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_name_screen.dart';
import '../../features/onboarding/presentation/screens/welcome_screen.dart';
import '../../features/parent/presentation/screens/parent_child_profile_screen.dart';
import '../../features/parent/presentation/screens/parent_dashboard_screen.dart';
import '../../features/parent/presentation/screens/parent_interest_detail_screen.dart';
import '../../features/parent/presentation/screens/parent_interest_summary_screen.dart';
import '../../features/profile/presentation/screens/child_profile_screen.dart';
import '../../features/profile/presentation/screens/child_profiles_screen.dart';
import '../../features/profile/presentation/screens/parent_profile_screen.dart';
import '../../features/settings/presentation/screens/about_nawa_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import 'nawa_shell_scaffold.dart';
import 'route_paths.dart';

/// Centralized Nawa router. The four primary tabs (Home, Explore, Profile,
/// Parent) live in a [StatefulShellRoute] with their own persistent
/// back-stacks; every detail/flow screen is a full-screen push outside the
/// shell (no bottom nav), matching the reference UI.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RoutePaths.splash,
    routes: [
      GoRoute(path: RoutePaths.splash, builder: (context, state) => const SplashScreen()),
      GoRoute(path: RoutePaths.welcome, builder: (context, state) => const WelcomeScreen()),
      GoRoute(path: RoutePaths.selectChild, builder: (context, state) => const ChildProfilesScreen(isEntryGate: true)),

      GoRoute(path: RoutePaths.onboardingIntro, builder: (context, state) => const OnboardingIntroScreen()),
      GoRoute(path: RoutePaths.onboardingName, builder: (context, state) => const OnboardingNameScreen()),
      GoRoute(path: RoutePaths.onboardingAge, builder: (context, state) => const OnboardingAgeScreen()),
      GoRoute(path: RoutePaths.onboardingInterestsIntro, builder: (context, state) => const OnboardingInterestsIntroScreen()),
      GoRoute(path: RoutePaths.onboardingInterests, builder: (context, state) => const OnboardingInterestsScreen()),
      GoRoute(path: RoutePaths.onboardingComplete, builder: (context, state) => const OnboardingCompleteScreen()),

      GoRoute(path: RoutePaths.login, builder: (context, state) => const LoginScreen()),
      GoRoute(path: RoutePaths.signup, builder: (context, state) => const SignupScreen()),
      GoRoute(path: RoutePaths.signupSuccess, builder: (context, state) => const AccountCreatedScreen()),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => NawaShellScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: RoutePaths.home, builder: (context, state) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: RoutePaths.explore, builder: (context, state) => const ExploreScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: RoutePaths.profile, builder: (context, state) => const ChildProfileScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: RoutePaths.parent, builder: (context, state) => const ParentDashboardScreen()),
          ]),
        ],
      ),

      GoRoute(
        path: RoutePaths.categoryDetail,
        builder: (context, state) => CategoryScreen(categoryId: state.pathParameters['categoryId']!),
      ),
      GoRoute(
        path: RoutePaths.experienceDetail,
        builder: (context, state) => ExperienceDetailsScreen(experienceId: state.pathParameters['experienceId']!),
      ),
      GoRoute(
        path: RoutePaths.experienceSession,
        builder: (context, state) => ExperienceSessionScreen(experienceId: state.pathParameters['experienceId']!),
      ),
      GoRoute(
        path: RoutePaths.experienceComplete,
        builder: (context, state) => ExperienceCompleteScreen(experienceId: state.pathParameters['experienceId']!),
      ),

      GoRoute(path: RoutePaths.interests, builder: (context, state) => const MyInterestsScreen()),
      GoRoute(
        path: RoutePaths.interestDetail,
        builder: (context, state) => InterestDetailScreen(categoryId: state.pathParameters['categoryId']!),
      ),
      GoRoute(path: RoutePaths.discover, builder: (context, state) => const DiscoverScreen()),

      GoRoute(path: RoutePaths.parentInterestSummary, builder: (context, state) => const ParentInterestSummaryScreen()),
      GoRoute(
        path: RoutePaths.parentInterestDetail,
        builder: (context, state) => ParentInterestDetailScreen(categoryId: state.pathParameters['categoryId']!),
      ),
      GoRoute(path: RoutePaths.parentChildProfile, builder: (context, state) => const ParentChildProfileScreen()),

      GoRoute(path: RoutePaths.settings, builder: (context, state) => const SettingsScreen()),
      GoRoute(path: RoutePaths.parentProfile, builder: (context, state) => const ParentProfileScreen()),
      GoRoute(path: RoutePaths.childProfiles, builder: (context, state) => const ChildProfilesScreen()),
      GoRoute(path: RoutePaths.aboutNawa, builder: (context, state) => const AboutNawaScreen()),
    ],
  );
});
