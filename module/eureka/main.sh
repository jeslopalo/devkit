#!/usr/bin/env bash
#=|
#=| DESCRIPTION
#%|   Utility to register services in eureka server
#=|
#+| USAGE
#+|   eureka [-h] [-r <services> [-e <services>]] [-u <services>]
#+|
#+| OPTIONS
#+|   -r all | <service1 [,service2]>       Register every service (comma-separated names or all)
#+|   -e <service1 [,service2]>             Exclude this services from being registered (comma-separated)
#+|   -u all | <service1 [,service2]>       Unregister every service (comma-separated names or all)
#+|   -h                                    Print this help message
#+|
#+| EXAMPLES
#+|   eureka -r all
#+|   eureka -r all -e service1
#+|   eureka -r service1,service2
#+|   eureka -u all
#+|   eureka -u service1,service2
#+|   eureka -r service1 -u service2
#=|
#-| AUTHORING
#-|   author          @jeslopalo <Jesús López Alonso>
#-|   year            2018
#=|
source $DEVKIT_LIB/error.lib.sh

# configure exception traps
enable_traps --path-prefix=$DEVKIT_HOME

source $DEVKIT_LIB/usage.lib.sh
source $DEVKIT_LIB/configuration.lib.sh
source $DEVKIT_MODULE/eureka/lib/dependencies.lib.sh
source $DEVKIT_MODULE/eureka/lib/eureka.lib.sh

eureka_usage() {
    usage
    printf "\\nAVAILABLE SERVICES\\n"
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
        eureka_usage
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
            h) eureka_usage;;
            \?)
                printf "invalid option: %s\\n\\n" "$OPTARG" 1>&2
                eureka_usage
            ;;
            :)
                printf "invalid option: -%s requires an argument\\n\\n" "$OPTARG" 1>&2
                eureka_usage
            ;;
            *)
                printf "invalid option: %s\\n\\n" "${opt}" 1>&2
                eureka_usage
            ;;
        esac
    done

    shift $((OPTIND-1))

    # obtiene el resto de parametros como nombres de servicios registrables
    if [ "$#" -gt 0 ]; then
        printf "invalid option: %s\\n\\n" "$*" 1>&2
        eureka_usage
    fi

    # elimina los servicios excluidos de los servicios a registrar
    for exclusion in "${exclusions[@]:-}"; do
        if [[ -n ${exclusion:-} ]]; then
            printf "Excluding service from being registered in eureka: %s\\n" "${exclusion}"

            # TODO: That removes prefixes matching $exclusion from the elements, not necessarily whole elements.
            register=( ${register[@]/$exclusion/} )
        fi
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
