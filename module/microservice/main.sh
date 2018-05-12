#!/usr/bin/env bash

source $TDK_LIB/error.lib.sh

# configure exception traps
enable_traps --path-prefix=$TDK_HOME

source $TDK_LIB/configuration.lib.sh
source $TDK_MODULE/microservice/lib/dependencies.lib.sh
source $TDK_MODULE/microservice/lib/microservices.lib.sh

usage() {
    local -r exit_code=${1:-0}

    printf "Usage:\\n"
    printf "\\tms [-c] [-b] [-r [-a <run_argument=value>]] <microservice>\\n"
    printf "\\tms [-q all | info | names | ports]\\n"
    printf "\\tms [-e]\\n"
    printf "\\tms [-h]\\n"
    printf "\\nOptions:\\n\\n"
    printf "  -q\\tQuery configuration files by name: all,info,names,ports\\n"
    printf "  -c\\tClean <microservice>\\n"
    printf "  -b\\tBuild <microservice>\\n"
    printf "  -r\\tRun <microservice>\\n"
    printf "  -a\\tArgument (key=value) to execute microservice (it will be converted to --key=value)\\n"
    printf "  -e\\tOpen config file for editing\\n"
    printf "  -h\\tShow this help message\\n"

    printf "\\nAvailable services:\\n\\n"
    find_microservice_names_in_columns

    exit ${exit_code}
}

main() {

    check_for_dependencies
    assert_configuration_file_exists

    if [ "$#" = 0 ]; then
        printf "Sorry! I need something more to continue :(\\n\\n" 1>&2
        usage 1
    fi

    local QUERY
    local CLEAN
    local BUILD
    local RUN
    local JAVA_OPTS
    local RUN_ARGUMENTS

    while getopts ":hcbrea:q:" opt; do
        case "${opt}" in
            h) usage 0;;
            c) CLEAN="--clean";;
            b) BUILD="--build";;
            r) RUN="--run";;
            e) ${FCEDIT:-${VISUAL:-${EDITOR:-vi}}} "$TDK_CONFIG_FILE"; exit $?;;
            a) RUN_ARGUMENTS="$RUN_ARGUMENTS $OPTARG";;
            q) QUERY="$OPTARG";;
            \?)
                printf "invalid option: %s\\n\\n" "$OPTARG" 1>&2
                usage 1
            ;;
            :)
                printf "invalid option: -%s requires an argument\\n\\n" "$OPTARG" 1>&2
                usage 1
            ;;
            *)
                printf "invalid option: %s\\n\\n" "${opt}" 1>&2
                usage 1
            ;;
        esac
    done

    shift $((OPTIND-1))

    if [ -n "${QUERY}" ]; then
        case "${QUERY}" in
            all)
                find_with_colors "." | less -FRX
                exit 0
            ;;
            info)
                printf "\\n"
                printf "config file name:\\t%s\\n" "$TDK_CONFIG_FILE"
                printf "config file version:\\t%d\\n" "$(find_version)"
                exit 0
            ;;
            names)
                printf "\\n"
                find_microservice_names_in_columns
                exit 0
            ;;
            ports)
                printf "\\n"
                find_microservice_ports_in_use
                exit 0
            ;;
            *)
                printf "\\n"
                find_with_colors "$QUERY" | less -FRX
                exit 0
            ;;
        esac
    fi

    if [ "$#" != 1 ]; then
        printf "Sorry! I need a microservice name to continue :(\\n\\n" 1>&2
        usage 1
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
        usage 1
    fi
    shift

    [ -n "$CLEAN" ] && {
        clean "$slug"
    }

    [ -n "$BUILD" ] && {
        build_parameters=($(find_microservice_build_parameters $name))
        build_javaopts=($(find_microservice_build_javaopts "$name" "$JAVA_OPTS"))

        JAVA_OPTS="${build_javaopts[*]}";

        build "$slug" "${build_parameters[*]}"
    }
    [ -n "$RUN" ] && {
        run_arguments=($(find_microservice_run_arguments "$name" "$RUN_ARGUMENTS"))
        run_javaopts=($(find_microservice_run_javaopts "$name" "$JAVA_OPTS"))

        if is_microservice_registerable_in_eureka "$name"; then
            eureka -u "$name"
        fi

        JAVA_OPTS="${run_javaopts[*]}";
        run "$slug" "${run_arguments[*]}"
    }

    exit "$?"
}

main "$@"
