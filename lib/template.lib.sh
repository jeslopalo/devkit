#!/usr/bin/env bash

import lib::argument

#
# Find {{varname}} matches in $template and replace with "value"
#
# usage: template::replace_var --text="$template" --name="varname" [--value="value"]
#
template::replace_var() {
    local template=$(argument::value "text" "$@")

    if argument::exists "name" "$@"; then
        local -r var_name=$(argument::value "name" "$@")
        local -r var_value=$(argument::value "value" "$@")

        shopt -s extglob
        template="${template//\{\{*([[:space:]])${var_name}*([[:space:]])\}\}/${var_value:-${!var_name}}}"
        shopt -u extglob
    fi

    echo "$template"
}

#
# Find every {{placeholder}} names in --text=text
#
# usage: template::get_vars --text="$text"
#
template::get_vars() {
    local -r text=$(argument::value "text" "$@")

    local -r replacement=" {{"
    local -r sanitized="${text//\{\{/$replacement}"
    local -r regex='\{\{([a-zA-Z_][a-zA-Z0-9_]*)\}\}'

    local -a var_names=()

    while read -ra words; do
        for word in "${words[@]}"; do
            if [[ $word =~ $regex ]]; then
                var_names=( "${var_names[@]:-}" "${BASH_REMATCH[@]:1}" )
            fi
        done
    done <<< "$sanitized"

    if [[ ${#var_names[@]} -gt 0 ]]; then
        echo ${var_names[@]} | xargs -n1 | sort -u | xargs
    fi
}
