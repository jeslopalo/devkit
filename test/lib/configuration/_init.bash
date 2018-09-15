#!/usr/bin/env bash

source $(sourcedir --base)/test/bootstrap.bash

load_lib bats-support
load_lib bats-assert

setup() {
    import lib::configuration

    fixtures
    DEVKIT_CONFIG_PATH="$FIXTURE_ROOT"
}

query_config() {
    local -r filter="${1:-}"
    jq "$filter" -cM "$DEVKIT_CONFIG_PATH/devkit-config.json"
}

query_config_prettified() {
    local -r filter="${1:-}"
    jq "$filter" -C "$DEVKIT_CONFIG_PATH/devkit-config.json"
}
