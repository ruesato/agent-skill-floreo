---
title: Hint States Reference
type: report
accent: technical
interactive: none
---

# Hint States Reference

A minimal floreo markdown fixture exercising every hint `status` state. Use this as a reference when testing the render pipeline's hint-handling behavior.

## Revenue Overview

```chart:bar
labels: [Q1, Q2, Q3, Q4]
data: [42, 58, 71, 63]
<hint>horizontal layout, muted palette, highlight Q3 as the peak</hint>
```

The chart above has no `status` attribute — the render agent applies it normally and strips it from the HTML.

## Key Wins This Quarter

<hint status="approved">Lead with the win. Two sentences max. Cut any hedging language.</hint>

We closed three enterprise deals totaling $2.4M in new ARR. Customer satisfaction hit an all-time high with NPS at 72.

The hint above is marked `approved` — the author accepts the directive and the render agent applies it.

## Growth Targets

```chart:bar
labels: [Q1, Q2, Q3, Q4]
data: [42, 58, 71, 63]
<hint status="resolved">Add a trend line overlay showing cumulative growth.</hint>
```

The hint above is marked `resolved` — the author already added the trend line by editing the block data directly. The render agent strips the hint without applying it.

## Glossary

<hint status="rejected" reason="audience is technical, glossary would add noise">Add a glossary table defining ARR, NPS, and churn.</hint>

The hint above is marked `rejected` — the author considered it but the audience is already familiar with the terms. The render agent preserves it as `<!-- floreo:hint (rejected): Add a glossary table defining ARR, NPS, and churn. — audience is technical, glossary would add noise -->` in the HTML output.

## Future Work

<hint applied="false">Restructure this section as a numbered priority list once the rankings are confirmed.</hint>

The hint above uses the legacy `applied="false"` syntax — still supported as an alias for `status="rejected"` (without a reason). The render agent preserves it as `<!-- floreo:hint (unapplied): … -->`.
