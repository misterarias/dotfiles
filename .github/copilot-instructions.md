# Copilot Instructions for Dotfiles Repository

## Repository Overview

This repository contains a comprehensive dotfiles management system for setting up and maintaining a consistent development environment across multiple platforms (macOS, Debian/Ubuntu, Arch Linux). It automates the installation and configuration of CLI tools, shell customization, development utilities, and various programming environments.

## Key Technologies & Tools

- **Shell**: Bash (primary shell scripting language)
- **Terminal Customization**: Starship prompt, custom bash aliases and functions
- **Version Control**: Git with delta diff viewer
- **Python**: pyenv for version management, pip for packages
- **Development Tools**: vim, fzf, fd, bat, direnv, imgcat
- **Configuration Management**: Symbolic linking system for dotfiles

## Project Structure

### Core Scripts
- `setup.sh`: Main orchestration script with modular setup functions
- `packages.sh`: Package installation and system configuration functions
- `tests.sh`: Test suite for validating functions
- `.bash_local_aliases`: Function definitions and color utilities
- `.bashrc`: Main bash configuration file

### Configuration Files
- `.vimrc`, `.gitconfig`, `.psqlrc`: Application-specific configurations
- `.fzf.bash`: fzf fuzzy finder configuration
- `.fdignore`: fd search tool exclusions
- `files/starship.toml`: Starship prompt configuration
- `files/direnvrc`: direnv environment management functions

### Utilities
- `files/bin/`: Custom utility scripts (curlt, wsl-open, yaml2json)
- `docker/`: Test dockerfiles for Debian, Ubuntu, and Arch Linux

## Coding Conventions

### Bash Scripting Standards

1. **Safety First**
   - Always use `set -o errexit`, `set -o nounset`, `set -o pipefail` at script start
   - Quote all variables: `"${variable}"` instead of `$variable`
   - Use `[[ ]]` for conditionals instead of `[ ]`

2. **Function Naming**
   - Public functions: `snake_case` (e.g., `setup_vim`, `setup_git`)
   - Private/internal functions: Prefix with double underscore `__function_name` (e.g., `__install_git`, `__prerequisites`)
   - Helper functions: Prefix with single underscore `_function_name`

3. **Platform Detection**
   - Use `is.mac`, `is.debian`, `is.arch` functions for OS detection
   - Always provide installation paths for all supported platforms
   - Use platform-specific package managers: `brew` (macOS), `apt` (Debian/Ubuntu), `pacman` (Arch)

4. **Color Output**
   - Use consistent color functions: `green()`, `blue()`, `red()`, `error()`
   - Format: `green "Success message"` or `error "Error message"`
   - Color codes defined in `.bash_local_aliases`: GREENCOLOR_BOLD, BLUECOLOR_BOLD, REDCOLOR_BOLD, ENDCOLOR

5. **Error Handling**
   - Check command existence: `command -v tool >/dev/null` or `[ -n "$(which tool)" ]`
   - Provide meaningful error messages with `error` function
   - Use `|| true` for commands that may fail without breaking execution

### Code Organization

1. **Modular Setup Functions**
   - Each major component has its own `setup_*` function
   - Installation helpers prefixed with `__install_*`
   - Keep functions focused and single-purpose

2. **Dotfile Linking**
   - Use `dotfiles_link` function for all symlink operations
   - First parameter: source file (relative to repo root)
   - Second parameter: target location (absolute path)
   - Function automatically backs up existing files

3. **Backup Strategy**
   - Existing system files backed up to `~/.backup` before replacement
   - Check if file is already a symlink before backing up

### Shell Configuration

1. **Bash Customization**
   - VI mode enabled by default (`set -o vi`)
   - Custom prompt using Starship
   - Completion settings: case-insensitive, show-all-if-ambiguous
   - History search with arrow keys

2. **Path Management**
   - Add local binaries: `~/.local/bin` first in PATH
   - Use `PATH_add` function from direnv when available
   - Export paths in `.bashrc`, not in individual functions

3. **Lazy Loading**
   - Implement lazy loading for heavy tools (e.g., pyenv)
   - Use alias wrapper pattern to load on first use
   - Set flag after loading to prevent reloading

## Common Patterns

### Installing a New Tool

```bash
__install_toolname() {
    if command -v toolname >/dev/null ; then
        return  # Already installed
    elif is.mac ; then
        brew install toolname
    elif is.debian ; then
        sudo apt install -y toolname
    elif is.arch ; then
        sudo pacman -S --noconfirm toolname
    else
        error "Don't know how to install toolname"
    fi
}
```

### Adding a Setup Function

```bash
setup_toolname() {
    __install_toolname
    green "Setting up toolname configuration..."
    dotfiles_link .toolnamerc ~/.toolnamerc
    # Additional configuration steps
}
```

### Cross-Platform File Paths

- Debian/Ubuntu may install tools with different names (e.g., `batcat` instead of `bat`)
- Create symlinks in `~/.local/bin` to normalize names
- Check for both variants when detecting installation

## Testing

- Tests located in `tests.sh`
- Test functions prefixed with `test__`
- Use `__assert_equals` for assertions
- Docker-based testing for Debian, Ubuntu, and Arch

## Dependencies & Installation

### Prerequisites
- `sudo` and `which` commands (Linux systems)
- Git (installed automatically if missing)
- Python 3 and pip (must be pre-installed)

### Installation Order
1. Git and delta diff viewer
2. Python environment (pyenv)
3. Shell enhancements (fzf, starship, direnv)
4. bash completion
5. Application configs (vim, git, postgres, ruby)
6. Custom binaries

## Important Notes

1. **Symbolic Links**: All dotfiles are symlinked, not copied, so changes to the repo automatically apply
2. **Idempotent**: Setup scripts can be run multiple times safely
3. **Non-Interactive**: All installations should work without user input
4. **User-Space Installation**: macOS setup now happens in userland (no sudo required)
5. **Shell Reload**: After setup, user must run `source ~/.bash_profile` to activate changes

## When Suggesting Code Changes

- Maintain cross-platform compatibility (macOS, Debian/Ubuntu, Arch)
- Follow the naming conventions (public vs private functions)
- Use the color output functions for user feedback
- Implement error checking with meaningful messages
- Add installation to appropriate setup function
- Update help text if adding new setup modes
- Consider backup strategy for system files
- Test changes in Docker containers when possible
- Keep bash completion patterns for new commands

## Starship Prompt Configuration

- Custom format with time, hostname, directory, git info
- Language-specific icons: Python (🐍), Rust, Golang
- Battery indicator for laptops
- Configuration in `files/starship.toml`

## Direnv Integration

- Custom layouts for pyenv, virtualenv, poetry
- `define` function for creating temporary session commands
- Virtual environment auto-activation
- Configuration in `files/direnvrc`
