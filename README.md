# trimtab

> *Find the small surface that steers the ship.*

A methodology and toolkit for human-AI collaboration, inspired by three principles:

- **Buckminster Fuller** — Ephemeralization. Do more with less. A trim tab is a tiny surface on a rudder's trailing edge that steers an entire ship.
- **Joe Armstrong** — Let it crash. Erlang supervision trees are trim tabs for reliability — a 3-line restart strategy governs a 100-process subsystem.
- **Donald Knuth** — Algorithmic rigor. You can only place a trim tab if you've done the analysis to know where the forces converge.

## The Idea

As AI coding agents (Claude Code, Codex, OpenCode) grow more capable, the leverage shifts toward **small, precisely-placed surfaces** that steer their work:

- A `CLAUDE.md` file is a trim tab — a few hundred lines that govern every interaction across a project
- Memory files are trim tabs that compound across conversations
- Observation systems (like Uncle's observer) are Armstrong's supervisors — watching for the right moment to intervene
- Task structures are Knuth's discipline — knowing which work matters before you start

The anti-pattern is **pushing the hull** — more dashboards, more process, more micromanagement. The trim tab practitioner asks: *what's the one signal, the one constraint, the one 6-line config that makes the rest unnecessary?*

## CLI

The `trimtab` command is a dispatcher — each subcommand is a standalone script at `~/bin/trimtab-<cmd>`.

### `trimtab status`

Phone-friendly status of your entire dev environment in under 3 seconds:

- Dev servers (port mapping)
- Claude Code sessions (project + elapsed time)
- Git activity (24h commit summary)
- Docker containers
- System resources
- Remote GPU status (nixos-thor via SSH)

### `trimtab dash`

Persistent tmux dashboard — `watch` over `trimtab status` with an interactive shell pane. Survives SSH disconnects.

### `trimtab observe`

Cross-project briefing — what happened across your agent ecosystem since you last looked.

```bash
trimtab observe                   # Last 24 hours
trimtab observe --since 2d        # Last 2 days
trimtab observe --since 1w --ai   # Last week, AI-summarized
```

Sections: shipped commits, active Claude sessions, memory changes, config changes, infrastructure (Docker). The `--ai` flag generates an LLM briefing via qwen3-32b on OpenRouter.

Inspired by Uncle's Observer pattern — token-based triggers that accumulate signal, then extract observations asynchronously.

### `trimtab steer`

Audit and manage trim tab infrastructure across all projects.

```bash
trimtab steer            # Audit all projects (default)
trimtab steer audit      # Same — show CLAUDE.md, memory, skills, tasks, git
trimtab steer gaps       # Show code projects missing key infrastructure
```

### `trimtab init`

Bootstrap trim tab infrastructure for a new project.

```bash
trimtab init              # Current directory
trimtab init ~/1-Projects/new-project
```

Creates: `CLAUDE.md` (template), `.claude/settings.json`, `~/.claude/projects/.../memory/MEMORY.md`, `.gitignore` (with `.claude/` entry). Skips files that already exist.

## Install

```bash
# Clone and link
git clone https://github.com/sportsculture/trimtab.git
ln -s "$(pwd)/trimtab/bin/trimtab" ~/bin/trimtab
for cmd in trimtab/bin/trimtab-*; do
  ln -s "$(pwd)/$cmd" ~/bin/$(basename "$cmd")
done

# Or copy directly
cp bin/trimtab bin/trimtab-* ~/bin/
chmod +x ~/bin/trimtab ~/bin/trimtab-*

# Edit the PORT_PROJECT map in trimtab-status to match your projects
```

## Site

[trimtab.dev](https://trimtab.dev) — manifesto + tools + methodology

## License

MIT
