/// Placeholder for future AI service configuration.
///
/// AI (recommendations, exploration-signal interpretation) is planned for
/// a later phase, accessed through a proper data/domain layer — never
/// called directly from the Flutter client with a private key embedded
/// in the app. This file only documents the boundary.
class AiConfig {
  const AiConfig._();

  // TODO(nawa-ai-phase): AI calls must go through a backend endpoint
  // (see AppConfig.apiBaseUrl), not directly from the client.
}
