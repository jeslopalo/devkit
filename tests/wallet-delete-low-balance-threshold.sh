#!/bin/bash


bold=$(tput bold)
normal=$(tput sgr0)

source ./environment.lib.sh
wallet_host_url="${WALLET_HOST_URL}"

wallet_id=$1

document='{ "lowBalanceThreshold" : -1, "lowBalanceNotification" : false }'

printf "Removing low balance threshold...\\n$bold"
curl -H "Content-Type: application/json" -XPATCH "${wallet_host_url}/wallets/$wallet_id/settings" -d "$document"
printf "$normal\\n\\n"
