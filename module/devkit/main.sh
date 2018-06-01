#!/usr/bin/env bash
#=|
#=| SYNOPSIS
#>|   devkit [-h] [-v | -e | -c | -l]
#=|
#=| DESCRIPTION
#%|   Devkit configuration tool
#+|
#+| USAGE
#+|   devkit [-velh]
#+|
#+| OPTIONS
#+|   -v          Print out devkit version
#+|   -e          Edit config file
#+|   -c          Set config file location
#+|   -l          Print a list of available commands
#+|   -h          Print this help message
#-|
#-| AUTHORING
#-|   author          @jeslopalo <Jesús López Alonso>
#-|   year            2018
#=|
source $DEVKIT_LIB/error.lib.sh

# configure exception traps
enable_traps --path-prefix=$DEVKIT_HOME

source $DEVKIT_LIB/usage.lib.sh
source $DEVKIT_LIB/color.lib.sh
source $DEVKIT_LIB/log.lib.sh
source $DEVKIT_LIB/configuration.lib.sh
source $DEVKIT_MODULE/devkit/lib/dependencies.lib.sh


version() {

    printf "$bold%s$reset\\n" "$(cat $DEVKIT_MODULE/devkit/assets/banner.txt)"
    printf "$white/* (%d) Devkit v%s */$reset\\n\\n" "$(date +%Y)" "$DEVKIT_VERSION"
    printf "$white// config version:$reset\\t${cyan}v%d$reset\\n" "$(find_version)"
    printf "$white// config file:$reset\\t\\t${cyan}%s$reset\\n" "$DEVKIT_CONFIG_FILE"
    printf "$white// author:$reset\\t\\t$cyan@jeslopalo$reset\\n"

    return 0
}

edit_config() {
    log::info "Open '$DEVKIT_CONFIG_FILE' config file in editor..."

    ${FCEDIT:-${VISUAL:-${EDITOR:-vi}}} "$DEVKIT_CONFIG_FILE";
    return $?;
}

set_config_file() {
    local -r config_file="${1:-$DEVKIT_CONFIG}"

    if [[ -r $config_file ]]; then
        echo "$config_file" > "$DEVKIT_CUSTOM_CONFIG_DESCRIPTOR"
        export DEVKIT_CONFIG_FILE="$config_file"
        log::info "Set '$config_file' as devkit configuration file"
        return 0
    else
        log::error "'$config_file' cannot be opened or it does not exist"
        return 1
    fi
}

list_commands() {
    local exclusions=( "sourcedir" )

    printf "$bblue$bold%s$reset\\n" "$(cat $DEVKIT_MODULE/devkit/assets/me.txt)"
    printf "\\nHi, how can I help you today? These are the available commands:\\n\\n"
    for command in $DEVKIT_BIN/[^_]*; do
        command_name=$(basename $command)

        if [[ ! ${exclusions[*]} =~ $command_name ]]; then
            printf " ➜ %-17s:  %s\\n" "$command_name" "$($command_name --purpose)"
        fi
    done

    return 0
}

main() {
    check_for_dependencies

    if [[ "$#" -lt 1 ]]; then
        log::warn "Sorry! I need something more to continue :("
        log::usage "$(devkit --synopsis)"
        exit 1
    fi

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
                devkit --help
                exit 0
            ;;
            :)
                log::error "invalid option: -$OPTARG requires an argument"
                log::usage "$(devkit --synopsis)"
                exit 1
            ;;
            \?|*)
                log::error "invalid option: $OPTARG"
                log::usage "$(devkit --synopsis)"
                exit 1
            ;;
        esac
    done

    exit $?
}

main "$@"
