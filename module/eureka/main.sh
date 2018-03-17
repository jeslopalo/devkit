#!/usr/bin/env bash

source $TDK_LIB_DIR/configuration.lib.sh
source $TDK_MODULE_DIR/eureka/lib/dependencies.lib.sh
source $TDK_MODULE_DIR/eureka/lib/eureka.lib.sh

usage() {
    printf "usage: eureka [-h ][-r <services> [-e <services>]][-u <services>]\\n\\n" 1>&2
    printf "  -h\\tShow this help message\\n"
    printf "  -r\\tRegister every service (comma-separated)\\n"
    printf "  -u\\tUnregister every service (comma-separated)\\n"
    printf "  -e\\tExclude this services from being registered (comma-separated)\\n"

    printf "\\nAvailable services:\\n\\n"
    find_eureka_registerable_microservices_in_columns
    exit 0
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
                    register=( $(find_eureka_registerable_microservices) )
                else
                    IFS=', ' read -r -a register <<< "${OPTARG}"
                fi
            ;;
            u)
                if [ "${OPTARG}" = "all" ]; then
                    unregister=( $(find_eureka_registerable_microservices) )
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
