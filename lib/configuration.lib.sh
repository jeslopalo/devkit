#!/usr/bin/env bash

find() {
    local -r filter="${1:-.}"
    local -r file="${2:-$TDK_CONFIGURATION}"

    jq -r "$filter" "$file"
}

find_ms_workspace() {
    local -r workspace=$(find ".ms.workspace")

    echo "${workspace/#\~/$HOME}"
}

find_maintenance_workspace() {
    local -r workspace=$(find ".maintenance.workspace")

    echo "${workspace/#\~/$HOME}"
}

find_maintenance_idea_cache_dir() {
    local -r workspace=$(find '.maintenance."idea-cache-dir"')

    echo "${workspace/#\~/$HOME}"
}

find_microservice_names() {
    local -r separator="${1:-,}"
    local -r names=($(find ".microservices[].name"))

    echo $(IFS="$separator" ; echo "${names[*]}")
}

find_microservice_by_name() {
    local name="$1"

    find ".microservices[] | select(.name == \"$name\")"
}

exists_microservice_by_name() {
    local name="$1"
    [[ $(find ".microservices[] | select(.name == \"$name\") | [.] | length") = 1 ]]
}

find_microservice_slug_by_name() {
    local name="$1"

    echo "$(find_microservice_by_name $name)" | jq -r ".slug?"
}

find_microservice_build_config() {
    local name="$1"

    echo "$(find_microservice_by_name $name)" | jq -r '."build-config"?'
}

find_microservice_build_javaopts() {
    local -r name="$1"
    local -r extra_opts="$2"
    local -r java_opts=$(echo "$(find_microservice_build_config $name)" | jq -r '."java-opts"[]?')

    echo "${java_opts[*]} $extra_opts"
}

find_microservice_build_parameters() {
    local name="$1"

    echo "$(find_microservice_build_config $name)" | jq -r '.params[]?'
}

find_microservice_run_config() {
    local name="$1"

    echo "$(find_microservice_by_name $name)" | jq -r '."run-config"?'
}

find_microservice_run_javaopts() {
    local -r name="$1"
    local -r extra_opts="$2"
    local -r java_opts=$(echo "$(find_microservice_run_config $name)" | jq -r '."java-opts"[]?')

    echo "${java_opts[*]} $extra_opts"
}

find_microservice_run_parameters() {
    local -r name="$1"
    local -r config_parameters=$(echo "$(find_microservice_run_config $name)" | jq -r ".params?")

    if [ -n "$2" ]; then
        local -r cli_parameters=$(jq -sR \
            'splits(" ")|split("=") as $i|{($i[0]?):($i[1]|sub("^(\\s)+";"";"x"))}' <<< $2 | jq -s "add")

        map=$(merge_json_maps "$config_parameters" "$cli_parameters")
        json_map_to_array_of_parameters "$map"
    else
        json_map_to_array_of_parameters "$config_parameters"
    fi
}

merge_json_maps() {
    local -r json_a="$1"
    local -r json_b="$2"

    if [ -z "$json_a" ]; then
        echo $json_b
    elif [ -z "$json_b" ]; then
        echo $json_a
    else
        jq -n --argjson json_a "$json_a" --argjson json_b "$json_b" '$json_a + $json_b'
    fi
}

json_map_to_array_of_parameters() {
    local -r map="$1"

    if [ -n "$map" ] && [ "$map" != null ]; then
        jq -r ". | to_entries | map(\"--\(.key)=\(.value|tostring)\") | .[]?" <<< "$map"
    fi
}
