#!/usr/bin/env bash

check_for_dependencies() {
    hash jq 2>/dev/null || { echo >&2 "error: I require jq but it's not installed.  Aborting."; exit 1; }
}
