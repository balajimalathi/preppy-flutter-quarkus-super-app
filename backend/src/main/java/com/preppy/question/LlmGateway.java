package com.preppy.question;

import java.util.List;

/**
 * Abstract LLM boundary. A concrete provider (OpenAI / Anthropic / Gemini /
 * local) is plugged in later via CDI {@code @Alternative}.
 */
public interface LlmGateway {

    String complete(String prompt);

    List<Float> embed(String text);
}
