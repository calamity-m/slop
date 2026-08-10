# Skills live categorized in the repo but must appear flat under ~/.agents/skills.
# Reconciled per shell so new/moved/removed skills need no install.sh rerun.
# Executed, not sourced: the reconciler uses `set -e` and would kill this shell.
# Synchronous: a shell may launch an agent immediately, and the run is sub-25ms.
if [ -x "$HOME/.scripts/sync-agent-skills" ] && [ -d "$HOME/.agents/skills" ]; then
  "$HOME/.scripts/sync-agent-skills" || true
fi
