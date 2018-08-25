#!/usr/bin/env bats

load _init

@test "$(testcase) should return empty string with empty text" {

    run config::interpolate

    assert_output ""
}

@test "$(testcase) should replace existant vars with property values" {
    template='{{plain_property}} will not contains vars!'

    run config::interpolate --text="$template" --identifier="module"

    refute_output "$template"
    assert_output 'value will not contains vars!'
}

@test "$(testcase) should replace all existant vars with property values" {
    template='{{plain_property}}, {{known_property}}, {{plain_property}} will not contains vars!'

    run config::interpolate --text="$template" --identifier="module"

    refute_output "$template"
    assert_output 'value, overriden known property, value will not contains vars!'
}

@test "$(testcase) should interpolate interpolable property values" {
    template='{{interpolable_property}} should be equal to "value interpolated!"'

    run config::interpolate --text="$template" --identifier="module"

    refute_output "$template"
    assert_output 'value interpolated! should be equal to "value interpolated!"'
}

@test "$(testcase) should interpolate until there are no more interpolable property values" {
    template='{{super_interpolable_property}} should be equal to "value interpolated!"'

    run config::interpolate --text="$template" --identifier="module"

    refute_output "$template"
    assert_output 'value interpolated! should be equal to "value interpolated!"'
}
