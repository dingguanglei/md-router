# DOC_INDEX.md

<!-- AUTO-GENERATED. DO NOT EDIT. -->
<!-- DOC_INDEX_SOURCE_HASH: 5786b2003d65a86dcb4ab4f56e3dd404aa67c3625df6dc075cec9255cb9da679 -->

This file is generated from Markdown headings, inline code paths, and Markdown links.


## FILE AGENTS.md

DIR: .

TITLE: AGENTS.md

HEADINGS:
- H1 L1 AGENTS.md

CODE_REFS:

LINKS:

---

## FILE README.md

DIR: .

TITLE: md-router

HEADINGS:
- H1 L1 md-router
- H2 L7 Why
- H2 L27 Design principles
- H2 L35 Install
- H2 L56 Usage
- H3 L58 Generate the index
- H3 L64 Check whether the index is up to date
- H3 L70 Install the pre-commit hook
- H2 L78 Searching the index
- H2 L106 Use as a coding-agent skill
- H2 L146 Markdown style for best results
- H2 L188 What gets indexed
- H2 L226 Files
- H2 L236 Requirements
- H2 L249 License

CODE_REFS:

LINKS:

---

## FILE examples/todo-app/config/README.md

DIR: examples/todo-app/config

TITLE: Config Module

HEADINGS:
- H1 L1 Config Module
- H2 L5 Environment Variables
- H2 L11 Secret Handling

CODE_REFS:
- config/load_env.ts

LINKS:
- environments.md

---

## FILE examples/todo-app/config/environments.md

DIR: examples/todo-app/config

TITLE: Environment Configuration

HEADINGS:
- H1 L1 Environment Configuration
- H2 L5 Local Development
- H2 L9 Staging
- H2 L13 Production

CODE_REFS:
- config/production.ts

LINKS:

---

## FILE examples/todo-app/src/api/README.md

DIR: examples/todo-app/src/api

TITLE: API Module

HEADINGS:
- H1 L1 API Module
- H2 L5 Route Handlers
- H2 L11 Request Validation
- H2 L17 Error Handling

CODE_REFS:
- src/api/routes.ts
- src/api/validation.ts

LINKS:
- error_handling.md

---

## FILE examples/todo-app/src/api/error_handling.md

DIR: examples/todo-app/src/api

TITLE: API Error Handling

HEADINGS:
- H1 L1 API Error Handling
- H2 L5 Validation Errors
- H2 L11 Authentication Errors
- H2 L17 Server Errors

CODE_REFS:
- src/api/error_handler.ts
- src/api/validation.ts

LINKS:
- ../auth/README.md

---

## FILE examples/todo-app/src/auth/README.md

DIR: examples/todo-app/src/auth

TITLE: Auth Module

HEADINGS:
- H1 L1 Auth Module
- H2 L5 Login Flow
- H2 L11 Session Validation
- H2 L17 Logout Behavior

CODE_REFS:
- src/auth/login.ts
- src/auth/session.ts

LINKS:
- ../api/error_handling.md

---

## FILE examples/todo-app/src/auth/login_flow.md

DIR: examples/todo-app/src/auth

TITLE: Login Flow

HEADINGS:
- H1 L1 Login Flow
- H2 L5 Credential Validation
- H2 L11 Session Token Creation
- H2 L17 Login Failure Cases

CODE_REFS:
- src/auth/login.ts
- src/auth/session.ts

LINKS:
- ../api/error_handling.md

---

## FILE examples/todo-app/src/db/README.md

DIR: examples/todo-app/src/db

TITLE: Database Module

HEADINGS:
- H1 L1 Database Module
- H2 L5 Schema Ownership
- H2 L11 Migration Workflow

CODE_REFS:
- src/db/schema.sql

LINKS:
- migrations.md

---

## FILE examples/todo-app/src/db/migrations.md

DIR: examples/todo-app/src/db

TITLE: Database Migrations

HEADINGS:
- H1 L1 Database Migrations
- H2 L5 Creating a Migration
- H2 L9 Applying Migrations
- H2 L15 Rollback Policy

CODE_REFS:
- src/db/migrate.ts
- src/db/migrations/

LINKS:

---
