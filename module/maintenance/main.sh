#!/usr/bin/env bash
#=|
#=| SYNOPSIS
#>|   maintenance
#=|
#=| DESCRIPTION
#%|   Clean IntelliJ (ie. metadata & cache folder) and execute clean (maven, gradle, ant) in every workspace project
#-|
#-| AUTHORING
#-|   author          @jeslopalo <Jesús López Alonso>
#-|   year            2018
#=|
include lib::usage "$@"

import lib::configuration

find_maintenance_workspace() {
    local -r workspace=$(config::find_property "workspaces-dir")
    echo "${workspace/#\~/$HOME}"
}

find_maintenance_idea_cache_dir() {
    local -r cache_dir=$(config::find_property "idea-cache-dir")
    echo "${cache_dir/#\~/$HOME}"
}

IDEA_CACHE_HOME=$(find_maintenance_idea_cache_dir)
DEVELOPMENT_HOME=$(find_maintenance_workspace)

printf "\\nCleaning intellij metadata: %s...\\n" "$IDEA_CACHE_HOME"
rm -vrf $IDEA_CACHE_HOME/caches/*
rm -vrf $IDEA_CACHE_HOME/jars/*
rm -vrf $IDEA_CACHE_HOME/js_caches/*
rm -vrf $IDEA_CACHE_HOME/jsp_related_caches/*
rm -vrf $IDEA_CACHE_HOME/compiler/*

printf "\\nCleaning projects: %s...\\n" "$DEVELOPMENT_HOME"
#/usr/bin/find $DEVELOPMENT_HOME -name "build.xml" -printf '\n\033[32m> %h ...\033[0m\n\n' -execdir ant clean ';'
#/usr/bin/find $DEVELOPMENT_HOME -name "pom.xml" -printf '\n\033[32m> %h ...\033[0m\n\n' -execdir mvn clean ';'
#/usr/bin/find $DEVELOPMENT_HOME -name "build.gradle" -printf '\n\033[32m> %h ...\033[0m\n\n' -execdir gradle clean ';'
/usr/bin/find $DEVELOPMENT_HOME -name "build.xml" -execdir ant clean ';'
/usr/bin/find $DEVELOPMENT_HOME -name "pom.xml" -execdir mvn clean ';'
/usr/bin/find $DEVELOPMENT_HOME -name "build.gradle" -execdir gradle clean ';'
