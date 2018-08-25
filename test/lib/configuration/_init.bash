#!/usr/bin/env bash

source $(dirname $(sourcedir "$BASH_SOURCE"))/../bootstrap.bash

setup() {
    import lib::configuration

    fixtures
    DEVKIT_CONFIG_PATH="$FIXTURE_ROOT"
}
