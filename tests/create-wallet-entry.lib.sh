#!/usr/bin/env bash

source ./environment.lib.sh
wallet_host_url="${WALLET_HOST_URL}"

bold=$(tput bold)
normal=$(tput sgr0)

create_entry() {
    local type="$1"
    local wid="$2"
    local amount="$3"
    local params="${4:-{ }}"

    if [ -z "$type" ] || [ -z "$wid" ] || [ -z "$amount" ]; then
        printf "error: no se recibieron los parámetros necesarios\\n"
        printf "parameters: <wallet id> <amount> [<params>]\\n"
        exit 1
    fi

    printf "Creating new %s entry in wallet [wid=%s, amount=%s cents, params=<%s>]...\\n" "$type" "$wid" "$amount" "$params"
    entry="{ \"type\" : \"$type\", \"amount\" : \"$amount\", \"params\" : $params }"
    printf "%s\\n$bold" "$entry"
    curl -XPOST "${wallet_host_url}/wallets/$wid/entries" --silent -H "Content-Type: application/json" -d "$entry"
    printf "$normal\\n\\n"
}

create_entry_raw() {
    local type="$1"
    local wid="$2"
    local amount="$3"
    local params="${4:-{ }}"

    if [ -z "$type" ] || [ -z "$wid" ] || [ -z "$amount" ]; then
        printf "error: no se recibieron los parámetros necesarios\\n"
        printf "parameters: <wallet id> <amount> [<params>]\\n"
        exit 1
    fi

    entry="{ \"type\" : \"$type\", \"amount\" : \"$amount\", \"params\" : $params }"
    curl -XPOST "${wallet_host_url}/wallets/$wid/entries" --silent -H "Content-Type: application/json" -d "$entry"
}

