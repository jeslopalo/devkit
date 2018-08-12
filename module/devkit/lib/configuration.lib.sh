#!/usr/bin/env bash

import lib::configuration
import lib::template
import lib::lang
import lib::log

# set config file if it's not set before
is_var_not_defined "DEVKIT_CONFIG_FILE" && export DEVKIT_CONFIG_FILE="${DEVKIT_CONFIG_PATH}/devkit-config.json"

devkit::assert_configuration_file_exists() {
    assert_configuration_file_exists "$DEVKIT_CONFIG_FILE"
}

devkit::find_version() {
    find ".version" "$DEVKIT_CONFIG_FILE"
}

devkit::find_configurable_modules() {
    find ".config_file_ids[]?" "$DEVKIT_CONFIG_FILE"
}

devkit::edit_config_file() {
    local -r name="${1:-}"

    local -a modules=$(devkit::find_configurable_modules)

    for module in $modules; do
        if [[ $module = $name ]]; then
            edit_config_file "$name"
            return
        fi
    done

    log::error "module '$name' not found! [availables: $(devkit::find_configurable_modules)]"
    return 1
}
