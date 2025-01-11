#!/usr/bin/env bash

#
# Usage:
#   ./install_debian.sh <shell_name> <python_version>
#
# Examples:
#   ./install_debian.sh zsh 3.10
#   ./install_debian.sh bash 3.8
#

set -eu  # -e: exit on error; -u exit on unset variables
set +x   # disable debug mode

usage() {
  cat <<EOF
Usage: $0 <shell_name>

Examples:
  $0 zsh 3.10
  $0 bash 3.8

Options:
  -h, --help    Show this help message and exit
EOF
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  usage
  exit 0
fi

DEFAULT_USER_SHELL="$1"
INSTALL_PYTHON_VERSION="$2"

source "$(dirname "${BASH_SOURCE[0]}")/logging.sh"

apts=(
    "snapd"
    "bash-completion"
    "doublecmd-gtk"
    "exfat-fuse"
    "feh"
    "flatpak"
    "git-extras"
    "gpg"
    "htop"
    "nodejs"
    "npm"
    "zsh"
    "vim"
    "wezterm"
    "xclip"
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
    "redshift"
    "redshift-gtk"
    # flashing ZSA voyager
    "libwebkit2gtk-4.1-0"
    "libgtk-3-0"
    "libusb-1.0-0"
)

cargos=("ripgrep")

snaps=(
    "alacritty"
    # nvim version through apt-get is ~2 years old, so use snap
    "chromium"
    # https://stackoverflow.com/questions/78585138/visual-studio-code-crashes-on-ubuntu-22-04-4-lts-errorprocess-memory-range-cc7
    # TODO: upgrade at a later date if crashing stops; tried 170, 175 179(latest)
    "--revision 159 --classic code"
    "opera"
    "keepassxc"
    "notion-snap-reborn"
    "nvim --beta --classic"
    "spotify"
    "whatsapp-app"
    "vlc"
    # "firefox"
)

brews=("fzf" "pipx" "ruff" "uv")
pipxs=("virtualenv" "poetry" "pip-tools" "glances[all]")

command_exists() {
    if type "$1" >/dev/null 2>&1; then
        log_info "$1 already installed"
        return 0
    fi
    return 1
}

install_brew() {
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
        pyenv install $INSTALL_PYTHON_VERSION
        pyenv global $INSTALL_PYTHON_VERSION
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

install_git_diff_highlight() {
    if command_exists "diff-highlight"; then
        return
    fi
    local diff_highlight_path
    diff_highlight_path="$(find /usr -type f -name diff-highlight 2>/dev/null \
    | grep '/contrib/diff-highlight/diff-highlight$')"

    if [[ -n "$diff_highlight_path" ]]; then
        sudo cp "$diff_highlight_path" /usr/local/bin/diff-highlight
        sudo chmod +x /usr/local/bin/diff-highlight
        echo "Installed diff-highlight to /usr/local/bin/"
    else
        echo "Could not find diff-highlight, verify Git's contrib scripts are installed."
    fi
}

install_standalone_tools() {
    log_task "Install standalone tools"
    install_brew
    install_pyenv
    install_rustup
    install_oh_my_posh
    install_zoxide
    install_jetbrains_nerd_font
    install_git_diff_highlight
}

install_apts() {
    log_task "Updating package list and installing APT packages..."
    sudo apt update
    for pkg in "${apts[@]}"; do
        log_task "Install apt package: $pkg"
        sudo apt install -y "$pkg"
    done
}

install_cargos() {
    log_task "Installing tools using Cargo..."
    for pkg in "${cargos[@]}"; do
        log_task "Install cargo package: $pkg"
        cargo install "$pkg"
    done
}

install_snaps() {
    log_task "Installing Snap packages..."
    for pkg in "${snaps[@]}"; do
        log_task "Install snap package: $pkg"
        sudo snap install $pkg
    done
    sudo update-desktop-database /var/lib/snapd/desktop/applications
}

install_brews() {
    log_task "Installing Brew packages..."
    for pkg in "${brews[@]}"; do
        log_task "Install brew package: $pkg"
        brew install $pkg
    done
}

install_jetbrains_toolbox() {
    if ls /opt | grep -q "jetbrains-toolbox"; then
        return
    fi
    file="jetbrains-toolbox-2.5.2.35332"
    wget -c "https://download.jetbrains.com/toolbox/$file.tar.gz"
    sudo tar -xzf "$file.tar.gz" -C /opt
    /opt/"$file"/jetbrains-toolbox
}

wezterm_prereqs() {
    if command_exists "wezterm"; then
        return
    fi
    curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /etc/apt/keyrings/wezterm-fury.gpg
    echo 'deb [signed-by=/etc/apt/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
}

set_system_key_bindings() {
    gsettings set org.gnome.settings-daemon.plugins.media-keys terminal "['<Super>t']"
    gsettings set org.gnome.desktop.default-applications.terminal exec-arg ''
    gsettings set org.gnome.desktop.default-applications.terminal exec 'wezterm'
    gsettings set org.gnome.desktop.wm.keybindings minimize "['<Super>Down']"
    gsettings set org.gnome.desktop.wm.keybindings maximize "['<Super>Up']"
    gsettings set org.gnome.desktop.wm.keybindings switch-applications "['<Super>Tab']"
    gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "['<Shift><Super>Tab']"
    gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Alt>Tab']"
    gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "['<Shift><Alt>Tab']"
}

set_default_shell() {
    set_shell="$(which $DEFAULT_USER_SHELL)"
    chsh -s $set_shell
    log_info "Set default shell to $set_shell"
}

install_pipxs() {
    for pkg in "${pipxs[@]}"; do
        log_task "Install pipx package: $pkg"
        pipx install --python=$(which python) "$pkg"
    done
}

add_flathub_repo() {
    log_task "Add flathub repo"
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
}

wezterm_prereqs
install_standalone_tools
install_apts
add_flathub_repo
install_cargos
install_snaps
install_brews
install_pipxs
install_jetbrains_toolbox
set_default_shell
set_system_key_bindings

success "All installations completed successfully!"
