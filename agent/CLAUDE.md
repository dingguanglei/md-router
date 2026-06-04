# CLAUDE.md

Use this file as a Claude Code rule when installing `md-router` in another repository.

Documentation may live next to the code, config, or data it explains.

`DOC_INDEX.md` is generated from Markdown headings, inline code paths, and Markdown links. Do not edit it manually.

Before editing code:

1. Search `DOC_INDEX.md` for the target file path, filename tokens, and relevant domain terms.
2. If needed, search project Markdown files directly, excluding generated indexes and agent instruction files.
3. Read the matching Markdown documents or sections before modifying code.

Useful commands:

```bash
rg "path/to/target_file" DOC_INDEX.md
rg "keyword1|keyword2" DOC_INDEX.md

rg "path/to/target_file" --glob "*.md" --glob "!DOC_INDEX.md" --glob "!AGENTS.md" --glob "!CLAUDE.md"
rg "keyword1|keyword2" --glob "*.md" --glob "!DOC_INDEX.md" --glob "!AGENTS.md" --glob "!CLAUDE.md"
rg "^#{1,3} " --glob "*.md" --glob "!DOC_INDEX.md" --glob "!AGENTS.md" --glob "!CLAUDE.md"
```

After creating, deleting, renaming, or editing Markdown files:

```bash
./scripts/doc_scan.sh
```

Before relying on the index:

```bash
./scripts/doc_check.sh
```

Markdown writing rules:

- Use exactly one H1.
- Use valid ATX headings: `# Title`, `## Section`, and `### Subsection`.
- Put a space or tab after the `#` marker.
- Put code paths in backticks.
- Use Markdown links for cross-document references.
