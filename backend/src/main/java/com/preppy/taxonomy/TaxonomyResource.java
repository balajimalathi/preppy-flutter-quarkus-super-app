package com.preppy.taxonomy;

import jakarta.inject.Inject;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

/**
 * Exposes exam syllabi as trees and per-user coverage stats.
 */
@Path("/taxonomy")
@Produces(MediaType.APPLICATION_JSON)
public class TaxonomyResource {

    @Inject
    TaxonomyService taxonomyService;

    @Inject
    CoverageService coverageService;

    @GET
    @Path("/syllabus")
    public Object syllabus() {
        return taxonomyService.tree();
    }

    @GET
    @Path("/coverage")
    public Object coverage() {
        return coverageService.summary();
    }
}
