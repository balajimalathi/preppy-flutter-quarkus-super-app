package com.preppy.dashboard;

/**
 * Static dashboard summary payload for the mobile demo endpoint.
 */
public record DashboardSummaryDto(
        String greeting,
        int streakDays,
        int cardsDueToday,
        int coveragePercent) {}
