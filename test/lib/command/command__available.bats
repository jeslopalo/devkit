#!/usr/bin/env bats

load _init

@test "$(testcase) should fail without command" {
    run command::available

    assert_failure
}

@test "$(testcase) should success with existing command" {
    run command::available "ls"

    assert_success
}

@test "$(testcase) should fail with unknown command" {
    run command::available "unknown_command"

    assert_failure
}
