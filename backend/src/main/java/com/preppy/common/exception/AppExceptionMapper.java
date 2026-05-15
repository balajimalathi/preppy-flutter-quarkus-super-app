package com.preppy.common.exception;

import com.preppy.common.AppException;
import com.preppy.common.ErrorResponse;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.ext.ExceptionMapper;
import jakarta.ws.rs.ext.Provider;

@Provider
public class AppExceptionMapper implements ExceptionMapper<AppException> {

    @Override
    public Response toResponse(final AppException exception) {
        return Response.status(exception.status())
                .entity(ErrorResponse.of(exception.getMessage()))
                .build();
    }
}
