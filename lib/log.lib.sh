#!/usr/bin/env bash

__trim() {
    local message="${@:-}"
    local nospaces=${message## }
    nospaces=${nospaces%% }
    echo "$nospaces"
}

log::usage() {
    local -r message="${1:-}"
    [[ -n $message ]] && printf "${white}usage: %s$reset\\n" "$(__trim $message)" 1>&2
}

log::info() {
    local -r message="${1:-}"
    [[ -n $message ]] && printf "%s\\n" "$(__trim $message)"
}

log::error() {
    local -r message="${1:-}"
    [[ -n $message ]] && printf "${error_color}error: %s$reset\\n" "$(__trim $message)" 1>&2
}

log::warn() {
    local -r message="${1:-}"
    [[ -n $message ]] && printf "${warn_color}%s$reset\\n" "$(__trim $message)"  1>&2
}
