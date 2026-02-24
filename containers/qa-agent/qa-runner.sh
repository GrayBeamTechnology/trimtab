#!/usr/bin/env bash
# qa-runner.sh — agent-agnostic QA runner entrypoint
#
# Waits for the app healthcheck, then dispatches to the configured AI agent
# (Claude Code or Goose) with the persona file and browser-use instructions.
#
# Usage (as container entrypoint):
#   qa-runner.sh <persona-file.md> [--scenarios 1,3,5]
#
# Environment:
#   QA_AGENT        Agent to use: claude (default), goose
#   APP_URL         App base URL (default: http://localhost:4005)
#   HEALTH_PATH     Health check path (default: /health)
#   MAX_WAIT        Max seconds to wait for app (default: 120)
#   REPORT_DIR      Where to write reports (default: /reports)
#   ANTHROPIC_API_KEY  Required for claude agent
#   OPENAI_API_KEY     Alternative for goose agent
set -euo pipefail

# --- Colors ---
R=$'\033[0;31m'  G=$'\033[0;32m'  D=$'\033[2m'
B=$'\033[1m'     C=$'\033[0;36m'  Y=$'\033[0;33m'
N=$'\033[0m'

# --- Config ---
QA_AGENT="${QA_AGENT:-claude}"
APP_URL="${APP_URL:-http://localhost:4005}"
HEALTH_PATH="${HEALTH_PATH:-/health}"
MAX_WAIT="${MAX_WAIT:-120}"
REPORT_DIR="${REPORT_DIR:-/reports}"
PERSONA_DIR="${PERSONA_DIR:-/personas}"

# --- Parse args ---
PERSONA_FILE=""
SCENARIOS=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --scenarios) SCENARIOS="$2"; shift 2 ;;
    --scenarios=*) SCENARIOS="${1#*=}"; shift ;;
    --*) echo "${Y}warn:${N} unknown flag $1" >&2; shift ;;
    *) PERSONA_FILE="$1"; shift ;;
  esac
done

die() { echo "${R}error:${N} $1" >&2; exit 1; }
ok()  { echo "  ${G}+${N} $1"; }

# --- Validate ---
[[ -z "$PERSONA_FILE" ]] && die "usage: qa-runner.sh <persona-file.md> [--scenarios 1,3,5]"

persona_path="${PERSONA_DIR}/${PERSONA_FILE}"
[[ -f "$persona_path" ]] || die "persona not found: ${persona_path}"

# --- Detect agent ---
detect_agent() {
  case "$QA_AGENT" in
    claude)
      command -v claude >/dev/null 2>&1 || die "claude not found in PATH"
      [[ -n "${ANTHROPIC_API_KEY:-}" ]] || echo "${Y}warn:${N} ANTHROPIC_API_KEY not set — claude may fail" >&2
      ok "agent: Claude Code"
      ;;
    goose)
      command -v goose >/dev/null 2>&1 || die "goose not found in PATH"
      ok "agent: Goose CLI"
      ;;
    *)
      die "unknown QA_AGENT: ${QA_AGENT} (supported: claude, goose)"
      ;;
  esac
}

# --- Wait for app ---
wait_for_app() {
  echo "${C}Waiting for app at ${APP_URL}${HEALTH_PATH}...${N}"
  local elapsed=0
  while ! curl -fsS "${APP_URL}${HEALTH_PATH}" >/dev/null 2>&1; do
    sleep 2
    elapsed=$((elapsed + 2))
    if (( elapsed >= MAX_WAIT )); then
      die "app not ready after ${MAX_WAIT}s"
    fi
  done
  ok "app ready (${elapsed}s)"
}

# --- Build prompt ---
build_prompt() {
  local prompt="You are a QA agent. Run the /qa-persona skill."
  prompt+=" The persona file is at ${persona_path}."
  prompt+=" The app is running at ${APP_URL}."
  prompt+=" Use browser-use for all browser interactions."
  prompt+=" Chromium is at ${CHROME_PATH:-/usr/bin/google-chrome-stable}."

  if [[ -n "$SCENARIOS" ]]; then
    prompt+=" Only run scenarios: ${SCENARIOS}."
  fi

  prompt+=" Save screenshots to ${REPORT_DIR}/screenshots/."
  prompt+=" When complete, write a markdown QA report to ${REPORT_DIR}/."
  prompt+=" Report filename: $(basename "$PERSONA_FILE" .md)-report-$(date +%Y%m%d-%H%M%S).md"

  echo "$prompt"
}

# --- Agent dispatch ---
run_claude() {
  local prompt="$1"
  local logfile="${REPORT_DIR}/qa-run-$(date +%Y%m%d-%H%M%S).log"

  mkdir -p "${REPORT_DIR}/screenshots"

  echo "${B}${C}── Running Claude Code${N}"
  claude \
    --print \
    --dangerously-skip-permissions \
    --output-format text \
    "$prompt" 2>&1 | tee "$logfile"

  return "${PIPESTATUS[0]}"
}

run_goose() {
  local prompt="$1"
  local logfile="${REPORT_DIR}/qa-run-$(date +%Y%m%d-%H%M%S).log"

  mkdir -p "${REPORT_DIR}/screenshots"

  echo "${B}${C}── Running Goose CLI${N}"
  GOOSE_MODE=auto \
  GOOSE_CONTEXT_STRATEGY=summarize \
    goose run \
    --no-session \
    -t "$prompt" 2>&1 | tee "$logfile"

  return "${PIPESTATUS[0]}"
}

# --- Main ---
main() {
  echo "${B}${C}── trimtab-qa-agent${N}"
  echo "  persona: ${PERSONA_FILE}"
  echo "  agent:   ${QA_AGENT}"
  echo "  app:     ${APP_URL}"
  [[ -n "$SCENARIOS" ]] && echo "  scenarios: ${SCENARIOS}"
  echo ""

  detect_agent
  wait_for_app

  local prompt
  prompt=$(build_prompt)

  local exit_code=0
  case "$QA_AGENT" in
    claude) run_claude "$prompt" || exit_code=$? ;;
    goose)  run_goose "$prompt"  || exit_code=$? ;;
  esac

  echo ""
  if (( exit_code == 0 )); then
    echo "${G}${B}QA run complete.${N} Reports in ${REPORT_DIR}/"
  else
    echo "${R}${B}QA run failed${N} (exit ${exit_code}). Check logs in ${REPORT_DIR}/"
  fi

  return $exit_code
}

main
