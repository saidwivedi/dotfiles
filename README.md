# 🖥️ Personal Dotfiles

A modern, feature-rich configuration for shell environments (zsh/bash), vim, and custom utility functions. Optimized for research/development workflows with remote cluster computing and machine learning experiments.

## 📂 Repository Structure

```
├── zshrc                      # Modern zsh configuration
├── bashrc                     # Bash configuration
├── vimrc                      # Vim configuration with enhanced Python support
└── functions/
    ├── download_functions.zsh # Advanced rsync-based file transfer utilities
    ├── remote_explorer.zsh    # SSHFS remote filesystem mounting
    └── wandb_functions.zsh    # WandB experiment synchronization
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
