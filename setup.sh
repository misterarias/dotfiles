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

dotfiles_error() {
  echo "[ERROR] $*"
  exit 1
}

setup_git() {
  echo "${GREENCOLOR}Setting up some git defaults.....${ENDCOLOR}"
  while read -r line ; do

    echo "${BLUECOLOR}${line}${ENDCOLOR}"
    section=$(echo "$line" | cut -d" " -f1)
    value=$(echo "$line" | cut -d" " -f2-)

    git config --global "$section" "$value"
  done < .gitconfig
}

setup_vim() {
  [ ! -x vim ] && \
    echo "You don't have VIM installed.... you suck" && return

  VIMDIR=~/.vim
  echo "${GREENCOLOR}Setting up VIM in ${VIMDIR} ...${ENDCOLOR}"
  rm -rf "${VIMDIR}/bundle"
  mkdir -p "${VIMDIR}/tmp" "${VIMDIR}/backup" "${VIMDIR}/colors" > /dev/null 2>&1
  cp .vim/colors/monokai.vim "${VIMDIR}/colors/"
  git clone https://github.com/gmarik/Vundle.vim ${VIMDIR}/bundle/Vundle.vim
  dotfiles_link .vimrc ~/.vimrc
  vim +PluginInstall +qall
}

setup_dotfiles() {
  echo "${GREENCOLOR}Setting up bash dotfiles_....${ENDCOLOR}"
  touch ~/.bash_profile # in case it does not exist..
  [ "$(grep -c "\. ~/.bashrc" ~/.bash_profile)" -ne 1 ] && cat .bash_profile  >> ~/.bash_profile

  dotfiles_link .bashrc ~/.bashrc
  dotfiles_link .bash_local_aliases ~/.bash_local_aliases

  # shellcheck source=/dev/null
  . ~/.bash_profile 2>&1 > /dev/null

  printf "\nNew functions and aliases installed, type '%s' tp check them out!\n" "${BLUECOLOR_BOLD}my_commands${ENDCOLOR}"
}

setup_ruby() {
  [ ! -f ~/.irbrc ] && return
  echo "${GREENCOLOR}Setting up some Ruby defaults.....${ENDCOLOR}"
  ! grep -q 'irb/completion' ~/.irbrc && \
    echo "require 'irb/completion'" >> ~/.irbrc
}

setup_postgres() {
  [ ! -f ~/.psqlrc ] && return
  echo "${GREENCOLOR}Setting up some PostgreSQL defaults.....${ENDCOLOR}"
  dotfiles_link .psqlrc ~/.psqlrc
}

setup_configs() {
  echo "${GREENCOLOR}Setting up some environment-specific configs.....${ENDCOLOR}"
  case "$ENV_TYPE" in
    "prod")
      ;;
    "dev-server")
      ;;
    "local")
      mkdir -p "$HOME/.config/terminator"
      dotfiles_link .config/terminator/config "$HOME/.config/terminator/config"
      ;;
  esac
}

# local       -> one of my computers, where I'd like to use Terminator, pretty nice colors, and the likes [DEFAULT]
# dev-server  -> a remote development computer, no local configs are needed (such as terminator)
# prod        -> a production environment, where I most probably don't need fancy colors, just some basics
setup_env() {
  ENV_TYPE="$1"
  if [ -z "$ENV_TYPE" ] ; then
    ENV_TYPE="local" # not using a bash default above, so the message is more explicit
    echo "${GREENCOLOR}No environment specified, defaulting to: ${ENDCOLOR}${BLUECOLOR_BOLD}${ENV_TYPE}${ENDCOLOR}"
  else
    case "$ENV_TYPE" in
      prod|dev-server|local)
        ;;
      *)
        dotfiles_error "Invalid environment selected '${REDCOLOR_BOLD}$ENV_TYPE${ENDCOLOR}'"
    esac
    echo "${GREENCOLOR}Environment set to: ${ENDCOLOR}${BLUECOLOR_BOLD}${ENV_TYPE}${ENDCOLOR}"
  fi
  export ENV_TYPE
}

setup-gnome-extensions() {
  # If not in Linux, just get out:
  is.mac && return

  # Maybe gnome stuff is not set up correctly
  [ ! -x gnome-shell-extension-installer ] && return
  [ ! -x gnome-shell ] && return

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

setup-repo-change-script() {
  autocomplete_route="$(_get_bash_completion)"
  [ ! -f "${autocomplete_route}" ] && \
    echo "Bash auto-completion not installed, or not found in '${autocomplete_route}', refusing to install repo autocomplete" && return

  # I instead of symlinking because I want to keep the original file versioned
  cp -f ./files/repo "${autocomplete_route}.d/"

  printf "\nAutocompletion for the %s command has been installed.\nRun it once to configure it, and then %s.\n" \
    "${BLUECOLOR_BOLD}repo${ENDCOLOR}" "${REDCOLOR_BOLD}START A NEW SHELL${ENDCOLOR}"
}

# Lots of fancy functions here:
# shellcheck source=/dev/null
source .bash_local_aliases

setup_env "$@"
setup_vim
setup_dotfiles
setup_git
setup_postgres
setup_ruby
setup_configs
setup-gnome-extensions
setup-repo-change-script

printf "\n%s\n" "${GREENCOLOR_BOLD}Everything is done, enjoy!${ENDCOLOR}"
