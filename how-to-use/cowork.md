# CoWork (Hosted Sessions)

CoWork is the Claude desktop app's hosted environment for running Claude Code sessions with plugins.

---

## 1. Installation

1. Open the Claude desktop app and go to the **Cowork** tab.
2. In the sidebar, click **Customize** and then **Plugins**.
3. Under **Personal plugins**, click **+** and then **Add marketplace**.
4. Choose **Add from a repository** and enter:
   ```
   https://github.com/Quentia-Technologies-Private-Limited/AgenticDevelopment
   ```
5. Turn off Auto Sync off
6. Your plugin now appears in the plugin list. Click Add and **Install**.

Open the plugin to check its skills, agents, and hooks. 

---

## 2. Usage

Start a Cowork task and type `/` or click **+** to see the plugin's skills and commands.

The dev-made-easy plugin is invoked via the slash command:

```
/dev {task description}
```

For example:

```
/dev Build a weather app with location search and 7-day forecast
```

---

## 3. Uninstallation

1. Go to **Customize** > **Plugins**.
2. Open your plugin and click **Uninstall**.
3. If you're done with the repo as well, click the **...** menu on the marketplace and choose **Remove**.

> **Note:** Uninstall the plugin first, then remove the marketplace. Removing a marketplace may not automatically remove the plugins you installed from it.

---

## 4. Updating

**In your repo:**

- Bump `version` in `plugin.json` and push to the default branch.
- If `version` is set and doesn't change, you may keep getting the old copy.
- You can also leave `version` out, so every commit counts as a new version.

**In Cowork:**

1. Go to **Customize** > **Plugins**.
2. Find your marketplace and click **Update**.
3. Open the plugin and check that the new version is showing.
