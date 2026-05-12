package com.preppy.pyq;

import jakarta.inject.Inject;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

/**
 * Previous-year question browsing and analytics.
 */
@Path("/pyq")
@Produces(MediaType.APPLICATION_JSON)
public class PyqResource {

    @Inject
    PyqService pyqService;

    @Inject
    PyqAnalyticsService pyqAnalyticsService;

    @GET
    public Object list() {
        return pyqService.list();
    }

    @GET
    @Path("/analytics")
    public Object analytics() {
        return pyqAnalyticsService.topicFrequency();
    }
}
