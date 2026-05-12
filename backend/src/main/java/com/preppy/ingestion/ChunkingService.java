package com.preppy.ingestion;

import jakarta.enterprise.context.ApplicationScoped;
import java.util.List;

/**
 * Splits extracted text into overlapping, token-bounded chunks ready for embedding.
 */
@ApplicationScoped
public class ChunkingService {

    public List<String> chunk(final String text) {
        return List.of(); // TODO: implement token-aware chunking with overlap.
    }
}
