# Config Module

The config module describes runtime configuration for local development, staging, and production.

## Environment Variables

Environment variables configure the database URL, session signing key, and HTTP port.

See [Environment Configuration](environments.md).

## Secret Handling

Secrets should not be committed to the repository.

Implementation: `config/load_env.ts`.
