#!/usr/bin/env bash
#=|
#=| SYNOPSIS
#>|   eureka [-h] [-r <services> [-e <services>]] [-u <services>]
#=|
#=| DESCRIPTION
#%|   Utility to register services in eureka server
#+|
#+| USAGE
#+|   eureka [-h] [-r <services> [-e <services>]] [-u <services>]
#+|
#+| OPTIONS
#+|   -r all | <service1 [,service2]>       Register every service (comma-separated names or all)
#+|   -e <service1 [,service2]>             Exclude this services from being registered (comma-separated)
#+|   -u all | <service1 [,service2]>       Unregister every service (comma-separated names or all)
#+|   -h                                    Print this help message
#+|
#+| EXAMPLES
#+|   eureka -r all
#+|   eureka -r all -e service1
#+|   eureka -r service1,service2
#+|   eureka -u all
#+|   eureka -u service1,service2
#+|   eureka -r service1 -u service2
#+|
#+| AVAILABLE SERVICES
#+| ((ms -q registerables))
#-|
#-| AUTHORING
#-|   author          @jeslopalo <Jesús López Alonso>
#-|   year            2018
#=|
include lib::usage "$@"

using ms

import lib::color
import lib::log
import lib::configuration

import module::eureka::configuration
import module::eureka::eureka

main() {
    eureka::assert_file_exists

    local exclusions=()
    local register=()
    local unregister=()

    if [ "$#" = 0 ]; then
        log::warn "Sorry! I need something more to continue :("
        log::usage "$(eureka --synopsis)"
        exit 1
    fi

    while getopts ":he:r:u:" opt; do
        case "${opt}" in
            e) IFS=', ' read -r -a exclusions <<< "${OPTARG}";;
            r)
                if [ "${OPTARG}" = "all" ]; then
                    register=( $(ms -q registerables) )
                else
                    IFS=', ' read -r -a register <<< "${OPTARG}"
                fi
            ;;
            u)
                if [ "${OPTARG}" = "all" ]; then
                    unregister=( $(ms -q registerables) )
                else
                    IFS=', ' read -r -a unregister <<< "${OPTARG}"
                fi
            ;;
            h)
                eureka --help
                exit 0
            ;;
            :)
                log::error "invalid option: -$OPTARG requires an argument"
                log::usage "$(eureka --synopsis)"
                exit 1
            ;;
            \?|*)
                log::error "invalid option: $OPTARG"
                log::usage "$(eureka --synopsis)"
                exit 1
            ;;
        esac
    done

    shift $((OPTIND-1))

    # It's an error if there are more parameters
    if [ "$#" -gt 0 ]; then
        log::error "invalid option: $*"
        log::usage "$(eureka --synopsis)"
        exit 1
    fi

    # exclude services to be registered
    for exclusion in "${exclusions[@]:-}"; do
        if [[ -n ${exclusion:-} ]]; then
            log::info "Excluding service from being registered in eureka: ${exclusion}"

            # TODO: That removes prefixes matching $exclusion from the elements, not necessarily whole elements.
            register=( ${register[@]/$exclusion/} )
        fi
    done

    # the list of services to be registered must not be empty
    if [ "${#register[@]}" != 0 ]; then
        register_services ${register[*]}
    fi

    # the list of services to be unregistered must not be empty
    if [ "${#unregister[@]}" != 0 ]; then
        unregister_services ${unregister[*]}
    fi
}

main "$@"
