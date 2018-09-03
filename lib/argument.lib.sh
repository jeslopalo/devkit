#!/usr/bin/env bash

# Search of existance of the $name in the rest of arguments.
# Usage:
#   argument::exists 'name' -- "$@"
#
# 'name' presence can occur in different forms:
#   --name -name --name=value -name=value name=value
#
# returns 0 if exists, 1 if not
argument::exists() {
    local -r name="${1:-}"

    for arg in "${@}"; do
        shift
        if [[ $arg = "--" ]]; then break; fi
    done

    argument::map_if_present "$name" "_lambda_exists" -- "$@"
}

_lambda_exists() { return 0; }


# Get the $name argument value in the rest of arguments.
# Usage:
#   argument::value 'name' -- "$@"
#
# 'name' presence can occur in different forms:
#   --name=value -name=value name=value --name value -name value
#
# return the value if exists
argument::value() {
    local -r name="${1:-}"

    for arg in "${@}"; do
        shift
        if [[ $arg = "--" ]]; then break; fi
    done

    argument::map_if_present "$name" "_lambda_extract" -- "$@"
}

_lambda_extract() { if [[ -n ${2:-} ]]; then echo "${2:-}"; else echo "${1#*=}"; fi }


# Get the $name argument if exists in the rest of arguments.
# Usage:
#   argument::get 'name' -- "$@"
#
# 'name' presence can occur in different forms:
#   --name=value -name=value name=value --name -name
#
# Warning! if the argument is in '(--)name value' form then
# it only returns the '(--)name' part.
#
# return the argument if exists
argument::get() {
    local -r name="${1:-}"

    for arg in "${@}"; do
        shift
        if [[ $arg = "--" ]]; then break; fi
    done

    argument::map_if_present "$name" "_lambda_echo" -- "$@"
}

_lambda_echo() { echo $1; }



argument::map_if_present() {
    local name="${1:-}"
    local f="${2:-echo}";

    for arg in "${@}"; do
        shift
        if [[ $arg = "--" ]]; then break; fi
    done

    for option in "$@"; do

        case ${option:-} in
            "--") return 1;;
            "$name="*|-"$name="*|--"$name="*) $f "$option"; return $?;;
            -"$name"|--"$name") $f "$option" "${2:-}"; return $? ;;
        esac

        shift
    done

    return 1
}
