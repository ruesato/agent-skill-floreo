# floreo

*floreo* — Latin: I flower. I bloom. I flourish.

A Claude Code skill that turns agent-created content into beautiful, self-contained HTML documents optimized for human reading. Agents write the markup; humans see the rendered page.

## Install

```
/plugin install github:ryanuesato/agent-skill-floreo
```

That's it. The `/floreo` skill is immediately available in any project.

## What it does

Invoke floreo whenever an agent produces content humans will read:

- Reports, summaries, analyses
- Architecture Decision Records (ADRs)
- Sprint retrospectives, project proposals
- Onboarding guides, API references
- Session-close summaries for agent handoffs
- Agent briefs for multi-agent pipelines

**Minimum threshold** — floreo when the content has ≥2 of: multiple sections, a table or diagram, content that persists beyond the conversation, or an audience beyond the immediate user.

## How it works

**Phase 1** (capable model) — think: audience, hierarchy, what needs visual treatment; write a structured Content Plan.

**Phase 2** (efficient subagent) — compose HTML from the Content Plan. Spawn with `model="haiku"` for token efficiency.

Output: a single self-contained `.html` file. No external dependencies. Everything inline.

## Design system

- System fonts, no external load
- CSS custom properties (`--ca`, `--cb`, `--cs`, `--ct`, …)
- Dark mode via `@media (prefers-color-scheme: dark)`
- Machine-readable metadata (`<meta name="floreo:type">`, etc.)
- Stable section IDs (`data-floreo-id`) for diffing and programmatic extraction
- Optional reading interface: sticky ToC, print styles, in-doc search, Markdown export

## Document types

Built-in Content Plan templates for: Incident Report · ADR �� Sprint Retrospective · Research Brief · Onboarding Guide · API Reference · Project Proposal · Agent Brief · Session-Close Summary

## License

MIT
