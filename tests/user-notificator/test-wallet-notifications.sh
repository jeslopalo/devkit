#!/usr/bin/env bash

if [ "$#" != 1 ]; then
    printf "usage: test-wallet-notifications.sh <wallet_id>\\n"
    exit 1
fi

clientId=${2:-136}
paymentDetailId=${3:-15}

printf "\\n\\nEnviando notificación de recarga realizada...\\n"
./notify-income-consolidated.sh $1 1 10000 '{ "clientId": '$clientId', "paymentDetailId": '$paymentDetailId'}'
printf "\\n\\nEnviando notificación de reembolso realizado...\\n"
./notify-withdrawal-consolidated.sh $1 1 1000 '{ "clientId": '$clientId', "paymentDetailId": '$paymentDetailId'}'
printf "\\n\\nEnviando notificación de aviso por saldo inferior a un umbral...\\n"
./notify-low-balance-threshold-reached.sh $1 4900 5000
printf "\\n\\nEnviando notificación de aviso por saldo negativo...\\n"
./notify-negative-balance-reached.sh $1 -13
