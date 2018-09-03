#!/usr/bin/env bats

load _init

@test "$(testcase) should get argument (as is)" {
    run argument::get 'module' -- "${arguments[@]}"
    assert_success
    assert_output "--module=devkit"

    run argument::get 'f' -- "${arguments[@]}"
    assert_success
    assert_output "-f=1"

    run argument::get 'C' -- "${arguments[@]}"
    assert_success
    assert_output "-C"

    run argument::get 'color' -- "${arguments[@]}"
    assert_success
    assert_output "--color"
}

@test "$(testcase) should get only argument name (as is) with space separated arguments" {
    run argument::get 'm' -- "${arguments[@]}"

    assert_success
    assert_output "-m"
}

@test "$(testcase) should ignore positional arguments (everything after '--')" {
    run argument::get 'positional_argument' -- "${arguments[@]}"

    assert_failure
    assert_output ""
}
