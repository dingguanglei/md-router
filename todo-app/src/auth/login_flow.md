# Login Flow

This document describes the request and response flow for user login in the Todo API.

## Credential Validation

The login endpoint validates email and password credentials before creating a session.

Implementation: `src/auth/login.ts`.

## Session Token Creation

After credentials are validated, the service creates a signed session token and stores session metadata.

Implementation: `src/auth/session.ts`.

## Login Failure Cases

Invalid credentials return authentication errors without exposing whether the email exists.

See [API Error Handling](../api/error_handling.md).
