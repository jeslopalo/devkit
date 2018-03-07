#!/usr/bin/env bash

function include() {
    local -r name="${1}"

    [[ -f ${LIB_DIRECTORY}/${name}.lib.sh ]] && source ${LIB_DIRECTORY}/${name}.lib.sh
}
