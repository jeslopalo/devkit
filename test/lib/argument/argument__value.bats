#!/usr/bin/env bats

load _init

@test "$(testcase) should get long argument value" {
    run argument::value 'module' -- "${arguments[@]}"

    assert_success
    assert_output "devkit"
}

@test "$(testcase) should get short argument value" {
    run argument::value 'm' -- "${arguments[@]}"

    assert_success
    assert_output "ms"
}

@test "$(testcase) should get argument value with spaces" {
    run argument::value 'with-spaces' -- "${arguments[@]}"

    assert_success
    assert_output "this is a message"
}

@test "$(testcase) should get argument value (--arg=value)" {
    run argument::value 'f' -- "${arguments[@]}"

    assert_success
    assert_output "1"
}

@test "$(testcase) should ignore positional arguments (everything after '--')" {
    run argument::value 'positional_argument' -- "${arguments[@]}"

    assert_failure
    assert_output ""
}
