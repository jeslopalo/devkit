#!/usr/bin/env bash

declare -i CONFIGURATION_FILE_VERSION=1

assert_configuration_file_exists() {
    local -r file="${1:-$TDK_CONFIGURATION}"

    if [ ! -f "$file" ]; then
        printf "error: I can read configuration file [%s] :(\\n\\n" "$file" 1>&2
        exit 1
    fi

    version=$(find_version "$file")
    if [[ $version != $CONFIGURATION_FILE_VERSION ]]; then
        printf "bad config: [%s] declares wrong version: %s (expected %s)\\n\\n" \
         "$file" "$version" "$CONFIGURATION_FILE_VERSION" 1>&2
        exit 1
    fi
}

find_with_colors() {
    local -r filter="${1:-.}"
    local -r file="${2:-$TDK_CONFIGURATION}"

    [ -f "$file" ] && jq -Cr "$filter" "$file"
}

find() {
    local -r filter="${1:-.}"
    local -r file="${2:-$TDK_CONFIGURATION}"

    [ -f "$file" ] && jq -r "$filter" "$file"
}

find_property() {
    local -r name="$1"
    local -r default="$2"

    if [ -n "$name" ]; then
        value=$(find ".properties.\"$name\"")
        if [ "$value" = null ] && [ -n $default ]; then
            echo "$default"
        else
            echo "$value"
        fi
    fi
}

find_version() {
    find ".version" "$@"
}

find_eureka_register_url_pattern() {
    find '.eureka."register-url"'
}

find_eureka_unregister_url_pattern() {
    find '.eureka."unregister-url"'
}

find_eureka_registerable_microservices() {
    find '.microservices.defaults."eureka-registerable" as $default|.microservices.data[]|{name:.name,registerable:(if ."eureka-registerable" == null then $default else ."eureka-registerable" end)}|select(.registerable==true)|.name' | sort
}

find_eureka_registerable_microservices_in_columns() {
    for value in $(find_eureka_registerable_microservices); do
        printf "%-8s\n" "${value}"
    done | column -x
}

is_microservice_registerable_in_eureka() {
    local -r name="$1"

    registerable=$(find '.microservices.defaults."eureka-registerable" as $default|.microservices.data[]|select(.name == "'$name'")|{name:.name,registerable:(if ."eureka-registerable" == null then $default else ."eureka-registerable" end)}|.registerable')
    [[ $registerable == "true" ]]
}

find_microservice_ports_in_use() {
    find '[.microservices.data[]|select(.run.arguments."server.port" != null)|{ key: .name, value: .run.arguments."server.port"}]|sort_by(.value)|map("  \(.value):\t\(.key)")|.[]'
}

find_microservice_workspace() {
    local -r workspace=$(find ".microservices.workspace")

    echo "${workspace/#\~/$HOME}"
}

find_maintenance_workspace() {
    local -r workspace=$(find_property "workspaces-dir")

    echo "${workspace/#\~/$HOME}"
}

find_maintenance_idea_cache_dir() {
    local -r cache_dir=$(find_property "idea-cache-dir")

    echo "${cache_dir/#\~/$HOME}"
}

find_microservice_default_build_params() {
    find ".microservices.defaults.build?.params[]?"
}

find_microservice_default_build_javaopts() {
    find ".microservices.defaults.build?.javaopts[]?"
}

find_microservice_default_run_arguments() {
    find ".microservices.defaults.run?.arguments?"
}

find_microservice_default_run_javaopts() {
    find ".microservices.defaults.run?.javaopts[]?"
}

find_microservice_names() {
    local -r separator="${1:-,}"
    local -r names=($(find ".microservices.data[].name" | sort))

    echo $(IFS="$separator" ; echo "${names[*]}")
}

find_microservice_names_in_columns() {
    for value in $(find_microservice_names " "); do
        printf "%-8s\n" "${value}"
    done | column -x
}

find_microservice_by_name() {
    local name="$1"

    find ".microservices.data[] | select(.name == \"$name\")"
}

exists_microservice_by_name() {
    local name="$1"

    [[ $(find ".microservices.data[] | select(.name == \"$name\") | [.] | length") = 1 ]]
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
    local -r default_parameters=$(find_microservice_default_build_params)
    local -r parameters=$(echo "$(find_microservice_build_config $name)" | jq -r '.params[]?')

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

find_microservice_run_arguments() {
    local -r name="$1"
    local -r defaults=$(find_microservice_default_run_arguments)
    local arguments=$(echo "$(find_microservice_run_config $name)" | jq -r ".arguments?")

    arguments=$(merge_json_maps "$defaults" "$arguments")

    if [ -n "$2" ]; then
        local -r cli_arguments=$(jq -sR \
            'splits(" ")|split("=") as $i|{($i[0]?):($i[1]|sub("^(\\s)+";"";"x"))}' <<< $2 | jq -s "add")

        arguments=$(merge_json_maps "$arguments" "$cli_arguments")
    fi

    json_map_to_array_of_arguments "$arguments"
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

json_map_to_array_of_arguments() {
    local -r map="$1"

    if [ -n "$map" ] && [ "$map" != null ]; then
        jq -r ". | to_entries | map(\"--\(.key)=\(.value|tostring)\") | .[]?" <<< "$map"
    fi
}
