---
name: floreo
description: >
  Produce a polished, self-contained HTML document from agent-created content.
  INVOKE whenever the agent is about to write: a report, summary, analysis,
  research brief, plan, proposal, retrospective, incident report, session-close
  summary, or agent brief (when the receiver is human). Floreo turns these into
  polished .html reading artifacts — do not write them as Markdown instead.
  Do NOT invoke for: any .md file the project or a tool expects (README.md,
  CLAUDE.md, AGENTS.md, SKILL.md, steering files, skill or command
  definitions), or content a downstream agent or tool will parse as plain text.
---

# Floreo

*floreo* — Latin: I flower. I bloom. I flourish.

Turn raw content into polished, self-contained HTML. Agents write the markup; humans see the rendered page. The same information, arranged so its meaning can finally be seen.

## When to Invoke

Use floreo for **documents that exist to be read** — reports, analyses, and any multi-section content a human will read for understanding, not to configure a tool:

- Reports · summaries · analyses
- Plans · proposals · design decisions
- Research · comparisons · tutorials
- Meeting notes · project updates
- Incident reports · post-mortems
- Session-close summaries (see **Session-Close Protocol** section below)
- Agent briefs (when the receiver is a human, not another agent parsing text)

**Default**: write these as `.html` via floreo, not as Markdown. Floreo is the output path for reading artifacts — don't default to `.md` just because that's the familiar format.

**Minimum threshold** — use floreo when the content has at least two of:
- Multiple sections (three or more headings)
- A table, chart, or diagram
- Content that must persist beyond the current conversation
- An audience beyond the immediate user (shared docs, stakeholder reports)

**Do NOT floreo any of these:**
- `.md` files the project expects: `README.md`, `CLAUDE.md`, `AGENTS.md`, `ONBOARDING.md`, `CONTRIBUTING.md`, ADRs saved as Markdown, or any file whose format is dictated by the project or a tool
- Skill and command definition files (`SKILL.md`, files in `skills/`, `commands/`, `agents/`)
- Steering and config files for agents or tools (`.cursor/rules`, `.github/copilot-instructions.md`, `system-prompt.txt`, etc.)
- Content a downstream agent or tool will parse as plain text or Markdown
- Short conversational answers, inline code explanations, or quick status updates (1–3 sentences)
- Content destined to be embedded in another system (Notion, Confluence, GitHub comments, PR descriptions)

## Two-Phase Composition

Phase 1 and Phase 2 may run sequentially in a single agent, or Phase 2 may be delegated to a Haiku subagent for token efficiency.

### Phase 1 — Content (current model)

The current model does the thinking work:

1. Understand the audience and purpose of this document
2. Determine the information hierarchy (what's primary, secondary, metadata)
3. **Identify visual treatment** — for every section with data, make an explicit choice using this table. Do not skip this step. Tables are for relationships; charts are for magnitudes and trends. Default to a chart when the data has shape.

   | If your content has… | Reach for… |
   |---|---|
   | 2–8 quantities to compare | Bar chart (inline SVG) |
   | A value changing over time | Line chart (inline SVG) |
   | Parts of a whole (percentages, shares) | Donut chart (inline SVG) |
   | Events in chronological order | Timeline (`.tl` component) |
   | A process with steps or branches | Flow diagram (inline SVG) |
   | 3+ headline metrics | Stat block (`.stats`) |
   | Phases or milestones with dates | Milestone chart (inline SVG) |
   | 4 or more `<h2>` sections | Table of contents (included by default) |

4. Write all prose, headings, and data in structured form
5. Produce a **Content Plan** (see format below)

### Phase 2 — Markup (efficient subagent preferred)

Compose the HTML from the Content Plan. This is mechanical work — use the most token-efficient model capable of producing clean HTML (currently Haiku; substitute any cheaper capable model as the ecosystem evolves).

**If the Agent tool is available**, spawn a markup subagent:

```
Use the Agent tool with model="haiku" (or the most efficient model currently available).

Prompt: [paste the MARKUP SUBAGENT PROMPT from the resources section]
Provide: the full Content Plan as input.
```

**If the Agent tool is unavailable**, compose the markup in the current model using the same guidelines.

### Phase 3 — Visual Polish (optional, requires impeccable)

After Phase 2 writes the `.html` file to disk:

1. **Check availability**: Scan the available skills list for `impeccable`. If it is not present, skip this phase silently.
2. **Check project context**: Look for `PRODUCT.md` in the project root (or wherever impeccable resolves it — `.agents/context/`, `docs/`). If impeccable is available but `PRODUCT.md` is missing, skip Phase 3 and tell the user: *"Run `/impeccable teach` to enable automatic visual polish on future floreo documents."*
3. **Invoke impeccable**: With both conditions met, run:
   ```
   /impeccable polish [path-to-generated-html-file]
   ```
   Impeccable will load its project context, apply its design system, and perform a full visual quality pass — typography hierarchy, spacing rhythm, color contrast, and document-appropriate polish.
4. **Verify self-containment**: After impeccable finishes, confirm the file still has no external dependencies (no `<link rel="stylesheet">`, no CDN `<script src=...>`, no remote `@import`). If impeccable introduced any, remove them and inline the styles.

**What impeccable improves over floreo's base output**: typography scale and weight contrast, spacing rhythm (impeccable enforces deliberate variation vs. uniform padding), color strategy (OKLCH tinted neutrals, chroma-aware palette), and any design drift from floreo's component patterns. Floreo provides structure; impeccable provides craft.

### Content Plan format

```
DOCUMENT: [title]
AUDIENCE: [who reads this]
PURPOSE: [what decision or understanding this enables]
ACCENT: [hex color matching document purpose/brand]

SECTIONS:
1. [Section name] — [content type: prose|table|list|figure|code]
   [content or structured data]

2. [Section name] — [content type]
   [content]

VISUAL ELEMENTS:
- [Required when any section has quantitative data. For each: chart type + data + which section. Write "none" explicitly if no quantitative content.]

INTERACTIVE:
- [Required field. List any: toc | tabs | search | collapsible — or write "none". ToC is required when 4+ sections.]

CALLOUTS:
- [NOTE|WARN|TIP]: [text]
```

For **table** sections, provide data in this form so Haiku can map it directly to `<thead>/<tbody>`:

```
3. API Comparison — table
   COLUMNS: Method | Latency (p50) | Auth Required | Rate Limit
   ROW: GET /users | 12ms | yes | 1000/hr
   ROW: POST /events | 45ms | yes | 500/hr
   ROW: GET /health | 2ms | no | unlimited
   HIGHLIGHT_ROW: POST /events  (draw attention to this row)
```

For **figure** sections, describe the data and the chart type. Available types: `bar chart`, `line chart`, `donut chart`, `milestone chart`, `flow diagram`, `timeline` (uses `.tl` component).

```
4. Response time by region — figure
   TYPE: bar chart
   DATA: us-east=12ms, eu-west=34ms, ap-southeast=78ms
   CAPTION: P50 latency measured over 7-day window

5. Error rate over time — figure
   TYPE: line chart
   DATA: Jan=0.1%, Feb=0.3%, Mar=0.2%, Apr=0.8%, May=0.15%
   CAPTION: Monthly p95 error rate

6. Traffic by source — figure
   TYPE: donut chart
   DATA: organic=60%, paid=25%, direct=15%
   CAPTION: Traffic sources Q1 2026

7. Release schedule — figure
   TYPE: milestone chart
   DATA: Alpha=2026-03-01(done), Beta=2026-05-01(done), Launch=2026-07-01(upcoming)
   CAPTION: Filled = complete, open = planned
```

### Content Plan preservation

Phase 2 **must** embed the Content Plan inside the generated HTML as a machine-readable artifact. This lets future agents update the document without reverse-engineering markup, and enables export to other formats without re-reading the source.

Convention: place a `<script type="application/floreo" id="content-plan">` element immediately before `</body>` containing the full Content Plan verbatim.

```html
<script type="application/floreo" id="content-plan">
DOCUMENT: [title]
AUDIENCE: [who reads this]
PURPOSE: [what this enables]
ACCENT: [hex]

SECTIONS:
1. ...

VISUAL ELEMENTS:
- ...

CALLOUTS:
- ...
</script>
</body>
```

This element is invisible to browsers and human readers. It is not executed. Its only consumer is a future agent.

## Content Plan Templates

Copy the matching template, fill in bracketed placeholders, then pass to Phase 2.

### Incident Report

```
DOCUMENT: [Service] Incident — [YYYY-MM-DD]
AUDIENCE: Engineering team, on-call, leadership
PURPOSE: Capture what happened, root cause, and prevention so this class of incident doesn't recur
ACCENT: #dc2626

SECTIONS:
1. Executive Summary — table
   COLUMNS: Field | Value
   ROW: Severity | [P0/P1/P2]
   ROW: Duration | [start] → [end] ([N] min)
   ROW: Services Affected | [list]
   ROW: User Impact | [description]
   ROW: Status | Resolved

2. Timeline — figure
   TYPE: timeline (use .tl component)
   [Each event: timestamp | title | description — ordered earliest to latest]

3. Root Cause — prose
   [Technical explanation of the underlying failure]

4. Impact — table
   COLUMNS: Metric | Before | During | After
   ROW: [error rate / latency / availability...]

5. Resolution — prose
   [Steps taken to restore service]

6. Prevention — list
   [Action items with owners and due dates]

VISUAL ELEMENTS:
- stat block: Duration=[N min], Error Rate=[peak %], Users Affected=[N]
- timeline: section 2 (use .tl component — required)

INTERACTIVE:
- toc (6 sections — required)

CALLOUTS:
- NOTE: [any important context about detection or response]
```

### Architecture Decision Record (ADR)

```
DOCUMENT: ADR-[NNN]: [Decision Title]
AUDIENCE: Engineering team, future maintainers
PURPOSE: Record why this decision was made so future engineers can revisit with full context
ACCENT: #7c3aed

SECTIONS:
1. Status — prose
   [Proposed | Accepted | Deprecated | Superseded by ADR-NNN]

2. Context — prose
   [The forces at play — technical, organizational, constraints — that motivated this decision]

3. Decision — prose
   [The change being made and exactly what it means]

4. Alternatives Considered — table
   COLUMNS: Option | Pros | Cons | Rejected Because
   ROW: [option A] | [pros] | [cons] | [reason]
   ROW: [option B] | [pros] | [cons] | [reason]

5. Consequences — list
   [What becomes easier, harder, or required as a result of this decision]

VISUAL ELEMENTS:
- none typically; flow diagram (optional) if section 2 describes component relationships affected by this decision

INTERACTIVE:
- toc (5 sections — required)

CALLOUTS:
- NOTE: [any constraint that explains an otherwise surprising choice]
```

### Sprint Retrospective

```
DOCUMENT: Sprint [N] Retrospective — [start date] → [end date]
AUDIENCE: Engineering team
PURPOSE: Surface what to keep, stop, and start to improve team velocity next sprint
ACCENT: #16a34a

SECTIONS:
1. Sprint Summary — table
   COLUMNS: Metric | Value
   ROW: Points Committed | [N]
   ROW: Points Delivered | [N]
   ROW: Velocity | [N]%
   ROW: Incidents | [N]
   ROW: PRs Merged | [N]

2. What Went Well — list
   [Things to continue or amplify]

3. What to Improve — list
   [Friction points, gaps, or frustrations the team experienced]

4. Action Items — table
   COLUMNS: Action | Owner | Due
   ROW: [specific change] | [name] | [date]

VISUAL ELEMENTS:
- stat block: Points Committed=[N], Points Delivered=[N], Velocity=[N]% (required)

INTERACTIVE:
- toc (4 sections — required)

CALLOUTS:
- TIP: [recognition for a team member or a win worth calling out]
```

### Research Brief

```
DOCUMENT: [Topic] Research Brief
AUDIENCE: [decision-maker role, e.g. "engineering leads", "product team"]
PURPOSE: Synthesize findings to inform [specific decision or question]
ACCENT: #0891b2

SECTIONS:
1. Research Question — prose
   [The specific question this brief answers]

2. Methodology — prose
   [Sources consulted, data collected, scope and timeframe]

3. Key Findings — list
   [Top 4–7 findings, most important first]

4. Comparison — table
   COLUMNS: Option | [criterion A] | [criterion B] | [criterion C] | Verdict
   ROW: [option] | [value] | [value] | [value] | [rec]

5. Recommendation — prose
   [Specific recommended course of action with rationale]

VISUAL ELEMENTS:
- bar chart: comparison data from section 4 (required when any criterion column is quantitative; omit only when all columns are qualitative text)

INTERACTIVE:
- toc (5 sections — required)
- search (optional — useful for long briefs with dense findings)

CALLOUTS:
- WARN: [significant risk, caveat, or data limitation]
```

### Onboarding Guide

```
DOCUMENT: [Team / System] Onboarding Guide
AUDIENCE: New engineers joining the team
PURPOSE: Get to first meaningful contribution within [N] days without requiring hand-holding
ACCENT: #2563eb

SECTIONS:
1. Welcome — prose
   [What this team does, who they serve, why it matters]

2. System Overview — prose
   [High-level architecture or domain model; link to deeper docs if available]

3. Setup — list (numbered procedure)
   [Step-by-step environment setup: repo, credentials, local run, first test]

4. Key Concepts — list
   [Glossary of team-specific terms, acronyms, and mental models]

5. Quick Reference — table
   COLUMNS: Task | Command / Link
   ROW: Run tests | [command]
   ROW: Deploy to staging | [command or link]
   ROW: File a bug | [link]

6. Getting Help — prose
   [Slack channels, on-call rotation, docs locations, who to ask for what]

VISUAL ELEMENTS:
- flow diagram (optional): system architecture if section 2 describes component relationships

INTERACTIVE:
- toc (6 sections — required)
- collapsible: wrap section 3 step details if setup has more than 8 steps

CALLOUTS:
- TIP: [most important thing a new person should know in the first week]
```

### API Reference Page

```
DOCUMENT: [API Name] Reference
AUDIENCE: Developers integrating the API
PURPOSE: Enable self-service integration without requiring direct support
ACCENT: #2563eb

SECTIONS:
1. Overview — prose
   [What the API does, base URL, protocol/versioning]

2. Authentication — code
   [Auth mechanism: API key / OAuth / JWT — show a minimal working example]

3. Endpoints — table
   COLUMNS: Method | Path | Description | Auth Required
   ROW: GET | /[resource] | [what it returns] | yes/no
   ROW: POST | /[resource] | [what it creates] | yes/no

4. Request / Response — code
   [Minimal working example: curl or JSON request + annotated response]

5. Error Codes — table
   COLUMNS: Code | Meaning | Common Cause
   ROW: 400 | Bad Request | [reason]
   ROW: 401 | Unauthorized | [reason]
   ROW: 429 | Rate Limited | [reason]

6. Rate Limits — prose
   [Limits, headers returned, backoff strategy]

VISUAL ELEMENTS:
- bar chart (optional): latency by endpoint if performance benchmarks are available
- none otherwise

INTERACTIVE:
- toc (6 sections — required)
- collapsible: each endpoint group if there are more than 6 endpoints

CALLOUTS:
- WARN: [breaking change, deprecation, or gotcha worth surfacing prominently]
```

### Project Proposal

```
DOCUMENT: [Project Name] Proposal
AUDIENCE: [stakeholder group], leadership
PURPOSE: Get approval and resources to begin [project] by [target date]
ACCENT: #7c3aed

SECTIONS:
1. Problem Statement — prose
   [The specific pain, cost, or opportunity this project addresses]

2. Proposed Solution — prose
   [What we'll build or change and why this approach]

3. Success Metrics — table
   COLUMNS: Metric | Baseline | Target | Measurement
   ROW: [metric] | [current] | [goal] | [how measured]

4. Timeline — figure
   TYPE: milestone chart (use the milestone SVG pattern from the skill — required)
   [Each phase: name=date(done|upcoming) — mark completed phases filled, add TODAY marker]

5. Resources Required — table
   COLUMNS: Resource | Amount | Source
   ROW: Engineering | [N weeks] | [team]
   ROW: Infrastructure | [$N/mo] | [budget]

6. Risks — table
   COLUMNS: Risk | Likelihood | Impact | Mitigation
   ROW: [risk] | H/M/L | H/M/L | [plan]

VISUAL ELEMENTS:
- milestone chart: phases from section 4 (required)
- stat block: 2–3 key success metrics from section 3

INTERACTIVE:
- toc (6 sections — required)

CALLOUTS:
- NOTE: [key constraint — deadline, dependency, or stakeholder requirement]
```

### Agent Brief

A compact handoff document for multi-agent pipelines. One agent produces it; a downstream agent reads it. Humans can also review it in a browser. Use `floreo:type="brief"` in the meta tag.

```
DOCUMENT: Brief — [task/agent name] — [YYYY-MM-DD]
AUDIENCE: Downstream agent in a multi-agent pipeline (and any human reviewer)
PURPOSE: Transfer task context so the receiving agent acts without re-discovery
ACCENT: #0f766e

SECTIONS:
1. Objective — prose
   [Single sentence: exactly what the receiving agent must accomplish]

2. Constraints — list
   [Hard constraints: tech stack, deadlines, non-negotiables, scope limits]

3. Context — prose
   [What was tried, what was learned, what the current state is — only what the receiving agent needs]

4. Available Inputs — table
   COLUMNS: Input | Location | Notes
   ROW: [file/resource] | [path or URL] | [how to use it]

5. Decisions Already Made — list
   [Choices the receiving agent must respect and not re-open, with brief rationale]

6. Handoff Notes — list
   [Watch-outs, assumptions in play, partial work left in progress]

VISUAL ELEMENTS:
- none typically; flow diagram (optional) if section 3 describes a multi-step process with branching paths

INTERACTIVE:
- none (briefs are consumed programmatically — interactive features add overhead for the target agent parser)

CALLOUTS:
- NOTE: [any constraint or dependency the receiving agent must not miss]
```

**Programmatic extraction**: sections are accessible via `document.querySelector('[data-floreo-id="constraints"]')` — no regex-parsing HTML. This works because every `<section>` carries a `data-floreo-id` matching its heading slug.

```

### Agent Session-Close Summary

```
DOCUMENT: Session Close — [agent/task name] — [YYYY-MM-DD]
AUDIENCE: Next agent or human resuming this work
PURPOSE: Transfer context so work can resume without re-discovery
ACCENT: #2563eb

SECTIONS:
1. Session Objective — prose
   [What this session set out to accomplish]

2. Work Completed — list
   [Concrete deliverables: files written, issues closed, decisions made]

3. Issues Updated — table
   COLUMNS: Issue ID | Title | Status | Notes
   ROW: [id] | [title] | closed / in_progress | [relevant context]

4. Key Decisions — list
   [Choices made during this session and the reasoning behind them]

5. Blockers & Open Questions — list
   [Anything unresolved that the next session needs to address]

6. Next Session Kickoff — prose
   [Exactly what to do first in the next session, including any commands to run]

VISUAL ELEMENTS:
- none typically; stat block if the session produced measurable outputs (issues closed, tests passing, files written)

INTERACTIVE:
- toc (6 sections — required)

CALLOUTS:
- WARN: [anything that could go wrong if context is lost — partial state, temp files, etc.]
```

## Session-Close Protocol

At the end of any work session involving meaningful decisions, code changes, or multi-step tasks, write a floreo session-close summary using the **Agent Session-Close Summary** Content Plan template.

**When a session-close summary is warranted** (≥2 of the following apply):
- Code was written, modified, or debugged
- Design or architecture decisions were made
- Blockers were encountered or resolved
- Issues were created, updated, or closed
- Context exists that a future agent would need to avoid re-discovering

**Output**: use the Agent Session-Close Summary template, write to `docs/session-close-<task-slug>-<YYYY-MM-DD>.html`.

This replaces the plain-text "hand off" step in agent session-close protocols. The floreo document is grep-able, scannable, and permanently structured — it carries the same context a markdown paragraph would, with reliable section boundaries a future agent can extract programmatically.

---

## File Output

**Naming convention**: `<kebab-document-title>-<YYYY-MM-DD>.html`

Examples: `sprint-retro-2026-05-22.html` · `auth-architecture-2026-04-10.html` · `incident-db-outage-2026-03-01.html`

**Default location**: `docs/` relative to the project root. Create the directory if it doesn't exist. If the project has an existing documentation convention, follow it.

**Uniqueness**: If a file with the same name exists, append `-v2`, `-v3`, etc. Do not silently overwrite.

---

## HTML Philosophy

### Audience split

| | Humans | Agents |
|---|---|---|
| **Sees** | Rendered page | Markup source |
| **Does** | Reads, navigates | Creates, reads, edits |
| **Optimize for** | Visual hierarchy, clarity | Semantic structure, token efficiency |

### Self-containment

Everything lives in one `.html` file:

- All CSS in `<style>` within `<head>`
- All JavaScript in `<script>` at the end of `<body>`
- All images as inline SVG or base64 data URIs
- No `<link rel="stylesheet">` to external files
- No CDN imports or `import` statements

**Target size**: keep documents under **100 KB** absolute maximum. More importantly, stay within the per-template budget for your document type:

| Template type | Target | Hard limit |
|---|---|---|
| Session-close summary | < 20 KB | 30 KB |
| Sprint retrospective | < 20 KB | 30 KB |
| Agent brief | < 20 KB | 30 KB |
| Incident report | < 30 KB | 50 KB |
| Architecture decision record | < 30 KB | 50 KB |
| Onboarding guide | < 30 KB | 50 KB |
| API reference | < 30 KB | 50 KB |
| Research brief | < 50 KB | 75 KB |
| Project proposal | < 50 KB | 75 KB |

Check size before writing: `wc -c <file>.html`. The base CSS alone is ~3.5 KB — content budget is total minus that overhead.

**When approaching 100 KB**, reduce before breaking self-containment:
- Replace base64 images with `<figure>` + caption text
- Simplify SVG paths (fewer points, combine shapes)
- Split into multiple linked floreo files with a floreo index page

**If self-containment must be broken** (e.g., a genuinely required binary asset):
1. Extract resources to `docs/assets/<document-slug>/`
2. Create `<document-name>.manifest.json` listing relative asset paths
3. Add `<meta name="floreo:assets" content="<document-name>.manifest.json">` to `<head>`
4. Note in the document footer that external dependencies exist

Never silently break self-containment — the manifest makes it explicit and machine-readable.

### Markup optimization

Markup is written for agent efficiency, not human readability of source:

- **Short class names**: `.hd`, `.bd`, `.fn`, `.sc`, `.card`, `.note`, `.warn`, `.tip`, `.fig`, `.tbl`, `.code`, `.grid`
- **Compressed CSS**: minimal whitespace; combine selectors; use shorthand
- **Omit optional attributes**: no `type="text/javascript"`, no `type="text/css"`
- **Semantic HTML5**: use `<header>`, `<main>`, `<section>`, `<article>`, `<aside>`, `<footer>`, `<figure>`, `<figcaption>`, `<nav>` to reduce class overhead
- **No redundant wrappers**: nest elements directly when a wrapper adds no semantic or layout value

### Markup Compression Rules

Source HTML is written for agents and LLMs, not humans. Humans see only the rendered page — they never read the source. Apply every rule without exception:

**Omit optional closing tags** — HTML5 allows these to be elided:
- `</p>` when followed by another block element or end of parent
- `</li>` when followed by `<li>` or end of list
- `</td>`, `</tr>`, `</th>`, `</thead>`, `</tbody>` — all optional in HTML5

**No whitespace between tags** — no newlines, no spaces between adjacent elements:
```
<!-- WRONG -->
<ul>
  <li>One</li>
  <li>Two</li>
</ul>

<!-- RIGHT -->
<ul><li>One<li>Two</ul>
```

**No indentation** — zero leading spaces or tabs before any element.

**No HTML comments** — never write `<!-- ... -->` in generated output.

**Boolean attributes without values** — `disabled` not `disabled="disabled"`, `checked` not `checked="true"`, `required` not `required="required"`.

**CSS shorthand throughout** — `margin:0 1rem` not four separate margin properties; `padding:.6rem 1rem` not two; `border:1px solid var(--cbr)` not three separate properties.

---

## Design System

### Typography

System fonts — no external dependencies, instant load:

```css
:root{
  --f-h:Georgia,'Times New Roman',serif;
  --f-b:system-ui,-apple-system,BlinkMacSystemFont,sans-serif;
  --f-m:'Courier New',Courier,monospace
}
```

**Serif Authority Rule:** `h1` and `h2` use `--f-h` (Georgia) — section-level authority. `h3` and below use `--f-b` (system-ui) — they are within a section, not starting a new chapter. Never apply `--f-h` to `h3` or below. Use `--f-m` for code, metadata, labels, eyebrows.

Type scale (rem): `--t-xs:.75` `--t-sm:.875` `--t-md:1` `--t-lg:1.125` `--t-xl:1.25` `--t-2xl:1.5` `--t-3xl:2` `--t-4xl:3`

### Color tokens

Adapt `--ca` (accent) to the document's purpose or brand:

```css
:root{
  --cb:#fafaf9;    /* page background */
  --cs:#ffffff;   /* surface (cards, panels) */
  --cbr:#e7e5e4;  /* border */
  --ct:#1c1917;   /* primary text */
  --cm:#57534e;   /* muted/secondary text */
  --cq:#a8a29e;   /* quiet/meta text */
  --ca:#2563eb;   /* accent — vary by document */
  --cab:#dbeafe;  /* accent background tint */
  --cw-bg:#fef3c7; --cw:#d97706;  /* warning amber */
  --cg-bg:#dcfce7; --cg:#16a34a   /* success green */
}
```

**Dark mode — always override callout backgrounds.** The pastel tints (`--cab`, `--cw-bg`, `--cg-bg`) become unreadable with near-white text in dark mode. Add these to the dark mode `:root` block:

```css
@media(prefers-color-scheme:dark){:root{
  /* ... other dark tokens ... */
  --cab:#082f3e;   /* dark teal — readable with #fafaf9 text */
  --cw-bg:#3d1a00; /* dark amber */
  --cg-bg:#052e16  /* dark green */
}}
```

Common accent values by document type — pick a shade to create visual variety within a category:

| Category | Light | Default | Deep |
|---|---|---|---|
| Technical / default | `#3b82f6` | `#2563eb` | `#1d4ed8` |
| Warning / incident | `#ef4444` | `#dc2626` | `#b91c1c` |
| Success / completion | `#22c55e` | `#16a34a` | `#15803d` |
| Planning / strategy | `#8b5cf6` | `#7c3aed` | `#6d28d9` |
| Research / analysis | `#06b6d4` | `#0891b2` | `#0e7490` |
| Brief / handoff | `#2dd4bf` | `#0f766e` | `#0d5e56` |
| Caution / review | `#fbbf24` | `#d97706` | `#b45309` |
| Neutral / meta | `#a8a29e` | `#78716c` | `#57534e` |

### Project-level brand color

If a project defines a brand color (via `floreo:brand-color: #hex` in CLAUDE.md, a project config, or explicit user instruction), use it as `--ca` for all documents in that project. This creates visual cohesion across a project's document library without per-document color decisions.

When using a brand color, verify contrast against `--cb` (background) and `--cs` (surface). Minimum contrast ratio: 3:1 for large text (headings, badges), 4.5:1 for body text.

### Layout variation

Beyond color, vary document layout to prevent monotony at scale:

- **Cover header** — large accent-background hero for high-stakes documents (proposals, major incident reports): set `.hd{background:var(--ca);color:#fff;padding:3rem;border-radius:8px}` and invert heading/subtitle colors
- **Dense data** — reduce padding for information-heavy reference docs: `.sc{margin-bottom:1.5rem}` and `.tbl td{padding:.4rem .75rem}`
- **Two-column body** — for comparison docs, `<div style="display:grid;grid-template-columns:1fr 1fr;gap:2rem">` wrapping parallel `<section>` elements

### Spacing

`--s1:4px` `--s2:8px` `--s3:12px` `--s4:16px` `--s5:24px` `--s6:32px` `--s7:48px` `--s8:64px`

---

## Base CSS Block

Include this compressed block in every floreo document. Extend as needed:

```css
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
:root{--f-h:Georgia,'Times New Roman',serif;--f-b:system-ui,-apple-system,sans-serif;--f-m:'Courier New',Courier,monospace;--cb:#fafaf9;--cs:#fff;--cs2:#f5f5f4;--cbr:#e7e5e4;--ct:#1c1917;--cm:#57534e;--cq:#a8a29e;--ca:#2563eb;--cab:#dbeafe;--cw-bg:#fef3c7;--cw:#d97706;--cg-bg:#dcfce7;--cg:#16a34a}
:root{--s1:4px;--s2:8px;--s3:12px;--s4:16px;--s5:24px;--s6:32px;--s7:48px;--s8:64px}
:root{--t-xs:.75rem;--t-sm:.875rem;--t-md:1rem;--t-lg:1.125rem;--t-xl:1.25rem;--t-2xl:1.5rem;--t-3xl:2rem;--t-4xl:3rem}
@media(prefers-color-scheme:dark){:root{--cb:#1c1917;--cs:#292524;--cs2:#211f1e;--cbr:#44403c;--ct:#fafaf9;--cm:#d6d3d1;--cq:#78716c;--cab:#082f3e;--cw-bg:#3d1a00;--cg-bg:#052e16}.code{border:1px solid var(--cbr)}}
body{font-family:var(--f-b);background:var(--cb);color:var(--ct);line-height:1.7;padding:0 1rem}
.pg{max-width:860px;margin:0 auto;padding:4rem 0 8rem}
h1,h2{font-family:var(--f-h);line-height:1.2;color:var(--ct)}
h3,h4{font-family:var(--f-b);line-height:1.2;color:var(--ct)}
h1{font-size:2.5rem;font-weight:400;letter-spacing:-.02em;margin-bottom:.4rem}
h2{font-size:1.5rem;font-weight:400;margin-bottom:1rem;padding-bottom:.4rem;border-bottom:1px solid var(--cbr)}
h3{font-size:1.1rem;font-weight:600;margin-bottom:.4rem}
p{margin-bottom:1rem;color:var(--cm)}
.sc{margin-bottom:3rem}
.hd{padding-bottom:2rem;margin-bottom:3rem;border-bottom:2px solid var(--cbr)}
.fn{border-top:1px solid var(--cbr);padding-top:1.5rem;font-size:.8rem;color:var(--cq);font-family:var(--f-m)}
.ey{font-family:var(--f-m);font-size:.75rem;letter-spacing:.1em;text-transform:uppercase;color:var(--ca);margin-bottom:.75rem}
.sub{font-size:1.1rem;color:var(--cm)}
.note,.warn,.tip{padding:1rem 1.25rem;border-radius:8px;margin:1.5rem 0;font-size:.95rem;color:var(--ct)}
.note{background:var(--cab)}
.warn{background:var(--cw-bg)}
.tip{background:var(--cg-bg)}
.tw{overflow-x:auto;margin:1.5rem 0;border:1px solid var(--cbr);border-radius:8px;overflow:hidden}
.tbl{width:100%;border-collapse:collapse;font-size:.9rem;background:var(--cs)}
.tbl thead{background:var(--cs2)}
.tbl th{text-align:left;padding:.6rem 1rem;font-family:var(--f-m);font-size:.75rem;letter-spacing:.06em;text-transform:uppercase;color:var(--cm);border-bottom:1px solid var(--cbr)}
.tbl td{padding:.6rem 1rem;border-bottom:1px solid var(--cs2);color:var(--cm);vertical-align:top}
.tbl tr:last-child td{border-bottom:none}
.grid{display:grid;gap:1rem;grid-template-columns:repeat(auto-fill,minmax(240px,1fr));margin:1.5rem 0}
.card{background:var(--cs);border:1px solid var(--cbr);border-radius:8px;padding:1.25rem}
.code{background:#1c1917;color:#f5f5f4;padding:1.25rem;border-radius:8px;font-family:var(--f-m);font-size:.85rem;overflow-x:auto;margin:1.5rem 0;white-space:pre-wrap;word-break:break-all}
.fig{margin:1.5rem 0;text-align:center}
.fig svg{max-width:100%;height:auto}
figcaption{font-size:.8rem;color:var(--cq);margin-top:.5rem;font-style:italic;text-align:center}
a{color:var(--ca);text-decoration:none;transition:color .15s ease-out}
a:hover{text-decoration:underline}
ul,ol{padding-left:1.5rem;margin-bottom:1rem;color:var(--cm)}
li{margin-bottom:.25rem}
strong{color:var(--ct)}
.ic{background:var(--cs2);padding:.1rem .3rem;border-radius:3px;font-family:var(--f-m);font-size:.85rem}
@media(prefers-reduced-motion:reduce){*{transition:none!important}}
```

---

## Page Skeleton

```html
<!DOCTYPE html><html lang="en"><head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="floreo:type" content="<!-- report|plan|adr|retro|session-close -->">
<meta name="floreo:created" content="<!-- YYYY-MM-DD -->">
<meta name="floreo:model" content="<!-- e.g. claude-sonnet-4-6 -->">
<meta name="floreo:version" content="1">
<title>Document Title</title>
<style>/* base css block + document-specific additions */</style>
</head><body>
<div class="pg">
  <header class="hd">
    <p class="ey"><!-- type label, e.g. "Technical Report · 2026-05-22" --></p>
    <h1>Document Title</h1>
    <p class="sub"><!-- one-line description --></p>
  </header>
  <main>
    <section class="sc" data-floreo-id="section-slug">
      <h2>Section Heading</h2>
      <!-- section content -->
    </section>
    <!-- more sections -->
  </main>
  <footer class="fn">
    <!-- source info, timestamp, author -->
  </footer>
</div>
<script>/* progressive enhancement JS, if needed */</script>
</body></html>
```

### Section IDs (`data-floreo-id`)

Every `<section>` element must carry a `data-floreo-id` attribute with a stable kebab-case slug derived from the section heading:

- "Root Cause Analysis" → `data-floreo-id="root-cause-analysis"`
- "Key Findings" → `data-floreo-id="key-findings"`
- "Next Session Kickoff" → `data-floreo-id="next-session-kickoff"`

Rules: lowercase, hyphens only (no underscores or spaces), no punctuation, match the `<h2>` text.

**Why this matters**: section IDs enable section-level diffs (`floreo-aware diff: "key-findings changed"` instead of raw line noise), stable deep-links across document versions (`#key-findings` survives a full regeneration), and programmatic extraction by downstream agents (`document.querySelector('[data-floreo-id="constraints"]').textContent`).

The attribute is zero-cost in source and invisible to readers. Add it to every `<section class="sc">` — no exceptions.

---

## Components

### Callouts

```html
<div class="note"><strong>Note:</strong> informational aside</div>
<div class="warn"><strong>Warning:</strong> caution or risk</div>
<div class="tip"><strong>Tip:</strong> helpful suggestion</div>
```

**Background tint is the signal. No side-stripe borders.** Never add `border-left` or `border-right` as a colored accent to callouts — that is the Bootstrap-alert aesthetic this system explicitly rejects. The background color alone communicates the variant. The dark mode overrides for `--cab`, `--cw-bg`, and `--cg-bg` are required (see Color tokens above).

### Inline code

Use the `.ic` class for inline code snippets within prose or table cells. Do not repeat inline `style` attributes:

```html
Run <code class="ic">/floreo install</code> to begin.
```

### Table

```html
<div class="tw"><table class="tbl">
<thead><tr><th>Column A</th><th>Column B</th><th>Column C</th></tr></thead>
<tbody>
<tr><td>value</td><td>value</td><td>value</td></tr>
</tbody>
</table></div>
```

Highlight a row: add `style="background:var(--cab)"` to `<tr>`.

### Card grid

```html
<div class="grid">
  <div class="card"><h3>Title</h3><p>Body text describing this card's content.</p></div>
  <div class="card"><h3>Title</h3><p>Body text.</p></div>
</div>
```

### Code block

```html
<pre class="code"><code>your code or command here</code></pre>
```

### Key-value metadata

```html
<dl style="display:grid;grid-template-columns:auto 1fr;gap:.25rem 1rem;font-size:.9rem">
  <dt style="color:var(--cq);font-family:var(--f-m)">Key</dt><dd style="color:var(--cm)">Value</dd>
</dl>
```

### Status badge

```html
<span style="background:var(--cab);color:var(--ca);font-size:.7rem;font-family:var(--f-m);letter-spacing:.08em;text-transform:uppercase;padding:.15rem .5rem;border-radius:4px;font-weight:600">STATUS</span>
```

### Stat block

Large metric + label — for dashboards, KPI summaries, and key numbers.

```html
<div class="stats">
  <div class="stat"><span class="sn">1,248</span><span class="sl">Requests/sec</span></div>
  <div class="stat"><span class="sn">42ms</span><span class="sl">P50 latency</span></div>
  <div class="stat"><span class="sn">99.9%</span><span class="sl">Uptime</span></div>
</div>
```

Additional CSS:

```css
.stats{display:flex;gap:1rem;flex-wrap:wrap;margin:1.5rem 0}
.stat{background:var(--cs);border:1px solid var(--cbr);border-radius:8px;padding:1.25rem 1.5rem;min-width:140px}
.sn{display:block;font-family:var(--f-h);font-size:2.5rem;font-weight:400;color:var(--ca);line-height:1}
.sl{display:block;font-family:var(--f-m);font-size:.75rem;letter-spacing:.08em;text-transform:uppercase;color:var(--cq);margin-top:.4rem}
```

### Timeline

Chronological event sequence — for roadmaps, incident timelines, and release notes.

```html
<ol class="tl">
  <li class="tli">
    <span class="tld"></span>
    <div><time class="tlt">2026-05-01</time><strong>Event title</strong><p>Description of what happened.</p></div>
  </li>
  <li class="tli">
    <span class="tld"></span>
    <div><time class="tlt">2026-05-15</time><strong>Second event</strong><p>Description.</p></div>
  </li>
</ol>
```

Additional CSS:

```css
.tl{list-style:none;padding:0;margin:1.5rem 0}
.tli{display:flex;gap:1rem;padding-bottom:1.5rem;position:relative}
.tli:not(:last-child)::before{content:'';position:absolute;left:7px;top:16px;bottom:0;width:1px;background:var(--cbr)}
.tld{width:15px;height:15px;border-radius:50%;background:var(--ca);flex-shrink:0;margin-top:4px}
.tlt{display:block;font-family:var(--f-m);font-size:.75rem;color:var(--cq);margin-bottom:.2rem}
```

### Numbered procedure

Visual steps with circle numbers — for tutorials, runbooks, and setup guides.

```html
<ol class="sps">
  <li class="step">
    <span class="spn">1</span>
    <div class="sbd"><h3>First step</h3><p>What to do and why.</p></div>
  </li>
  <li class="step">
    <span class="spn">2</span>
    <div class="sbd"><h3>Second step</h3><p>Continue here.</p></div>
  </li>
</ol>
```

Additional CSS:

```css
.sps{list-style:none;padding:0;margin:1.5rem 0}
.step{display:flex;gap:1rem;margin-bottom:1.5rem}
.spn{width:32px;height:32px;border-radius:50%;background:var(--ca);color:#fff;font-family:var(--f-m);font-size:.875rem;font-weight:600;display:flex;align-items:center;justify-content:center;flex-shrink:0;margin-top:2px}
.sbd{flex:1}
.sbd h3{margin-bottom:.25rem}
```

### Before / after split

Two-column comparison — for code migrations, config changes, and before/after states.

```html
<div class="spl">
  <div>
    <span class="slbl split-before">Before</span>
    <pre class="code">old value or code</pre>
  </div>
  <div>
    <span class="slbl split-after">After</span>
    <pre class="code">new value or code</pre>
  </div>
</div>
```

Additional CSS:

```css
.spl{display:grid;grid-template-columns:1fr 1fr;gap:1rem;margin:1.5rem 0}
@media(max-width:600px){.spl{grid-template-columns:1fr}}
.slbl{display:inline-block;font-family:var(--f-m);font-size:.7rem;letter-spacing:.1em;text-transform:uppercase;padding:.15rem .5rem;border-radius:4px;margin-bottom:.5rem}
.slb{background:var(--cw-bg);color:var(--cw)}
.sla{background:var(--cg-bg);color:var(--cg)}
```

### Collapsible section

Native `<details>`/`<summary>` — no JS needed. Use for supplementary details, long appendices, or optional reading.

```html
<details class="clp">
  <summary class="clph">Section title (click to expand)</summary>
  <div class="clpb">
    <p>Content revealed on expand. Can contain any floreo components.</p>
  </div>
</details>
```

Additional CSS:

```css
.clp{border:1px solid var(--cbr);border-radius:8px;margin:1rem 0}
.clph{padding:.75rem 1rem;cursor:pointer;font-weight:600;list-style:none;display:flex;justify-content:space-between;align-items:center;color:var(--ct)}
.clph::-webkit-details-marker{display:none}
.clph::after{content:'▸';color:var(--cq);font-size:.85rem}
details[open]>.clph::after{content:'▾'}
.clpb{padding:1rem 1.25rem;border-top:1px solid var(--cbr)}
```

### Diff table

Red/green row highlighting — for changelogs, migrations, and schema diffs. Extends `.tbl`; include the standard table CSS.

```html
<div class="tw"><table class="tbl">
<thead><tr><th>Field</th><th>Old</th><th>New</th></tr></thead>
<tbody>
<tr class="da"><td>status</td><td>—</td><td>active</td></tr>
<tr class="dr"><td>legacy_id</td><td>usr_1234</td><td>—</td></tr>
<tr class="dc"><td>role</td><td>viewer</td><td>editor</td></tr>
</tbody>
</table></div>
```

Additional CSS:

```css
.da{background:#f0fdf4}.da td:first-child{border-left:3px solid var(--cg)}
.dr{background:#fff1f2}.dr td:first-child{border-left:3px solid #ef4444}
.dc{background:var(--cw-bg)}.dc td:first-child{border-left:3px solid var(--cw)}
```

### Table of contents

Auto-generated from `<h2>` headings via ~20 lines of JS. Place near the top of `<main>`, before the first `<section class="sc">`.

**Default rule:** include when the document has 4 or more `<h2>` sections. Declare this in the Content Plan's `INTERACTIVE:` field as `toc`.

**Responsive layout:** on viewports ≥1100px the ToC moves into a sticky right-hand sidebar alongside the document body — it stays visible no matter how far the user scrolls. On narrower viewports it renders inline as a card.

```html
<nav class="toc" aria-label="Contents">
  <p class="toch">Contents</p>
  <ol id="toc-list" class="tocl"></ol>
</nav>
```

Additional CSS:

```css
.toc{background:var(--cs);border:1px solid var(--cbr);border-radius:8px;padding:1.25rem 1.5rem;margin:1.5rem 0;display:inline-block;min-width:220px}
.toch{font-family:var(--f-m);font-size:.75rem;letter-spacing:.08em;text-transform:uppercase;color:var(--cq);margin-bottom:.5rem}
.tocl{padding-left:1.25rem;margin:0}
.tocl li{margin-bottom:.2rem}
.tocl a{color:var(--cm);font-size:.9rem;text-decoration:none;display:block;padding:.15rem .25rem;border-radius:3px}
.tocl a:hover,.tocl a.active{color:var(--ca);background:var(--cab)}
@media(min-width:1100px){.pg{max-width:1080px}main{display:grid;grid-template-columns:1fr 220px;gap:0 3rem;align-items:start}.toc{grid-column:2;grid-row:1/999;position:sticky;top:2rem;margin:0;display:block}.sc{grid-column:1}}
@media print{main{display:block}.toc{display:none}}
```

JS (add to the `<script>` block):

```js
(function(){
  const list=document.getElementById('toc-list');
  if(!list)return;
  document.querySelectorAll('main h2').forEach((h,i)=>{
    if(!h.id)h.id='s'+i;
    const li=document.createElement('li');
    li.innerHTML='<a href="#'+h.id+'">'+h.textContent+'</a>';
    list.appendChild(li);
  });
  const obs=new IntersectionObserver(entries=>{
    entries.forEach(e=>{
      const a=list.querySelector('a[href="#'+e.target.id+'"]');
      if(a)a.classList.toggle('active',e.isIntersecting);
    });
  },{rootMargin:'-10% 0px -75% 0px'});
  document.querySelectorAll('main h2').forEach(h=>obs.observe(h));
})();
```

---

## SVG Charts and Diagrams

Use inline SVG for all charts, diagrams, and illustrations. Never embed raster images for data visualization.

**SVG rules:**
- `viewBox="0 0 W H"` — no fixed `width`/`height` on the `<svg>` element; CSS controls size
- Use `fill="var(--ca)"` and other CSS variables inside SVG
- Include `<title>` for accessibility
- Keep coordinates clean (integer pixels, consistent scale)

### Bar chart pattern

```html
<figure class="fig">
<svg viewBox="0 0 400 220" xmlns="http://www.w3.org/2000/svg">
  <title>Chart title</title>
  <!-- Y-axis gridlines -->
  <line x1="40" y1="10" x2="40" y2="180" stroke="var(--cbr)" stroke-width="1"/>
  <!-- Bars -->
  <rect x="60" y="80" width="40" height="100" fill="var(--ca)" rx="3"/>
  <rect x="120" y="50" width="40" height="130" fill="var(--ca)" opacity=".7" rx="3"/>
  <!-- Labels -->
  <text x="80" y="195" text-anchor="middle" font-size="12" fill="var(--cm)">Label A</text>
  <text x="140" y="195" text-anchor="middle" font-size="12" fill="var(--cm)">Label B</text>
</svg>
<figcaption>Caption describing what this chart shows</figcaption>
</figure>
```

### Flow diagram pattern

```html
<figure class="fig">
<svg viewBox="0 0 500 120" xmlns="http://www.w3.org/2000/svg">
  <title>Flow diagram</title>
  <!-- Box -->
  <rect x="10" y="40" width="120" height="40" rx="6" fill="var(--cab)" stroke="var(--ca)" stroke-width="1.5"/>
  <text x="70" y="65" text-anchor="middle" font-size="13" fill="var(--ct)">Step One</text>
  <!-- Arrow -->
  <path d="M130 60 L180 60" stroke="var(--cq)" stroke-width="1.5" fill="none" marker-end="url(#arr-1)"/>
  <!-- Arrowhead marker — use a unique ID per figure (arr-1, arr-2, …) to avoid ID collisions when a document has multiple flow diagrams -->
  <defs><marker id="arr-1" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
    <path d="M0,0 L0,6 L8,3 z" fill="var(--cq)"/>
  </marker></defs>
  <!-- Next box... -->
</svg>
</figure>
```

### Line chart pattern

Use for trends over time or sequential values. The area fill is optional — remove the `<polygon>` for a clean line-only chart.

```html
<figure class="fig">
<svg viewBox="0 0 400 220" xmlns="http://www.w3.org/2000/svg">
<title>Trend over time</title>
<line x1="44" y1="10" x2="44" y2="180" stroke="var(--cbr)" stroke-width="1"/>
<line x1="44" y1="180" x2="390" y2="180" stroke="var(--cbr)" stroke-width="1"/>
<line x1="44" y1="60" x2="390" y2="60" stroke="var(--cbr)" stroke-width="1" stroke-dasharray="4 3"/>
<line x1="44" y1="120" x2="390" y2="120" stroke="var(--cbr)" stroke-width="1" stroke-dasharray="4 3"/>
<!-- Area fill (optional) -->
<polygon points="80,150 150,110 220,75 290,95 360,50 360,180 80,180" fill="var(--ca)" opacity=".08"/>
<!-- Data line — y=10 is top, y=170 is bottom; scale your values to fit -->
<polyline points="80,150 150,110 220,75 290,95 360,50"
  fill="none" stroke="var(--ca)" stroke-width="2" stroke-linejoin="round" stroke-linecap="round"/>
<circle cx="80" cy="150" r="4" fill="var(--ca)"/>
<circle cx="150" cy="110" r="4" fill="var(--ca)"/>
<circle cx="220" cy="75" r="4" fill="var(--ca)"/>
<circle cx="290" cy="95" r="4" fill="var(--ca)"/>
<circle cx="360" cy="50" r="4" fill="var(--ca)"/>
<text x="80" y="198" text-anchor="middle" font-size="11" fill="var(--cm)">Jan</text>
<text x="150" y="198" text-anchor="middle" font-size="11" fill="var(--cm)">Feb</text>
<text x="220" y="198" text-anchor="middle" font-size="11" fill="var(--cm)">Mar</text>
<text x="290" y="198" text-anchor="middle" font-size="11" fill="var(--cm)">Apr</text>
<text x="360" y="198" text-anchor="middle" font-size="11" fill="var(--cm)">May</text>
</svg>
<figcaption>Caption describing the trend this chart shows</figcaption>
</figure>
```

### Donut chart pattern

Use for parts of a whole. Technique: stroke-dasharray on a circle (simpler than arc paths). Formula: `circumference ≈ 283` (for r=45). Each segment: `length = pct × 283`, `offset = -(sum of prior lengths)`. All segments use `transform="rotate(-90 100 100)"` to start at 12 o'clock.

```html
<figure class="fig">
<svg viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
<title>Proportion breakdown</title>
<!-- r=45, circumference≈283. Formula: length=pct×283 | offset=-(sum of prior lengths) -->
<circle cx="100" cy="100" r="45" fill="none" stroke="var(--cs2)" stroke-width="24"/>
<!-- Segment 1: 60% (length=170) — starts at 12 o'clock -->
<circle cx="100" cy="100" r="45" fill="none" stroke="var(--ca)" stroke-width="24"
  stroke-dasharray="170 283" transform="rotate(-90 100 100)"/>
<!-- Segment 2: 25% (length=71) — starts after segment 1 (offset=-170) -->
<circle cx="100" cy="100" r="45" fill="none" stroke="var(--ca)" stroke-width="24" opacity=".5"
  stroke-dasharray="71 283" stroke-dashoffset="-170" transform="rotate(-90 100 100)"/>
<!-- Center hole + label -->
<circle cx="100" cy="100" r="28" fill="var(--cb)"/>
<text x="100" y="96" text-anchor="middle" font-size="20" font-family="Georgia,'Times New Roman',serif" fill="var(--ca)">60%</text>
<text x="100" y="112" text-anchor="middle" font-size="9" font-family="'Courier New',monospace" fill="var(--cq)" letter-spacing="2">PRIMARY</text>
</svg>
<figcaption>Caption describing what the proportions represent</figcaption>
</figure>
```

### Milestone chart pattern

Use for project timelines, release schedules, and roadmaps. Filled circles = complete; open circles = upcoming. Add a TODAY marker (dashed vertical line) to show current progress.

```html
<figure class="fig">
<svg viewBox="0 0 560 100" xmlns="http://www.w3.org/2000/svg">
<title>Project milestones</title>
<line x1="60" y1="38" x2="500" y2="38" stroke="var(--cbr)" stroke-width="2"/>
<!-- Completed milestone -->
<circle cx="120" cy="38" r="8" fill="var(--cg)"/>
<text x="120" y="60" text-anchor="middle" font-size="11" fill="var(--cm)">Phase 1</text>
<text x="120" y="74" text-anchor="middle" font-size="10" font-family="'Courier New',monospace" fill="var(--cq)">May 1</text>
<!-- Completed milestone -->
<circle cx="250" cy="38" r="8" fill="var(--cg)"/>
<text x="250" y="60" text-anchor="middle" font-size="11" fill="var(--cm)">Phase 2</text>
<text x="250" y="74" text-anchor="middle" font-size="10" font-family="'Courier New',monospace" fill="var(--cq)">Jun 15</text>
<!-- TODAY marker -->
<line x1="320" y1="20" x2="320" y2="56" stroke="var(--ca)" stroke-width="1.5" stroke-dasharray="3 2"/>
<text x="320" y="15" text-anchor="middle" font-size="9" font-family="'Courier New',monospace" fill="var(--ca)">TODAY</text>
<!-- Upcoming milestone (open circle) -->
<circle cx="380" cy="38" r="8" fill="var(--cb)" stroke="var(--cbr)" stroke-width="2"/>
<text x="380" y="60" text-anchor="middle" font-size="11" fill="var(--cm)">Phase 3</text>
<text x="380" y="74" text-anchor="middle" font-size="10" font-family="'Courier New',monospace" fill="var(--cq)">Aug 1</text>
<!-- Upcoming milestone -->
<circle cx="470" cy="38" r="8" fill="var(--cb)" stroke="var(--cbr)" stroke-width="2"/>
<text x="470" y="60" text-anchor="middle" font-size="11" fill="var(--cm)">Launch</text>
<text x="470" y="74" text-anchor="middle" font-size="10" font-family="'Courier New',monospace" fill="var(--cq)">Sep 30</text>
</svg>
<figcaption>Project milestones — filled circles complete, open circles planned</figcaption>
</figure>
```

---

## JavaScript

Add JavaScript only for progressive enhancement. The document must be fully readable without it.

Appropriate uses:
- Collapsible sections (`<details>` is often better)
- Tab switching between content panels
- Copy-to-clipboard on code blocks
- Client-side filtering/sorting of large tables
- Scroll-triggered reveals

All JS goes in a single `<script>` block at the end of `<body>`. Vanilla JS only — no external libraries.

```html
<script>
// Tab switching example
document.querySelectorAll('[data-tab]').forEach(btn=>{
  btn.addEventListener('click',()=>{
    const target=btn.dataset.tab;
    document.querySelectorAll('.tab-panel').forEach(p=>p.hidden=p.id!==target);
    document.querySelectorAll('[data-tab]').forEach(b=>b.setAttribute('aria-selected',b===btn));
  });
});
</script>
```

---

## Reading Interface (Optional)

An opt-in ~100-line CSS + JS block that turns a floreo document into a light reading app. **Do not include in the base CSS block** — add only when explicitly useful (long reference docs, stakeholder reports, onboarding guides).

### HTML additions

Add inside `<header class="hd">` (for the export button) and at the start of `<main>` (for search and sticky ToC):

```html
<!-- In header -->
<button class="ri-export">Copy as Markdown</button>

<!-- At start of main, before first section -->
<div class="ri-search"><input type="search" placeholder="Search document…" aria-label="Search"></div>

<!-- Sticky side ToC (CSS shows only on wide viewports) -->
<nav class="ri-toc" aria-label="Contents"><p class="ri-toc-hd">Contents</p><ol></ol></nav>
```

### CSS additions

```css
@media(min-width:1200px){
  .pg{max-width:1100px;display:grid;grid-template-columns:200px 1fr;gap:3rem;align-items:start}
  .hd,.fn{grid-column:1/-1}
  .ri-toc{position:sticky;top:2rem}
  .ri-toc-hd{font-family:var(--f-m);font-size:.7rem;letter-spacing:.1em;text-transform:uppercase;color:var(--cq);margin-bottom:.5rem}
  .ri-toc ol{list-style:none;padding:0;margin:0}
  .ri-toc li{margin-bottom:.2rem}
  .ri-toc a{color:var(--cm);text-decoration:none;display:block;padding:.2rem .5rem;border-radius:4px;font-size:.85rem;transition:background .1s}
  .ri-toc a:hover,.ri-toc a.active{background:var(--cab);color:var(--ca)}
}
@media print{
  .ri-toc,.ri-search,.ri-export{display:none}
  .pg{display:block;max-width:100%}
  h2{page-break-after:avoid}
  .sc{page-break-inside:avoid}
  a[href]{color:inherit;text-decoration:none}
}
.ri-search{margin:1rem 0 1.5rem}
.ri-search input{width:100%;max-width:400px;padding:.4rem .75rem;border:1px solid var(--cbr);border-radius:6px;font-family:var(--f-b);font-size:.9rem;background:var(--cs);color:var(--ct)}
.ri-search input:focus{outline:2px solid var(--ca);outline-offset:1px}
mark.ri-hl{background:var(--cab);color:var(--ct);border-radius:2px;padding:0 1px}
.ri-export{font-family:var(--f-m);font-size:.75rem;color:var(--cq);cursor:pointer;text-decoration:underline dotted;background:none;border:none;padding:0;margin-top:.5rem}
.ri-export:hover{color:var(--ca)}
```

### JS additions

```js
(function(){
  const tocList=document.querySelector('.ri-toc ol');
  const headings=document.querySelectorAll('main h2');
  if(tocList&&headings.length){
    headings.forEach((h,i)=>{
      if(!h.id)h.id='s'+i;
      const li=document.createElement('li');
      li.innerHTML='<a href="#'+h.id+'">'+h.textContent+'</a>';
      tocList.appendChild(li);
    });
    const obs=new IntersectionObserver(entries=>{
      entries.forEach(e=>{
        const a=tocList.querySelector('a[href="#'+e.target.id+'"]');
        if(a)a.classList.toggle('active',e.isIntersecting);
      });
    },{rootMargin:'-10% 0px -75% 0px'});
    headings.forEach(h=>obs.observe(h));
  }
  const inp=document.querySelector('.ri-search input');
  if(inp){
    inp.addEventListener('input',()=>{
      document.querySelectorAll('mark.ri-hl').forEach(m=>{
        const p=m.parentNode;p.replaceChild(document.createTextNode(m.textContent),m);p.normalize();
      });
      const q=inp.value.trim();if(q.length<2)return;
      const re=new RegExp(q.replace(/[.*+?^${}()|[\]\\]/g,'\\$&'),'gi');
      const walker=document.createTreeWalker(document.querySelector('main'),NodeFilter.SHOW_TEXT);
      const nodes=[];while(walker.nextNode())nodes.push(walker.currentNode);
      nodes.forEach(n=>{
        re.lastIndex=0;if(!re.test(n.textContent))return;
        const frag=document.createDocumentFragment();let last=0,m;re.lastIndex=0;
        while((m=re.exec(n.textContent))!==null){
          frag.appendChild(document.createTextNode(n.textContent.slice(last,m.index)));
          const mark=document.createElement('mark');mark.className='ri-hl';mark.textContent=m[0];
          frag.appendChild(mark);last=m.index+m[0].length;
        }
        frag.appendChild(document.createTextNode(n.textContent.slice(last)));
        n.parentNode.replaceChild(frag,n);
      });
    });
  }
  const btn=document.querySelector('.ri-export');
  if(btn)btn.addEventListener('click',()=>{
    const lines=[];
    document.querySelectorAll('main h2,main h3,main p,main li').forEach(el=>{
      if(el.tagName==='H2')lines.push('\n## '+el.textContent);
      else if(el.tagName==='H3')lines.push('\n### '+el.textContent);
      else if(el.tagName==='P')lines.push(el.textContent);
      else if(el.tagName==='LI')lines.push('- '+el.textContent);
    });
    navigator.clipboard.writeText(lines.join('\n')).then(()=>{
      btn.textContent='Copied!';setTimeout(()=>btn.textContent='Copy as Markdown',2000);
    });
  });
})();
```

---

## Markup Subagent Prompt

When spawning the markup phase as a subagent, use the most token-efficient model available (currently `model="haiku"`). Use this prompt:

```
You are composing a self-contained HTML document using the floreo design system.

INPUT: The structured content plan below.

REQUIREMENTS:
1. Output a COMPLETE, VALID HTML file — nothing else. No explanation, no markdown fences.
2. Single file: all CSS inline in <style>, all JS inline in <script>, no external resources.
3. Use floreo class names: .pg .hd .fn .sc .card .tbl .tw .note .warn .tip .fig .code .grid
4. Use the floreo base CSS block exactly as provided. Add document-specific rules after it.
5. Use CSS variables (--ca, --cb, --cs, --cbr, --ct, --cm, --cq, --cab) — never hardcode colors.
6. COMPRESSION — source is read by agents and LLMs, never by humans. Humans see only the rendered page. Apply ALL rules with no exceptions:
   - No indentation. Zero leading spaces or tabs before any element.
   - No whitespace between tags. Write <ul><li>One<li>Two</ul> not a newline-indented list.
   - Omit optional closing tags: </p> </li> </td> </tr> </th> </thead> </tbody>
   - No HTML comments. Never write <!-- anything --> in output.
   - Boolean attributes without values: write disabled not disabled="disabled".
   - CSS shorthand throughout: margin:0 1rem not four margin properties; padding:.6rem 1rem not two.

COMPRESSION EXAMPLE:

BEFORE (wrong — do not produce this):
<table>
  <thead>
    <tr>
      <th>Name</th>
      <th>Value</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Alpha</td>
      <td>1</td>
    </tr>
  </tbody>
</table>
<ul>
  <li>First item</li>
  <li>Second item</li>
</ul>
<p>Some prose here.</p>

AFTER (correct — produce this):
<table><thead><tr><th>Name<th>Value<tbody><tr><td>Alpha<td>1</table>
<ul><li>First item<li>Second item</ul>
<p>Some prose here.

7. SVG for any charts or diagrams (inline, viewBox only — no fixed width/height). Match chart type to data: bar chart for comparisons, line chart for trends, donut (stroke-dasharray technique) for proportions, `.tl` timeline for events, milestone SVG for phases. Implement the `INTERACTIVE` field from the Content Plan: `toc` → add `.toc` nav block + JS; `collapsible` → use `<details class="clp">`; `tabs` → use the tab JS pattern; `search` → use the search input + JS from the Reading Interface section.
8. Semantic HTML5 elements (header, main, section, footer, figure) to reduce class overhead.
9. <meta viewport> present. max-width on .pg for readability.
10. Set --ca to the accent color specified in the content plan.
11. Add floreo meta tags: <meta name="floreo:type">, <meta name="floreo:created">, <meta name="floreo:model">, <meta name="floreo:version" content="1">.
12. Embed the full Content Plan verbatim in <script type="application/floreo" id="content-plan"> immediately before </body>.

FLOREO BASE CSS (copy verbatim from the "## Base CSS Block" section of the floreo skill you loaded):
<insert the full contents of the ```css block from ## Base CSS Block here>

CONTENT PLAN:
<insert your full Content Plan here>
```

**Important**: Do not pass the angle-bracket placeholders literally. Replace them with the actual CSS block and actual Content Plan before sending to Haiku. The CSS block is in this skill document under `## Base CSS Block` — copy it exactly.

---

## Quality Checklist

Before writing the final file:

- [ ] File size within per-template budget (run `wc -c <file>.html`; see Self-containment table for limits)
- [ ] Self-contained — no external dependencies
- [ ] `<title>` is meaningful and specific
- [ ] Floreo meta tags present (`floreo:type`, `floreo:created`, `floreo:model`, `floreo:version`)
- [ ] Accent color (`--ca`) matches document purpose
- [ ] Visual hierarchy is clear: h1 > h2 (Georgia) → h3 (system-ui), spacing creates sections
- [ ] `h3`/`h4` use `--f-b` (system-ui), NOT `--f-h` (Georgia) — Serif Authority Rule
- [ ] Callouts use background-tint only — no `border-left` accent stripe
- [ ] Dark mode overrides present for `--cab`, `--cw-bg`, `--cg-bg` in the dark media query
- [ ] Tables used for comparative data (not prose lists)
- [ ] Callouts (`.note`, `.warn`, `.tip`) surface key insights
- [ ] SVG chart present for any section with 3+ quantitative data points — a table alone is not sufficient for magnitude or trend data
- [ ] `INTERACTIVE` field from Content Plan implemented — ToC present if 4+ sections, collapsible/tabs/search added if declared
- [ ] CSS variables used throughout (no hardcoded hex values)
- [ ] Mobile-responsive (`<meta viewport>` present, `max-width` on `.pg`)
- [ ] JS (if any) degrades gracefully without it
- [ ] Content Plan embedded in `<script type="application/floreo" id="content-plan">` before `</body>`

---

## Updating an Existing Floreo Document

When a floreo document needs new content, a corrected section, or a data refresh:

1. **Recover the Content Plan** — read `<script type="application/floreo" id="content-plan">` from the existing file. If present, use it directly as Phase 1 input (skip re-deriving structure from markup). If absent, extract structure by scanning `<h2>` headings.
2. **Produce an updated Content Plan** — add, remove, or edit sections in the recovered plan
3. **Regenerate via Phase 2** — pass the updated Content Plan to Haiku; produce a complete new HTML file
4. **Write as a new version** — use the `-v2` / `-v3` suffix convention; do not overwrite unless the user explicitly asks

Do not surgically edit compressed HTML markup by hand. The cost of a full regeneration is low and the result is clean. The original file serves as a fallback until the new version is confirmed.

---

## Reference Example

`reference/agent-skill-floreo-name.html` in this repository is an example of floreo-quality output: a naming research document with candidate cards, comparison table, etymology section, and decision banner — all self-contained, visually refined, and fully readable.

## Integration

**With `frontend-design`**: For presentations and stakeholder documents where aesthetic quality is the primary concern, load `frontend-design` first. It provides creative aesthetic direction; floreo provides document structure and agent-optimized markup conventions. They are complementary.
