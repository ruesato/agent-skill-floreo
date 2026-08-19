#!/usr/bin/env bash
# migrate-floreo.sh — bulk migration tooling for a docs/ directory of floreo documents.
#
# When the base CSS or component patterns change, existing floreo docs do not update.
# The "Updating an Existing Floreo Document" section covers one doc at a time via
# Content Plan recovery. This tool scales that to a whole directory.
#
# Subcommands:
#   report [dir]        — inventory every floreo .html: type, version, content-plan
#                         presence, size, and whether the base CSS block is current.
#   extract [dir]       — pull each doc's embedded Content Plan to a .md file (same
#                         basename) so the floreo skill can re-render it via Phase 2.
#   refresh-css [dir]   — mechanically replace each doc's base CSS block with the
#                         current version extracted from SKILL.md. Safe, deterministic
#                         patch — no re-render needed. Reports docs that need manual
#                         review when the block boundaries can't be located.
#
# Usage:
#   scripts/migrate-floreo.sh report docs/
#   scripts/migrate-floreo.sh extract docs/
#   scripts/migrate-floreo.sh refresh-css docs/ [--dry-run]
#
# Defaults to docs/ when no dir is given. --dry-run shows what would change without
# writing. Exit 0 on success, 1 if any file needs manual review, 2 on usage error.
set -euo pipefail

# Resolve the skill root (parent of scripts/) to locate SKILL.md.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILL_MD="$SKILL_ROOT/skills/floreo/SKILL.md"

DRY_RUN=0
SUBCOMMAND=""
DIR=""

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    -h|--help)
      sed -n '2,22p' "$0"
      exit 0
      ;;
    report|extract|refresh-css)
      [ -z "$SUBCOMMAND" ] && SUBCOMMAND="$arg" || { echo "multiple subcommands" >&2; exit 2; }
      ;;
    -*) echo "unknown flag: $arg" >&2; exit 2 ;;
    *) [ -z "$DIR" ] && DIR="$arg" || { echo "unexpected argument: $arg" >&2; exit 2; }
      ;;
  esac
done

if [ -z "$SUBCOMMAND" ]; then
  echo "usage: $0 <report|extract|refresh-css> [dir] [--dry-run]" >&2
  exit 2
fi

[ -z "$DIR" ] && DIR="docs"

if [ ! -e "$DIR" ]; then
  echo "path not found: $DIR" >&2
  exit 2
fi

if [ ! -f "$SKILL_MD" ]; then
  echo "SKILL.md not found at $SKILL_MD (needed for refresh-css)" >&2
  exit 2
fi

# Collect floreo .html files (those carrying a floreo meta tag).
FILES=()
while IFS= read -r line; do FILES+=("$line"); done < <(grep -rlE 'name="floreo:type"' "$DIR" --include='*.html' 2>/dev/null || true)

if [ ${#FILES[@]} -eq 0 ]; then
  echo "no floreo .html files found in $DIR"
  exit 0
fi

# Extract the current base CSS block from SKILL.md (the ```css block under
# "## Base CSS Block"). Boundaries: the first ```css after the header, up to ```.
current_base_css() {
  awk '
    /^## Base CSS Block/ { in_section=1; next }
    in_section && /^```css$/ { in_block=1; next }
    in_block && /^```$/ { in_block=0; in_section=0; next }
    in_block { print }
  ' "$SKILL_MD"
}

# Compress CSS to a single line for byte comparison: join lines by removing
# newlines and surrounding indentation only. Intra-line whitespace is preserved
# so at-rules that require internal spaces (e.g. `@media print`) stay valid and
# comparable. (SKILL.md holds the block multi-line; generated docs hold it
# compressed on one line. Compressing both makes them hash-comparable.)
normalize_css() { perl -0777 -pe 's/[ \t]*\n[ \t]*//g'; }

# Extract the base CSS block from a generated (possibly single-line) doc using
# perl regex with greedy matching across the whole file. The block runs from the
# universal reset selector to the end of the last base-CSS media query. The end
# marker is version-dependent: current blocks end with the print media query
# (a[href]{...}}); older v1.0 blocks end with the reduced-motion query
# (transition:none!important}}). Greedy .* captures the full current block when
# both media queries are present; falls back to the reduced-motion end otherwise.
# Prints the block to stdout; empty if boundaries can't be located.
extract_doc_base_css() {
  local file="$1"
  perl -0777 -ne 'print $1 if /(\*,\*::before,\*::after\{box-sizing:border-box.*(?:a\[href\]\{color:inherit;text-decoration:none\}\}|transition:none!important\}\}))/s' "$file" 2>/dev/null
}

# --- report ---
cmd_report() {
  printf '%-60s %-16s %-10s %-12s %s\n' "FILE" "TYPE" "VERSION" "CONTENTPLAN" "SIZE"
  printf '%s\n' "----------------------------------------------------------------------------------------------------"
  local needs_review=0
  for f in "${FILES[@]}"; do
    local content t v cp size has_cp
    content=$(cat "$f")
    t=$(grep -oE 'name="floreo:type"[^>]*content="[^"]*"' <<<"$content" | sed -E 's/.*content="([^"]*)".*/\1/' || true)
    v=$(grep -oE 'name="floreo:version"[^>]*content="[^"]*"' <<<"$content" | sed -E 's/.*content="([^"]*)".*/\1/' || true)
    [ -z "$t" ] && t="(none)"
    [ -z "$v" ] && v="(none)"
    if grep -qE 'id="content-plan"' <<<"$content"; then has_cp="yes"; else has_cp="no"; needs_review=1; fi
    size=$(wc -c <"$f" | tr -d ' ')
    printf '%-60s %-16s %-10s %-12s %sB\n' "$f" "$t" "$v" "$has_cp" "$size"
  done
  echo ""
  echo "${#FILES[@]} floreo document(s) in $DIR"
  if [ "$needs_review" -gt 0 ]; then
    echo "note: some docs lack an embedded Content Plan — re-render is not available for those (manual update only)"
  fi
  echo ""
  echo "next steps:"
  echo "  extract      → scripts/migrate-floreo.sh extract $DIR"
  echo "  refresh-css  → scripts/migrate-floreo.sh refresh-css $DIR"
}

# --- extract ---
cmd_extract() {
  local out=0
  for f in "${FILES[@]}"; do
    local base cp
    base="${f%.html}"
    # Pull the content plan out of <script type="application/floreo" id="content-plan"> ... </script>
    cp=$(awk '
      /<script type="application\/floreo"[^>]*id="content-plan"/ { in_cp=1; next }
      /id="content-plan"[^>]*type="application\/floreo"/ { in_cp=1; next }
      in_cp && /<\/script>/ { in_cp=0; next }
      in_cp { print }
    ' "$f")
    if [ -z "$cp" ]; then
      echo "skip: $f (no embedded Content Plan)"
      out=1
      continue
    fi
    local md="${base}.md"
    if [ "$DRY_RUN" -eq 1 ]; then
      echo "would write: $md ($(echo -n "$cp" | wc -c | tr -d ' ')B)"
    else
      printf '%s\n' "$cp" >"$md"
      echo "wrote: $md"
    fi
  done
  if [ "$DRY_RUN" -eq 0 ]; then
    echo ""
    echo "Content Plans extracted. Re-render each with the floreo skill:"
    echo "  /floreo render docs/<slug>.md   (or say \"render docs/<slug>.md\" to the skill)"
    echo "Re-rendering regenerates each doc against the current skill version."
  fi
  return "$out"
}

# --- refresh-css ---
cmd_refresh_css() {
  local current current_norm current_hash
  current=$(current_base_css)
  if [ -z "$current" ]; then
    echo "ERROR: could not extract base CSS block from $SKILL_MD" >&2
    exit 2
  fi
  # Normalize (strip whitespace) so the multi-line SKILL.md block compares equal to
  # the compressed single-line block in generated docs. Hash the normalized form.
  current_norm=$(printf '%s' "$current" | normalize_css)
  current_hash=$(printf '%s' "$current_norm" | shasum -a 256 | cut -d' ' -f1)
  # The replacement string inserted into docs is the compressed (whitespace-stripped)
  # form, matching floreo's markup-compression convention.
  local patched=0 needs_review=0
  for f in "${FILES[@]}"; do
    local doc_block doc_norm doc_hash
    doc_block=$(extract_doc_base_css "$f")
    if [ -z "$doc_block" ]; then
      echo "manual review: $f (base CSS block boundaries not found)"
      needs_review=1
      continue
    fi
    doc_norm=$(printf '%s' "$doc_block" | normalize_css)
    doc_hash=$(printf '%s' "$doc_norm" | shasum -a 256 | cut -d' ' -f1)
    if [ "$doc_hash" = "$current_hash" ]; then
      echo "current:       $f"
      continue
    fi
    if [ "$DRY_RUN" -eq 1 ]; then
      echo "would patch:   $f ($(printf '%s' "$doc_norm" | wc -c | tr -d ' ')B → $(printf '%s' "$current_norm" | wc -c | tr -d ' ')B base CSS)"
      patched=1
      continue
    fi
    # Replace the doc's base CSS block (old or current end marker) with the
    # compressed current block via perl. Greedy .* matches through to the last
    # base-CSS media query present. The replacement passes through an env var to
    # avoid shell-quoting issues with CSS braces/semicolons. A .bak backup is kept.
    local tmp
    tmp=$(mktemp)
    REPLACEMENT="$current_norm" perl -0777 -pe \
      's/\*,\*::before,\*::after\{box-sizing:border-box.*(?:a\[href\]\{color:inherit;text-decoration:none\}\}|transition:none!important\}\})/$ENV{REPLACEMENT}/s' \
      "$f" >"$tmp"
    if [ ! -s "$tmp" ]; then
      echo "manual review: $f (replacement produced empty output — not written)"
      needs_review=1
      rm -f "$tmp"
      continue
    fi
    cp -f "$f" "$f.bak"
    mv -f "$tmp" "$f"
    echo "patched:       $f (backup: $f.bak)"
    patched=1
  done
  echo ""
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "dry run — no files written"
  elif [ "$patched" -eq 1 ]; then
    echo "patched docs back up to *.bak. Run scripts/check-floreo.sh $DIR to verify."
  else
    echo "all docs already on the current base CSS."
  fi
  if [ "$needs_review" -gt 0 ]; then
    echo "note: docs flagged for manual review were not patched — re-render via extract instead."
    return 1
  fi
  return 0
}

case "$SUBCOMMAND" in
  report) cmd_report ;;
  extract) cmd_extract; ec=$?; [ "$ec" -ne 0 ] && exit 1; exit 0 ;;
  refresh-css) cmd_refresh_css; ec=$?; [ "$ec" -ne 0 ] && exit 1; exit 0 ;;
esac
