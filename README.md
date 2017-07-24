# My dotfiles

This little project serves as a quick shortcut in order to start a new development environment as fast as possible

Currently tested in MacOS X, CentOs, Debian and Ubuntu.

## Usage

Just exec `$ setup.sh` and magic happens.

### Tweaks

* If you want to change default prompt to be less verbose and not show git state, change appropriate flag in .bashrc
* List of gnome extensions to install has to be modified in the script, I don't want to add config files yet.

## [Gnome Desktop only]

I now use the Gnome shell extension installer from [here](https://github.com/brunelli/gnome-shell-extension-installer) to automate
the installation of some of my most-used extensions

# Bash completion scripts

I have added a bash-completion script for the new `repo` command, installable with setup.
Upon installation and first use, it allows to automatically navigate a certain _repo dir_ with
autocomplete
