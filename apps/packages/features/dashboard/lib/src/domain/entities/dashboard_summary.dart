/// Dashboard home summary from the backend or local cache.
class DashboardSummary {
  const DashboardSummary({
    required this.greeting,
    required this.streakDays,
    required this.cardsDueToday,
    required this.coveragePercent,
  });

  final String greeting;
  final int streakDays;
  final int cardsDueToday;
  final int coveragePercent;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DashboardSummary &&
          other.greeting == greeting &&
          other.streakDays == streakDays &&
          other.cardsDueToday == cardsDueToday &&
          other.coveragePercent == coveragePercent);

  @override
  int get hashCode =>
      Object.hash(greeting, streakDays, cardsDueToday, coveragePercent);
}
