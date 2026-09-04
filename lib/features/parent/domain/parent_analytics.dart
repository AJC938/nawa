import '../../experiences/domain/exploration_record.dart';
import '../../interests/domain/interest_category.dart';
import '../../interests/domain/interest_signal.dart';

/// Derived, read-only Parent Dashboard analytics.
///
/// Purely an aggregation of data that already exists elsewhere: real
/// exploration records and the real, already-calculated [InterestSignal]
/// profile. Never recomputes interest scores itself (that formula lives
/// only in `InterestScoringEngine`) and never touches Firestore — see
/// [ParentAnalyticsCalculator].
class ParentAnalytics {
  const ParentAnalytics({
    required this.totalExperiencesCompleted,
    required this.totalDurationSeconds,
    required this.thisWeekExperiencesCompleted,
    required this.thisWeekDurationSeconds,
    required this.topInterests,
  });

  final int totalExperiencesCompleted;
  final int totalDurationSeconds;
  final int thisWeekExperiencesCompleted;
  final int thisWeekDurationSeconds;

  /// The real [InterestSignal]s, strongest-first — reused directly from the
  /// calculated profile, never recalculated here.
  final List<InterestSignal> topInterests;
}

/// Pure calculation from real source data — no Firebase, no Riverpod, no I/O.
class ParentAnalyticsCalculator {
  const ParentAnalyticsCalculator._();

  static ParentAnalytics calculate({
    required List<ExplorationRecord> explorations,
    required Map<InterestCategoryType, InterestSignal> interestProfile,
    DateTime? now,
  }) {
    // Only completed sessions count toward "experiences completed" and
    // "time spent" — a started-but-abandoned session isn't finished
    // exploration time, per the product definition for this MVP.
    final completed = explorations.where((record) => record.completed).toList();

    final weekStart = _startOfWeek(now ?? DateTime.now());
    final weekEnd = weekStart.add(const Duration(days: 7));
    final thisWeek = completed.where((record) {
      final at = record.completedAt ?? record.startedAt;
      return !at.isBefore(weekStart) && at.isBefore(weekEnd);
    }).toList();

    final topInterests = interestProfile.values.toList()..sort((a, b) => b.score.compareTo(a.score));

    return ParentAnalytics(
      totalExperiencesCompleted: completed.length,
      totalDurationSeconds: _sumDuration(completed),
      thisWeekExperiencesCompleted: thisWeek.length,
      thisWeekDurationSeconds: _sumDuration(thisWeek),
      topInterests: topInterests,
    );
  }

  static int _sumDuration(List<ExplorationRecord> records) =>
      records.fold(0, (sum, record) => sum + record.durationSeconds);

  /// Monday 00:00, in local time, of the week containing [date] — through
  /// Sunday 23:59:59 (the exclusive [date, +7 days) range this bounds).
  static DateTime _startOfWeek(DateTime date) {
    final localMidnight = DateTime(date.year, date.month, date.day);
    // DateTime.weekday: Monday == 1 ... Sunday == 7.
    return localMidnight.subtract(Duration(days: localMidnight.weekday - 1));
  }
}
