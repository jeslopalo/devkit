#!/usr/bin/env bash

import lib::color

# minimal information: invocation, file & lineno
error_info_min_elements=3

debug=${DEBUG:-0}

# prefix to relativize paths
path_prefix=""

# colors
clr_exit_code=$bred$reverse$bold
clr_text=$bwhite
clr_code=$bblue
clr_code_args=$blue
clr_function=$bold
clr_line=$white

exit_code() {
  local sig_name code="$1"

  case $code in
    # Catchall for general errors
    1)   sig_name=ERROR ;;
    # Misuse of shell builtins (according to Bash documentation)
    2)   sig_name=BUILTIN_MISUSE ;;
    # Command invoked cannot execute
    126) sig_name=CANNOT_INVOKE ;;
    # command not found (ex : source script_not_existing)
    127) sig_name=COMMAND_NOT_FOUND ;;
    # Fatal error signal "n" (128 + n)
    129) sig_name=HUP ;;
    130) sig_name=INT ;; # Script terminated by Control-C
    131) sig_name=QUIT ;;
    132) sig_name=ILL ;;
    134) sig_name=ABRT ;;
    136) sig_name=FPE ;;
    137) sig_name=KILL ;;
    139) sig_name=SEGV ;;
    141) sig_name=PIPE ;;
    143) sig_name=TERM ;;
    255) sig_name=BAD_EXIT_CODE ;; # (exit takes only integer args in the range 0 - 255)
    *)  sig_name=FATAL ;;
  esac

  echo $sig_name
}

trap_handler() {
    local -r last_error="${1:-13}"
    local -r last_command="${2:-$BASH_COMMAND}"

    disable_traps

    (( ${last_error} <= 1 )) && exit $last_error;

    printf "\\n$clr_exit_code %s $reset$clr_text (code: %s)" "$(exit_code $last_error)" "$last_error"
    if [[ $last_command != ^exit\ [0-9]+$ ]]; then
        printf ": while trying to run $clr_code%s$reset!\\n" "$last_command"
    fi

    local frame=0
    local argv_offset=0
    local argc_frames=${#BASH_ARGC[@]}

    while caller_info=( $(caller $frame) ) ; do

        if shopt -q extdebug ; then

            declare argv=()
            declare argc
            declare frame_argc

            if [[ $frame -lt $argc_frames ]]; then
                for ((frame_argc=${BASH_ARGC[frame]},frame_argc--,argc=0; frame_argc >= 0; argc++, frame_argc--)) ; do
                    argv[argc]=${BASH_ARGV[argv_offset+frame_argc]}
                    case "${argv[argc]}" in
                        *[[:space:]]*) argv[argc]="'${argv[argc]}'" ;;
                    esac
                done
                argv_offset=$((argv_offset + ${BASH_ARGC[frame]}))
                print_line "${caller_info[@]}" -- "${FUNCNAME[frame]:-}" "${argv[*]:-}"
            else
                print_line "${caller_info[@]}"
            fi
        fi

        frame=$((frame+1))
    done

    # deprecated? i dont know what is the rationale of this piece of code
    #    if [[ $frame = 1 ]] ; then
    #       caller_info=( $(caller 0) )
    #       print_line "${caller_info[@]}"
    #    fi

    exit ${last_error}
}

print_line(){

    local info=("$@")
    local lineno="${info[0]:-?}"
    local invocation="${info[1]:-}"
    local file="${info[2]:-}"

    local separator="${info[3]:-}"
    local command="${info[4]:-}"
    local arguments="${info[@]:5}"

    if [[ $file != ${BASH_SOURCE[0]} ]] && (( ${#info[@]} >= $error_info_min_elements )); then

        if [[ -n $file ]]; then
            file="$(sourcedir $file)/$(basename $file)"
            file=${file#$path_prefix/}
        fi

        printf "${reset}  at $clr_function%s$reset" "$invocation"
        if [[ ${separator} = '--' ]] && [[ ${command} != "trap_handler" ]]; then
            printf "$reset invoking $clr_code%s($clr_code_args%s$reset$clr_code)$reset" "$command" "${arguments[@]}"
        fi
        printf "$reset $clr_line[$underline%s:%s$remove_underline]$reset\\n" "$file" "$lineno"
    fi
}

enable_traps() {
    # find wether path prefix has been configured
    for arg in ${@}; do
        if [[ $arg =~ "--path-prefix=".+ ]]; then
            path_prefix=${arg##*=}
        fi
    done

    # provide an error handler whenever a command exits
    trap 'trap_handler $?' ERR INT QUIT TERM EXIT

    # Run in debug mode, if set
    if [[ ${debug} == 1 ]]; then
        set -o xtrace
        set -o verbose
    fi

    set -o errexit
    set -o pipefail
    set -o nounset
    set -o functrace
    # propagate ERR trap handler functions, expansions and subshells
    set -o errtrace

    shopt -s extdebug
}

disable_traps() {
    trap - ERR INT QUIT TERM EXIT
}
