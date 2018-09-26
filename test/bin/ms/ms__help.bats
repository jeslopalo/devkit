#!/usr/bin/env bats

load _init

@test "$(testcase) the help should success" {
    run ms --help
    assert_success

    run ms -h
    assert_success
}

@test "$(testcase) the help should contains USAGE, OPTIONS, NAMED QUERIES, EXAMPLES, AVAILABLE SERVICES" {

    for help_option in "-h" "--help"; do
        run ms $help_option

        assert_line -n 0 -p "USAGE"
        assert_line -n 5 -p "OPTIONS"
        assert_line -n 12 -p "NAMED QUERIES"
        assert_line -n 18 -p "EXAMPLES"
        assert_line -n 24 -p "AVAILABLE SERVICES"
    done
}
