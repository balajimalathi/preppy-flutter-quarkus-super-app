/// Multiple-choice question model used by learning flows.
class Question {
  const Question({
    required this.id,
    required this.stem,
    required this.options,
    required this.correctKey,
    this.explanation,
  });

  /// Stable identifier for the question.
  final String id;

  /// Prompt shown to the learner.
  final String stem;

  /// Answer options keyed by a stable option id or label.
  final Map<String, String> options;

  /// Key in [options] representing the correct answer.
  final String correctKey;

  /// Optional explanation shown after answering.
  final String? explanation;
}
