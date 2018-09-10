#!/usr/bin/env bats

load _init

@test "$(testcase) should check that long flag argument exists" {
    run argument::exists 'color' -- "${arguments[@]}"

    assert_success
}

@test "$(testcase) should check that long flag argument not exists" {
    run argument::exists 'colors' -- "${arguments[@]}"

    assert_failure
}

@test "$(testcase) should check that short flag argument exists" {
    run argument::exists 'C' -- "${arguments[@]}"

    assert_success
}

@test "$(testcase) should check that short flag argument not exists" {
    run argument::exists 'c' -- "${arguments[@]}"

    assert_failure
}

@test "$(testcase) should check that long argument exists" {
    run argument::exists 'module' -- "${arguments[@]}"

    assert_success
}

@test "$(testcase) should check that short argument exists" {
    run argument::exists 'f' -- "${arguments[@]}"

    assert_success
}

@test "$(testcase) should ignore positional arguments (everything after '--')" {
    run argument::exists 'positional_argument' -- "${arguments[@]}"

    assert_failure
}
