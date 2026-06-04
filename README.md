# Markdown Doc Router

A tiny, dependency-free documentation indexing skill for large code repositories.

It assumes documentation can live anywhere in the repo, next to the code, config, data, or module it explains. The tool scans Markdown files and generates a grep-friendly `DOC_INDEX.md` from:

- Markdown H1/H2/H3 headings
- Inline code path references such as `src/model/action_head.py`
- Markdown links to other `.md` files

No Python. No Node. No frontmatter. No vector database. No centralized `docs/` directory required.

## Why

Large projects often contain many local README/DESIGN/USAGE markdown files. LLM coding agents may miss them because they are not always in the active context.

This repo provides a lightweight mechanism:

```text
Markdown everywhere
  -> scripts/doc_scan.sh
  -> DOC_INDEX.md
  -> rg/grep search by human or coding agent
```

## Files

```text
scripts/doc_scan.sh     Generate DOC_INDEX.md
scripts/doc_check.sh    Check whether DOC_INDEX.md is stale
scripts/install_hook.sh Install a pre-commit hook that auto-updates DOC_INDEX.md
AGENTS.md              Suggested agent rules
DOC_INDEX.md           Generated index, committed to repo
```

## Quick start

Copy the scripts into your repo:

```bash
mkdir -p scripts
cp scripts/doc_scan.sh scripts/doc_check.sh scripts/install_hook.sh /path/to/your/repo/scripts/
cp AGENTS.md /path/to/your/repo/AGENTS.md
```

Generate the index:

```bash
./scripts/doc_scan.sh
```

Search the index:

```bash
rg "src/model/action_head.py|action head|72D|joint mask" DOC_INDEX.md
```

Check freshness:

```bash
./scripts/doc_check.sh
```

Install pre-commit auto-sync:

```bash
./scripts/install_hook.sh
```

## Markdown writing contract

To make documents easy to index:

1. Use exactly one H1 per markdown file.
2. Use semantic H2/H3 headings.
3. Put concrete code paths in backticks.
4. Use Markdown links for cross-document references.
5. Do not manually edit `DOC_INDEX.md`.

Good example:

```md
# Action Head

## 72D Action Output

Implementation: `src/model/action_head.py`.

## Robot Joint Masking

See [Robot Joint Mapping](../../configs/robots/joint_mapping.md).
```

## Generated index format

```md
## FILE src/model/action_head.md

DIR: src/model
TITLE: Action Head

HEADINGS:
- H1 L1 Action Head
- H2 L3 72D Action Output
- H2 L7 Robot Joint Masking

CODE_REFS:
- src/model/action_head.py

LINKS:
- ../../configs/robots/joint_mapping.md
```

## Design principles

- Documentation location carries meaning.
- Markdown headings are the semantic skeleton.
- The index is derived from source docs, not manually maintained.
- Search is done with `rg`/`grep`, not custom RAG.
- Generated files are protected by a source hash.
