#!/usr/bin/env bash
# vi: ft=sh ts=2 sw=2
# shellcheck source=/dev/null

# Set default shell mode to VIM, fuck emacs
set -o vi
#set -o emacs  # sorry pal

# Nice defaults
export PS1="$ "
export PROMPT_COMMAND=

# If left empty, pyenv is not loaded by default, freeing up resources
export __ENABLE_PYENV=

# If left empty, npm is not loaded by default, freeing up resources
export __ENABLE_NPM=1

# Locale select
export LANG="es_ES.UTF-8"

# My local binaries path
export PATH="$HOME/.local/bin:$PATH"

# Allow system PIP packages to be found
export PATH="$HOME/Library/Python/3.9/bin:$PATH"

# Add (non-sudo) homebrew path
#export PATH="$HOME/.homebrew/bin:$PATH"
export HOMEBREW_PREFIX="/opt/homebrew";
export HOMEBREW_CELLAR="/opt/homebrew/Cellar";
export HOMEBREW_REPOSITORY="/opt/homebrew";
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin${PATH+:$PATH}";
export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:";
export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}";

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

# Pycharm bug when using gevent
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

export ENABLE_RAW_POWERLINE=1
if [ -n "${ENABLE_RAW_POWERLINE}" ] ; then
  POWERLINE_ROOT="$(pip show powerline-status | grep Location | awk '{print $2}')/powerline"
  #POWERLINE_ROOT="/Users/e053375/.pyenv/versions/3.12.0/lib/python3.12/site-packages/powerline"
  export POWERLINE_ROOT
  powerline-daemon -q
  export POWERLINE_BASH_CONTINUATION=1
  export POWERLINE_BASH_SELECT=1
  _POWERLINE_EXECTIME_TIMER_START="$(date +%s)"
  . "${POWERLINE_ROOT}/bindings/bash/powerline.sh"
  # POWERLINE_EXTENSIONS="${HOME}/.config/powerline/extensions"
  #. "${POWERLINE_EXTENSIONS}/powerline-exectime/bindings/bash/powerline-exectime.sh"
fi

[ -f ~/.bash_local_aliases ] && . ~/.bash_local_aliases

if [ -n "${__ENABLE_PYENV}" ] ; then  enable.pyenv ; else  green "pyenv disabled by environment variable, type enable.pyenv to enable locally" ; fi
if [ -n "${__ENABLE_NPM}" ] ; then  enable.npm ; else  green "npm disabled by environment variable, type enable.npm to enable locally" ; fi


# DO NOT VERSION THIS!!! THANKS
[ -f ~/.bash_private_vars ] && source ~/.bash_private_vars

# Enable bash to cycle through completions (https://superuser.com/a/59198)
#[[ $- = *i* ]] && bind TAB:menu-complete

# Options for autocompletion
#bind "set show-all-if-ambiguous on"
#bind "set completion-ignore-case on"
#bind "set menu-complete-display-prefix on"
bind "set colored-completion-prefix on"
bind "set colored-stats on"
# Alternative would be ~/.inputrc
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# git autocompletion
source ~/.git-completion.bash

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


# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/e053375/Downloads/google-cloud-sdk/path.bash.inc' ]; then . '/Users/e053375/Downloads/google-cloud-sdk/path.bash.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/e053375/Downloads/google-cloud-sdk/completion.bash.inc' ]; then . '/Users/e053375/Downloads/google-cloud-sdk/completion.bash.inc'; fi

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

