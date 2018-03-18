#!/usr/bin/env bash

source ./environment.lib.sh
wallet_host_url="${WALLET_HOST_URL}"

bold=$(tput bold)
normal=$(tput sgr0)

printf "Trying to delete wallet %s...\\n$bold" "$1"
curl -XDELETE "${wallet_host_url}/wallets/$1" -d ''
printf "$normal\\n\\n"
