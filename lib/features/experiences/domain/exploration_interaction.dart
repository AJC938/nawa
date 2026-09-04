/// One recorded interaction within an exploration session — the child
/// answering a single question. Mirrors exactly what the existing
/// experience session already tracks locally (question + chosen option),
/// in the order it happened.
class ExplorationInteraction {
  const ExplorationInteraction({required this.questionId, required this.selectedOptionId, required this.order});

  final String questionId;
  final String selectedOptionId;

  /// 0-based position within the session, so order survives serialization.
  final int order;

  Map<String, dynamic> toMap() => {
        'questionId': questionId,
        'selectedOptionId': selectedOptionId,
        'order': order,
      };

  factory ExplorationInteraction.fromMap(Map<String, dynamic> map) {
    return ExplorationInteraction(
      questionId: map['questionId'] as String? ?? '',
      selectedOptionId: map['selectedOptionId'] as String? ?? '',
      order: (map['order'] as num?)?.toInt() ?? 0,
    );
  }
}
