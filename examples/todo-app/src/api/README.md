# API Module

The API module defines HTTP routes, request validation, response formatting, and error handling for the Todo service.

## Route Handlers

Route handlers parse incoming requests and call the service layer.

Implementation: `src/api/routes.ts`.

## Request Validation

Request validation rejects malformed payloads before business logic runs.

Implementation: `src/api/validation.ts`.

## Error Handling

API errors are normalized before being returned to clients.

See [API Error Handling](error_handling.md).
