#!/usr/bin/env bats

load _init

@test "$(testcase) should fail without options" {
    run devkit

    assert_failure
    assert_line -n 0 "Sorry! I need something more to continue :("
    assert_line -n 1 --partial "usage: devkit [-h] [-v | -l | -t | -E] [-e <name>] [-c <dir>]"
}

@test "$(testcase) should fail with bad or incomplete options" {

    for bad_option in "-s" "--s" "-ab" "-c"; do
        run devkit $bad_option

        assert_failure
        assert_line -n 0 --partial "error: invalid option:"
        assert_line -n 1 --partial "usage: devkit [-h] [-v | -l | -t | -E] [-e <name>] [-c <dir>]"
    done
}

@test "$(testcase) should fail when configuration file does not exist" {
    unset_configuration_path

    run devkit -h

    assert_failure
    assert_output --regexp '^error: I can read configuration file \[.*devkit-config.json\] :\($'
}
