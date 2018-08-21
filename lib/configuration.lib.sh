#!/usr/bin/env bash

import lib::log
import lib::json
import lib::template
import lib::argument

config::assert_file_exists() {
    local -r identifier="${1:-}"
    local -r file=$(config::file_path "$identifier")

    if [ ! -f "$file" ]; then
        printf "error: I can read configuration file [%s] :(\\n\\n" "$file" 1>&2
        exit 1
    fi

    version=$(config::find ".version" "$identifier")
    if [[ $version != $DEVKIT_VERSION ]]; then
        printf "bad config: [%s] declares wrong version: %s (expected %s)\\n\\n" \
         "$file" "$version" "$DEVKIT_VERSION" 1>&2
        exit 1
    fi
}

config::file_path() {
    local -r identifier="${1:-devkit}"

    echo "${DEVKIT_CONFIG_PATH}/$identifier-config.json"
}

config::find_with_colors() {
    local -r filter="${1:-.}"
    local -r file="$(config::file_path ${2:-})"

    json::query -Cr "$filter" "$file"
}

config::_find() {
    local -r filter=$(argument::value 'filter' "$@")
    local -r identifier=$(argument::value 'identifier' "$@")
    local -r file=$(config::file_path "$identifier")

    local document=$(json::query -r "$filter" "$file")

    if argument::exists "interpolate" "$@"; then
        document=$(config::interpolate "$document" "$identifier")
    fi

    if argument::exists "prettify" "$@"; then
        json::prettify "$document"
    else
        echo "$document"
    fi
}

config::find() {
    local -r filter="${1:-.}"
    local -r identifier="${2:-}"
    local -r interpolate=$(argument::get "interpolate" "$@")
    local -r prettify=$(argument::get "prettify" "$@")

    config::_find --filter="$filter" --identifier="$identifier" "$interpolate" "$prettify"
}

config::find_property() {
    local -r name="$1"
    local -r identifier="${2:-}"
    local -r file="$(config::file_path $identifier)"
    local value

    if [ -n "$name" ]; then
        value=$(config::_find --filter=".properties.\"$name\"" --identifier="$identifier")
        if [[ $value == null ]] && [[ $identifier != 'devkit' ]]; then
            value=$(config::_find --filter=".properties.\"$name\"")
        fi
    fi
    [[ $value != null ]] && echo $value
}

config::interpolate() {
    local -r document="${1:-}"
    local -r identifier="${2:-}"
    local partial="$document"

    keys=( $(config::_find --filter=".properties | keys | .[]" --identifier="$identifier") )
    for key in "${keys[@]}"; do
        partial=$(template::replace_var "$partial" "$key" "$(config::find_property $key $identifier)")
    done

    # try to find properties in base configuration with not empty identifier
    if [[ $identifier != "" ]]; then
        keys=($(config::_find --filter=".properties | keys | .[]"))
        for key in "${keys[@]}"; do
            partial=$(template::replace_var "$partial" "$key" "$(config::find_property $key $identifier)")
        done
    fi

    echo $partial
}

config::edit_file() {
    local -r name="${1:-}"
    local -r config_file="$(config::file_path $name)"

    log::info "Open '$name' config file in editor [$config_file]..."

    ${FCEDIT:-${VISUAL:-${EDITOR:-vi}}} "$config_file";
    return $?;
}
