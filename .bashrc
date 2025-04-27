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

# source wrapper
__source() {
  [ -z "${__TIMINGS_ENABLED}" ] && source "${1}" && return
  [ -f "${1}" ] && __time_cmd source "${1}" && return
  error "Cannot source '${1}': File not found"
}

__get_timing_date() {
  date '+%s.%N'
}

__get_timing_diff() {
  start_timer="$1"
  end_timer="$2"
  echo "scale=3; ${end_timer} - ${start_timer}" | bc | LC_NUMERIC=C awk '{printf "%.3f\n", $1}'
  #env LC_ALL=en_US.UTF-8 printf "%'.3f\n" "${diff}"
}

__time_cmd() {
  _tmp_file="/tmp/_timing_$(echo "$@" | cksum | awk '{print $1}')"
  __get_timing_date > "$_tmp_file"

  "$@"
  _tmp_file="/tmp/_timing_$(echo "$@" | cksum | awk '{print $1}')"
  _start=$(cat "$_tmp_file")
  _end="$(__get_timing_date)"
  _diff=$(__get_timing_diff "${_start}" "${_end}")
  printf "[TIMING] - %-72s - %s\n" "${*}" "${_diff}ms"
  rm "$_tmp_file"
}

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

# enable all
enable.fzf
enable.pyenv
enable.npm
