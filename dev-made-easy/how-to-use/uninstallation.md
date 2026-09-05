# Uninstallation

Choose the method that matches how you installed the plugin.

---

## Claude Code Plugin Uninstall

If you installed via `claude plugin install`:

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

---

## Manual Uninstall

If you installed via `install.sh`:

```bash
cd ~/.claude/skills/agentic-development/dev-made-easy

bash install.sh --uninstall --global         # remove from ~/.claude/agents/
bash install.sh --uninstall --local          # remove from .claude/agents/ in current project
bash install.sh --uninstall --path /path/to/repo  # remove from a specific repo
```

---

## What Gets Removed

| Method | Files removed | Files kept |
|--------|--------------|------------|
| Plugin uninstall | Plugin cache at `~/.claude/plugins/cache/agentic-development/` | Cloned repo (step 3 is optional) |
| Marketplace remove | Marketplace registration entry | Everything else |
| `rm -rf` clone | Source repo at `~/.claude/skills/agentic-development/` | Plugin cache (already removed in step 1) |
| Manual `--uninstall` | Agent `.md` files from target `agents/` directory | Source clone |

After uninstalling, run `/reload-plugins` inside any active Claude Code session to clear loaded agents.
