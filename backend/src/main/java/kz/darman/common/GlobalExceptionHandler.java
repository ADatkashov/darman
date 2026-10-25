package kz.darman.common;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.ConstraintViolationException;
import java.time.Instant;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.dao.OptimisticLockingFailureException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.web.HttpMediaTypeNotSupportedException;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;
import org.springframework.web.multipart.MaxUploadSizeExceededException;
import org.springframework.web.multipart.support.MissingServletRequestPartException;
import org.springframework.web.servlet.resource.NoResourceFoundException;

@RestControllerAdvice
public class GlobalExceptionHandler {
    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    @ExceptionHandler(ApiException.class)
    ResponseEntity<ApiError> api(ApiException e, HttpServletRequest req) {
        return build(e.status(), e.code(), e.getMessage(), req, List.of());
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    ResponseEntity<ApiError> invalid(MethodArgumentNotValidException e, HttpServletRequest req) {
        List<ApiError.FieldIssue> issues = e.getBindingResult().getFieldErrors().stream()
                .map(f -> new ApiError.FieldIssue(f.getField(), f.getCode(), f.getDefaultMessage())).toList();
        return build(HttpStatus.BAD_REQUEST, "VALIDATION_FAILED", "Request validation failed", req, issues);
    }

    @ExceptionHandler(ConstraintViolationException.class)
    ResponseEntity<ApiError> constraint(ConstraintViolationException e, HttpServletRequest req) {
        List<ApiError.FieldIssue> issues = e.getConstraintViolations().stream()
                .map(v -> new ApiError.FieldIssue(v.getPropertyPath().toString(), "Constraint", v.getMessage())).toList();
        return build(HttpStatus.BAD_REQUEST, "VALIDATION_FAILED", "Request validation failed", req, issues);
    }

    @ExceptionHandler({HttpMessageNotReadableException.class, MissingServletRequestParameterException.class,
            MethodArgumentTypeMismatchException.class, MissingServletRequestPartException.class})
    ResponseEntity<ApiError> badInput(Exception e, HttpServletRequest req) {
        return build(HttpStatus.BAD_REQUEST, "BAD_REQUEST", "Malformed request", req, List.of());
    }

    @ExceptionHandler(MaxUploadSizeExceededException.class)
    ResponseEntity<ApiError> tooLarge(Exception e, HttpServletRequest req) {
        return build(HttpStatus.PAYLOAD_TOO_LARGE, "FILE_TOO_LARGE", "Uploaded file is too large", req, List.of());
    }

    @ExceptionHandler(HttpRequestMethodNotSupportedException.class)
    ResponseEntity<ApiError> method(Exception e, HttpServletRequest req) {
        return build(HttpStatus.METHOD_NOT_ALLOWED, "METHOD_NOT_ALLOWED", "Method not allowed", req, List.of());
    }

    @ExceptionHandler(HttpMediaTypeNotSupportedException.class)
    ResponseEntity<ApiError> media(Exception e, HttpServletRequest req) {
        return build(HttpStatus.UNSUPPORTED_MEDIA_TYPE, "UNSUPPORTED_MEDIA_TYPE", "Unsupported media type", req, List.of());
    }

    @ExceptionHandler(NoResourceFoundException.class)
    ResponseEntity<ApiError> noResource(Exception e, HttpServletRequest req) {
        return build(HttpStatus.NOT_FOUND, "NOT_FOUND", "Resource not found", req, List.of());
    }

    @ExceptionHandler(AccessDeniedException.class)
    ResponseEntity<ApiError> denied(AccessDeniedException e, HttpServletRequest req) {
        return build(HttpStatus.FORBIDDEN, "FORBIDDEN", "Access denied", req, List.of());
    }

    @ExceptionHandler({OptimisticLockingFailureException.class})
    ResponseEntity<ApiError> locking(Exception e, HttpServletRequest req) {
        return build(HttpStatus.CONFLICT, "CONCURRENT_MODIFICATION", "The resource was modified concurrently, retry", req, List.of());
    }

    @ExceptionHandler(DataIntegrityViolationException.class)
    ResponseEntity<ApiError> integrity(DataIntegrityViolationException e, HttpServletRequest req) {
        log.warn("Data integrity violation: {}", e.getMostSpecificCause().getMessage());
        return build(HttpStatus.CONFLICT, "CONFLICT", "The request conflicts with existing data", req, List.of());
    }

    @ExceptionHandler(Exception.class)
    ResponseEntity<ApiError> unexpected(Exception e, HttpServletRequest req) {
        log.error("Unhandled error on {} {}", req.getMethod(), req.getRequestURI(), e);
        return build(HttpStatus.INTERNAL_SERVER_ERROR, "INTERNAL_ERROR", "Unexpected server error", req, List.of());
    }

    static ResponseEntity<ApiError> build(HttpStatus status, String code, String message, HttpServletRequest req,
                                          List<ApiError.FieldIssue> issues) {
        ApiError body = new ApiError(Instant.now(), status.value(), code, message, req.getRequestURI(),
                MDC.get(CorrelationIdFilter.MDC_KEY), issues.isEmpty() ? null : issues);
        return ResponseEntity.status(status).body(body);
    }
}
