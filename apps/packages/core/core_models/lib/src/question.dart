class Question {
  const Question({
    required this.id,
    required this.stem,
    required this.options,
    required this.correctKey,
    this.explanation,
  });

  final String id;
  final String stem;
  final Map<String, String> options;
  final String correctKey;
  final String? explanation;
}
