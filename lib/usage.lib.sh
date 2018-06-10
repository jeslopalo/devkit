#!/usr/bin/env bash

#>|          mark 'synopsis' line
#+|          mark 'help' lines
#%|          mark 'purpose' line
#-|          mark 'authorship' line
#[%+-=>]|    mark 'manual' lines

# inspired by https://stackoverflow.com/a/29579226
usage::extract_from_header() {
    local -r pattern="${1:-'#'}"
    local -r source_file="${2:-}"

    [[ -r $source_file ]] || exit 1
    grep -e "$pattern" ${source_file} | sed -e "s/$pattern//g" -e "s/^ //" ;
}

usage::extract_command_main_source() {
    # In "devkit" framework, usage documentation is in "main.sh" script
    # and it's always in the second place of calling stack
    for (( idx=${#BASH_SOURCE[@]}-1 ; idx>=0 ; idx-- )) ; do
        if [[ ${BASH_SOURCE[idx]##*/} = main.sh ]]; then
            echo "${BASH_SOURCE[idx]}"
            return 0
        fi
    done
    return 1
}

usage::synopsis() {
    usage::extract_from_header "^#>|" "${1:-}"
}

usage::help() {
    usage::extract_from_header "^#+|" "${1:-}"
}

usage::purpose() {
    usage::extract_from_header "^#%|[ ]*" "${1:-}"
}

usage::authorship() {
    usage::extract_from_header "^#-|" "${1:-}"
}

usage::manual() {
    usage::extract_from_header "^#[%+-=>]|" "${1:-}"
}

#
# Add usage options when it is sourced
#
if [[ $_ != $0 ]]; then
    for option in "$@"; do
        case ${option:-} in
        --synopsis)
            usage::synopsis "$(usage::extract_command_main_source)"
            exit 0
        ;;
        --help)
            usage::help "$(usage::extract_command_main_source)"
            exit 0
        ;;
        --purpose)
            usage::purpose "$(usage::extract_command_main_source)"
            exit 0
        ;;
        --authorship)
            usage::authorship "$(usage::extract_command_main_source)"
            exit 0
        ;;
        --manual)
            usage::manual "$(usage::extract_command_main_source)"
            exit 0
        ;;
        esac
    done
fi
