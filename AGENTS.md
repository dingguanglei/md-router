# AGENTS.md

Documentation is distributed across the repository.

`DOC_INDEX.md` is auto-generated from Markdown headings, inline code paths, and Markdown links. Do not edit it manually.

Before editing code:

1. Search `DOC_INDEX.md` for the target file path, filename tokens, and relevant domain terms.
2. If needed, search Markdown files directly with `rg` or `grep`.
3. Read the matching Markdown documents or sections before modifying code.

Useful commands:

```bash
rg "path/to/target_file" DOC_INDEX.md
rg "keyword1|keyword2" DOC_INDEX.md
rg "path/to/target_file" --glob "*.md"
rg "^#{1,3} " --glob "*.md"
```

If `rg` is unavailable, use:

```bash
grep -nE "keyword1|keyword2" DOC_INDEX.md
grep -RIn "path/to/target_file" --include="*.md" .
```

After editing Markdown files:

```bash
./scripts/doc_scan.sh
```

Before relying on `DOC_INDEX.md`, verify it is fresh:

```bash
./scripts/doc_check.sh
```

Markdown writing rules:

- Use exactly one H1.
- Use valid ATX headings: `# Title`, `## Section`, and `### Subsection`.
- Put a space or tab after the `#` marker.
- Put code paths in backticks.
- Use Markdown links for cross-document references.
