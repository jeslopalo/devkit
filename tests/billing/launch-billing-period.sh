#!/usr/bin/env bash

source ../lib/messaging.lib.sh

function launch_billing_period() {
    local -r today=$(date +'%Y-%m-%d')
    local -r dateFrom="${1:-$today}"
    local -r dateTo="${2:-$today}"

    local -r routing_key="billing-period.billing"
    local -r payload="{ \\\"startDate\\\" : \\\"$dateFrom\\\", \\\"endDate\\\" : \\\"$dateTo\\\" }"

    printf "\\nEnviando solicitud de calculo de ciclo de facturación [%s]\\n" "$payload"
    send_message "$routing_key" "$payload"
}

launch_billing_period "$@"
printf "\\n"
