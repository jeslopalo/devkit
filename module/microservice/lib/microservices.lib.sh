#!/usr/bin/env bash

import lib::configuration

error_project_not_found() {
    printf "error: '%s' workspace could not be found in current directory [%s]\\n" "$slug" "$(ms::find_workspace)" 1>&2
    exit 1
}

go_to_slug() {
    local -r slug="$1"
    local -r ms_workspace="$(ms::find_workspace)"

    [ -d "$ms_workspace/$slug" ] || error_project_not_found
    cd "$ms_workspace/$slug"
}

version() {
	local slug="$1"
    local version_line

    go_to_slug "$slug"

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
    echo "$version"
}

clean() {
    local slug="$1"

    go_to_slug "$slug"

    printf "\\nClean '%s' workspace...\\n" "$slug"
    gradle clean
}

build() {
    local -r slug="$1"
    local -r parameters="${2:-}"

    go_to_slug "$slug"

    local version="$(version $slug)"

    printf "\\nBuilding version '%s'...\\n" "$version"
    [ -z "$parameters" ] || printf "parameters: [%s]\\n" "$parameters"
    [ -z "$JAVA_OPTS" ] || printf "java opts: [%s]\\n" "$JAVA_OPTS"

    gradle build $parameters
}

run() {
	local slug="$1"
	shift

	local args="$@"
	local microservice="${slug##*/}"

    go_to_slug "$slug"

	local version="$(version $slug)"

    printf "\\nRunning microservice '<%s, %s>'...\\n" "$microservice" "$version"
	if [ -f "build/libs/$microservice-$version.jar" ]; then
		printf "\e[2m"
		java -version
		printf "\e[22m"

		[ -z "$args" ] || printf "arguments: [%s]\\n" "$args"
		[ -z "$JAVA_OPTS" ] || printf "java opts: [%s]\\n" "$JAVA_OPTS"
		java -D$microservice $JAVA_OPTS -jar "build/libs/$microservice-$version.jar" $args

		return $?
	else
		printf "error: no se encontro el jar de la aplicacion en [%s]\\n" "$PWD/build/lib/$microservice-$version.jar" 1>&2
		return 1
	fi
}
