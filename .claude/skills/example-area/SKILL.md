---
name: example-area
description: TEMPLATE, not a real skill. Copy this folder to .claude/skills/<area>/ for each area of the codebase with rules the agent can't infer from the code, then delete this one. Write the real description as a trigger, for example "Use before writing any Supabase query, adding a table, or changing RLS policies."
disable-model-invocation: true
---

<!--
How to write an area skill:
- One skill per area with non-obvious rules: auth, database/RLS, payments, a pipeline.
  If a rule fits on one line, put it in AGENTS.md under Conventions instead.
- The description decides when the agent loads it. Name the actions that should trigger it
  ("before adding a table", "before touching barcode scanning"), not the topic.
- Remove `disable-model-invocation: true` so the agent loads it automatically. Keep it only for
  skills that should run when you type /<name>, like a release checklist.
- Keep the body under ~150 lines. Move long reference material into files next to SKILL.md and
  link to them; the agent reads them only when needed.
- Point at exemplar files rather than pasting code. Delete any section below that's empty.
- Add the skill to the "More context" list in AGENTS.md.
-->

# <Area name>

<One or two sentences: what this area does and why it needs care.>

## Invariants

Rules that must always hold. Each one should prevent a real mistake.

- <e.g. Every table has RLS enabled and a policy using `is_household_member()`.>

## How to

<The usual change in this area, as numbered steps, pointing at an exemplar.>

1. <e.g. Copy `supabase/migrations/<exemplar>.sql` for the policy shape.>
2. <...>

## Verify

- `<command that proves a change in this area works>`

## Gotchas

- <Failure modes that have actually happened, and how to spot them.>
