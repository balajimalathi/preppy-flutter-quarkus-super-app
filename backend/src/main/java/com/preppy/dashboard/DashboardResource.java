package com.preppy.dashboard;

import com.preppy.common.ApiResponse;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

/**
 * Dashboard overview for the authenticated home screen (static demo data).
 */
@Path("/dashboard")
@Produces(MediaType.APPLICATION_JSON)
public class DashboardResource {

    @GET
    @Path("/summary")
    public ApiResponse<DashboardSummaryDto> summary() {
        final var dto = new DashboardSummaryDto(
                "Welcome back to Preppy",
                7,
                24,
                68);
        return ApiResponse.of(dto);
    }
}
