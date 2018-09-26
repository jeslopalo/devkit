#!/usr/bin/env bats

load _init

@test "$(testcase) the help should success" {
    run maintenance --help
    assert_success

    run maintenance -h
    assert_success
}

@test "$(testcase) the help should contains USAGE, OPTIONS, CLEAN JOBS, EXAMPLES" {

    for help_option in "-h" "--help"; do
        run maintenance $help_option

        assert_line -n 0 -p "USAGE"
        assert_line -n 2 -p "OPTIONS"
        assert_line -n 5 -p "CLEAN JOBS"
        assert_line -n 9 -p "EXAMPLES"
    done
}
