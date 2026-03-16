#!/usr/bin/env bash
#
# pipeline-dashboard.sh — Quick terminal dashboard for GitLab pipeline status
#
# Uses `glab` CLI to fetch the latest pipeline for each configured repo.
#
# USAGE:
#   ./pipeline-dashboard.sh                        One-shot run
#   ./pipeline-dashboard.sh --watch                Refresh every 60s
#   ./pipeline-dashboard.sh --watch 30             Refresh every 30s
#   ./pipeline-dashboard.sh --watch group/repo1    Watch specific repos
#
# CONFIGURATION:
#   1. Config file:  List repos in ~/.pipeline-dashboard.conf (one per line)
#   2. CLI args:     ./pipeline-dashboard.sh group/repo1 group/repo2 ...
#   3. Hardcoded:    Edit the DEFAULT_REPOS array below
#
# Repos should be in "namespace/project" format, e.g. "myteam/backend-api"

set -euo pipefail

# ── Hardcoded fallback repos (edit these if you don't use a config file) ──────
DEFAULT_REPOS=(
  # "mygroup/project-alpha"
  # "mygroup/project-beta"
  # "mygroup/infrastructure"
)

# ── Config ────────────────────────────────────────────────────────────────────
CONFIG_FILE="${PIPELINE_DASHBOARD_CONF:-$HOME/.pipeline-dashboard.conf}"
MAX_PARALLEL=6          # concurrent glab calls
TIMEOUT_SECS=10         # per-repo timeout
DEFAULT_BRANCH=""       # empty = use repo default branch; set to override globally
WATCH_INTERVAL=60       # seconds between refreshes in watch mode

# ── Flag parsing ──────────────────────────────────────────────────────────────
WATCH_MODE=false
REPO_ARGS=()

usage() {
  echo "Usage: $(basename "$0") [--watch [SECS]] [repo1 repo2 ...]"
  echo ""
  echo "Options:"
  echo "  --watch [SECS]   Refresh every SECS seconds (default: ${WATCH_INTERVAL}s)"
  echo "  -h, --help       Show this help"
  echo ""
  echo "Repos can also be listed in ${CONFIG_FILE} (one per line)."
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --watch|-w)
      WATCH_MODE=true
      # If next arg is a number, use it as the interval
      if [[ "${2:-}" =~ ^[0-9]+$ ]]; then
        WATCH_INTERVAL="$2"
        shift
      fi
      shift
      ;;
    -h|--help)
      usage
      ;;
    *)
      REPO_ARGS+=("$1")
      shift
      ;;
  esac
done

# ── Colors & Symbols ─────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
  BOLD="\033[1m"
  DIM="\033[2m"
  RESET="\033[0m"
  RED="\033[31m"
  GREEN="\033[32m"
  YELLOW="\033[33m"
  BLUE="\033[34m"
  CYAN="\033[36m"
  GRAY="\033[90m"
else
  BOLD="" DIM="" RESET="" RED="" GREEN="" YELLOW="" BLUE="" CYAN="" GRAY=""
fi

status_icon() {
  case "$1" in
    success)            echo -e "${GREEN}✔ passed${RESET}" ;;
    failed)             echo -e "${RED}✘ failed${RESET}" ;;
    running)            echo -e "${BLUE}● running${RESET}" ;;
    pending|waiting*)   echo -e "${YELLOW}◌ pending${RESET}" ;;
    canceled|cancelled) echo -e "${GRAY}⊘ canceled${RESET}" ;;
    skipped)            echo -e "${GRAY}⊘ skipped${RESET}" ;;
    created)            echo -e "${CYAN}◦ created${RESET}" ;;
    manual)             echo -e "${YELLOW}▶ manual${RESET}" ;;
    *)                  echo -e "${DIM}? $1${RESET}" ;;
  esac
}

# ── Resolve repo list ─────────────────────────────────────────────────────────
resolve_repos() {
  local repos=()

  # Priority: CLI args > config file > hardcoded
  if [[ $# -gt 0 ]]; then
    repos=("$@")
  elif [[ -f "$CONFIG_FILE" ]]; then
    while IFS= read -r line; do
      line="${line%%#*}"          # strip comments
      line="${line// /}"          # strip whitespace
      [[ -n "$line" ]] && repos+=("$line")
    done < "$CONFIG_FILE"
  else
    repos=("${DEFAULT_REPOS[@]}")
  fi

  if [[ ${#repos[@]} -eq 0 ]]; then
    echo -e "${RED}Error:${RESET} No repos configured." >&2
    echo "" >&2
    echo "Configure repos in one of three ways:" >&2
    echo "  1. Add repos to ${CONFIG_FILE} (one per line)" >&2
    echo "  2. Pass as arguments: $0 group/repo1 group/repo2" >&2
    echo "  3. Edit the DEFAULT_REPOS array in this script" >&2
    exit 1
  fi

  printf '%s\n' "${repos[@]}"
}

# ── Hyperlink helper (OSC 8) ─────────────────────────────────────────────────
hyperlink() {
  local url="$1" text="$2"
  if [[ -t 1 ]]; then
    echo -e "\033]8;;${url}\033\\${text}\033]8;;\033\\"
  else
    echo "$text"
  fi
}

# ── Relative time ─────────────────────────────────────────────────────────────
relative_time() {
  local ts="$1"
  if [[ -z "$ts" || "$ts" == "null" ]]; then
    echo "—"
    return
  fi

  local now epoch_ts diff
  now=$(date +%s)

  # Try GNU date first, then BSD date
  if epoch_ts=$(date -d "$ts" +%s 2>/dev/null); then
    :
  elif epoch_ts=$(date -jf "%Y-%m-%dT%H:%M:%S" "${ts%%.*}" +%s 2>/dev/null); then
    :
  else
    echo "$ts"
    return
  fi

  diff=$(( now - epoch_ts ))
  if   (( diff < 60 ));    then echo "just now"
  elif (( diff < 3600 ));  then echo "$(( diff / 60 ))m ago"
  elif (( diff < 86400 )); then echo "$(( diff / 3600 ))h ago"
  else                          echo "$(( diff / 86400 ))d ago"
  fi
}

# ── Fetch pipeline for a single repo ─────────────────────────────────────────
fetch_pipeline() {
  local repo="$1"
  local branch_flag=""
  [[ -n "$DEFAULT_BRANCH" ]] && branch_flag="--branch $DEFAULT_BRANCH"

  local json
  # shellcheck disable=SC2086
  if ! json=$(timeout "$TIMEOUT_SECS" glab -R "$repo" pipeline list \
      --per-page 1 --output json $branch_flag 2>/dev/null); then
    echo -e "  ${RED}⚠${RESET}  ${BOLD}${repo}${RESET}  ${DIM}— could not fetch${RESET}"
    return
  fi

  # glab returns a JSON array; grab the first element
  local status branch web_url created_at sha source
  status=$(echo "$json"     | jq -r '.[0].status // "unknown"')
  branch=$(echo "$json"     | jq -r '.[0].ref // "—"')
  web_url=$(echo "$json"    | jq -r '.[0].web_url // ""')
  created_at=$(echo "$json" | jq -r '.[0].created_at // ""')
  sha=$(echo "$json"        | jq -r '.[0].sha // ""')
  source=$(echo "$json"     | jq -r '.[0].source // ""')

  local short_sha="${sha:0:8}"
  local time_str
  time_str=$(relative_time "$created_at")

  # Fetch commit message from the SHA
  local commit_msg="—"
  if [[ -n "$sha" && "$sha" != "null" ]]; then
    local commit_json
    if commit_json=$(timeout "$TIMEOUT_SECS" glab -R "$repo" api \
        "projects/:id/repository/commits/$sha" 2>/dev/null); then
      commit_msg=$(echo "$commit_json" | jq -r '.title // "—"')
    fi
  fi
  # Truncate long commit messages
  local max_msg_len=50
  if (( ${#commit_msg} > max_msg_len )); then
    commit_msg="${commit_msg:0:$max_msg_len}…"
  fi

  # Build output line
  local icon
  icon=$(status_icon "$status")

  local line=""
  line+="  ${icon}  ${BOLD}${repo}${RESET}"
  line+="  ${DIM}on${RESET} ${CYAN}${branch}${RESET}"
  line+="  ${DIM}(${short_sha})${RESET}"
  line+="  ${GRAY}${time_str}${RESET}"

  if [[ -n "$web_url" && "$web_url" != "null" ]]; then
    local link
    link=$(hyperlink "$web_url" "→ open")
    line+="  ${link}"
  fi

  echo -e "$line"
  echo -e "           ${DIM}${commit_msg}${RESET}"
}

# ── Main ──────────────────────────────────────────────────────────────────────

# Single fetch cycle — returns 1 if any pipeline failed, 0 otherwise
run_once() {
  local repos=("$@")
  local count=${#repos[@]}

  local now_str
  now_str=$(date '+%H:%M:%S')

  echo ""
  echo -e "${BOLD}  ╭─────────────────────────────────────╮${RESET}"
  echo -e "${BOLD}  │   GitLab Pipeline Dashboard         │${RESET}"
  echo -e "${BOLD}  │   ${DIM}${count} repositories${RESET}${BOLD}                   │${RESET}"
  if [[ "$WATCH_MODE" == true ]]; then
  echo -e "${BOLD}  │   ${DIM}Updated ${now_str}  (every ${WATCH_INTERVAL}s)${RESET}${BOLD}    │${RESET}"
  fi
  echo -e "${BOLD}  ╰─────────────────────────────────────╯${RESET}"
  echo ""

  # Run fetches in parallel, capped at MAX_PARALLEL
  local pids=()
  local tmpdir
  tmpdir=$(mktemp -d)

  for i in "${!repos[@]}"; do
    (
      fetch_pipeline "${repos[$i]}" > "$tmpdir/$i.out" 2>&1
    ) &
    pids+=($!)

    # Throttle parallelism
    if (( ${#pids[@]} >= MAX_PARALLEL )); then
      wait "${pids[0]}"
      pids=("${pids[@]:1}")
    fi
  done

  # Wait for remaining
  for pid in "${pids[@]}"; do
    wait "$pid" 2>/dev/null || true
  done

  # Print results in order
  for i in "${!repos[@]}"; do
    if [[ -f "$tmpdir/$i.out" ]]; then
      cat "$tmpdir/$i.out"
    fi
  done

  echo ""

  # Summary counts
  local passed=0 failed=0 running=0 other=0
  for i in "${!repos[@]}"; do
    local out=""
    [[ -f "$tmpdir/$i.out" ]] && out=$(cat "$tmpdir/$i.out")
    if   [[ "$out" == *"passed"* ]];  then (( passed++ ))
    elif [[ "$out" == *"failed"* ]];  then (( failed++ ))
    elif [[ "$out" == *"running"* ]]; then (( running++ ))
    else (( other++ ))
    fi
  done

  echo -ne "  ${DIM}Summary:${RESET} "
  (( passed  > 0 )) && echo -ne "${GREEN}${passed} passed${RESET}  "
  (( failed  > 0 )) && echo -ne "${RED}${failed} failed${RESET}  "
  (( running > 0 )) && echo -ne "${BLUE}${running} running${RESET}  "
  (( other   > 0 )) && echo -ne "${GRAY}${other} other${RESET}  "
  echo ""

  rm -rf "$tmpdir"

  (( failed > 0 )) && return 1
  return 0
}

main() {
  # Dependency check
  for cmd in glab jq; do
    if ! command -v "$cmd" &>/dev/null; then
      echo -e "${RED}Error:${RESET} '$cmd' is required but not installed." >&2
      exit 1
    fi
  done

  local repos
  mapfile -t repos < <(resolve_repos "${REPO_ARGS[@]}")

  if [[ "$WATCH_MODE" == true ]]; then
    # Trap Ctrl+C for clean exit
    trap 'printf "\n\033[?25h"; echo -e "  ${DIM}Dashboard stopped.${RESET}"; echo ""; exit 0' INT TERM

    # Hide cursor during watch mode
    printf '\033[?25l'

    while true; do
      # Clear screen and move cursor to top
      tput clear 2>/dev/null || printf '\033[2J\033[H'

      run_once "${repos[@]}" || true

      # Countdown timer on the same line
      for (( remaining=WATCH_INTERVAL; remaining>0; remaining-- )); do
        printf "\r  ${GRAY}Refreshing in %ds... (Ctrl+C to quit)${RESET}  " "$remaining"
        sleep 1
      done
    done
  else
    run_once "${repos[@]}"
    exit $?
  fi
}

main
