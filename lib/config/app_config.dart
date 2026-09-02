import 'app_environment.dart';

/// Per-environment configuration values.
///
/// No secrets live here. Real values (API base URLs, keys) must be
/// supplied via --dart-define / --dart-define-from-file at build time
/// in a later phase, never hardcoded or committed.
class AppConfig {
  const AppConfig({required this.environment, required this.apiBaseUrl});

  final AppEnvironment environment;
  final String apiBaseUrl;

  static AppConfig get current {
    switch (AppEnvironmentResolver.current) {
      case AppEnvironment.production:
        return const AppConfig(
          environment: AppEnvironment.production,
          apiBaseUrl: 'https://api.nawa.app',
        );
      case AppEnvironment.staging:
        return const AppConfig(
          environment: AppEnvironment.staging,
          apiBaseUrl: 'https://api.staging.nawa.app',
        );
      case AppEnvironment.development:
        return const AppConfig(
          environment: AppEnvironment.development,
          apiBaseUrl: 'https://api.dev.nawa.app',
        );
    }
  }
}
