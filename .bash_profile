# .bash_profile
# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

export PATH=$HOME/bin:$PATH

LANG="en_US.UTF-8"
LC_ALL=$LANG
echo -e "Setting LANG=$GREENCOLOR_BOLD$LANG$ENDCOLOR"
