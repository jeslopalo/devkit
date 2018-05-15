#!/usr/bin/env bash

#+|         mark 'usage' lines
#%|         mark 'purpose' line
#-|         mark 'authorship' line
#[%+-=]|    mark 'man' lines

# inspired by https://stackoverflow.com/a/29579226
extract_from_header() {
    local -r pattern="${1:-'#'}"
    local -r source_file="${2:-${BASH_SOURCE[1]}}"

    grep -e "$pattern" ${source_file} | sed -e "s/$pattern//g" -e "s/^ //" ;
}

usage() {
    printf "\\n"
    extract_from_header "^#+|" "${1:-${BASH_SOURCE[1]}}"
}

purpose() {
    extract_from_header "^#%|[ ]*" "${1:-${BASH_SOURCE[1]}}"
}

authorship() {
    extract_from_header "^#-|" "${1:-${BASH_SOURCE[1]}}"
}

manual() {
    extract_from_header "^#[%+-=]|" "${1:-${BASH_SOURCE[1]}}"
}

#
# Add --usage-describe option when it is sourced
#
if [[ $_ != $0 ]]; then
    for option in "$@"; do
        if [[ ${option:-} = "--usage-describe" ]]; then
                purpose "${BASH_SOURCE[1]}"
            exit 0
        fi
    done
fi
