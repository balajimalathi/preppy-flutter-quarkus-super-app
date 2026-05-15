package com.preppy.common.exception;

import com.preppy.common.ErrorResponse;
import com.preppy.common.apilog.ApiLogContext;
import jakarta.ws.rs.container.ContainerRequestContext;
import jakarta.ws.rs.core.Context;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.ext.ExceptionMapper;
import jakarta.ws.rs.ext.Provider;
import org.jboss.logging.Logger;

@Provider
public class ThrowableMapper implements ExceptionMapper<Throwable> {

    private static final Logger LOG = Logger.getLogger(ThrowableMapper.class);

    @Context
    ContainerRequestContext requestContext;

    @Override
    public Response toResponse(final Throwable exception) {
        LOG.error("Unhandled exception", exception);
        final String message = exception.getMessage() != null && !exception.getMessage().isBlank()
                ? exception.getMessage()
                : exception.getClass().getSimpleName() + " occurred while processing the request";
        ApiLogContext.reportError(
                requestContext, message, Response.Status.INTERNAL_SERVER_ERROR.getStatusCode());
        return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                .entity(ErrorResponse.of(message))
                .build();
    }
}
