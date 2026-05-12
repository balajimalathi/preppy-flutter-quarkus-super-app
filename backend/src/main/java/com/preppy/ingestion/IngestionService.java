package com.preppy.ingestion;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;

/**
 * Orchestrates: file storage -> OCR -> chunking -> embedding -> Qdrant upsert.
 */
@ApplicationScoped
public class IngestionService {

    @Inject
    OcrService ocrService;

    @Inject
    ChunkingService chunkingService;

    public Object enqueue() {
        return null; // TODO: persist Document row, dispatch background pipeline.
    }
}
