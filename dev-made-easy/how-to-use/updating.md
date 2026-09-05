# Updating the Plugin

When new agent versions are pushed to the repository, run these 4 steps to pick up the changes.

---

## Update Steps

```bash
# 1. Pull latest from GitHub into your local clone
cd ~/.claude/skills/agentic-development && git pull

# 2. Force-sync agents into the plugin cache (auto-detects version directory)
bash dev-made-easy/install.sh --update-cache

# 3. Also run the official update command (for metadata/manifest changes)
claude plugin update dev-made-easy@agentic-development
```

Then inside your Claude Code session:

```
# 4. Reload plugins to activate
/reload-plugins
```

---

## Why 4 Steps?

| Step | What it does | Without it |
|------|-------------|------------|
| `git pull` | Updates the local clone from GitHub | Local clone still has old agent files |
| `--update-cache` | Force-copies agents into the plugin cache and verifies with `diff` | **Cache keeps stale agents** even after `plugin update` |
| `plugin update` | Updates plugin metadata and manifest | Manifest may be out of date |
| `/reload-plugins` | Loads the updated cache into the active session | Session still runs old agents |

> **Why is step 2 needed?** `claude plugin update` does not always copy updated agent files into the plugin cache at `~/.claude/plugins/cache/`. The `--update-cache` flag auto-detects the versioned cache directory, copies all agents, and verifies each file matches. This is more reliable than a manual `cp` with a hardcoded version path.

---

## Verify the Update

After completing all 4 steps, verify the cache matches the source:

The `--update-cache` flag already runs `diff` verification automatically. If all agents match, you'll see:

```
checkmark Verification passed — all agents match
```

If any mismatch is reported, re-run step 2 (`bash dev-made-easy/install.sh --update-cache`).

> You never need to uninstall/reinstall unless `marketplace.json` or `plugin.json` structure changes.
