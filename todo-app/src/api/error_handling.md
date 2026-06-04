# API Error Handling

This document describes how the Todo API represents validation errors, authentication failures, and server-side exceptions.

## Validation Errors

Validation errors use HTTP 400 and include field-level messages.

Implementation: `src/api/validation.ts`.

## Authentication Errors

Authentication errors use HTTP 401 when the user is not logged in and HTTP 403 when the user lacks permission.

Related document: [Auth Module](../auth/README.md).

## Server Errors

Unexpected server errors use HTTP 500 and should not expose internal stack traces.

Implementation: `src/api/error_handler.ts`.
