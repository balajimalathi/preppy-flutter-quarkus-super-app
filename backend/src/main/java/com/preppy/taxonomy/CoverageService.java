package com.preppy.taxonomy;

import jakarta.enterprise.context.ApplicationScoped;

/**
 * Computes "how much of the syllabus has the user attempted / mastered".
 * Drives the dashboard heatmap and gates the daily plan.
 */
@ApplicationScoped
public class CoverageService {

    public Object summary() {
        return null; // TODO: aggregate srs_state per syllabus_item for current user.
    }
}
