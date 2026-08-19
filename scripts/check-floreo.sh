#!/usr/bin/env bash
# check-floreo.sh — validate a generated floreo .html against the Quality Checklist.
#
# Usage:
#   scripts/check-floreo.sh <file.html>            # check one file
#   scripts/check-floreo.sh docs/                  # check every .html in a dir (recursive)
#   scripts/check-floreo.sh --strict docs/         # treat warnings as failures too
#
# Exit codes:
#   0 — all checks passed (warnings allowed unless --strict)
#   1 — one or more ERROR-level checks failed
#   2 — usage error / no floreo files found
#
# CI integration: gate on exit 0.
#   run: scripts/check-floreo.sh docs/ && echo "floreo docs OK"
set -u

STRICT=0
TARGETS=()

for arg in "$@"; do
  case "$arg" in
    --strict) STRICT=1 ;;
    -h|--help)
      sed -n '2,14p' "$0"
      exit 0
      ;;
    *) TARGETS+=("$arg") ;;
  esac
done

if [ ${#TARGETS[@]} -eq 0 ]; then
  echo "usage: $0 [--strict] <file.html|dir>" >&2
  exit 2
fi

# Collect .html files (recursive for dirs, single for files).
FILES=()
for t in "${TARGETS[@]}"; do
  if [ -d "$t" ]; then
    while IFS= read -r -d '' f; do FILES+=("$f"); done < <(find "$t" -type f -name '*.html' -print0)
  elif [ -f "$t" ]; then
    FILES+=("$t")
  else
    echo "skip: $t (not found)" >&2
  fi
done

if [ ${#FILES[@]} -eq 0 ]; then
  echo "no .html files found" >&2
  exit 2
fi

# count_matches PATTERN STRING — number of regex matches, 0 if none.
# No pipefail so `grep | wc` returns wc's status (0) even when grep finds nothing.
count_matches() { grep -oE "$1" <<<"$2" 2>/dev/null | wc -l | tr -d ' '; }

# first_match PATTERN STRING — first capture of content="...", or empty.
first_match() { grep -oE "$1" <<<"$2" 2>/dev/null | sed -E 's/.*content="([^"]*)".*/\1/' | head -n1; }

# Per-template hard size limits (bytes). Sourced from the Self-containment table.
budget_for_type() {
  local t="$1"
  case "$t" in
    session-close|retro|brief) echo 30720 ;;
    incident|adr|onboarding|api-reference|api) echo 51200 ;;
    research-brief|research) echo 76800 ;;
    project-proposal|proposal|plan) echo 76800 ;;
    *) echo 102400 ;;
  esac
}

ABSOLUTE_MAX=102400
ERRORS=0
WARNINGS=0

check_file() {
  local file="$1"
  local ferr=0
  local fwarn=0
  local content
  content=$(cat "$file")

  echo "── $file"

  # --- Meta tags (ERROR if missing) ---
  local mtype mcreated mmodel mversion
  mtype=$(first_match 'name="floreo:type"[^>]*content="[^"]*"' "$content")
  mcreated=$(first_match 'name="floreo:created"[^>]*content="[^"]*"' "$content")
  mmodel=$(first_match 'name="floreo:model"[^>]*content="[^"]*"' "$content")
  mversion=$(first_match 'name="floreo:version"[^>]*content="[^"]*"' "$content")

  [ -z "$mtype" ]    && { echo "  ERROR  missing meta floreo:type";    ferr=1; }
  [ -z "$mcreated" ] && { echo "  ERROR  missing meta floreo:created"; ferr=1; }
  [ -z "$mmodel" ]   && { echo "  ERROR  missing meta floreo:model";   ferr=1; }
  [ -z "$mversion" ] && { echo "  ERROR  missing meta floreo:version"; ferr=1; }

  # --- <title> (ERROR if missing/empty) ---
  local title
  title=$(grep -oE '<title>[^<]+</title>' <<<"$content" 2>/dev/null | sed -E 's/<\/?title>//g' | head -n1)
  if [ -z "$title" ]; then
    echo "  ERROR  missing or empty <title>"; ferr=1
  elif echo "$title" | grep -qiE '^(document title|untitled|title)$'; then
    echo "  WARN   generic <title>: \"$title\""; fwarn=1
  fi

  # --- Viewport (ERROR if missing) ---
  if ! grep -qE 'name="viewport"' <<<"$content" 2>/dev/null; then
    echo "  ERROR  missing <meta name=\"viewport\">"; ferr=1
  fi

  # --- Self-containment (ERROR on any external dependency) ---
  if grep -qE '<link[^>]*rel=["'\'']stylesheet["'\'']' <<<"$content" 2>/dev/null; then
    echo "  ERROR  external stylesheet link (breaks self-containment)"; ferr=1
  fi
  if grep -qE '<script[^>]*src=["'\'']https?://' <<<"$content" 2>/dev/null; then
    echo "  ERROR  external <script src> (breaks self-containment)"; ferr=1
  fi
  if grep -qE '@import[[:space:]]+(url\()?["'\'']?https?://' <<<"$content" 2>/dev/null; then
    echo "  ERROR  remote @import (breaks self-containment)"; ferr=1
  fi
  if grep -qE '<img[^>]*src=["'\'']https?://' <<<"$content" 2>/dev/null; then
    echo "  ERROR  remote <img src> (breaks self-containment)"; ferr=1
  fi

  # --- Content Plan embedded (ERROR if missing) ---
  if ! grep -qE 'id="content-plan"[^>]*type="application/floreo"|type="application/floreo"[^>]*id="content-plan"' <<<"$content" 2>/dev/null; then
    echo "  ERROR  missing embedded Content Plan (<script type=\"application/floreo\" id=\"content-plan\">)"; ferr=1
  fi

  # --- data-floreo-id on <section> elements (ERROR if any section lacks it) ---
  local sec_total sec_with_id
  sec_total=$(count_matches '<section' "$content")
  sec_with_id=$(count_matches '<section[^>]*data-floreo-id=' "$content")
  if [ "$sec_total" -gt 0 ] && [ "$sec_with_id" -ne "$sec_total" ]; then
    echo "  ERROR  $((sec_total - sec_with_id))/$sec_total <section> missing data-floreo-id"; ferr=1
  fi

  # --- SVG accessibility (ERROR if any svg lacks role/title/desc/aria-labelledby) ---
  local svg_count svg_role svg_aria svg_title svg_desc
  svg_count=$(count_matches '<svg' "$content")
  if [ "$svg_count" -gt 0 ]; then
    svg_role=$(count_matches '<svg[^>]*role="img"' "$content")
    svg_aria=$(count_matches '<svg[^>]*aria-labelledby=' "$content")
    svg_title=$(count_matches '<title[^>]*id=' "$content")
    svg_desc=$(count_matches '<desc[^>]*id=' "$content")
    if [ "$svg_role" -ne "$svg_count" ]; then
      echo "  ERROR  $((svg_count - svg_role))/$svg_count <svg> missing role=\"img\""; ferr=1
    fi
    if [ "$svg_aria" -ne "$svg_count" ]; then
      echo "  ERROR  $((svg_count - svg_aria))/$svg_count <svg> missing aria-labelledby"; ferr=1
    fi
    if [ "$svg_title" -lt "$svg_count" ]; then
      echo "  ERROR  $((svg_count - svg_title))/$svg_count <svg> missing <title id>"; ferr=1
    fi
    if [ "$svg_desc" -lt "$svg_count" ]; then
      echo "  ERROR  $((svg_count - svg_desc))/$svg_count <svg> missing <desc id>"; ferr=1
    fi
  fi

  # --- Dark mode callout overrides (ERROR if missing) ---
  # --cab, --cw-bg, --cg-bg must be redefined after the dark media query.
  if ! grep -qE 'prefers-color-scheme:dark' <<<"$content" 2>/dev/null; then
    echo "  ERROR  no dark mode media query (prefers-color-scheme:dark)"; ferr=1
  else
    local dark_block
    dark_block=$(sed -n '/prefers-color-scheme:dark/,$p' <<<"$content")
    for var in --cab --cw-bg --cg-bg; do
      if ! grep -qE -- "${var}:" <<<"$dark_block" 2>/dev/null; then
        echo "  ERROR  dark mode missing override for $var"; ferr=1
      fi
    done
  fi

  # --- File size (ERROR over absolute max; WARN over per-template budget) ---
  local size budget
  size=$(wc -c <"$file" | tr -d ' ')
  budget=$(budget_for_type "$mtype")
  if [ "$size" -gt "$ABSOLUTE_MAX" ]; then
    echo "  ERROR  file size ${size}B exceeds absolute max ${ABSOLUTE_MAX}B"; ferr=1
  elif [ "$size" -gt "$budget" ]; then
    echo "  WARN   file size ${size}B over ${mtype:-unknown} budget ${budget}B (under absolute max)"; fwarn=1
  fi

  # --- Hardcoded hex outside :root (WARN — variables should be used) ---
  # Inline style attributes with hex colors, and SVG fill/stroke with literal hex
  # (not var()). :root definitions are allowed to define hex variables.
  local hex_inline hex_svg
  hex_inline=$(count_matches 'style="[^"]*#[0-9a-fA-F]{3,6}' "$content")
  hex_svg=$(count_matches '(fill|stroke)="#[0-9a-fA-F]{3,6}"' "$content")
  if [ "$hex_inline" -gt 0 ] || [ "$hex_svg" -gt 0 ]; then
    echo "  WARN   $((hex_inline + hex_svg)) hardcoded hex color(s) outside :root (use CSS variables)"; fwarn=1
  fi

  # --- max-width on .pg (ERROR if missing — mobile responsive) ---
  if ! grep -qE '\.pg\{[^}]*max-width' <<<"$content" 2>/dev/null; then
    echo "  ERROR  .pg missing max-width (mobile responsive)"; ferr=1
  fi

  # --- Tally ---
  if [ "$ferr" -eq 0 ] && [ "$fwarn" -eq 0 ]; then
    echo "  ✓ all checks passed (${size}B)"
  elif [ "$ferr" -eq 0 ]; then
    echo "  ~ passed with $fwarn warning(s)"
  else
    echo "  ✗ failed with error(s)"
  fi

  [ "$ferr" -eq 1 ] && ERRORS=$((ERRORS + 1))
  [ "$fwarn" -eq 1 ] && WARNINGS=$((WARNINGS + 1))
}

for f in "${FILES[@]}"; do
  check_file "$f"
done

echo ""
echo "summary: ${#FILES[@]} file(s) · $ERRORS error(s) · $WARNINGS warning(s)"

if [ "$ERRORS" -gt 0 ]; then
  exit 1
fi
if [ "$STRICT" -eq 1 ] && [ "$WARNINGS" -gt 0 ]; then
  exit 1
fi
exit 0
