import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/auth_state.dart';
import '../../../auth/presentation/state/auth_controller.dart';
import '../../../interests/domain/interest_category.dart';
import '../../../interests/presentation/state/interest_profile_controller.dart';
import '../../../profile/presentation/state/child_profile_controller.dart';
import '../../data/exploration_repository.dart';
import '../../data/mock_experiences.dart';
import '../../domain/experience.dart';
import '../../domain/experience_session_state.dart';
import '../../domain/exploration_interaction.dart';
import 'exploration_history_controller.dart';

/// Guard against an impossible/lifecycle-glitch duration (e.g. a paused app
/// resumed after being backgrounded for a long time) polluting recorded data.
const _minDurationSeconds = 1;
const _maxDurationSeconds = 6 * 60 * 60;

/// Drives a single interactive experience session end to end. Selecting an
/// option actually mutates local state (the current question's feedback),
/// and completing the last question records real signals into the
/// interest profile and child profile — this is the "app behaves like a
/// real product" requirement for the experience flow.
///
/// It also persists the session as a real Firestore exploration record
/// (`users/{uid}/explorations/{id}`) via [ExplorationRepository]: created on
/// [start], updated in place on completion — never a second document for the
/// same session. That persistence is best-effort and tracked separately via
/// [ExperienceSessionState.explorationStatus]; a Firestore failure never
/// blocks or resets the local question flow, which must keep working exactly
/// as before.
class ExperienceSessionController extends Notifier<ExperienceSessionState> {
  @override
  ExperienceSessionState build() => const ExperienceSessionState();

  void start(String experienceId) {
    final current = state;
    // A rebuild or duplicate widget-lifecycle call for the SAME experience
    // that already has an exploration record in flight/created must not
    // start a second one.
    if (current.experience?.id == experienceId &&
        current.status != SessionStatus.completed &&
        (current.explorationStatus == ExplorationStatus.started || current.explorationStatus == ExplorationStatus.inProgress)) {
      return;
    }

    final experience = experienceById(experienceId);
    final startedAt = DateTime.now();
    state = ExperienceSessionState(
      experience: experience,
      status: SessionStatus.inProgress,
      startedAt: startedAt,
      explorationStatus: experience == null ? ExplorationStatus.idle : ExplorationStatus.started,
    );

    if (experience != null) {
      _startExploration(experience, startedAt);
    }
  }

  Future<void> _startExploration(Experience experience, DateTime startedAt) async {
    final auth = ref.read(authControllerProvider);
    final uid = auth.user?.uid;
    if (auth.status != AuthStatus.authenticated || uid == null) {
      // No signed-in owner to attach this exploration to — never write an
      // orphan record. The local question flow still works.
      if (_isCurrentSession(experience.id, startedAt)) {
        state = state.copyWith(explorationStatus: ExplorationStatus.error);
      }
      return;
    }

    try {
      final explorationId = await ref.read(explorationRepositoryProvider).startExploration(
            uid: uid,
            experienceId: experience.id,
            categoryId: experience.category.id,
          );
      if (!_isCurrentSession(experience.id, startedAt)) return;
      state = state.copyWith(explorationId: explorationId, explorationStatus: ExplorationStatus.inProgress);
    } catch (_) {
      if (!_isCurrentSession(experience.id, startedAt)) return;
      state = state.copyWith(explorationStatus: ExplorationStatus.error);
    }
  }

  /// True if the session hasn't moved on (e.g. the child navigated to a
  /// different experience) since an async call for [experienceId]/[startedAt]
  /// was kicked off — guards against a stale async result overwriting a
  /// newer session's state.
  bool _isCurrentSession(String experienceId, DateTime startedAt) {
    return state.experience?.id == experienceId && state.startedAt == startedAt;
  }

  void selectOption(String optionId) {
    final exp = state.experience;
    if (exp == null) return;
    final question = exp.questions[state.currentQuestionIndex];
    final option = question.options.firstWhere((o) => o.id == optionId);

    state = state.copyWith(
      selectedOptionId: optionId,
      feedback: option.isEncouraged ? OptionFeedback.positive : OptionFeedback.tryAgain,
    );
  }

  /// Advances past the current question (only reachable once feedback is
  /// positive) and completes the session on the last question.
  void continueToNext() {
    final exp = state.experience;
    if (exp == null || state.feedback != OptionFeedback.positive) return;

    final question = exp.questions[state.currentQuestionIndex];
    final answered = {...state.answeredQuestionIds, question.id};
    final interactions = [
      ...state.interactions,
      ExplorationInteraction(questionId: question.id, selectedOptionId: state.selectedOptionId!, order: state.interactions.length),
    ];

    if (state.isLastQuestion) {
      state = state.copyWith(status: SessionStatus.completed, answeredQuestionIds: answered, interactions: interactions);
      ref.read(childProfileProvider.notifier).recordExperienceCompleted();
      _completeExploration();
      return;
    }

    state = state.copyWith(
      currentQuestionIndex: state.currentQuestionIndex + 1,
      clearSelectedOptionId: true,
      feedback: OptionFeedback.none,
      answeredQuestionIds: answered,
      interactions: interactions,
    );
  }

  /// Retries the completion write for the current session — safe to call
  /// repeatedly since it always updates the same [ExperienceSessionState.explorationId]
  /// document rather than creating a new one.
  Future<void> retryCompleteExploration() => _completeExploration();

  Future<void> _completeExploration() async {
    final explorationId = state.explorationId;
    final auth = ref.read(authControllerProvider);
    final uid = auth.user?.uid;
    if (explorationId == null || uid == null || auth.status != AuthStatus.authenticated) {
      state = state.copyWith(explorationStatus: ExplorationStatus.error);
      return;
    }

    state = state.copyWith(explorationStatus: ExplorationStatus.completing);
    final startedAt = state.startedAt ?? DateTime.now();
    final durationSeconds = DateTime.now().difference(startedAt).inSeconds.clamp(_minDurationSeconds, _maxDurationSeconds);

    try {
      final repository = ref.read(explorationRepositoryProvider);
      await repository.completeExploration(
        uid: uid,
        explorationId: explorationId,
        durationSeconds: durationSeconds,
        interactions: state.interactions,
      );
      state = state.copyWith(explorationStatus: ExplorationStatus.completed);

      // Recalculate the real interest profile from source data (the freshly
      // persisted exploration records), never incrementally — so it never
      // drifts from what's actually stored. Reflects immediately without
      // needing an app restart.
      final selectedInterests = ref.read(childProfileProvider).interests;
      final explorations = await repository.getExplorations(uid);
      ref.read(explorationHistoryProvider.notifier).setExplorations(explorations);
      ref.read(interestProfileProvider.notifier).recalculate(selectedInterests: selectedInterests, explorations: explorations);
    } catch (_) {
      state = state.copyWith(explorationStatus: ExplorationStatus.error);
    }
  }

  void reset() => state = const ExperienceSessionState();
}

final experienceSessionProvider = NotifierProvider<ExperienceSessionController, ExperienceSessionState>(
  ExperienceSessionController.new,
);
