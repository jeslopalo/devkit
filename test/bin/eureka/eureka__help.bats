#!/usr/bin/env bats

load _init

@test "$(testcase) the help should success" {
    run eureka --help
    assert_success

    run eureka -h
    assert_success
}

@test "$(testcase) the help should contains USAGE, OPTIONS, EXAMPLES, AVAILABLE SERVICES" {

    for help_option in "-h" "--help"; do
        run eureka $help_option

        assert_line -n 0 -p "USAGE"
        assert_line -n 2 -p "OPTIONS"
        assert_line -n 7 -p "EXAMPLES"
        assert_line -n 14 -p "AVAILABLE SERVICES"
    done
}
