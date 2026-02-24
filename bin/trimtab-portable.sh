#!/usr/bin/env bash
# trimtab-portable.sh — cross-platform shims for macOS + Linux
# Source this from any trimtab script: source "$(dirname "$0")/trimtab-portable.sh"

# Detect OS once
_IS_MACOS=false
[[ "$OSTYPE" == darwin* ]] && _IS_MACOS=true

# Portable readlink -f (resolves symlinks to absolute path)
_realpath() {
  if $_IS_MACOS; then
    # Use greadlink if available (coreutils), else python fallback
    if command -v greadlink >/dev/null 2>&1; then
      greadlink -f "$1"
    else
      python3 -c "import os,sys; print(os.path.realpath(sys.argv[1]))" "$1"
    fi
  else
    readlink -f "$1"
  fi
}

# Portable stat: get file modification time as epoch seconds
_mtime() {
  if $_IS_MACOS; then
    stat -f '%m' "$1" 2>/dev/null || echo 0
  else
    stat -c '%Y' "$1" 2>/dev/null || echo 0
  fi
}

# Portable date: convert a relative time string to epoch seconds
# Usage: _date_ago "24 hours ago" or _date_ago "2 days ago"
_date_ago() {
  if $_IS_MACOS; then
    # Parse "N hours/days/weeks ago" into BSD date -v flags
    local spec="$1"
    case "$spec" in
      *hours\ ago)   local n="${spec%% *}"; date -v-"${n}"H +%s ;;
      *hour\ ago)    date -v-1H +%s ;;
      *days\ ago)    local n="${spec%% *}"; date -v-"${n}"d +%s ;;
      *day\ ago)     date -v-1d +%s ;;
      *weeks\ ago)   local n="${spec%% *}"; date -v-"${n}"w +%s ;;
      *week\ ago)    date -v-1w +%s ;;
      *)             date -v-24H +%s ;;  # fallback: 24h ago
    esac
  else
    date -d "$1" +%s 2>/dev/null || date -d "24 hours ago" +%s
  fi
}

# Portable: get cwd of a process by PID
_proc_cwd() {
  local pid="$1"
  if $_IS_MACOS; then
    lsof -a -d cwd -p "$pid" -Fn 2>/dev/null | awk '/^n/{print substr($0,2); exit}'
  else
    readlink -f "/proc/$pid/cwd" 2>/dev/null
  fi
}

# Portable: list listening TCP ports with PIDs
# Output format: port<TAB>pid per line (only ports in 4000-5200 range)
_listening_ports() {
  if $_IS_MACOS; then
    lsof -iTCP -sTCP:LISTEN -P -n 2>/dev/null | awk '
      NR>1 {
        split($9, a, ":");
        port = a[length(a)];
        if (port >= 4000 && port <= 5200) print port "\t" $2
      }
    ' | sort -t$'\t' -k1,1n -u
  else
    ss -tlnp 2>/dev/null | grep -oP ':\K(4\d{3}|51[0-9]{2})\b.*pid=\d+' | \
      sed 's/.*:\([0-9]*\).*pid=\([0-9]*\).*/\1\t\2/' | sort -t$'\t' -k1,1n -u
  fi
}

# Portable: system load average
_system_load() {
  if $_IS_MACOS; then
    sysctl -n vm.loadavg 2>/dev/null | sed 's/[{}]//g' | xargs
  else
    cut -d' ' -f1-3 /proc/loadavg
  fi
}

# Portable: memory usage string like "8192M / 16384M (50%)"
_system_mem() {
  if $_IS_MACOS; then
    local total_bytes
    total_bytes=$(sysctl -n hw.memsize 2>/dev/null)
    local total_mb=$((total_bytes / 1048576))
    # vm_stat gives pages; page size is typically 16384 on Apple Silicon
    local page_size
    page_size=$(pagesize 2>/dev/null || echo 16384)
    local used_pages
    used_pages=$(vm_stat 2>/dev/null | awk '
      /Pages active/    { a=int($NF) }
      /Pages wired/     { w=int($NF) }
      /Pages compressed/{ c=int($NF) }
      END { print a+w+c }
    ')
    local used_mb=$(( (used_pages * page_size) / 1048576 ))
    local pct=0
    (( total_mb > 0 )) && pct=$(( used_mb * 100 / total_mb ))
    printf "%dM / %dM (%d%%)" "$used_mb" "$total_mb" "$pct"
  else
    free -m | awk '/^Mem:/ {printf "%dM / %dM (%.0f%%)", $3, $2, $3/$2*100}'
  fi
}

# Portable: timeout command
_timeout() {
  if command -v timeout >/dev/null 2>&1; then
    timeout "$@"
  elif command -v gtimeout >/dev/null 2>&1; then
    gtimeout "$@"
  else
    # Fallback: just run without timeout
    shift  # drop the timeout value
    "$@"
  fi
}

# Portable: chezmoi project memory path prefix
# On Linux: -home-mchughson-1-Projects
# On macOS: -Users-mchughsonchambers-1-Projects
_chezmoi_projects_prefix() {
  echo "$HOME/1-Projects" | sed 's|/|-|g; s|^-||'
}
