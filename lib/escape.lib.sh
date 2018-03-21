#!/usr/bin/env bash

escape_json() {
    local line="${1:-}"
    line=${line//\\/\\\\}
    line=${line//\"/\\\"}
    echo $line
}
