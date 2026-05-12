package com.preppy.srs;

import jakarta.enterprise.context.ApplicationScoped;

/**
 * Assembles a daily plan = (due flashcards) ∪ (under-covered syllabus topics) ∪
 * (PYQ trending items), capped by the user's daily time budget.
 */
@ApplicationScoped
public class DailyPlanService {

    public Object today() {
        return null; // TODO: build today's plan.
    }
}
