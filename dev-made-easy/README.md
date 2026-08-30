# dev-made-easy

A multi-agent development pipeline for Claude Code. Takes a task description from planning through implementation, code review, testing, and documentation — producing structured artifacts at every stage.

## What It Does

```
Orchestrator → Planning → [YOUR REVIEW] → Development → [YOUR REVIEW]
            → Code Review → Testing → Documentation
```

| Agent | Role | Output |
|-------|------|--------|
| Orchestrator | Coordinates pipeline, shows live status | Status dashboard |
| Planning | Product spec, DB schema, API contracts, acceptance criteria | `docs/specs/{task}/` |
| Development | Implements code with OOP/Factory Pattern | Source code + implementation notes |
| Code Review | Reviews against spec, security, quality | `06-review-report.md` |
| Testing | Tests against acceptance criteria, triages issues | `issues/issue-NNN.md` per bug |
| Documentation | README, API docs, CHANGELOG, docstrings | Project documentation |

## How the Plugin Works

### What is this "plugin"?

In Claude Code, an **agent** is a `.md` file that defines an AI specialist — its name, the model it uses, and its instructions. Claude Code automatically discovers and loads any `.md` file placed in a `.claude/agents/` directory.

A **plugin** in this context is a curated, distributable collection of related agents bundled together in a GitHub repository. There is no binary to compile, no package to publish to a registry, and no build step. The repository itself is the plugin.

```
dev-made-easy/               ← this repo IS the plugin
├── .claude-plugin/
│   └── plugin.json          ← official Claude Code plugin manifest
├── agents/
│   ├── 00-orchestrator.md   ← each .md file is one agent
│   ├── 01-planning.md
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
git clone https://github.com/{your-username}/dev-made-easy.git ~/.claude/skills/dev-made-easy

# 2. Install globally (available in all your projects)
claude plugin install dev-made-easy@skills-dir --scope user

# 3. Verify it loaded
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
claude plugin install dev-made-easy@skills-dir --scope project

# Local scope (personal, not committed)
claude plugin install dev-made-easy@skills-dir --scope local
```

### Alternative — manual install script

If you prefer not to use the plugin system, the included `install.sh` copies agent files directly:

```bash
git clone https://github.com/{your-username}/dev-made-easy.git
cd dev-made-easy

bash install.sh --global               # ~/.claude/agents/ — all projects
bash install.sh --local                # .claude/agents/  — current project only
bash install.sh --path /path/to/repo   # <path>/.claude/agents/ — another repo
bash install.sh                        # interactive prompt
```

> The plugin install method is preferred as Claude Code manages versioning and scope automatically.

## Usage

Open Claude Code in your project directory and invoke the orchestrator:

```
/agent "Development Orchestrator"
```

You will be prompted for a task description, e.g.:

> "Build a user authentication system with JWT tokens and email verification"

The orchestrator will:
1. Derive a slug (`user-authentication-system-jwt-tokens`)
2. Create `docs/specs/user-authentication-system-jwt-tokens/`
3. Run the full pipeline with two approval gates (after Planning and Development)
4. Auto-chain Code Review → Testing → Documentation

## Artifact Structure

Every task produces:

```
docs/specs/{task_title}/
├── 01-product-spec.md
├── 02-acceptance-criteria.md
├── 03-db-schema.md
├── 04-api-contracts.md
├── 05-implementation-notes.md
├── 06-review-report.md
└── issues/
    ├── issue-001.md
    └── issue-002.md
```

## Technology Defaults

You can override any of these when the Development Agent prompts you:

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

| File | Agent Name |
|------|-----------|
| `agents/00-orchestrator.md` | Development Orchestrator |
| `agents/01-planning.md` | Planning Agent |
| `agents/02-development.md` | Development Agent |
| `agents/03-code-review.md` | Code Review Agent |
| `agents/04-testing.md` | Testing Agent |
| `agents/05-documentation.md` | Documentation Agent |

## License

MIT
