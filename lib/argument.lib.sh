#!/usr/bin/env bash

# Search of existance of the $name in the rest of arguments.
# Usage:
#   argument::exists 'name' "$@"
#
# 'name' presence can occur in different forms:
#   --name -name --name=value -name=value name=value
#
# returns 0 if exists, 1 if not
argument::exists() {
    local -r name="${1:-}"
    shift

    for option in "$@"; do
        case ${option:-} in
            "$name="*|-"$name="*|--"$name="*) return 0;;
            -"$name"|--"$name") return 0;;
        esac
    done
    return 1
}

# Get the $name argument value in the rest of arguments.
# Usage:
#   argument::value 'name' "$@"
#
# 'name' presence can occur in different forms:
#   --name=value -name=value name=value --name value -name value
#
# return the value if exists
argument::value() {
    local -r name="${1:-}"
    shift

    for option in "$@"; do

        case ${option:-} in
        "$name="*|-"$name="*|--"$name="*)
            echo "${option#*=}"
            break
        ;;
        -"$name"|--"$name")
            echo "$2"
            break
        ;;

        esac

        shift
    done
}

