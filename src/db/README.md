# Database Module

The database module owns schema definitions, migrations, and database access utilities for the Todo service.

## Schema Ownership

Database schema files define users, todo items, sessions, and migration metadata.

Implementation: `src/db/schema.sql`.

## Migration Workflow

Schema changes should be represented as ordered migrations.

See [Database Migrations](migrations.md).
