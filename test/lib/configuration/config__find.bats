#!/usr/bin/env bats

load _init

## prettify behavior

@test "$(testcase) should not prettify the result" {
    run config::find --filter=".services"

    [[ "$output" == '{"workspace":"{{known_property}}/path","data":[{"name":"service_one","type":"spring-boot"},{"name":"service_two","type":"docker"}]}' ]]
}

@test "$(testcase) should prettify the result" {
    run config::find --filter=".services" --prettify

    [[ "${lines[0]}" == '{' ]]
    [[ "${lines[1]}" == '  "workspace": "{{known_property}}/path",' ]]
    [[ "${lines[2]}" == '  "data": [' ]]
    [[ "${lines[3]}" == '  {' ]]
    [[ "${lines[4]}" == '      "name": "service_one",' ]]
    [[ "${lines[5]}" == '      "type": "spring-boot"' ]]
    [[ "${lines[6]}" == '  },' ]]
    [[ "${lines[7]}" == '  {' ]]
    [[ "${lines[8]}" == '      "name": "service_two",' ]]
    [[ "${lines[9]}" == '      "type": "docker"' ]]
    [[ "${lines[10]}" == '  }' ]]
    [[ "${lines[11]}" == '  ]' ]]
    [[ "${lines[12]}" == '}' ]]
    [ "$status" -eq 0 ]
}
