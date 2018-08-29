#!/usr/bin/env bash

import lib::configuration

maintenance::assert_file_exists() {
    config::assert_file_exists
}

maintenance::find_workspace() {
    local -r workspace=$(config::property --name="workspace" --interpolate)

    echo "${workspace/#\~/$HOME}"
}

maintenance::find_idea_cache_dir() {
    local -r cache_dir=$(config::property --name="idea-cache-dir" --interpolate)

    echo "${cache_dir/#\~/$HOME}"
}
