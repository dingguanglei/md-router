# AGENTS.md

Documentation is distributed across the repository.

`DOC_INDEX.md` is auto-generated from Markdown headings, inline code paths, and Markdown links. Do not edit it manually.

## Before editing code

1. Search `DOC_INDEX.md` for the target file path, filename tokens, and relevant domain terms.
2. If needed, search Markdown files directly with `rg` or `grep`.
3. Read the matching Markdown documents or sections before modifying code.

Useful commands:

```bash
rg "<target/file.py>" DOC_INDEX.md
rg "<keyword1>|<keyword2>" DOC_INDEX.md
rg "<target/file.py>" --glob "*.md"
rg "^#{1,3} " --glob "*.md"
```

If `rg` is unavailable:

```bash
grep -RIn "<target/file.py>" --include="*.md" .
grep -nE "<keyword1>|<keyword2>" DOC_INDEX.md
```

## After editing Markdown files

After creating, deleting, renaming, or editing any Markdown file, run:

```bash
./scripts/doc_scan.sh
```

Before relying on the index, check freshness:

```bash
./scripts/doc_check.sh
```

## Markdown writing rules

- Use exactly one H1 per Markdown file.
- Use semantic H2/H3 headings.
- Put concrete code paths in backticks, for example `src/model/action_head.py`.
- Use Markdown links for cross-document references.
- Do not manually edit `DOC_INDEX.md`.
