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

# Allow system PIP packages to be found
# export PATH="$HOME/Library/Python/3.9/bin:$PATH"

# At the very least, colours in MAC
export CLICOLOR=1

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
export LESS="--RAW-CONTROL-CHARS"

# DAMNED WARNING
export BASH_SILENCE_DEPRECATION_WARNING=1

# source wrapper
__source() {
  [ -f "${1}" ] && __time_cmd source "${1}" && return
  error "Cannot source '${1}': File not found"
}

__get_timing_date() {
  date '+%s.%N'
}

__get_timing_diff() {
  start_timer="$1"
  end_timer="$2"
  diff=$(echo "${end_timer} - ${start_timer}" | bc --leading-zeroes)
  env LC_ALL=en_US.UTF-8 printf "%'.3f\n" "${diff}"
}

__time_cmd() {
  [ -z "${__TIMINGS_ENABLED}" ] && $* && return

  _tmp_file="/tmp/_timing_$(echo $* | cksum | awk '{print $1}')"
  __get_timing_date > $_tmp_file

  $*
  _tmp_file="/tmp/_timing_$(echo $* | cksum | awk '{print $1}')"
  _start=$(cat $_tmp_file)
  _end="$(__get_timing_date)"
  _diff=$(__get_timing_diff "${_start}" "${_end}")
  printf "[TIMING] - %-72s - %s\n" "${*}" "${_diff}ms"
  rm $_tmp_file
}

# I want cores
# ulimit -c unlimited

# Pycharm bug when using gevent
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

enable.fzf() {
  echo $PATH | grep -q fzf || export PATH="~/.fzf/bin:$PATH"

  if ! command -v fzf >/dev/null ; then return ; fi

  preload_fzf() {
    [ -n "${_FZF_LOADED}" ] && return
    export _FZF_LOADED=1
    [ -f ~/.fzf.bash ] && source ~/.fzf.bash
  }
  alias fzf='preload_fzf; fzf'

  # FZF Custom vars and functions
  FZF_OPTS="--layout=reverse"
  FZF_OPTS="${FZF_OPTS}  --info=hidden"
  FZF_OPTS="${FZF_OPTS} --height=60%"
  FZF_BORDER="--border=none --margin=0,1"
  FZF_COLOR="\
    --color=dark \
    --color=preview-bg:#e8e8e8 \
    "
  export FZF_DEFAULT_OPTS="${FZF_OPTS} ${FZF_COLOR} ${FZF_BORDER}"
  export FZF_DEFAULT_COMMAND="fd --type f  --color=auto -H"
  __FZF_PREVIEW_COMMAND() {
    fzf $FZF_DEFAULT_OPTS --preview '~/.fzf/bin/fzf-preview.sh {}' --preview-window 'right,border-none,60%,<70(bottom,60%,border-top)'
  }

  # filetype-based handler
  __open() {
    [ -z "$1" ] && error "No file to open" && return
    file=${1/#\~\//$HOME/}
    [ -d "$file" ] && cd "$file" && return
    [ ! -f "$file" ] && error "$file is not a valid file"
    type="$(file --dereference --mime "$file")"
    if [[ ! $type =~ image/ ]] && [[ ! $type =~ =binary ]]; then vim "$file" ; else file "$file" ; fi
  }

  # vim's latest files
  __vim_latest() {
    local _FILE
    _FILE="/tmp/.vim$RANDOM"
    vim +":redir > ${_FILE} | oldfiles | redir END" +":q!"
    __open $(cat $_FILE | grep -v '^$' | awk '{print $2}' | __FZF_PREVIEW_COMMAND) || rm  ${_FILE}
  }
  alias vim.latest='__vim_latest'

  # time-based finders
  __finder() {
    $FZF_DEFAULT_COMMAND --changed-within "$1" . $HOME | __FZF_PREVIEW_COMMAND
  }
  alias c.h='__open $(__finder 1h)'
  alias c.d='__open $(__finder 1d)'
  alias c.w='__open $(__finder 7d)'
  alias c.m='__open $(__finder 30d)'

  __list_repos() {
    fd -H --maxdepth 2 --min-depth 2 --type d . "$_REPO_AUTOCOMPLETE_BASE_DIR/"
  }

  # Automagically autocomplete repo names and 'cd' into them. Needs a proper base repo dir. Depends on fzf and fd
  repo() {
    local regex
    base_dir="${_REPO_AUTOCOMPLETE_BASE_DIR}"
    [ -d "$*" ] && cd "$*" && return
    [ $# -gt 0 ] && regex=$(echo "$*" | sed -E 's# +#.*#g')
    [ "${regex}" != "" ] && [ -d "${base_dir}/${regex}" ] && cd "${base_dir}/${regex}" && return

    repo="$(__list_repos | grep -i "${regex}" | __FZF_PREVIEW_COMMAND)"
    if [ -z "${repo}" ] ; then error "No results" ; else cd "${repo}" ; fi
  }

  _repo() {
    _get_comp_words_by_ref cur prev

    base_dir="${_REPO_AUTOCOMPLETE_BASE_DIR}"
    [ "${prev}" = "repo" ] && prev=""
    regex="${prev} ${cur}"
    regex="${regex// /.*}"
    if [ -d "${base_dir}/${regex}" ] ; then
      COMPREPLY=$( compgen -W "${base_dir}/${regex}" )
    elif __list_repos | grep -iq "${regex}"  ; then
      COMPREPLY=$( compgen -W "$(fd --maxdepth 2 --type d . "${base_dir}" | grep -i "${regex}" | __FZF_PREVIEW_COMMAND)"  )
    fi
  }
  complete -F _repo repo

  # git greps and offers vim to open a result
  ggrep() {
    [ -z "$1" ] && error "Cannot search nothing...."
    local matches

    matches=$(git grep -i "$@" | cut -d":" -f1 | sort -u | __FZF_PREVIEW_COMMAND)
    [ -z "${matches}" ] && error "No matches for '$*'" && return
    vim +/"$1" "${matches}"
  }

  # git greps and opens all results
  gopen() {
    [ -z "$1" ] && error "Cannot search nothing...."

    local matches

    matches=$(git grep -i "$@" | cut -d":" -f1 | sort | xargs)
    [ -z "${matches}" ] && error "No matches for '$*'" && return
    vim +/"$1" ${matches}
  }

  # Vim + fzf
  fim() {
    local matches
    if [ $# -gt 0 ] ; then
      matches=$(fd --hidden --type file | grep -i "$1" | __FZF_PREVIEW_COMMAND)
    else
      matches="$(__FZF_PREVIEW_COMMAND)"
    fi
    [ -n "${matches}" ] && vim "${matches}"
  }
}

. ~/.bash_local_aliases
. ~/.bash_private_vars

# Add (non-sudo) homebrew path
#export PATH="$HOME/.homebrew/bin:$PATH"
if is.mac ; then
  export HOMEBREW_PREFIX="/opt/homebrew";
  export HOMEBREW_CELLAR="/opt/homebrew/Cellar";
  export HOMEBREW_REPOSITORY="/opt/homebrew";
  export PATH="/opt/homebrew/bin:/opt/homebrew/sbin${PATH+:$PATH}";
  export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:";
  export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}";
fi

enable.npm
enable.fzf
enable.sdkman

# Enable bash to cycle through completions (https://superuser.com/a/59198)
[[ $- = *i* ]] && bind TAB:menu-complete
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

# Add this AFTER any prompt-manipulating extensions: https://direnv.net/docs/hook.html
_direnv_hook() {
  local previous_exit_status=$?;
  direnv_out=$(direnv export bash)
  if [[ -n $direnv_out ]]; then
    eval "$direnv_out"
  fi
  return $previous_exit_status
}

if ! [[ "${PROMPT_COMMAND:-}" =~ _direnv_hook ]]; then
  PROMPT_COMMAND="_direnv_hook${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
fi
## # This introduces the SIGINT trap error: eval "$(direnv hook bash)"
## #
## #__source "${HOME}/.ghcup/env" # ghcup-env
## #__source '/Users/e053375/Downloads/google-cloud-sdk/path.bash.inc'
## #__source '/Users/e053375/Downloads/google-cloud-sdk/completion.bash.inc'
##
# bash autocompletion
if is.debian ; then
  __source /etc/bash_completion
elif is.mac ; then
  __source /opt/homebrew/etc/profile.d/bash_completion.sh
fi

# git autocompletion
__source ~/.git-completion.bash

# testing starship
command -v starship &> /dev/null && eval "$(starship init bash)"
