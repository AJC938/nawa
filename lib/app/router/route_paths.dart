/// Centralized route path constants for the Nawa app.
class RoutePaths {
  const RoutePaths._();

  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String selectChild = '/select-child';

  static const String onboardingIntro = '/onboarding';
  static const String onboardingName = '/onboarding/name';
  static const String onboardingAge = '/onboarding/age';
  static const String onboardingInterestsIntro = '/onboarding/interests-intro';
  static const String onboardingInterests = '/onboarding/interests';
  static const String onboardingComplete = '/onboarding/complete';

  static const String login = '/login';
  static const String signup = '/signup';
  static const String signupSuccess = '/signup/success';

  // Bottom-nav shell roots.
  static const String home = '/home';
  static const String explore = '/explore';
  static const String profile = '/profile';
  static const String parent = '/parent';

  static const String categoryDetail = '/explore/category/:categoryId';
  static String categoryPath(String categoryId) => '/explore/category/$categoryId';

  static const String experienceDetail = '/explore/experience/:experienceId';
  static String experiencePath(String experienceId) => '/explore/experience/$experienceId';

  static const String experienceSession = '/explore/experience/:experienceId/session';
  static String experienceSessionPath(String experienceId) => '/explore/experience/$experienceId/session';

  static const String experienceComplete = '/explore/experience/:experienceId/complete';
  static String experienceCompletePath(String experienceId) => '/explore/experience/$experienceId/complete';

  static const String interests = '/interests';
  static const String interestDetail = '/interests/:categoryId';
  static String interestDetailPath(String categoryId) => '/interests/$categoryId';

  static const String discover = '/discover';

  static const String parentInterestSummary = '/parent/interests';
  static const String parentInterestDetail = '/parent/interests/:categoryId';
  static String parentInterestDetailPath(String categoryId) => '/parent/interests/$categoryId';
  static const String parentChildProfile = '/parent/child-profile';

  static const String settings = '/settings';
  static const String parentProfile = '/settings/parent-profile';
  static const String childProfiles = '/settings/child-profiles';
  static const String aboutNawa = '/settings/about';
}
