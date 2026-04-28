# Claude Code Config

Personal Claude Code setup — global instructions, environment notes, and statusline.

## Install

```bash
./install.sh
```

Copies these files to `~/.claude/`:

| File                 | Purpose                                                      |
| -------------------- | ------------------------------------------------------------ |
| `CLAUDE.md`          | Global instructions loaded into every session                |
| `ENV.md`             | HPC environment notes, referenced from `CLAUDE.md` via `@`   |
| `settings.json`      | Statusline + enabled plugins                                 |
| `keybindings.json`   | Custom key bindings (`Ctrl+Shift+C` to copy in scroll mode)  |
| `statusline-hud.sh`  | Wrapper that runs `claude-hud` and surfaces error hints      |

After install, fill in the placeholders:
- `~/.claude/CLAUDE.md` — Identity section
- `~/.claude/ENV.md`    — cluster paths, package manager, work dirs

## Statusline (claude-hud)

The statusline is rendered by [`claude-hud`](https://github.com/anthropics/claude-code/tree/main/plugins/claude-hud), installed as a plugin. Enable it from inside Claude Code:

```
/plugin install claude-hud@claude-hud
```

`statusline-hud.sh` runs the plugin's `dist/index.js` with `DEBUG=claude-hud`, captures stderr to `~/.claude/claude-hud.log`, and appends a `→ tail <log>` hint when the HUD reports an API error (network, timeout, http-4xx) — so transient issues are visible without leaving the prompt.

## Skills

Project-agnostic skills (research collaborator, results-to-slides, token-usage, paper-review) live in a separate repo and are installed as a plugin marketplace:

- **`saidwivedi/research-skills`** — https://github.com/saidwivedi/research-skills

Add the marketplace and enable the plugins from inside Claude Code:

```
/plugin marketplace add saidwivedi/research-skills
/plugin install research-collaborator@research-skills
/plugin install results-to-slides@research-skills
/plugin install token-usage@research-skills
```
