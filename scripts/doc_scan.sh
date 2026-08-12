#!/usr/bin/env bash
set -euo pipefail

OUT="DOC_INDEX.md"
ROOT_DIR="$(pwd -P)"
SESSION_INDEX_SCRIPT="${DOC_SESSION_INDEX_SCRIPT:-$ROOT_DIR/scripts/doc_session_index.py}"
SESSION_DIR="${CODEX_SESSION_DIR:-$HOME/.codex/sessions}"

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

uri_decode() {
  local value="$1"
  local prefix
  local remainder
  local hex
  local decoded=""
  local decoded_char

  while [[ "$value" == *'%'* ]]; do
    prefix="${value%%\%*}"
    remainder="${value#*%}"
    decoded+="$prefix"
    hex="${remainder:0:2}"
    if [[ "$hex" =~ ^[[:xdigit:]]{2}$ ]]; then
      printf -v decoded_char '%b' "\\x$hex"
      decoded+="$decoded_char"
      value="${remainder:2}"
    else
      decoded+="%"
      value="$remainder"
    fi
  done

  printf '%s' "$decoded$value"
}

is_obsidian_safe_path() {
  case "$1" in
    *'%'*|*'#'*|*'|'*|*'['*|*']'*|*'^'*|*':'*) return 1 ;;
  esac
}

is_obsidian_safe_alias() {
  case "$1" in
    *'|'*|*'[['*|*']]'*) return 1 ;;
  esac
}

obsidian_document_entry() {
  local path="$1"

  if is_obsidian_safe_path "$path" && is_obsidian_safe_alias "$path"; then
    printf '[[%s|%s]]' "$path" "$path"
  else
    printf '%s' "$path"
  fi
}

normalize_markdown_path() {
  local source_file="$1"
  local target_path="$2"
  local joined
  local part
  local -a raw_parts=()
  local -a normalized=()

  joined="$(dirname "$source_file")/$target_path"
  IFS=/ read -r -a raw_parts <<< "$joined"
  for part in "${raw_parts[@]}"; do
    case "$part" in
      ''|.) ;;
      ..)
        if [ "${#normalized[@]}" -eq 0 ]; then
          return 1
        fi
        normalized=("${normalized[@]:0:${#normalized[@]} - 1}")
        ;;
      *) normalized+=("$part") ;;
    esac
  done

  (IFS=/; printf '%s' "${normalized[*]}")
}

obsidian_link() {
  local source_file="$1"
  local raw_target="$2"
  local raw_target_path
  local raw_fragment=""
  local target
  local target_path
  local fragment=""
  local resolved

  raw_target_path="${raw_target%%#*}"
  if [[ "$raw_target" == *'#'* ]]; then
    raw_fragment="${raw_target#*#}"
  fi
  target_path="$(uri_decode "$raw_target_path")"
  if [ -n "$raw_fragment" ]; then
    fragment="#$(uri_decode "$raw_fragment")"
  fi
  target="${target_path}${fragment}"
  case "$target_path" in
    ''|/*|http://*|https://*|mailto:*|obsidian:*) return 1 ;;
  esac

  resolved="$(normalize_markdown_path "$source_file" "$target_path")" || return 1
  if [[ "$resolved" != *.md || ! -f "$resolved" ]] \
    || ! is_obsidian_safe_path "$resolved" \
    || ! is_obsidian_safe_alias "$target"; then
    return 1
  fi

  printf '[[%s%s|%s]]' "$resolved" "$fragment" "$target"
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
  | sort \
  | while read -r file; do
      if grep -q '[^[:space:]]' "$file"; then
        printf '%s\n' "$file"
      fi
    done
}

file_mtime() {
  local epoch
  if epoch="$(stat -c %Y -- "$1" 2>/dev/null)"; then
    date -u -d "@${epoch}" '+%Y-%m-%dT%H:%M:%SZ'
  else
    epoch="$(stat -f %m -- "$1")"
    date -u -r "${epoch}" '+%Y-%m-%dT%H:%M:%SZ'
  fi
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
SESSION_HASH="$(python3 "$SESSION_INDEX_SCRIPT" "$SESSION_DIR" "$ROOT_DIR" --hash 2>/dev/null || printf '%s' unknown)"
TMP="${OUT}.tmp"
SESSION_MAP="${TMP}.sessions"
trap 'rm -f "$TMP" "$SESSION_MAP"' EXIT

cat > "$TMP" <<EOF2
# DOC_INDEX.md

<!-- AUTO-GENERATED. DO NOT EDIT. -->
<!-- DOC_INDEX_SOURCE_HASH: $SOURCE_HASH -->
<!-- DOC_INDEX_SESSION_HASH: $SESSION_HASH -->

EOF2

if [ -f "$SESSION_INDEX_SCRIPT" ] && [ -d "$SESSION_DIR" ]; then
  python3 "$SESSION_INDEX_SCRIPT" "$SESSION_DIR" "$ROOT_DIR" --map > "$SESSION_MAP"
fi

first_file=1
list_markdown_files \
| while read -r file; do
    clean="${file#./}"

    if [ "$first_file" -eq 0 ]; then
      echo "" >> "$TMP"
    fi
    first_file=0

    echo "## $(obsidian_document_entry "$clean")" >> "$TMP"
    echo "- last_modified: \`$(file_mtime "$file")\`" >> "$TMP"

    if [ -s "$SESSION_MAP" ]; then
      awk -v target="$clean" '
        $0 == "SESSION_MAP_BEGIN\t" target { in_block=1; next }
        $0 == "SESSION_MAP_END" { in_block=0; next }
        in_block { print }
      ' "$SESSION_MAP" >> "$TMP"
    fi

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

    mapfile -t raw_links < <(awk '
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
          print link
          line = substr(line, RSTART + RLENGTH)
        }
      }
    ' "$file" | sort -u)

    obsidian_links=()
    for raw_link in "${raw_links[@]}"; do
      if link="$(obsidian_link "$file" "$raw_link")"; then
        obsidian_links+=("$link")
      fi
    done
    links="$(printf '%s\n' "${obsidian_links[@]:-}" | sort -u | join_lines)"

    if [ -n "${links:-}" ]; then
      echo "links: $links" >> "$TMP"
    fi

  done

mv "$TMP" "$OUT"
echo "Generated $OUT"
