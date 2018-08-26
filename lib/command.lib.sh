#!/usr/bin/env bash

# [https://unix.stackexchange.com/a/86017]: hash is a bash built-in command.
# The hash table is a feature of bash that prevents it from having to search $PATH
# every time you type a command by caching the results in memory. The table gets
# cleared on events that obviously invalidate the results (such as modifying $PATH)

command::available() {
    local -r command="${1:-}"

    if [[ -z $command ]]; then
        return 1
    fi

    hash $command 2>/dev/null
}

command::assert() {
    local -ra commands=( "$@" )

    for command in ${commands[@]}; do
        command::available $command || \
        { echo >&2 "error: I require '$command' but it's not installed.  Aborting."; exit 1; }
    done
}
