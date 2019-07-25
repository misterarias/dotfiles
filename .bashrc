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

# git completion is installed with 'brew install git bash-completion'
if ! is.mac ; then
  [ ! -f ~/.git-completion ] && \
      curl http://git.kernel.org/cgit/git/git.git/plain/contrib/completion/git-completion.bash?id=HEAD > ~/.git-completion
  # shellcheck source=/dev/null
  . ~/.git-completion
fi

# My custom stuff
export PATH=$HOME/.local/bin:$PATH

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

__present() {
  printf "(%s)" "$*"
}

__jobs() {
  local job_number=$(jobs | \grep -v git | wc -l | tr -d ' ')
  if [ ${job_number} -gt 0 ] ; then
    __present "${job_number}"
  else
    printf ""
  fi
}

__battery_state() {
  local LOW_THRESHOLD=25 HIGH_THRESHOLD=65 state discharging percentage batt
  if ! is.mac ; then
    state=$(acpi)
    discharging=$(echo "$state" | grep remaining)
  else
    state=$(pmset -g batt)
    discharging=$(echo "$state" | grep discharging)
  fi
  percentage=$(echo "$state" | grep -o "[0-9]*%" | tr -d '%')
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
  [ ! -z "${batt}" ] && echo "${batt} "
}

# Some color codes
BOLD=$(tput bold)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
ENDCOLOR=$(tput sgr0)

DISPLAY_BATTERY_LEVEL=1
[ ! -z "${DISPLAY_BATTERY_LEVEL}" ] && BATT="\$(__battery_state)"
SEPARATOR=" "
PS2='> '
WHEN='\[${BLUE}${BOLD}\]$(date +%H:%M)\[${ENDCOLOR}\]'
WHERE='\[${WHITE}${BOLD}\]\w\[${ENDCOLOR}\]'
JOBS='\[${RED}\]$(__jobs)\[${ENDCOLOR}\]'
AWS_PROFILE_SHOW='$([ ! -z "$AWS_PROFILE" ] && echo "\[${CYAN}\]$(__present aws:${AWS_PROFILE})\[${ENDCOLOR}\]")'
VENV_SHOW='$([ ! -z "$VIRTUAL_ENV" ] && echo "\[${MAGENTA}\]$(__present venv:$(basename $VIRTUAL_ENV))\[${ENDCOLOR}\]")'
#GIT='${GREEN}(git:%s)${ENDCOLOR}'
GIT='${GREEN}(git:%s)${ENDCOLOR}'
PROMPT_SYMBOL='$ '

PROMPT_INFO="${BATT}${WHEN}${SEPARATOR}${WHERE}${SEPARATOR}${JOBS}${VENV_SHOW}${AWS_PROFILE_SHOW}"
SYMBOL="\\n${PROMPT_SYMBOL}"
PS1="${PROMPT_INFO}${SYMBOL}"

USE_GIT_PROMPT=yes
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

# I want cores
ulimit -c unlimited

# Useful for everything: bash, git, postgres...
export EDITOR=vim
export PSQL_EDITOR='vim -c"set syntax=sql"'
