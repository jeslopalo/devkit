#!/usr/bin/env bash

import lib::configuration

# set config file if it's not set before
is_var_not_defined "EUREKA_CONFIG_FILE" && export EUREKA_CONFIG_FILE="${DEVKIT_CONFIG_PATH}/eureka-config.json"

eureka::find_version() {
    find ".version" "$EUREKA_CONFIG_FILE"
}

eureka::assert_configuration_exists() {
    assert_configuration_file_exists "$EUREKA_CONFIG_FILE"
}

eureka::find_register_url_pattern() {
    find '.eureka."register-url"' "$EUREKA_CONFIG_FILE"
}

eureka::find_unregister_url_pattern() {
    find '.eureka."unregister-url"' "$EUREKA_CONFIG_FILE"
}
