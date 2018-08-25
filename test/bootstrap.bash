#!/usr/bin/env bash

source $(dirname $(sourcedir "$BASH_SOURCE"))/.rc

assert_success() {
    [[ $status -eq 0 ]]
}

assert_failure() {
    [[ $status -eq $1 ]]
}

assert_true() {
    [[ $status -eq 0 ]]
}

assert_false() {
    [[ $status -eq 1 ]]
}

assert_equals() {
    [[ $output == $1 ]]
}

fixtures() {
    local -r name="${1:-}"

    if [[ -z $name ]]; then
        FIXTURE_ROOT="$BATS_TEST_DIRNAME/fixtures"
    else
        FIXTURE_ROOT="$BATS_TEST_DIRNAME/fixtures/$name"
    fi

    RELATIVE_FIXTURE_ROOT="${FIXTURE_ROOT#$BATS_CWD/}"
}

trace_output() {
    printf "# status: %s\\n" "$status" >&3
    printf "# output: %s\\n" "$output" >&3
    if [[ ${#lines[@]} -gt 0 ]]; then
        printf "# lines:\\n" >&3
        printf "# |%s\\n" "${lines[@]}" >&3
    fi
}

testcase() {
    local testcase=$(basename "$BATS_TEST_FILENAME")
    testcase=${testcase//.bats/}
    echo "[ ${testcase//__/::} ]"
}
