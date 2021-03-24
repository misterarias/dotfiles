# vi: ft=sh ts=2 sw=2
[ -f ~/.bash_local_aliases ] && source ~/.bash_local_aliases

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
export LESS="--RAW-CONTROL-CHARS"

# DDAMNDED WARNING
export BASH_SILENCE_DEPRECATION_WARNING=1

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
[ -f "${HOME}/.ghcup/env" ] && source "${HOME}/.ghcup/env" # ghcup-env

# CAREFUL
eval "$(direnv hook bash)"

export SDKMAN_DIR="${HOME}/.sdkman"
# shellcheck source=/dev/null
[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"

# PATH=$(brew --prefix)/opt/python/libexec/bin:$PATH

eval "$(thefuck --alias)"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
