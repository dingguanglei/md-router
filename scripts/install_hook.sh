#!/usr/bin/env bash
set -euo pipefail

mkdir -p .git/hooks

cat > .git/hooks/pre-commit <<'HOOK'
#!/usr/bin/env bash
set -euo pipefail

changed_md="$(git diff --cached --name-only -- '*.md' || true)"

if [ -n "$changed_md" ]; then
  ./scripts/doc_scan.sh
  git add DOC_INDEX.md
fi
HOOK

chmod +x .git/hooks/pre-commit

echo "Installed .git/hooks/pre-commit"
