#!/usr/bin/env bats

load _init

@test "$(testcase) should get zero vars without vars" {
    run template::get_vars --text="text without vars"

    assert_output ""
}

@test "$(testcase) should get var name from text" {
    run template::get_vars --text="text with {{var}}"

    assert_output "var"
}

@test "$(testcase) should get multiple var names from text" {
    run template::get_vars --text="text{{ with {{var1}}{{var2}}\$var3 {{other}}{{var1}}\${var3}{{var4}}{{}} }}{{ }}"

    assert_output "other var1 var2 var4"
}
