#!/usr/bin/env bash

is_var_defined()
{
    if [ $# -ne 1 ]
    then
        echo "Expected exactly one argument: variable name as string, e.g., 'my_var'"
        exit 1
    fi

    [ ! -z ${!1:-} ];
}

is_var_not_defined() {
    ! is_var_defined "$@"
}
