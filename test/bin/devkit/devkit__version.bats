#!/usr/bin/env bats

load _init

@test "$(testcase) should print out version" {
    run devkit -v

    assert_success
    assert_line -n 17 "/* (2018) Devkit v$DEVKIT_VERSION */"
    assert_line -n 18 "// config version : v$DEVKIT_VERSION"
    assert_line -n 19 "// config path    : $DEVKIT_CONFIG_PATH"
    assert_line -n 20 "// author         : @jeslopalo"
}
