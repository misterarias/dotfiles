#!/bin/bash

#set -o errexit
#set -o nounset
set -o pipefail

# Copies of system files will be kept here
BACKUP_FOLDER="${HOME}/.backup"
[ ! -d "$BACKUP_FOLDER" ] && mkdir -p "$BACKUP_FOLDER"

# Temporary crap
PIPFILE_LIST="$(mktemp -d)/piplistfile"

# return the absolute path of a local file
abspath() {
    local file=$1
    echo "$(cd "$(dirname "$file")" && pwd)/$(basename "$file")"
}

# Easily choose the link method between a symbolic link or a copy
dotfiles_link() {
    local_dotfile="$(abspath "$1")"
    system_dotfile_dir="$(dirname "$2")"
    [ ! -d "${system_dotfile_dir}" ] && \
        mkdir -p "${system_dotfile_dir}"

    system_dotfile="$(abspath "$2")"

    # save a copy of the system file, if it is not a link already
    if readlink "$system_dotfile" >/dev/null ; then
        mv "$system_dotfile" "$BACKUP_FOLDER" > /dev/null 2>&1 || true
    fi
    ln -sf "$local_dotfile" "$system_dotfile"
    blue "${local_dotfile} ---> ${system_dotfile}"
}

__install_git() {
    # ¿ubuntu not likey? if command -v git > /dev/null ; then
    if [ -n "$(which git)" ] ; then
        return
    elif is.mac ; then
        error "Install git using XCode Developer tools"
    elif is.debian ; then
        sudo apt install -y git
    elif is.arch ; then
        sudo pacman -S --noconfirm  git
    else
        error "Don't know how to install 'git'"
    fi
}

setup_git() {
    __install_git
    __install_git_delta
    __install_autocompletion

    green "Setting up some git defaults..."
    while read -r line ; do
        section=$(echo "$line" | cut -d" " -f1)
        value=$(echo "$line" | cut -d" " -f2-)

        git config --global "$section" "$value"
    done < .gitconfig

  # This is now configured in core.excludesfile
  dotfiles_link .gitignore ~/.gitignore

  green "Remember to execute: ${GREENCOLOR_BOLD}git config --global user.email <YOUR_EMAIL>${ENDCOLOR}"
}

setup_vim() {
    if [ -z "$(which vim)" ] ; then
        if is.mac ; then
            error "Install vim from source or link it properly -it comes preinstalled."
        elif is.debian ; then
            sudo apt install -y vim
        elif is.arch ; then
            sudo pacman -S --noconfirm  vim
        else
            error "Don't know how to install 'vim'"
        fi
    fi

    VIMDIR="${HOME}/.vim"
    green "Setting up VIM in ${VIMDIR}..."
    mkdir -p "${VIMDIR}/tmp" "${VIMDIR}/backup" "${VIMDIR}/colors" > /dev/null 2>&1
    cp .vim/colors/monokai.vim "${VIMDIR}/colors/"
    dotfiles_link .vimrc ~/.vimrc

    __install_git
    if [ -z "$(which deno)" ] ; then
        if is.mac ; then
            pip install deno --break-system-packages
        else
            curl -fsSL https://deno.land/x/install/install.sh | sh
        fi
    fi
    green "Deno installed"

  # Python libs for Python (requieres Python3 support for VIM)
  pip install flake8 jedi mypy --break-system-packages
}

__install_git_delta() {
    if ! command -v delta >/dev/null ; then
        if is.mac ; then
            delta_version="0.15.0"
            delta_pkg="delta-${delta_version}-x86_64-apple-darwin"
            curl -L "https://github.com/dandavison/delta/releases/download/${delta_version}/${delta_pkg}.tar.gz" | tar -xvzf -
            mv delta*/delta ~/.local/bin/delta
            chmod +x ~/.local/bin/delta
            rm -rf "${delta_pkg}"
        elif is.debian ; then
            # Fuck U Ubuntu....
            curl -kL -o delta.deb https://github.com/dandavison/delta/releases/download/0.13.0/git-delta-musl_0.13.0_amd64.deb
            sudo dpkg -i delta.deb && rm delta.deb
        elif is.arch ; then
            sudo pacman -S --noconfirm  git-delta
        else
            error "Don't know how to install delta"
        fi
    else
        blue "Not reinstalling git-delta"
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
    green "Git 'delta' configured successfully"
}

__install_bat() {
    if command -v bat >/dev/null ;then
        return
    elif is.mac ; then
        pip install bat --break-system-packages
    elif is.debian ; then
        sudo apt install -y bat
        # Due to Ubuntu installing this as batcat instead
        mkdir -p ~/.local/bin
        ln -sf "$(which batcat)" ~/.local/bin/bat
    elif is.arch ; then
        sudo pacman -S --noconfirm  bat
    else
        error "Don't know how to install bat"
    fi
}

__install_curl() {
    if command -v curl >/dev/null ;then
        return
    elif is.mac ; then
        echo "Install curl somehow but WOW you have fucked up"
    elif is.debian ; then
        sudo apt install -y curl
    elif is.arch ; then
        sudo pacman -S --noconfirm curl
    else
        error "Don't know how to install curl"
    fi
}

__install_fd() {
    if ! command -v fd >/dev/null ; then
        if is.mac ; then
            pip install fd --break-system-packages
        elif is.debian ; then
            sudo apt install -y fd-find
        elif is.arch ; then
            sudo pacman -S --noconfirm  fd
        else
            error "Don't know how to install fd"
        fi
        if command -v fdfind > /dev/null ; then
            mkdir -p ~/.local/bin
            ln -sf "$(which fdfind)" ~/.local/bin/fd
        fi
    fi

  # link local fd ignore file
  dotfiles_link .fdignore ~/.fdignore
}

__install_pyenv() {
    if ! command -v pyenv >/dev/null ; then
        __install_git

        if is.mac ; then
            [ ! -d ~/.pyenv ] && curl https://pyenv.run | bash
            eval "$(~/.pyenv/bin/pyenv init -)"
            #git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv
        else
            __install_curl
            # actually, all the recommended dependencies for building python
            apt install build-essential libssl-dev zlib1g-dev \
                libbz2-dev libreadline-dev libsqlite3-dev curl \
                libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

            rm -rf "${HOME}/.pyenv"
            curl -qsfL https://pyenv.run | bash
            export PATH="${HOME}/.pyenv/bin:$PATH"
            echo 'export PATH="${HOME}/.pyenv/bin:$PATH"' >> ~/.bashrc

            pyenv_virtualenv_root="$(pyenv root)/plugins/pyenv-virtualenv"
            rm -rf "${pyenv_virtualenv_root}"
            git clone -q https://github.com/pyenv/pyenv-virtualenv.git "${pyenv_virtualenv_root}"
        fi
    fi
}

__install_fzf() {
    if ! command -v fzf >/dev/null ; then
        [ ! -d ~/.fzf ] && git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install --all
    fi
    dotfiles_link .fzf.bash ~/.fzf.bash
    dotfiles_link files/.fzf/bin/fzf-preview.sh ~/.fzf/bin/fzf-preview.sh

    __install_imgcat
    __install_fd
    __install_bat
}

__install_imgcat() {
    if ! command -v imgcat >/dev/null ; then
        if is.mac ; then
            brew install imgcat
        elif is.debian ; then
            sudo apt install -y imgcat
        elif is.arch ; then
            sudo pacman -S --noconfirm imgcat
        else
            error "Don't know how to install imgcat"
        fi
    fi
}

__install_autocompletion() {
    if is.mac ; then
        [[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] || pip install bash-completion 
    elif is.debian ; then
        if [[ -r "/etc/profile.d/bash_completion.sh" ]] ; then
            sudo apt install  bash-completion
        fi
    elif is.arch ; then
        sudo pacman -S --noconfirm bash-completion
    else
        error "Don't know how to install bash completion"
    fi
    curl -sL https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash > ~/.git-completion.bash
}

__install_direnv() {
    if ! command -v direnv >/dev/null ; then
        if is.mac ;then
            curl -sfL https://direnv.net/install.sh | bash
        elif is.debian ; then
            sudo apt install direnv
        elif is.arch ; then
            __install_curl
            curl -qsfL https://direnv.net/install.sh | bash
        else
            error "Don't know how to install direnv"
            return
        fi
    fi

    direnv_dir="${HOME}/.config/direnv/"
    green "Setting up direnv main file in ${direnv_dir}"
    dotfiles_link files/direnvrc "${direnv_dir}/.direnvrc"
}

__install_powerline() {
    # Powerline package and config
    grep -q powerline-shell < "${PIPFILE_LIST}" ||
        pip install powerline-status powerline_gitstatus --break-system-packages


    # For now, default config is enough
    powerline_config_dir="${HOME}/.config/powerline"
    green "Setting up direnv main files in ${powerline_config_dir}"
    rm "${powerline_config_dir}"
    dotfiles_link "files/powerline" "${powerline_config_dir}"
}

__install_python() {
  if ! command -v python3 > /dev/null || ! command -v pip3 > /dev/null ; then
    red "Not installing python3 and PIP for you dude, go figure it out..." && exit 1
  fi

  if is.mac ; then
    echo "Python should be installed already"
  elif is.debian ; then
    sudo apt install -y python3 pip
  elif is.arch ; then
    sudo pacman -S --noconfirm python3 python-pip
  else
    error "Don't know how to install 'git'"
  fi
}

__prepare_pip() {
  __install_python

  green "Updating PIP now..."
  #pip install --upgrade  pip
  pip3 list --no-color > "${PIPFILE_LIST}"
}

setup_dotfiles() {
  green "Setting up bash dotfiles..."
  touch ~/.bash_profile # in case it does not exist..
  [ "$(grep -c "\. ~/.bashrc" ~/.bash_profile)" -ne 1 ] && cat .bash_profile  >> ~/.bash_profile

  __prepare_pip
  __install_fzf
  __install_pyenv
  __install_autocompletion
  __install_direnv
  __install_powerline

  dotfiles_link .bashrc ~/.bashrc
  dotfiles_link .bash_local_aliases ~/.bash_local_aliases
  [ ! -f ~/.bash_private_vars ] && \
    dotfiles_link .bash_private_vars ~/.bash_private_vars && \
    printf "\nCreated sample %s file, edit it and modify %s var to enable 'repo' command autocompletion.\n" "${BLUECOLOR_BOLD}~/.bash_private_vars${ENDCOLOR}" "${REDCOLOR}_REPO_AUTOCOMPLETE_BASE_DIR${ENDCOLOR}"


  # shellcheck source=/dev/null
  #. ~/.bash_profile

  green "New functions and aliases installed, to start using them type:\nsource ~/.bash_profile\n"
  # blue "type 'my_commands' to check them out!"
}

setup_ruby() {
  green "Setting up some Ruby defaults..."
  if ! grep -q 'irb/completion' ~/.irbrc ; then
    echo "require 'irb/completion'" >> ~/.irbrc
  fi
}

setup_postgres() {
  green "Setting up some PostgreSQL defaults..."
  dotfiles_link .psqlrc ~/.psqlrc
}

setup_configs() {
  if command -v terminator >/dev/null ; then
    green "Setting my terminator config..." && \
    dotfiles_link .config/terminator/config "$HOME/.config/terminator/config"
  fi
}


setup_all() {
  setup_dotfiles
  setup_vim
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
  for local_bin in $(ls files/bin) ; do
      rm -f "${bin_dir}/${local_bin}"
      dotfiles_link "files/bin/${local_bin}" "${bin_dir}/${local_bin}"
  done
}

help() {
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
}

__prerequisites() {
    if is.mac ; then
        echo "MAC installation now happens in userland - no sudo required"
    elif is.arch ; then
        if ! command -v sudo > /dev/null || ! command -v which > /dev/null ; then
            error "sudo and which need to be installed" && exit 1
        fi
    elif is.debian ; then
        if ! command -v sudo > /dev/null || ! command -v which > /dev/null ; then
            error "sudo and which need to be installed" && exit 1
        fi
    fi
}


setup() {
    # Lots of fancy functions here:
    # shellcheck source=/dev/null
    source .bash_local_aliases

    __prerequisites

    case "${1}" in
        all)      setup_all ;;
        vim)      setup_vim ;;
        dotfiles) setup_dotfiles ;;
        git)      setup_git ;;
        postgres) setup_postgres ;;
        ruby)     setup_ruby ;;
        configs)  setup_configs ;;
        binaries) setup_binaries ;;
        test)     run_tests;;
        help|*)   help ;;
    esac

    green "Everything is done, enjoy!"
}

mode="${1:-all}"
setup "${mode}"
