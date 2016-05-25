#!/bin/bash
BOLD=$(tput bold)
BLUECOLOR=$(tput setaf 4)
REDCOLOR=$(tput setaf 1)
GREENCOLOR=$(tput setaf 2)
WHITECOLOR=$(tput setaf 7)
BLUECOLOR_BOLD=$BLUECOLOR$BOLD
REDCOLOR_BOLD=$REDCOLOR$BOLD
GREENCOLOR_BOLD=$GREENCOLOR$BOLD
WHITECOLOR_BOLD=$WHITECOLOR$BOLD
ENDCOLOR=$(tput sgr0)

error() {
  echo "[ERROR] $@"
  exit 1
}

setup.git() {
  echo -e "${GREENCOLOR}Setting up some git defaults.....${ENDCOLOR}"
  while read line ; do 
    echo -e "${BLUECOLOR}${line}${ENDCOLOR}"
    section=$(echo $line | cut -d" " -f1)
    value=$(echo $line | cut -d" " -f2-)

    git config --global "$section" "$value"
  done < .gitconfig
}

setup.vim() {
  VIMDIR=~/.vim
  echo -e "${GREENCOLOR}Setting up VIM in ${VIMDIR} ...${ENDCOLOR}"
  rm -rf ${VIMDIR}/bundle
  mkdir -p ${VIMDIR}/tmp ${VIMDIR}/backup ${VIMDIR}/colors > /dev/null 2>&1 
  cp .vim/colors/monokai.vim ${VIMDIR}/colors/
  git clone https://github.com/gmarik/Vundle.vim ${VIMDIR}/bundle/Vundle.vim
  cp .vimrc ~/.vimrc
  vim +PluginInstall +qall
}

setup.dotfiles() {
  echo -e "${GREENCOLOR}Setting up bashrc.....${ENDCOLOR}"
  [[ $(grep -c "\. ~/.bashrc" ~/.bash_profile) -ne 1 ]] && cat >> ~/.bash_profile << _EOF 
# Get the aliases and functions
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi
_EOF
  cp .bashrc ~/.bashrc
  cp .bash_local_aliases ~/.bash_local_aliases
  . ~/.bash_profile
}

setup.postgres() {
  echo -e "${GREENCOLOR}Setting up some PostgreSQL defaults.....${ENDCOLOR}"
  cp .psqlrc ~/.psqlrc
}

setup.configs() {
  echo -e "${GREENCOLOR}Setting up some environment-specific configs.....${ENDCOLOR}"
  case "$ENV_TYPE" in
    "prod")
      ;;
    "dev-server")
      ;;
    "local")
      ln -sf $PWD/.config/terminator/config $HOME/.config/terminator/config
      ;;
  esac
}

# local       -> one of my computers, where I'd like to use Terminator, pretty nice colors, and the likes [DEFAULT]
# dev-server  -> a remote development computer, no local configs are needed (such as terminator)
# prod        -> a production environment, where I most probably don't need fancy colors, just some basics
setup.env() {
  ENV_TYPE="$1"
  if [ -z "$ENV_TYPE" ] ; then
    ENV_TYPE="local" # not using a bash default above, so the message is more explicit
    echo -e "${GREENCOLOR}No environment specified, defaulting to: ${ENDCOLOR}${BLUECOLOR_BOLD}${ENV_TYPE}${ENDCOLOR}"
  else 
    case "$ENV_TYPE" in
      prod|dev-server|local)
        ;;
      *)
        error "Invalid environment selected '${REDCOLOR_BOLD}$ENV_TYPE${ENDCOLOR}'"
    esac
    echo -e "${GREENCOLOR}Environment set to: ${ENDCOLOR}${BLUECOLOR_BOLD}${ENV_TYPE}${ENDCOLOR}"
  fi
  export ENV_TYPE
}

setup.env $@
setup.vim
setup.dotfiles
setup.git
setup.postgres
setup.configs

echo -e "${GREENCOLOR_BOLD}Everything is done, enjoy!${ENDCOLOR}"
