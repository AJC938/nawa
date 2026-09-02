/// Build environments Nawa can run in.
enum AppEnvironment { development, staging, production }

/// Resolves the current [AppEnvironment].
///
/// Pass at build/run time, e.g.:
///   flutter run --dart-define=APP_ENV=development
/// Defaults to [AppEnvironment.development] when not provided.
class AppEnvironmentResolver {
  const AppEnvironmentResolver._();

  static const String _raw = String.fromEnvironment('APP_ENV', defaultValue: 'development');

  static AppEnvironment get current {
    switch (_raw) {
      case 'production':
        return AppEnvironment.production;
      case 'staging':
        return AppEnvironment.staging;
      default:
        return AppEnvironment.development;
    }
  }
}
