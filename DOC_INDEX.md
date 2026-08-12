# DOC_INDEX.md

<!-- AUTO-GENERATED. DO NOT EDIT. -->
<!-- DOC_INDEX_SOURCE_HASH: c17d61af7aa3be81a2e087ce011ad655f02d0d85b822baa51910eadbcc6d615a -->
<!-- DOC_INDEX_SESSION_HASH: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855 -->

## [[README.md|README.md]]
- last_modified: `2026-08-12T05:02:00Z`
- L1 md-router
  - L7 Why
  - L13 Install
  - L46 Search workflow
  - L69 Default ignores
  - L81 Use as a coding-agent skill
  - L92 Markdown style
  - L113 Obsidian links
  - L148 Compact index format
  - L161 Requirements
  - L167 License
refs: `./scripts/doc_scan.sh`, `[Error handling](../api/error_handling.md)`, `~/.codex/sessions`

## [[examples/todo-app/config/README.md|examples/todo-app/config/README.md]]
- last_modified: `2026-08-11T05:31:04Z`
- L1 Config Module
  - L5 Environment Variables
  - L11 Secret Handling
refs: `config/load_env.ts`
links: [[examples/todo-app/config/environments.md|environments.md]]

## [[examples/todo-app/config/environments.md|examples/todo-app/config/environments.md]]
- last_modified: `2026-08-11T05:31:04Z`
- L1 Environment Configuration
  - L5 Local Development
  - L9 Staging
  - L13 Production
refs: `config/production.ts`

## [[examples/todo-app/src/api/README.md|examples/todo-app/src/api/README.md]]
- last_modified: `2026-08-11T05:31:04Z`
- L1 API Module
  - L5 Route Handlers
  - L11 Request Validation
  - L17 Error Handling
refs: `src/api/routes.ts`, `src/api/validation.ts`
links: [[examples/todo-app/src/api/error_handling.md|error_handling.md]]

## [[examples/todo-app/src/api/error_handling.md|examples/todo-app/src/api/error_handling.md]]
- last_modified: `2026-08-11T05:31:04Z`
- L1 API Error Handling
  - L5 Validation Errors
  - L11 Authentication Errors
  - L17 Server Errors
refs: `src/api/error_handler.ts`, `src/api/validation.ts`
links: [[examples/todo-app/src/auth/README.md|../auth/README.md]]

## [[examples/todo-app/src/auth/README.md|examples/todo-app/src/auth/README.md]]
- last_modified: `2026-08-11T05:31:04Z`
- L1 Auth Module
  - L5 Login Flow
  - L11 Session Validation
  - L17 Logout Behavior
refs: `src/auth/login.ts`, `src/auth/session.ts`
links: [[examples/todo-app/src/api/error_handling.md|../api/error_handling.md]]

## [[examples/todo-app/src/auth/login_flow.md|examples/todo-app/src/auth/login_flow.md]]
- last_modified: `2026-08-11T05:31:04Z`
- L1 Login Flow
  - L5 Credential Validation
  - L11 Session Token Creation
  - L17 Login Failure Cases
refs: `src/auth/login.ts`, `src/auth/session.ts`
links: [[examples/todo-app/src/api/error_handling.md|../api/error_handling.md]]

## [[examples/todo-app/src/db/README.md|examples/todo-app/src/db/README.md]]
- last_modified: `2026-08-11T05:31:04Z`
- L1 Database Module
  - L5 Schema Ownership
  - L11 Migration Workflow
refs: `src/db/schema.sql`
links: [[examples/todo-app/src/db/migrations.md|migrations.md]]

## [[examples/todo-app/src/db/migrations.md|examples/todo-app/src/db/migrations.md]]
- last_modified: `2026-08-11T05:31:04Z`
- L1 Database Migrations
  - L5 Creating a Migration
  - L9 Applying Migrations
  - L15 Rollback Policy
refs: `src/db/migrate.ts`, `src/db/migrations/`
