#!/usr/bin/env bash

source ../lib/messaging.lib.sh

function notify_user_password_changed() {
    local -r uid="$1"
    local -r email="${2:-jeslopalo.corpme@gmail.com}"
    local -r nickname="${3:-jesus.lopez}"    

    local -r routing_key="user-password-changed.user-notificator"
    local -r payload="{ \\\"userId\\\" : $uid, \\\"email\\\" : \\\"${email}\\\", \\\"nickName\\\" : \\\"${nickname}\\\" }"

    send_message "$routing_key" "$payload"
}

notify_user_password_changed "$@"
printf "\\n"
