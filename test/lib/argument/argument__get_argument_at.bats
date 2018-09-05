#!/usr/bin/env bats

load _init

@test "$(testcase) should get no values without positional arguments (no '--')" {
    run argument::get_argument_at -p 1 -- -a value1 --barg value2

    assert_failure
    assert_output ""
}

@test "$(testcase) should fail without option" {
    run argument::get_argument_at -- -a value1 --barg value2 -- positional argument

    assert_failure
    assert_output ""
}

@test "$(testcase) should get a positional argument after '--'" {
    run argument::get_argument_at -p 1 -- -a value1 --barg value2 -- positional argument

    assert_success
    assert_output "positional"


    run argument::get_argument_at -p 13 -- -a value1 --barg value2 -- a b c d e f g h i j k l m n ñ

    assert_success
    assert_output "m"
}

@test "$(testcase) should get a positional argument with spaces after '--'" {
    run argument::get_argument_at -p 1 -- -a value1 --barg value2 -- "positional argument" with\ spaces

    assert_success
    assert_output "positional argument"


    run argument::get_argument_at -p 2 -- -a value1 --barg value2 -- "positional argument" with\ spaces

    assert_success
    assert_output "with spaces"
}

@test "$(testcase) should not get any positional argument after '--' without enough arguments" {
    run argument::get_argument_at -p 2 -- -a value1 --barg value2 -- positional

    assert_failure
    assert_output ""
}

@test "$(testcase) should get all positional arguments after '--' as string with --join" {
    run argument::get_argument_at --join -- -a value1 -- "positional arguments" "should be" returned with --join

    assert_success
    assert_output "positional arguments should be returned with --join"
}

@test "$(testcase) should get all positional arguments after '--' as array with -p all" {
    declare -a arguments=( --option -- "positional arguments" should be returned "with spaces")

    declare -a output=()
    while IFS='' read -r -d '' element; do
        output+=( "$element" )
    done < <( argument::get_argument_at -p all -- "${arguments[@]}" )

    assert_equal "${output[0]}" "positional arguments"
    assert_equal "${output[1]}" should
    assert_equal "${output[2]}" be
    assert_equal "${output[3]}" returned
    assert_equal "${output[4]}" "with spaces"
}
