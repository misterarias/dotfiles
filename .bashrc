# .bashrc
#ft=sh; ts=2; sw=2

# Bash Aliases
if [ -f ~/.bash_local_aliases ]; then
  # shellcheck source=/dev/null
	. ~/.bash_local_aliases
fi

# Bash completion location depends on OS
# shellcheck source=/dev/null
[ -f "$(_get_bash_completion)" ] && . "$(_get_bash_completion)"

# git completion
[ ! -f ~/.git-completion ] && \
    curl http://git.kernel.org/cgit/git/git.git/plain/contrib/completion/git-completion.bash?id=HEAD > ~/.git-completion

# shellcheck source=/dev/null
. ~/.git-completion

# show help on custom commands
my_commands() {
  local alias_filter="alias .*"
  local function_filter='^[a-z][a-z._]\+()'
  for aliases in ${HOME}/.bash_local_aliases $HOME/.bash_private_aliases ; do
    [ ! -f "${aliases}" ] && continue
    printf  "\n%s%s%s:\n\n" "${GREENCOLOR_BOLD}" "${aliases}" "${ENDCOLOR}"
    grep -B1 -e "${alias_filter}" "$aliases" | sed -e 's#=.*##' -e 's#.*alias ##'  -e 's#--##g' \
      -e "s/^\([a-z._]*\)$/${REDCOLOR_BOLD}\1${ENDCOLOR}/g"

    printf "\n"

    # Do not show functions starting with '_'
    grep -B1 -e "${function_filter}" "$aliases" | sed -e 's#().*##g' -e 's#--##g' \
        -e "s/^\([a-z._]*\)$/${REDCOLOR_BOLD}\1${ENDCOLOR}/g"
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
    is.repo && echo "$PROMPT_COMMAND" | grep -q -o __git_ps1 && \
      job_number=$((job_number - 3))
    if [ ${job_number} -gt 0 ] ; then
      printf "(%d) " "${job_number}"
    else
      printf ""
    fi
}

# For MacOSX only :(
function __battery_state() {
  local LOW_THRESHOLD=25
  local HIGH_THRESHOLD=65
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

# Some color codes
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

function __manage_prompt() {

  local DISPLAY_BATTERY_LEVEL=1
  [ ! -z "${DISPLAY_BATTERY_LEVEL}" ] && \
    local BATT="\$(__battery_state)"
  # local WHO="\[${BLUECOLOR_BOLD}\][\h]\[${ENDCOLOR}\]"
  local WHEN="\[${BLUECOLOR_BOLD}\]\t\[${ENDCOLOR}\]"
  local WHERE="\[${WHITECOLOR_BOLD}\]\w\[${ENDCOLOR}\]"
  local JOBS="\[${REDCOLOR}\]\$(__jobs)\[${ENDCOLOR}\]"
  local SEPARATOR=" "
  local PS2='> '

  local AWS_PROFILE_SHOW='$([ ! -z "$AWS_PROFILE" ] && echo "\[${GREENCOLOR_BOLD}\]aws: $AWS_PROFILE \[${ENDCOLOR}\]")'
  local VENV_SHOW='$([ ! -z "$VIRTUAL_ENV" ] && echo "(venv: $(basename $VIRTUAL_ENV)) ")'
  local PROMPT_SYMBOL='$ '

  # For git prompt (download with: curl https://raw.github.com/git/git/master/contrib/completion/git-prompt.sh -o ~/.   git-prompt.sh)
  local USE_GIT_PROMPT=1
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
    export GIT_PS1_DESCRIBE_STYLE=branch
    #export GIT_PS1="\[${BLUECOLOR}\]\$(__git_ps1)\[${ENDCOLOR}\]"
    #PS1=${BATT}${JOBS}${WHEN}${SEPARATOR}${WHERE}${SEPARATOR}${GIT_PS1}\\n${PROMPT_SYMBOL}
    PROMPT_INFO=${JOBS}${AWS_PROFILE_SHOW}${BATT}${WHEN}${SEPARATOR}${WHERE}
    SYMBOL="\\n${VENV_SHOW}${PROMPT_SYMBOL}"
    GIT=' [%s]'

    export PROMPT_COMMAND='__git_ps1 "${PROMPT_INFO}" "${SYMBOL}" "${GIT}"'
  else
    export PROMPT_COMMAND='echo -en "\033]0;$(whoami)$(__jobs)@${PWD}\a"'
  fi

  if [ -z "${USE_RIGHT_COLUMN}" ] ; then
    function __rightprompt() {
      printf "%*s" ${COLUMNS} "$(date +"%D %T")";
    }

    START_RIGHT_COLUMN=$(tput sc)
    END_RIGHT_COLUMN=$(tput rc)
    RIGHTPROMPT="${START_RIGHT_COLUMN}${GREENCOLOR}\$(__rightprompt)${ENDCOLOR}${END_RIGHT_COLUMN}"
    PS1=${RIGHTPROMPT}${PS1}
  fi

  [ ! -z "${PS1}" ] && export PS1
}
__manage_prompt

# I want cores
ulimit -c unlimited

# Careful with messages (David Hasselhoff bombing is real)
[ ! -z "$(which mesg)" ] && mesg n

# Useful fore everything: bash, git, postgres...
export EDITOR=vim
export PSQL_EDITOR='vim -c"set syntax=sql"'
