package com.preppy.question;

import io.quarkus.test.junit.QuarkusTest;
import jakarta.inject.Inject;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertNotNull;

@QuarkusTest
class QuestionServiceTest {

    @Inject
    QuestionService questionService;

    @Test
    void serviceIsInjectable() {
        assertNotNull(questionService);
    }
}
