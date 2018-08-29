#!/usr/bin/env bash

using find

import lib::error
import lib::command
import lib::color

import module::maintenance::configuration

maintenance::clean_intellij_caches() {
    local -r idea_cache_dir=$(maintenance::find_idea_cache_dir)

    if [[ -n $idea_cache_dir ]] && [[ -d $idea_cache_dir ]]; then
        printf "Cleaning intellij metadata: %s...\\n" "$idea_cache_dir"
        rm -vrf $idea_cache_dir/caches/*
        rm -vrf $idea_cache_dir/jars/*
        rm -vrf $idea_cache_dir/js_caches/*
        rm -vrf $idea_cache_dir/jsp_related_caches/*
        rm -vrf $idea_cache_dir/compiler/*
    else
        log::error "directory not found: $idea_cache_dir"
    fi
}

maintenance::clean_workspace() {
    local -r development_home=$(maintenance::find_workspace)

    if [[ -n $development_home ]] && [[ -d $development_home ]]; then
        printf "Cleaning projects in '$yellow%s$reset':\\n\\n" "$development_home"


        for build_descriptor in $(find $development_home \( -name "build.xml" -o -name "pom.xml" -o -name "build.gradle" \)); do
            printf " ➔ $yellow%s$reset:\\n" "$build_descriptor"
            case "$build_descriptor" in
                */build.xml)
                    printf "   ☛ found $cyan%s$reset project\\n\\n" "ant"
                    maintenance::clean $build_descriptor "ant"
                ;;
                */pom.xml)
                    printf "   ☛ found $cyan%s$reset project\\n\\n" "mvn"
                    maintenance::clean $build_descriptor "mvn"
                ;;
                */build.gradle)
                    printf "   ☛ found $cyan%s$reset project\\n\\n" "gradle"
                    maintenance::clean $build_descriptor "gradle"
                ;;
                *)
                    printf "   ☛ ${red}error: %s${reset}\\n\\n" "$build_descriptor"
                ;;
            esac
        done
    fi
}

maintenance::clean() {
    local -r location=$(dirname ${1:-})
    local -r command=${2:-}

    if command::available $command; then
        cd "$location"
        $command clean && printf "\\n   $green...cleaned ${bgreen}✔$reset\\n\\n" || printf "\\n   $red...error ${bred}✘$reset\\n\\n"
    else
        printf "   ${bg_red}${bold} WARNING ${reset} ${bold}%s command not found!\\n\\n" "$command"
        printf "   ${reset}${red}...skipping ${bred}✘${reset}\\n\\n"
    fi
}
