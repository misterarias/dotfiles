# .bashrc

# 'Darwin' for Mac, 'Linux' or similar elsewhere
ARCH=$(uname -s)

# Bash completion
if [ -f /etc/bash_completion ] ; then
	. /etc/bash_completion
elif [ -f /usr/local/etc/bash_completion ] ; then
	. /usr/local/etc/bash_completion
fi

# git completion
if [ ! -f ~/.git-completion ]; then
    curl http://git.kernel.org/cgit/git/git.git/plain/contrib/completion/git-completion.bash?id=HEAD > ~/.git-completion
fi
. ~/.git-completion

#sets up some colors
if [ $ARCH == "Darwin" ] ; then
	export CLICOLOR=1
fi
export LSCOLORS=gxfxcxdxbxegedabagacad

#enables color for iTerm
export TERM=xterm-color

export GREP_COLOR="01;34"

export LANG=en_US.UTF8
export LC_ALL=en_US.UTF8
export LC_CTYPE=en_US.UTF8
export LANGUAGE=en_US.UTF8

# don't put duplicate lines in the history
# don't save commands which start with a space
HISTCONTROL=ignoredups:erasedups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=100000

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
export LESS="--RAW-CONTROL-CHARS"

BOLD=$(tput bold)
BLUECOLOR=$(tput setaf 4)
REDCOLOR=$(tput setaf 1)
GREENCOLOR=$(tput setaf 2)
WHITECOLOR=$(tput setaf 7)
export BLUECOLOR_BOLD=$BLUECOLOR$BOLD
export REDCOLOR_BOLD=$REDCOLOR$BOLD
export GREENCOLOR_BOLD=$GREENCOLOR$BOLD
export WHITECOLOR_BOLD=$WHITECOLOR$BOLD
ENDCOLOR=$(tput sgr0)
SEPARATOR="::"
PROMPT=' $ '

function __jobs() {
    JOB_NUMBER=$(jobs | egrep -c "^\[[0-9]+\]")
    if [ "${JOB_NUMBER}" -gt 0 ] ; then
      printf "(%d)" "$JOB_NUMBER"
    else
        printf ""
    fi
}

WHO="\[$REDCOLOR_BOLD\][\h]\[$ENDCOLOR\]"
WHEN="\[$GREENCOLOR\]\t\[$ENDCOLOR\]"
WHERE="\[$BLUECOLOR_BOLD\]\w\[$ENDCOLOR\]"
JOBS="\[$REDCOLOR_BOLD\]\$(__jobs)\[$ENDCOLOR\]"

# For git prompt (download with: curl https://raw.github.com/git/git/master/contrib/completion/git-prompt.sh -o ~/.   git-prompt.sh)
USE_GIT_PROMPT=1
if [ $USE_GIT_PROMPT -eq 1 ] ; then
  if [ ! -f ~/.git-prompt.sh ]; then
    curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh -o ~/.git-prompt.sh
  fi
  source  ~/.git-prompt.sh
  # Enable for small repos or local (non NFS mounted) connections
  export GIT_PS1_SHOWDIRTYSTATE=1
  export GIT_PS1_SHOWUNTRACKEDFILES=1
  export GIT_PS1="\[$GREENCOLOR_BOLD\]\$(__git_ps1)\[$ENDCOLOR\]"
  export SEPARATOR=" "
  export PS1=$WHO$WHEN$SEPARATOR$WHERE$SEPARATOR$GIT_PS1\\n$JOBS$PROMPT
  #export PS1=$WHO$SEPARATOR$WHERE$JOBS$GIT_PS1$PROMPT
else
  export PS1=$WHO$WHEN$SEPARATOR$WHERE$JOBS$GIT_PS1$PROMPT
fi

# This sets the tab title:
PROMPT_COMMAND='echo -en "\033]0;$(whoami)$(__jobs)@$PWD\a"'

# I want cores
ulimit -c unlimited

# Careful with messages (David Hasselhoff bombing is real)
[ ! -z $(which mesg) ] && mesg n

# Useful fore everything: bash, git, postgres...
EDITOR=vim
export EDITOR
export PSQL_EDITOR='vim -c"set syntax=sql"'

# show help on custom commands
my_commands() {
  local me="$HOME/.bash_local_aliases"

  printf  "\n${GREENCOLOR_BOLD}Custom aliases:${ENDCOLOR}\n\n"
  grep alias "$me" | sed -e "s@^alias \([^=]\+\)='\(.*\)'@\1:\n\t\2\n@g"

  printf  "\n${GREENCOLOR_BOLD}Local functions:${ENDCOLOR}\n\n"
  grep -B1 -e '^[a-z_]\+()' "$me" | sed -e 's/^-\+//g' | sed -e 's/()\s\+{//g'
}

# Bash Aliases
if [ -f ~/.bash_local_aliases ]; then
	. ~/.bash_local_aliases
fi

# Add profile info (beware of redirections)
if [ -z $loaded_bash_profile ] && [ -f ~/.bash_profile ] ; then
  export loaded_bash_profile=1
	. ~/.bash_profile
fi
unset loaded_bash_profile

#ft=sh; ts=2; sw=2
