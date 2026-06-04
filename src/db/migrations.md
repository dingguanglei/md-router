# Database Migrations

This document explains how database schema changes are created, reviewed, and applied.

## Creating a Migration

New migrations are stored under `src/db/migrations/`.

## Applying Migrations

Migrations are applied before the server starts in production.

Implementation: `src/db/migrate.ts`.

## Rollback Policy

Rollback scripts should be provided for destructive schema changes.
