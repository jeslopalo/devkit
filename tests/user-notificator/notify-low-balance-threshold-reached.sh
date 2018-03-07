#!/usr/bin/env bash

source ../lib/messaging.lib.sh

function notify_low_balance_reached() {
    local -r wid="$1"
    local -r balance="${2:-4500}"
    local -r threshold="${3:-5000}"

    local -r routing_key="wallet-balance-threshold-reached.user-notificator"
    local -r payload="{ \\\"eventType\\\" : \\\"LOW_BALANCE_THRESHOLD_REACHED\\\", \\\"walletId\\\"  : $wid, \\\"timestamp\\\" : \\\"2017-10-02T07:35:14.445Z\\\", \\\"balance\\\"   : $balance, \\\"balanceThreshold\\\"  : $threshold }"

    send_message "$routing_key" "$payload"
}

notify_low_balance_reached "$@"
printf "\\n"
