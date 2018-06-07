#!/usr/bin/env bash

_tput=":"
# Use colors, but only if connected to a terminal, and that terminal supports them.
if [[ ${DEVKIT_COLORS:-0} = 1 ]] && test -t 1; then
    _tput=$(which tput)
    _number_of_colors=$($_tput colors)

    [[ ${_number_of_colors:-0} -ge 8 ]] || _tput=":"
fi

color::test() {
    local -i max_color="(( ${_number_of_colors:-1}-1 ))"

    printf "Printing %d colors...\\n" "$max_color"
    for c in $(seq 0 $max_color); do
        printf "%s %-3d $reset%s %-3d $reset" "$($_tput setaf $c)" "$c" "$($_tput setab $c)" "$c"

        if (( c == 7 )); then
            printf "\\n"
        fi

        if (( c == 15 )) || (( c > 15 )) && (( (c-15) % 6 == 0 )); then
            printf "\\n"
        fi
    done
    printf "$reset\\n"
}

color::regular() { $_tput setaf "${1:-7}"; }
color::background() { $_tput setab "${1:-7}"; }
color::reset() { $_tput sgr0; }
color::bold() { $_tput bold; }
color::underline() { $_tput smul; }
color::nounderline() { $_tput rmul; }
color::reverse() { $_tput rev; }

## COLORS

#Regular
black=$($_tput setaf 0)
red=$($_tput setaf 1)
green=$($_tput setaf 2)
yellow=$($_tput setaf 3)
blue=$($_tput setaf 4)
purple=$($_tput setaf 5)
cyan=$($_tput setaf 6)
white=$($_tput setaf 7)

#Bright
bblack=$($_tput setaf 8)
bred=$($_tput setaf 9)
bgreen=$($_tput setaf 10)
byellow=$($_tput setaf 11)
bblue=$($_tput setaf 12)
bpurple=$($_tput setaf 13)
bcyan=$($_tput setaf 14)
bwhite=$($_tput setaf 15)

#Background
bg_black=$($_tput setab 0)
bg_red=$($_tput setab 1)
bg_green=$($_tput setab 2)
bg_yellow=$($_tput setab 3)
bg_blue=$($_tput setab 4)
bg_purple=$($_tput setab 5)
bg_cyan=$($_tput setab 6)
bg_white=$($_tput setab 7)

#Brightackground
bg_bblack=$($_tput setab 8)
bg_bred=$($_tput setab 9)
bg_bgreen=$($_tput setab 10)
bg_byellow=$($_tput setab 11)
bg_bblue=$($_tput setab 12)
bg_bpurple=$($_tput setab 13)
bg_bcyan=$($_tput setab 14)
bg_bwhite=$($_tput setab 15)

reset=$($_tput sgr0)
bold=$($_tput bold)
underline=$($_tput smul)
remove_underline=$($_tput rmul)
reverse=$($_tput rev)

error_color="$bwhite$bold"
warn_color="$white$bold"

color::println() { printf "${1:-}${@:2}${reset}"; }

black()  { color::println $black  "$@"; }
grey()   { color::println $bblack "$@"; }
red()    { color::println $red    "$@"; }
green()  { color::println $green  "$@"; }
blue()   { color::println $blue   "$@"; }
yellow() { color::println $yellow "$@"; }
purple() { color::println $purple "$@"; }
cyan()   { color::println $cyan   "$@"; }
white()  { color::println $white  "$@"; }

# utils

strip_color_codes() {
    perl -pe 's/\e\[?.*?[\@-~]//g' $content
}
