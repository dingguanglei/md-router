# Environment Configuration

This document describes configuration differences between local development, staging, and production.

## Local Development

Local development uses a local database and relaxed logging settings.

## Staging

Staging should match production behavior while using isolated credentials.

## Production

Production requires explicit values for database URL, session signing key, and allowed origins.

Implementation: `config/production.ts`.
