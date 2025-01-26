#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

source packages.sh

setup() {
    # Lots of fancy functions here:
    # shellcheck source=/dev/null
    source .bash_local_aliases

    __prerequisites

    case "${1}" in
        all)      setup_all ;;
        vim)      setup_vim ;;
        dotfiles) setup_dotfiles ;;
        git)      setup_git ;;
        postgres) setup_postgres ;;
        ruby)     setup_ruby ;;
        configs)  setup_configs ;;
        binaries) setup_binaries ;;
        test)     run_tests;;
        help|*)   help ;;
    esac

    green "Everything is done, enjoy!"
}

mode="${1:-all}"
setup "${mode}"
