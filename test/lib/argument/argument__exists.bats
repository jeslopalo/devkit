#!/usr/bin/env bats

load _init

arguments=("-C" "--color" "--module=devkit" "-m" "ms" "--with-spaces" "this is a message" "-f=1")

@test "$(testcase) should check that long flag argument exists" {
    run argument::exists 'color' "${arguments[@]}"

    assert_success
}

@test "$(testcase) should check that long flag argument not exists" {
    run argument::exists 'colors' "${arguments[@]}"

    assert_false
}

@test "$(testcase) should check that short flag argument exists" {
    run argument::exists 'C' "${arguments[@]}"

    assert_success
}

@test "$(testcase) should check that short flag argument not exists" {
    run argument::exists 'c' "${arguments[@]}"

    assert_false
}

@test "$(testcase) should check that long argument exists" {
    run argument::exists 'module' "${arguments[@]}"

    assert_success
}

@test "$(testcase) should check that short argument exists" {
    run argument::exists 'f' "${arguments[@]}"

    assert_success
}
