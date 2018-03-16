#!/usr/bin/env bash

register_service() {
    declare service_name="$1"

    if [ -z "$service_name" ]; then
    	usage
    	exit 1
    fi

    printf "Registering service in local eureka: %s\\n" "$service_name"

    curl -g --request POST \
        --url "http://localhost:8761/eureka/apps/${service_name}" \
        --header 'cache-control: no-cache' \
        --header 'content-type: application/json' \
        --data '{
            "instance": {
              "instanceId" : "PARADTRA04.corpme.es:'${service_name}'",
              "app": "'${service_name}'",
              "hostName": "'${service_name}'-desarrollo.osrouter.dev.corpme.int",
              "ipAddr": "http://'${service_name}'-desarrollo.osrouter.dev.corpme.int",
              "homePageUrl": "http://'${service_name}'-desarrollo.osrouter.dev.corpme.int",
              "statusPageUrl":"http://'${service_name}'-desarrollo.osrouter.dev.corpme.int/info",
              "healthCheckUrl":"http://'${service_name}'-desarrollo.osrouter.dev.corpme.int/health",
              "port": {
                "$":80,
                "@enabled": false
              },
              "leaseInfo": {
                "renewalIntervalInSecs":10000,
                "durationInSecs":10000
              },
              "vipAddress": "'${service_name}'",
              "dataCenterInfo": {
                "@class":"com.netflix.appinfo.InstanceInfo$DefaultDataCenterInfo",
                "name": "MyOwn"
              },
              "status": "UP"
            }
          }'
}

unregister_service() {
    declare service_name="$1"

    if [ -z "$service_name" ]; then
    	usage
    	exit 1
    fi

    printf "Unregistering service in local eureka: %s\\n" "$service_name"
    curl -g --request DELETE \
        --url "http://localhost:8761/eureka/apps/${service_name}/PARADTRA04.corpme.es:${service_name}" \
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
