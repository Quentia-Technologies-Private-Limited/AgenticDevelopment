# Creating a New Vertical

This guide explains how to extend the dev-made-easy plugin with a new pipeline for your own domain — a "vertical." The existing Greenfield and Feature Addition pipelines are two verticals that share the same architecture. You can add more (Design, Data Engineering, DevOps, Mobile, etc.) following the same pattern.

## Architecture

Every vertical follows the **Router → Orchestrator → Subagents** pattern:

```
00-orchestrator.md (Router)
├── 00a-orchestrator-greenfield.md    ← vertical A
├── 00b-orchestrator-feature.md       ← vertical B
└── 00x-orchestrator-{yours}.md       ← your vertical
    ├── subagent-1.md
    ├── subagent-2.md
    └── subagent-3.md
```

| Layer | Responsibility | Talks to user? |
|-------|---------------|----------------|
| Router | Detects which vertical to use, dispatches | Yes — asks which mode |
| Orchestrator | Runs the pipeline steps in order, manages approval gates | Yes — asks domain questions |
| Subagent | Performs one specialized task, reports back | No — only talks to orchestrator |

## Step 1 — Define Your Pipeline

Before writing any files, answer these questions:

1. **What domain is this for?** (e.g., "Design System", "Data Pipeline", "Infrastructure")
2. **What are the steps?** List them in order. Each step is either:
   - A **subagent step** — a specialist agent does the work
   - An **orchestrator step** — YOU (the orchestrator) interact with the user directly
3. **Which steps need user approval gates?** (pause and wait for "proceed")
4. **What artifacts does each step produce?** (files written to `spec_path/`)

Example for a hypothetical "Design System" vertical:

```
1. Design Audit Agent        — subagent scans existing UI components
2. Design Decisions           — orchestrator asks user about style direction, tokens, breakpoints
3. Component Spec Agent      — subagent creates component specs
4. Implementation Agent      — subagent writes component code
5. Visual Review Agent       — subagent runs visual regression tests
6. Documentation Agent       — subagent writes Storybook stories + docs
```

## Step 2 — Create Your Orchestrator

Copy the template below into `agents/00x-orchestrator-{name}.md`. Replace all `{placeholders}`.

```markdown
---
name: {Vertical Name} Orchestrator
description: >
  Coordinates the {N}-step pipeline for {what it does}.
  {One more sentence about when to use it.}
  Invoked by the Development Router or directly.
model: claude-opus-4-6
---

# {Vertical Name} Orchestrator

You coordinate a {N}-step pipeline for {domain description} using specialist subagents.

---

## STOP — READ THESE RULES BEFORE DOING ANYTHING

### Rule 1: This pipeline has EXACTLY {N} steps

{List all steps with one-line descriptions}

### Rule 2: YOU handle user interaction — NOT any subagent

Subagents CANNOT talk to users. Only YOU can.
YOU handle all {domain-specific decisions} in Step {X}.

### Rule 3: Maintain pipeline-state.json

You MUST create and update `{spec_path}/pipeline-state.json` to track progress.
Update the file EVERY time a step status changes.

### WRONG behaviors

| Wrong | Right |
|-------|-------|
| {common mistake} | {correct behavior} |

---

## Pipeline State Management

### State file format

Create `{spec_path}/pipeline-state.json` after the spec folder is established:

{paste the JSON template — change "pipeline" value and steps array to match yours}

### Resume detection

Before starting, check for an existing `pipeline-state.json` in `spec_path`:

| State file says | Action |
|----------------|--------|
| Does not exist | Fresh run |
| `status: "in_progress"` | Ask: resume or start over? |
| `status: "completed"` | Ask: re-run a step or start new? |

---

## Step 1 — Collect Task Description

If not provided, ask:
> "{Your domain-specific prompt}"

Then show dashboard:
{N-item dashboard with all steps listed}

## Step 2 — {First Agent Step}

Mark: {step name} → `[⟳]`

Invoke the agent named **"{Agent Name}"** with this prompt:
{prompt template}

Mark: {step name} → `[✓]`. Update `pipeline-state.json`.

## Step 3 — {User Decision Step}

Mark: {step name} → `[⟳]`

{Questions to ask the user, grouped logically}

**STOP. Wait for user reply.**

Mark: {step name} → `[✓]`. Update `pipeline-state.json`.

{... repeat for all steps ...}

## Step {N+1} — Pipeline Complete

{Final dashboard showing all steps completed}

## Error Handling

If any agent fails: mark `[✗]`, update `pipeline-state.json`
(step → `"failed"` with `"error"` and `"failed_at"`),
display error, ask user whether to retry/skip/abort.
```

## Step 3 — Create Your Subagents

Each subagent is a separate `.md` file in `agents/`. Use this template:

```markdown
---
name: {Agent Name}
description: >
  {What this agent does. When it is invoked.
  Can also be used standalone with a spec path.}
model: claude-opus-4-6
---

# {Agent Name}

You are the {Agent Name} in the Development Plugin.
Your role is to {one sentence about the agent's purpose}.

## Inputs

You will receive:
- `spec_path` — path to planning and implementation artifacts

Read before starting:
- `{spec_path}/{file1}` — {why}
- `{spec_path}/{file2}` — {why}

## Process

### Step 1 — {First thing to do}
{Instructions}

### Step 2 — {Second thing to do}
{Instructions}

## Output Files

Write `{spec_path}/{output-file}`:
{Format and content specification}

## Completion

After finishing, report back to the Orchestrator:
1. {What to report}
2. {What to report}
```

**Subagent rules:**
- One clear responsibility per agent
- Read inputs before producing outputs
- Write artifacts to `spec_path/`
- Report a summary back to the orchestrator — never ask the user questions directly
- Keep the agent under 300 lines — if it's longer, split it

## Step 4 — Register with the Router

Edit `agents/00-orchestrator.md` to add your vertical. Two changes:

**1. Add detection logic to Step 1:**

```markdown
## Step 1 — Determine the Mode

Ask the user:

> **What kind of work are you doing?**
> - **New project** → Greenfield pipeline (7 steps)
> - **Feature/change to existing project** → Feature Addition pipeline (8 steps)
> - **{Your vertical}** → {Your vertical} pipeline ({N} steps)
```

**2. Add dispatch logic to Step 3:**

```markdown
### If {Your Vertical}

Invoke the agent named **"{Vertical Name} Orchestrator"** with this prompt:

{paste the user's full task description here}

The {Vertical Name} Orchestrator handles the complete {N}-step pipeline:
{Step 1} → {Step 2} → ... → {Step N}.
```

## Step 5 — Update README.md

Add your new agents to three places in `README.md`:

1. **Directory tree** — add your orchestrator and subagent files
2. **Agent summary table** — add rows for each new agent
3. **Agent files table** — add rows with file paths and pipeline step numbers

## Naming Conventions

| Item | Convention | Example |
|------|-----------|---------|
| Orchestrator file | `00{letter}-orchestrator-{name}.md` | `00c-orchestrator-design.md` |
| Subagent file | `{NN}-{name}.md` | `06-design-audit.md` |
| Orchestrator name | `{Vertical} Orchestrator` | `Design System Orchestrator` |
| Subagent name | `{Role} Agent` | `Design Audit Agent` |
| Pipeline type in state | `kebab-case` | `"pipeline": "design-system"` |
| Spec subfolder | `docs/specs/{task-slug}/` | `docs/specs/component-library/` |

Use the next available letter for orchestrators (`00c-`, `00d-`, ...) and the next available number for subagents (`06-`, `07-`, ...).

## Checklist

Before testing your vertical:

- [ ] Orchestrator file created with correct step count in rules, dashboard, and final summary
- [ ] All subagent files created, each with clear inputs/outputs/completion reporting
- [ ] `pipeline-state.json` format defined with correct step names and agents
- [ ] Resume detection section included in orchestrator
- [ ] Router updated with detection and dispatch for your vertical
- [ ] README.md updated (directory tree, both agent tables)
- [ ] Error handling covers all subagent steps
- [ ] Approval gates added where user review is needed
- [ ] No subagent tries to ask the user questions directly
- [ ] Tested in a fresh Claude Code session (avoids context pollution from editing)

## Example Verticals

Ideas for verticals the community could build:

| Vertical | Steps | Key Subagents |
|----------|-------|---------------|
| Design System | 6 | Design Audit, Component Spec, Implementation, Visual Review, Storybook Docs |
| Data Pipeline | 5 | Schema Discovery, Transform Spec, Pipeline Build, Data Validation, Lineage Docs |
| Infrastructure | 5 | Infra Audit, Architecture Spec, IaC Generation, Security Review, Runbook Docs |
| Mobile App | 7 | Platform Analysis, Screen Spec, API Contract, Implementation, UI Review, Testing, Store Listing |
| API Migration | 6 | Legacy Analysis, Contract Mapping, Scaffold, Migration, Compatibility Testing, Changelog |
