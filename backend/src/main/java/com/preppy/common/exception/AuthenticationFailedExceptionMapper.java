package com.preppy.common.exception;

import com.preppy.common.ErrorResponse;
import com.preppy.common.apilog.ApiLogContext;
import io.quarkus.security.AuthenticationFailedException;
import jakarta.ws.rs.container.ContainerRequestContext;
import jakarta.ws.rs.core.Context;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.ext.ExceptionMapper;
import jakarta.ws.rs.ext.Provider;
import org.jboss.logging.Logger;

@Provider
public class AuthenticationFailedExceptionMapper implements ExceptionMapper<AuthenticationFailedException> {

    private static final Logger LOG = Logger.getLogger(AuthenticationFailedExceptionMapper.class);

    @Context
    ContainerRequestContext requestContext;

    @Override
    public Response toResponse(final AuthenticationFailedException exception) {
        final String message = exception.getMessage() != null
                ? exception.getMessage()
                : "Missing or invalid Bearer token";
        LOG.warnf("Authentication failed: %s", message);
        ApiLogContext.reportError(
                requestContext, message, Response.Status.UNAUTHORIZED.getStatusCode());
        return Response.status(Response.Status.UNAUTHORIZED)
                .entity(ErrorResponse.of(message))
                .build();
    }
}
