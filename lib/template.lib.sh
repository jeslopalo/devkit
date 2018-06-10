#!/usr/bin/env bash

#
# usage: template::replace_var $template "varname" ["value"]
#
template::replace_var() {
    local template="${1}"
    local -r var_name="${2}"
    local -r var_value="${3:-${!var_name}}"

    if [ -z "$var_name" ]; then
        echo "$template"
    fi

    template="${template//\$\{$var_name\}/${var_value}}"
    eval echo '$template'
}
