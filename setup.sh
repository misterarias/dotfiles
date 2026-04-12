#!/bin/bash

set -o errexit
# set -o nounset
set -o pipefail

# Core user directories
BACKUP_FOLDER="${HOME}/.backup"
LOCAL_BIN_DIR="${HOME}/.local/bin"
CONFIG_DIR="${HOME}/.config"
DIRENV_CONFIG_DIR="${CONFIG_DIR}/direnv"

# Application directories
VIM_DIR="${HOME}/.vim"
FZF_DIR="${HOME}/.fzf"
PYENV_DIR="${HOME}/.pyenv"

# Bash configuration files
BASHRC="${HOME}/.bashrc"
BASH_PROFILE="${HOME}/.bash_profile"
BASH_LOCAL_ALIASES="${HOME}/.bash_local_aliases"
BASH_PRIVATE_VARS="${HOME}/.bash_private_vars"

# Tool configuration files
VIMRC="${HOME}/.vimrc"
GITIGNORE_FILE="${HOME}/.gitignore"
FDIGNORE="${HOME}/.fdignore"
GIT_COMPLETION="${HOME}/.git-completion.bash"
IRBRC="${HOME}/.irbrc"
PSQLRC="${HOME}/.psqlrc"
STARSHIP_CONFIG="${CONFIG_DIR}/starship.toml"
TERMINATOR_CONFIG="${CONFIG_DIR}/terminator/config"

# Global tool list - source of truth for all managed software
declare -a TOOLS=(
    "git"
    "vim"
    "python3"
    "pip3"
    "uv"
    "fzf"
    "fd"
    "bat"
    "curl"
    "direnv"
    "starship"
    "imgcat"
    "pyenv"
)

# Initialize backup folder
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

    # save a copy of the system file, if it exists and is not a symlink already
    if [ -e "$system_dotfile" ] && [ ! -L "$system_dotfile" ] ; then
        mv "$system_dotfile" "$BACKUP_FOLDER" > /dev/null 2>&1 || true
    fi
    ln -sf "$local_dotfile" "$system_dotfile"
    blue "   ${local_dotfile} ---> ${system_dotfile}"
}

install_git() {
    if command -v git >/dev/null 2>&1 ; then
        return
    elif is.mac ; then
        error "Install git using XCode Developer tools"
        return 1
    elif is.debian ; then
        sudo apt install -y git
    elif is.arch ; then
        sudo pacman -S --noconfirm git
    else
        error "Don't know how to install 'git'"
        return 1
    fi

    if ! command -v git >/dev/null 2>&1 ; then
        error "git installation failed"
        return 1
    fi
}

configure_git() {
    green "Setting up some git defaults..."
    while read -r line ; do
        section=$(echo "$line" | cut -d" " -f1)
        value=$(echo "$line" | cut -d" " -f2-)

        git config --global "$section" "$value"
    done < .gitconfig

    # This is now configured in core.excludesfile
    dotfiles_link .gitignore "${GITIGNORE_FILE}"
    
    if [ -z "$(git config --global user.name)" ] || [ -z "$(git config --global user.email)" ] ; then
        red "Remember to execute: ${GREENCOLOR_BOLD}git config --global user.email <YOUR_EMAIL>${ENDCOLOR}"
    fi
}

install_vim() {
    if command -v vim >/dev/null 2>&1 ; then
        return
    elif is.mac ; then
        error "Install vim from source or link it properly - it comes preinstalled."
        return 1
    elif is.debian ; then
        sudo apt install -y vim
    elif is.arch ; then
        sudo pacman -S --noconfirm vim
    else
        error "Don't know how to install 'vim'"
        return 1
    fi

    if ! command -v vim >/dev/null 2>&1 ; then
        error "vim installation failed"
        return 1
    fi
}

configure_vim() {
    green "Setting up VIM in ${VIM_DIR}..."
    mkdir -p "${VIM_DIR}/tmp" "${VIM_DIR}/backup" "${VIM_DIR}/colors" > /dev/null 2>&1
    if [ ! -f "${VIM_DIR}/colors/monokai.vim" ] || ! cmp -s .vim/colors/monokai.vim "${VIM_DIR}/colors/monokai.vim" ; then
        cp .vim/colors/monokai.vim "${VIM_DIR}/colors/"
    fi
    dotfiles_link .vimrc "${VIMRC}"

    # Python libs for Python (requieres Python3 support for VIM)
    green "Installing some Python tools for VIM..."
    python3 -m pip install -q --break-system-packages \
        flake8 \
        jedi
}

install_bat() {
    if command -v bat >/dev/null 2>&1 ; then
        return
    elif is.mac ; then
        pip install bat --break-system-packages
    elif is.debian ; then
        sudo apt install -y bat
        # Due to Ubuntu installing this as batcat instead
        mkdir -p "${LOCAL_BIN_DIR}"
        ln -sf "$(which batcat)" "${LOCAL_BIN_DIR}/bat"
    elif is.arch ; then
        sudo pacman -S --noconfirm bat
    else
        error "Don't know how to install bat"
        return 1
    fi

    if ! command -v bat >/dev/null 2>&1 ; then
        error "bat installation failed"
        return 1
    fi
}

install_curl() {
    if command -v curl >/dev/null 2>&1 ; then
        return
    elif is.mac ; then
        echo "Install curl somehow but WOW you have fucked up"
    elif is.debian ; then
        sudo apt install -y curl
    elif is.arch ; then
        sudo pacman -S --noconfirm curl
    else
        error "Don't know how to install curl"
        return 1
    fi

    if ! command -v curl >/dev/null 2>&1 ; then
        error "curl installation failed"
        return 1
    fi
}

install_fd() {
    if command -v fd >/dev/null 2>&1 ; then
        dotfiles_link .fdignore "${FDIGNORE}"
        return
    fi

    if is.mac ; then
        pip install fd --break-system-packages
    elif is.debian ; then
        sudo apt install -y fd-find
    elif is.arch ; then
        sudo pacman -S --noconfirm fd
    else
        error "Don't know how to install fd"
        return 1
    fi
    if command -v fdfind >/dev/null 2>&1 ; then
        mkdir -p "${LOCAL_BIN_DIR}"
        ln -sf "$(which fdfind)" "${LOCAL_BIN_DIR}/fd"
    fi

    if ! command -v fd >/dev/null 2>&1 ; then
        error "fd installation failed"
        return 1
    fi

  # link local fd ignore file
  dotfiles_link .fdignore "${FDIGNORE}"
}

install_pyenv() {
    if command -v pyenv >/dev/null 2>&1 ; then
        return
    fi
    install_git

    if [ -d "${PYENV_DIR}" ] ; then
        export PATH="${PYENV_DIR}/bin:$PATH"
    fi

    if command -v pyenv >/dev/null 2>&1 ; then
        return
    fi

    if is.mac ; then
        [ ! -d "${PYENV_DIR}" ] && curl https://pyenv.run | bash
        export PATH="${PYENV_DIR}/bin:$PATH"
    else
        install_curl
        sudo apt install -y build-essential libssl-dev zlib2g-dev \
            libbz2-dev libreadline-dev libsqlite3-dev curl \
            libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

        if [ ! -d "${PYENV_DIR}" ] ; then
            curl -qsfL https://pyenv.run | bash
        fi
        export PATH="${PYENV_DIR}/bin:$PATH"
        if ! grep -Fq "export PATH=\"${PYENV_DIR}/bin:$PATH\"" "${BASHRC}" 2>/dev/null ; then
            echo "export PATH=\"${PYENV_DIR}/bin:$PATH\"" >> "${BASHRC}"
        fi
    fi

    if command -v pyenv >/dev/null 2>&1 ; then
        pyenv_virtualenv_root="$(pyenv root)/plugins/pyenv-virtualenv"
        if [ ! -d "${pyenv_virtualenv_root}" ] ; then
            git clone -q https://github.com/pyenv/pyenv-virtualenv.git "${pyenv_virtualenv_root}"
        fi
    fi

    if ! command -v pyenv >/dev/null 2>&1 ; then
        error "pyenv installation failed"
        return 1
    fi
}

install_fzf() {
    if ! command -v fzf >/dev/null 2>&1 ; then
        [ ! -d "${FZF_DIR}" ] && git clone --depth 1 https://github.com/junegunn/fzf.git "${FZF_DIR}"
        "${FZF_DIR}/install" --all
    fi

    if ! command -v fzf >/dev/null 2>&1 ; then
        error "fzf installation failed"
        return 1
    fi

    dotfiles_link .fzf.bash "${HOME}/.fzf.bash"
    dotfiles_link files/.fzf/bin/fzf-preview.sh "${FZF_DIR}/bin/fzf-preview.sh"

    install_imgcat
    install_fd
    install_bat
}

install_imgcat() {
    if command -v imgcat >/dev/null 2>&1 ; then
        return
    fi

    if is.mac ; then
        brew install imgcat
    elif is.debian ; then
        sudo apt install -y imgcat
    elif is.arch ; then
        sudo pacman -S --noconfirm imgcat
    else
        error "Don't know how to install imgcat"
        return 1
    fi

    if ! command -v imgcat >/dev/null 2>&1 ; then
        error "imgcat installation failed"
        return 1
    fi
}

install_autocompletion() {
    if is.mac ; then
        [ ! -f /opt/homebrew/etc/profile.d/bash_completion.sh ] && brew install bash-completion@2
    elif is.debian ; then
        [[ -r "/etc/profile.d/bash_completion.sh" ]] ||  sudo apt install  bash-completion
    elif is.arch ; then
        sudo pacman -S --noconfirm bash-completion
    else
        error "Don't know how to install bash completion"
    fi
    [ ! -f "${GIT_COMPLETION}" ] &&
        curl -v -sL https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash > "${GIT_COMPLETION}"
    return 0
}

install_direnv() {
    if command -v direnv >/dev/null 2>&1 ; then
        green "Setting up direnv main file in ${DIRENV_CONFIG_DIR}"
        dotfiles_link files/direnvrc "${DIRENV_CONFIG_DIR}/.direnvrc"
        return
    fi

    if is.mac ;then
        curl -sfL https://direnv.net/install.sh | bash
    elif is.debian ; then
        sudo apt install direnv
    elif is.arch ; then
        install_curl
        curl -qsfL https://direnv.net/install.sh | bash
    else
        error "Don't know how to install direnv"
        return 1
    fi

    if ! command -v direnv >/dev/null 2>&1 ; then
        error "direnv installation failed"
        return 1
    fi
}

configure_direnv() {
    green "Setting up direnv main file in ${DIRENV_CONFIG_DIR}"
    dotfiles_link files/direnvrc "${DIRENV_CONFIG_DIR}/.direnvrc"
}

install_status_bar() {
    # We now use starship: https://starship.rs/guide/
    if ! command -v starship &>/dev/null ; then
        if is.mac ; then
            brew install starship
        elif is.debian ; then
            curl -sS https://starship.rs/install.sh | sh
            # sudo apt install -y starship
        elif is.arch ; then
            sudo pacman -S --noconfirm starship
        else
            error "Don't know how to install starship"
            return 1
        fi
    fi

    if ! command -v starship &>/dev/null ; then
        error "starship installation failed"
        return 1
    fi

    green "Setting up starship main files in ${STARSHIP_CONFIG}"
    dotfiles_link "files/starship.toml" "${STARSHIP_CONFIG}"
}

install_python() {
    if command -v python3 >/dev/null 2>&1 && command -v pip3 >/dev/null 2>&1 ; then
        return
    fi

    if is.mac ; then
        echo "Python should be installed already"
    elif is.debian ; then
        sudo apt install -y python3 pip
    elif is.arch ; then
        sudo pacman -S --noconfirm python3 python-pip
    else
        error "Don't know how to install python3 and pip3"
        return 1
    fi

    if ! command -v python3 >/dev/null 2>&1 || ! command -v pip3 >/dev/null 2>&1 ; then
        error "python3 / pip3 installation failed"
        return 1
    fi
}

install_uv() {
    if command -v uv >/dev/null 2>&1 ; then
        return
    fi

    curl -LsSf https://astral.sh/uv/install.sh | sh

    if ! command -v uv >/dev/null 2>&1 ; then
        error "uv installation failed"
        return 1
    fi
}

__prepare_pip() {
  install_python

  green "Updating PIP now..."
  #pip install --upgrade  pip
  pip3 list --no-color > "${PIPFILE_LIST}"
}

install_all_tools() {
    green "Installing all required tools..."
    
    # __prepare_pip
    install_git
    install_vim
    install_fzf
    install_pyenv
    install_uv
    install_autocompletion
    install_direnv
    install_status_bar
}

configure_python() {
    green "Setting up some Python defaults..."
    pip install -q --upgrade --break-system-packages \
        pip \
        flake8 \
        mypy \
        ipython \
        pandas
    blue "   Installed global Python tools: pip, flake8, mypy, ipython and pandas"
}
configure_all_tools() {
    green "Configuring all tools..."
    
    configure_git
    configure_python
    configure_vim
    configure_direnv
    
    # Ruby configuration
    if ! grep -q 'irb/completion' "${IRBRC}" ; then
        green "Setting up Ruby defaults..."
        echo "require 'irb/completion'" >> "${IRBRC}"
    fi
    
    # PostgreSQL configuration
    green "Setting up PostgreSQL defaults..."
    dotfiles_link .psqlrc "${PSQLRC}"

    if command -v terminator >/dev/null ; then
        green "Setting my terminator config..." && \
        dotfiles_link .config/terminator/config "${TERMINATOR_CONFIG}"
    fi
}

configure_bash_dotfiles() {
    green "Configuring bash dotfiles..."
    touch "${BASH_PROFILE}" # in case it does not exist..
    if ! grep -q "^[[:space:]]*\. ${BASHRC}" "${BASH_PROFILE}" 2>/dev/null ; then
        printf "\n. ${BASHRC}\n" >> "${BASH_PROFILE}"
    fi

    dotfiles_link .bashrc "${BASHRC}"
    dotfiles_link .bash_local_aliases "${BASH_LOCAL_ALIASES}"
    if [ ! -f "${BASH_PRIVATE_VARS}" ] ; then
        cp .bash_private_vars "${BASH_PRIVATE_VARS}"
        printf "\nCreated sample %s file, edit it and modify %s var to enable 'repo' command autocompletion.\n" "${BLUECOLOR_BOLD}${BASH_PRIVATE_VARS}${ENDCOLOR}" "${REDCOLOR}_REPO_AUTOCOMPLETE_BASE_DIR${ENDCOLOR}"
    fi
}

setup_binaries() {
  green "Copying 'useful' binaries..."

  # I like this, it's the same used by 'pip install --user'
  mkdir -p "${LOCAL_BIN_DIR}"
  for local_bin in files/bin/* ; do
      file_name="$(basename "$local_bin")"
      dotfiles_link "$local_bin" "${LOCAL_BIN_DIR}/${file_name}"
  done
}

prerequisites() {
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

print_installation_summary() {
    local tool version location
    
    blue "\n════════════════════════════════════════════════════════════════\n"
    green "Installation Summary"
    blue "════════════════════════════════════════════════════════════════\n"
    
    printf "%-20s %-50s %s\n" "Tool" "Location" "Version"
    printf "%-20s %-50s %s\n" "----" "--------" "-------"
    
    for tool in "${TOOLS[@]}"; do
        location="$(command -v "$tool" 2>/dev/null || echo "—")"
        
        if [ "$location" != "—" ]; then
            case "$tool" in
                git|curl)
                    version=$("$tool" --version 2>/dev/null | head -n1 | awk '{print $NF}' || echo "—") ;;
                python3|pip3)
                    version=$("$tool" --version 2>/dev/null | awk '{print $NF}' || echo "—") ;;
                vim|uv|fzf|fd|bat|direnv|starship|imgcat|pyenv)
                    version=$("$tool" --version 2>/dev/null | head -n1 | sed 's/^[^0-9]*//; s/[^0-9.].*$//' || echo "—") ;;
                *)
                    version="—" ;;
            esac
        else
            version="—"
        fi
        
        printf "%-20s %-50s %s\n" "$tool" "${location:0:50}" "$version"
    done
    
    # Custom binaries from ~/.local/bin
    if [ -d "${LOCAL_BIN_DIR}" ]; then
        local custom_bins
        custom_bins=$(ls -1 "${LOCAL_BIN_DIR}" 2>/dev/null | tr '\n' ' ')
        if [ -n "$custom_bins" ]; then
            printf "%-20s %-50s %s\n" "custom scripts" "${LOCAL_BIN_DIR}" "$custom_bins"
        fi
    fi
    
    blue "════════════════════════════════════════════════════════════════\n"
}

# shellcheck source=/dev/null
source .bash_local_aliases

prerequisites
install_all_tools
configure_bash_dotfiles
configure_all_tools
setup_binaries
print_installation_summary
green "Everything is done, enjoy!"