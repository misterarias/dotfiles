#!/bin/bash
# Copies of system files will be kept here
BACKUP_FOLDER="${HOME}/backup"

# return the absolute path of a local file
dotfiles_absolute() {
  local file=$1
  echo "$(cd "$(dirname "$file")" && pwd)/$(basename "$file")"
}

# Easily choose the link method between a symbolic link or a copy
dotfiles_link() {
  local local_dotfile system_dotfile
  local_dotfile=$(dotfiles_absolute "$1")
  system_dotfile="$2"

  [ ! -d "$BACKUP_FOLDER" ] && mkdir -p "$BACKUP_FOLDER"

  # save a copy of the system file, if it is not a link already
  readlink "$system_dotfile" >/dev/null && \
    mv "$system_dotfile" "$BACKUP_FOLDER" > /dev/null 2>&1
  ln -sf "$local_dotfile" "$system_dotfile"
}

setup_git() {
  install_git_delta
  green "Setting up some git defaults..."
  while read -r line ; do

    blue "$line"
    section=$(echo "$line" | cut -d" " -f1)
    value=$(echo "$line" | cut -d" " -f2-)

    git config --global "$section" "$value"
  done < .gitconfig

  printf "\n%s\n" "Remember to execute: ${GREENCOLOR_BOLD}git config --global user.email <YOUR_EMAIL>${ENDCOLOR}"
}

setup_vim() {
  ! command -v vim > /dev/null &&
    red "You don't have VIM installed.... you suck" && return

  VIMDIR=~/.vim
  green "Setting up VIM in ${VIMDIR}..."
  rm -rf "${VIMDIR}/bundle"
  mkdir -p "${VIMDIR}/tmp" "${VIMDIR}/backup" "${VIMDIR}/colors" > /dev/null 2>&1
  cp .vim/colors/monokai.vim "${VIMDIR}/colors/"
  git clone https://github.com/gmarik/Vundle.vim ${VIMDIR}/bundle/Vundle.vim
  dotfiles_link .vimrc ~/.vimrc
  vim +PluginInstall +qall
}

install_git_delta() {
  if ! command -v delta >/dev/null ; then
    if is.mac ; then
      brew install git-delta
     elif is.debian ; then
      sudo apt install -y git-delta
    elif is.arch ; then
      sudo pacman -S --noconfirm  git-delta
    else
      error "Don't know how to install delta"
    fi
  fi
  git config --global core.pager delta

  ! grep -q '[delta "interactive"]' ~/.gitconfig && cat >> ~/.gitconfig <<EOF
[interactive]
    diffFilter = delta --color-only --features=interactive

[delta]
    features = decorations

[delta "interactive"]
    keep-plus-minus-markers = false

[delta "decorations"]
    commit-decoration-style = blue ol
    commit-style = raw
    file-style = omit
    hunk-header-decoration-style = blue box
    hunk-header-file-style = red
    hunk-header-line-number-style = "#067a00"
    hunk-header-style = file line-number syntax
EOF

  green "Git 'delta' installed successfully"
}

install_bat() {
  if command -v bat >/dev/null ;then
    return
  elif is.mac ; then
    brew install bat
   elif is.debian ; then
    sudo apt install -y bat
  elif is.arch ; then
    sudo pacman -S --noconfirm  bat
  else
    error "Don't know how to install bat"
  fi
}

install_fd() {
  if command -v fd >/dev/null ;then
    return
  elif is.mac ; then
    brew install fd
   elif is.debian ; then
    sudo apt install -y fd-find
  elif is.arch ; then
    sudo pacman -S --noconfirm  fd
  else
    error "Don't know how to install fd"
  fi
}

install_pyenv() {
  if command -v pyenv >/dev/null ;then
    return
  elif is.mac ; then
    brew install pyenv
    brew install pyenv-virtualenv
  else
    curl https://pyenv.run | bash
    export PATH="${HOME}/.pyenv/bin:$PATH"
    git clone https://github.com/pyenv/pyenv-virtualenv.git "$(pyenv root)/plugins/pyenv-virtualenv"
  fi
}

install_fzf() {
  if ! command -v fzf >/dev/null ; then
    if is.mac ; then
      brew install fzf
    elif is.debian ; then
      sudo apt install fzf
    elif is.arch ; then
      sudo pacman -S --noconfirm  fzf
    else
      error "Don't know how to install fzf"
    fi
  fi
  install_fd
  install_bat
}

# batt management
install_acpi() {
  if command -v acpi >/dev/null ;then
    return
  elif is.debian ; then
    sudo apt install acpi
  elif is.arch ; then
    sudo pacman -S --noconfirm acpi
  else
    error "Don't know how to install acpi"
  fi
}

install_autocompletion() {
  if is.mac ; then
    brew install bash-completion
    return
  elif is.debian ; then
    sudo apt install  bash-completion
  elif is.arch ; then
    sudo pacman -S bash-completion
  else
    error "Don't know how to install bash completion"
  fi
}

install_direnv() {
  if command -v direnv >/dev/null ; then
    return
  elif is.mac ;then
    brew install direnv
  elif is.debian ; then
    sudo apt install direnv
  elif is.arch ; then
    curl -sfL https://direnv.net/install.sh | bash
  else
    error "Don't know how to install direnv"
    return
  fi
  dotfiles_link direnvrc ~/.direnvrc
}

setup_dotfiles() {
  green "Setting up bash dotfiles..."
  touch ~/.bash_profile # in case it does not exist..
  [ "$(grep -c "\. ~/.bashrc" ~/.bash_profile)" -ne 1 ] && cat .bash_profile  >> ~/.bash_profile

  # Install pre-requisites for powerline and pyenv
  install_fzf
  install_pyenv
  install_autocompletion
  install_direnv

  # Powerline package and config
  pip3 install powerline-shell
  mkdir -p "${HOME}/.config"
  [ ! -d "${HOME}/.config/powerline-shell" ] && \
    cp -a ./powerline-shell "${HOME}/.config/powerline-shell"

  is.mac && brew install git bash-completion
  ! is.mac && install_acpi

  dotfiles_link .bashrc ~/.bashrc
  dotfiles_link .bash_local_aliases ~/.bash_local_aliases
  [ ! -f ~/.bash_private_vars ] && \
    dotfiles_link .bash_private_vars ~/.bash_private_vars && \
    printf "\nCreated sample %s file, edit it and modify %s var to enable 'repo' command autocompletion.\n" "${BLUECOLOR_BOLD}~/.bash_private_vars${ENDCOLOR}" "${REDCOLOR}_REPO_AUTOCOMPLETE_BASE_DIR${ENDCOLOR}"

  dotfiles_link .fzf.bash ~/.fzf.bash

  # shellcheck source=/dev/null
  . ~/.bash_profile

  green "New functions and aliases installed"
  # blue "type 'my_commands' to check them out!"
}

setup_ruby() {
  [ ! -f ~/.irbrc ] && return
  green "Setting up some Ruby defaults..."
  ! grep -q 'irb/completion' ~/.irbrc && \
    echo "require 'irb/completion'" >> ~/.irbrc
}

setup_postgres() {
  [ ! -f ~/.psqlrc ] && return
  green "Setting up some PostgreSQL defaults..."
  dotfiles_link .psqlrc ~/.psqlrc
}

setup_configs() {
  command -v terminator >/dev/null  && \
    green "Setting my terminator config..." && \
    mkdir -p "$HOME/.config/terminator" && \
    dotfiles_link .config/terminator/config "$HOME/.config/terminator/config"
}

# Lots of fancy functions here:
# shellcheck source=/dev/null
source .bash_local_aliases

setup_all() {
  setup_vim
  setup_dotfiles
  setup_git
  setup_postgres
  setup_ruby
  setup_configs
  setup_binaries
}


setup_binaries() {
  green "Copying 'useful' binaries..."

  # I like this, it's the same used by 'pip install --user'
  bin_dir="${HOME}/.local/bin"
  mkdir -p "${bin_dir}"
  cp -v ./bin/* "${bin_dir}"
  chmod +x "${bin_dir}/"*
}

mode=${1:-all}
case "${mode}" in
  all)      setup_all ;;
  vim)      setup_vim ;;
  dotfiles) setup_dotfiles ;;
  git)      setup_git ;;
  postgres) setup_postgres ;;
  ruby)     setup_ruby ;;
  configs)  setup_configs ;;
  binaries) setup_binaries ;;
  test)     run_tests;;
  help|*)
    blue "setup.sh"
    echo "One-time, not-interactive setup for optimal CLI - by Juan Arias"
    echo ; echo "Args:"
    echo "* [no args] - Default option, installs everything in one go"
    echo "* vim       - installs my .vimrc file and most useful Plugins using Vundle (requires vim)"
    echo "* dotfiles  - installs my .bash* files, including Prompt and Aliases"
    echo "* git       - Some useful git aliases"
    echo "* postgres  - Basically a simple .psqlrc file"
    echo "* ruby      - Small improvement over default irb config"
    echo "* configs   - For now, only some terminator tweaks (requires Linux && terminator)"
    echo "* binaries  - Installs some useful binaries for everyday use"
    echo "* test      - Runs locally installed test-battery"
    echo "* help      - this message"
    echo && exit 0
    ;;
esac

green "Everything is done, enjoy!"
