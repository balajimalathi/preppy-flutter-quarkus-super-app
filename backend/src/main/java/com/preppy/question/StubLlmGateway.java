package com.preppy.question;

import jakarta.enterprise.context.ApplicationScoped;
import java.util.List;

/**
 * Default {@link LlmGateway} until a real provider is registered (for example
 * as a CDI {@code @Alternative}).
 */
@ApplicationScoped
public class StubLlmGateway implements LlmGateway {

    @Override
    public String complete(String prompt) {
        return "";
    }

    @Override
    public List<Float> embed(String text) {
        return List.of();
    }
}
