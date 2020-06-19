#!/bin/bash
BOLD=$(tput bold)
BLUECOLOR=$(tput setaf 4)
REDCOLOR=$(tput setaf 1)
GREENCOLOR=$(tput setaf 2)
BLUECOLOR_BOLD=$BLUECOLOR$BOLD
REDCOLOR_BOLD=$REDCOLOR$BOLD
GREENCOLOR_BOLD=$GREENCOLOR$BOLD
ENDCOLOR=$(tput sgr0)

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
  echo && echo "${GREENCOLOR}Setting up some git defaults.....${ENDCOLOR}"
  while read -r line ; do

    echo "${BLUECOLOR}${line}${ENDCOLOR}"
    section=$(echo "$line" | cut -d" " -f1)
    value=$(echo "$line" | cut -d" " -f2-)

    git config --global "$section" "$value"
  done < .gitconfig

  printf "\n%s\n" "Remember to execute: ${GREENCOLOR_BOLD}git config --global user.email <YOUR_EMAIL>${ENDCOLOR}"
}

setup_vim() {
  ! command -v vim > /dev/null &&
    echo "You don't have VIM installed.... you suck" && return

  VIMDIR=~/.vim
  echo && echo "${GREENCOLOR}Setting up VIM in ${VIMDIR} ...${ENDCOLOR}"
  rm -rf "${VIMDIR}/bundle"
  mkdir -p "${VIMDIR}/tmp" "${VIMDIR}/backup" "${VIMDIR}/colors" > /dev/null 2>&1
  cp .vim/colors/monokai.vim "${VIMDIR}/colors/"
  git clone https://github.com/gmarik/Vundle.vim ${VIMDIR}/bundle/Vundle.vim
  dotfiles_link .vimrc ~/.vimrc
  vim +PluginInstall +qall
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
  if command -v fzf >/dev/null ;then
    return
  elif is.mac ; then
    brew install fzf
  elif is.debian ; then
    sudo apt install fzf
  elif is.arch ; then
    sudo pacman -S --noconfirm  fzf
  else
    error "Don't know how to install fzf"
  fi
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
  elif is.debian ; then
    sudo apt install  bash-completion
  elif is.arch ; then
    sudo pacman -S bash-completion
  else
    echo "Don't know how to install bash completion"
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
    echo "Don't know how to install direnv"
  fi
}

setup_dotfiles() {
  echo && echo "${GREENCOLOR}Setting up bash dotfiles_....${ENDCOLOR}"
  touch ~/.bash_profile # in case it does not exist..
  [ "$(grep -c "\. ~/.bashrc" ~/.bash_profile)" -ne 1 ] && cat .bash_profile  >> ~/.bash_profile

  # Install pre-requisites for powerline and pyenv
  install_fzf
  install_fd
  install_pyenv
  install_autocompletion
  install_direnv
  pip3 install powerline-shell

  is.mac && brew install git bash-completion
  ! is.mac && install_acpi

  dotfiles_link .bashrc ~/.bashrc
  dotfiles_link .bash_local_aliases ~/.bash_local_aliases
  dotfiles_link .fzf-bash ~/.fzf.bash

  # shellcheck source=/dev/null
  . ~/.bash_profile

  printf "\nNew functions and aliases installed, type '%s' tp check them out!\n" "${BLUECOLOR_BOLD}my_commands${ENDCOLOR}"
}

setup_ruby() {
  [ ! -f ~/.irbrc ] && return
  echo && echo "${GREENCOLOR}Setting up some Ruby defaults.....${ENDCOLOR}"
  ! grep -q 'irb/completion' ~/.irbrc && \
    echo "require 'irb/completion'" >> ~/.irbrc
}

setup_postgres() {
  [ ! -f ~/.psqlrc ] && return
  echo "${GREENCOLOR}Setting up some PostgreSQL defaults.....${ENDCOLOR}"
  dotfiles_link .psqlrc ~/.psqlrc
}

setup_configs() {
  command -v terminator >/dev/null  && \
    echo && echo "${GREENCOLOR}Setting my terminator config...${ENDCOLOR}" && \
    mkdir -p "$HOME/.config/terminator" && \
    dotfiles_link .config/terminator/config "$HOME/.config/terminator/config"
}

setup_gnome_extensions() {
  # If not in Linux, just get out:
  is.mac && return

  # Maybe gnome stuff is not set up correctly
  ! command -v gnome-shell-extension-installer > /dev/null && return
  ! command -v gnome-shell >/dev/null && return

  # Download magnificent and already-created script for shell extension's management
  if [ ! -f "$HOME/bin/gnome-shell-extension-installer" ] ; then
    mkdir -p "$HOME/bin"
    curl -qsS https://raw.githubusercontent.com/brunelli/gnome-shell-extension-installer/master/gnome-shell-extension-installer -o "$HOME/bin/gnome-shell-extension-installer"
    chmod +x "$HOME/bin/gnome-shell-extension-installer"
  fi

  # Install my main extensions
  gnome-shell-extension-installer 307 3.18 # Dash to dock
  gnome-shell-extension-installer 112 3.18 # remove accesibility
  gnome-shell-extension-installer 613 3.14 # Weather
  gnome-shell-extension-installer 545  # Hide top bar
  gnome-shell-extension-installer 442 3.20 # Dropdown terminal

  # restart shell - the ampersand is mandatory
  gnome-shell --replace &
}

# Lots of fancy functions here:
# shellcheck source=/dev/null
source .bash_local_aliases

setup_all() {
  #setup_vim
  setup_dotfiles
  setup_git
  setup_postgres
  setup_ruby
  setup_configs
  setup_gnome_extensions
  setup_binaries
}

_DEPRECATED() {
  echo "${REDCOLOR_BOLD}DEPRECATED${ENDCOLOR} - $*"
}

setup_binaries() {
  echo && echo "${GREENCOLOR}Copying 'useful' binaries....${ENDCOLOR}"

  # I like this, it's the same used by 'pip install --user'
  bin_dir="${HOME}/.local/bin"
  mkdir -p "${bin_dir}"
  cp -v ./bin/* "${bin_dir}"
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
  gnome)    _DEPRECATED setup_gnome_extensions ;;
  repo)     setup_rep,o_change_script ;;
  test)     run_tests;;
  help|*)
    echo && echo "${GREENCOLOR_BOLD}setup.sh${ENDCOLOR}"
    echo "One-time, not-interactive setup for optimal CLI - by Juan Arias"
    echo ; echo "Args:"
    echo "* [no args] - Default option, installs everything in one go"
    echo "* vim       - installs my .vimrc file and most useful Plugins using Vundle (requires vim)"
    echo "* dotfiles  - installs my .bash* files, including Prompt and Aliases"
    echo "* git       - Some useful git aliases"
    echo "* postgres  - Basically a simple .psqlrc file"
    echo "* ruby      - Small improvement over default irb config"
    echo "* configs   - For now, only some terminator tweaks (requires Linux && terminator)"
    echo "* gnome     - Installs some really useful Gnome addons (requires Gnome 3.x)"
    echo "* binaries  - Installs some useful binaries for everyday use"
    echo "* repo      - If you have a lot of repos, you'll love this"
    echo "* test      - Runs locally installed test-battery"
    echo "* help      - this message"
    echo && exit 0
    ;;
esac

printf "\n%s\n" "${GREENCOLOR_BOLD}Everything is done, enjoy!${ENDCOLOR}"
