package com.preppy.common.apilog;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.quarkus.arc.profile.IfBuildProfile;
import io.quarkus.runtime.StartupEvent;
import io.vertx.ext.web.Router;
import io.vertx.ext.web.RoutingContext;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.enterprise.event.Observes;
import jakarta.inject.Inject;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.UUID;
import org.jboss.logging.Logger;

/**
 * Logs HTTP requests that never reach {@link RequestLoggingFilter} (e.g. 401 from
 * Quarkus HTTP auth). Detailed request/response bodies are still logged by the JAX-RS filter
 * when the request proceeds into REST.
 */
@ApplicationScoped
@IfBuildProfile("dev")
public class DevHttpAccessLogger {

    private static final Logger LOG = Logger.getLogger("com.preppy.http");

    @Inject
    ObjectMapper objectMapper;

    void register(@Observes final StartupEvent event, final Router router) {
        router.route()
                .order(-200)
                .handler(this::handle);
    }

    private void handle(final RoutingContext ctx) {
        final String path = ctx.request().path();
        if (ApiLogContext.shouldSkipLogging(path)) {
            ctx.next();
            return;
        }

        final String requestId = UUID.randomUUID().toString();
        ctx.put(ApiLogContext.REQUEST_ID, requestId);
        ctx.put(ApiLogContext.START_TIME, System.currentTimeMillis());

        ctx.addEndHandler(v -> {
            if (Boolean.TRUE.equals(ctx.get(ApiLogContext.DETAILED_LOGGED))) {
                return;
            }
            final long start = ctx.get(ApiLogContext.START_TIME) != null
                    ? (long) ctx.get(ApiLogContext.START_TIME)
                    : System.currentTimeMillis();
            final long durationMs = System.currentTimeMillis() - start;
            final Map<String, Object> payload = new LinkedHashMap<>();
            payload.put("phase", "response");
            payload.put("requestId", requestId);
            payload.put("method", ctx.request().method().name());
            payload.put("path", path);
            final String query = ctx.request().query();
            if (query != null) {
                payload.put("query", query);
            }
            payload.put("status", ctx.response().getStatusCode());
            payload.put("durationMs", durationMs);
            logJson(payload);
        });

        ctx.next();
    }

    private void logJson(final Map<String, Object> payload) {
        try {
            LOG.info(objectMapper.writeValueAsString(payload));
        } catch (final JsonProcessingException e) {
            LOG.info(payload.toString());
        }
    }
}
