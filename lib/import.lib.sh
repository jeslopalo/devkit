#!/usr/bin/env bash

source $DEVKIT_LIB/command.lib.sh

# When a source file is imported, it is also cached to be included only once
CACHED_IMPORTS=( "lib::import" "lib::command" )

import::list() {
    printf "[trace] imported libraries: %s\\n" "${CACHED_IMPORTS[*]}"
}

import::assert_that_is_valid() {
    local -r libid="${1:-}"

    if [[ -z ${libid:-} ]]; then
        printf "error: import with no arguments!\\n"
        return 1
    fi

    case $libid in
        lib::*)         return 0;;
        module::*::*)   return 0;;
        main::*)        return 0;;
        *)
            printf "error: %s: unkown library identifier\\n" "$libid"
            return 1
        ;;
    esac
}

import::location() {
    local -r libid="${1:-}"

    case $libid in
        lib::*)
            echo "$DEVKIT_LIB"
        ;;
        module::*::*)
            if [[ $libid =~ ^module::(.+)::.+$ ]]; then
                echo "$DEVKIT_MODULE/${BASH_REMATCH[1]}/lib"
            fi
        ;;
        main::*)
            if [[ $libid =~ ^main::(.+)$ ]]; then
                echo "$DEVKIT_MODULE/${BASH_REMATCH[1]}"
            fi
        ;;
    esac
}

import::filename() {
    local -r filename="${1##*::}"
    local -r extension="${2:-.sh}"
    echo "${filename}${extension}"
}

# contains(string, array)
#
# Returns 0 if the specified array contains the specified substring,
# otherwise returns 1.
#
import::contains() {
    local needle=${1:-}
    shift
    local -a haystack=( "$@" )

    for candidate in ${haystack[@]}; do
        if [[ $candidate == $needle ]]; then
            return 0
        fi
    done

    return 1
}

execute() {
    local -r libid="${1:-}"
    shift

    import::assert_that_is_valid "$libid" || exit 1

    local -r location=$(import::location "$libid")
    local -r filename=$(import::filename "main")

    if [[ ! -r $location/$filename ]]; then
        printf "error: '%s/%s': file not found" "$location" "$filename"
        exit 1
    fi

    source "$location/$filename" "$@"
}

import() {
    local -r libid="${1:-}"
    shift

    import::assert_that_is_valid "$libid" || exit 1

    local -r location=$(import::location "$libid")
    local -r filename=$(import::filename "$libid" ".lib.sh")

    if [[ ! -r $location/$filename ]]; then
        printf "error: '%s/%s': file not found" "$location" "$filename"
        exit 1
    fi

    if ! import::contains "$libid" "${CACHED_IMPORTS[@]}"; then
        CACHED_IMPORTS=( "${CACHED_IMPORTS[@]}" "$libid" )

        [[ ${DEVKIT_DEBUG:-0} -eq 0 ]] || {
            printf "m ${bpurple:-}%-10s?\\n\\t${green:-}%s${reset:-}\\n" "$libid" "${CACHED_IMPORTS[*]}" >> $DEVKIT_DEBUG_FILE;
        }
        source "$location/$filename" "$@"
    else
        [[ ${DEVKIT_DEBUG:-0} -eq 0 ]] || {
            printf "u ${bpurple:-}%-10s?\\n\\t${green:-}%s${reset:-}\\n" "$libid" "${CACHED_IMPORTS[*]}" >> $DEVKIT_DEBUG_FILE;
        }
    fi
}

include() {
    local -r libid="${1:-}"
    shift

    import::assert_that_is_valid "$libid" || exit 1

    local -r location=$(import::location "$libid")
    local -r filename=$(import::filename "$libid" ".lib.sh")

    if [[ ! -r $location/$filename ]]; then
        printf "error: '%s/%s': file not found" "$location" "$filename"
        exit 1
    fi

    source "$location/$filename" "$@"
}

using() {
    command::assert "${@//,/ }"
}
