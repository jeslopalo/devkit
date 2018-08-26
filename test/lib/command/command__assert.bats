#!/usr/bin/env bats

load _init

@test "$(testcase) should success without command" {
    run command::assert

    assert_success
}

@test "$(testcase) should success with existing command" {
    run command::assert "ls"

    assert_success
}

@test "$(testcase) should fail with unknown command" {
    run command::assert "unknown_command"

    assert_failure
    assert_output "error: I require 'unknown_command' but it's not installed.  Aborting."
}

@test "$(testcase) should success when all commands exists" {
    run command::assert "ls" "cp" "cd"

    assert_success
}

@test "$(testcase) should fail when commands do not exists (fail fast at first unknown command)" {
    run command::assert "unknown_command1" "unknown_command2" "unknown_command3"

    assert_failure
    assert_output "error: I require 'unknown_command1' but it's not installed.  Aborting."
}

@test "$(testcase) should fail fast at first unknown command" {
    run command::assert "ls" "cp" "unknown_command1" "unknown_command2" "cd"

    assert_failure
    assert_output "error: I require 'unknown_command1' but it's not installed.  Aborting."
}
