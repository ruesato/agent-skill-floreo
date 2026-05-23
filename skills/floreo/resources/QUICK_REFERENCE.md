# Floreo Quick Reference

## Class names
`.pg` page wrapper · `.hd` header · `.fn` footer · `.sc` section · `.bd` body  
`.card` card · `.grid` card grid · `.tbl` table · `.tbl-w` table wrapper  
`.note` info callout · `.warn` warning callout · `.tip` tip callout  
`.fig` figure/chart · `.code` code block

## CSS variable tokens
`--cb` bg · `--cs` surface · `--cs2` subtle surface (table headers, row dividers) · `--cbr` border  
`--ct` text · `--cm` muted · `--cq` quiet  
`--ca` accent · `--cab` accent-bg tint · `--cw-bg`/`--cw` warn amber · `--cg-bg`/`--cg` success green  
`--f-h` heading font · `--f-b` body font · `--f-m` mono font  
`--s1`–`--s8` spacing (4px→64px) · `--t-xs`–`--t-4xl` type scale (.75rem→3rem)

Dark mode auto-activates via `@media(prefers-color-scheme:dark)` — overrides `--cb`, `--cs`, `--cs2`, `--cbr`, `--ct`, `--cm`, `--cq`

## Accent color by doc type
`#2563eb` technical (default) · `#dc2626` warning/incident · `#16a34a` success  
`#7c3aed` planning · `#0891b2` research · `#d97706` caution

## Skeleton (minimal)
```html
<!DOCTYPE html><html lang="en"><head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="floreo:type" content="report"><meta name="floreo:created" content="YYYY-MM-DD">
<meta name="floreo:model" content="claude-sonnet-4-6"><meta name="floreo:version" content="1">
<title>Title</title><style>/* base css */</style></head><body>
<div class="pg"><header class="hd"><h1>Title</h1></header>
<main><section class="sc"><h2>Section</h2><p>Content.</p></section></main>
<footer class="fn">source · date</footer></div></body></html>
```

## Markup subagent invocation
```
Agent tool, model="haiku" (or most efficient available)
Provide: Content Plan + floreo base CSS + requirements from SKILL.md
Receive: complete HTML file
```

## Two-phase rule
Phase 1 (capable model): content, structure, prose  
Phase 2 (most efficient model): markup composition from Content Plan
