#!/usr/bin/env bats

load _init

@test "$(testcase) should get all without filter" {
    run config::find

    query_config "." | assert_output
}

@test "$(testcase) should find in base configuration without identifier" {
    run config::find --filter=".properties.known_property"

    assert_output "known"
}

@test "$(testcase) should find in specific configuration with identifier" {
    run config::find --filter=".properties.known_property" --identifier="module"

    assert_output "overriden known property"
}

## interpolation behavior

@test "$(testcase) should not interpolate configuration (as default)" {
    run config::find --filter=".properties.interpolable_property"

    assert_output "{{known_property}} value"
}

@test "$(testcase) should interpolate configuration (with flag)" {
    run config::find --filter=".properties.interpolable_property" --interpolate

    assert_output "known value"
}

@test "$(testcase) should interpolate configuration recursively (with flag)" {
    run config::find --filter=".properties.super_interpolable_property" --identifier="module" --interpolate

    assert_output "recursively value interpolated!"
}

## prettify behavior

@test "$(testcase) should not prettify the result" {
    run config::find --filter=".services"

    assert_success
    query_config ".services" | assert_output
}

@test "$(testcase) should prettify the result" {
    run config::find --filter=".services" --prettify

    assert_success
    query_config_prettified ".services" | assert_output
}
