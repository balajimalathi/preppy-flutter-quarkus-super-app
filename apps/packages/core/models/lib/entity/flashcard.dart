/// Two-sided study prompt used for recall practice.
class Flashcard {
  const Flashcard({required this.id, required this.front, required this.back});

  /// Stable identifier for the flashcard.
  final String id;

  /// Front side shown before reveal.
  final String front;

  /// Back side shown after reveal.
  final String back;
}
