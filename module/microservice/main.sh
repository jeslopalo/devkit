#!/usr/bin/env bash
#=|
#=| SYNOPSIS
#>|   ms [-h] [-q <query|named-query>] [[-cbr [-a <arg=value>]] <service>]
#=|
#=| DESCRIPTION
#%|   Utility to work with micrservices (now: git+gradle+springboot+eureka)
#+|
#+| USAGE
#+|   ms [-c] [-b] [-r [-a <run_argument=value>]] <microservice>
#+|   ms [-q <named-query|query> ]
#+|   ms [-h]
#+|   ms <microservice>
#+|
#+| OPTIONS
#+|   -c <microservice>         Clean microservice's previous build (ie. gradle clean)
#+|   -b <microservice>         Build microservice
#+|   -r <microservice>         Run microservice
#+|   -a <key=value>            Run argument (it will be converted to --key=value)
#+|   -q <named-query>|<query>  Query configuration by named-query or by jq's query
#+|   -h                        Print this help message
#+|
#+| NAMED QUERIES
#+|   all               Print microservices configuration in use
#+|   names             Print every configured microservice's name
#+|   registerables     Print every configured microservice's name that is registerable in eureka server
#+|   ports             Print every configured microservice's port
#+|   defaults          Print microservice configuration defaults
#+|
#+| EXAMPLES
#+|   ms microservice1
#+|   ms -cbr microservice1
#+|   ms -r -a log=debug microservice1
#+|   ms -q ports
#+|   ms -q ".workspace"
#-|
#-| AUTHORING
#-|   author          @jeslopalo <Jesús López Alonso>
#-|   year            2018
#=|
include lib::usage "$@"

import lib::color
import lib::log
import lib::configuration

import module::microservice::dependencies
import module::microservice::microservices

microservice_usage() {
    ms --help
    printf "\\nAVAILABLE SERVICES:\\n"
    find_microservice_names_in_columns
}

main() {

    check_for_dependencies
    assert_configuration_file_exists

    if [ "$#" = 0 ]; then
        log::warn "Sorry! I need something more to continue :("
        log::usage "$(ms --synopsis)"
        exit 1
    fi

    local QUERY
    local CLEAN
    local BUILD
    local RUN
    local JAVA_OPTS
    local RUN_ARGUMENTS

    while getopts ":hcbra:q:" opt; do
        case "${opt}" in
            c) CLEAN="--clean";;
            b) BUILD="--build";;
            r) RUN="--run";;
            a) RUN_ARGUMENTS="$RUN_ARGUMENTS $OPTARG";;
            q) QUERY="$OPTARG";;
            h)
                microservice_usage
                exit 0
            ;;
            :)
                log::error "invalid option: -$OPTARG requires an argument"
                log::usage "$(ms --synopsis)"
                exit 1
            ;;
            \?|*)
                log::error "invalid option: $OPTARG"
                log::usage "$(ms --synopsis)"
                exit 1
            ;;
        esac
    done

    shift $((OPTIND-1))

    if [[ -n ${QUERY:-} ]]; then
        case "${QUERY}" in
            all)
                find_with_colors ".microservices" | less -FRX
                exit $?
            ;;
            names)
                find_microservice_names_in_columns
                exit $?
            ;;
            registerables)
                find_eureka_registerable_microservices_in_columns
                exit $?
            ;;
            ports)
                find_microservice_ports_in_use
                exit $?
            ;;
            defaults)
                find_with_colors ".microservices.defaults" | less -FRX
                exit $?
            ;;
            *)
                find_with_colors ".microservices$QUERY" | less -FRX
                exit $?
            ;;
        esac
    fi

    if [[ "$#" != 1 ]]; then
        log::warn "Sorry! I need a microservice name to continue :("
        log::usage "$(ms --synopsis)"
        exit 1
    fi

    name="$1"
    if [[ -z ${CLEAN:-} ]] && [[ -z ${BUILD:-} ]] && [[ -z ${RUN:-} ]]; then

        if exists_microservice_by_name "$name"; then
            find_microservice_by_name "$name"
            exit 0
        else
            log::error "Sorry! I can't find a '$name' microservice configuration :("
            exit 1
        fi
    fi

    slug="$(find_microservice_slug_by_name $name)"
    if [[ -z $slug ]] || [[ $slug = "null" ]]; then

        log::error "Sorry! I can't find a '$name' slug in microservice configuration :("
        exit 1
    fi
    shift

    [[ -n ${CLEAN:-} ]] && {
        clean "$slug"
    }

    [[ -n ${BUILD:-} ]] && {
        build_parameters=($(find_microservice_build_parameters $name))
        build_javaopts=($(find_microservice_build_javaopts "$name" "${JAVA_OPTS:-}"))

        JAVA_OPTS="${build_javaopts[*]}";

        build "$slug" "${build_parameters[*]}"
    }

    [[ -n ${RUN:-} ]] && {
        run_arguments=($(find_microservice_run_arguments "$name" "${RUN_ARGUMENTS:-}"))
        run_javaopts=($(find_microservice_run_javaopts "$name" "${JAVA_OPTS:-}"))

        if is_microservice_registerable_in_eureka "$name"; then
            if ! eureka -u "$name"; then
                #TODO include in log::warn messsage
                printf "\\n"
                log::warn "${yellow}WARN:$reset eureka server is not reachable and '$name' can't be unregistered!"
            fi
        fi

        JAVA_OPTS="${run_javaopts[*]}";
        run "$slug" "${run_arguments[*]}"
    }

    exit 0
}

main "$@"
