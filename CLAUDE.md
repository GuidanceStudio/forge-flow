# forge-flow — project instructions

## This repository is public

`github.com/GuidanceStudio/forge-flow` is public, and `forge-flow/` is a payload
installed onto other people's machines. Everything written here ships.

## Never name another project (HARD)

**No file in this repo may name a project, repo, path, host, service, ticket ID
or milestone ID belonging to work outside forge-flow.** This covers `DEVPLAN.md`,
the skill payload, tests, commit messages and code comments alike — a devplan
entry is not a private notebook, it is a public file.

The rule bites hardest where the writing is most useful: a measurement is
evidence, and the instinct is to cite where it came from. **Keep the number,
drop the origin.** Both of these say the same thing to a reader of this repo:

- ✗ `<private-repo>/<tool>.sh is 40% comment lines (1233 of 3048)`
- ✓ `one 3048-line shell tool in a production ops repo is 40% comment lines`

The ✗ form above is written with placeholders on purpose: this file may not
carry a real foreign name either, not even as an example of one.

The generic form loses nothing a forge-flow reader can act on. The specific form
adds a private repo name, a file path, and — in the case that produced this rule
— a **production hostname**, published on GitHub inside an installable skill.

Worked examples in the payload get the same treatment: use `example.com`,
`state.example`, `M-OPS-CI-RED-1`. Never a real host, never a real ticket.

**Before every commit**, check the staged diff for foreign identifiers:

```bash
git diff --cached | grep -nEi '<known-project-names>|[a-z0-9-]+\.(ai|com|io|dev)|/home/|~/Documents'
```

Anything it finds is either genericised or dropped. Same check applies when a
measurement arrives mid-session and you are about to paste it into a milestone's
`**Why:**`.

Measured 2026-08-14: eight references to a private sibling repo — including a
production management-plane hostname inside `forge-flow/EXECUTOR-CORE.md` —
accumulated across five milestones and were pushed to the public remote before
anyone read them back.

## Workflow

The user's global `CLAUDE.md` governs the devplan gate, writing rules and
reporting. This file only adds what is specific to a public skill repo.
