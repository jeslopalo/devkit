#!/usr/bin/env bash

source $(sourcedir --base)/test/bootstrap.bash

load_lib bats-support
load_lib bats-assert

arguments=(\
    "-C" \
    "--color" \
    "--module=devkit" \
    "-m" "ms" \
    "--with-spaces" "this is a message" \
    "-f=1" \
    -- \
    "--positional_argument" \
    "will be" \
    ignored \
)

setup() {
    import lib::argument
}
