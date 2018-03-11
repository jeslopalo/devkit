#!/usr/bin/env bash

source $TDK_LIB_DIR/configuration.lib.sh
source $TDK_MODULE_DIR/microservice/lib/dependencies.lib.sh
source $TDK_MODULE_DIR/microservice/lib/microservices.lib.sh

usage() {
    printf "usage: ms [-h][-i <microservice>][-c][-b][-r [-p <run_parameter=value>]] <microservice>\\n\\n"
    printf "  -c\\tClean <microservice>\\n"
    printf "  -b\\tBuild <microservice>\\n"
    printf "  -r\\tRun <microservice>\\n"
    printf "  -i\\tPrint microservice info\\n"
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
            i) find_microservice_by_name $OPTARG; exit 0;;
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
    slug="$(find_microservice_slug_by_name $name)"
    if [ -z "$slug" ]; then
        printf "Sorry! I can't find a '%s' microservice configuration :(\\n\\n" "$name" 1>&2
        usage
        exit 1
    fi
    shift

    build_parameters=($(find_microservice_build_parameters $name))
    build_javaopts=($(find_microservice_build_javaopts "$name" "$JAVA_OPTS"))

    run_parameters=($(find_microservice_run_parameters "$name" "$RUN_PARAMETERS"))
    run_javaopts=($(find_microservice_run_javaopts "$name" "$JAVA_OPTS"))

    if [ -z "$CLEAN" ] && [ -z "$BUILD" ] && [ -z "$RUN" ]; then
	    printf "Sorry! I need you to tell me what to do with <%s> microservice (ie. clean (-c), build (-b), run (-r)) :(\\n\\n" \
	        "$name" 1>&2
        usage
		return 1;
    fi

    [ -n "$CLEAN" ] && clean "$slug"
    [ -n "$BUILD" ] && { JAVA_OPTS="${build_javaopts[*]}"; build "$slug" "${build_parameters[*]}"; }
    [ -n "$RUN" ] && { JAVA_OPTS="${run_javaopts[*]}"; run "$slug" "${run_parameters[*]}"; }

}

main "$@"
