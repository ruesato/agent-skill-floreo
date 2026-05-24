---
name: Floreo
description: HTML reading artifacts for agent-generated content — editorial, trustworthy, unhurried.
colors:
  parchment-warm: "#fafaf9"
  surface-white: "#ffffff"
  surface-muted: "#f5f5f4"
  stone-border: "#e7e5e4"
  ink-deep: "#1c1917"
  ink-mid: "#57534e"
  ink-quiet: "#a8a29e"
  accent: "#2563eb"
  accent-tint: "#dbeafe"
  amber-warning: "#d97706"
  amber-warning-bg: "#fef3c7"
  emerald-tip: "#16a34a"
  emerald-tip-bg: "#dcfce7"
  dark-base: "#1c1917"
  dark-surface: "#292524"
  dark-surface-muted: "#211f1e"
  dark-border: "#44403c"
typography:
  display:
    fontFamily: "Georgia, 'Times New Roman', serif"
    fontSize: "2.5rem"
    fontWeight: 400
    lineHeight: 1.2
    letterSpacing: "-0.02em"
  headline:
    fontFamily: "Georgia, 'Times New Roman', serif"
    fontSize: "1.5rem"
    fontWeight: 400
    lineHeight: 1.2
  title:
    fontFamily: "system-ui, -apple-system, sans-serif"
    fontSize: "1.1rem"
    fontWeight: 600
    lineHeight: 1.2
  body:
    fontFamily: "system-ui, -apple-system, sans-serif"
    fontSize: "1rem"
    fontWeight: 400
    lineHeight: 1.7
  label:
    fontFamily: "'Courier New', Courier, monospace"
    fontSize: "0.75rem"
    fontWeight: 400
    letterSpacing: "0.1em"
rounded:
  sm: "4px"
  md: "8px"
spacing:
  xs: "4px"
  sm: "8px"
  md: "16px"
  lg: "24px"
  xl: "32px"
  2xl: "48px"
  3xl: "64px"
components:
  callout-note:
    backgroundColor: "{colors.accent-tint}"
    rounded: "{rounded.md}"
    padding: "1rem 1.25rem"
  callout-warn:
    backgroundColor: "{colors.amber-warning-bg}"
    rounded: "{rounded.md}"
    padding: "1rem 1.25rem"
  callout-tip:
    backgroundColor: "{colors.emerald-tip-bg}"
    rounded: "{rounded.md}"
    padding: "1rem 1.25rem"
  card:
    backgroundColor: "{colors.surface-white}"
    rounded: "{rounded.md}"
    padding: "1.25rem"
  code-block:
    backgroundColor: "{colors.ink-deep}"
    textColor: "{colors.parchment-warm}"
    rounded: "{rounded.md}"
    padding: "1.25rem"
---

# Design System: Floreo

## 1. Overview

**Creative North Star: "The Reference Shelf"**

Floreo documents are the books you keep. Not dashboards, not feeds — reading artifacts meant to be consulted again weeks later when context is needed to make a decision or understand a past event. The design system exists to make AI-generated content feel like it was worth writing. Considered layout, unhurried typography, quiet components: everything in service of the information, nothing competing with it.

The palette is warm stone, not clinical white — chosen to feel like paper, not a screen. Headings speak in Georgian serif: a voice with authority but without aggression. Body copy runs in system-ui: native, fast, unobtrusive. The mono face appears only where precision matters — code, metadata, eyebrows, timestamps. Three voices, each in its place, never overlapping.

This system explicitly rejects four things: the SaaS dashboard aesthetic (dark sidebars, metric cards, gradient accents); AI-generated generic output (uniform padding everywhere, identical card grids, the visual signature of no one making choices); the corporate report PDF (gray on gray, correct but forgettable); and the marketing landing page (hero sections, gradient headlines, energy performing in place of substance).

**Key Characteristics:**
- Warm stone neutrals, never clinical white or reflexively dark
- Three font stacks with strict roles: serif for display, sans for body, mono for metadata
- Accent color varies per document type; its rarity on any given surface is the point
- Flat surfaces with tonal depth only, no shadows
- Components recede; typography and spacing carry all meaning

## 2. Colors: The Stone Inkwell Palette

Ink-on-paper warmth. Every neutral tilts toward stone, never toward gray. One variable accent per document.

### Primary
- **Variable Document Accent** (`{colors.accent}`, default #2563eb): The document's identity badge. Changes per type: crimson (#dc2626) for incident reports, violet (#7c3aed) for decisions, teal (#0891b2) for research, green (#16a34a) for retrospectives. Used on at most 10% of any given surface. Tint backgrounds (`{colors.accent-tint}`) may extend it as a whisper.

### Neutral
- **Parchment Warm** (`{colors.parchment-warm}`, #fafaf9): Page background. Near-white with a barely perceptible stone undertone. Prevents the screen-glare coldness of pure white.
- **Surface White** (`{colors.surface-white}`, #ffffff): Card and panel surfaces. One tonal step above the page to create depth without shadows.
- **Surface Muted** (`{colors.surface-muted}`, #f5f5f4): Table headers, secondary surfaces, hover states on interactive elements.
- **Stone Border** (`{colors.stone-border}`, #e7e5e4): All borders and dividers. Present but not heavy.
- **Ink Deep** (`{colors.ink-deep}`, #1c1917): Primary text. Near-black with a warm brown undertone. Never `#000`.
- **Ink Mid** (`{colors.ink-mid}`, #57534e): Body copy. Lightened from deep ink to reduce fatigue over long reads.
- **Ink Quiet** (`{colors.ink-quiet}`, #a8a29e): Metadata, timestamps, captions, footer text. Disappears at distance; readable up close.

### States
- **Amber Warning** (`{colors.amber-warning}`, #d97706) on **Amber Mist** (`{colors.amber-warning-bg}`, #fef3c7): Warning callouts. Warm amber reads cautionary without red's urgency.
- **Emerald Tip** (`{colors.emerald-tip}`, #16a34a) on **Emerald Mist** (`{colors.emerald-tip-bg}`, #dcfce7): Tip and success callouts.

### Named Rules
**The One Accent Rule.** The document accent (`--ca`) appears on at most 10% of any surface. Its rarity is the signal. A document drowning in its own accent color loses its identity badge.

**The Warm Neutral Rule.** All neutrals tint toward warm stone, never toward cool gray. The chroma is low (0.005–0.01 in OKLCH) but measurable; the warmth is felt before it is noticed.

## 3. Typography: The Three-Voice Hierarchy

**Display Font:** Georgia, 'Times New Roman', serif
**Body Font:** system-ui, -apple-system, sans-serif
**Label / Mono Font:** 'Courier New', Courier, monospace

**Character:** Georgia signals authority without formality — a reading font, not a display font performing status. System-ui disappears into the content; it is the voice of the information, not of the design. Courier New appears only where precision matters. The three voices never substitute for each other.

### Hierarchy
- **Display** (400 weight, 2.5rem, line-height 1.2, letter-spacing −0.02em): Document title only — one h1 per document. Slightly tracked in for density and presence. Slightly below the scale you would expect; this document should feel like a manuscript, not a poster.
- **Headline** (400 weight, 1.5rem, line-height 1.2): Section headings (h2). Light weight — a serif at 1.5rem has natural authority without needing emphasis. Underlined with a 1px stone border to mark section transitions.
- **Title** (600 weight, 1.1rem, line-height 1.2): Sub-section headings (h3). Bold sans — switches register from the serif headings above. The contrast signals "within a section," not "a new chapter."
- **Body** (400 weight, 1rem, line-height 1.7, max 65–75ch): All running prose. The generous line-height serves both the scanner (who can scan columns cleanly) and the linear reader (who needs visual breathing room).
- **Label** (400 weight, 0.75rem, letter-spacing 0.1em, UPPERCASE, Courier New): Eyebrow labels above titles, table column headers, timestamps, metadata lines, footer text. The tracked-out mono creates clear register contrast with the prose around it.

### Named Rules
**The Three-Voice Rule.** Georgia for headings. System-ui for body. Courier New for metadata and code. Never mix them within a role. A monospaced eyebrow above a serif h1 is deliberate contrast. A monospaced paragraph is a mistake.

**The Serif Authority Rule.** h1 and h2 are always Georgia. They carry the document's voice. h3 and below switch to system-ui — not for variety, but to signal information hierarchy. Serif = chapter. Sans = section within the chapter.

## 4. Elevation

Floreo documents are flat by default. Depth is expressed entirely through tonal layering, never shadows.

The three-step stack: page (`{colors.parchment-warm}`) → surface (`{colors.surface-white}`) → surface muted (`{colors.surface-muted}`). Cards sit on the page. Table headers sit on the table. No element floats. Everything belongs to the same plane — because documents are read, not navigated.

Dark mode inverts the stack cleanly: `{colors.dark-base}` → `{colors.dark-surface}` → `{colors.dark-surface-muted}`. Borders shift from `{colors.stone-border}` to `{colors.dark-border}`. Same relative tonal relationships, same flat philosophy.

### Named Rules
**The No-Shadow Rule.** No `box-shadow` on any document element except interactive focus rings. Shadows signal interactivity; floreo documents are read, not clicked. A shadow on a card implies it can be dragged, expanded, or dismissed. None of those are true.

## 5. Components

Components are typographic and editorial. They recede rather than announce. The measure of a well-executed component is that the reader notices the content, not the container.

### Callouts
Three semantic variants: Note (blue tint, `{colors.accent-tint}`), Warning (amber, `{colors.amber-warning-bg}`), Tip (green, `{colors.emerald-tip-bg}`). The background tint is the signal. No side-stripe borders — a 3px left border accent looks like a Bootstrap alert from 2018. Geometry: 8px radius, 1rem 1.25rem padding. An optional bold label ("Note:", "Warning:", "Tip:") in body weight precedes the text. The variant is communicated by color and label, not decoration.

### Cards / Containers
Surface white background (`{colors.surface-white}`), 1px stone border, 8px radius, 1.25rem internal padding. No shadow. Cards are differentiated from the page by their surface color alone. Use sparingly — the default for groups of related information is a section, not a card grid.

### Code Blocks
The only fully dark surface. `{colors.ink-deep}` background creates strong figure-ground contrast for technical content. Courier New at 0.85rem, 1.25rem padding, 8px radius. Pre-wrapped for long lines. Dark mode: add a 1px `{colors.dark-border}` border so the block remains distinguishable on the dark page.

### Tables
Full-width, collapsed borders. Header row in `{colors.surface-muted}` with Courier New uppercase labels (0.75rem, letter-spacing 0.06em). Data cells in `{colors.ink-mid}`. Last row has no bottom border — the container's border closes the table. Wrapped in a 1px `{colors.stone-border}` border + 8px radius container. Highlighted rows use `{colors.accent-tint}` background on the `<tr>`.

### Stat Block
Large Georgia number in the document accent color. All-caps Courier New label below. No card container — stats float in the reading flow on a surface card background. Use a flex row for groups. Minimum width 140px per stat to prevent label truncation.

### Timeline
Vertical sequence with a 1px `{colors.stone-border}` line drawn through 15px accent-colored circles. Timestamps in `{colors.ink-quiet}` Courier New, 0.75rem. Event titles in bold system-ui. Descriptions in body regular. The structure is data-forward; the decoration is the 15px dot.

## 6. Do's and Don'ts

### Do:
- **Do** use Georgia at 2.5rem, weight 400 for the document title. The reading experience depends on that display moment landing with the right authority.
- **Do** vary the document accent (`--ca`) per document type. The accent is the document's identity; it should be different for an incident report vs. a research brief.
- **Do** keep accent use below 10% of any surface. Its scarcity is the signal.
- **Do** tint all neutrals warm toward stone. `#1c1917` not `#111111`. `#fafaf9` not `#fafafa`. The chroma is low but the warmth is measurable.
- **Do** use the three-step tonal stack (parchment → surface → muted) as the only depth mechanism.
- **Do** max body line length at 65–75ch. Prose on an uncontrolled 860px container is unreadable.
- **Do** use Courier New uppercase labels for eyebrows, table headers, timestamps, and metadata. These are the document's navigational signposts.
- **Do** embed the floreo Content Plan in `<script type="application/floreo">` before `</body>`. Future agents must be able to update the document without reverse-engineering markup.
- **Do** respect `prefers-color-scheme: dark` and `prefers-reduced-motion`. Both are non-negotiable baseline accessibility.

### Don't:
- **Don't** use side-stripe borders (border-left or border-right greater than 1px as a colored accent) on callouts, cards, or list items. The background tint is the callout signal. A stripe makes it look like a Bootstrap alert. Rewrite with background tint only, or full border, or nothing.
- **Don't** use gradient text. Single solid color only. Emphasis via weight or size.
- **Don't** use the SaaS dashboard aesthetic — dark sidebars, metric cards, gradient accents. Documents are read, not monitored.
- **Don't** produce AI-generic output — uniform padding on every element, identical card grids with icon + heading + body, no spacing rhythm. If the spacing is the same everywhere, the design is making no choices.
- **Don't** produce a corporate report PDF aesthetic — gray on gray, no accent, dense tables as primary structure. The document must have a voice.
- **Don't** use marketing landing page patterns — hero sections, animated blobs, gradient headlines, the hero-metric template (big number, small label, gradient accent background). These patterns undermine content credibility.
- **Don't** use `#000` or `#fff`. Always tint toward warm stone.
- **Don't** animate layout properties. The only valid CSS transition is `background` or `color` on interactive hover/focus states (150ms ease-out).
- **Don't** break self-containment. No external fonts, no CDN stylesheets, no remote images. One `.html` file, everything inline.
- **Don't** add shadows to document elements. The No-Shadow Rule has no exceptions beyond interactive focus rings.
