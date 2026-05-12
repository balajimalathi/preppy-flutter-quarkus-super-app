package com.preppy.question;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;

/**
 * Generates MCQs from chunks via {@link LlmGateway} and persists them.
 */
@ApplicationScoped
public class QuestionService {

    @Inject
    LlmGateway llmGateway;

    public Object generate() {
        return null; // TODO: retrieve top-k chunks, prompt LLM, parse + persist.
    }
}
