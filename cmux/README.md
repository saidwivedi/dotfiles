# Workstation access (connect + cmux)

Turn a [cmux](https://cmux.com) terminal on a Mac into a persistent, auto-resuming
window onto a remote workstation. When the cmux app is running, `connect` opens a
cmux-managed remote workspace (`cmux mosh-tmux`): mosh survives roaming, sleep, and
network outages, and the Files sidebar / diff view track the **remote** working
directory. Outside cmux (or with `CONNECT_LEGACY=1`) it falls back to inline
mosh/ssh + tmux.

```
Mac (cmux)  ──connect─▶  Tailscale  ──mosh/ssh──▶  workstation (tmux sessions)
   ▲                                                        │
   └────────── workspace name ◀── terminal title ◀──────────┘
```

## Files

| File | Goes where | Purpose |
|------|------------|---------|
| `connect` | Mac `~/.local/bin/connect` | cmux mosh-tmux → mosh+tmux → ssh+tmux → local shell |
| `cmux-edit` | Mac `~/.local/bin/cmux-edit` | preferredEditor hook: sidebar double-click opens the file in vim in a split |
| `workstation.tmux.conf` | Workstation `~/.tmux.conf` | Workspace-name title + truecolor passthrough + light-theme cosmetics |

## Usage

```bash
connect              # new cmux workspace + fresh tmux session every time
connect gpu          # create/reattach a named session
connect --resume     # pick a running session on the workstation and reattach
connect status       # reachability + transport selection
CONNECT_LEGACY=1 connect   # force the old inline mosh/ssh+tmux transport
```

## Reproduce on a new Mac

```bash
# 1. cmux
brew tap manaflow-ai/cmux && brew install --cask cmux
sudo ln -sf /Applications/cmux.app/Contents/Resources/bin/cmux /usr/local/bin/cmux

# 2. connect + editor hook
cp cmux/connect cmux/cmux-edit ~/.local/bin/ && chmod +x ~/.local/bin/{connect,cmux-edit}
mkdir -p ~/.config/connect && cat > ~/.config/connect/config <<'EOF'
WS_USER=youruser
WS_TS_IP=100.x.y.z          # tailscale ip -4   (run on the workstation)
WS_MOSH_SERVER=mosh-server  # legacy inline path only; absolute path if not on PATH
EOF
# enable instant-resume once mosh UDP (60000-61000) is reachable over Tailscale:
#   touch ~/.config/connect/mosh-ok
```

In **cmux Settings**, enable the **Remote tmux** beta toggle (required for the
`cmux mosh-tmux` transport). For sidebar double-click → vim, add to
`~/.config/cmux/cmux.json`:

```json
"app":          { "preferredEditor": "/Users/youruser/.local/bin/cmux-edit" },
"fileExplorer": { "doubleClickAction": "preferredEditor" }
```

On the **workstation**, install Tailscale + mosh + **tmux ≥ 3.2** (required by
remote tmux; if the distro tmux is older, drop a tmux AppImage at
`~/.local/bin/tmux` — `connect --resume` looks for it there), then append
`workstation.tmux.conf` to `~/.tmux.conf`.

## Colors & truecolor

cmux uses its built-in **light** theme by default — there is no custom palette to copy.
Your prompt, `ls`, and git colors come from `zshrc` (256-color ANSI codes), so they look
the same on any machine. For 24-bit **truecolor** (vim themes, etc.) inside a tmux
workspace, `connect` sets `COLORTERM=truecolor` and `workstation.tmux.conf` enables
tmux's RGB passthrough (`terminal-overrides ",*:Tc"`), plus copy-mode selection colors
and blue italics tuned for the light theme. To customize the terminal palette itself,
create `~/.config/ghostty/config` on the Mac; cmux reads it on `reload-config`.
