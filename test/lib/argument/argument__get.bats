#!/usr/bin/env bats

load _init

arguments=("-C" "--color" "--module=devkit" "-m" "ms" "--with-spaces" "this is a message" "-f=1")

@test "$(testcase) should get argument (as is)" {
    run argument::get 'module' "${arguments[@]}"
    assert_equals "--module=devkit"

    run argument::get 'f' "${arguments[@]}"
    assert_equals "-f=1"

    run argument::get 'C' "${arguments[@]}"
    assert_equals "-C"

    run argument::get 'color' "${arguments[@]}"
    assert_equals "--color"
}

@test "$(testcase) should get only argument name (as is) with space separated arguments" {
    run argument::get 'm' "${arguments[@]}"
    assert_equals "-m"
}
