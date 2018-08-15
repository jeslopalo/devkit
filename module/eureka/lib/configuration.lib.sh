#!/usr/bin/env bash

import lib::configuration

eureka_config_identifier="eureka"

eureka::find_version() {
    config::find ".version" "$eureka_config_identifier"
}

eureka::assert_file_exists() {
    config::assert_file_exists "$eureka_config_identifier"
}

# customize configuration file identifier
eureka::find() {
    config::find "$@" "$eureka_config_identifier"
}

eureka::find_register_url_pattern() {
    eureka::find '.eureka."register-url"'
}

eureka::find_unregister_url_pattern() {
    eureka::find '.eureka."unregister-url"'
}
