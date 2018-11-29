#!/usr/bin/env bash

import lib::configuration

eureka_config_identifier="eureka"

eureka::assert_file_exists() {
    config::assert_file_exists "$eureka_config_identifier"
}

eureka::find_version() {
    config::find --filter=".version" --identifier="$eureka_config_identifier"
}

eureka::environment() {
    config::property --name="environment" --identifier="$eureka_config_identifier"
}

eureka::instance_hostname_pattern() {
    config::find --filter='.eureka."instance-hostname-pattern"' --interpolate --identifier="$eureka_config_identifier"
}

eureka::register_url_pattern() {
    config::find --filter='.eureka."register-url-pattern"' --interpolate --identifier="$eureka_config_identifier"
}

eureka::unregister_url_pattern() {
    config::find --filter='.eureka."unregister-url-pattern"' --interpolate --identifier="$eureka_config_identifier"
}
