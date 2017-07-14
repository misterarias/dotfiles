# .bashrc

# 'Darwin' for Mac, 'Linux' or similar elsewhere
is_mac() {
  [ "$(uname -s)" == "Darwin" ]
}

# Bash completion
# shellcheck source=/dev/null
is_mac && [ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion
# shellcheck source=/dev/null
! is_mac && [ -f /etc/bash_completion ] && . /etc/bash_completion

# git completion
if [ ! -f ~/.git-completion ]; then
    curl http://git.kernel.org/cgit/git/git.git/plain/contrib/completion/git-completion.bash?id=HEAD > ~/.git-completion
fi
# shellcheck source=/dev/null
. ~/.git-completion

# show help on custom commands
my_commands() {
  for aliases in ${HOME}/.bash_local_aliases $HOME/.bash_private_aliases ; do
    [ ! -f "${aliases}" ] && continue
    printf  "\n%s%s%s (%s)\n\n" "${GREENCOLOR_BOLD}" "Custom aliases:" "${ENDCOLOR}" "${aliases}"
    grep -B1 -e 'alias ' "$aliases" |  sed -e 's@.*alias \(.*\)=.*@\1@g'

    printf "\n%s%s%s (%s)\n\n" "${GREENCOLOR_BOLD}" "Local functions:" "${ENDCOLOR}" "${aliases}"
    grep -B1 -e '^[a-z_]\+()' "$aliases" | grep -v '^_' | sed -e 's#\(.*\)(.*#\1#g'
  done
}

#sets up some colors
is_mac && export CLICOLOR=1

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

function __jobs() {
    job_number=$(jobs | wc -l | tr -d '' )
    is_repo && echo "$PROMPT_COMMAND" | grep -q -o __git_ps1 && \
      job_number=$((job_number - 3))
    if [ ${job_number} -gt 0 ] ; then
      printf "(%d) " "${job_number}"
    else
      printf ""
    fi
}

# For MacOSX only :(
function __battery_state() {
  LOW_THRESHOLD=25
  HIGH_THRESHOLD=65
  if is_mac ; then
    state=$(pmset -g batt)
    discharging=$(echo "$state" | grep discharging)
    percentage=$(echo "$state" | grep -o "[0-9]*%" | tr -d '%')
    if [ ! -z "$discharging" ] ; then
      if [ "${percentage}" -gt ${HIGH_THRESHOLD} ] ; then
        batt="${GREENCOLOR}${percentage}%${ENDCOLOR}"
      elif [ "${percentage}" -gt ${LOW_THRESHOLD} ] ; then
        batt="${YELLOWCOLOR}${percentage}%${ENDCOLOR}"
      else
        batt="${REDCOLOR_BOLD}${percentage}%${ENDCOLOR}"
      fi
    else
      # while charging, only show while it's kind of low
      if [ "${percentage}" -lt ${HIGH_THRESHOLD} ] ; then
        batt="${YELLOWCOLOR_BOLD}${percentage}%${ENDCOLOR}"
      fi
    fi
    [ ! -z "${batt}" ] && echo "${batt} "
  fi
}

BOLD=$(tput bold)
REDCOLOR=$(tput setaf 1)
GREENCOLOR=$(tput setaf 2)
YELLOWCOLOR=$(tput setaf 3)
BLUECOLOR=$(tput setaf 4)
WHITECOLOR=$(tput setaf 7)
BLUECOLOR_BOLD=${BLUECOLOR}${BOLD}
REDCOLOR_BOLD=${REDCOLOR}${BOLD}
GREENCOLOR_BOLD=${GREENCOLOR}${BOLD}
WHITECOLOR_BOLD=${WHITECOLOR}${BOLD}
YELLOWCOLOR_BOLD=${YELLOWCOLOR}${BOLD}
ENDCOLOR=$(tput sgr0)

DISPLAY_BATTERY_LEVEL=1
[ ! -z "${DISPLAY_BATTERY_LEVEL}" ] && BATT="\$(__battery_state)"
#WHO="\[${BLUECOLOR_BOLD}\][\h]\[${ENDCOLOR}\]"
WHEN="\[${BLUECOLOR_BOLD}\]\t\[${ENDCOLOR}\]"
WHERE="\[${WHITECOLOR_BOLD}\]\w\[${ENDCOLOR}\]"
JOBS="\[${REDCOLOR_BOLD}\]\$(__jobs)\[${ENDCOLOR}\]"
SEPARATOR=" "
PS2='> '

PROMPT_SYMBOL='$(if [ ! -z "$VIRTUAL_ENV" ] ; then echo "(venv: $(basename $VIRTUAL_ENV)) $ " ; else echo "$ " ; fi)'

# For git prompt (download with: curl https://raw.github.com/git/git/master/contrib/completion/git-prompt.sh -o ~/.   git-prompt.sh)
USE_GIT_PROMPT=1
if [ ${USE_GIT_PROMPT} -eq 1 ] ; then
  if [ ! -f ~/.git-prompt.sh ]; then
    curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh -o ~/.git-prompt.sh
  fi

  # shellcheck source=/dev/null
  source  ~/.git-prompt.sh

  # Enable for small repos or local (non NFS mounted) connections
  export GIT_PS1_SHOWDIRTYSTATE=1
  export GIT_PS1_SHOWUNTRACKEDFILES=1
  export GIT_PS1_SHOWUPSTREAM="auto verbose"
  export GIT_PS1_SHOWCOLORHINTS=true
  #export GIT_PS1="\[${BLUECOLOR}\]\$(__git_ps1)\[${ENDCOLOR}\]"
  #PS1=${BATT}${JOBS}${WHEN}${SEPARATOR}${WHERE}${SEPARATOR}${GIT_PS1}\\n${PROMPT_SYMBOL}
  export PROMPT_COMMAND='__git_ps1 "${BATT}${JOBS}${WHEN}${SEPARATOR}${WHERE}" "\\n${PROMPT_SYMBOL}" " [%s]"'
else
  export PROMPT_COMMAND='echo -en "\033]0;$(whoami)$(__jobs)@${PWD}\a"'
fi


if [ "x" = "x${USE_RIGHT_COLUMN} " ] ; then
  function __rightprompt() {
    printf "%*s" ${COLUMNS} "$(date +"%D %T")";
  }

  START_RIGHT_COLUMN=$(tput sc)
  END_RIGHT_COLUMN=$(tput rc)
  RIGHTPROMPT="${START_RIGHT_COLUMN}${GREENCOLOR}\$(__rightprompt)${ENDCOLOR}${END_RIGHT_COLUMN}"
  PS1=${RIGHTPROMPT}${PS1}
fi

[ ! -z "${PS1}" ] && export PS1

# I want cores
ulimit -c unlimited

# Careful with messages (David Hasselhoff bombing is real)
[ ! -z "$(which mesg)" ] && mesg n

# Useful fore everything: bash, git, postgres...
EDITOR=vim
export EDITOR
export PSQL_EDITOR='vim -c"set syntax=sql"'

# Bash Aliases
if [ -f ~/.bash_local_aliases ]; then
  # shellcheck source=/dev/null
	. ~/.bash_local_aliases
fi
#ft=sh; ts=2; sw=2
