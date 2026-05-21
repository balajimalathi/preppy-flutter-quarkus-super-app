package com.preppy.common;

import jakarta.ws.rs.core.Response.Status;
import java.util.List;

/**
 * Domain exception that carries an HTTP status. Translated by a JAX-RS
 * {@link jakarta.ws.rs.ext.ExceptionMapper} (to be added when needed).
 */
public class AppException extends RuntimeException {

    private final Status status;
    private final List<String> errors;

    public AppException(final Status status, final String message) {
        super(message);
        this.status = status;
        this.errors = null;
    }

    public AppException(final Status status, final String message, final Throwable cause) {
        super(message, cause);
        this.status = status;
        this.errors = null;
    }

    public AppException(final Status status, final String message, final List<String> errors) {
        super(message);
        this.status = status;
        this.errors = errors == null || errors.isEmpty() ? null : List.copyOf(errors);
    }

    public Status status() {
        return status;
    }

    public List<String> errors() {
        return errors;
    }

    public static AppException notFound(final String message) {
        return new AppException(Status.NOT_FOUND, message);
    }

    public static AppException badRequest(final String message) {
        return new AppException(Status.BAD_REQUEST, message);
    }

    public static AppException badRequest(final String message, final List<String> errors) {
        return new AppException(Status.BAD_REQUEST, message, errors);
    }

    public static AppException unauthorized(final String message) {
        return new AppException(Status.UNAUTHORIZED, message);
    }
}
