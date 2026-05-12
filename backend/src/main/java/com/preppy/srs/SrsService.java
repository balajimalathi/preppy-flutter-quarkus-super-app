package com.preppy.srs;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;

/**
 * Implements the SM-2 / FSRS scheduling algorithm and updates {@code srs_state}.
 */
@ApplicationScoped
public class SrsService {

    @Inject
    SchedulerService schedulerService;

    public Object recordReview() {
        return null; // TODO: take a rating, compute next interval, persist.
    }
}
