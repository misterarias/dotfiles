#!/bin/bash

REDCOLOR=$(tput setaf 1)
GREENCOLOR=$(tput setaf 2)
BLUECOLOR=$(tput setaf 4)
ENDCOLOR=$(tput sgr0)

setup.git() {
  while read line ; do 
    echo -e "${BLUECOLOR}${line}${ENDCOLOR}"
    section=$(echo $line | cut -d" " -f1)
    value=$(echo $line | cut -d" " -f2-)

    git config --global "$section" "$value"
  done < .gitconfig
}

setup.vim() {
  VIMDIR=~/.vim
  rm -rf ${VIMDIR}/bundle
  mkdir -p ${VIMDIR}/tmp ${VIMDIR}/backup ${VIMDIR}/colors > /dev/null 2>&1 
  cp .vim/colors/monokai.vim ${VIMDIR}/colors/
  git clone https://github.com/gmarik/Vundle.vim ${VIMDIR}/bundle/Vundle.vim
  cp .vimrc ~/.vimrc
  vim +PluginInstall +qall
}

setup.dotfiles() {
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

# First of all, setup VIM
echo -e "${GREENCOLOR}Setting up VIM in ${VIMDIR} ...${ENDCOLOR}"
setup.vim

# Next, setup session dotfiles
echo -e "${GREENCOLOR}Setting up bashrc.....${ENDCOLOR}"
setup.dotfiles

# Some git basics
echo -e "${GREENCOLOR}Setting up some git defaults.....${ENDCOLOR}"
setup.git

# PostgreSQL client defaults
echo -e "${GREENCOLOR}Setting up some PostgreSQL defaults.....${ENDCOLOR}"
cp .psqlrc ~/.psqlrc

# Ubuntu/Debian configs
echo -e "${GREENCOLOR}Setting up some specific configs.....${ENDCOLOR}"
ln -sf $PWD/.config/terminator/config $HOME/.config/terminator/config

# Done!
echo -e "${REDCOLOR}Everything is done, enjoy!${ENDCOLOR}"
