package com.preppy.ingestion;

import jakarta.enterprise.context.ApplicationScoped;

/**
 * Pluggable OCR boundary. The default implementation will use Apache PDFBox for
 * text-based PDFs; image-only PDFs / scans can be routed to an external OCR API.
 */
@ApplicationScoped
public class OcrService {

    public String extractText(final byte[] bytes) {
        return ""; // TODO: PDFBox / external OCR.
    }
}
