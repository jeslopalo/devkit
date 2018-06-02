#!/usr/bin/env bash

# Use colors, but only if connected to a terminal, and that terminal supports them.
tput=$(which tput)
if [[ -n "$tput" ]]; then
    ncolors=$(tput colors)
fi

if [[ -t 1 ]] && [[ -n "$ncolors" ]] && [[ "$ncolors" -ge 8 ]]; then

    #Regular
    black="$(tput setaf 0)"
    red="$(tput setaf 1)"
    green="$(tput setaf 2)"
    yellow="$(tput setaf 3)"
    blue="$(tput setaf 4)"
    purple="$(tput setaf 5)"
    cyan="$(tput setaf 6)"
    white="$(tput setaf 7)"

    #Bright
    bblack="$(tput setaf 8)"
    bred="$(tput setaf 9)"
    bgreen="$(tput setaf 10)"
    byellow="$(tput setaf 11)"
    bblue="$(tput setaf 12)"
    bpurple="$(tput setaf 13)"
    bcyan="$(tput setaf 14)"
    bwhite="$(tput setaf 15)"

    #Background
    bg_black="$(tput setab 0)"
    bg_red="$(tput setab 1)"
    bg_green="$(tput setab 2)"
    bg_yellow="$(tput setab 3)"
    bg_blue="$(tput setab 4)"
    bg_purple="$(tput setab 5)"
    bg_cyan="$(tput setab 6)"
    bg_white="$(tput setab 7)"

    #Brightackground
    bg_bblack="$(tput setab 8)"
    bg_bred="$(tput setab 9)"
    bg_bgreen="$(tput setab 10)"
    bg_byellow="$(tput setab 11)"
    bg_bblue="$(tput setab 12)"
    bg_bpurple="$(tput setab 13)"
    bg_bcyan="$(tput setab 14)"
    bg_bwhite="$(tput setab 15)"

    reset="$(tput sgr0)"
    bold="$(tput bold)"
    underline="$(tput smul)"
    remove_underline="$(tput rmul)"
    blink="$(tput blink)"
    reverse="$(tput rev)"
else

    #Regular
    black=""
    red=""
    green=""
    yellow=""
    blue=""
    purple=""
    cyan=""
    white=""

    #Bright
    bblack=""
    bred=""
    bgreen=""
    byellow=""
    bblue=""
    bpurple=""
    bcyan=""
    bwhite=""

    #Background
    bg_black=""
    bg_red=""
    bg_green=""
    bg_yellow=""
    bg_blue=""
    bg_purple=""
    bg_cyan=""
    bg_white=""

    #Brightackground
    bg_bblack=""
    bg_bred=""
    bg_bgreen=""
    bg_byellow=""
    bg_bblue=""
    bg_bpurple=""
    bg_bcyan=""
    bg_bwhite=""

    reset=""
    bold=""
    underline=""
    remove_underline=""
    blink=""
    reverse=""
fi

error_color="$bwhite$bold"
warn_color="$white$bold"

color::println() {
printf "$@"
    local -r color="${1:-}"
    shift
    local -r message="$@"

    printf "$color%s$reset\\n" "$message"
}

red() {
    color::println $red "$@"
}

green() {
    color::println $green "$@"
}

blue() {
    color::println $blue "$@"
}

yellow() {
    color::println $yellow "$@"
}

purple() {
    color::println $purple "$@"
}

cyan() {
    color::println $cyan "$@"
}

white() {
    color::println $white "$@"
}

strip_color_codes() {
    perl -pe 's/\e\[?.*?[\@-~]//g' $content
}
