# md-router

A tiny heading-based Markdown indexer for docs-everywhere repositories.

`md-router` lets you keep documentation next to the code, config, or data it explains, while generating a grep-friendly `DOC_INDEX.md` that coding agents can search before editing.

## Why

In large repositories, documentation often lives everywhere:

- module docs next to source code
- API docs next to route handlers
- migration notes next to database code
- deployment notes next to config files

That is good for humans, but coding agents can miss those docs unless there is a searchable index.

`md-router` solves this by extracting:

- Markdown headings
- heading line numbers
- inline code path references
- Markdown document links

and writing them into a single `DOC_INDEX.md`.

## Design principles

- Keep docs close to what they explain.
- Use Markdown headings as the source of structure.
- Do not require frontmatter, YAML, JSON, embeddings, or a database.
- Do not manually maintain duplicate metadata.
- Generate an index that works with `rg`, `grep`, Codex, Claude Code, Cursor, Aider, and other repo-aware agents.

## Install

Copy the scripts into your repository:

```bash
mkdir -p scripts
cp scripts/doc_scan.sh scripts/doc_check.sh scripts/install_hook.sh /path/to/your/repo/scripts/
```

Then generate the index:

```bash
./scripts/doc_scan.sh
```

This creates or updates:

```text
DOC_INDEX.md
```

## Usage

### Generate the index

```bash
./scripts/doc_scan.sh
```

### Check whether the index is up to date

```bash
./scripts/doc_check.sh
```

### Install the pre-commit hook

```bash
./scripts/install_hook.sh
```

The hook updates `DOC_INDEX.md` automatically before commits that include Markdown changes.

## Searching the index

Search by target file path:

```bash
rg "src/auth/login.ts" DOC_INDEX.md
```

Search by domain terms:

```bash
rg "auth|login|session" DOC_INDEX.md
```

Search Markdown directly when needed:

```bash
rg "src/auth/login.ts" --glob "*.md"
rg "^#{1,3} " --glob "*.md"
```

If `rg` is unavailable, use `grep`:

```bash
grep -nE "auth|login|session" DOC_INDEX.md
grep -RIn "src/auth/login.ts" --include="*.md" .
```

## Default ignores

`md-router` indexes project documentation by default. It intentionally ignores common agent-instruction files and directories so the index does not become polluted by tool-specific instructions.

Default ignored directories:

```text
.codex/
.claude/
```

Default ignored files:

```text
AGENTS.md
CLAUDE.md
DOC_INDEX.md
```

The `agent/` directory in this repository provides templates, but files with these names are ignored when generating `DOC_INDEX.md`.

## Use as a coding-agent skill

Use the templates under `agent/` when you want to install md-router as a coding-agent skill.

- `agent/AGENTS.md` is suitable for Codex-style agents.
- `agent/CLAUDE.md` is suitable for Claude Code.

The core rules are:

- Documentation is distributed across the repository.
- `DOC_INDEX.md` is auto-generated from Markdown headings, inline code paths, and Markdown links.
- Do not edit `DOC_INDEX.md` manually.
- Before editing code, search `DOC_INDEX.md` for the target file path, filename tokens, and relevant domain terms.
- Read the matching Markdown documents or sections before modifying code.
- After editing Markdown files, run `./scripts/doc_scan.sh`.

Useful commands for agents:

```bash
rg "path/to/target_file" DOC_INDEX.md
rg "keyword1|keyword2" DOC_INDEX.md
rg "path/to/target_file" --glob "*.md"
rg "^#{1,3} " --glob "*.md"
```

## Markdown style for best results

Good Markdown structure makes the generated index more useful.

`md-router` indexes valid ATX headings only:

```md
# Title
## Section
### Subsection
```

Heading rules:

- Use a space or tab after the `#` marker.
- Use at most three leading spaces before the heading marker.
- Use H1-H3 for indexed structure.
- Use ATX headings instead of Setext headings.

Setext headings are intentionally ignored in the MVP:

```md
Title
=====

Section
-------
```

Prefer:

```md
# Auth Module

The auth module handles login, sessions, token validation, and logout behavior.

## Login Flow

The login flow validates credentials and creates a signed session token.

Implementation: `src/auth/login.ts`.

## Session Validation

Session validation checks incoming API requests and rejects expired tokens.

See [API Error Handling](../api/error_handling.md).
```

Avoid vague headings:

```md
## Overview
## Details
## Notes
## Misc
```

Prefer semantic headings:

```md
## Login Flow
## Session Validation
## Token Expiration
## API Error Handling
```

## What gets indexed

`doc_scan.sh` extracts:

```text
file path
H1-H3 heading tree
inline code path references
Markdown document links
```

Example output:

```md
## examples/todo-app/src/auth/README.md
- L1 Auth Module
  - L5 Login Flow
  - L11 Session Validation
  - L17 Logout Behavior
refs: `src/auth/login.ts`, `src/auth/session.ts`
links: `../api/error_handling.md`
```

## Files

```text
scripts/doc_scan.sh      Generate DOC_INDEX.md
scripts/doc_check.sh     Check whether DOC_INDEX.md is stale
scripts/install_hook.sh  Install a pre-commit hook that updates DOC_INDEX.md
agent/                   Agent-rule templates for Codex and Claude Code
examples/                Small Todo API example
```

## Requirements

Only standard shell tools:

- `bash`
- `awk`
- `find`
- `sort`
- `grep`
- `sha256sum` or `shasum`

No Python, Node.js, database, or vector index is required.

## License

MIT
