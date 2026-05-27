# Changelog

All notable changes to floreo are documented here. Follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) format and [Semantic Versioning](https://semver.org/).

---

## [1.2.1] — 2026-05-27

### Changed

- **Draft-first default workflow** — `/floreo` now drafts a floreo markdown file before rendering HTML. After producing the draft, the agent outputs a decision prompt showing section and intent block counts, then waits for user input:
  ```
  Draft complete → `docs/[slug].md`
  [N] sections · [X] intent blocks

  Edit the file and say **"render"** when ready, or say **"render now"** to go straight to HTML.
  ```
- **Re-entry pattern** — after a user edits the draft, the agent recognizes render triggers ("render", "looks good", "done", "go ahead", etc.) and proceeds to HTML without re-prompting
- **Escape hatch** — users can skip the draft step by saying "just give me the HTML", "skip the draft", or "render directly"; session-close summaries and agent briefs always skip to HTML as single-pass documents
- Skill description updated to lead with the new default behavior

---

## [1.2.0] — 2026-05-27

### Added

- **`/floreo:draft` skill** — new draft mode that produces a floreo markdown file instead of HTML. Use for iterative content development: multiple revision rounds, human edits between passes, or documents where structure is still being decided. Token-efficient — no template boilerplate during iteration.

- **Floreo markdown format** — lightweight source format for the draft workflow:
  - YAML frontmatter: `title`, `type`, `accent`, `interactive`, `author`, `date`
  - Intent blocks: fenced blocks that declare rich element intent (`chart:bar`, `diagram:flow`, `callout:warning`, `stat-block`, `decision-table`, `steps`, etc.) without implementing HTML
  - `<hint>` annotation syntax for both intent blocks and prose sections

- **`<hint>` annotation system** — unified XML-tag syntax for attaching render instructions to any element in a floreo markdown draft:
  - Works inside intent blocks and in prose (before/after any element)
  - Supports single-line and multi-line hints
  - `applied="false"` attribute preserves a hint through render as an HTML comment for the next pass
  - Hints are stripped from final HTML output

- **Render-from-markdown path in `/floreo`** — the render skill now accepts a floreo markdown file as input. Detects floreo frontmatter, converts intent blocks to HTML components, applies hints, and composes the full floreo template. Unapplied hints preserved as `<!-- floreo:hint (unapplied): ... -->` comments.

- **Intent block vocabulary** (for `/floreo:draft` and render):

  | Block | Renders as |
  |---|---|
  | `chart:bar` / `chart:bar-h` | Inline SVG bar chart (vertical / horizontal) |
  | `chart:line` | Inline SVG line chart |
  | `chart:donut` | Inline SVG donut chart |
  | `chart:milestone` | Inline SVG milestone/phases chart |
  | `diagram:flow` | Inline SVG flow diagram |
  | `diagram:timeline` | `.tl` timeline component |
  | `callout:info/warning/success` | Callout components |
  | `stat-block` | `.stats` stat block |
  | `decision-table` | Styled decision table |
  | `steps` | Numbered steps list |

### Changed

- `/floreo` skill description updated to reflect that it also accepts floreo markdown files as input
- README restructured: two-phase workflow documented, floreo markdown format reference added, intent block vocabulary and hint syntax shown with examples

---

## [1.1.5] — 2026-05-26

### Changed

- Removed errant Copilot instruction file (`.github/code-review-graph.instruction.md`) — duplicate of the MCP tools section in `CLAUDE.md`

---

## [1.1.4] — 2026-05-26

### Fixed

- **Search highlights** — changed from subtle `--cab` tint to `--ca`/`--cb` (accent color with base text) for strong, readable contrast
- **Search match navigation** — added ↑↓ buttons and Enter/Shift+Enter keyboard shortcuts to cycle through matches
- **Search match count** — inline "2 / 7" display with `aria-live` region for screen readers
- **Search empty state** — "No results" feedback when query finds zero matches
- **Search active match** — current match gets a distinct outline ring (`mark.ri-hl.ri-hl-cur`) and auto-scrolls into view

### Changed

- **ToC card surface removed** — stripped `background`, `border`, and `border-radius` from `.toc`; the sidebar ToC now floats as borderless label text. Padding and sticky positioning unchanged.

---

## [1.1.3] — 2026-05-25

### Added

- Sticky right-hand sidebar ToC on wide viewports (≥1100px) via CSS grid layout

### Fixed

- Callout text unreadable in dark mode — added explicit `color: var(--ct)` override

---

## [1.1.1] — 2026-05-24

### Added

- Visual decision table component
- New chart patterns
- Mandatory `INTERACTIVE` field in Content Plan

---

## [1.0.0] — Initial release

Core floreo skill: design system, component library, SVG charts, dark mode, reading interface (ToC, search, copy-as-Markdown).
