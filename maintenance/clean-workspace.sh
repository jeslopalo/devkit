#!/bin/sh
IDEA_CACHE_HOME=$HOME/.IntelliJIdea14/system
DEVELOPMENT_HOME=$HOME/development

printf "\\nCleaning intellij metadata...\\n"
rm -vrf $IDEA_CACHE_HOME/caches/*
rm -vrf $IDEA_CACHE_HOME/jars/*
rm -vrf $IDEA_CACHE_HOME/js_caches/*
rm -vrf $IDEA_CACHE_HOME/jsp_related_caches/*
rm -vrf $IDEA_CACHE_HOME/compiler/*

printf "\\nCleaning projects...\\n"
cd $DEVELOPMENT_HOME
find . -name "build.xml" -printf '\n\033[32m> %h ...\033[0m\n\n' -execdir ant clean ';'
find . -name "pom.xml" -printf '\n\033[32m> %h ...\033[0m\n\n' -execdir mvn clean ';'
find . -name "build.gradle" -printf '\n\033[32m> %h ...\033[0m\n\n' -execdir gradle clean ';'
cd -
