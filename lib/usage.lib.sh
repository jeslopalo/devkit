#!/usr/bin/env bash

#>|          mark 'synopsis' line
#+|          mark 'usage' lines
#%|          mark 'purpose' line
#-|          mark 'authorship' line
#[%+-=>]|    mark 'man' lines

# inspired by https://stackoverflow.com/a/29579226
extract_from_header() {
    local -r pattern="${1:-'#'}"
    local -r source_file="${2:-${BASH_SOURCE[1]}}"

    grep -e "$pattern" ${source_file} | sed -e "s/$pattern//g" -e "s/^ //" ;
}

help() {
    extract_from_header "^#+|" "${1:-${BASH_SOURCE[1]}}"
}

synopsis() {
    extract_from_header "^#>|" "${1:-${BASH_SOURCE[1]}}"
}

purpose() {
    extract_from_header "^#%|[ ]*" "${1:-${BASH_SOURCE[1]}}"
}

authorship() {
    extract_from_header "^#-|" "${1:-${BASH_SOURCE[1]}}"
}

manual() {
    extract_from_header "^#[%+-=>]|" "${1:-${BASH_SOURCE[1]}}"
}

#
# Add usage options when it is sourced
#
if [[ $_ != $0 ]]; then
    for option in "$@"; do
        case ${option:-} in
        (--manual)
            manual "${BASH_SOURCE[1]}"
            exit 0
        ;;
        (--purpose)
            purpose "${BASH_SOURCE[1]}"
            exit 0
        ;;
        (--synopsis)
            synopsis "${BASH_SOURCE[1]}"
            exit 0
        ;;
        (--authorship)
            authorship "${BASH_SOURCE[1]}"
            exit 0
        ;;
        (--help)
            help "${BASH_SOURCE[1]}"
            exit 0
        ;;
        esac
    done
fi
