#!/usr/bin/env bash

using column

output::columnize() {
    local -a elements=$@

    for value in ${elements[@]}; do
        printf "%-8s\n" "${value}"
    done | column -x
}
