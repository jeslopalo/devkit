#!/bin/bash

source ./environment.lib.sh
wallet_host_url="${WALLET_HOST_URL}"

bold=$(tput bold)
normal=$(tput sgr0)

printf "Getting wallet entry [walletId=%s, entryId=%s]...\\n$bold" "$1" "$2"
curl -XGET "${wallet_host_url}/wallets/$1/entries/$2" -d ''
printf "$normal\\n\\n"
