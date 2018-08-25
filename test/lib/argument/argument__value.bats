#!/usr/bin/env bats

load _init

arguments=("-C" "--color" "--module=devkit" "-m" "ms" "--with-spaces" "this is a message" "-f=1")

@test "$(testcase) should get long argument value" {
    run argument::value 'module' "${arguments[@]}"

    assert_equals "devkit"
}

@test "$(testcase) should get short argument value" {
    run argument::value 'm' "${arguments[@]}"

    assert_equals "ms"
}

@test "$(testcase) should get argument value with spaces" {
    run argument::value 'with-spaces' "${arguments[@]}"

    assert_equals "this is a message"
}

@test "$(testcase) should get argument value (--arg=value)" {
    run argument::value 'f' "${arguments[@]}"

    assert_equals "1"
}
