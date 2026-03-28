#!/usr/bin/env bash

set -euo pipefail

usage() {
    echo "usage: $0 <subject> [body]" >&2
    exit 2
}

[[ $# -eq 2 ]] || usage

subject=$1
body=$2

if [[ ! $subject =~ ^[a-z]+\([a-z0-9-]+\):\ [[:graph:]].*$ ]]; then
    echo "invalid subject: expected <type>(<scope>): short" >&2
    exit 1
fi

if [[ ${#subject} -gt 72 ]]; then
    echo "invalid subject: keep it at 72 characters or fewer" >&2
    exit 1
fi

if [[ -z $body ]]; then
    echo "invalid body: a body is required" >&2
    exit 1
fi

if [[ $body == *$'\n'* ]]; then
    echo "invalid body: use a short single paragraph" >&2
    exit 1
fi

if [[ ${#body} -gt 500 ]]; then
    echo "invalid body: keep it concise (500 characters or fewer)" >&2
    exit 1
fi

exit 0
