#!/usr/bin/env bash

json::query() {
    jq "$@"
}

json::merge_maps() {
    local -r json_a="$1"
    local -r json_b="$2"

    if [ -z "$json_a" ]; then
        echo $json_b
    elif [ -z "$json_b" ]; then
        echo $json_a
    else
        json::query -n --argjson json_a "$json_a" --argjson json_b "$json_b" '$json_a + $json_b'
    fi
}

json::map_to_array_of_arguments() {
    local -r map="$1"

    if [ -n "$map" ] && [ "$map" != null ]; then
        jq -r ". | to_entries | map(\"--\(.key)=\(.value|tostring)\") | .[]?" <<< "$map"
    fi
}