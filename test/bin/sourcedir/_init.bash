#!/usr/bin/env bash

source $(sourcedir --base)/test/bootstrap.bash

load_lib bats-support
load_lib bats-assert

setup() {
    fixtures

    ln -s "$FIXTURE_ROOT/plain.txt" "$FIXTURE_ROOT/symlink_to_plain.txt"
    ln -s "$FIXTURE_ROOT/directory/depth/depth_file.txt" "$FIXTURE_ROOT/directory/depth/symlink_to_depth_file.txt"
}

teardown() {
    rm -f "$FIXTURE_ROOT/symlink_to_plain.txt"
    rm -f "$FIXTURE_ROOT/directory/depth/symlink_to_depth_file.txt"
}
