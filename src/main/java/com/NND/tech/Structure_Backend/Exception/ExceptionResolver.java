package com.NND.tech.Structure_Backend.Exception;

import io.jsonwebtoken.ExpiredJwtException;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ProblemDetail;
import org.springframework.security.authentication.AccountStatusException;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

import java.nio.file.AccessDeniedException;
import java.security.SignatureException;

@ControllerAdvice
public class ExceptionResolver extends ResponseEntityExceptionHandler {

    @ExceptionHandler(Exception.class)
    public ProblemDetail handleSecurityException(Exception exception) {

        if (exception instanceof BadCredentialsException) {
            return createProblemDetail(401, exception.getMessage(), "The username or password is incorrect");
        } else if (exception instanceof AccountStatusException) {
            return createProblemDetail(403, exception.getMessage(), "The account is locked");
        } else if (exception instanceof AccessDeniedException) {
            return createProblemDetail(403, exception.getMessage(), "You are not authorized to access this resource");
        } else if (exception instanceof SignatureException) {
            return createProblemDetail(403, exception.getMessage(), "The JWT signature is invalid");
        } else if (exception instanceof ExpiredJwtException) {
            return createProblemDetail(403, exception.getMessage(), "The JWT token has expired");
        } else {
            return createProblemDetail(500, exception.getMessage(), "Unknown internal server error.");
        }
    }


    private ProblemDetail createProblemDetail(int status, String message, String description) {
        ProblemDetail detail = ProblemDetail.forStatusAndDetail(HttpStatusCode.valueOf(status), message);
        detail.setProperty("description", description);
        return detail;
    }
}
