---
name: floreo
description: >
  Transform agent-created content into beautiful, self-contained HTML documents
  optimized for human visual consumption. Invoke whenever an agent creates
  documentation, reports, summaries, plans, analyses, or any content that
  humans will read.
---

# Floreo

*floreo* — Latin: I flower. I bloom. I flourish.

Turn raw content into polished, self-contained HTML. Agents write the markup; humans see the rendered page. The same information, arranged so its meaning can finally be seen.

## When to Invoke

Use floreo for **any agent-created content that humans will read**:

- Reports · summaries · analyses
- Technical documentation · architecture docs
- Plans · proposals · design decisions
- Research · comparisons · tutorials
- Meeting notes · project updates

**Default rule**: If a human reads it, floreo it. Markdown is for source control. HTML is for reading.

**Minimum threshold** — use floreo when the content has at least two of:
- Multiple sections (three or more headings)
- A table, chart, or diagram
- Content that must persist beyond the current conversation
- An audience beyond the immediate user (shared docs, stakeholder reports)

Do NOT floreo: short conversational answers, inline code explanations, quick status updates (1–3 sentences), or content destined to be embedded in another system (Notion, Confluence, GitHub comments).

## Two-Phase Composition

Phase 1 and Phase 2 may run sequentially in a single agent, or Phase 2 may be delegated to a Haiku subagent for token efficiency.

### Phase 1 — Content (current model)

The current model does the thinking work:

1. Understand the audience and purpose of this document
2. Determine the information hierarchy (what's primary, secondary, metadata)
3. Identify what needs visual treatment: tables for comparisons, callouts for warnings, code blocks, SVG charts for quantitative data
4. Write all prose, headings, and data in structured form
5. Produce a **Content Plan** (see format below)

### Phase 2 — Markup (Haiku subagent preferred)

Compose the HTML from the Content Plan. Haiku handles mechanical markup composition efficiently.

**If the Agent tool is available**, spawn a Haiku subagent:

```
Use the Agent tool with model="haiku".

Prompt: [paste the HAIKU SUBAGENT PROMPT from the resources section]
Provide: the full Content Plan as input.
```

**If the Agent tool is unavailable**, compose the markup in the current model using the same guidelines.

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
- [describe any charts, diagrams, or figures needed with their data]

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

For **figure** sections, describe the data and the chart type:

```
4. Response time by region — figure
   TYPE: bar chart
   DATA: us-east=12ms, eu-west=34ms, ap-southeast=78ms
   CAPTION: P50 latency measured over 7-day window
```

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

Everything lives in one `.html` file. No exceptions unless the user explicitly requests otherwise:

- All CSS in `<style>` within `<head>`
- All JavaScript in `<script>` at the end of `<body>`
- All images as inline SVG or base64 data URIs
- No `<link rel="stylesheet">` to external files
- No CDN imports or `import` statements

### Markup optimization

Markup is written for agent efficiency, not human readability of source:

- **Short class names**: `.hd`, `.bd`, `.fn`, `.sc`, `.card`, `.note`, `.warn`, `.tip`, `.fig`, `.tbl`, `.code`, `.grid`
- **Compressed CSS**: minimal whitespace; combine selectors; use shorthand
- **Omit optional attributes**: no `type="text/javascript"`, no `type="text/css"`
- **Semantic HTML5**: use `<header>`, `<main>`, `<section>`, `<article>`, `<aside>`, `<footer>`, `<figure>`, `<figcaption>`, `<nav>` to reduce class overhead
- **No redundant wrappers**: nest elements directly when a wrapper adds no semantic or layout value

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

Use `--f-h` for headings and display text. Use `--f-b` for body copy. Use `--f-m` for code, metadata, labels, eyebrows.

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

Common accent values by document type:
- Technical / default: `#2563eb` (blue)
- Warning / incident: `#dc2626` (red)
- Success / completion: `#16a34a` (green)
- Planning / strategy: `#7c3aed` (violet)
- Research / analysis: `#0891b2` (cyan)

### Spacing

`--s1:4px` `--s2:8px` `--s3:12px` `--s4:16px` `--s5:24px` `--s6:32px` `--s7:48px` `--s8:64px`

---

## Base CSS Block

Include this compressed block in every floreo document. Extend as needed:

```css
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
:root{--f-h:Georgia,'Times New Roman',serif;--f-b:system-ui,-apple-system,sans-serif;--f-m:'Courier New',Courier,monospace;--cb:#fafaf9;--cs:#fff;--cbr:#e7e5e4;--ct:#1c1917;--cm:#57534e;--cq:#a8a29e;--ca:#2563eb;--cab:#dbeafe;--cw-bg:#fef3c7;--cw:#d97706;--cg-bg:#dcfce7;--cg:#16a34a}
:root{--s1:4px;--s2:8px;--s3:12px;--s4:16px;--s5:24px;--s6:32px;--s7:48px;--s8:64px}
:root{--t-xs:.75rem;--t-sm:.875rem;--t-md:1rem;--t-lg:1.125rem;--t-xl:1.25rem;--t-2xl:1.5rem;--t-3xl:2rem;--t-4xl:3rem}
body{font-family:var(--f-b);background:var(--cb);color:var(--ct);line-height:1.7;padding:0 1rem}
.pg{max-width:860px;margin:0 auto;padding:4rem 0 8rem}
h1,h2,h3,h4{font-family:var(--f-h);line-height:1.2;color:var(--ct)}
h1{font-size:2.5rem;font-weight:400;letter-spacing:-.02em;margin-bottom:.4rem}
h2{font-size:1.5rem;font-weight:400;margin-bottom:1rem;padding-bottom:.4rem;border-bottom:1px solid var(--cbr)}
h3{font-size:1.1rem;font-weight:600;margin-bottom:.4rem}
p{margin-bottom:1rem;color:var(--cm)}
.sc{margin-bottom:3rem}
.hd{padding-bottom:2rem;margin-bottom:3rem;border-bottom:2px solid var(--cbr)}
.fn{border-top:1px solid var(--cbr);padding-top:1.5rem;font-size:.8rem;color:var(--cq);font-family:var(--f-m)}
.eyebrow{font-family:var(--f-m);font-size:.75rem;letter-spacing:.1em;text-transform:uppercase;color:var(--ca);margin-bottom:.75rem}
.subtitle{font-size:1.1rem;color:var(--cm);font-style:italic}
.note,.warn,.tip{padding:1rem 1.25rem;border-radius:6px;margin:1.5rem 0;font-size:.95rem}
.note{background:var(--cab);border-left:3px solid var(--ca)}
.warn{background:var(--cw-bg);border-left:3px solid var(--cw)}
.tip{background:var(--cg-bg);border-left:3px solid var(--cg)}
.tbl-w{overflow-x:auto;margin:1.5rem 0;border:1px solid var(--cbr);border-radius:8px;overflow:hidden}
.tbl{width:100%;border-collapse:collapse;font-size:.9rem;background:var(--cs)}
.tbl thead{background:#f5f5f4}
.tbl th{text-align:left;padding:.6rem 1rem;font-family:var(--f-m);font-size:.75rem;letter-spacing:.06em;text-transform:uppercase;color:var(--cm);border-bottom:1px solid var(--cbr)}
.tbl td{padding:.6rem 1rem;border-bottom:1px solid #f5f5f4;color:var(--cm);vertical-align:top}
.tbl tr:last-child td{border-bottom:none}
.grid{display:grid;gap:1rem;grid-template-columns:repeat(auto-fill,minmax(240px,1fr));margin:1.5rem 0}
.card{background:var(--cs);border:1px solid var(--cbr);border-radius:8px;padding:1.25rem}
.code{background:#1c1917;color:#f5f5f4;padding:1.25rem;border-radius:8px;font-family:var(--f-m);font-size:.85rem;overflow-x:auto;margin:1.5rem 0;white-space:pre-wrap;word-break:break-all}
.fig{margin:1.5rem 0;text-align:center}
.fig svg{max-width:100%;height:auto}
figcaption{font-size:.8rem;color:var(--cq);margin-top:.5rem;font-style:italic;text-align:center}
a{color:var(--ca);text-decoration:none}
a:hover{text-decoration:underline}
ul,ol{padding-left:1.5rem;margin-bottom:1rem;color:var(--cm)}
li{margin-bottom:.25rem}
strong{color:var(--ct)}
```

---

## Page Skeleton

```html
<!DOCTYPE html><html lang="en"><head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Document Title</title>
<style>/* base css block + document-specific additions */</style>
</head><body>
<div class="pg">
  <header class="hd">
    <p class="eyebrow"><!-- type label, e.g. "Technical Report · 2026-05-22" --></p>
    <h1>Document Title</h1>
    <p class="subtitle"><!-- one-line description --></p>
  </header>
  <main>
    <section class="sc">
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

---

## Components

### Callouts

```html
<div class="note"><strong>Note:</strong> informational aside</div>
<div class="warn"><strong>Warning:</strong> caution or risk</div>
<div class="tip"><strong>Tip:</strong> helpful suggestion</div>
```

### Table

```html
<div class="tbl-w"><table class="tbl">
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
  <path d="M130 60 L180 60" stroke="var(--cq)" stroke-width="1.5" fill="none" marker-end="url(#arr)"/>
  <!-- Arrowhead marker -->
  <defs><marker id="arr" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
    <path d="M0,0 L0,6 L8,3 z" fill="var(--cq)"/>
  </marker></defs>
  <!-- Next box... -->
</svg>
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

## Haiku Subagent Prompt

When spawning the markup phase via the Agent tool (`model="haiku"`), use this prompt:

```
You are composing a self-contained HTML document using the floreo design system.

INPUT: The structured content plan below.

REQUIREMENTS:
1. Output a COMPLETE, VALID HTML file — nothing else. No explanation, no markdown fences.
2. Single file: all CSS inline in <style>, all JS inline in <script>, no external resources.
3. Use floreo class names: .pg .hd .fn .sc .card .tbl .tbl-w .note .warn .tip .fig .code .grid
4. Use the floreo base CSS block exactly as provided. Add document-specific rules after it.
5. Use CSS variables (--ca, --cb, --cs, --cbr, --ct, --cm, --cq, --cab) — never hardcode colors.
6. Compressed markup: short class names, minimal whitespace in CSS, no redundant attributes.
7. SVG for any charts or diagrams (inline, viewBox only — no fixed width/height).
8. Semantic HTML5 elements (header, main, section, footer, figure) to reduce class overhead.
9. <meta viewport> present. max-width on .pg for readability.
10. Set --ca to the accent color specified in the content plan.

FLOREO BASE CSS (copy verbatim from the "## Base CSS Block" section of the floreo SKILL.md you loaded):
<insert the full contents of the ```css block from ## Base CSS Block here>

CONTENT PLAN:
<insert your full Content Plan here>
```

**Important**: Do not pass the angle-bracket placeholders literally. Replace them with the actual CSS block and actual Content Plan before sending to Haiku. The CSS block is in this skill document under `## Base CSS Block` — copy it exactly.

---

## Quality Checklist

Before writing the final file:

- [ ] Self-contained — no external dependencies
- [ ] `<title>` is meaningful and specific
- [ ] Accent color (`--ca`) matches document purpose
- [ ] Visual hierarchy is clear: h1 > h2 > h3, spacing creates sections
- [ ] Tables used for comparative data (not prose lists)
- [ ] Callouts (`.note`, `.warn`, `.tip`) surface key insights
- [ ] SVG present for any quantitative comparisons
- [ ] CSS variables used throughout (no hardcoded hex values)
- [ ] Mobile-responsive (`<meta viewport>` present, `max-width` on `.pg`)
- [ ] JS (if any) degrades gracefully without it

---

## Updating an Existing Floreo Document

When a floreo document needs new content, a corrected section, or a data refresh:

1. **Read the existing file** — extract the current section structure (scan for `<h2>` headings and their content)
2. **Produce an updated Content Plan** — treat the existing document as Phase 1 input; add, remove, or edit sections in the plan
3. **Regenerate via Phase 2** — pass the updated Content Plan to Haiku; produce a complete new HTML file
4. **Write as a new version** — use the `-v2` / `-v3` suffix convention; do not overwrite unless the user explicitly asks

Do not surgically edit compressed HTML markup by hand. The cost of a full regeneration is low and the result is clean. The original file serves as a fallback until the new version is confirmed.

---

## Reference Example

`reference/agent-skill-floreo-name.html` in this repository is an example of floreo-quality output: a naming research document with candidate cards, comparison table, etymology section, and decision banner — all self-contained, visually refined, and fully readable.

## Integration

**With `frontend-design`**: For presentations and stakeholder documents where aesthetic quality is the primary concern, load `frontend-design` first. It provides creative aesthetic direction; floreo provides document structure and agent-optimized markup conventions. They are complementary.
