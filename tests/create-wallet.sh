#!/bin/bash


bold=$(tput bold)
normal=$(tput sgr0)

if [ "$1" = "raw" ]; then
    source ./environment.lib.sh "$1"
    wallet_host_url="${WALLET_HOST_URL}"

    curl -H "Content-Type: application/json" --silent -XPOST "${wallet_host_url}/wallets" -d ''
else
    source ./environment.lib.sh
    wallet_host_url="${WALLET_HOST_URL}"

    printf "Creating new wallet...\\n$bold"
    curl -H "Content-Type: application/json" -XPOST "${wallet_host_url}/wallets" -d ''
    printf "$normal\\n\\n"
fi
