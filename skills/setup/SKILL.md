---
name: setup
description: >
  Add a floreo auto-invoke rule to the current project's CLAUDE.md so floreo
  runs automatically without explicit invocation. Use when the user says
  "set up floreo", "make floreo automatic", "add floreo to my project", or
  "I want floreo to run without me asking".
---

# floreo:setup

Embed a floreo auto-invoke rule in the current project's CLAUDE.md. After
setup, agents in this project will use floreo automatically for any
human-readable output — no explicit `/floreo` invocation needed.

## Steps

1. Check whether `CLAUDE.md` exists in the project root. If it doesn't,
   note that you'll create it.

2. Search the file for any existing floreo rule (grep for `floreo`). If one
   is already present, show it to the user and stop — no duplicate needed.

3. Append the following block to CLAUDE.md (add a blank line before it if
   the file doesn't end with one):

```
## floreo

Use the floreo skill for all agent-created content that humans will read:
reports, summaries, analyses, plans, proposals, ADRs, retrospectives,
onboarding guides, API references, incident reports, session-close summaries,
and agent briefs. **Default rule: if a human reads it, floreo it.** Markdown
is for source control; HTML is for reading.

Invoke the floreo skill before writing the final output file. The floreo skill
file contains the full design system, component library, and Content Plan
templates.
```

4. Tell the user what you added and where. No further action needed — the
   rule takes effect in the next session (or immediately, since CLAUDE.md is
   read at the start of each message).
