# Workstation access (connect + cmux)

Turn a [cmux](https://cmux.com) terminal on a Mac into a persistent, auto-resuming
window onto a remote workstation, with each cmux workspace bound to its own tmux
session and the sidebar name reflecting what Claude (or any program) is doing there.

```
Mac (cmux)  ──connect─▶  Tailscale  ──mosh/ssh──▶  workstation (tmux sessions)
   ▲                                                        │
   └────────── workspace name ◀── terminal title ◀──────────┘
```

## Files

| File | Goes where | Purpose |
|------|------------|---------|
| `connect` | Mac `~/.local/bin/connect` | mosh+tmux → ssh+tmux → local shell |
| `workstation.tmux.conf` | Workstation `~/.tmux.conf` | Workspace-name title + truecolor passthrough |

## Reproduce on a new Mac

```bash
# 1. cmux
brew tap manaflow-ai/cmux && brew install --cask cmux
sudo ln -sf /Applications/cmux.app/Contents/Resources/bin/cmux /usr/local/bin/cmux

# 2. connect
cp cmux/connect ~/.local/bin/connect && chmod +x ~/.local/bin/connect
mkdir -p ~/.config/connect && cat > ~/.config/connect/config <<'EOF'
WS_USER=youruser
WS_TS_IP=100.x.y.z          # tailscale ip -4   (run on the workstation)
WS_MOSH_SERVER=mosh-server  # or an absolute path on the workstation
EOF
# enable instant-resume once mosh UDP (60000-61000) is reachable over Tailscale:
#   touch ~/.config/connect/mosh-ok
```

On the **workstation**, install Tailscale + mosh + tmux, then append
`workstation.tmux.conf` to `~/.tmux.conf`.

Launch by running `connect` in a cmux terminal (`connect status` shows reachability).

## Colors & truecolor

cmux uses its built-in **light** theme by default — there is no custom palette to copy.
Your prompt, `ls`, and git colors come from `zshrc` (256-color ANSI codes), so they look
the same on any machine. For 24-bit **truecolor** (vim themes, etc.) inside a tmux
workspace, `connect` sets `COLORTERM=truecolor` and `workstation.tmux.conf` enables
tmux's RGB passthrough (`terminal-overrides ",*:Tc"`). To customize the terminal palette
itself, create `~/.config/ghostty/config` on the Mac; cmux reads it on `reload-config`.
