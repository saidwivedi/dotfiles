# 🖥️ Personal Dotfiles

A modern, feature-rich configuration for shell environments (zsh/bash), vim, and custom utility functions. Optimized for research/development workflows with remote cluster computing and machine learning experiments.

## 📂 Repository Structure

```
├── zshrc                      # Modern zsh configuration
├── bashrc                     # Bash configuration
├── vimrc                      # Vim configuration with enhanced Python support
├── functions/
│   ├── download_functions.zsh # Advanced rsync-based file transfer utilities
│   ├── remote_explorer.zsh    # SSHFS remote filesystem mounting
│   └── wandb_functions.zsh    # WandB experiment synchronization
├── claude/
│   ├── CLAUDE.md              # Global instructions for Claude Code
│   ├── ENV.md                 # HPC environment notes (template)
│   ├── settings.json          # Statusline + enabled plugins
│   ├── keybindings.json       # Custom key bindings
│   ├── statusline-hud.sh      # claude-hud statusline wrapper
│   ├── install.sh             # Installation script
│   └── README.md              # Setup and skills marketplace pointer
└── cmux/
    ├── connect                # Persistent workstation terminal (Tailscale + mosh + tmux)
    ├── workstation.tmux.conf  # Workstation tmux: workspace-name title + truecolor
    └── README.md              # connect + cmux setup and reproduction
```

## ⚙️ Configuration

Before using the remote utilities, configure your environment variables. Add these to your `~/.zshrc` or `~/.bashrc`:

```bash
# Remote server configuration (required for download_functions and wandb_functions)
export REMOTE_HOST="your-server.com"              # Your remote server hostname
export REMOTE_BASE_PATH="/path/to/remote/data"    # Base path for downloads

# Remote filesystem mounting (required for remote_explorer)
export REMOTE_USER="your-username"                # Your username on remote server
export REMOTE_DIR="/home/username"                # Remote directory to mount

# WandB synchronization (required for wandb_functions)
export WANDB_REMOTE_PATH="/path/to/wandb_logs"    # Path to wandb logs on remote
export WANDB_LOCAL_PATH="."                       # Local path for wandb logs (default: current directory)
```

Alternatively, you can edit the default values directly in each function file.

## ⚡ Key Features

### 🔧 Shell Configuration (zshrc/bashrc)

- **Modern prompt** with git integration and environment indicators
- **Micromamba/Conda** environment management
- **Enhanced history** with smart deduplication and sharing across sessions
- **Performance-optimized completions** with case-insensitive matching
- **Custom color schemes** optimized for light terminal backgrounds
- **Git workflow aliases** (`gll`, `gpush`, `gsu`, etc.)
- **Useful functions** (`mkcd`, `extract`, `compress_folder`, `weather`)

### 📝 Vim Configuration (vimrc)

- **Enhanced Python syntax highlighting** for NumPy, PyTorch, OpenCV
- **Smart commenting system** with `gcc` (toggle line) and `gc` (visual mode)
- **Advanced navigation** with window splitting, tab management
- **Plugin support** for NERDTree, FZF, ALE linting, AnyJump
- **Modern status line** with mode indicators and file info
- **Auto-extraction function** for various archive formats

### Claude Code Configuration (claude/)

Portable configuration for [Claude Code](https://github.com/anthropics/claude-code) CLI:

```bash
# Install on a new device
./claude/install.sh
```

**Contents:**
- **CLAUDE.md**: Global instructions and preferences (Identity section is a placeholder — fill in after install)
- **ENV.md**: HPC environment template (cluster paths, package manager, filesystem gotchas)
- **settings.json**: Statusline command and enabled plugins
- **keybindings.json**: Custom key bindings (e.g. `Ctrl+Shift+C` to copy in scroll mode)
- **statusline-hud.sh**: Wrapper that runs the [`claude-hud`](https://github.com/anthropics/claude-code) plugin and surfaces API error hints

Reusable skills (research collaborator, results-to-slides, paper-review, token-usage) live in a separate plugin marketplace: [`saidwivedi/research-skills`](https://github.com/saidwivedi/research-skills). See [`claude/README.md`](claude/README.md) for install steps.

**Note:** Sensitive data (history, session files, cache, credentials) is excluded from this repo.

### 📡 Workstation Access (connect + cmux)

`connect` turns a [cmux](https://cmux.com) terminal into a persistent, auto-resuming window onto a remote workstation over Tailscale — mosh+tmux when reachable (instant resume across sleep/roaming/outage), ssh+tmux otherwise, local shell when offline. Each cmux workspace maps to its own tmux session, and the sidebar name reflects what Claude (or any program) is running there.

```bash
cp cmux/connect ~/.local/bin/connect && chmod +x ~/.local/bin/connect
mkdir -p ~/.config/connect && printf 'WS_USER=you\nWS_TS_IP=100.x.y.z\n' > ~/.config/connect/config
```

See [`cmux/README.md`](cmux/README.md) for the full Mac + workstation reproduction steps.

### 📡 Download Functions (download_functions.zsh)

Advanced rsync-based file transfer system with visual progress tracking and wildcard support:

```bash
# Download single folder with preview
download_folder "experiment_results"

# Batch download multiple folders
dfs folder1 folder2 folder3

# Download folders with wildcard patterns
dfs 'results_*/2024*'          # All matching folders

# Fast batch download (skip previews)
dfs_fast folder1 folder2 folder3
```

**Features:**
- **Wildcard pattern support** (`*`, `?`, `[...]`) for bulk downloads
- **SSH connection sharing** (authenticate once per session)
- **Automatic pattern expansion** on remote server
- **Visual progress bars** with transfer speeds and ETA
- **Smart retry logic** with automatic resume
- **Intelligent size calculation** (GB/MB auto-formatting)
- **Preview scans** showing remaining files to download

### 🗂️ Remote Explorer (remote_explorer.zsh)

SSHFS-based remote filesystem mounting with performance modes:

```bash
# Standard mount (balanced performance)
remote_up

# Turbo mode (aggressive caching, ~100x faster)
remote_up_turbo

# Live mode (no caching, always fresh data)
remote_up_live

# Management commands
remote_status      # Check mount status
remote_open        # Open in file manager
remote_cd          # Navigate to mount
remote_refresh     # Clear cache and remount
remote_down        # Unmount
```

**Performance Modes:**
- **Balanced**: Good performance with reasonable memory usage
- **Turbo**: Maximum speed with 7-day caching (~50-100x faster)
- **Live**: Real-time updates, no caching (collaboration-friendly)

### 🧪 WandB Functions (wandb_functions.zsh)

Machine learning experiment synchronization for cluster environments:

```bash
# Sync recent experiments (last 2 hours)
sync_wandb

# Sync with custom time window
sync_wandb 6  # last 6 hours

# Check cluster status without syncing
check_wandb_cluster

# Sync only completed runs (avoid active experiments)
sync_wandb_completed 5  # older than 5 minutes
```

**Features:**
- **Intelligent time-based filtering** with timezone adjustment
- **Conflict resolution** for duplicate run IDs
- **Corruption detection** and handling
- **Selective syncing** (only modified experiments)
- **SSH connection multiplexing** to minimize authentication
