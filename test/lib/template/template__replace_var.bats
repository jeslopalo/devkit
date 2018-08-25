#!/usr/bin/env bats

load _init

@test "$(testcase) should do nothing without var name (without placeholders)" {
    run template::replace_var --text="text without vars"

    assert_equals "text without vars"
}

@test "$(testcase) should do nothing without var name (with placeholders)" {
    run template::replace_var --text="text with {{vars}}"

    assert_equals "text with {{vars}}"
}

@test "$(testcase) should replace a placeholder with empty string without value (without parameter)" {
    run template::replace_var --text="text with {{var}}" --name="var"

    assert_equals "text with "
}

@test "$(testcase) should replace a placeholder with current var value (without parameter)" {
    var="value"
    run template::replace_var --text="text with {{var}}" --name="var"

    assert_equals "text with value"
}

@test "$(testcase) should replace all placeholders with current var value (without parameter)" {
    var="value"
    run template::replace_var --text="text with {{var}} & {{var}}" --name="var"

    assert_equals "text with value & value"
}

@test "$(testcase) should replace only requested placeholders with current var value (without parameter)" {
    var="value"
    run template::replace_var --text="text with {{untouched}}, {{var}} & {{var}}" --name="var"

    assert_equals "text with {{untouched}}, value & value"
}

@test "$(testcase) should replace a placeholder with value (with parameter)" {
    run template::replace_var --text="text with {{var}}" --name="var" --value="replacement"

    assert_equals "text with replacement"
}

@test "$(testcase) should replace all placeholders with value (with parameter)" {
    run template::replace_var --text="text with {{var}} & {{var}}" --name="var" --value="replacement"

    assert_equals "text with replacement & replacement"
}

@test "$(testcase) should replace only requested placeholders with value (with parameter)" {
    run template::replace_var --text="text with {{untouched}}, {{var}} & {{var}}" --name="var" --value="replacement"

    assert_equals "text with {{untouched}}, replacement & replacement"
}

@test "$(testcase) should replace placeholders with starting and tailing spaces" {
    run template::replace_var --text="{{var}}/{{ var }}/{{var }}/{{  var}}/{{  var  }}" --name="var" --value="replacement"

    assert_equals "replacement/replacement/replacement/replacement/replacement"
}
