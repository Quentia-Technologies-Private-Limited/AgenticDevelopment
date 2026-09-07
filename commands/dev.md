---
description: Launch the dev-made-easy development pipeline for any project task
---

# /dev — Pipeline Entry Point

**Read `${CLAUDE_PLUGIN_ROOT}/agents/00-orchestrator.md` and follow it yourself, in this
conversation. Do NOT dispatch it to a subagent.**

## Why this matters — do not "optimise" this into an Agent call

The router and the pipeline orchestrators are *interactive*. They ask the user which
mode to run, they ask three separate groups of technology questions and wait for a
reply after each, and they hold a Planning Approval Gate and a Development Approval
Gate.

A subagent has no channel back to the user. It cannot send a message and wait — it
runs to completion and returns a single string. So if the orchestrator is dispatched
via the Agent tool, every one of those gates becomes unsatisfiable, and each step from
Step 2 onward is blocked on answers that can never arrive. The only path that
terminates is for the agent to skip the pipeline, improvise the build inline, and
report success without writing any artifacts.

That is a silent failure: you get working code, no specs, no review report, no tests,
no docs, and a `pipeline-index.json` entry claiming the pipeline completed.

**You are the router.** You ask the questions. You hold the gates.

## What DOES get dispatched

The specialist agents are non-interactive by design — they read spec files, write
files, and return a summary. Dispatch these via the Agent tool, from this conversation,
one level deep:

- `dev-made-easy:Planning Analysis Agent`
- `dev-made-easy:Planning Specs Agent`
- `dev-made-easy:Development Agent`
- `dev-made-easy:Code Review Agent`
- `dev-made-easy:Testing Agent`
- `dev-made-easy:Documentation Agent`
- `dev-made-easy:Codebase Analysis Agent`

Never nest orchestrators inside agents inside agents. The main conversation dispatches
specialists directly — one level, no deeper.

## The three orchestrators are FILES YOU READ, not things you invoke

`Development Orchestrator`, `Greenfield Orchestrator` and `Feature Addition Orchestrator`
are agent definitions. They are **not** skills, and in this pipeline they are **not**
dispatched as agents either.

- `Skill(dev-made-easy:Greenfield Orchestrator)` → fails with `Unknown skill`
- `Agent(dev-made-easy:Greenfield Orchestrator)` → runs, but behind a wall it cannot talk
  through, which is the bug this design exists to prevent

The only correct move is `Read` the file and follow its contents as your own
instructions. If a Read fails because `${CLAUDE_PLUGIN_ROOT}` did not expand, locate the
plugin first — try `find ~/.claude/plugins -name '00-orchestrator.md' -path '*dev-made-easy*'`
— and read the path you find. Do not fall back to invoking it, and do not fall back to
building the project yourself.

## Before you start

Do NOT invoke brainstorming, planning, or any other skill first — the orchestrator
handles its own planning, analysis, and technology decisions.

Establish `project_root` before dispatching anything. See Step 3 of the router: it must
be a real absolute path to the user's project. Do not assume the current working
directory is the project — in hosted environments (Cowork, cloud sessions) the cwd is
an ephemeral sandbox with no repo in it. Ask the user if you cannot determine it.

The user's task description: $ARGUMENTS
