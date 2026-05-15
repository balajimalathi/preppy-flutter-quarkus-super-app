package com.preppy.common.exception;

import com.preppy.common.ErrorResponse;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.ext.ExceptionMapper;
import jakarta.ws.rs.ext.Provider;
import org.jboss.logging.Logger;

@Provider
public class ThrowableMapper implements ExceptionMapper<Throwable> {

    private static final Logger LOG = Logger.getLogger(ThrowableMapper.class);

    @Override
    public Response toResponse(final Throwable exception) {
        LOG.error("Unhandled exception", exception);
        final String message = exception.getMessage() != null && !exception.getMessage().isBlank()
                ? exception.getMessage()
                : exception.getClass().getSimpleName() + " occurred while processing the request";
        return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                .entity(ErrorResponse.of(message))
                .build();
    }
}
