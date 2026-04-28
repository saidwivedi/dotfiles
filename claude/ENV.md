# HPC Environment

Template — fill in with your cluster-specific paths and conventions. Loaded into `CLAUDE.md` via `@~/.claude/ENV.md`.

## Cluster
- Filesystem: `<FILESYSTEM_TYPE>` at `<CLUSTER_ROOT>/`
- Package manager: `<PKG_MANAGER>` (e.g. micromamba) — never use system conda or global pip
- `MAMBA_ROOT_PREFIX=<MAMBA_ROOT>`
- Python envs: `<ENVS_ROOT>/`
- Always call the env's binary directly (`<ENVS_ROOT>/<env>/bin/python`), never `<pkg> activate <env> && python ...`. Same for `pip`, `pytest`, etc.
- Pretrained models: `<WORK_ROOT>/pretrained_models/`
- Work directory: `<WORK_ROOT>/`

## Filesystem Gotchas
- Some networked filesystems (e.g. Lustre, CIFS) do not support `flock` — HuggingFace Hub direct downloads can hang indefinitely
- Workaround: use `modelscope download` or `huggingface-cli download --local-dir` with `HF_HUB_DISABLE_IMPLICIT_TOKEN=1`
- Flash Attention install may require `--no-build-isolation` (cross-device link errors on some filesystems)
- Lock-file warnings (`FileSystem does not appear to support flock`) are usually harmless — ignore
- npm `ENOTEMPTY` errors on shared filesystems — retry once, usually clears

## CIFS/Network FS Edit Pattern
For files on networked filesystems where the editor sees stale `mtime`/cache, use copy-edit-copy:
1. Copy to local scratch: `cp <network_path>/file.py /tmp/edit-temp.py`
2. Edit `/tmp/edit-temp.py`
3. Copy back: `cp /tmp/edit-temp.py <network_path>/file.py`

This avoids "file modified externally" errors triggered by network filesystem cache timing.
