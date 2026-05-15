package com.preppy.common.exception;

import com.preppy.common.ErrorResponse;
import io.quarkus.security.AuthenticationFailedException;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.ext.ExceptionMapper;
import jakarta.ws.rs.ext.Provider;

@Provider
public class AuthenticationFailedExceptionMapper implements ExceptionMapper<AuthenticationFailedException> {

    @Override
    public Response toResponse(final AuthenticationFailedException exception) {
        final String message = exception.getMessage() != null
                ? exception.getMessage()
                : "Missing or invalid Bearer token";
        return Response.status(Response.Status.UNAUTHORIZED)
                .entity(ErrorResponse.of(message))
                .build();
    }
}
