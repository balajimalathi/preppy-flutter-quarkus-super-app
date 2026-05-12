package com.preppy.ingestion;

import io.quarkus.test.junit.QuarkusTest;
import jakarta.inject.Inject;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertNotNull;

@QuarkusTest
class ChunkingServiceTest {

    @Inject
    ChunkingService chunkingService;

    @Test
    void serviceIsInjectable() {
        assertNotNull(chunkingService);
    }
}
