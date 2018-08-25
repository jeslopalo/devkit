#!/usr/bin/env bats

load _init

## resolution behavior

@test "$(testcase) should return '' with unknown property" {
    run config::property --name="unknown_property"

    [[ $output == '' ]]
}

@test "$(testcase) should return '' with unknown property (when overriding)" {
    run config::property --name="unknown_property" --identifier="module"

    [[ $output == '' ]]
}

@test "$(testcase) should return the value of known property" {
    run config::property --name="known_property"

    [[ $output == 'known' ]]
}

@test "$(testcase) should return empty value with a module without properties node" {
    run config::property --name="a_property" --identifier="no_properties_module"

    [[ $output == '' ]]
}

@test "$(testcase) should return empty value with a module with empty properties node" {
    run config::property --name="a_property" --identifier="empty_properties_module"

    [[ $output == '' ]]
}

@test "$(testcase) should return the overriden value of known property (when overriding)" {
    run config::property --name="known_property" --identifier="module"

    [[ $output == 'overriden kwown property' ]]
}

## interpolation behavior

@test "$(testcase) should not replace existant vars with property values (without flag)" {
    run config::property --name="interpolable_property"

    [[ "$output" == '{{known_property}}'* ]]
}

@test "$(testcase) should replace existant vars with property values (with flag)" {
    run config::property --name="interpolable_property" --interpolate

    [[ "$output" == 'known value' ]]
}
