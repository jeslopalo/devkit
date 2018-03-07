#!/usr/bin/env bash

wid="$1"
eid="$2"

source ./environment.lib.sh
rabbit_host="${RABBIT_HOST}"

exchange_name="amq.default"
exchange_url="${rabbit_host}/api/exchanges/%2F/$exchange_name/publish"
routing_key="payment-wallet-entry-cancelled.wallet"

curl -i -u rabbitdev:rabbitdev \
    -XPOST -d '{"vhost":"/","name":"'$exchange_name'","properties":{"delivery_mode":1,"headers":{"contentType":"application/json"}},"routing_key":"'$routing_key'","delivery_mode":"1","payload":"{ \"walletId\": \"'$wid'\", \"entryId\": \"'$eid'\" }","headers":{"contentType":"application/json"},"props":{"content-type":"application/json"},"payload_encoding":"string"}' \
    $exchange_url

printf "\\n"
