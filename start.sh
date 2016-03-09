#!/bin/bash

REDCOLOR=$(tput setaf 1)
GREENCOLOR=$(tput setaf 2)
ENDCOLOR=$(tput sgr0)

# First of all, setup VIM
VIMDIR=~/.vim
echo -e "${GREENCOLOR}Setting up VIM in ${VIMDIR} ...${ENDCOLOR}"
rm -rf ${VIMDIR}/bundle
mkdir -p ${VIMDIR}/tmp ${VIMDIR}/backup ${VIMDIR}/colors > /dev/null 2>&1 
cp .vim/colors/monokai.vim ${VIMDIR}/colors/
git clone https://github.com/gmarik/Vundle.vim ${VIMDIR}/bundle/Vundle.vim
cp .vimrc ~/.vimrc
vim +PluginInstall +qall

# Next, setup session dotfiles
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

# Some git basics
echo -e "${GREENCOLOR}Setting up some git defaults.....${ENDCOLOR}"
git config --global user.name 'Juan Arias'
git config --global rerere.enabled true
git config --global color.ui true

# Done!
echo -e "${REDCOLOR}Everything is done, enjoy!${ENDCOLOR}"
