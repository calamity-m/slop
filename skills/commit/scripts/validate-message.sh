#!/usr/bin/env bash

set -euo pipefail

usage() {
    echo "usage: $0 <subject> [body]" >&2
    exit 2
}

[[ $# -ge 1 && $# -le 2 ]] || usage

subject=$1
body=${2-}

if [[ ! $subject =~ ^[a-z]+\([a-z0-9-]+\):\ [[:graph:]].*$ ]]; then
    echo "invalid subject: expected <type>(<scope>): short" >&2
    exit 1
fi

if [[ ${#subject} -gt 72 ]]; then
    echo "invalid subject: keep it at 72 characters or fewer" >&2
    exit 1
fi

if [[ -n $body ]]; then
    if [[ $body == *$'\n'* ]]; then
        echo "invalid body: use a short single paragraph" >&2
        exit 1
    fi

    if [[ ${#body} -gt 200 ]]; then
        echo "invalid body: keep it concise (200 characters or fewer)" >&2
        exit 1
    fi
fi

exit 0
