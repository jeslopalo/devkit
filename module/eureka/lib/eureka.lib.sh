#!/usr/bin/env bash

import lib::template
import module::eureka::configuration

EUREKA_REGISTER_DOCUMENT_FILE="$DEVKIT_MODULE/eureka/resources/eureka-register-app.json"

register_service() {
    declare service_name="$1"

    if [ -z "$service_name" ]; then
    	usage
    	exit 1
    fi

    if [ ! -f "$EUREKA_REGISTER_DOCUMENT_FILE" ]; then
        printf "error: %s template not found\\n" "$EUREKA_REGISTER_DOCUMENT_FILE"
        exit 1
    fi

    declare document=$(<"$EUREKA_REGISTER_DOCUMENT_FILE")

    document=$(template::replace_var --text="$document" --name="service_name")
    url=$(template::replace_var --text="$(eureka::find_register_url_pattern)" --name="service_name")

    printf "Registering service in local eureka: %s\\n" "$service_name"
    curl -g --request POST \
        --url "$url" \
        --header 'cache-control: no-cache' \
        --header 'content-type: application/json' \
        --data "$document"
}

unregister_service() {
    declare service_name="$1"

    if [ -z "$service_name" ]; then
    	usage
    	exit 1
    fi

    url=$(template::replace_var --text="$(eureka::find_unregister_url_pattern)" --name="service_name")

    printf "Unregistering service in local eureka: %s\\n" "$service_name"
    curl -g --request DELETE \
        --url "$url" \
        --header 'cache-control: no-cache' \
        --header 'content-type: application/json'
}

register_services() {
    local -r services=("$@")

    if [ "${#services[@]}" = 0 ]; then
        printf "Sorry! I need a list of service names to continue :(\\n\\n" 1>&2
        usage
        exit 1
    fi

    for service in "${services[@]}"; do
        register_service "$service"
    done
}

unregister_services() {
    local -r services=("$@")

    if [ "${#services[@]}" = 0 ]; then
        printf "Sorry! I need a list of service names to continue :(\\n\\n" 1>&2
        usage
        exit 1
    fi

    for service in "${services[@]}"; do
        unregister_service "$service"
    done
}
