package com.preppy.common;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.preppy.common.apilog.ApiLogContext;
import com.preppy.common.apilog.ApiLogSanitizer;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import io.quarkus.vertx.http.runtime.CurrentVertxRequest;
import io.vertx.ext.web.RoutingContext;
import jakarta.enterprise.inject.Instance;
import jakarta.ws.rs.container.ContainerRequestContext;
import jakarta.ws.rs.container.ContainerRequestFilter;
import jakarta.ws.rs.container.ContainerResponseContext;
import jakarta.ws.rs.container.ContainerResponseFilter;
import jakarta.ws.rs.ext.Provider;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.UUID;
import org.jboss.logging.Logger;

@Provider
@ApplicationScoped
public class RequestLoggingFilter implements ContainerRequestFilter, ContainerResponseFilter {

    private static final Logger LOG = Logger.getLogger("com.preppy.http");

    @Inject
    ObjectMapper objectMapper;

    @Inject
    Instance<CurrentVertxRequest> currentVertxRequest;

    @Override
    public void filter(final ContainerRequestContext requestContext) throws IOException {
        final String path = requestContext.getUriInfo().getPath();
        if (ApiLogContext.shouldSkipLogging(path)) {
            return;
        }

        ApiLogContext.markDetailedLogged(routingContext());

        final String requestId = resolveRequestId();
        requestContext.setProperty(ApiLogContext.REQUEST_ID, requestId);
        requestContext.setProperty(ApiLogContext.START_TIME, System.currentTimeMillis());

        final String method = requestContext.getMethod();
        final String query = requestContext.getUriInfo().getRequestUri().getQuery();
        final String contentType = requestContext.getHeaderString("Content-Type");
        final Map<String, String> headers = ApiLogSanitizer.sanitizeHeaders(requestContext.getHeaders());

        requestContext.setProperty(ApiLogContext.REQUEST_HEADERS, headers);

        String requestBody = null;
        if (requestContext.hasEntity() && ApiLogSanitizer.shouldCaptureBody(contentType)) {
            final byte[] bytes = readAllBytes(requestContext.getEntityStream());
            requestContext.setEntityStream(new ByteArrayInputStream(bytes));
            requestBody = ApiLogSanitizer.truncateBytes(bytes);
        } else if (contentType != null && !ApiLogSanitizer.shouldCaptureBody(contentType)) {
            requestBody = "[" + contentType.split(";")[0].trim() + " omitted]";
        }

        requestContext.setProperty(ApiLogContext.REQUEST_BODY, requestBody);

        logAccess("request", requestId, method, path, query, null, null, headers, requestBody, null, null);
    }

    @Override
    public void filter(
            final ContainerRequestContext requestContext,
            final ContainerResponseContext responseContext)
            throws IOException {
        final String path = requestContext.getUriInfo().getPath();
        if (ApiLogContext.shouldSkipLogging(path)) {
            return;
        }

        ApiLogContext.markDetailedLogged(routingContext());

        final String requestId = (String) requestContext.getProperty(ApiLogContext.REQUEST_ID);
        if (requestId == null) {
            return;
        }
        final Long start = (Long) requestContext.getProperty(ApiLogContext.START_TIME);
        final long durationMs = start != null ? System.currentTimeMillis() - start : -1;

        final String method = requestContext.getMethod();
        final String query = requestContext.getUriInfo().getRequestUri().getQuery();
        final int status = responseContext.getStatus();
        final String errorMessage = (String) requestContext.getProperty(ApiLogContext.ERROR_MESSAGE);
        final String responseBody = serializeEntity(responseContext.getEntity());

        @SuppressWarnings("unchecked")
        final Map<String, String> requestHeaders =
                (Map<String, String>) requestContext.getProperty(ApiLogContext.REQUEST_HEADERS);
        final String requestBody = (String) requestContext.getProperty(ApiLogContext.REQUEST_BODY);

        final Object errorStatus = requestContext.getProperty(ApiLogContext.ERROR_STATUS);
        final int recordedStatus = errorStatus instanceof Integer i ? i : status;

        logAccess(
                "response",
                requestId,
                method,
                path,
                query,
                recordedStatus,
                durationMs,
                requestHeaders,
                requestBody,
                responseBody,
                errorMessage);
    }

    private String resolveRequestId() {
        final RoutingContext routingContext = routingContext();
        if (routingContext != null && routingContext.get(ApiLogContext.REQUEST_ID) != null) {
            return (String) routingContext.get(ApiLogContext.REQUEST_ID);
        }
        return UUID.randomUUID().toString();
    }

    private RoutingContext routingContext() {
        if (!currentVertxRequest.isResolvable()) {
            return null;
        }
        return currentVertxRequest.get().getCurrent();
    }

    private void logAccess(
            final String phase,
            final String requestId,
            final String method,
            final String path,
            final String query,
            final Integer status,
            final Long durationMs,
            final Map<String, String> requestHeaders,
            final String requestBody,
            final String responseBody,
            final String errorMessage) {
        final Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("phase", phase);
        payload.put("requestId", requestId);
        payload.put("method", method);
        payload.put("path", path);
        if (query != null) {
            payload.put("query", query);
        }
        if (status != null) {
            payload.put("status", status);
        }
        if (durationMs != null) {
            payload.put("durationMs", durationMs);
        }
        if (requestHeaders != null && !requestHeaders.isEmpty()) {
            payload.put("requestHeaders", requestHeaders);
        }
        if (requestBody != null) {
            payload.put("requestBody", requestBody);
        }
        if (responseBody != null) {
            payload.put("responseBody", responseBody);
        }
        if (errorMessage != null) {
            payload.put("errorMessage", errorMessage);
        }
        try {
            LOG.info(objectMapper.writeValueAsString(payload));
        } catch (final JsonProcessingException e) {
            LOG.infof(
                    "%s %s %s %s status=%s durationMs=%s",
                    phase,
                    requestId,
                    method,
                    path,
                    status,
                    durationMs);
        }
    }

    private String serializeEntity(final Object entity) {
        if (entity == null) {
            return null;
        }
        if (entity instanceof String s) {
            return ApiLogSanitizer.truncate(s);
        }
        if (entity instanceof byte[] bytes) {
            return ApiLogSanitizer.truncateBytes(bytes);
        }
        try {
            return ApiLogSanitizer.truncate(objectMapper.writeValueAsString(entity));
        } catch (final JsonProcessingException e) {
            return ApiLogSanitizer.truncate(String.valueOf(entity));
        }
    }

    private static byte[] readAllBytes(final InputStream stream) throws IOException {
        return stream.readAllBytes();
    }
}
