/// Static feature flags for gating unfinished or experimental Nawa features.
///
/// This is a foundation-only placeholder. A later phase may replace this
/// with a remote-config-backed implementation.
class FeatureFlags {
  const FeatureFlags._();

  static const bool aiRecommendationsEnabled = false;
  static const bool parentDashboardEnabled = false;
}
