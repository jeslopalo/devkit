#!/usr/bin/env bats

load _init

@test "$(testcase) should print out devkit environment variables" {
    run devkit -E

    assert_success
    for line in $(seq 1 12); do
        assert_line -n $line --partial "DEVKIT_"
    done
}
