#!/usr/bin/env bash

check_for_dependencies() {
    hash curl 2>/dev/null || { echo >&2 "error: I require curl but it's not installed.  Aborting."; exit 1; }
    hash jq 2>/dev/null || { echo >&2 "error: I require jq but it's not installed.  Aborting."; exit 1; }

    hash eureka 2>/dev/null || { echo >&2 "error: I require eureka but it's not installed.  Aborting."; exit 1; }
}
