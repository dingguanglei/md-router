#!/usr/bin/env bash
set -euo pipefail

OUT="DOC_INDEX.md"

hash_cmd_file() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1"
  else
    shasum -a 256 "$1"
  fi
}

hash_cmd_stdin() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum | awk '{print $1}'
  else
    shasum -a 256 | awk '{print $1}'
  fi
}

list_markdown_files() {
  find . \
    -type d \( \
      -name .git -o \
      -name .venv -o \
      -name venv -o \
      -name node_modules -o \
      -name outputs -o \
      -name output -o \
      -name runs -o \
      -name wandb -o \
      -name checkpoints -o \
      -name ckpts -o \
      -name build -o \
      -name dist -o \
      -name __pycache__ -o \
      -name third_party \
    \) -prune -o \
    -type f -name "*.md" ! -name "DOC_INDEX.md" -print \
  | sort
}

compute_docs_hash() {
  list_markdown_files \
  | while read -r f; do
      printf '%s\n' "$f"
      hash_cmd_file "$f"
    done \
  | hash_cmd_stdin
}

SOURCE_HASH="$(compute_docs_hash)"
TMP="${OUT}.tmp"

cat > "$TMP" <<EOF2
# DOC_INDEX.md

<!-- AUTO-GENERATED. DO NOT EDIT. -->
<!-- DOC_INDEX_SOURCE_HASH: $SOURCE_HASH -->

This file is generated from Markdown headings, inline code paths, and Markdown links.

EOF2

list_markdown_files \
| while read -r file; do
    clean="${file#./}"
    dir="$(dirname "$clean")"

    {
      echo ""
      echo "## FILE $clean"
      echo ""
      echo "DIR: $dir"
      echo ""
    } >> "$TMP"

    title="$(awk '
      BEGIN { in_code=0 }
      /^```/ || /^~~~/ { in_code = !in_code; next }
      !in_code && /^# / {
        sub(/^# +/, "", $0)
        sub(/ +#* *$/, "", $0)
        print $0
        exit
      }
    ' "$file")"

    if [ -n "${title:-}" ]; then
      echo "TITLE: $title" >> "$TMP"
    else
      echo "TITLE: <missing H1>" >> "$TMP"
    fi

    echo "" >> "$TMP"
    echo "HEADINGS:" >> "$TMP"

    awk '
      BEGIN { in_code=0 }
      /^```/ || /^~~~/ { in_code = !in_code; next }

      !in_code && /^#+ / {
        line = NR
        level = 0
        while (substr($0, level + 1, 1) == "#") level++
        if (level > 3) next

        text = $0
        sub(/^#+ +/, "", text)
        sub(/ +#* *$/, "", text)

        indent = ""
        for (i = 1; i < level; i++) indent = indent "  "

        printf "%s- L%d %s\n", indent, line, text
      }
    ' "$file" >> "$TMP"

    echo "" >> "$TMP"
    echo "CODE_REFS:" >> "$TMP"

    awk '
      BEGIN { in_code=0 }
      /^```/ || /^~~~/ { in_code = !in_code; next }

      !in_code {
        line = $0
        while (match(line, /`[^`]+`/)) {
          ref = substr(line, RSTART + 1, RLENGTH - 2)
          if (ref ~ /[A-Za-z0-9_.-]+\/[A-Za-z0-9_./-]+/) {
            print "- " ref
          }
          line = substr(line, RSTART + RLENGTH)
        }
      }
    ' "$file" | sort -u >> "$TMP"

    echo "" >> "$TMP"
    echo "LINKS:" >> "$TMP"

    awk '
      BEGIN { in_code=0 }
      /^```/ || /^~~~/ { in_code = !in_code; next }

      !in_code {
        line = $0
        while (match(line, /\[[^]]+\]\([^)]+\.md(#[^)]+)?\)/)) {
          link = substr(line, RSTART, RLENGTH)
          sub(/^.*\]\(/, "", link)
          sub(/\)$/, "", link)
          print "- " link
          line = substr(line, RSTART + RLENGTH)
        }
      }
    ' "$file" | sort -u >> "$TMP"

    echo "" >> "$TMP"
    echo "---" >> "$TMP"
  done

mv "$TMP" "$OUT"
echo "Generated $OUT"
