#!/usr/bin/env bash
# vi: ft=sh ts=2 sw=2
# shellcheck source=/dev/null

# Set default shell mode to VIM, fuck emacs
set -o vi
#set -o emacs  # sorry pal

# Nice defaults
export PS1="$ "
export PROMPT_COMMAND=

# Locale select
export LANG="es_ES.UTF-8"

# My local binaries path
export PATH="$HOME/.local/bin:$PATH"

# At the very least, colours in MAC
export CLICOLOR=1

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
export LESS="--RAW-CONTROL-CHARS"

# DAMNED WARNING
export BASH_SILENCE_DEPRECATION_WARNING=1

# Pycharm bug when using gevent
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

. ~/.bash_local_aliases

# Enable bash to cycle through completions (https://superuser.com/a/59198)
#[[ $- = *i* ]] && bind TAB:menu-complete
##
## # Options for autocompletion
bind "set show-all-if-ambiguous on"
bind "set completion-ignore-case on"
bind "set menu-complete-display-prefix on"
bind "set colored-completion-prefix on"
bind "set colored-stats on"
## # Alternative would be ~/.inputrc
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
##

# testing starship
command -v starship &> /dev/null && eval "$(starship init bash)"
export STARSHIP_CACHE="$HOME/.cache/starship"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
export PATH="${HOME}/.pyenv/bin:$PATH"
export PATH="${HOME}/.pyenv/bin:$PATH"
