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

The `floreo` skill is immediately available in any project.

### Local development

To test from a local clone without pushing:

```bash
claude --plugin-dir /path/to/agent-skill-floreo
```

Use `/reload-plugins` after editing skill files to pick up changes without restarting.

---

## Usage

### Manual — invoke explicitly

Call the skill before writing a document:

```
/floreo
```

Then describe what you want. The agent will produce a structured Content Plan and compose a complete `.html` file written to `docs/`.

### Automatic — set-and-forget per project

Run once in any project to embed an auto-invoke rule in `CLAUDE.md`:

```
/floreo:setup
```

After that, the agent uses floreo automatically for any human-readable output in that project — no explicit invocation needed.

---

## How it works

Floreo uses a two-phase approach to keep token costs low:

**Phase 1 — Content** (current model)
Think: who reads this, what's the hierarchy, what needs visual treatment. Write a structured Content Plan.

**Phase 2 — Markup** (efficient subagent, currently Haiku)
Compose the HTML from the Content Plan. Mechanical work delegated to the cheapest capable model.

Output: a single `.html` file with all CSS and JS inline. No CDN. No external fonts. Opens offline.

---

## Design system highlights

- **System fonts** — no external load, instant render
- **CSS custom properties** — `--ca` (accent), `--cb` (background), `--cs` (surface), `--ct` (text), and more; swap accent color by document type
- **Dark mode** — automatic via `@media (prefers-color-scheme: dark)`
- **Component library** — tables, cards, callouts, code blocks, stat blocks, timelines, numbered steps, before/after splits, collapsible sections, diff tables, table of contents
- **SVG charts** — inline bar charts and flow diagrams; no raster images
- **Optional reading interface** — sticky ToC, print styles, in-doc search, copy-as-Markdown export (~100 lines, opt-in)

---

## Document anatomy

Every floreo document includes:

- `<meta name="floreo:type|created|model|version">` — machine-readable metadata for cataloging and discovery
- `data-floreo-id` on every `<section>` — stable IDs for diffs and deep-links across versions
- `<script type="application/floreo" id="content-plan">` — the original Content Plan, embedded for future agent updates

---

## License

MIT
