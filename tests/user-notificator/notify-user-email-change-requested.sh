#!/usr/bin/env bash

source ../lib/messaging.lib.sh

function notify_user_mail_change_requested() {
    local -r uid="$1"
    local -r old="${2:-jeslopalo.corpme+old@gmail.com}"
    local -r new="${3:-jeslopalo.corpme+new@gmail.com}"

    local -r routing_key="user-email-change-requested.user-notificator"
    local -r payload="{ \\\"userId\\\" : $uid, \\\"oldEmail\\\" : \\\"${old}\\\", \\\"newEmail\\\" : \\\"${new}\\\" }"

    send_message "$routing_key" "$payload"
}

notify_user_mail_change_requested "$@"
printf "\\n"
