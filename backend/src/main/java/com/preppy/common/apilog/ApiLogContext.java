package com.preppy.common.apilog;

import io.vertx.ext.web.RoutingContext;
import jakarta.ws.rs.container.ContainerRequestContext;

public final class ApiLogContext {

    public static final String REQUEST_ID = "preppy.request.id";
    public static final String START_TIME = "preppy.request.start";
    public static final String REQUEST_BODY = "preppy.request.body";
    public static final String REQUEST_HEADERS = "preppy.request.headers";
    public static final String ERROR_MESSAGE = "preppy.request.error";
    public static final String ERROR_STATUS = "preppy.request.error.status";
    public static final String DETAILED_LOGGED = "preppy.http.detailed";

    private ApiLogContext() {}

    public static boolean shouldSkipLogging(final String path) {
        if (path == null) {
            return false;
        }
        if (path.startsWith("/q/dev/api-log-viewer")) {
            return true;
        }
        return path.equals("/q/dev/access.log")
                || path.equals("/q/dev/api-logs")
                || path.startsWith("/q/dev/api-logs/");
    }

    public static void reportError(
            final ContainerRequestContext requestContext, final String message, final int status) {
        if (requestContext == null || message == null) {
            return;
        }
        requestContext.setProperty(ERROR_MESSAGE, message);
        requestContext.setProperty(ERROR_STATUS, status);
    }

    public static void markDetailedLogged(final RoutingContext routingContext) {
        if (routingContext != null) {
            routingContext.put(DETAILED_LOGGED, true);
        }
    }
}
