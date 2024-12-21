#!/bin/bash

# -e: exit on error
# -u: exit on unset variables
set -eu
set +x

source "$(dirname "${BASH_SOURCE[0]}")/logging.sh"

apts=(
    "snapd"
    "doublecmd-gtk"
    "gpg"
    "nodejs"
    "npm"
    "zsh"
    "vim"
    # Alacritty
    # https://github.com/alacritty/alacritty/blob/master/INSTALL.md#debianubuntu
    "cmake"
    "g++"
    "pkg-config"
    "libfreetype6-dev"
    "libfontconfig1-dev"
    "libxcb-xfixes0-dev"
    "libxkbcommon-dev"
    # Python (refer to pyenv docs)
    # https://github.com/pyenv/pyenv/wiki#suggested-build-environment
    "build-essential"
    "libssl-dev"
    "zlib1g-dev"
    "libbz2-dev"
    "libreadline-dev"
    "libsqlite3-dev"
    "libncursesw5-dev"
    "xz-utils"
    "tk-dev"
    "libxml2-dev"
    "libxmlsec1-dev"
    "libffi-dev"
    "liblzma-dev"
    # JetBrains Toolbox
    # https://dev.to/janetmutua/installing-jetbrains-toolbox-on-ubuntu-527f
    "libfuse2"
)

cargos=("ripgrep")

snaps=(
    "alacritty"
    # nvim version through apt-get is ~2 years old, so use snap
    "--beta nvim --classic"
    "vlc"
    "--classic code"
    "opera"
    "keepassxc"
    # "firefox"
)

brews=("fzf" "pipx" "ruff" "uv")

command_exists() {
    if type "$1" >/dev/null 2>&1; then
        log_info "$1 already installed"
        return 0
    fi
    return 1
}

install_brew(){
    if command_exists brew; then
        return
    fi
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

install_pyenv() {
    if command_exists pyenv; then
        return
    fi
    curl -sSf https://pyenv.run | bash
    if command_exists pyenv; then
        pyenv install 3.12
        pyenv global 3.12
    fi
}

install_rustup() {
    if command_exists rustup; then
        return
    fi
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
}

install_zoxide() {
    if command_exists zoxide; then
        return
    fi
    curl -sSf https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
}

install_jetbrains_nerd_font() {
    if fc-list | grep -q JetBrains; then
        return
    fi
    curl -fsSL https://raw.githubusercontent.com/JetBrains/JetBrainsMono/master/install_manual.sh | bash
}

install_oh_my_posh() {
    if command_exists "oh-my-posh"; then
        return
    fi
    curl -s https://ohmyposh.dev/install.sh | bash -s
}

install_apts() {
    log_task "Updating package list and installing APT packages..."
    sudo apt update
    for pkg in "${apts[@]}"; do
        log_task "Installing: $pkg"
        sudo apt install -y "$pkg"
    done
}

install_standalone_tools() {
    log_task "Install standalone tools"
    install_brew
    install_pyenv
    install_rustup
    install_oh_my_posh
    install_zoxide
    install_jetbrains_nerd_font
}

install_cargos() {
    log_task "Installing tools using Cargo..."
    for pkg in "${cargos[@]}"; do
        log_task "Installing: $pkg"
        cargo install "$pkg"
    done
}

install_snaps() {
    log_task "Installing Snap packages..."
    for pkg in "${snaps[@]}"; do
        log_task "Installing: $pkg"
        sudo snap install $pkg
    done
    sudo update-desktop-database /var/lib/snapd/desktop/applications
}

install_brews(){
    log_task "Installing Brew packages..."
    for pkg in "${brews[@]}"; do
        log_task "Installing: $pkg"
        brew install $pkg
    done
}

install_jetbrains_toolbox(){
    if ls /opt | grep -q "jetbrains-toolbox"; then
        return
    fi
    file="jetbrains-toolbox-2.5.2.35332"
    wget -c "https://download.jetbrains.com/toolbox/$file.tar.gz"
    sudo tar -xzf "$file.tar.gz" -C /opt
    /opt/"$file"/jetbrains-toolbox
}

install_standalone_tools
install_apts
install_cargos
install_snaps
install_brews
install_jetbrains_toolbox

success "All installations completed successfully!"
