#!/usr/bin/env bash
#=|
#=| SYNOPSIS
#>|   devkit [-h] [-v | -e | -c | -l | -t | -E]
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
#+|   -t          Print a color test
#+|   -E          Print devkit's environment vars
#+|   -h          Print this help message
#-|
#-| AUTHORING
#-|   author          @jeslopalo <Jesús López Alonso>
#-|   year            2018
#=|
include lib::usage "$@"

import lib::color
import lib::log
import lib::configuration
import module::devkit::dependencies

version() {
    printf "$bold%s$reset\\n" "$(cat $DEVKIT_MODULE/devkit/assets/banner.txt)"
    printf "$white/* (%d) Devkit v%s */$reset\\n\\n" "$(date +%Y)" "$DEVKIT_VERSION"
    printf "$white// config version :$reset ${cyan}v%d$reset\\n" "$(find_version)"
    printf "$white// config file    :$reset ${cyan}%s$reset\\n" "$DEVKIT_CONFIG_FILE"
    printf "$white// author         :$reset $cyan@jeslopalo$reset\\n"

    return 0
}

print_environment() {
    printf "Devkit environment values:\\n\\n"

    if [[ ${DEVKIT_COLORS:-} = 1 ]]; then
        env \
            | grep -E "^_?DEVKIT_" \
            | perl -pe 's/^(\w+)(=)(.*)$/\033[32m$1\033[m $2 $3/'
    else
        env \
            | grep -E "^_?DEVKIT_" \
            | perl -pe 's/^(\w+)(=)(.*)$/$1 $2 $3/'
    fi
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

test_colors() {
    echo "$bg_bgreen$black colors everywhere! $reset"

    black black-
    red red-
    green green-
    yellow yellow-
    blue blue-
    purple purple-
    cyan cyan-
    white "white\\n\\n"

    color::test

    return 0
}

main() {
    check_for_dependencies

    while getopts ":veElhtc:" opt; do
        case "${opt}" in
            v)
                version
                exit $?
            ;;
            c)
                set_config_file "$OPTARG"
                exit $?
            ;;
            E)
                print_environment
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
            t)
                test_colors
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

    log::warn "Sorry! I need something more to continue :("
    log::usage "$(devkit --synopsis)"
    exit 1
}

main "$@"
