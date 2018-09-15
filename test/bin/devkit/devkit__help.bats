#!/usr/bin/env bash

load _init

@test "$(testcase) the help should success" {
    run devkit --help
    assert_success

    run devkit -h
    assert_success
}

@test "$(testcase) the help should contains USAGE, OPTIONS" {

    for help_option in "-h" "--help"; do
        run devkit $help_option

        assert_line -n 0 -p "USAGE"
        assert_line -n 2 -p "OPTIONS"
    done
}
