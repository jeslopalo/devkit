#!/usr/bin/env bash

source ../lib/messaging.lib.sh

function notify_user_nickname_changed() {
    local -r uid="$1"
    local -r email="${2:-jeslopalo.corpme@gmail.com}"
    local -r old="${3:-prince}"
    local -r new="${4:-theArtist}"

    local -r routing_key="user-nickname-changed.user-notificator"
    local -r payload="{ \\\"userId\\\" : $uid, \\\"email\\\" : \\\"${email}\\\", \\\"newNickName\\\" : \\\"${new}\\\", \\\"oldNickName\\\" : \\\"${old}\\\" }"

    send_message "$routing_key" "$payload"
}

notify_user_nickname_changed "$@"
printf "\\n"
