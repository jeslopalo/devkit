#!/bin/bash

function error_project_not_found() {
    printf "error: no existe el proyecto '%s' en el directorio actual [%s]\\n" "$slug" "$PWD" 1>&2
}

function go_to_slug() {
    local slug="$1"

    cd "$MICROSERVICES_WORKSPACE"
    if [ ! -d "$slug" ]; then
        error_project_not_found
        exit 1
    fi

    cd "$slug"
}

function version() {
	local slug="$1"

    go_to_slug "$slug"

	if [ -f "gradle.properties" ]; then
		eval "$(cat gradle.properties | grep "version" | tr -d ' ')"
		echo "$version"
	fi
}

function clean() {
    local slug="$1"

    go_to_slug "$slug"

    printf "\\nClean '%s' workspace...\\n" "$slug"
    gradle clean
    return $?
}

function build() {
    local slug="$1"
    local skip_tests="${2:-0}"
    local flags=""

    go_to_slug "$slug"

    local version="$(version $slug)"

    printf "\\nBuilding version '%s'...\\n" "$version"

    if [ -n "$skip_tests" ]; then
        printf "\\nSkiping tests...\\n"
        flags="-x test $flags"
    fi
    gradle build $flags
    return $?
}

function run() {
	local slug="$1"
	shift
	local args="$@"
	local microservice="${slug##*/}"

    go_to_slug "$slug"

	local version="$(version $slug)"

	if [ -f "build/libs/$microservice-$version.jar" ]; then
		printf "\\nEjecutando el microservicio '<%s, %s>'...\\n" "$microservice" "$version"
		printf "\e[2m"
		java -version
		printf "\e[22m"
		printf "arguments: [%s]\\n" "$args"
		printf "java opts: [%s]\\n" "$JAVA_OPTS"
		java -D$microservice $JAVA_OPTS -jar "build/libs/$microservice-$version.jar" $args
		return $?
	else
		printf "error: no se encontro el jar de la aplicacion en [%s]\\n" "$PWD/build/lib/$microservice-$version.jar" 1>&2
		return 1
	fi
}

function microservice_lifecycle() {

	if [ $# = 0 ]; then
        printf "error: necesito un nombre de microservicio :(\\n" 1>&2
        return 1;
    fi

	local parameters="$@"
	local microservice_name="$1"
	local skip_tests=0
	shift;

	while [[ $# -gt 0 ]];  do
        key="$1"

        case "$key" in
            --skip-tests)
                skip_tests=1
            ;;
            --parameters|-p)
                shift
                microservice_parameters="$microservice_parameters $1"
            ;;
            --clean|-c)
                clean_phase=1
            ;;
            --build|-b)
			    build_phase=1
            ;;
            --run|-r)
                run_phase=1
            ;;
            -bc|-cb)
                clean_phase=1
                build_phase=1
            ;;
            -br|-rb)
                build_phase=1
                run_phase=1
            ;;
            -brc|-bcr|-rbc|-rcb|-cbr|-crb)
                build_phase=1
                run_phase=1
                clean_phase=1
            ;;
            *)
                printf "\\nerror: Ouch! Unknown option '%s'. Please try agan!\\n" "$key" 1>&2
                printf "parameters: %s\\n" "$parameters" 1>&2
                return 1
            ;;
        esac

        shift;
    done

    if [ -z "$clean_phase" ] && [ -z "$build_phase" ] && [ -z "$run_phase" ]; then
	    printf "\\nerror: no me has dicho que quieres hacer (ie. --clean, --build, --run) :(\\n" 1>&2
        printf "parameters: %s\\n" "$parameters" 1>&2
		return 1;
    fi

	if [ -n "$clean_phase" ]; then
	    clean "$microservice_name"
        if [ "$?" = 1 ]; then
            printf "\\nerror: no se ha podido limpiar el microservicio: %s\\n" "$microservice_name" 1>&2
            printf "parameters: %s\\n" "$parameters" 1>&2
            return 1
        fi
    fi

	if [ -n "$build_phase" ]; then
	    build "$microservice_name" "$skip_tests"
        if [ "$?" = 1 ]; then
            printf "\\nerror: no se ha podido construir el microservicio: %s\\n" "$microservice_name" 1>&2
            printf "parameters: %s\\n" "$parameters" 1>&2
            return 1
        fi
    fi

    if [ -n "$run_phase" ]; then
        run "$microservice_name" $microservice_parameters
        if [ "$?" = 1 ]; then
            printf "\\nerror: no se ha podido ejecutar el microservicio: %s\\n" "$microservice_name" 1>&2
            printf "parameters: %s\\n" "$parameters" 1>&2
            return 1
        fi
    fi
}
