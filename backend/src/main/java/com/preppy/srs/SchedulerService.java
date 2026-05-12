package com.preppy.srs;

import jakarta.enterprise.context.ApplicationScoped;
import java.time.Instant;

/**
 * Pure-function scheduler: given a card's history and a rating, return the next
 * due timestamp + ease factor. Kept separate so it can be unit-tested in isolation.
 */
@ApplicationScoped
public class SchedulerService {

    public Instant nextDue(final int repetitions, final double easeFactor, final int rating) {
        return Instant.now(); // TODO: SM-2 / FSRS implementation.
    }
}
