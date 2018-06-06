#!/usr/bin/env bash

# colors
clr_usage="${bblue:-}"
clr_error="${bwhite:-}${bold:-}"
clr_debugr="${bpurple:-}"
clr_warn="${white:-}${bold:-}"


__trim() {
    local message="${@:-}"
    local nospaces=${message## }
    nospaces=${nospaces%% }
    echo "$nospaces"
}

log::usage() {
    local -r message="${1:-}"
    [[ -n $message ]] && printf "${clr_usage}usage: %s$reset\\n" "$(__trim $message)" 1>&2
}

log::info() {
    local -r message="${1:-}"
    [[ -n $message ]] && printf "%s\\n" "$(__trim $message)"
}

log::error() {
    local -r message="${1:-}"
    [[ -n $message ]] && printf "${clr_error}error: %s$reset\\n" "$(__trim $message)" 1>&2
}

log::warn() {
    local -r message="${1:-}"
    [[ -n $message ]] && printf "${clr_warn}%s$reset\\n" "$(__trim $message)"  1>&2
}

log::debug() {
    local -r message="${1:-}"
    if [[ ${DEVKIT_DEBUG:-} = 1 ]] && [[ -w ${DEVKIT_DEBUG_FILE:-} ]]; then
        [[ -n $message ]] && printf "${clr_debug}[debug] %s$reset\\n" "$(__trim $message)"  1>&2 >> $DEVKIT_DEBUG_FILE;
    fi
}
