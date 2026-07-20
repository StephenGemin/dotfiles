#!/usr/bin/env bash

#
# Usage:
#   ./install_debian.sh <shell_name> <python_version> <brews> [pipx_package ...]
#
# Examples:
#   ./install_debian.sh zsh 3.10 "fzf ripgrep" virtualenv poetry
#   ./install_debian.sh bash 3.8 "fzf"
#
# This script is meant to be *sourced* by run_onchange_debian_01-install.sh.tmpl,
# which renders the apts, cargos and snaps arrays from .chezmoidata/debian.yaml
# into the environment before sourcing. Run directly, those three lists are
# empty (no apt/cargo/snap packages installed); the positional args above still
# drive the shell/python/brews/pipx steps.
#

set -eu  # -e: exit on error; -u exit on unset variables
set +x   # disable debug mode

CI="${CI:-false}"

usage() {
  cat <<EOF
Usage: $0 <shell_name> <python_version> <brews> [pipx_package ...]

Examples:
  $0 zsh 3.10 "brew1 brew2" virtualenv poetry
  $0 bash 3.8 "brew1 brew2 brew3"

Options:
  -h, --help    Show this help message and exit
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

DEFAULT_USER_SHELL="$1"
INSTALL_PYTHON_VERSION="$2"
read -ra BREWS <<< "$3"   # space-separated list passed in quotes -> array
shift 3
PIPX_PACKAGES=("$@")   # remaining args, one pipx package each

# shellcheck source=scripts/logging.sh
source "$(dirname "${BASH_SOURCE[0]}")/logging.sh"

# apts, cargos and snaps are provided by the caller. The
# run_onchange_debian_01-install.sh.tmpl script renders them from
# .chezmoidata/debian.yaml and sources this script, so the arrays are already
# set in the environment. `declare -a` (no assignment) documents the contract
# and keeps shellcheck happy without clobbering the caller's values.
declare -a apts cargos snaps

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
    if [[ "$CI" == "true" ]]; then
        log_info "[CI] Would install Homebrew"
        return
    fi
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

install_pyenv() {
    if command_exists pyenv; then
        return
    fi
    if [[ "$CI" == "true" ]]; then
        log_info "[CI] Would install pyenv and Python $INSTALL_PYTHON_VERSION"
        return
    fi
    curl -sSf https://pyenv.run | bash
    if command_exists pyenv; then
        pyenv install "$INSTALL_PYTHON_VERSION"
        pyenv global "$INSTALL_PYTHON_VERSION"
    fi
}

install_rustup() {
    if command_exists rustup; then
        if [[ "$CI" == "true" ]]; then
            log_info "[CI] Would run rustup update"
            return
        fi
        rustup update stable
        rustup component add rust-analyzer
        return
    fi
    if [[ "$CI" == "true" ]]; then
        log_info "[CI] Would install rustup"
        return
    fi
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    "$HOME/.cargo/bin/rustup" component add rust-analyzer
}

install_zoxide() {
    if command_exists zoxide; then
        return
    fi
    if [[ "$CI" == "true" ]]; then
        log_info "[CI] Would install zoxide"
        return
    fi
    curl -sSf https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
}

install_jetbrains_nerd_font() {
    if fc-list | grep -q JetBrains; then
        return
    fi
    if [[ "$CI" == "true" ]]; then
        log_info "[CI] Would install JetBrains NerdFont"
        return
    fi
    curl -fsSL https://raw.githubusercontent.com/JetBrains/JetBrainsMono/master/install_manual.sh | bash
}

install_oh_my_posh() {
    if command_exists "oh-my-posh"; then
        return
    fi
    if [[ "$CI" == "true" ]]; then
        log_info "[CI] Would install oh-my-posh"
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
    | grep '/contrib/diff-highlight/diff-highlight$' || true)"

    if [[ -n "$diff_highlight_path" ]]; then
        if [[ "$CI" == "true" ]]; then
            log_info "[CI] Would install diff-highlight from $diff_highlight_path"
            return
        fi
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
    if [[ "$CI" == "true" ]]; then
        log_info "[CI] Would apt install: ${apts[*]}"
        return
    fi
    sudo apt update
    for pkg in "${apts[@]}"; do
        log_task "Install apt package: $pkg"
        sudo apt install -y "$pkg"
    done
}

install_cargos() {
    log_task "Installing tools using Cargo..."
    if [[ "$CI" == "true" ]]; then
        log_info "[CI] Would cargo install: ${cargos[*]}"
        return
    fi
    for pkg in "${cargos[@]}"; do
        log_task "Install cargo package: $pkg"
        cargo install "$pkg"
    done
}

install_snaps() {
    log_task "Installing Snap packages..."
    if [[ "$CI" == "true" ]]; then
        log_info "[CI] Would snap install: ${snaps[*]}"
        return
    fi
    for pkg in "${snaps[@]}"; do
        log_task "Install snap package: $pkg"
        # shellcheck disable=SC2086  # intentional: $pkg contains flags (e.g. "nvim --beta --classic")
        sudo snap install $pkg
    done
    sudo update-desktop-database /var/lib/snapd/desktop/applications
}

install_brews() {
    log_task "Installing Brew packages..."
    if [[ "$CI" == "true" ]]; then
        log_info "[CI] Would brew install: ${BREWS[*]:-<none>}"
        return
    fi
    for pkg in "${BREWS[@]}"; do
        log_task "Install brew package: $pkg"
        # shellcheck disable=SC2086  # intentional: $pkg may contain extra args
        brew install $pkg
    done
}

install_jetbrains_toolbox() {
    if compgen -G "/opt/jetbrains-toolbox*" > /dev/null 2>&1; then
        return
    fi
    if [[ "$CI" == "true" ]]; then
        log_info "[CI] Would install JetBrains Toolbox"
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
    if [[ "$CI" == "true" ]]; then
        log_info "[CI] Would configure WezTerm apt source"
        return
    fi
    curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /etc/apt/keyrings/wezterm-fury.gpg
    echo 'deb [signed-by=/etc/apt/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
}

set_system_key_bindings() {
    if [[ "$CI" == "true" ]]; then
        log_info "[CI] Would configure GNOME key bindings"
        return
    fi
    gsettings set org.gnome.settings-daemon.plugins.media-keys terminal "['<Super>t']"
    gsettings set org.gnome.desktop.default-applications.terminal exec-arg ''
    gsettings set org.gnome.desktop.default-applications.terminal exec 'wezterm'
    gsettings set org.gnome.desktop.wm.keybindings minimize "['<Super>Down', '<Super>e']"
    gsettings set org.gnome.desktop.wm.keybindings maximize "['<Super>Up', '<Super>i']"
    gsettings set org.gnome.desktop.wm.keybindings switch-applications "['<Super>Tab']"
    gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "['<Shift><Super>Tab']"
    gsettings set org.gnome.desktop.wm.keybindings switch-group "['<Super>comma']"
    gsettings set org.gnome.mutter.keybindings toggle-tiled-left "['<Primary><Super>Left', '<Primary><Super>n']"
    gsettings set org.gnome.mutter.keybindings toggle-tiled-right "['<Primary><Super>Right', '<Primary><Super>o']"
    gsettings set org.gnome.shell.extensions.pop-shell pop-monitor-left "['<Super><Shift>Left', '<Super><Shift>n']"
    gsettings set org.gnome.shell.extensions.pop-shell pop-monitor-right "['<Super><Shift>Right', '<Super><Shift>o']"
    gsettings set org.gnome.shell.extensions.pop-shell focus-left "['<Super>Left', '<Super>n']"
    gsettings set org.gnome.shell.extensions.pop-shell focus-right "['<Super>Right', '<Super>o']"
    gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Alt>Tab']"
    gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "['<Shift><Alt>Tab']"
    gsettings set org.gnome.shell.keybindings focus-active-notification "['']"
}

set_default_shell() {
    if [[ "$CI" == "true" ]]; then
        log_info "[CI] Would set default shell to: $DEFAULT_USER_SHELL"
        return
    fi
    set_shell="$(which "$DEFAULT_USER_SHELL")"
    chsh -s "$set_shell"
    log_info "Set default shell to $set_shell"
}

install_pipxs() {
    if [[ "$CI" == "true" ]]; then
        log_info "[CI] Would pipx install: ${PIPX_PACKAGES[*]}"
        return
    fi
    for pkg in "${PIPX_PACKAGES[@]}"; do
        log_task "Install pipx package: $pkg"
        pipx install --python="$(which python)" "$pkg"
    done
}

add_flathub_repo() {
    log_task "Add flathub repo"
    if [[ "$CI" == "true" ]]; then
        log_info "[CI] Would add Flathub remote"
        return
    fi
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
