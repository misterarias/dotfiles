#!/usr/bin/env bash

SOURCES=$(cd "$(dirname "$0")" ; pwd )
source "${SOURCES}/.bash_local_aliases"

# Some color codes
BOLD=$(tput bold)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
ENDCOLOR=$(tput sgr0)

function test__get_repo_and_project {
  repos[0]=ssh://git@globaldevtools.bbva.com:7999/cucumber/cucumber-jvm-groovy.git
  repos[1]=https://github.com/cucumber/cucumber-jvm-groovy.git
  repos[2]=git@github.com:cucumber/cucumber-jvm-groovy.git

  for (( i=0 ; i<${#repos[*]} ; i++ )) ; do
    result="$( _get_repo_and_project "${repos[$i]}" )"
    __assert_equals "${result}" "cucumber cucumber-jvm-groovy"
  done
}

function load_git_functions {
  git > /dev/null 2>&1
}

__error() {
  echo "${RED}${BOLD}[ERROR]${ENDCOLOR} - $*"
  exit 1
}

__assert_equals() {
  [ "${1}" != "${2}" ] && echo "'$1' should be equal to '$2'"
}

test_table_load() {
  TESTS[0]="get_repo_and_project"

  for (( i=0 ; i<${#TESTS[*]} ; i++ )) ; do
    entry=(${TESTS[$i]})
    function="${entry[0]}"

    printf "Running tests for '%s'....." "${function}"
    errors=$(eval "test__${function}")
    [ ! -z "${errors}" ] && __error "${errors}"
    echo "${GREEN}${BOLD}OK${ENDCOLOR}"

  done
}

load_git_functions
test_table_load
