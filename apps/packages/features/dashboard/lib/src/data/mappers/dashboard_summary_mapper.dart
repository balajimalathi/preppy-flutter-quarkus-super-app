import 'dart:convert';

import '../../domain/entities/dashboard_summary.dart';

/// JSON mapping for dashboard summary API and Hive cache.
mixin DashboardSummaryMapper {
  static const cacheKey = 'dashboard_summary';

  DashboardSummary summaryFromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      greeting: json['greeting'] as String? ?? '',
      streakDays: (json['streakDays'] as num?)?.toInt() ?? 0,
      cardsDueToday: (json['cardsDueToday'] as num?)?.toInt() ?? 0,
      coveragePercent: (json['coveragePercent'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> summaryToJson(DashboardSummary summary) {
    return {
      'greeting': summary.greeting,
      'streakDays': summary.streakDays,
      'cardsDueToday': summary.cardsDueToday,
      'coveragePercent': summary.coveragePercent,
    };
  }

  String encodeSummary(DashboardSummary summary) =>
      jsonEncode(summaryToJson(summary));

  DashboardSummary decodeSummary(String raw) =>
      summaryFromJson(jsonDecode(raw) as Map<String, dynamic>);
}
