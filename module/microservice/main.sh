#!/usr/bin/env bash

source $TDK_LIB_DIR/configuration.lib.sh
source $TDK_MODULE_DIR/microservice/lib/dependencies.lib.sh
source $TDK_MODULE_DIR/microservice/lib/microservices.lib.sh

usage() {
    printf "usage: ms [-h][-c][-b][-r [-p <run_parameter=value>]] <microservice>\\n\\n"
    printf "  -c\\tClean <microservice>\\n"
    printf "  -b\\tBuild <microservice>\\n"
    printf "  -r\\tRun <microservice>\\n"
    printf "  -h\\tShow this help message\\n"

    printf "\\nAvailable services:\\n  %s\\n" "$(find_microservice_names)"
}

main() {

    check_for_dependencies

    if [ "$#" = 0 ]; then
        printf "Sorry! I need something more to continue :(\\n\\n" 1>&2
        usage
        exit 1
    fi

    while getopts ":hcbri:p:" opt; do
        case "${opt}" in
            c) CLEAN="--clean";;
            b) BUILD="--build";;
            r) RUN="--run";;
            p) RUN_PARAMETERS="$RUN_PARAMETERS $OPTARG";;
            h) usage; exit 1;;
            \?)
                printf "invalid option: %s\\n\\n" "$OPTARG" 1>&2
                usage
                exit 1
            ;;
            :)
                printf "invalid option: -%s requires an argument\\n\\n" "$OPTARG" 1>&2
                usage
                exit 1
            ;;
            *)
                printf "invalid option: %s\\n\\n" "${opt}" 1>&2
                usage
                exit 1
            ;;
        esac
    done

    shift $((OPTIND-1))

    if [ "$#" != 1 ]; then
        printf "Sorry! I need a microservice name to continue :(\\n\\n" 1>&2
        usage
        exit 1
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
        usage
        exit 1
    fi
    shift

    [ -n "$CLEAN" ] && clean "$slug"
    [ -n "$BUILD" ] && (
        build_parameters=($(find_microservice_build_parameters $name))
        build_javaopts=($(find_microservice_build_javaopts "$name" "$JAVA_OPTS"))

        JAVA_OPTS="${build_javaopts[*]}";
        build "$slug" "${build_parameters[*]}";
    )
    [ -n "$RUN" ] && (
        run_parameters=($(find_microservice_run_parameters "$name" "$RUN_PARAMETERS"))
        run_javaopts=($(find_microservice_run_javaopts "$name" "$JAVA_OPTS"))

        JAVA_OPTS="${run_javaopts[*]}";
        run "$slug" "${run_parameters[*]}";
    )
}

main "$@"
