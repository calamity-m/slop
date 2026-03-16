#!/usr/bin/env bash

dexec() {
	CONTAINER=$(docker ps | rg -v CONTAINER | awk '-F ' ' {print $NF}' | fzf)
	if [ ! -z "$CONTAINER" ]; then
		docker exec -it "$CONTAINER" bash
	fi
}
