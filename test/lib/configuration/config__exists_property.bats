#!/usr/bin/env bats

load _init

@test "$(testcase) should fail with unknown property" {
    run config::exists_property --name="unknown_property"

    assert_failure
}

@test "$(testcase) should fail with unknown property (when overriding)" {
    run config::exists_property --name="unknown_property" --identifier="module"

    assert_failure
}

@test "$(testcase) should success with known property" {
    run config::exists_property --name="known_property"

    assert_success
}

@test "$(testcase) should success with known property (when overriding)" {
    run config::exists_property --name="known_property" --identifier="module"

    assert_success
}
