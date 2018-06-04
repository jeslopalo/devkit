#!/usr/bin/env bash

declare tput=$(which tput)
declare -i terminal=$(test -t 1)
declare -i with_colors

color::tput() {
    local -r args="${@:-sgr0}"
    local -i ncolors=0

    # Use colors, but only if connected to a terminal, and that terminal supports them.
    if [[ -z ${with_colors:-} ]]; then
        if [[ -n "$tput" ]]; then
            ncolors=$(tput colors)
        fi

        [[ $terminal ]] && [[ -n ${ncolors:-} ]] && [[ $ncolors -ge 8 ]] && with_colors=1 || with_colors=0
    fi

    if [[ $with_colors = 1 ]]; then $tput ${args[@]}; fi
}

color::test() {
    local -ri ncolors=$(color::tput colors)

    printf "Printing %d colors...\\n" "$ncolors"

    for((c=0; c < $ncolors; c++)); do
        printf "%s %-3d $reset%s %-3d $reset" "$(color::regular $c)" "$c" "$(color::background $c)" "$c"

        if (( c == 7 )); then
            printf "$reset\\n"
        fi

        if (( c == 15 )) || (( c > 15 )) && (( (c-15) % 6 == 0 )); then
            printf "$reset\\n"
        fi
    done
    printf "$reset\\n"
}

color::test2() {
    local -r type="${1:-regular}"
    local -ri ncolors=$(color::tput colors)

    printf "Printing %d colors...\\n" "$ncolors"
    for((c=0; c < $ncolors; c++)); do
        printf "%s %-3d $reset" "$(color::$type $c)" "$c"

        if (( c == 7 )); then
            printf "$reset\\n"
        fi

        if (( c == 15 )) || (( c > 15 )) && (( (c-15) % 6 == 0 )); then
            printf "$reset\\n"
        fi
    done
    printf "$reset\\n"
}

color::regular() { color::tput setaf "${1:-7}"; }
color::background() { color::tput setab "${1:-7}"; }
color::reset() { color::tput sgr0; }
color::bold() { color::tput bold; }
color::underline() { color::tput smul; }
color::nounderline() { color::tput rmul; }
color::reverse() { color::tput rev; }

color::println() {
    local -r color="${1:-}"
    shift
    local -r message="$@"
    printf "${color}${message}${reset}"
}

strip_color_codes() {
    perl -pe 's/\e\[?.*?[\@-~]//g' $content
}

## COLORS

black()  { color::println $black  "$@"; }
grey()   { color::println $bblack "$@"; }
red()    { color::println $red    "$@"; }
green()  { color::println $green  "$@"; }
blue()   { color::println $blue   "$@"; }
yellow() { color::println $yellow "$@"; }
purple() { color::println $purple "$@"; }
cyan()   { color::println $cyan   "$@"; }
white()  { color::println $white  "$@"; }

#Regular
black="$(color::regular 0)"
red="$(color::regular 1)"
green="$(color::regular 2)"
yellow="$(color::regular 3)"
blue="$(color::regular 4)"
purple="$(color::regular 5)"
cyan="$(color::regular 6)"
white="$(color::regular 7)"

#Bright
bblack="$(color::regular 8)"
bred="$(color::regular 9)"
bgreen="$(color::regular 10)"
byellow="$(color::regular 11)"
bblue="$(color::regular 12)"
bpurple="$(color::regular 13)"
bcyan="$(color::regular 14)"
bwhite="$(color::regular 15)"

#Background
bg_black="$(color::background 0)"
bg_red="$(color::background 1)"
bg_green="$(color::background 2)"
bg_yellow="$(color::background 3)"
bg_blue="$(color::background 4)"
bg_purple="$(color::background 5)"
bg_cyan="$(color::background 6)"
bg_white="$(color::background 7)"

#Brightackground
bg_bblack="$(color::background 8)"
bg_bred="$(color::background 9)"
bg_bgreen="$(color::background 10)"
bg_byellow="$(color::background 11)"
bg_bblue="$(color::background 12)"
bg_bpurple="$(color::background 13)"
bg_bcyan="$(color::background 14)"
bg_bwhite="$(color::background 15)"

reset="$(color::reset)"
bold="$(color::bold)"
underline="$(color::underline)"
remove_underline="$(color::nounderline)"
#blink="$(tput blink)"
reverse="$(color::reverse)"

error_color="$bwhite$bold"
warn_color="$white$bold"
