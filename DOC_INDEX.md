# DOC_INDEX.md

<!-- AUTO-GENERATED. DO NOT EDIT. -->
<!-- DOC_INDEX_SOURCE_HASH: 9980b18af1896a91b07576be3299568d48eee2b265aaf139e90a3b757a4dc344 -->

## [[README.md|README.md]]
- L1 md-router
  - L7 Why
  - L13 Install
  - L40 Search workflow
  - L63 Default ignores
  - L75 Use as a coding-agent skill
  - L86 Markdown style
  - L107 Obsidian links
  - L142 Compact index format
  - L155 Requirements
  - L161 License
refs: `./scripts/doc_scan.sh`, `[Error handling](../api/error_handling.md)`

## [[examples/todo-app/config/README.md|examples/todo-app/config/README.md]]
- L1 Config Module
  - L5 Environment Variables
  - L11 Secret Handling
refs: `config/load_env.ts`
links: [[examples/todo-app/config/environments.md|environments.md]]

## [[examples/todo-app/config/environments.md|examples/todo-app/config/environments.md]]
- L1 Environment Configuration
  - L5 Local Development
  - L9 Staging
  - L13 Production
refs: `config/production.ts`

## [[examples/todo-app/src/api/README.md|examples/todo-app/src/api/README.md]]
- L1 API Module
  - L5 Route Handlers
  - L11 Request Validation
  - L17 Error Handling
refs: `src/api/routes.ts`, `src/api/validation.ts`
links: [[examples/todo-app/src/api/error_handling.md|error_handling.md]]

## [[examples/todo-app/src/api/error_handling.md|examples/todo-app/src/api/error_handling.md]]
- L1 API Error Handling
  - L5 Validation Errors
  - L11 Authentication Errors
  - L17 Server Errors
refs: `src/api/error_handler.ts`, `src/api/validation.ts`
links: [[examples/todo-app/src/auth/README.md|../auth/README.md]]

## [[examples/todo-app/src/auth/README.md|examples/todo-app/src/auth/README.md]]
- L1 Auth Module
  - L5 Login Flow
  - L11 Session Validation
  - L17 Logout Behavior
refs: `src/auth/login.ts`, `src/auth/session.ts`
links: [[examples/todo-app/src/api/error_handling.md|../api/error_handling.md]]

## [[examples/todo-app/src/auth/login_flow.md|examples/todo-app/src/auth/login_flow.md]]
- L1 Login Flow
  - L5 Credential Validation
  - L11 Session Token Creation
  - L17 Login Failure Cases
refs: `src/auth/login.ts`, `src/auth/session.ts`
links: [[examples/todo-app/src/api/error_handling.md|../api/error_handling.md]]

## [[examples/todo-app/src/db/README.md|examples/todo-app/src/db/README.md]]
- L1 Database Module
  - L5 Schema Ownership
  - L11 Migration Workflow
refs: `src/db/schema.sql`
links: [[examples/todo-app/src/db/migrations.md|migrations.md]]

## [[examples/todo-app/src/db/migrations.md|examples/todo-app/src/db/migrations.md]]
- L1 Database Migrations
  - L5 Creating a Migration
  - L9 Applying Migrations
  - L15 Rollback Policy
refs: `src/db/migrate.ts`, `src/db/migrations/`
