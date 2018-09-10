#!/usr/bin/env bash

import lib::configuration
import lib::template
import lib::json

ms_config_identifier="ms"

ms::assert_file_exists() {
    config::assert_file_exists "$ms_config_identifier"
}

ms::find_version() {
    config::find --filter=".version" --identifier="$ms_config_identifier"
}

# customize configuration file identifier
ms::find() {
    config::find "$@" --identifier="$ms_config_identifier"
}

ms::find_registerables() {
    ms::find --interpolate --filter='.microservices.defaults.registerable as $default|.microservices.data[]|{name:.name,registerable:(if .registerable == null then $default else .registerable end)}|select(.registerable==true)|.name' | sort
}

ms::is_registerable() {
    local -r name="${1:-}"

    registerable=$(ms::find --interpolate --filter='.microservices.defaults."registerable" as $default|.microservices.data[]|select(.name == "'$name'")|{name:.name,registerable:(if ."registerable" == null then $default else ."registerable" end)}|.registerable')
    [[ $registerable == "true" ]]
}

ms::find_ports_in_use() {
    ms::find --interpolate --filter='[.microservices.data[]|select(.run.arguments."server.port" != null)|{ key: .name, value: .run.arguments."server.port"}]|sort_by(.value)|map("  \(.value):\t\(.key)")|.[]'
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
    local -r workspace=$(ms::find --interpolate --filter=".microservices.workspace")

    echo "${workspace/#\~/$HOME}"
}

ms::find_default_build_params() {
    ms::find --interpolate --filter=".microservices.defaults.build?.params[]?"
}

ms::find_default_build_javaopts() {
    ms::find --interpolate --filter=".microservices.defaults.build?.javaopts[]?"
}

ms::find_default_run_arguments() {
    ms::find --interpolate --filter=".microservices.defaults.run?.arguments?"
}

ms::find_default_run_javaopts() {
    ms::find --interpolate --filter=".microservices.defaults.run?.javaopts[]?"
}

ms::find_microservice_names() {
    local -r separator="${1:- }"
    local -r names=$(ms::find --interpolate --filter=".microservices.data[].name")
    local -r sorted=$(sort <<< "${names[*]}")

    echo $(IFS="$separator"; echo "${sorted[*]}")
}

ms::find_by_name() {
    local name="$1"
    local -r prettify=$(argument::get "prettify" -- "$@")

    ms::find --interpolate --filter=".microservices.data[] | select(.name == \"$name\")" "$prettify"
}

ms::exists_by_name() {
    local name="$1"

    [[ $(ms::find "--filter=.microservices.data[] | select(.name == \"$name\") | [.] | length") = 1 ]]
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

    endpoint_url=$(ms::find --interpolate --filter=".microservices.url.$environment")
    endpoint_url=$(template::replace_var --text="$endpoint_url" --name="name")
    endpoint_url=$(template::replace_var --text="$endpoint_url" --name="port")
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
