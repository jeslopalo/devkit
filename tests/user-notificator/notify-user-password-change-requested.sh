#!/usr/bin/env bash

source ../lib/messaging.lib.sh

function notify_user_password_change_requested() {
    local -r uid="$1"
    local -r email="${2:-jeslopalo.corpme@gmail.com}"
    local -r name="${3:-Jesús}"    
    local -r firstLastname="${4:-López}"    
    local -r secondLastname="${5:-Alonso}"    

    local -r routing_key="user-restart-password-requested.user-notificator"
    local -r payload="{ \\\"userId\\\" : $uid, \\\"email\\\" : \\\"${email}\\\", \\\"name\\\" : \\\"${name}\\\", \\\"primaryLastName\\\" : \\\"${firstLastname}\\\", \\\"secondLastName\\\" : \\\"${secondLastname}\\\" }"

    send_message "$routing_key" "$payload"
}

notify_user_password_change_requested "$@"
printf "\\n"
