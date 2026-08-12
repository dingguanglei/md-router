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

compute_docs_hash() {
  list_markdown_files \
  | while read -r f; do
      printf '%s\n' "$f"
      hash_cmd_file "$f"
    done \
  | hash_cmd_stdin
}

if [ ! -f "$OUT" ]; then
  echo "ERROR: $OUT does not exist."
  echo "Run: ./scripts/doc_scan.sh"
  exit 1
fi

current_hash="$(compute_docs_hash)"
index_hash="$(grep -Eo 'DOC_INDEX_SOURCE_HASH: [a-fA-F0-9]+' "$OUT" | awk '{print $2}' || true)"

if [ -z "$index_hash" ]; then
  echo "ERROR: $OUT has no DOC_INDEX_SOURCE_HASH."
  echo "Run: ./scripts/doc_scan.sh"
  exit 1
fi

if [ "$current_hash" != "$index_hash" ]; then
  echo "ERROR: $OUT is stale."
  echo ""
  echo "Current docs hash: $current_hash"
  echo "Index docs hash:   $index_hash"
  echo ""
  echo "Run:"
  echo "  ./scripts/doc_scan.sh"
  exit 1
fi

current_session_hash="$(python3 "$SESSION_INDEX_SCRIPT" "$SESSION_DIR" "$ROOT_DIR" --hash 2>/dev/null || printf '%s' unknown)"
index_session_hash="$(grep -Eo 'DOC_INDEX_SESSION_HASH: [a-fA-F0-9]+' "$OUT" | awk '{print $2}' || true)"
if [ -z "$index_session_hash" ]; then
  echo "ERROR: $OUT has no DOC_INDEX_SESSION_HASH."
  echo "Run: ./scripts/doc_scan.sh"
  exit 1
fi
if [ "$current_session_hash" != "$index_session_hash" ]; then
  echo "ERROR: $OUT session associations are stale."
  echo "Run: ./scripts/doc_scan.sh"
  exit 1
fi

echo "OK: $OUT is up to date."
