#!/usr/bin/env bash

source $(dirname $(sourcedir "$BASH_SOURCE"))/../bootstrap.bash

load_lib bats-support
load_lib bats-assert

setup() {
    import lib::import
}
