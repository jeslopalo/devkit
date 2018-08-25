#!/usr/bin/env bash

import lib::configuration
import lib::log

devkit_config_identifier="devkit"

devkit::assert_file_exists() {
    config::assert_file_exists "$devkit_config_identifier"
}

devkit::find_version() {
    config::find --filter=".version" --identifier="$devkit_config_identifier"
}

devkit::find_configurable_modules() {
    config::find --filter=".config_file_ids[]?" --identifier="$devkit_config_identifier"
}

devkit::edit_file() {
    local -r name="${1:-}"

    local -a modules=$(devkit::find_configurable_modules)

    for module in $modules; do
        if [[ $module = $name ]]; then
            config::edit_file "$name"
            return $?
        fi
    done

    log::error "module '$name' not found! [availables: $(devkit::find_configurable_modules)]"
    return 1
}
