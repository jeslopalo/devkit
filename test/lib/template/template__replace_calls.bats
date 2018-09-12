#!/usr/bin/env bats

load _init

@test "$(testcase) should do nothing without command call" {
    run template::replace_calls --text="will print this message!!"
    assert_output "will print this message!!"
}

@test "$(testcase) should replace a single command call" {
    run template::replace_calls --text="will print ((echo this message))!!"
    assert_output "will print this message!!"

    run template::replace_calls --text="((echo this message))"
    assert_output "this message"
}

@test "$(testcase) should replace multiple command calls" {
    run template::replace_calls --text="will print ((echo this)) ((echo message))!!"
    assert_output "will print this message!!"

    run template::replace_calls --text="((echo this)) ((echo message))"
    assert_output "this message"
}

@test "$(testcase) should replace nested command calls" {
    run template::replace_calls --text="((echo not ((echo equilibrated))))"
    assert_output "not equilibrated"
}

@test "$(testcase) should ignore unpaired parentheses" {
    run template::replace_calls --text="((not closed"
    assert_output "((not closed"

    run template::replace_calls --text="not opened))"
    assert_output "not opened))"

    run template::replace_calls --text="(not (equilibrated))"
    assert_output "(not (equilibrated))"
}
