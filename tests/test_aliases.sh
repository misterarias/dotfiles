#/usr/bin/env bash

SOURCES=$(cd "$(dirname "$0")/.." ; pwd )
source "${SOURCES}/.bash_local_aliases"

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
  git >> /dev/null 2&>1
}

__assert_equals() {
  [ "${1}" != "${2}" ] && \
    echo "[ERROR] $1 should be equal to $2" && exit 1
}

load_git_functions
test__get_repo_and_project
echo "OK!!!"
