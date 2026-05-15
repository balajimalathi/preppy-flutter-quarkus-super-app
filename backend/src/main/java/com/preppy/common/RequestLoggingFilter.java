package com.preppy.common;

import jakarta.ws.rs.container.ContainerRequestContext;
import jakarta.ws.rs.container.ContainerRequestFilter;
import jakarta.ws.rs.container.ContainerResponseContext;
import jakarta.ws.rs.container.ContainerResponseFilter;
import jakarta.ws.rs.ext.Provider;
import java.io.IOException;
import org.jboss.logging.Logger;

@Provider
public class RequestLoggingFilter implements ContainerRequestFilter, ContainerResponseFilter {

    private static final Logger LOG = Logger.getLogger(RequestLoggingFilter.class);
    private static final String START_TIME = "preppy.request.start";

    @Override
    public void filter(final ContainerRequestContext requestContext) throws IOException {
        requestContext.setProperty(START_TIME, System.currentTimeMillis());
        if (LOG.isDebugEnabled()) {
            LOG.debugf(
                    "Request %s %s",
                    requestContext.getMethod(),
                    requestContext.getUriInfo().getRequestUri());
        }
    }

    @Override
    public void filter(
            final ContainerRequestContext requestContext,
            final ContainerResponseContext responseContext)
            throws IOException {
        final Long start = (Long) requestContext.getProperty(START_TIME);
        final long durationMs = start != null ? System.currentTimeMillis() - start : -1;
        LOG.infof(
                "%s %s -> %d (%d ms)",
                requestContext.getMethod(),
                requestContext.getUriInfo().getPath(),
                responseContext.getStatus(),
                durationMs);
    }
}
