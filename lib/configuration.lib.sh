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

    version=$(config::find --filter=".version" --identifier="$identifier")
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

config::find() {
    local -r filter=$(argument::value 'filter' -- "$@")
    local -r identifier=$(argument::value 'identifier' -- "$@")
    local -r file=$(config::file_path "$identifier")

    local document=$(json::query -r "$filter" "$file")

    if argument::exists "interpolate" -- "$@"; then
        document=$(config::interpolate --text="$document" --identifier="$identifier")
    fi

    if argument::exists "prettify" -- "$@"; then
        json::prettify "$document"
    else
        echo "$document"
    fi
}

config::property() {
    local -r name=$(argument::value 'name' -- "$@")
    local -r identifier=$(argument::value 'identifier' -- "$@")
    local value=""

    if [ -n "$name" ]; then
        value=$(config::find --filter=".properties.\"$name\"" --identifier="$identifier")
        if [[ $value == null ]] && [[ $identifier != 'devkit' ]]; then
            value=$(config::find --filter=".properties.\"$name\"")
        fi
    fi

    if argument::exists "interpolate" -- "$@"; then
        config::interpolate --text="$value" --identifier="$identifier"
    elif [[ $value != null ]]; then
        echo $value
    fi
}

config::exists_property() {
    local -r name=$(argument::value 'name' -- "$@")
    local -r identifier=$(argument::value 'identifier' -- "$@")
    local -r filter=".properties | has(\"$name\")"

    local value="false"

    if [ -n "$name" ]; then
        value=$(config::find --filter="$filter" --identifier="$identifier")
        if [[ $value == "false" ]] && [[ $identifier != 'devkit' ]]; then
            value=$(config::find --filter="$filter")
        fi
    fi

    [[ $value == "true" ]]
}

config::interpolate() {
    local -r identifier=$(argument::value 'identifier' -- "$@")
    local text=$(argument::value 'text' -- "$@")
    local found_vars="false"

    if [[ $text != "" ]]; then
        for var in $(template::get_vars --text="$text"); do
            if config::exists_property --name="$var" --identifier="$identifier"; then
                value=$(config::property --name="$var" --identifier="$identifier")
                text=$(template::replace_var --text="$text" --name="$var" --value="$value")
                found_vars="true"
            fi
        done
    fi

    # if at least one var has been interpolated, then recurse to found more vars
    if [[ $found_vars == true ]]; then
        config::interpolate --text="$text" --identifier="$identifier"
    else
        echo $text
    fi
}

config::edit_file() {
    local -r name="${1:-}"
    local -r config_file="$(config::file_path $name)"

    log::info "Open '$name' config file in editor [$config_file]..."

    ${FCEDIT:-${VISUAL:-${EDITOR:-vi}}} "$config_file";
    return $?;
}
