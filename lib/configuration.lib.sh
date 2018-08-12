#!/usr/bin/env bash

import lib::template
import lib::lang
import lib::log
import lib::json

assert_configuration_file_exists() {
    local -r file="${1:-}"

    if [ ! -f "$file" ]; then
        printf "error: I can read configuration file [%s] :(\\n\\n" "$file" 1>&2
        exit 1
    fi

    version=$(find ".version" "$file")
    if [[ $version != $DEVKIT_VERSION ]]; then
        printf "bad config: [%s] declares wrong version: %s (expected %s)\\n\\n" \
         "$file" "$version" "$DEVKIT_VERSION" 1>&2
        exit 1
    fi
}

find_with_colors() {
    local -r filter="${1:-.}"
    local -r file="${2:-}"

    json::query -Cr "$filter" "$file"
}

find() {
    local -r filter="${1:-.}"
    local -r file="${2:-}"

    json::query -r "$filter" "$file"
}

find_property() {
    local -r name="$1"
    local -r file="${2:-}"

    if [ -n "$name" ]; then
        find ".properties.\"$name\"" "$file"
    fi
}

edit_config_file() {
    local -r name="${1:-}"
    local -r config_file="${DEVKIT_CONFIG_PATH}/$name-config.json"

    log::info "Open '$name' config file in editor [$config_file]..."

    ${FCEDIT:-${VISUAL:-${EDITOR:-vi}}} "$config_file";
    return $?;
}
