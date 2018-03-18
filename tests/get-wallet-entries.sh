#!/usr/bin/env bash

source ./environment.lib.sh
wallet_host_url="${WALLET_HOST_URL}"

bold=$(tput bold)
normal=$(tput sgr0)

filters="${4}"

printf "Getting wallet entries [walletId=%s, page=%s, size=%s, filters(&%s)]...\\n$bold" \
"$1" "$2" "$3" "$filters"
curl -XGET "${wallet_host_url}/wallets/$1/entries?page=$2&size=$3&$filters" -d ''
printf "$normal\\n\\n"
