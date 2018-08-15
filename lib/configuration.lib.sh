#!/usr/bin/env bash

import lib::log
import lib::json

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

config::find() {
    local -r filter="${1:-.}"
    local -r file="$(config::file_path ${2:-})"

    json::query -r "$filter" "$file"
}

config::find_property() {
    local -r name="$1"
    local -r identifier="${2:-}"
    local -r file="$(config::file_path $identifier)"

    if [ -n "$name" ]; then
        config::find ".properties.\"$name\"" "$identifier"
    fi
}

config::edit_file() {
    local -r name="${1:-}"
    local -r config_file="$(config::file_path $name)"

    log::info "Open '$name' config file in editor [$config_file]..."

    ${FCEDIT:-${VISUAL:-${EDITOR:-vi}}} "$config_file";
    return $?;
}
