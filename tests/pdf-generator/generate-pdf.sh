#!/usr/bin/env bash

DEFAULT_ENDPOINT_URL="http://localhost:8012/v1/files"
url="$DEFAULT_ENDPOINT_URL"
verbose=""

usage() {
    local -r code="${1:-0}"
    printf "\\nusage: %s [-h -v] [ -u <host url> ] <json file path>\\n" "$0" 1>&2;
    if [[ $code = 0 ]]; then
        printf "\\nOptions:\\n";
        printf "\\t-u <host url>           Url del endpoint a invocar (por defecto %s)\\n" "$DEFAULT_ENDPOINT_URL";
        printf "\\t-v                      Muestra información de debug en la invocación remota\\n";
        printf "\\t-h                      Muestra la ayuda\\n";
        printf "\\nArguments:\\n";
        printf "\\t<json file path>        Path de la petición json a enviar\\n";
    fi
    exit $code;
}

generate_pdf() {
    local -r file="${1}"
    local -r url="${2}"
    local -r verbose="${3:---silent}"

    if [ ! -f $file ]; then
        printf "\\nerror: no existe el fichero [%s]\\n" "$file"
        usage 2
    fi

    if [ -z $url ]; then
        printf "\\nerror: es necesaria la url del endpoint\\n"
        usage 3
    fi

    printf "\\nGenerating pdf from request: \\n%s\\n" "$(cat $file)"

    curl --header 'Content-Type: application/json' \
         --header 'Accept: application/json' \
         --data-binary "@$file" \
         "$verbose" \
         "$url"

    printf "\\n"
}

main() {
    # obtiene las opciones de ejecución
    while getopts ":vhu:" opt; do
        case "${opt}" in
            v) verbose="--verbose" ;;
            h) usage ;;
            u) url="${OPTARG}" ;;
        esac
    done
    shift $((OPTIND-1))

    if [ "$#" -gt 0 ]; then
        file="$@"
    fi

    if [ -z "${file}" ] || [ -z "${url}" ]; then
        usage
    fi

    generate_pdf "$file" "$url" "$verbose"
}

main "$@"
