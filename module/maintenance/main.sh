#!/usr/bin/env bash
#=|
#=| SYNOPSIS
#>|   maintenance [-h] [-c <clean job>]
#=|
#=| DESCRIPTION
#%|   Maintenance operations: cleaning caches, workspaces, etc.
#+|
#+| USAGE
#+|   maintenance [-h] [-c <clean job>]
#+|
#+| OPTIONS
#+|   -c <clean job>        Execute a clean job
#+|   -h                    Print this help message
#+|
#+| CLEAN JOBS
#+|   builds                Clean project workspaces
#+|   caches                Clean caches (IDEA, etc)
#+|   all                   Execute all clean jobs
#+|
#+| EXAMPLES
#+|   maintenance -c builds
#+|   maintenance -h
#-|
#-| AUTHORING
#-|   author          @jeslopalo <Jesús López Alonso>
#-|   year            2018
#=|
include lib::usage "$@"

include lib::log

import module::maintenance::configuration
import module::maintenance::maintenance

clean() {
    local -r opt="${1:-}"

    case "${opt}" in
        caches)
            maintenance::clean_intellij_caches
        ;;
        builds)
            maintenance::clean_workspace
        ;;
        all)
            maintenance::clean_intellij_caches
            printf "\\n"
            maintenance::clean_workspace
        ;;
        *)
            log::error "invalid option: $option"
            exit 1
        ;;
    esac

    exit $?
}

main() {
    maintenance::assert_file_exists

    if [ "$#" = 0 ]; then
        log::warn "Sorry! I need something more to continue :("
        log::usage "$(maintenance --synopsis)"
        exit 1
    fi

    local clean="none"

    while getopts ":hc:" opt; do
        case "${opt}" in
            c)
                clean "${OPTARG}"
                exit $?
            ;;
            h)
                maintenance --help
                exit 0
            ;;
            :)
                log::error "invalid option: -$OPTARG requires an argument"
                log::usage "$(maintenance --synopsis)"
                exit 1
            ;;
            \?|*)
                log::error "invalid option: $OPTARG"
                log::usage "$(maintenance --synopsis)"
                exit 1
            ;;
        esac
    done

    shift $((OPTIND-1))

    # It's an error if there are more parameters
    if [ "$#" -gt 0 ]; then
        log::error "invalid option: $*"
        log::usage "$(maintenance --synopsis)"
        exit 1
    fi
}

main "$@"
