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

join_lines() {
  awk 'BEGIN { first=1 } { if (!first) printf ", "; printf "%s", $0; first=0 }'
}

list_markdown_files() {
  find . \
    -type d \( \
      -name .git -o \
      -name ".co""dex" -o \
      -name ".cl""aude" -o \
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
    -type f -name "*.md" \
      ! -name "DOC_INDEX.md" \
      ! -iname "AGENTS.md" \
      ! -iname "CLAUDE.md" \
      -print \
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

EOF2

list_markdown_files \
| while read -r file; do
    clean="${file#./}"

    echo "## $clean" >> "$TMP"

    awk '
      function fence_run(s, ch,   n) {
        n = 0
        while (substr(s, n + 1, 1) == ch) n++
        return n
      }

      BEGIN { in_code=0; fence=""; fence_len=0 }
      {
        raw = $0
        lead = 0
        while (substr(raw, lead + 1, 1) == " ") lead++
        stripped = raw
        if (lead <= 3) stripped = substr(raw, lead + 1)

        if (!in_code && lead <= 3 && fence_run(stripped, "`") >= 3) {
          in_code=1; fence="`"; fence_len=fence_run(stripped, "`"); next
        }
        if (!in_code && lead <= 3 && fence_run(stripped, "~") >= 3) {
          in_code=1; fence="~"; fence_len=fence_run(stripped, "~"); next
        }

        if (in_code) {
          if (lead <= 3 && fence == "`" && fence_run(stripped, "`") >= fence_len) {
            in_code=0; fence=""; fence_len=0
          } else if (lead <= 3 && fence == "~" && fence_run(stripped, "~") >= fence_len) {
            in_code=0; fence=""; fence_len=0
          }
          next
        }

        if (lead >= 4 || raw ~ /^\t/) next

        if (stripped ~ /^#+[ \t]/) {
          line = NR
          level = 0
          while (substr(stripped, level + 1, 1) == "#") level++
          if (level > 3) next

          text = stripped
          sub(/^#+[ \t]+/, "", text)
          sub(/[ \t]+#*[ \t]*$/, "", text)

          indent = ""
          for (i = 1; i < level; i++) indent = indent "  "

          printf "%s- L%d %s\n", indent, line, text
        }
      }
    ' "$file" >> "$TMP"

    code_refs="$(awk '
      function fence_run(s, ch,   n) {
        n = 0
        while (substr(s, n + 1, 1) == ch) n++
        return n
      }

      BEGIN { in_code=0; fence=""; fence_len=0 }
      {
        raw = $0
        lead = 0
        while (substr(raw, lead + 1, 1) == " ") lead++
        stripped = raw
        if (lead <= 3) stripped = substr(raw, lead + 1)

        if (!in_code && lead <= 3 && fence_run(stripped, "`") >= 3) {
          in_code=1; fence="`"; fence_len=fence_run(stripped, "`"); next
        }
        if (!in_code && lead <= 3 && fence_run(stripped, "~") >= 3) {
          in_code=1; fence="~"; fence_len=fence_run(stripped, "~"); next
        }

        if (in_code) {
          if (lead <= 3 && fence == "`" && fence_run(stripped, "`") >= fence_len) {
            in_code=0; fence=""; fence_len=0
          } else if (lead <= 3 && fence == "~" && fence_run(stripped, "~") >= fence_len) {
            in_code=0; fence=""; fence_len=0
          }
          next
        }

        if (lead >= 4 || raw ~ /^\t/) next

        line = raw
        while (match(line, /`[^`]+`/)) {
          ref = substr(line, RSTART + 1, RLENGTH - 2)
          if (ref ~ /[A-Za-z0-9_.-]+\/[A-Za-z0-9_./-]+/) {
            print "`" ref "`"
          }
          line = substr(line, RSTART + RLENGTH)
        }
      }
    ' "$file" | sort -u | join_lines)"

    if [ -n "${code_refs:-}" ]; then
      echo "refs: $code_refs" >> "$TMP"
    fi

    links="$(awk '
      function fence_run(s, ch,   n) {
        n = 0
        while (substr(s, n + 1, 1) == ch) n++
        return n
      }

      BEGIN { in_code=0; fence=""; fence_len=0 }
      {
        raw = $0
        lead = 0
        while (substr(raw, lead + 1, 1) == " ") lead++
        stripped = raw
        if (lead <= 3) stripped = substr(raw, lead + 1)

        if (!in_code && lead <= 3 && fence_run(stripped, "`") >= 3) {
          in_code=1; fence="`"; fence_len=fence_run(stripped, "`"); next
        }
        if (!in_code && lead <= 3 && fence_run(stripped, "~") >= 3) {
          in_code=1; fence="~"; fence_len=fence_run(stripped, "~"); next
        }

        if (in_code) {
          if (lead <= 3 && fence == "`" && fence_run(stripped, "`") >= fence_len) {
            in_code=0; fence=""; fence_len=0
          } else if (lead <= 3 && fence == "~" && fence_run(stripped, "~") >= fence_len) {
            in_code=0; fence=""; fence_len=0
          }
          next
        }

        if (lead >= 4 || raw ~ /^\t/) next

        line = raw
        while (match(line, /\[[^]]+\]\([^)]+\.md(#[^)]+)?\)/)) {
          link = substr(line, RSTART, RLENGTH)
          sub(/^.*\]\(/, "", link)
          sub(/\)$/, "", link)
          print "`" link "`"
          line = substr(line, RSTART + RLENGTH)
        }
      }
    ' "$file" | sort -u | join_lines)"

    if [ -n "${links:-}" ]; then
      echo "links: $links" >> "$TMP"
    fi

    echo "" >> "$TMP"
  done

mv "$TMP" "$OUT"
echo "Generated $OUT"
