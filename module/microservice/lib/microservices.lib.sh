#!/bin/bash

source $TDK_LIB_DIR/configuration.lib.sh

function error_project_not_found() {
    printf "error: '%s' workspace could not be found in current directory [%s]\\n" "$slug" "$(find_ms_workspace)" 1>&2
    exit 1
}

function go_to_slug() {
    local -r slug="$1"
    local -r ms_workspace="$(find_ms_workspace)"

    [ -d "$ms_workspace/$slug" ] || error_project_not_found
    cd "$ms_workspace/$slug"
}

function version() {
	local slug="$1"

    go_to_slug "$slug" || exit 1

    # strategy 1: version is placed in a properties file
	if [ -f "gradle.properties" ]; then
	    version_line=$(cat gradle.properties | grep "^version")
	fi

    # strategy 2: version is placed in gradle main script
	if [ -z "$version_line" ] && [ -f "build.gradle" ]; then
	    version_line=$(cat build.gradle | grep "^version")
	fi

    # strategy 3: gradle is asked to get the version (slow)
    if [ -z "$version_line" ] && [ -f "build.gradle" ]; then
        version_line=$(gradle properties | grep "^version")
    fi

    version=${version_line//[^[:print:]]/}
    version=${version/version/}
    version=${version//[ =:\'\"]/}
    echo $version
}

function clean() {
    local slug="$1"

    go_to_slug "$slug" || exit 1

    printf "\\nClean '%s' workspace...\\n" "$slug"
    gradle clean
}

function build() {
    local -r slug="$1"
    local -r parameters="${2:-}"

    go_to_slug "$slug" || exit 1

    local version="$(version $slug)"

    printf "\\nBuilding version '%s'...\\n" "$version"
    [ -z "$parameters" ] || printf "parameters: [%s]\\n" "$parameters"
    [ -z "$JAVA_OPTS" ] || printf "java opts: [%s]\\n" "$JAVA_OPTS"

    gradle build $parameters
}

function run() {
	local slug="$1"
	shift

	local args="$@"
	local microservice="${slug##*/}"

    go_to_slug "$slug"

	local version="$(version $slug)"

	if [ -f "build/libs/$microservice-$version.jar" ]; then
		printf "\\nRunning microservice '<%s, %s>'...\\n" "$microservice" "$version"
		printf "\e[2m"
		java -version
		printf "\e[22m"
		[ -z "$args" ] || printf "arguments: [%s]\\n" "$args"
		[ -z "$JAVA_OPTS" ] || printf "java opts: [%s]\\n" "$JAVA_OPTS"
		java -D$microservice $JAVA_OPTS -jar "build/libs/$microservice-$version.jar" $args
	else
		printf "error: no se encontro el jar de la aplicacion en [%s]\\n" "$PWD/build/lib/$microservice-$version.jar" 1>&2
		exit 1
	fi
}
