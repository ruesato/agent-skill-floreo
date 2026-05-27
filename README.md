# floreo

*floreo* — Latin: I flower. I bloom. I flourish.

A Claude Code skill that turns agent-created content into polished, self-contained HTML documents. Agents write the markup; you see the rendered page.

---

## Why

Agents default to Markdown. Markdown is fine for source control, but it's a poor reading surface: no visual hierarchy, no tables that scan easily, no charts, no sidebar navigation, no print layout. For anything a human actually reads — a report, a plan, a post-incident review — it undersells the content.

Floreo gives every agent output a consistent visual layer: a design system with typography, color tokens, dark mode, responsive layout, and a component library (tables, cards, timelines, code blocks, callouts, stat blocks, flow diagrams). The result is a single `.html` file with no external dependencies that opens instantly in any browser and looks like it was made by a designer.

Secondary benefit: the HTML is also structured for agents. Stable `data-floreo-id` section attributes enable section-level diffs. Embedded `<meta floreo:*>` tags make documents grep-able and catalog-able. A `<script type="application/floreo">` block preserves the original Content Plan so future agents can update the document without reverse-engineering markup.

---

## What it produces

Any document type an agent generates:

| Template | Use case |
|---|---|
| Report / Summary | Analysis, research brief, findings |
| Architecture Decision Record | Technical decisions with context |
| Incident Report | Post-mortems with timeline and action items |
| Sprint Retrospective | Team health, velocity, action items |
| Onboarding Guide | Step-by-step setup for new team members |
| API Reference | Endpoint docs with request/response examples |
| Project Proposal | Problem, solution, metrics, timeline, risks |
| Agent Brief | Multi-agent context handoff |
| Session-Close Summary | End-of-session context for the next agent |

---

## Install

Claude Code plugins require a two-step install: register the marketplace, then install the plugin.

```
/plugin marketplace add ruesato/agent-skill-floreo
/plugin install floreo@floreo
```

This installs floreo at user scope (available in every project). To limit to a single project, add `--scope project` to the install command.

Both `/floreo` and `/floreo:draft` are available immediately in any Claude Code session.

### Local development

To test from a local clone without publishing:

```bash
claude --plugin-dir /path/to/agent-skill-floreo
```

Use `/reload-plugins` after editing skill files to pick up changes without restarting.

---

## Usage

### One-shot — invoke and render directly

Call the skill before writing a document:

```
/floreo
```

Then describe what you want. The agent produces a structured Content Plan and composes a complete `.html` file written to `docs/`.

### Two-phase — draft first, render when ready

For documents that need iteration — multiple revision rounds, human edits between passes, or content that isn't fully decided yet — use the draft workflow:

**Step 1: Draft**

```
/floreo:draft
```

The agent produces a floreo markdown file (`docs/[slug].md`) — clean prose, intent blocks for rich elements, no HTML boilerplate. Edit it freely by hand or ask the agent to revise sections. Token-efficient: no template overhead during iteration.

**Step 2: Render**

```
/floreo docs/[slug].md
```

When the content is close to final, pass the draft file to `/floreo`. The render agent converts every intent block to a polished HTML component, applies any hints, and writes `docs/[slug].html`.

### Automatic — set-and-forget per project

Run once in any project to embed an auto-invoke rule in `CLAUDE.md`:

```
/floreo:setup
```

After that, the agent uses floreo automatically for any human-readable output in that project — no explicit invocation needed.

---

## Floreo Markdown Format

Floreo markdown is the source format for the draft workflow. It is plain markdown with three additions:

### Frontmatter

```yaml
---
title: Q1 Performance Review
type: report            # report | analysis | plan | proposal | incident | retrospective | brief | tutorial
accent: technical       # technical | warning | success | planning | research
interactive: toc        # toc | search | collapsible | tabs | none
date: 2026-05-27        # optional
author: Name            # optional
---
```

### Intent blocks

Rich elements are declared as fenced intent blocks. The render agent implements them:

````markdown
```chart:bar
title: Revenue by Quarter
labels: [Q1, Q2, Q3, Q4]
data: [42000, 58000, 71000, 63000]
unit: $
```

```diagram:flow
User submits form → Validate input → Save to DB → Send confirmation
```

```callout:warning
Churn increased 12% in the SMB segment.
```

```stat-block
Revenue: $2.4M
Growth: +18% YoY
NPS: 72
```
````

**Supported block types:** `chart:bar`, `chart:bar-h`, `chart:line`, `chart:donut`, `chart:milestone`, `diagram:flow`, `diagram:timeline`, `callout:info`, `callout:warning`, `callout:success`, `stat-block`, `decision-table`, `steps`

### Hints

Annotate any element with `<hint>` to give the render agent implementation instructions. Hints are stripped from the final HTML.

```markdown
```chart:bar
labels: [Q1, Q2, Q3, Q4]
data: [42, 58, 71, 63]
<hint>horizontal layout, muted palette, highlight Q3 as the peak</hint>
```
```

```markdown
## Executive Summary

<hint>Lead with the win. Two sentences max. Cut any hedging.</hint>

Content here...
```

Mark a hint as `applied="false"` to skip it during the current render and preserve it as a comment in the HTML for the next pass:

```markdown
<hint applied="false">Restructure as a numbered list once rankings are confirmed.</hint>
```

---

## How it works

### One-shot path

**Phase 1 — Content** (current model): Understand audience and purpose. Determine information hierarchy. Choose visual treatment for each data-heavy section. Write a structured Content Plan.

**Phase 2 — Markup** (efficient subagent, currently Haiku): Compose the HTML from the Content Plan. Mechanical work delegated to the cheapest capable model.

### Two-phase path

**Draft phase** (`/floreo:draft`): Produce a floreo markdown file. Pure content — no template overhead. Edit in any text editor or iterate with the agent. `<hint>` tags capture implementation intent inline.

**Render phase** (`/floreo [file.md]`): Read the draft, process intent blocks into HTML components, apply hints, compose the full floreo template. Unapplied hints (`applied="false"`) are preserved as HTML comments for subsequent rounds.

Output (both paths): a single `.html` file with all CSS and JS inline. No CDN. No external fonts. Opens offline.

---

## Design system highlights

- **System fonts** — no external load, instant render
- **CSS custom properties** — `--ca` (accent), `--cb` (background), `--cs` (surface), `--ct` (text), and more; swap accent color by document type
- **Dark mode** — automatic via `@media (prefers-color-scheme: dark)`
- **Component library** — tables, cards, callouts, code blocks, stat blocks, timelines, numbered steps, before/after splits, collapsible sections, diff tables, table of contents
- **SVG charts** — inline bar charts, line charts, donut charts, flow diagrams, milestone charts; no raster images
- **Optional reading interface** — sticky ToC, in-doc search with match navigation, copy-as-Markdown export

---

## Document anatomy

Every floreo document includes:

- `<meta name="floreo:type|created|model|version">` — machine-readable metadata for cataloging and discovery
- `data-floreo-id` on every `<section>` — stable IDs for diffs and deep-links across versions
- `<script type="application/floreo" id="content-plan">` — the original Content Plan, embedded for future agent updates

---

## License

MIT
