#!/usr/bin/env bats

load _init

@test "$(testcase) should raise an error with unknown command" {
    run using unknown_command

    assert_failure
    assert_output "error: I require 'unknown_command' but it's not installed.  Aborting."
}

@test "$(testcase) should validate the existance of a command" {
    run using ls

    assert_success
    assert_output
}

@test "$(testcase) should validate the existance of a list of commands (space separated)" {
    run using ls cd

    assert_success
    assert_output
}

@test "$(testcase) should validate the existance of a list of commands (comma separated)" {
    run using ls, cd,cp,"mkdir,rm"

    assert_success
    assert_output
}
