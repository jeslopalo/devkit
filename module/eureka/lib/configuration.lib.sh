#!/usr/bin/env bash

import lib::configuration

eureka_config_identifier="eureka"

eureka::assert_file_exists() {
    config::assert_file_exists "$eureka_config_identifier"
}

eureka::find_version() {
    config::find --filter=".version" --identifier="$eureka_config_identifier"
}

eureka::find_register_url_pattern() {
    config::find --filter='.eureka."register-url"' --interpolate --identifier="$eureka_config_identifier"
}

eureka::find_unregister_url_pattern() {
    config::find --filter='.eureka."unregister-url"' --interpolate --identifier="$eureka_config_identifier"
}
