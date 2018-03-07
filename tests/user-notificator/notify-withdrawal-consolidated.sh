#!/usr/bin/env bash

source ../lib/messaging.lib.sh

function notify_consolidated_withdrawal() {
    local -r wid="$1"
    local -r eid="${2:-1}"
    local -r amount="${3:-2000}"
    local -r params="${4:-{\\\"clientId\\\": 136, \\\"paymentDetailId\\\": 15}}"

    local -r routing_key="wallet-entry-consolidated.user-notificator"
    local -r payload="{ \\\"eventType\\\" : \\\"CONSOLIDATED\\\", \\\"walletId\\\"  : $wid, \\\"entryId\\\" : $eid, \\\"entryType\\\" : \\\"WITHDRAWAL\\\",\
     \\\"amount\\\" : $amount, \\\"timestamp\\\" : \\\"2017-10-02T07:35:14.445Z\\\", \\\"params\\\" : $params }"

    send_message "$routing_key" "$payload"
}

notify_consolidated_withdrawal "$@"
printf "\\n"
