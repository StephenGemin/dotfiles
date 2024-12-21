#!/bin/bash

# -e: exit on error
# -u: exit on unset variables
set -eu


curls=(
    "https://sh.rustup.rs -sSf | sh"
    "https://pyenv.run | bash"
    "https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh -sSf | sh"
    "https://raw.githubusercontent.com/JetBrains/JetBrainsMono/master/install_manual.sh -fsSL | bash"
)

apts=(
    "snapd"
    "doublecmd-gtk"
    "gpg"
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
    # NeoVim & NVChad
    "ripgrep"
    "neovim"
    "vim"
)

cargos=(
    "alacritty"
)

snaps=(
    "vlc"
    "--classic code"
    "opera"
    "firefox"
)

install_curls() {
    echo "Installing tools using curl..."
    for cmd in "${curls[@]}"; do
        echo "Running: $cmd"
        # curl "$cmd"
    done
}

install_apts() {
    echo "Updating package list and installing APT packages..."
    sudo apt update
    for pkg in "${apts[@]}"; do
        echo "Installing: $pkg"
        # sudo apt install -y "$pkg"
    done
}

install_cargos() {
    echo "Installing tools using Cargo..."
    for pkg in "${cargos[@]}"; do
        echo "Installing: $pkg"
        # cargo install "$pkg"
    done
}

install_snaps() {
    echo "Installing Snap packages..."
    for pkg in "${snaps[@]}"; do
        echo "Installing: $pkg"
        # sudo snap install $pkg
    done
}

# Run all the functions
install_curls
install_apts
install_cargos
install_snaps

echo "All installations completed successfully!"
