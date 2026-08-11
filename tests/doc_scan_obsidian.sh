#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
fixture_dir="$(mktemp -d)"
trap 'rm -rf "$fixture_dir"' EXIT

mkdir -p "$fixture_dir/docs" "$fixture_dir/notes"
printf '%s\n' '# Source' '' '[Target](../notes/target%20note.md#Target%20heading)' > "$fixture_dir/docs/from.md"
printf '%s\n' '# Target' '' '## Target heading' > "$fixture_dir/notes/target note.md"
printf '%s\n' '# Encoded hash source' '' '[Target](../notes/target%23note.md)' > "$fixture_dir/docs/encoded_hash.md"
printf '%s\n' '# Target' > "$fixture_dir/notes/target#note.md"
printf '%s\n' '# Pipe target' > "$fixture_dir/notes/a|b.md"
printf '%s\n' '# Invalid percent source' '' '[Target](../notes/a%ZZb.md)' > "$fixture_dir/docs/invalid_percent.md"
printf '%s\n' '# Target' > "$fixture_dir/notes/a%ZZb.md"

(
  cd "$fixture_dir"
  "$repo_root/scripts/doc_scan.sh" >stdout 2>stderr
)

index="$fixture_dir/DOC_INDEX.md"
rg -Fq '## [[docs/from.md|docs/from.md]]' "$index"
rg -Fq 'links: [[notes/target note.md#Target heading|../notes/target note.md#Target heading]]' "$index"
rg -Fq '## [[notes/target note.md|notes/target note.md]]' "$index"
rg -Fq '## notes/a|b.md' "$index"
if rg -Fq '[[notes/a|b.md|' "$index"; then
  echo 'ERROR: unsafe pipe path was emitted as a Wiki Link.' >&2
  exit 1
fi
if rg -Fq 'links: [[notes/target#note.md|' "$index"; then
  echo 'ERROR: encoded hash path was emitted as a Wiki Link.' >&2
  exit 1
fi
if rg -Fq 'links: [[notes/a%ZZb.md|' "$index"; then
  echo 'ERROR: malformed percent escape was emitted as a Wiki Link.' >&2
  exit 1
fi
test ! -s "$fixture_dir/stderr"

echo 'OK: Obsidian Wiki Links resolve local Markdown links from the vault root.'
