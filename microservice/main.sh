#!/usr/bin/env bash

[[ -f $PWD/.tdkrc ]] && source $PWD/.tdkrc
[[ -f $PWD/../.tdkrc ]] && source $PWD/../.tdkrc

source $TDK_HOME/microservice/lib/dependencies.sh
source $TDK_HOME/microservice/lib/microservices.lib.sh

TDK_CONFIGURATION="$TDK_HOME/config-dev.json"
microservices=( $(jq -r ".microservices[].name" "$TDK_CONFIGURATION") )

usage() {
    printf "usage: ms [-i <microservice>]\\n\\n"
    printf "  -c\\t\\t\\tClean <microservice>\\n"
    printf "  -b\\t\\t\\tBuild <microservice>\\n"
    printf "  -r\\t\\t\\tRun <microservice>\\n"
    printf "  -i\\t\\t\\tPrint microservice info\\n"
    printf "  -h\\t\\t\\tShow this help message\\n"

    printf "\\nAvailable services:\\n %s\\n" "$(find_microservice_names)"
    exit 0
}

find() {
    local -r filter="${1:-.}"

    jq -r "$filter" "$TDK_CONFIGURATION"
}

find_microservice_names() {
    local -r names=($(find ".microservices[].name"))

    echo $(IFS="," ; echo "${names[*]}")
}

find_microservice_by_name() {
    local name="$1"

    find ".microservices[] | select(.name == \"$name\")"
}

find_microservice_slug_by_name() {
    local name="$1"

    echo "$(find_microservice_by_name $name)" | jq -r ".slug"
}

find_microservice_build_config() {
    local name="$1"

    echo "$(find_microservice_by_name $name)" | jq -r '."build-config"'
}

find_microservice_build_parameters() {
    local name="$1"

    echo "$(find_microservice_build_config $name)" | jq -r '.params[]'
}

find_microservice_run_config() {
    local name="$1"

    echo "$(find_microservice_by_name $name)" | jq -r '."run-config"'
}

find_microservice_run_parameters() {
    local name="$1"

    echo "$(find_microservice_run_config $name)" \
        | jq -r ".params | to_entries | map(\"--\(.key)=\(.value|tostring)\") | .[]"
}

main() {

    if [ "$#" = 0 ]; then
        printf "Sorry! I need something more to continue :(\\n\\n" 1>&2
        usage
        exit 1
    fi

    # obtiene las opciones de ejecución
    while getopts ":hcbri:" opt; do
        case "${opt}" in
            i) find_microservice_by_name $OPTARG; exit 0;;
            c) CLEAN="--clean";;
            b) BUILD="--build";;
            r) RUN="--run";;
            h) usage;;
            \?)
                printf "invalid option: %s\\n\\n" "$OPTARG" 1>&2
                usage
            ;;
            :)
                printf "invalid option: -%s requires an argument\\n\\n" "$OPTARG" 1>&2
                usage
            ;;
            *)
                printf "invalid option: %s\\n\\n" "${opt}" 1>&2
                usage
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
    run_parameters=($(find_microservice_run_parameters $name))

    if [ -n "$CLEAN" ] || [ -n "$BUILD" ] || [ -n "$RUN" ]; then
        microservice_lifecycle "$slug" $CLEAN $BUILD "${build_parameters[*]}" $RUN --parameters "${run_parameters[*]}"
    fi
}

main "$@"
