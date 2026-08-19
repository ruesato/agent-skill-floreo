#!/usr/bin/env bash
# Scan the skills under skills/ with NVIDIA SkillSpector and fail on any
# non-suppressed finding.
#
# Adapted from crodris/skills (MIT) — bin/scan-skills.sh, via
# ruesato/agent-skills-lastcall.
#
# Usage:
#   scripts/scan-skills.sh [skill ...]   # default: every skills/<name>/ with a SKILL.md
#
# Environment:
#   SKILLSPECTOR_LLM=1   also run the LLM semantic stage (requires provider credentials,
#                        e.g. SKILLSPECTOR_PROVIDER=anthropic + ANTHROPIC_API_KEY)
#   REPORT_DIR=<dir>     write per-skill JSON and Markdown reports into <dir>
#
# Known false positives are suppressed via the repo-root .skillspector-baseline.yaml,
# with an auditable reason per suppression. Suppressed findings still appear in the
# JSON reports under "suppressed".
#
# Two properties this script exists to guarantee:
#
#   1. Each skill is scanned exactly once, and the Markdown report is rendered from
#      that scan's JSON. The scanner is not fully deterministic, so a re-scan to
#      produce the report could contradict the verdict that gated CI.
#   2. A scanner crash is not a clean skill. Crashes are counted separately from
#      findings and fail the run with their own message, so a skill that was never
#      assessed is never reported as passing.
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"

if ! command -v skillspector >/dev/null 2>&1; then
  echo "skillspector not found. Install it with:" >&2
  echo "  uv tool install git+https://github.com/NVIDIA/skillspector.git" >&2
  exit 1
fi

skill_names=("$@")
if [ ${#skill_names[@]} -eq 0 ]; then
  for d in skills/*/; do
    [ -f "$d/SKILL.md" ] && skill_names+=("$(basename "$d")")
  done
fi
if [ ${#skill_names[@]} -eq 0 ]; then
  echo "No skills with a SKILL.md found under skills/." >&2
  exit 1
fi

# The LLM stage is optional, so the same green check can mean two different
# depths of scan. Name the mode up front and carry it into every report: a
# --no-llm run must not be mistaken for a full one, and the baseline is only
# valid for the mode it was calibrated under.
scan_flags=()
if [ "${SKILLSPECTOR_LLM:-0}" = "1" ]; then
  scan_mode="static + LLM semantic stage"
else
  scan_mode="static only (--no-llm)"
  scan_flags+=(--no-llm)
fi

baseline_flags=()
baseline=".skillspector-baseline.yaml"
if [ -f "$baseline" ]; then
  baseline_flags=(--baseline "$baseline")
  baseline_state="$baseline"
else
  baseline_state="none (no $baseline present)"
fi

echo "skillspector $(skillspector --version 2>/dev/null || echo 'version unknown')"
echo "scan mode: $scan_mode"
echo "baseline:  $baseline_state"
echo

[ -n "${REPORT_DIR:-}" ] && mkdir -p "$REPORT_DIR"

failures=0
crashes=0
scanned=0
for skill in "${skill_names[@]}"; do
  skill_dir="skills/$skill"
  if [ ! -f "$skill_dir/SKILL.md" ]; then
    # Auto-discovered names always have a SKILL.md, so reaching here means an
    # explicitly requested skill is wrong (likely a typo). Fail rather than
    # risk a false "PASS" after scanning nothing.
    echo "error: $skill_dir has no SKILL.md" >&2
    exit 1
  fi
  scanned=$((scanned + 1))
  json="$(mktemp)"

  # skillspector is documented to always exit 0, but a crash (bad install,
  # provider error in the LLM stage) can still exit non-zero; under set -e an
  # unguarded call would kill the whole run with no summary and no reports.
  if ! skillspector scan "$skill_dir" ${scan_flags[@]+"${scan_flags[@]}"} ${baseline_flags[@]+"${baseline_flags[@]}"} \
    --format json --output "$json" >/dev/null; then
    echo "ERROR: skillspector crashed while scanning $skill" >&2
    crashes=$((crashes + 1))
    rm -f "$json"
    continue
  fi

  summary="$(python3 - "$json" "$skill" <<'PY'
import json, sys
report = json.load(open(sys.argv[1]))
risk = report["risk_assessment"]
active = report["issues"]
line = (
    f"{sys.argv[2]}: score {risk['score']}/100 ({risk['severity']}, "
    f"{risk['recommendation']}) | active {len(active)} | "
    f"suppressed {report['suppressed_count']}"
)
print(line)
for issue in active:
    loc = issue["location"]
    print(f"  {issue['id']} {issue['pattern']} [{issue['severity']}] "
          f"{loc['file']}:{loc['start_line']}")
sys.exit(1 if active else 0)
PY
)" && skill_ok=0 || skill_ok=1
  echo "$summary"

  if [ -n "${REPORT_DIR:-}" ]; then
    cp "$json" "$REPORT_DIR/$skill.json"
    # Render the Markdown report from the same JSON rather than re-scanning:
    # a second scan doubles cost (twice per skill, including the LLM stage)
    # and, because the scanner is not fully deterministic, could produce a
    # report that contradicts the JSON that decided pass/fail.
    python3 - "$json" "$skill" "$scan_mode" > "$REPORT_DIR/$skill.md" <<'PY'
import json, sys
report = json.load(open(sys.argv[1]))
risk = report["risk_assessment"]
print(f"# SkillSpector report: {sys.argv[2]}\n")
print(f"- Score: {risk['score']}/100 ({risk['severity']})")
print(f"- Recommendation: {risk['recommendation']}")
print(f"- Scan mode: {sys.argv[3]}")
print(f"- Active findings: {len(report['issues'])}")
print(f"- Suppressed findings: {report['suppressed_count']}")

def code_fence(text):
    # A snippet containing a backtick run >= the fence length would terminate
    # the fence early and corrupt the rest of the report, so pick a longer one.
    n = 3
    while "`" * n in text:
        n += 1
    return "`" * n

def emit(title, findings, suppressed):
    print(f"\n## {title}\n")
    if not findings:
        print("None.")
        return
    for f in findings:
        loc = f.get("location") or {}
        where = f"{loc.get('file', '?')}:{loc.get('start_line', '?')}"
        print(f"### {f.get('id', '?')} {f.get('pattern', '')} [{f.get('severity', '?')}] {where}\n")
        for key in ("finding", "explanation", "remediation"):
            if f.get(key):
                print(f"- **{key.capitalize()}**: {f[key]}")
        if suppressed and f.get("suppression_reason"):
            print(f"- **Suppression reason**: {f['suppression_reason']}")
        if f.get("code_snippet"):
            fence = code_fence(f["code_snippet"])
            print(f"\n{fence}\n{f['code_snippet']}\n{fence}")
        print()

emit("Active findings", report["issues"], suppressed=False)
emit("Suppressed findings", report.get("suppressed", []), suppressed=True)
PY
  fi
  rm -f "$json"

  [ "$skill_ok" -ne 0 ] && failures=$((failures + 1))
done

if [ "$scanned" -eq 0 ]; then
  # Belt and braces: reaching here with nothing scanned would otherwise print
  # a false "PASS" after scanning nothing.
  echo "error: no skills were scanned" >&2
  exit 1
fi

if [ "$failures" -gt 0 ] || [ "$crashes" -gt 0 ]; then
  echo
  if [ "$failures" -gt 0 ]; then
    echo "FAIL: $failures skill(s) have non-suppressed findings." >&2
    echo "Fix the finding, or if it is a reviewed false positive, add a rule with a" >&2
    echo "reason to .skillspector-baseline.yaml." >&2
  fi
  if [ "$crashes" -gt 0 ]; then
    echo "FAIL: the scanner crashed on $crashes skill(s); those skills were NOT" >&2
    echo "assessed. Check the install and provider credentials, then re-run." >&2
  fi
  exit 1
fi

echo
echo "PASS: all scanned skills are clean ($scan_mode; suppressions documented in $baseline)."
