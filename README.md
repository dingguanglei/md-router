# md-router

A tiny heading-based Markdown indexer for docs-everywhere repositories.

`md-router` lets you keep documentation next to the code, config, or data it explains, while generating a grep-friendly, Obsidian-compatible `DOC_INDEX.md` that coding agents can search before editing.

## Why

Large repositories often keep documentation next to the modules, APIs, database code, config, or data it explains. That layout is good for humans, but coding agents can miss those docs unless there is a searchable index.

`md-router` extracts Markdown headings, heading line numbers, inline code path references, and Markdown document links into a single compact `DOC_INDEX.md`. Local Markdown links are resolved from the source document and emitted as Obsidian Wiki Links.

## Install

Copy the scripts into your repository:

```bash
mkdir -p scripts
cp scripts/doc_scan.sh scripts/doc_check.sh scripts/install_hook.sh /path/to/your/repo/scripts/
```

Generate the index:

```bash
./scripts/doc_scan.sh
```

Check freshness:

```bash
./scripts/doc_check.sh
```

Install the pre-commit hook:

```bash
./scripts/install_hook.sh
```

## Search workflow

Search the generated index first:

```bash
rg "src/auth/login.ts" DOC_INDEX.md
rg "auth|login|session" DOC_INDEX.md
```

Search project Markdown directly only when needed. Exclude generated indexes and agent instruction files to avoid recursive index hits:

```bash
rg "src/auth/login.ts" --glob "*.md" --glob "!DOC_INDEX.md" --glob "!AGENTS.md" --glob "!CLAUDE.md"
rg "^#{1,3} " --glob "*.md" --glob "!DOC_INDEX.md" --glob "!AGENTS.md" --glob "!CLAUDE.md"
```

If `rg` is unavailable:

```bash
grep -nE "auth|login|session" DOC_INDEX.md
find . -type f -name "*.md" ! -name "DOC_INDEX.md" ! -iname "AGENTS.md" ! -iname "CLAUDE.md" -print0 | xargs -0 grep -nE "src/auth/login.ts"
```

## Default ignores

`md-router` indexes project documentation by default. It intentionally ignores common agent-instruction files and generated index files.

Ignored directories include common Codex and Claude instruction directories. Ignored files include:

```text
AGENTS.md
CLAUDE.md
DOC_INDEX.md
```

## Use as a coding-agent skill

Use the templates under the agent directory when installing `md-router` as a coding-agent skill.

Core rules:

- Search `DOC_INDEX.md` before editing code.
- If direct Markdown search is needed, exclude generated indexes and agent instruction files.
- Read matching project docs before modifying code.
- After editing Markdown files, run `./scripts/doc_scan.sh`.

## Markdown style

`md-router` indexes valid ATX headings only:

```md
# Title
## Section
### Subsection
```

Rules:

- Use exactly one H1 per document.
- Put a space or tab after the `#` marker.
- Use H1-H3 for indexed structure.
- Put code paths in backticks.
- Use Markdown links for cross-document references.
- Use ATX headings instead of Setext headings.

Setext headings are intentionally ignored in the MVP.

## Obsidian links

Open the repository root as an Obsidian vault. Generated document entries and
resolved local Markdown links use Obsidian Wiki Link syntax, so they are
clickable and appear in Backlinks:

```md
## [[docs/auth/README.md|docs/auth/README.md]]
links: [[docs/api/error_handling.md|../api/error_handling.md]]
```

For a source link such as `[Error handling](../api/error_handling.md)`, the
index resolves the target relative to the source file and writes the canonical
path from the vault root. URL-encoded paths and heading fragments are decoded:

```md
[Target](../notes/target%20note.md#Target%20heading)
```

becomes:

```md
[[notes/target note.md#Target heading|../notes/target note.md#Target heading]]
```

Only existing local `.md` targets inside the vault are emitted as Wiki Links.
External or unresolved targets are omitted from the generated `links:` line.
The original Markdown links remain unchanged, so Obsidian records both the
source-document relationship and the navigable index entry.

Paths containing Obsidian-reserved link characters (such as `#`, `|`, `^`,
`:`, `%`, `[` or `]`) are not emitted as Wiki Links. Such document entries
remain readable as plain text, and their local references are omitted rather
than generating a malformed link.

## Compact index format

Example output:

```md
## [[examples/todo-app/src/auth/README.md|examples/todo-app/src/auth/README.md]]
- L1 Auth Module
  - L5 Login Flow
  - L11 Session Validation
refs: `src/auth/login.ts`, `src/auth/session.ts`
links: [[examples/todo-app/src/api/error_handling.md|../api/error_handling.md]]
```

## Requirements

Only standard shell tools are required: `bash`, `awk`, `find`, `sort`, `grep`, and `sha256sum` or `shasum`.

No Python, Node.js, database, or vector index is required.

## License

MIT
