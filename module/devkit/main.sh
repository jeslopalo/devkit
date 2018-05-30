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
#+|   -e          Edit config file
#+|   -c          Set config file location
#+|   -l          Print a list of available commands
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

    printf "// config version:\\tv%d\\n" "$(find_version)"
    printf "// config file:\\t\\t%s\\n" "$DEVKIT_CONFIG_FILE"
    printf "// author:\\t\\t@jeslopalo\\n"

    return 0
}

edit_config() {
    printf "Open '%s' config file in editor...\\n" "$DEVKIT_CONFIG_FILE"

    ${FCEDIT:-${VISUAL:-${EDITOR:-vi}}} "$DEVKIT_CONFIG_FILE";
    return $?;
}

set_config_file() {
    local -r config_file="${1:-$DEVKIT_CONFIG}"

    if [[ -r $config_file ]]; then
        echo "$config_file" > "$DEVKIT_CUSTOM_CONFIG_DESCRIPTOR"
        export DEVKIT_CONFIG_FILE="$config_file"
        printf "Set '%s' as devkit configuration file\\n" "$config_file"
        return 0
    else
        printf "error: '%s' cannot be opened or it does not exist\\n" "$config_file"
        return 1
    fi
}

list_commands() {
    local exclusions=( "sourcedir" )

    clr_blue clr_bold "$(cat $DEVKIT_MODULE/devkit/assets/me.txt)"
    printf "\\nHi, how can I help you today? These are the available commands:\\n\\n"
    for command in $DEVKIT_BIN/[^_]*; do
        command_name=$(basename $command)

        if [[ ! ${exclusions[*]} =~ $command_name ]]; then
            printf " ⭑ %-17s:  %s\\n" "$command_name" "$($command_name --usage-describe)"
        fi
    done

    return 0
}

main() {
    check_for_dependencies

    while getopts ":velhc:" opt; do
        case "${opt}" in
            v)
                version
                exit $?
            ;;
            c)
                set_config_file "$OPTARG"
                exit $?
            ;;
            e)
                edit_config
                exit $?
            ;;
            l)
                list_commands
                exit $?
            ;;
            h)
                usage
                exit $?
            ;;
            \?)
                printf "invalid option: %s\\n\\n" "$OPTARG" 1>&2
                usage
                exit 1
            ;;
            :)
                printf "invalid option: -%s requires an argument\\n\\n" "$OPTARG" 1>&2
                usage
                exit 1
            ;;
            *)
                printf "invalid option: %s\\n\\n" "${opt}" 1>&2
                usage
                exit 1
            ;;
        esac
    done

    usage
    exit $?
}

main "$@"
