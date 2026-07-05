#!/usr/bin/env bash
# Renames the current zellij tab to the cwd of its currently highlighted pane.
# `list-panes` reports a focused pane per layer (floating vs embedded), so the
# floating-visibility check picks the layer the user is actually looking at.
set -euo pipefail

tab_id=$(zellij action current-tab-info | awk -F': ' '/^id:/{print $2}')

if zellij action are-floating-panes-visible >/dev/null 2>&1; then
	floating=true
else
	floating=false
fi

cwd=$(zellij action list-panes --json -a | jq -r \
	--arg tab "$tab_id" \
	--argjson floating "$floating" \
	'map(select(.tab_id == ($tab | tonumber) and .is_focused == true and .is_floating == $floating and .is_plugin == false)) | .[0].pane_cwd // empty')

if [ -n "$cwd" ]; then
	zellij action rename-tab "$(basename "$cwd")"
fi
