#!/usr/bin/env bash
#=|
#=| DESCRIPTION
#%|   Devkit configuration tool
#=|
#+| USAGE
#+|   devkit [-velh]
#+|
#+| OPTIONS
#+|   -v          Print out devkit version
#+|   -e          Open config file in editor
#+|   -l          Print out a list of available commands
#+|   -h          Print this help message
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
source $DEVKIT_MODULE/devkit/lib/dependencies.lib.sh
source $DEVKIT_THIRDPARTY/github.com/mercuriev/bash_colors/bash_colors.sh

version() {
    clr_bold clr_blue "$(cat $DEVKIT_MODULE/devkit/assets/banner.txt)" -n
    clr_reset " "

    printf "/* (%d) Devkit v%s */\\n\\n" "$(date +%Y)" "$DEVKIT_VERSION"

    printf "// author:\\t\\t@jeslopalo\\n"
    printf "// config file:\\t\\t%s\\n" "$DEVKIT_CONFIG_FILE"
    printf "// config version:\\tv%d\\n" "$(find_version)"

    return 0
}

edit_config() {
    ${FCEDIT:-${VISUAL:-${EDITOR:-vi}}} "$DEVKIT_CONFIG_FILE";

    return $?;
}

list_commands() {
    local exclusions=( "sourcedir" )

    printf "Hi, how can I help you today? These are the available commands:\\n\\n"
    for command in $DEVKIT_BIN/*; do
        command_name=$(basename $command)

        if [[ ! ${exclusions[*]} =~ $command_name ]]; then
            printf " ⭑ %-17s:  %s\\n" "$command_name" "$($command_name --usage-describe)"
        fi
    done

    return 0
}

main() {
    check_for_dependencies

    while getopts ":velh" opt; do
        case "${opt}" in
            v)
                version
                exit 0
            ;;
            e)
                edit_config
                exit 0
            ;;
            l)
                list_commands
                exit 0
            ;;
            h)
                usage
                exit 0
            ;;
        esac
    done

    usage

    exit 0
}

main "$@"
