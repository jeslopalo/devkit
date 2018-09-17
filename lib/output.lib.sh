#!/usr/bin/env bash

using column, xargs, sort, head, read, wc

output::columnize() {
    local -a elements="$@"
    local -r length=$(__longest_element "${elements[@]}")

    for value in ${elements[@]}; do
        printf "  %-${length}s\\n" "${value}"
    done | column -c "$(__max_width)"
}

__max_width() {
    local -r cols="$(tput cols)"
    local -r max=150

    echo $((cols < max ? cols : max))
}

__longest_element() {
    echo "$@" | \
    xargs -n1 -I{} sh -c 'echo $(echo -n {} | wc -c)\\t{}' | \
    sort -nr | \
    head -1 | \
    { read first rest; echo $first; }
}
