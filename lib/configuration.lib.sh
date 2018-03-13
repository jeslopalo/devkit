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

find_microservice_default_build_params() {
    find ".ms.defaults.build?.params[]?"
}

find_microservice_default_build_javaopts() {
    find ".ms.defaults.build?.javaopts[]?"
}

find_microservice_default_run_params() {
    find ".ms.defaults.run?.params?"
}

find_microservice_default_run_javaopts() {
    find ".ms.defaults.run?.javaopts[]?"
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

    echo "$(find_microservice_by_name $name)" | jq -r '.build?'
}

find_microservice_build_javaopts() {
    local -r name="$1"
    local -r extra_opts="$2"
    local -r default_opts=$(find_microservice_default_build_javaopts)
    local -r java_opts=$(echo "$(find_microservice_build_config $name)" | jq -r '.javaopts[]?')

    echo "$default_opts ${java_opts[*]} $extra_opts"
}

find_microservice_build_parameters() {
    local -r name="$1"
    local -r default_parameters=($(find_microservice_default_build_params))
    local -r parameters=($(echo "$(find_microservice_build_config $name)" | jq -r '.params[]?'))

    local combined=( "${default_parameters[@]}" "${parameters[@]}" )
    combined_and_sorted=($(printf "%s\n" "${combined[@]}" | sort -u))

    echo "${combined_and_sorted[@]}"
}

find_microservice_run_config() {
    local name="$1"

    echo "$(find_microservice_by_name $name)" | jq -r '.run?'
}

find_microservice_run_javaopts() {
    local -r name="$1"
    local -r extra_opts="$2"
    local -r default_opts=$(find_microservice_default_run_javaopts)
    local -r java_opts=$(echo "$(find_microservice_run_config $name)" | jq -r '.javaopts[]?')

    echo "$default_opts ${java_opts[*]} $extra_opts"
}

find_microservice_run_parameters() {
    local -r name="$1"
    local -r default_parameters=$(find_microservice_default_run_params)
    local config_parameters=$(echo "$(find_microservice_run_config $name)" | jq -r ".params?")

    config_parameters=$(merge_json_maps "$default_parameters" "$config_parameters")

    if [ -n "$2" ]; then
        local -r cli_parameters=$(jq -sR \
            'splits(" ")|split("=") as $i|{($i[0]?):($i[1]|sub("^(\\s)+";"";"x"))}' <<< $2 | jq -s "add")

        config_parameters=$(merge_json_maps "$config_parameters" "$cli_parameters")
    fi

    json_map_to_array_of_parameters "$config_parameters"
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
