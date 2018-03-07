#!/usr/bin/env bash

if [ "$#" != 1 ]; then
    printf "usage: test-user-modification-notifications.sh <user_id>\\n"
    exit 1
fi

printf "\\n\\nEnviando notificaciónes de cambio de email...\\n"
./notify-user-email-change-requested.sh $1

printf "\\n\\nEnviando notificaciónes de cambio de nickname...\\n"
./notify-user-nickname-changed.sh $1

printf "\\n\\nEnviando notificaciónes de recuperación de password...\\n"
./notify-user-password-change-requested.sh $1

printf "\\n\\nEnviando notificaciónes de cambio de password...\\n"
./notify-user-password-changed.sh $1
