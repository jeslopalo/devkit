#!/usr/bin/env bash

source $TDK_LIB_DIR/configuration.lib.sh
source $TDK_MODULE_DIR/eureka/lib/dependencies.lib.sh

usage() {
    printf "usage: eureka [-h ][-r <services> [-e <services>]][-u <services>]\\n\\n" 1>&2
    printf "  -h\\t\\t\\tShow this help message\\n"
    printf "  -r\\t\\t\\tRegister every service (comma-separated)\\n"
    printf "  -u\\t\\t\\tUnregister every service (comma-separated)\\n"
    printf "  -e\\t\\t\\tExclude this services from being registered (comma-separated)\\n"

    printf "\\nAvailable services:\\n %s\\n" "$(find_microservice_names)"
    exit 0
}

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

main() {

    local exclusions=()
    local register=()
    local unregister=()

    check_for_dependencies

    if [ "$#" = 0 ]; then
        printf "Sorry! I need something more to continue :(\\n\\n" 1>&2
        usage
        exit 1
    fi

    # obtiene las opciones de ejecución
    while getopts ":he:r:u:" opt; do
        case "${opt}" in
            e) IFS=', ' read -r -a exclusions <<< "${OPTARG}";;
            r)
                if [ "${OPTARG}" = "all" ]; then
                    register=( $(find_microservice_names " ") )
                else
                    IFS=', ' read -r -a register <<< "${OPTARG}"
                fi
            ;;
            u)
                if [ "${OPTARG}" = "all" ]; then
                    unregister=( $(find_microservice_names " ") )
                else
                    IFS=', ' read -r -a unregister <<< "${OPTARG}"
                fi
            ;;
            h) usage;;
            \?)
                printf "invalid option: %s\\n\\n" "$OPTARG" 1>&2
                usage
            ;;
            :)
                printf "invalid option: -%s requires an argument\\n\\n" "$OPTARG" 1>&2
                usage
            ;;
            *)
                printf "invalid option: %s\\n\\n" "${opt}" 1>&2
                usage
            ;;
        esac
    done

    shift $((OPTIND-1))

    # obtiene el resto de parametros como nombres de servicios registrables
    if [ "$#" -gt 0 ]; then
        printf "invalid option: %s\\n\\n" "$*" 1>&2
        usage
    fi

    # elimina los servicios excluidos de los servicios a registrar
    for exclusion in "${exclusions[@]}"; do
        printf "Excluding service from being registered in eureka: %s\\n" "${exclusion}"
        register=( ${register[@]/$exclusion/} )
    done

    # la lista de servicios registrables no puede estar vacia
    if [ "${#register[@]}" != 0 ]; then
        register_services ${register[*]}
    fi

    # la lista de servicios desregistrables no puede estar vacia
    if [ "${#unregister[@]}" != 0 ]; then
        unregister_services ${unregister[*]}
    fi
}

main "$@"
