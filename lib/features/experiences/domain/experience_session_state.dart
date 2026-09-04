import 'experience.dart';
import 'exploration_interaction.dart';

enum SessionStatus { notStarted, inProgress, completed }

/// Feedback shown for the currently selected option. Kept intentionally
/// gentle — [tryAgain] is a nudge, never a failure.
enum OptionFeedback { none, positive, tryAgain }

/// Lifecycle of the Firestore-backed exploration record for the current
/// session — separate from [SessionStatus], which drives the local
/// question-by-question UI and must keep working even if Firestore fails.
enum ExplorationStatus {
  /// No exploration record for the current session.
  idle,

  /// The initial `startExploration` write is in flight.
  started,

  /// The exploration record exists (id known) and interactions are being
  /// recorded locally as the child answers questions.
  inProgress,

  /// The `completeExploration` write is in flight.
  completing,

  /// The completion write succeeded.
  completed,

  /// Either the start or the completion write failed.
  error,
}

class ExperienceSessionState {
  const ExperienceSessionState({
    this.experience,
    this.status = SessionStatus.notStarted,
    this.currentQuestionIndex = 0,
    this.selectedOptionId,
    this.feedback = OptionFeedback.none,
    this.answeredQuestionIds = const {},
    this.explorationId,
    this.explorationStatus = ExplorationStatus.idle,
    this.startedAt,
    this.interactions = const [],
  });

  final Experience? experience;
  final SessionStatus status;
  final int currentQuestionIndex;
  final String? selectedOptionId;
  final OptionFeedback feedback;

  /// Question ids the child has already answered positively.
  final Set<String> answeredQuestionIds;

  /// The Firestore document id for this session's exploration record, once
  /// `startExploration` has succeeded — reused for the completion update so
  /// a session never produces two exploration documents.
  final String? explorationId;
  final ExplorationStatus explorationStatus;

  /// Client-recorded session start time, used to compute the real duration
  /// on completion.
  final DateTime? startedAt;

  /// Interactions recorded so far, in answer order.
  final List<ExplorationInteraction> interactions;

  double get progress {
    final exp = experience;
    if (exp == null || exp.questions.isEmpty) return 0;
    return answeredQuestionIds.length / exp.questions.length;
  }

  bool get isLastQuestion {
    final exp = experience;
    if (exp == null) return false;
    return currentQuestionIndex == exp.questions.length - 1;
  }

  ExperienceSessionState copyWith({
    Experience? experience,
    SessionStatus? status,
    int? currentQuestionIndex,
    String? selectedOptionId,
    bool clearSelectedOptionId = false,
    OptionFeedback? feedback,
    Set<String>? answeredQuestionIds,
    String? explorationId,
    ExplorationStatus? explorationStatus,
    DateTime? startedAt,
    List<ExplorationInteraction>? interactions,
  }) {
    return ExperienceSessionState(
      experience: experience ?? this.experience,
      status: status ?? this.status,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      selectedOptionId: clearSelectedOptionId ? null : (selectedOptionId ?? this.selectedOptionId),
      feedback: feedback ?? this.feedback,
      answeredQuestionIds: answeredQuestionIds ?? this.answeredQuestionIds,
      explorationId: explorationId ?? this.explorationId,
      explorationStatus: explorationStatus ?? this.explorationStatus,
      startedAt: startedAt ?? this.startedAt,
      interactions: interactions ?? this.interactions,
    );
  }
}
