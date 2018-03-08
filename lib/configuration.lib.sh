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
