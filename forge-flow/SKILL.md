---
name: forge-flow
description: Design a Markdown dev plan or execute it milestone by milestone with full autonomy. Three modes: `design` (plan), `TDD` (test-first, default), `IDD` (exploratory). Closed loop: plan → test → implement → simplify → verify → commit → push. Use when planning work or executing a devplan end-to-end.
---

# Forge-flow — Router

This skill has three modes:

- **`design`** — create or update a dev plan. Proposes in chat, writes only after approval.
- **`TDD` (RECOMMENDED DEFAULT)** — test-first: write tests, run red, implement green, simplify, commit.
- **`IDD`** — implement-first for exploratory work: code then tests, simplify, commit.

## Scope

All code changes — features, refactors, and bug fixes — go through this skill.

## Mode selection

Parse the first token of the args:

- `design` or `design <description>` → design mode
- `TDD <devplan-path>` → TDD mode
- `IDD <devplan-path>` → IDD mode
- `<devplan-path>` (path alone, no mode token) → TDD (default)
- no args → ask the user, in their language, whether they want
  `design` (create/update the plan) or execution — `TDD` (recommended)
  or `IDD` (exploratory)

A token counts as a devplan path if it contains `/`, ends with `.md` or
`.markdown`, or has a basename starting with `DEVPLAN` (case-insensitive).
If ambiguous, ask rather than routing silently.

## Language

Chat interactions (questions, proposals, recaps) happen in the user's
language. Devplan **file** content is written in English — unless the
project's existing devplan already uses another language, in which
case match it.

## Routing

1. Announce the mode at the very start: `Mode: design`, `Mode: TDD`,
   or `Mode: IDD`.
2. Read the corresponding playbook file (in this skill directory):
   - design → `DESIGN.md`
   - TDD → `TDD.md`
   - IDD → `IDD.md`
3. Follow that playbook end-to-end. Do not load any other playbook
   unless the chosen playbook explicitly instructs a per-milestone
   fallback.
