#!/usr/bin/env bash
#=|
#=| DESCRIPTION
#%|   Utility to work with micrservices (now: git+gradle+springboot+eureka)
#=|
#+| USAGE
#+|    ms [-c] [-b] [-r [-a <run_argument=value>]] <microservice>
#+|    ms [-q <query-name|query> ]
#+|    ms [-h]
#+|    ms <microservice>
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
#+|
#+| EXAMPLES
#+|   ms microservice1
#+|   ms -cbr microservice1
#+|   ms -r -a log=debug microservice1
#+|   ms -q ports
#+|   ms -q ".workspace"
#=|
#-| AUTHORING
#-|   author          @jeslopalo <Jesús López Alonso>
#-|   year            2018
#=|
source $DEVKIT_LIB/error.lib.sh

# configure exception traps
enable_traps --path-prefix=$DEVKIT_HOME

source $DEVKIT_LIB/usage.lib.sh
source $DEVKIT_LIB/configuration.lib.sh
source $DEVKIT_MODULE/microservice/lib/dependencies.lib.sh
source $DEVKIT_MODULE/microservice/lib/microservices.lib.sh

microservice_usage() {
    local -r exit_code=${1:-0}
    usage

    printf "\\nAVAILABLE SERVICES:\\n"
    find_microservice_names_in_columns

    exit ${exit_code}
}

main() {

    check_for_dependencies
    assert_configuration_file_exists

    if [ "$#" = 0 ]; then
        printf "Sorry! I need something more to continue :(\\n\\n" 1>&2
        microservice_usage 1
    fi

    local QUERY
    local CLEAN
    local BUILD
    local RUN
    local JAVA_OPTS
    local RUN_ARGUMENTS

    while getopts ":hcbra:q:" opt; do
        case "${opt}" in
            h) microservice_usage 0;;
            c) CLEAN="--clean";;
            b) BUILD="--build";;
            r) RUN="--run";;
            a) RUN_ARGUMENTS="$RUN_ARGUMENTS $OPTARG";;
            q) QUERY="$OPTARG";;
            \?)
                printf "invalid option: %s\\n\\n" "$OPTARG" 1>&2
                microservice_usage 1
            ;;
            :)
                printf "invalid option: -%s requires an argument\\n\\n" "$OPTARG" 1>&2
                microservice_usage 1
            ;;
            *)
                printf "invalid option: %s\\n\\n" "${opt}" 1>&2
                microservice_usage 1
            ;;
        esac
    done

    shift $((OPTIND-1))

    if [ -n "${QUERY:-}" ]; then
        case "${QUERY}" in
            all)
                find_with_colors ".microservices" | less -FRX
                exit $?
            ;;
            names)
                printf "\\n"
                find_microservice_names_in_columns
                exit $?
            ;;
            registerables)
                printf "\\n"
                find_eureka_registerable_microservices_in_columns
                exit $?
            ;;
            ports)
                printf "\\n"
                find_microservice_ports_in_use
                exit $?
            ;;
            *)
                printf "\\n"
                find_with_colors "$QUERY" | less -FRX
                exit $?
            ;;
        esac
    fi

    if [ "$#" != 1 ]; then
        printf "Sorry! I need a microservice name to continue :(\\n\\n" 1>&2
        microservice_usage 1
    fi

    name="$1"
    if [ -z "$CLEAN" ] && [ -z "$BUILD" ] && [ -z "$RUN" ]; then
        if exists_microservice_by_name "$name"; then
            find_microservice_by_name "$name"
            exit 0
        else
            printf "Sorry! I can't find a '%s' microservice configuration :(\\n\\n" "$name" 1>&2
            exit 1
        fi
    fi

    slug="$(find_microservice_slug_by_name $name)"
    if [ -z "$slug" ] || [ "$slug" = "null" ]; then
        printf "Sorry! I can't find a '%s' microservice configuration :(\\n\\n" "$name" 1>&2
        microservice_usage 1
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
            eureka -u "$name"
        fi

        JAVA_OPTS="${run_javaopts[*]}";
        run "$slug" "${run_arguments[*]}"
    }

    exit "$?"
}

main "$@"
