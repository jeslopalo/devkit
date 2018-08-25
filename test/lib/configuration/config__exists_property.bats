#!/usr/bin/env bats

load _init

@test "$(testcase) should return 1 with unknown property" {
    run config::exists_property --name="unknown_property"

    [ "$status" -eq 1 ]
}

@test "$(testcase) should return 1 with unknown property (when overriding)" {
    run config::exists_property --name="unknown_property" --identifier="module"

    [ "$status" -eq 1 ]
}

@test "$(testcase) should return 0 with known property" {
    run config::exists_property --name="known_property"

    [ "$status" -eq 0 ]
}

@test "$(testcase) should return 0 with known property (when overriding)" {
    run config::exists_property --name="known_property" --identifier="module"

    [ "$status" -eq 0 ]
}
