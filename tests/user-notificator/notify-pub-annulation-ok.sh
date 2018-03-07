#!/usr/bin/env bash

source ../lib/messaging.lib.sh

function notify_annulation_ok() {
    local -r rid="${1:-15804}"
    local -r email="${2:-jeslopalo.corpme@gmail.com}"

    local -r routing_key="annulation-ok.user-notificator"
    local -r payload="{ \\\"resendingType\\\" : \\\"REQUEST\\\", \\\"requestId\\\"  : $rid, \\\"email\\\" : \\\"$email\\\" }"

    send_message "$routing_key" "$payload" "{\"contentType\": \"application/json\", \"x-notify-required\": true}"
}

notify_annulation_ok "$@"
printf "\\n"
