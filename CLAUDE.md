# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

trimtab is a Bash CLI toolkit for managing distributed AI-human collaboration across multiple projects and machines. Named after Buckminster Fuller's trim tab principle — small surfaces that steer large systems.

## Architecture

**Dispatcher pattern:** `bin/trimtab` resolves `trimtab <cmd>` to `bin/trimtab-{cmd}` via `exec`. All subcommands are standalone Bash scripts.

**Shared libraries** (sourced, not executed):
- `bin/trimtab-common.sh` — colors (R/G/D/B/C/Y/N), output functions (section/err/ok/skip/info/warn), `PROJECTS_DIR`, `_find_openrouter_key()`
- `bin/trimtab-portable.sh` — cross-platform shims for macOS/Linux (stat, date, readlink, proc cwd, listening ports, `_chezmoi_projects_prefix()`)

**Every subcommand** must `source` both libraries (portable first, then common). Colors are raw ANSI escapes — no tput dependency.

**Remote host system:** `~/.config/trimtab/hosts` stores `alias|ssh_host|remote_projects_dir` entries. Agent discovery runs a single SSH call per host to find containers, tmux panes, and orphan claude processes.

**Container system:** Podman-based, two images:
- `trimtab-agent` — Elixir+Node+Claude Code for development sessions
- QA agent — Chrome+browser-use+Claude/Goose for automated QA

Both use `--userns=keep-id` for volume ownership. SELinux hosts (Fedora) need `:Z` volume suffix — detected via `getenforce`, not distro name.

## Key Paths & Conventions

- `PROJECTS_DIR="$HOME/1-Projects"` — all projects live here, hardcoded across the toolkit
- Memory dirs: `~/.claude/projects/-{CHEZMOI_PREFIX}-{PROJ}/memory/` where CHEZMOI_PREFIX is the home path with `/` → `-` (e.g., `home-mchughson-1-Projects`)
- Hosts file: `${XDG_CONFIG_HOME:-$HOME/.config}/trimtab/hosts`
- Container names: `agent-{project}` prefix for discovery
- tmux session: `agents` for managed sessions

## Adding a New Subcommand

1. Create `bin/trimtab-{name}` (executable, `#!/usr/bin/env bash`)
2. Source both libraries: `source "$(dirname "$0")/trimtab-portable.sh"` then `source "$(dirname "$0")/trimtab-common.sh"`
3. Use `set -euo pipefail`
4. Use shared output functions (`section`, `err`, `ok`, etc.) — don't redefine them
5. Add to help text in `bin/trimtab`
6. Internal dispatch pattern: `subcmd="${1:-default}"; shift 2>/dev/null || true; case "$subcmd" in ...`

## Commands

| Command | Purpose |
|---------|---------|
| `trimtab status` | Phone-friendly env snapshot (<3s) |
| `trimtab dash` | Persistent tmux dashboard |
| `trimtab agent list\|spawn\|peek\|send\|broadcast\|auth\|attach\|build` | Manage Claude sessions (local + remote) |
| `trimtab observe [--since 24h] [--ai]` | Cross-project briefing |
| `trimtab steer audit\|gaps\|sync\|ux` | Audit infrastructure and UX patterns |
| `trimtab secrets scan\|audit\|fix` | Secret detection and .env hygiene |
| `trimtab qa run\|build\|list\|report` | Containerized QA runner |
| `trimtab init [dir]` | Bootstrap project quality stack |
| `trimtab init-host <alias> <ssh>` | Provision remote agent host |

## Common Pitfalls

- **Don't redefine colors/functions** — they come from common.sh. Every past bug in this area was duplicate definitions drifting out of sync.
- **Chezmoi prefix is machine-dependent** — never hardcode usernames in memory dir paths. Use `_chezmoi_projects_prefix()`.
- **`tmux send-keys` to Claude TUI needs delay** — send text first, `sleep 0.2`, then send Enter separately. Without the delay, Enter is consumed before the text is processed.
- **SELinux detection checks `getenforce`**, not `/etc/fedora-release`. A Fedora host with SELinux disabled shouldn't get `:Z` volume mounts.
- **Remote SSH commands use `BatchMode=yes`** with 3s timeout — they must never prompt for passwords.
- **The `--ai` flag** on observe/steer sync requires `OPENROUTER_API_KEY` found via `_find_openrouter_key()` which searches `.env` files in known project dirs and `$HOME/.env`.

## Testing Changes

No test suite — verify manually:

```bash
trimtab help                    # dispatcher + help text
trimtab status                  # sources common+portable correctly
trimtab steer audit             # chezmoi prefix resolution
trimtab steer ux                # LiveView pattern scanning
trimtab secrets audit           # .env hygiene table
trimtab agent list              # local + remote discovery
trimtab init --help             # project bootstrapping
```

After modifying shared libraries, test every subcommand that sources them — a broken common.sh breaks everything.
