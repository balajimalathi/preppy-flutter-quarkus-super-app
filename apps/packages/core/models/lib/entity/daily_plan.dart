class DailyPlan {
  const DailyPlan({
    required this.date,
    required this.minutesBudget,
    required this.items,
  });

  final DateTime date;
  final int minutesBudget;
  final List<String> items;
}
