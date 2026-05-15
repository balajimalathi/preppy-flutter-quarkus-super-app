package com.preppy.common.exception;

import com.preppy.common.ErrorResponse;
import jakarta.ws.rs.WebApplicationException;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.ext.ExceptionMapper;
import jakarta.ws.rs.ext.Provider;

@Provider
public class WebApplicationExceptionMapper implements ExceptionMapper<WebApplicationException> {

    @Override
    public Response toResponse(final WebApplicationException exception) {
        final Response response = exception.getResponse();
        final String message = exception.getMessage() != null
                ? exception.getMessage()
                : "HTTP " + response.getStatus();
        return Response.status(response.getStatus())
                .entity(ErrorResponse.of(message))
                .build();
    }
}
