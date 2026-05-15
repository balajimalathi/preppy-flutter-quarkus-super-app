package com.preppy.common.exception;

import com.preppy.common.AppException;
import com.preppy.common.ErrorResponse;
import com.preppy.common.apilog.ApiLogContext;
import jakarta.ws.rs.container.ContainerRequestContext;
import jakarta.ws.rs.core.Context;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.ext.ExceptionMapper;
import jakarta.ws.rs.ext.Provider;
import org.jboss.logging.Logger;

@Provider
public class AppExceptionMapper implements ExceptionMapper<AppException> {

    private static final Logger LOG = Logger.getLogger(AppExceptionMapper.class);

    @Context
    ContainerRequestContext requestContext;

    @Override
    public Response toResponse(final AppException exception) {
        LOG.errorf(exception, "Application error: %s", exception.getMessage());
        ApiLogContext.reportError(
                requestContext, exception.getMessage(), exception.status().getStatusCode());
        return Response.status(exception.status())
                .entity(ErrorResponse.of(exception.getMessage()))
                .build();
    }
}
