#!/usr/bin/env bash
# trimtab-common.sh — shared colors, functions, and config for all trimtab scripts
# Source this from any trimtab script: source "$(dirname "$0")/trimtab-common.sh"

# --- Colors (raw ANSI, no tput) ---
R=$'\033[0;31m'   # red
G=$'\033[0;32m'   # green
D=$'\033[2m'      # dim
B=$'\033[1m'      # bold
C=$'\033[0;36m'   # cyan
Y=$'\033[0;33m'   # yellow
A=$'\033[0;33m'   # amber (alias for yellow)
N=$'\033[0m'      # reset

# --- Common config ---
PROJECTS_DIR="$HOME/1-Projects"

# --- Common functions ---
section() { printf "\n${B}${C}── %s${N}\n" "$1"; }
err()     { printf "${R}error:${N} %s\n" "$1" >&2; exit 1; }
ok()      { printf "  ${G}✓${N} %s\n" "$1"; }
skip()    { printf "  ${D}· %s (already done)${N}\n" "$1"; }
info()    { printf "  ${C}…${N} %s\n" "$1"; }
warn()    { printf "  ${Y}!${N} %s\n" "$1"; }

# --- API key discovery ---
# Search common locations for an OpenRouter API key
_find_openrouter_key() {
  local key=""
  for env_file in "$PROJECTS_DIR/decision_forge_v2/.env" "$PROJECTS_DIR/ai-brand-studio/.env" "$HOME/.env"; do
    if [[ -f "$env_file" ]]; then
      key=$(grep '^OPENROUTER_API_KEY=' "$env_file" 2>/dev/null | cut -d'=' -f2- | tr -d '"' | tr -d "'")
      [[ -n "$key" ]] && break
    fi
  done
  echo "$key"
}
