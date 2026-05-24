# Product

## Register

brand

## Users

Mixed audience: engineers and technical leads reading ADRs, incident reports, and session summaries during a work session; and stakeholders (managers, PMs, leadership) reading proposals and analyses to make decisions. Engineers scan fast and want to find signal quickly. Stakeholders read linearly and need enough visual warmth not to feel excluded. The document must serve both without compromising either.

## Product Purpose

Floreo turns AI-generated content into standalone HTML reading artifacts that are worth reading. Where agents default to Markdown, floreo produces structured HTML with a built-in design system: typography, color tokens, components, dark mode, and responsive layout. Every document is a single .html file — no external dependencies, opens offline.

The core promise: the same information, arranged so its meaning can finally be seen. Documents exist to be read, not to drive a workflow.

## Brand Personality

Clear · Trustworthy · Warm · Readable · Unhurried.

Documents should feel considered and permanent — like something worth keeping. Human enough that non-technical readers don't feel excluded. Serious enough that engineers trust the information hierarchy. The reading experience itself is the product.

Voice: precise but not cold. No filler. Every element earns its presence.

## Anti-references

- **SaaS dashboard aesthetic** — dark sidebars, metric cards, gradient accents. Feels like a tool, not a document.
- **AI-generated generic output** — uniform padding, identical card grids, zero visual hierarchy. The "AI made this" tell. Floreo documents should feel like a human chose every layout decision.
- **Corporate report PDF** — dense tables, gray on gray, no personality. Correct but forgettable.
- **Marketing landing page** — hero sections, animated blobs, gradient headlines. Too loud for a reading artifact.

## Design Principles

1. **Meaning through structure.** Typography and spacing carry hierarchy. The reader's eye should land in the right place without prompting — no visual noise competing for attention.
2. **Considered, not decorated.** Every visual element serves the content or navigation. Nothing is aesthetic-only. If removing an element doesn't hurt comprehension, remove it.
3. **Readable to everyone.** Engineers scan; stakeholders read linearly. The document must serve both — clear entry points for scanners, coherent flow for readers.
4. **Documents that persist.** Output should feel worth keeping and referencing, not ephemeral AI churn. Timeless typography, stable structure, no trends that date.
5. **Trustworthy by default.** The visual register signals reliability. No gradient text, no bounce animations, no hero metrics — anything that makes the document look like it's trying too hard undermines the content.

## Accessibility & Inclusion

WCAG AA as baseline. Dark mode supported via `prefers-color-scheme` in the floreo CSS base block. `prefers-reduced-motion` should be respected — no animations that can't be disabled. Minimum contrast ratios: 4.5:1 for body text, 3:1 for large text and UI components.
