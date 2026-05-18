/// Study plan for a specific day.
class DailyPlan {
  const DailyPlan({
    required this.date,
    required this.minutesBudget,
    required this.items,
  });

  /// Calendar date this plan applies to.
  final DateTime date;

  /// Target study duration in minutes.
  final int minutesBudget;

  /// Ordered study items or task identifiers for the day.
  final List<String> items;
}
