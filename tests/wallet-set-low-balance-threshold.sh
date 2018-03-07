#!/bin/bash


bold=$(tput bold)
normal=$(tput sgr0)

source ./environment.lib.sh
wallet_host_url="${WALLET_HOST_URL}"

wallet_id=$1
threshold=${2:-100}
activation=${3:-true}

document='{ "lowBalanceThreshold" : '$threshold', "lowBalanceNotification" : '$activation' }'
printf "Setting low balance threshold (threshold: %s, activation: %s)...\\n$bold" "$threshold" "$activation"
curl -H "Content-Type: application/json" -XPATCH "${wallet_host_url}/wallets/$wallet_id/settings" -d "$document"
printf "$normal\\n\\n"
