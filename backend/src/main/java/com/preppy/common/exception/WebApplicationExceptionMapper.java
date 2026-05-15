package com.preppy.common.exception;

import com.preppy.common.ErrorResponse;
import com.preppy.common.apilog.ApiLogContext;
import jakarta.ws.rs.WebApplicationException;
import jakarta.ws.rs.container.ContainerRequestContext;
import jakarta.ws.rs.core.Context;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.ext.ExceptionMapper;
import jakarta.ws.rs.ext.Provider;
import org.jboss.logging.Logger;

@Provider
public class WebApplicationExceptionMapper implements ExceptionMapper<WebApplicationException> {

    private static final Logger LOG = Logger.getLogger(WebApplicationExceptionMapper.class);

    @Context
    ContainerRequestContext requestContext;

    @Override
    public Response toResponse(final WebApplicationException exception) {
        final Response response = exception.getResponse();
        final String message = exception.getMessage() != null
                ? exception.getMessage()
                : "HTTP " + response.getStatus();
        if (response.getStatus() >= 500) {
            LOG.errorf(exception, "Web application error: %s", message);
        } else {
            LOG.warnf("Web application error: %s", message);
        }
        ApiLogContext.reportError(requestContext, message, response.getStatus());
        return Response.status(response.getStatus())
                .entity(ErrorResponse.of(message))
                .build();
    }
}
