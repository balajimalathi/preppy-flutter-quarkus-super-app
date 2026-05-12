package com.preppy.srs;

import jakarta.inject.Inject;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

/**
 * Spaced repetition + daily plan endpoints.
 */
@Path("/srs")
@Produces(MediaType.APPLICATION_JSON)
public class SrsResource {

    @Inject
    SrsService srsService;

    @Inject
    DailyPlanService dailyPlanService;

    @POST
    @Path("/review")
    public Object review() {
        return srsService.recordReview();
    }

    @GET
    @Path("/plan/today")
    public Object today() {
        return dailyPlanService.today();
    }
}
