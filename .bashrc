#!/usr/bin/env bash
#ft=sh; ts=2; sw=2

# Bash Aliases
if [ -f ~/.bash_local_aliases ]; then
  # shellcheck source=/dev/null
  . ~/.bash_local_aliases
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

#export GREP_COLOR="01;34"

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
#ulimit -c unlimited

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

# Enable a pyenv-powered virtualenv via direnv
venv.create() {
  [ -f ".envrc" ]  && echo "[INFO] .envrc already exists, ignoring..." && return
  [ -z "$1" ] && error "No python version specified as parameter" && return

  version=$1
  valid_versions="$(pyenv  versions | grep -e '^\s*[23]\.' | cut -d '/' -f1 | sort -u | tr -d ' ' | xargs)"
  [ -z "$(echo "${valid_versions}" | grep -o "${version}")" ] && \
    error "No valid Python version specified, choose one of: ${valid_versions}" && return

  cat > .envrc << EOF
pyversion=${version}
pvenv=\$(basename \$PWD)

use python \${pyversion}
layout virtualenv \${pyversion} \${pvenv}
layout activate \${pvenv}-\${pyversion}
unset PS1
EOF
  direnv allow
  echo "Done!"
}

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
[ -f "/Users/juanito/.ghcup/env" ] && source "/Users/juanito/.ghcup/env" # ghcup-env

#AWSume alias to source the AWSume script
alias awsume=". \$(pyenv which awsume)"

#Auto-Complete function for AWSume
_awsume() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts=$(awsume-autocomplete)
    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
    return 0
}
complete -F _awsume awsume


export SDKMAN_DIR="/Users/juanito/.sdkman"
# shellcheck source=/dev/null
[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"

eval "$(thefuck --alias)"
