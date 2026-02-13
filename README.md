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

## Tools

### `workstatus`

Phone-friendly status of your entire dev environment in under 3 seconds:

- Dev servers (port mapping)
- Claude Code sessions (project + elapsed time)
- Git activity (24h commit summary)
- Docker containers
- System resources
- Remote GPU status

### `workdash`

Persistent tmux dashboard — `watch` over `workstatus` with an interactive shell pane. Survives SSH disconnects.

## Install

```bash
# Copy tools to your PATH
cp bin/workstatus bin/workdash ~/bin/
chmod +x ~/bin/workstatus ~/bin/workdash

# Edit the PORT_PROJECT map in workstatus to match your projects
```

## Site

[trimtab.dev](https://trimtab.dev) — manifesto + tools + methodology

## License

MIT
