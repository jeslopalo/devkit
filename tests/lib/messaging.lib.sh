#!/usr/bin/env bash

source ../environment.lib.sh

function send_message() {
    local -r routing_key="$1"
    local -r payload="$2"
    local -r exchange_name="amq.default"
    local -r exchange_url="${RABBIT_HOST}/api/exchanges/%2F/$exchange_name/publish"
    local -r headers="${3:-\{\"contentType\": \"application/json\"\}}"

    echo $headers
    echo $payload
    echo '{"vhost":"/","name":"'$exchange_name'","properties":{"delivery_mode":1,"headers":'"$headers"'},"routing_key":"'$routing_key'","delivery_mode":"1","payload":"'"$payload"'","headers":'"$headers"',"props":{"content-type":"application/json"},"payload_encoding":"string"}'

    curl -i -u rabbitdev:rabbitdev \
    -XPOST -d '{"vhost":"/","name":"'$exchange_name'","properties":{"delivery_mode":1,"headers":'"$headers"'},"routing_key":"'$routing_key'","delivery_mode":"1","payload":"'"$payload"'","headers": '"$headers"',"props":{"content-type":"application/json"},"payload_encoding":"string"}' \
    $exchange_url
}
