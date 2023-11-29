#!/usr/bin/env bash
# vi: ft=sh ts=2 sw=2
# shellcheck source=/dev/null

# Set default shell mode to VIM, fuck emacs
set -o emacs  # sorry pal

# Nice defaults
export PS1="$ "
export PROMPT_COMMAND=

# If left empty, pyenv is not loaded by default, freeing up resources
export __ENABLE_PYENV=

[ -f ~/.bash_local_aliases ] && . ~/.bash_local_aliases

if [ -n "${__ENABLE_PYENV}" ] ; then  enable.pyenv ; else  green "pyenv disabled by environment variable, type enable.pyenv to enable locally" ; fi

# DO NOT VERSION THIS!!! THANKS
[ -f ~/.bash_private_vars ] && source ~/.bash_private_vars

# Locale select
export LANG="es_ES.UTF-8"

# My local binaries path
export PATH="$HOME/.local/bin:$PATH"

# Allow system PIP packages to be found
export PATH="$HOME/Library/Python/3.9/bin:$PATH"

# MacVIM's own vim
export PATH="~/Apps/MacVim.app/Contents/bin:$PATH"

# Add non-sudo homebrew path
export PATH="$HOME/.homebrew/bin:$PATH"

# At the very least, colours in MAC
export CLICOLOR=1

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
export LESS="--RAW-CONTROL-CHARS"

# DAMNDED WARNING
export BASH_SILENCE_DEPRECATION_WARNING=1

# Should enable timings
export __TIMINGS_ENABLED=
__start_timing() {
  [ -z "${__TIMINGS_ENABLED}" ] && return
  __START_TIMER=$(date '+%s')
  export __START_TIMER
}
__end_timing() {
  [ -z "${__TIMINGS_ENABLED}" ] && return
  sot="${1?:operation}"
  end_timer=$(date '%s')
  echo "${sot} took $(( end_timer - __START_TIMER ))ms"
  unset __START_TIMER
}

# I want cores
ulimit -c unlimited

# Useful for everything: bash, git, postgres...
export EDITOR=vim
export PSQL_EDITOR='vim -c"set syntax=sql"'

# Pycharm bug when using gevent
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

# Enable bash to cycle through completions (https://superuser.com/a/59198)
[[ $- = *i* ]] && bind TAB:menu-complete

# Options for autocompletion
bind "set show-all-if-ambiguous on"
bind "set completion-ignore-case on"
bind "set menu-complete-display-prefix on"

# git autocompletion
source ~/.git-completion.bash

export ENABLE_RAW_POWERLINE=1
if [ -n "${ENABLE_RAW_POWERLINE}" ] ; then
  export POWERLINE_ROOT="$(pip show powerline-status | grep Location | awk '{print $2}')/powerline"
  powerline-daemon -q
  export POWERLINE_BASH_CONTINUATION=1
  export POWERLINE_BASH_SELECT=1
  . "${POWERLINE_ROOT}/bindings/bash/powerline.sh"
else
  # Depends on 'pip install powerline-shell'
  _update_ps1() {
      PS1=$(powerline-shell $?)
  }

  if [[ $TERM != linux && ! $PROMPT_COMMAND =~ _update_ps1 ]]; then
      PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
  fi
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

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
