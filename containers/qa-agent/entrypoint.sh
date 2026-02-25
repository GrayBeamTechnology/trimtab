#!/usr/bin/env bash
# entrypoint.sh — root wrapper that sets up auth then drops to agent
#
# Auth modes (in priority order):
#   1. ANTHROPIC_API_KEY env var → API key mode, no file mount needed
#   2. /auth/.credentials.json (read-only mount) → copied into container-owned ~/.claude/
#
# NEVER chown or write to host-mounted files. The /auth/ mount is read-only.
# Only the copy at /home/agent/.claude/.credentials.json is touched.
set -euo pipefail

R=$'\033[0;31m'  G=$'\033[0;32m'  Y=$'\033[0;33m'  N=$'\033[0m'

# --- Auth setup ---
if [[ -n "${ANTHROPIC_API_KEY:-}" ]]; then
  echo "  ${G}+${N} auth: API key"
elif [[ -f /auth/.credentials.json ]]; then
  mkdir -p /home/agent/.claude
  cp /auth/.credentials.json /home/agent/.claude/.credentials.json
  chown agent:agent /home/agent/.claude /home/agent/.claude/.credentials.json
  chmod 600 /home/agent/.claude/.credentials.json
  echo "  ${G}+${N} auth: OAuth credentials (copied)"
else
  echo "  ${Y}warn:${N} no auth found — set ANTHROPIC_API_KEY or mount .credentials.json to /auth/" >&2
fi

# Fix ownership on reports dir (container output, safe to chown)
chown -R agent:agent /reports 2>/dev/null || true

# Drop to agent user and run the qa-runner
exec sudo -u agent --preserve-env=QA_AGENT,APP_URL,HEALTH_PATH,MAX_WAIT,REPORT_DIR,PERSONA_DIR,ANTHROPIC_API_KEY,OPENAI_API_KEY,CHROME_PATH,CHROMIUM_FLAGS,TERM,PATH,CLAUDE_CODE_DISABLE_AUTO_UPDATE \
  /home/agent/qa-runner.sh "$@"
