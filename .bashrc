#!/usr/bin/env bash
# vi: ft=sh ts=2 sw=2
# shellcheck source=/dev/null
[ -f ~/.bash_local_aliases ] && . ~/.bash_local_aliases

# My local binaries path
export PATH="$HOME/.local/bin:$PATH"

# At the very least, colours in MAC
export CLICOLOR=1

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
export LESS="--RAW-CONTROL-CHARS"

# DDAMNDED WARNING
export BASH_SILENCE_DEPRECATION_WARNING=1

# I want cores
ulimit -c unlimited

# Useful for everything: bash, git, postgres...
export EDITOR=vim
export PSQL_EDITOR='vim -c"set syntax=sql"'

# Pycharm bug when using gevent
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

# Rust Package manager
export PATH="$HOME/.cargo/bin:$PATH"

# Pyenv goodness
export PYENV_ROOT=${HOME}/.venvs
export PATH="${HOME}/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# Enable bash to cycle through completions (https://superuser.com/a/59198)
[[ $- = *i* ]] && bind TAB:menu-complete

# Options for autocompletion
bind "set show-all-if-ambiguous on"
bind "set completion-ignore-case on"
bind "set menu-complete-display-prefix on"

# Depends on 'pip install powerline-shell'
_update_ps1() {
    PS1=$(powerline-shell $?)
}

if [[ $TERM != linux && ! $PROMPT_COMMAND =~ _update_ps1 ]]; then
    PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
fi

# Add this AFTER any prompt-manipulating extensions: https://direnv.net/docs/hook.html
_direnv_hook() {
  local previous_exit_status=$?;
  eval "$(direnv export bash)";
  return $previous_exit_status;
}

if ! [[ "${PROMPT_COMMAND:-}" =~ _direnv_hook ]]; then
  PROMPT_COMMAND="_direnv_hook${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
fi

## Should not be needed if the above works
# eval "$(direnv hook bash)"

# This introduces the SIGINT trap error: eval "$(direnv hook bash)"
[ -f "${HOME}/.ghcup/env" ] && . "${HOME}/.ghcup/env" # ghcup-env

# brew install fuck
eval "$(thefuck --alias)"

# brew install fzf
[ -f ~/.fzf.bash ] && . ~/.fzf.bash
export JAVA_HOME="${HOME}/.sdkman/candidates/java/current/"

# To use 'gtools' as normal, i.e make instead of gmake
PATH="/usr/local/opt/make/libexec/gnubin:$PATH"

# GIT completion, among others
is.mac && [[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"

