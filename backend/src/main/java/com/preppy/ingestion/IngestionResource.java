package com.preppy.ingestion;

import jakarta.inject.Inject;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

/**
 * Multipart uploads for PDFs / images that should be turned into questions.
 */
@Path("/ingestion")
@Produces(MediaType.APPLICATION_JSON)
public class IngestionResource {

    @Inject
    IngestionService ingestionService;

    @POST
    @Path("/upload")
    public Object upload() {
        return ingestionService.enqueue();
    }
}
