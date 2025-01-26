# Setup fzf
# ---------
if [[ ! "$PATH" == */home/juanito/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/juanito/.fzf/bin"
fi

eval "$(fzf --bash)"
