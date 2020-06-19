# .bashrc
#ft=sh; ts=2; sw=2

# Bash Aliases
if [ -f ~/.bash_local_aliases ]; then
  # shellcheck source=/dev/null
  source ~/.bash_local_aliases
fi

# Bash completion location depends on OS
# shellcheck source=/dev/null
[ -f "$(_get_bash_completion)" ] && . "$(_get_bash_completion)"

# show help on custom commands
my_commands() {
  alias_filter="alias .*"
  function_filter='^[a-z][a-z._]\+()'
  for aliases in ${HOME}/.bash_local_aliases $HOME/.bash_private_aliases ; do
    [ ! -f "${aliases}" ] && continue
    printf  "\n%s%s%s:\n\n" "${GREEN}${BOLD}" "${aliases}" "${ENDCOLOR}"
    grep -B1 -e "${alias_filter}" "$aliases" | sed -e 's#=.*##' -e 's#.*alias ##'  -e 's#--##g' \
      -e "s/^\([a-z._]*\)$/${RED}${BOLD}\1${ENDCOLOR}/g"

    printf "\n"

    # Do not show functions starting with '_'
    grep -B1 -e "${function_filter}" "$aliases" | sed -e 's#().*##g' -e 's#--##g' \
        -e "s/^\([a-z._]*\)$/${RED}${BOLD}\1${ENDCOLOR}/g"
  done
}

__present() {
  printf "(%s)" "$*"
}

# Be careful with background stuff such as Z, or git
__jobs() {
  local job_number=$(jobs | \grep -v -E '(git|_z)' | wc -l | tr -d ' ')
  if [ ${job_number} -gt 0 ] ; then
    __present "${job_number}"
  else
    printf ""
  fi
}


__battery_status() {
  if ! is.mac ; then
    state=$(acpi)
    discharging=$(echo "$state" | grep remaining)
  else
    state=$(pmset -g batt)
    discharging=$(echo "$state" | grep discharging)
  fi
  echo "$discharging"
}

__battery_level() {
  if ! is.mac ; then
    state=$(acpi)
  else
    state=$(pmset -g batt)
  fi
  echo "$state" | grep -o "[0-9]*%" | tr -d '%'
}

__display_battery_state() {
  set -e
  local LOW_THRESHOLD=25 HIGH_THRESHOLD=65 state discharging percentage batt
  percentage=$(__battery_level)
  discharging=$(__battery_status)
  if [ ! -z "$discharging" ] ; then
    if [ "${percentage}" -gt ${HIGH_THRESHOLD} ] ; then
      batt="${GREEN}${BOLD}${percentage}%${ENDCOLOR}"
    elif [ "${percentage}" -gt ${LOW_THRESHOLD} ] ; then
      batt="${YELLOW}${BOLD}${percentage}%${ENDCOLOR}"
    else
      batt="${RED}${BOLD}${percentage}%${ENDCOLOR}"
    fi
  else
    # while charging, only show while it's kind of low
    if [ "${percentage}" -lt ${HIGH_THRESHOLD} ] ; then
      batt="${YELLOW}${BOLD}${percentage}%${ENDCOLOR}"
    fi
  fi
  [ ! -z "${batt}" ] && echo "${batt}"
}

# Some color codes
##BOLD=$(tput bold)
##RED=$(tput setaf 1)
##GREEN=$(tput setaf 2)
##YELLOW=$(tput setaf 3)
##BLUE=$(tput setaf 4)
##MAGENTA=$(tput setaf 5)
##CYAN=$(tput setaf 6)
##WHITE=$(tput setaf 7)
##ENDCOLOR=$(tput sgr0)

DISPLAY_BATTERY_LEVEL=0
[ ! -z "${DISPLAY_BATTERY_LEVEL}" ] && \
  #BATT="\$(__display_battery_state)" && \
  export BATT_LEVEL_VALUE=$(__battery_level) && \
  export BATT_STATUS=$(__battery_status)

# SEPARATOR=" "
##PS2='> '
##WHEN='\[${BLUE}${BOLD}\]$(date +%H:%M)\[${ENDCOLOR}\]'
###WHERE='$([ $? -eq 0 ] && echo ''[${WHITE}'' || echo ''[${RED}'')${BOLD}\]\w\[${ENDCOLOR}\]'
##WHERE='\[${WHITE}${BOLD}\]\w\[${ENDCOLOR}\]'
##JOBS='\[${RED}\]$(__jobs)\[${ENDCOLOR}\]'
##AWS_PROFILE_SHOW='$([ ! -z "$AWS_PROFILE" ] && echo "\[${CYAN}\]$(__present aws:${AWS_PROFILE})\[${ENDCOLOR}\]")'
##VENV_SHOW='$([ ! -z "$VIRTUAL_ENV" ] && echo "\[${MAGENTA}\]$(__present venv:$(basename $VIRTUAL_ENV))\[${ENDCOLOR}\]")'
##GIT='${GREEN}(git:%s)${ENDCOLOR}'
##PROMPT_SYMBOL='$ '
##
##PROMPT_INFO="${BATT}${WHEN}${SEPARATOR}${WHERE}${SEPARATOR}${JOBS}${VENV_SHOW}${AWS_PROFILE_SHOW}"
##SYMBOL="\\n${PROMPT_SYMBOL}"

CUSTOMIZE_GIT_PROMPT=no
[ "yes" == "${CUSTOMIZE_GIT_PROMPT}" ] && \
  PS1="${PROMPT_INFO}${SYMBOL}"

USE_GIT_PROMPT=no
if [ "yes" == "${USE_GIT_PROMPT}" ] ; then
  # For git prompt (download with: curl https://raw.github.com/git/git/master/contrib/completion/git-prompt.sh -o ~/.   git-prompt.sh)
  if [ ! -f ~/.git-prompt.sh ]; then
    curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh -o ~/.git-prompt.sh
  fi

  # Enable for small repos or (non NFS mounted) connections
  export GIT_PS1_SHOWDIRTYSTATE=1
  export GIT_PS1_SHOWUNTRACKEDFILES=1
  export GIT_PS1_SHOWUPSTREAM="auto verbose"
  #export GIT_PS1_SHOWCOLORHINTS=true
  export GIT_PS1_HIDE_IF_PWD_IGNORED=true
  export GIT_PS1_STATESEPARATOR=" "
  export GIT_PS1_DESCRIBE_STYLE=branch
  unset GIT_PS1_SHOWCOLORHINTS

  # shellcheck source=/dev/null
  source  ~/.git-prompt.sh
  export PROMPT_COMMAND='__git_ps1 "${PROMPT_INFO}" "${SYMBOL}" "${GIT}"'
else
  unset PROMPT_COMMAND GIT_PS1_SHOWDIRTYSTATE GIT_PS1_SHOWUNTRACKEDFILES GIT_PS1_SHOWUPSTREAM GIT_PS1_SHOWCOLORHINTS GIT_PS1_HIDE_IF_PWD_IGNORED GIT_PS1_STATESEPARATOR GIT_PS1_DESCRIBE_STYLE
  export PS1
fi

# My custom stuff
export PATH=$HOME/bin:$PATH
export PATH=$HOME/.local/bin:$PATH

export LANG="en_US.UTF-8"
export LC_ALL=$LANG

# Used by '/usr/local/etc/bash_completion/repo'
export _REPO_AUTOCOMPLETE_BASE_DIR=/Users/juanito/Stuff

# Bind the Tab key to the menu-complete command instead of the default complete
bind '"\C-i": menu-complete'

# Display a list of the matching files
bind "set show-all-if-ambiguous on"

# Perform partial completion on the first Tab press,
# only start cycling full results on the second Tab press
bind "set menu-complete-display-prefix on"

export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"
export PATH=$PATH:$GOBIN  #/usr/local/opt/go/libexec/bin

#sets up some colors
is.mac && export CLICOLOR=1

export LSCOLORS=gxfxcxdxbxegedabagacad

#enables color for iTerm
export TERM=xterm-color

export GREP_COLOR="01;34"

# don't put duplicate lines in the history
# don't save commands which start with a space
export HISTCONTROL=ignoredups:erasedups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
export HISTSIZE=10000
export HISTFILESIZE=100000

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
export LESS="--RAW-CONTROL-CHARS"

# I want cores
ulimit -c unlimited

# Useful for everything: bash, git, postgres...
export EDITOR=vim
export PSQL_EDITOR='vim -c"set syntax=sql"'

# Pycharm bug when using gevent
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

# Rust Package manager
export PATH="$HOME/.cargo/bin:$PATH"

# Python BREW path
#export PATH="/usr/local/opt/python@3.8/bin:$PATH"
#alias python=python3
#alias pip=pip3

# Pyenv goodness
export PYENV_ROOT=${HOME}/.venvs
export PATH="${HOME}/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# direnv + virtualenvs
#show_virtual_env() { :; }
#export -f show_virtual_env
# PS1='$(show_virtual_env)'$PS1

# Depends on 'pip install powerline-shell'
function _update_ps1() {
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
# This introduces the SIGINT trap error: eval "$(direnv hook bash)"
