#!/bin/bash

source $TDK_LIB_DIR/configuration.lib.sh

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
