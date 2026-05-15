package com.preppy.common.exception;

import com.preppy.common.ErrorResponse;
import com.preppy.common.apilog.ApiLogContext;
import jakarta.validation.ConstraintViolation;
import jakarta.validation.ConstraintViolationException;
import jakarta.ws.rs.container.ContainerRequestContext;
import jakarta.ws.rs.core.Context;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.ext.ExceptionMapper;
import jakarta.ws.rs.ext.Provider;
import java.util.List;
import java.util.stream.Collectors;
import org.jboss.logging.Logger;

@Provider
public class ValidationExceptionMapper implements ExceptionMapper<ConstraintViolationException> {

    private static final Logger LOG = Logger.getLogger(ValidationExceptionMapper.class);

    @Context
    ContainerRequestContext requestContext;

    @Override
    public Response toResponse(final ConstraintViolationException exception) {
        final List<String> errors = exception.getConstraintViolations().stream()
                .map(ValidationExceptionMapper::formatViolation)
                .collect(Collectors.toList());
        final String message = "Request validation failed";
        LOG.warnf("Validation failed: %s", errors);
        ApiLogContext.reportError(
                requestContext,
                message + ": " + String.join("; ", errors),
                Response.Status.BAD_REQUEST.getStatusCode());
        return Response.status(Response.Status.BAD_REQUEST)
                .entity(ErrorResponse.of(message, errors))
                .build();
    }

    static String formatViolation(final ConstraintViolation<?> violation) {
        final String path = violation.getPropertyPath() != null
                ? violation.getPropertyPath().toString()
                : "request";
        return path + ": " + violation.getMessage();
    }
}
