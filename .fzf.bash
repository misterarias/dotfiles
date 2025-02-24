# Setup fzf
# ---------
if [[ ! "$PATH" == *.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}${HOME}/.fzf/bin"
fi

eval "$(fzf --bash)"
