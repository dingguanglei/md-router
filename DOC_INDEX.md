# DOC_INDEX.md

<!-- AUTO-GENERATED. DO NOT EDIT. -->
<!-- DOC_INDEX_SOURCE_HASH: c4055b559d349bd9ef34cb0f6eb2898e71c2b6a38e6e9bcad48dcbb0cd511e32 -->

## README.md
- L1 md-router
  - L7 Why
  - L27 Design principles
  - L35 Install
  - L56 Usage
    - L58 Generate the index
    - L64 Check whether the index is up to date
    - L70 Install the pre-commit hook
  - L78 Searching the index
  - L106 Default ignores
  - L127 Use as a coding-agent skill
  - L152 Markdown style for best results
  - L219 What gets indexed
  - L242 Files
  - L252 Requirements
  - L265 License
refs: `./scripts/doc_scan.sh`

## examples/todo-app/config/README.md
- L1 Config Module
  - L5 Environment Variables
  - L11 Secret Handling
refs: `config/load_env.ts`
links: `environments.md`

## examples/todo-app/config/environments.md
- L1 Environment Configuration
  - L5 Local Development
  - L9 Staging
  - L13 Production
refs: `config/production.ts`

## examples/todo-app/src/api/README.md
- L1 API Module
  - L5 Route Handlers
  - L11 Request Validation
  - L17 Error Handling
refs: `src/api/routes.ts`, `src/api/validation.ts`
links: `error_handling.md`

## examples/todo-app/src/api/error_handling.md
- L1 API Error Handling
  - L5 Validation Errors
  - L11 Authentication Errors
  - L17 Server Errors
refs: `src/api/error_handler.ts`, `src/api/validation.ts`
links: `../auth/README.md`

## examples/todo-app/src/auth/README.md
- L1 Auth Module
  - L5 Login Flow
  - L11 Session Validation
  - L17 Logout Behavior
refs: `src/auth/login.ts`, `src/auth/session.ts`
links: `../api/error_handling.md`

## examples/todo-app/src/auth/login_flow.md
- L1 Login Flow
  - L5 Credential Validation
  - L11 Session Token Creation
  - L17 Login Failure Cases
refs: `src/auth/login.ts`, `src/auth/session.ts`
links: `../api/error_handling.md`

## examples/todo-app/src/db/README.md
- L1 Database Module
  - L5 Schema Ownership
  - L11 Migration Workflow
refs: `src/db/schema.sql`
links: `migrations.md`

## examples/todo-app/src/db/migrations.md
- L1 Database Migrations
  - L5 Creating a Migration
  - L9 Applying Migrations
  - L15 Rollback Policy
refs: `src/db/migrate.ts`, `src/db/migrations/`
