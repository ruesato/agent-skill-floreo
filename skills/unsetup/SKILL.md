---
name: unsetup
description: >
  Remove the floreo auto-invoke rule from the current project's CLAUDE.md.
  Reverses /floreo:setup. Use when the user says "remove floreo", "undo
  floreo setup", "disable floreo auto-invoke", "unsetup floreo", or "remove
  floreo from CLAUDE.md".
---

# floreo:unsetup

Remove the floreo auto-invoke rule that `/floreo:setup` embedded in the
current project's CLAUDE.md. After unsetup, agents in this project will no
longer use floreo automatically — explicit `/floreo` invocation is required
to produce floreo documents.

This is the inverse of `/floreo:setup`. It targets only the `## floreo`
section that setup adds; any other floreo references in CLAUDE.md (in a
beads integration block, a `floreo:brand-color` line, project notes, etc.)
are left untouched.

## Steps

1. Check whether `CLAUDE.md` exists in the project root. If it doesn't,
   tell the user there is nothing to remove and stop.

2. Read `CLAUDE.md` and locate the `## floreo` section — the heading line
   `## floreo` plus every line after it up to (but not including) the next
   `## ` heading, or to the end of the file if it is the last section.

   If no `## floreo` heading is present, tell the user there is no floreo
   auto-invoke rule to remove and stop.

3. Remove that section. Use the Edit tool with `oldString` = the full block
   (the `## floreo` heading line and all following lines through the end of
   the section, including any trailing blank lines that belong to it) and
   `newString` = empty.

   Clean up spacing after removal:
   - If the section was the last content in the file, remove any trailing
     blank lines so the file ends with a single newline.
   - If removing the section leaves two or more consecutive blank lines
     where it used to sit, collapse them to one.
   - Preserve one blank line between the preceding and following sections
     if both exist.

4. Tell the user what was removed and from which file. The change takes
   effect immediately — CLAUDE.md is read at the start of each message,
   so the next message in this session will not auto-invoke floreo.

## Notes

- **Scope**: only the `## floreo` section added by `/floreo:setup` is
  removed. If the heading was renamed or the rule was merged into another
  section, unsetup will not find it — restore the `## floreo` heading first,
  or remove the rule manually.
- **Other floreo mentions**: a `floreo:brand-color` line, a reference inside
  a beads integration block, or any floreo mention outside the `## floreo`
  section is preserved. Unsetup targets the auto-invoke rule, not floreo
  itself.
- **Re-run setup any time**: `/floreo:setup` can be invoked again to
  re-add the auto-invoke rule. Setup and unsetup are idempotent inverses.
