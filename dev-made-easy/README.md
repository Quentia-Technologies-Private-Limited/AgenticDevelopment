# dev-made-easy

A multi-agent development pipeline for Claude Code. Supports two modes: **Greenfield** (new projects) and **Feature Addition** (existing projects). Takes a task description from planning through implementation, code review, testing, and documentation — producing structured artifacts at every stage.

## What It Does

The Orchestrator asks you upfront: **new project** or **feature addition**?

### Greenfield Mode (New Project — 7 steps)

```
Orchestrator → Planning Analysis Agent → [TECH DECISIONS] → Planning Specs Agent
            → [YOUR REVIEW] → Development → [YOUR REVIEW]
            → Code Review → Testing → Documentation
```

### Feature Addition Mode (Existing Project — 8 steps)

```
Orchestrator → Codebase Analysis Agent → Planning Analysis Agent → [TECH GAP ANALYSIS]
            → Planning Specs Agent → [YOUR REVIEW] → Development → [YOUR REVIEW]
            → Code Review → Testing → Documentation
```

In Feature Addition mode, the pipeline first scans your existing codebase, then plans the feature in context, only asks about tech gaps (not the full stack), and ensures all new code follows your existing patterns.

| Agent | Role | Output |
|-------|------|--------|
| Development Orchestrator | Router: determines new vs. existing project, dispatches to correct pipeline | — |
| Greenfield Orchestrator | Coordinates 7-step pipeline for new projects, asks tech questions | Status dashboard |
| Feature Addition Orchestrator | Coordinates 8-step pipeline for existing projects, does tech gap analysis | Status dashboard |
| Codebase Analysis Agent | Scans existing project: tech stack, patterns, schema, API, tests. Outputs to `docs/codebase/` | `00-codebase-analysis.md` + `codebase-graph.json` |
| Planning Analysis Agent | System analysis, product spec, acceptance criteria (tech-independent) | `00-technical-analysis.md`, `01-product-spec.md`, `02-acceptance-criteria.md` |
| Planning Specs Agent | DB schema, API contracts using confirmed tech stack (tech-dependent) | `03-tech-decisions.md`, `04-db-schema.md`, `05-api-contracts.md` |
| Development Agent | Implements code, follows existing patterns in Feature Addition mode | Source code + implementation notes |
| Code Review Agent | Reviews against spec, security, quality, and codebase consistency | `07-review-report.md` |
| Testing Agent | Tests against acceptance criteria, triages issues | `issues/issue-NNN.md` per bug |
| Documentation Agent | README, API docs, CHANGELOG, docstrings (updates existing docs in Feature Addition) | Project documentation |

## How the Plugin Works

### What is this "plugin"?

In Claude Code, an **agent** is a `.md` file that defines an AI specialist — its name, the model it uses, and its instructions. Claude Code automatically discovers and loads any `.md` file placed in a `.claude/agents/` directory.

A **plugin** in this context is a curated, distributable collection of related agents bundled together in a GitHub repository. There is no binary to compile, no package to publish to a registry, and no build step. The repository itself is the plugin.

```
dev-made-easy/               ← this repo IS the plugin
├── .claude-plugin/
│   ├── plugin.json          ← official Claude Code plugin manifest
│   └── marketplace.json     ← marketplace manifest for plugin distribution
├── agents/
│   ├── 00-orchestrator.md          ← smart router: asks new vs. existing, dispatches
│   ├── 00a-orchestrator-greenfield.md  ← Greenfield pipeline (7 steps)
│   ├── 00b-orchestrator-feature.md     ← Feature Addition pipeline (8 steps)
│   ├── 01-codebase-analysis.md     ← scans existing project (Feature Addition only)
│   ├── 01a-planning-analysis.md    ← Phase 1: tech-independent analysis
│   ├── 01b-planning-specs.md       ← Phase 2: tech-dependent specs
│   ├── 02-development.md
│   ├── 03-code-review.md
│   ├── 04-testing.md
│   └── 05-documentation.md
└── install.sh               ← manual fallback installer
```

### How installation works

`install.sh` copies the `agents/*.md` files into Claude Code's agent discovery directory:

```
~/.claude/agents/             ← global:  Claude Code reads this in every project
.claude/agents/               ← local:   Claude Code reads this only in this project
<custom-path>/.claude/agents/ ← custom:  Claude Code reads this in that specific project
```

Once the files are there, Claude Code picks them up automatically — no restart needed.
You can verify installed agents by running `/agents` in the Claude Code CLI.

### Agent file anatomy

```markdown
---
name: Agent Name            ← how you invoke it: /agent "Agent Name"
description: >              ← shown when browsing agents; helps Claude Code
  What it does.               suggest the right agent automatically
  Can be used standalone.
model: claude-opus-4-6      ← change this per-agent to suit cost/quality needs
---

# Agent Name

(Plain-English instructions that tell the agent exactly what to do,
 what files to read, what files to write, and how to report back.)
```

### Plugin structure at a glance

| File | Purpose |
|------|---------|
| `.claude-plugin/plugin.json` | Official Claude Code plugin manifest — name, version, description |
| `.claude-plugin/marketplace.json` | Marketplace manifest — required for `claude plugin marketplace add` |
| `agents/*.md` | The agents — edit these to customise behaviour |
| `install.sh` | Manual fallback installer (alternative to `claude plugin install`) |
| `README.md` | Documentation for users of the plugin |

## Requirements

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code)
- Claude account with API access

## Installation

This repo is a proper Claude Code plugin. It contains a `.claude-plugin/plugin.json` manifest that Claude Code reads natively via its plugin system.

### Recommended — Claude Code plugin install (official)

```bash
# 1. Clone into Claude's skills directory
git clone https://github.com/Quentia-Technologies-Private-Limited/AgenticDevelopment.git ~/.claude/skills/agentic-development

# 2. Register the marketplace (one-time setup)
claude plugin marketplace add ~/.claude/skills/agentic-development/dev-made-easy --scope user

# 3. Install the plugin
claude plugin install dev-made-easy@agentic-development --scope user
```

**4. Activate inside Claude Code** — open Claude Code in any project (`claude` in terminal), then run:

```
/reload-plugins
```

```bash
# 5. Verify it loaded
claude plugin list
```

**Install scopes:**

| Scope | Command | Effect |
|-------|---------|--------|
| `user` | `--scope user` | Available in all your projects (default) |
| `project` | `--scope project` | This project only — committed to repo, shared with team |
| `local` | `--scope local` | This project only — not committed, not shared |

```bash
# Project scope (team shared)
claude plugin marketplace add ~/.claude/skills/agentic-development/dev-made-easy --scope project
claude plugin install dev-made-easy@agentic-development --scope project

# Local scope (personal, not committed)
claude plugin marketplace add ~/.claude/skills/agentic-development/dev-made-easy --scope local
claude plugin install dev-made-easy@agentic-development --scope local
```

### Alternative — manual install script

If you prefer not to use the plugin system, the included `install.sh` copies agent files directly:

```bash
git clone https://github.com/Quentia-Technologies-Private-Limited/AgenticDevelopment.git
cd AgenticDevelopment/dev-made-easy

bash install.sh --global               # ~/.claude/agents/ — all projects
bash install.sh --local                # .claude/agents/  — current project only
bash install.sh --path /path/to/repo   # <path>/.claude/agents/ — another repo
bash install.sh                        # interactive prompt
```

> The plugin install method is preferred as Claude Code manages versioning and scope automatically.

## Usage

### Step 1 — Create your project folder

```bash
mkdir ~/Documents/GitHub/MyProject
```

### Step 2 — Open Claude Code in that folder

```bash
cd ~/Documents/GitHub/MyProject
claude
```

### Step 3 — Invoke the Orchestrator with your task description

In the Claude Code session, use the plugin prefix and paste your task description in the same message:

```
@dev-made-easy:Development Orchestrator

Build a backend API for a personal task management system. Users can register
and log in, then create and manage projects and tasks within those projects.

Core Features:
- User registration and login with JWT authentication
- Create, read, update, and delete projects
- Create tasks with title, description, due date, priority, and status
- List tasks with filtering by status and priority
- Mark a task as complete
- Delete completed tasks in bulk per project
```

> **Note:** The plugin prefix `dev-made-easy:` is required when agents are installed via the plugin system. Do not use `/agent "..."` or `@"..."` (with quotes around the full string) — both will fail.

The orchestrator will first ask: **new project or feature addition?**

**Greenfield** (new project):
1. Run the **Planning Analysis Agent** — produces technical analysis, product spec, and acceptance criteria
2. Ask you **3 groups of technology questions** informed by the analysis (backend, data, infrastructure)
3. Run the **Planning Specs Agent** — produces tech-decisions, db schema, and API contracts using your confirmed choices
4. Pause for your review of all planning artifacts
5. Run Development (pauses for review), then auto-chain Code Review → Testing → Documentation

**Feature Addition** (existing project):
1. Run the **Codebase Analysis Agent** — scans your project for tech stack, patterns, schema, API, tests
2. Run the **Planning Analysis Agent** — plans the feature in context of the existing codebase
3. **Tech Gap Analysis** — compares what exists vs. what the feature needs, only asks about gaps
4. Run the **Planning Specs Agent** — produces incremental schema changes and new API endpoints only
5. Pause for your review of all planning artifacts
6. Run Development (follows existing patterns, pauses for review), then auto-chain Code Review → Testing → Documentation

## Artifact Structure

Every task produces artifacts in `docs/specs/{task_title}/`:

### Greenfield Mode

```
docs/specs/{task_title}/
├── 00-technical-analysis.md    ← system analysis for tech recommendations
├── 01-product-spec.md          ← product spec and user stories
├── 02-acceptance-criteria.md   ← Given/When/Then acceptance criteria
├── 03-tech-decisions.md           ← confirmed technology choices
├── 04-db-schema.md             ← full database schema
├── 05-api-contracts.md         ← full API contracts
├── 06-implementation-notes.md
├── 07-review-report.md
└── issues/
    ├── issue-001.md
    └── issue-002.md
```

### Feature Addition Mode

```
docs/codebase/                          ← global codebase memory (shared across all pipelines)
├── 00-codebase-analysis.md             ← existing project analysis (tech, patterns, schema, API)
└── codebase-graph.json                 ← machine-queryable dependency graph

docs/specs/{feature_name}/              ← feature-specific specs
├── 00-technical-analysis.md            ← feature analysis referencing existing codebase
├── 01-product-spec.md                  ← feature-scoped product spec
├── 02-acceptance-criteria.md           ← feature-scoped acceptance criteria
├── 03-tech-decisions.md                   ← full stack (existing + new, marked)
├── 04-db-schema.md                     ← incremental schema changes only
├── 05-api-contracts.md                 ← new/modified endpoints only
├── 06-implementation-notes.md
├── 07-review-report.md
└── issues/
    ├── issue-001.md
    └── issue-002.md
```

## Technology Decisions

The Orchestrator asks you about technology choices **after** the Planning Analysis Agent analyzes your system requirements. This means recommendations are informed by your actual needs — not generic defaults. The defaults below are only used if you say "defaults" or "I don't know":

| Layer | Default |
|-------|---------|
| Backend | Python / FastAPI |
| Frontend | Next.js |
| Database | PostgreSQL |
| Cache | Redis |
| Auth | JWT |
| Container | Docker Compose |

## Design Principles Enforced

- **OOP with Factory Pattern** — all services created via `ServiceFactory`
- **Repository Pattern** — DB access separated from business logic
- **SOLID Principles** — applied across all generated code
- **Layer Separation** — API → Service → Repository → Database

## Issue Triage

The Testing Agent scores every bug on four dimensions (1–5):

| Dimension | High Score Means |
|-----------|-----------------|
| Impact | System broken or data loss |
| Feasibility to Fix | Simple or trivial fix |
| Customer Experience | Blocks core user flow |
| Revenue Impact | Direct revenue loss |

Issues scoring (Impact >= 4 AND CX >= 4) or (Revenue >= 4) are marked **MANDATORY**.

## Models

All agents use `claude-opus-4-6` by default. To switch models, edit the `model:` field at the top of any agent file in `agents/`.

## Agent Files

| File | Agent Name | Role |
|------|-----------|------|
| `agents/00-orchestrator.md` | Development Orchestrator | Router: asks new vs. existing, dispatches to correct pipeline |
| `agents/00a-orchestrator-greenfield.md` | Greenfield Orchestrator | Greenfield pipeline (7 steps) |
| `agents/00b-orchestrator-feature.md` | Feature Addition Orchestrator | Feature Addition pipeline (8 steps) |
| `agents/01-codebase-analysis.md` | Codebase Analysis Agent | Feature Addition Step 1: scans existing project |
| `agents/01a-planning-analysis.md` | Planning Analysis Agent | Greenfield Step 1 / Feature Addition Step 2: tech-independent analysis |
| `agents/01b-planning-specs.md` | Planning Specs Agent | Greenfield Step 3 / Feature Addition Step 4: tech-dependent specs |
| `agents/02-development.md` | Development Agent | Greenfield Step 4 / Feature Addition Step 5: implementation |
| `agents/03-code-review.md` | Code Review Agent | Greenfield Step 5 / Feature Addition Step 6: code review |
| `agents/04-testing.md` | Testing Agent | Greenfield Step 6 / Feature Addition Step 7: testing |
| `agents/05-documentation.md` | Documentation Agent | Greenfield Step 7 / Feature Addition Step 8: documentation |

## Updating the Plugin

When new agent versions are pushed to the repository, run these 4 steps to pick up the changes:

```bash
# 1. Pull latest from GitHub into your local clone
cd ~/.claude/skills/agentic-development && git pull

# 2. Force-clear the plugin cache (IMPORTANT — claude plugin update alone is unreliable)
cp ~/.claude/skills/agentic-development/dev-made-easy/agents/*.md \
   ~/.claude/plugins/cache/agentic-development/dev-made-easy/1.0.0/agents/

# 3. Also run the official update command (for metadata/manifest changes)
claude plugin update dev-made-easy@agentic-development
```

Then inside your Claude Code session:

```
# 4. Reload plugins to activate
/reload-plugins
```

**Why 4 steps?**

| Step | What it does | Without it |
|------|-------------|------------|
| `git pull` | Updates the local clone from GitHub | Local clone still has old agent files |
| `cp ... agents/` | Force-copies agent files into the plugin cache | **Cache keeps stale agents** even after `plugin update` |
| `plugin update` | Updates plugin metadata and manifest | Manifest may be out of date |
| `/reload-plugins` | Loads the updated cache into the active session | Session still runs old agents |

> **Why is step 2 needed?** `claude plugin update` does not always copy updated agent files into the plugin cache at `~/.claude/plugins/cache/`. The `cp` command guarantees the cache has the latest agents. This is a known workaround.

### Verify the update worked

After completing all 4 steps, verify the cache matches the source:

```bash
# Should produce no output (no differences)
diff ~/.claude/skills/agentic-development/dev-made-easy/agents/00-orchestrator.md \
     ~/.claude/plugins/cache/agentic-development/dev-made-easy/1.0.0/agents/00-orchestrator.md
```

> You never need to uninstall/reinstall unless `marketplace.json` or `plugin.json` structure changes.

## Uninstallation

### Claude Code plugin uninstall (if installed via plugin system)

```bash
# Step 1 — Uninstall the plugin
claude plugin uninstall dev-made-easy@agentic-development --scope user

# Step 2 — Remove the marketplace registration
claude plugin marketplace remove agentic-development

# Step 3 — Optionally delete the cloned repo
rm -rf ~/.claude/skills/agentic-development
```

If you installed with a different scope, use the matching scope in step 1:

```bash
# Project scope
claude plugin uninstall dev-made-easy@agentic-development --scope project

# Local scope
claude plugin uninstall dev-made-easy@agentic-development --scope local
```

### Manual uninstall (if installed via install.sh)

```bash
cd ~/.claude/skills/agentic-development/dev-made-easy

bash install.sh --uninstall --global         # remove from ~/.claude/agents/
bash install.sh --uninstall --local          # remove from .claude/agents/ in current project
bash install.sh --uninstall --path /path/to/repo  # remove from a specific repo
```

### How to create a new vertical (custom pipeline)

Want to add a pipeline for a different domain (Design, Data Engineering, DevOps, Mobile)?

See **[docs/README.md](./docs/AddUrOwnOrchestrator.md)** — a step-by-step guide with templates for creating your own orchestrator and subagents, registering with the router, and testing.

### How to create or extend your own plugin

Want to fork this or build your own? Here is how:

1. **Fork or clone** this repository

2. **Edit an existing agent** — each `.md` file has a YAML frontmatter block at the top
   and plain-English instructions below. Change the instructions, model, or description:
   ```markdown
   ---
   name: My Custom Agent
   description: What this agent does and when Claude Code should suggest it.
   model: claude-opus-4-6
   ---

   # My Custom Agent

   You are... (your instructions here)
   ```

3. **Add a new agent** — create a new `.md` file in `agents/` following the same structure.
   The `name:` field is what you use to invoke it: `/agent "My Custom Agent"`

4. **Test locally** — run `bash install.sh --local` inside any project and invoke
   the agent with `/agent "My Custom Agent"` to verify it works

5. **Publish** — push your fork to GitHub. Anyone can install it by cloning the repo
   and running `bash install.sh`

## License

MIT
