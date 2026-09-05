# Installation

This plugin can be installed via the official Claude Code plugin system (recommended) or manually using the included install script.

---

## Recommended: Claude Code Plugin Install

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

### Install Scopes

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

---

## Alternative: Manual Install Script

If you prefer not to use the plugin system, the included `install.sh` copies agent files directly:

```bash
git clone https://github.com/Quentia-Technologies-Private-Limited/AgenticDevelopment.git
cd AgenticDevelopment/dev-made-easy

bash install.sh --global               # ~/.claude/agents/ — all projects
bash install.sh --local                # .claude/agents/  — current project only
bash install.sh --path /path/to/repo   # <path>/.claude/agents/ — another repo
bash install.sh                        # interactive prompt
```

---

## File Locations After Install

After a successful plugin install, agent files exist in three locations:

| Location | Purpose |
|----------|---------|
| `~/.claude/skills/agentic-development/dev-made-easy/agents/` | Source clone (git-managed) |
| `~/.claude/plugins/cache/agentic-development/dev-made-easy/1.0.0/agents/` | Plugin cache (runtime copy) |
| `~/.claude/skills/dev-made-easy/agents/` | Skills symlink (auto-created) |

All three must stay in sync. See [updating.md](updating.md) for how to keep them aligned.

---

## Verify Installation

```bash
# List installed plugins — dev-made-easy should appear
claude plugin list

# Check agents are accessible inside a Claude Code session
# Type this inside Claude Code:
/reload-plugins
```

Then invoke the orchestrator:

```
@dev-made-easy:Development Orchestrator <your task description>
```
