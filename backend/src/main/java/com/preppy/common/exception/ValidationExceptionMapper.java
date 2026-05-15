package com.preppy.common.exception;

import com.preppy.common.ErrorResponse;
import jakarta.validation.ConstraintViolation;
import jakarta.validation.ConstraintViolationException;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.ext.ExceptionMapper;
import jakarta.ws.rs.ext.Provider;
import java.util.List;
import java.util.stream.Collectors;

@Provider
public class ValidationExceptionMapper implements ExceptionMapper<ConstraintViolationException> {

    @Override
    public Response toResponse(final ConstraintViolationException exception) {
        final List<String> errors = exception.getConstraintViolations().stream()
                .map(ValidationExceptionMapper::formatViolation)
                .collect(Collectors.toList());
        return Response.status(Response.Status.BAD_REQUEST)
                .entity(ErrorResponse.of("Request validation failed", errors))
                .build();
    }

    static String formatViolation(final ConstraintViolation<?> violation) {
        final String path = violation.getPropertyPath() != null
                ? violation.getPropertyPath().toString()
                : "request";
        return path + ": " + violation.getMessage();
    }
}
