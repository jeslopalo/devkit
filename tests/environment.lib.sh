#!/usr/bin/env bash

## sólo editar éstas variables
wallet_local=false
rabbit_local=false
## @@@@@@@@@@@@@@@@@@@@@@@@@@@

wallet_server_port=8081

function wallet_endpoint(){
    local -r wallet_local="${1:-true}"

    wallet_localhost="http://localhost:${wallet_server_port:-8080}"
    wallet_openshift="http://wallet-desarrollo.osrouter.dev.corpme.int:80"

    if [ "$wallet_local" = "true" ]; then
        export WALLET_HOST_URL="${wallet_localhost}"
    else
        export WALLET_HOST_URL="${wallet_openshift}"
    fi
}

function rabbit_host() {
    local -r rabbit_local="${1:-true}"

    rabbit_local_host="http://localhost:15672"
    rabbit_remote_host="http://rabbitmq.dev.corpme.int:15672"

    if [ "$rabbit_local" = "true" ]; then
        export RABBIT_HOST="${rabbit_local_host}"
    else
        export RABBIT_HOST="${rabbit_remote_host}"
    fi
}

wallet_endpoint $wallet_local
rabbit_host $rabbit_local

if [ "$1" != "raw" ]; then
    printf "\e[2mdebug: wallet_host_url=%s, rabbit_host=%s\e[22m\\n" "$WALLET_HOST_URL" "$RABBIT_HOST"
fi
