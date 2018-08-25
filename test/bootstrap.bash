#!/usr/bin/env bash

source $(dirname $(sourcedir "$BASH_SOURCE"))/.rc

export DEVKIT_TEST_ROOT="$DEVKIT_HOME/test"

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

# Load a library from the `${BATS_TEST_DIRNAME}/test_helper' directory.
#
# Globals:
#   none
# Arguments:
#   $1 - name of library to load
# Returns:
#   0 - on success
#   1 - otherwise
load_lib() {
    local name="$1"
    load "$DEVKIT_TEST_ROOT/test_helper/${name}/load.bash"
}
