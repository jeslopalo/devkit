#!/usr/bin/env bash

import lib::configuration
import lib::template
import lib::output
import lib::json

# set config file if it's not set before
is_var_not_defined "MS_CONFIG_FILE" && export MS_CONFIG_FILE="${DEVKIT_CONFIG_PATH}/ms-config.json"

ms::find_version() {
    find ".version" "$MS_CONFIG_FILE"
}

ms::assert_configuration_exists() {
    assert_configuration_file_exists "$MS_CONFIG_FILE"
}

# customize configuration file location
ms::find() {
    find "$@" "$MS_CONFIG_FILE"
}

# customize configuration file location
ms::find_with_colors() {
    find_with_colors "$@" "$MS_CONFIG_FILE"
}

ms::find_registerables() {
    ms::find '.microservices.defaults.registerable as $default|.microservices.data[]|{name:.name,registerable:(if .registerable == null then $default else .registerable end)}|select(.registerable==true)|.name' | sort
}

ms::is_registerable() {
    local -r name="${1:-}"

    registerable=$(ms::find '.microservices.defaults."eureka-registerable" as $default|.microservices.data[]|select(.name == "'$name'")|{name:.name,registerable:(if ."eureka-registerable" == null then $default else ."eureka-registerable" end)}|.registerable')
    [[ $registerable == "true" ]]
}

ms::find_ports_in_use() {
    ms::find '[.microservices.data[]|select(.run.arguments."server.port" != null)|{ key: .name, value: .run.arguments."server.port"}]|sort_by(.value)|map("  \(.value):\t\(.key)")|.[]'
}

ms::find_port () {
    local -r name="$1"
    local arguments=$(ms::find_run_arguments "$name")

    for argument in ${arguments[@]}; do
        if [[ $argument =~ "server.port"* ]]; then
            echo "${argument##*=}"
            return
        fi
    done
}

ms::find_workspace() {
    local -r workspace=$(ms::find ".microservices.workspace")

    echo "${workspace/#\~/$HOME}"
}

ms::find_default_build_params() {
    ms::find ".microservices.defaults.build?.params[]?"
}

ms::find_default_build_javaopts() {
    ms::find ".microservices.defaults.build?.javaopts[]?"
}

ms::find_default_run_arguments() {
    ms::find ".microservices.defaults.run?.arguments?"
}

ms::find_default_run_javaopts() {
    ms::find ".microservices.defaults.run?.javaopts[]?"
}

ms::find_microservice_names() {
    local -r separator="${1:- }"
    local -r names=$(ms::find ".microservices.data[].name")
    local -r sorted=$(sort <<< "${names[*]}")

    echo $(IFS="$separator"; echo "${sorted[*]}")
}

ms::find_by_name() {
    local name="$1"

    ms::find ".microservices.data[] | select(.name == \"$name\")"
}

ms::exists_by_name() {
    local name="$1"

    [[ $(ms::find ".microservices.data[] | select(.name == \"$name\") | [.] | length") = 1 ]]
}

ms::find_slug_by_name() {
    local name="$1"

    local configuration=$(ms::find_by_name $name)
    echo "$configuration" | json::query -r ".slug?"
}

ms::find_build_config() {
    local name="$1"

    echo "$(ms::find_by_name $name)" | json::query -r '.build?'
}

ms::find_endpoint_url() {
    local name="$1"
    local environment="${2:-local}"

    port=$(ms::find_port "$name")

    endpoint_url=$(ms::find ".microservices.url.$environment")
    endpoint_url=$(template::replace_var "$endpoint_url" "name")
    endpoint_url=$(template::replace_var "$endpoint_url" "port")
    echo "$endpoint_url"
}

ms::find_build_javaopts() {
    local -r name="$1"
    local -r extra_opts="$2"
    local -r default_opts=$(ms::find_default_build_javaopts)
    local -r java_opts=$(echo "$(ms::find_build_config $name)" | json::query -r '.javaopts[]?')

    echo "$default_opts ${java_opts[*]} $extra_opts"
}

ms::find_build_parameters() {
    local -r name="$1"
    local -r default_parameters=$(ms::find_default_build_params)
    local -r parameters=$(echo "$(ms::find_build_config $name)" | json::query -r '.params[]?')

    local combined=( "${default_parameters[@]}" "${parameters[@]}" )

    combined_and_sorted=($(printf "%s\n" "${combined[@]}" | sort -u))

    echo "${combined_and_sorted[@]}"
}

ms::find_run_config() {
    local name="$1"

    echo "$(ms::find_by_name $name)" | json::query -r '.run?'
}

ms::find_run_javaopts() {
    local -r name="$1"
    local -r extra_opts="$2"
    local -r default_opts=$(ms::find_default_run_javaopts)
    local -r java_opts=$(echo "$(ms::find_run_config $name)" | json::query -r '.javaopts[]?')

    echo "$default_opts ${java_opts[*]} $extra_opts"
}

ms::find_run_arguments() {
    local -r name="$1"
    local -r defaults=$(ms::find_default_run_arguments)
    local arguments=$(echo "$(ms::find_run_config $name)" | json::query -r ".arguments?")

    arguments=$(json::merge_maps "$defaults" "$arguments")

    if [ -n "$2" ]; then
        local -r cli_arguments=$(json::query -sR \
            'splits(" ")|split("=") as $i|{($i[0]?):($i[1]|sub("^(\\s)+";"";"x"))}' <<< $2 | json::query -s "add")

        arguments=$(json::merge_maps "$arguments" "$cli_arguments")
    fi

    json::map_to_array_of_arguments "$arguments"
}