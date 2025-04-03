#!/usr/bin/env bash
# based on fzf-preview.sh

set -euo pipefail


input=${1/#\~\//$HOME/}
if [ -d "${input}" ]; then
    # if there is a README.md, use it
    if [ -f "${input}/README.md" ]; then
        ~/.fzf/bin/fzf-preview.sh "${input}/README.md"
    else
        # If not a git repository, use tree to list the files
        tree -C --gitignore -L 2 -- "${input}"
    fi
    exit
else
    # fall back to fzf-preview.sh
    ~/.fzf/bin/fzf-preview.sh "${1}"
fi
