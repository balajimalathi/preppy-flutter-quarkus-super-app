package com.preppy.common.apilog;

import io.quarkus.arc.profile.IfBuildProfile;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;

/**
 * Serves {@code backend/.log} for the dev API log viewer. Excluded from
 * {@link com.preppy.common.RequestLoggingFilter} to avoid poll feedback loops.
 */
@Path("/q/dev/access.log")
@IfBuildProfile("dev")
public class AccessLogResource {

    private static final java.nio.file.Path LOG_FILE = Paths.get(".log");

    @GET
    @Produces(MediaType.TEXT_PLAIN)
    public Response get() throws IOException {
        if (!Files.isRegularFile(LOG_FILE)) {
            return Response.ok("")
                    .header("Cache-Control", "no-store")
                    .build();
        }
        final String content = Files.readString(LOG_FILE, StandardCharsets.UTF_8);
        return Response.ok(content)
                .header("Cache-Control", "no-store")
                .build();
    }
}
