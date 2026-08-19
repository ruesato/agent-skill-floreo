---
name: draft
description: >
  Produce a floreo markdown draft file — the lightweight source format for
  iterating on content before final HTML rendering. Use when content is still
  being shaped or will go through multiple revision rounds. Humans and agents
  can edit the .md file freely; render to polished HTML any time with /floreo.
  Do NOT use for files that tools or agents parse as plain text (README.md,
  CLAUDE.md, SKILL.md, steering files, config files, etc.).
---

# Floreo Draft

Produce a floreo markdown file — the source format for iterating on content before rendering. Write prose in clean markdown, declare rich elements as intent blocks, annotate anything with `<hint>` tags. Render to polished HTML via `/floreo` when the content is ready.

## When to invoke

Use `/floreo:draft` when content needs iteration:
- Structure is still being decided
- Multiple revision rounds are expected  
- A human will edit the file between agent rounds
- You want to outline or draft before committing to final markup

Use `/floreo` (render) when:
- The draft is close to final and you want the polished HTML artifact
- You are rendering an existing floreo markdown file

## Output

Write to `docs/[kebab-case-slug].md`. Derive the slug from the document title. The file is plain text — open and edit in any editor.

---

## Floreo Markdown Format

### Frontmatter

Every floreo markdown file begins with YAML frontmatter:

```yaml
---
title: Document Title
type: report            # report | analysis | plan | proposal | incident | retrospective | brief | tutorial
accent: technical       # technical | warning | success | planning | research
interactive: toc        # toc | search | collapsible | tabs | none  (comma-separated)
author: Name            # optional
date: YYYY-MM-DD        # optional, ISO 8601
---
```

**`accent`** maps to the document's color palette when rendered:

| Value | Color | Use for |
|---|---|---|
| `technical` | Blue `#2563eb` | Engineering, default |
| `warning` | Red `#dc2626` | Incidents, risks |
| `success` | Green `#16a34a` | Completions, wins |
| `planning` | Purple `#7c3aed` | Strategy, roadmaps |
| `research` | Cyan `#0891b2` | Analysis, comparisons |

**`interactive`** lists reading interface features to enable on render. `toc` is added automatically when there are 4+ sections; others are opt-in. Use `none` to suppress.

---

### Prose

Standard markdown throughout: headings, paragraphs, lists, tables, inline code, bold, italic. Use `##` for top-level sections and `###` for subsections. Do **not** write HTML directly in draft files — use intent blocks for rich elements.

---

### Intent Blocks

Rich elements are declared as **intent blocks** using fenced code syntax. The render agent implements them as polished HTML components. You do not need complete data to declare an intent block — a placeholder with a hint is fine.

#### Charts

```
```chart:bar
title: Revenue by Quarter
labels: [Q1, Q2, Q3, Q4]
data: [42000, 58000, 71000, 63000]
unit: $
```
```

```
```chart:bar-h
title: Top Products by Units Sold
labels: [Widget A, Widget B, Widget C]
data: [1240, 890, 560]
```
```

```
```chart:line
title: Weekly Active Users
labels: [Wk 1, Wk 2, Wk 3, Wk 4]
data: [1200, 1450, 1380, 1620]
```
```

```
```chart:donut
title: Revenue by Segment
labels: [Enterprise, Mid-market, SMB]
data: [62, 28, 10]
unit: %
```
```

```
```chart:milestone
phases: [Discovery, Design, Build, Launch]
dates: [Jan, Feb, Mar–Apr, May]
current: Build
```
```

#### Diagrams

```
```diagram:flow
User submits form → Validate input → Save to DB → Send confirmation email
```
```

```
```diagram:timeline
2025-Q1: Project kickoff
2025-Q2: Beta launch
2025-Q3: GA release
2025-Q4: v2.0 planning
```
```

#### Document Components

```
```callout:info
Use for neutral supplementary information.
```
```

```
```callout:warning
Use for risks, caveats, or things requiring attention.
```
```

```
```callout:success
Use for wins, completions, or positive outcomes.
```
```

```
```stat-block
Revenue: $2.4M
Growth: +18% YoY
NPS: 72
Churn: 3.2%
```
```

```
```decision-table
options: [Option A, Option B, Option C]
criteria:
  Cost:  [Low, High, Medium]
  Speed: [Fast, Slow, Medium]
  Risk:  [Medium, Low, High]
recommendation: Option A
```
```

```
```steps
Install the CLI
Authenticate with your account
Initialize the project
Run the dev server
```
```

---

### Hints

Annotate any element — intent block or prose — with a `<hint>` tag. The render agent reads every hint and applies it during HTML generation. Hints are stripped from the final HTML output.

**Tracking hint state during revision cycles** — add a `status` attribute to mark whether a hint has been acted on. This lets you see at a glance what's still pending vs. resolved when reviewing a draft across multiple render rounds.

| Status | When to use | Render behavior |
|---|---|---|
| *(none)* | Default — no decision yet | Apply normally, strip from HTML |
| `pending` | Not yet acted on (explicit) | Apply normally, strip from HTML |
| `approved` | Accepted — apply as written | Apply normally, strip from HTML |
| `resolved` | Addressed by editing content directly | Strip without applying |
| `rejected` | Considered and declined | Preserve as `<!-- floreo:hint (rejected): … -->` comment |

**Inline hint inside a block:**

```
```chart:bar
labels: [Q1, Q2, Q3, Q4]
data: [42, 58, 71, 63]
<hint>horizontal layout, muted palette, highlight Q3 as the peak</hint>
```
```

**Multi-line hint inside a block:**

```
```diagram:flow
Login → Validate → Dashboard
<hint>
Omit the Validate step.
Expose step descriptions on hover.
Keep the diagram minimal — no more than 4 nodes.
</hint>
```
```

**Prose hint — placed before or after the target:**

```markdown
## Executive Summary

<hint>Lead with the win. Two sentences max. Cut any hedging language.</hint>

Content here...
```

```markdown
| Region | Q1  | Q2  |
|--------|-----|-----|
| North  | 42  | 58  |

<hint>Sort by Q2 descending. Add a totals row.</hint>
```

**Marking a hint as resolved** — you fixed the underlying issue yourself by editing the content, so the hint is no longer needed:

```markdown
<hint status="resolved">Restructure this section as a numbered priority list.</hint>
```

The render agent strips the hint without applying it — the content already reflects the change.

**Marking a hint as approved** — you accept the hint and want it applied as written:

```markdown
<hint status="approved">Sort by Q2 descending. Add a totals row.</hint>
```

**Marking a hint as rejected** — you considered the hint but it doesn't apply. An optional `reason` attribute records why:

```markdown
<hint status="rejected" reason="audience is non-technical, numbered priorities would add noise">Restructure as a numbered priority list.</hint>
```

The render agent preserves the hint as `<!-- floreo:hint (rejected): Restructure as a numbered priority list. — audience is non-technical … -->` so the decision is visible in the rendered output.

**Legacy: `applied="false"`** — the original mechanism for skipping a hint during render. Still supported as an alias for `status="rejected"` (without a reason). Prefer `status="rejected"` in new drafts for the clearer semantics.

```markdown
<hint applied="false">Restructure this section as a numbered priority list once the rankings are confirmed.</hint>
```

---

## Drafting Guidelines

- **Write prose first.** Block types and hints can be added or refined at any point; content quality comes first.
- **Placeholder blocks are fine.** Declare intent even without complete data: a `chart:bar` with a note like "data TBD" signals the visual intent without blocking progress.
- **Hint where you have a strong opinion.** Omit hints where you trust the render agent's judgment — the agent will make good choices for unmarked blocks.
- **Use `status` to track hint decisions.** Mark hints `resolved` when you've handled them yourself, `approved` when you want them applied, or `rejected` when they don't apply. Leave hints without a status (or `pending`) when you haven't decided yet. This makes revision-round reviews faster — you can see at a glance what's been acted on.
- **Frontmatter `interactive:` is a suggestion.** The render agent may add or remove features based on actual content (e.g., `toc` is always added for 4+ sections regardless of the frontmatter value).
- **One file per document.** Don't split a single logical document across multiple draft files.
