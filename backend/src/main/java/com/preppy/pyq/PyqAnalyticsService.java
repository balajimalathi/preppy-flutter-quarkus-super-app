package com.preppy.pyq;

import jakarta.enterprise.context.ApplicationScoped;

/**
 * Computes "how often does topic X appear in the last N years" and exposes
 * trending signals that feed back into the daily plan.
 */
@ApplicationScoped
public class PyqAnalyticsService {

    public Object topicFrequency() {
        return null; // TODO: aggregate pyq_topic_freq, return ranked list.
    }
}
