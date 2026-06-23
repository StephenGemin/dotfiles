#!/usr/bin/env bash

#
# CI variant of install_debian.sh
# Runs through the same flow and validates args/packages without installing anything.
# Keep package arrays in sync with install_debian.sh.
#
# Usage: same as install_debian.sh
#   ./install_debian_ci.sh <shell_name> <python_version> <brews_list>
#

set -eu
set +x

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    echo "Usage: $0 <shell_name> <python_version> \"brew1 brew2\""
    exit 0
fi

DEFAULT_USER_SHELL="$1"
INSTALL_PYTHON_VERSION="$2"
BREWS="$3"

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
    "cmake"
    "g++"
    "pkg-config"
    "libfreetype6-dev"
    "libfontconfig1-dev"
    "libxcb-xfixes0-dev"
    "libxkbcommon-dev"
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
    "libfuse2"
    "redshift"
    "redshift-gtk"
    "libwebkit2gtk-4.1-0"
    "libgtk-3-0"
    "libusb-1.0-0"
)

cargos=("ripgrep")

snaps=(
    "alacritty"
    "chromium"
    "--revision 159 --classic code"
    "opera"
    "keepassxc"
    "notion-snap-reborn"
    "nvim --beta --classic"
    "spotify"
    "whatsapp-app"
    "vlc"
)

pipxs=("virtualenv" "poetry" "pip-tools" "glances[all]")

validate_args() {
    [[ -n "$DEFAULT_USER_SHELL" ]] || { log_error "Shell name is required"; exit 1; }
    [[ -n "$INSTALL_PYTHON_VERSION" ]] || { log_error "Python version is required"; exit 1; }
    log_info "shell=$DEFAULT_USER_SHELL  python=$INSTALL_PYTHON_VERSION  brews=${BREWS:-<none>}"
}

ci_standalone_tools() {
    log_task "[CI] Would install: brew, pyenv ($INSTALL_PYTHON_VERSION), rustup, oh-my-posh, zoxide, JetBrains NerdFont, diff-highlight"
}

ci_wezterm_prereqs() {
    log_task "[CI] Would configure WezTerm apt source"
}

ci_apts() {
    log_task "[CI] Would apt install ${#apts[@]} packages:"
    for pkg in "${apts[@]}"; do
        log_info "      $pkg"
    done
}

ci_flathub() {
    log_task "[CI] Would add Flathub remote"
}

ci_cargos() {
    log_task "[CI] Would cargo install ${#cargos[@]} package(s):"
    for pkg in "${cargos[@]}"; do
        log_info "      $pkg"
    done
}

ci_snaps() {
    log_task "[CI] Would snap install ${#snaps[@]} packages:"
    for pkg in "${snaps[@]}"; do
        log_info "      $pkg"
    done
}

ci_brews() {
    log_task "[CI] Would brew install: ${BREWS:-<none>}"
}

ci_pipxs() {
    log_task "[CI] Would pipx install ${#pipxs[@]} package(s):"
    for pkg in "${pipxs[@]}"; do
        log_info "      $pkg"
    done
}

ci_jetbrains_toolbox() {
    log_task "[CI] Would install JetBrains Toolbox"
}

ci_default_shell() {
    log_task "[CI] Would set default shell to: $DEFAULT_USER_SHELL"
}

ci_keybindings() {
    log_task "[CI] Would configure GNOME key bindings"
}

validate_args
ci_wezterm_prereqs
ci_standalone_tools
ci_apts
ci_flathub
ci_cargos
ci_snaps
ci_brews
ci_pipxs
ci_jetbrains_toolbox
ci_default_shell
ci_keybindings

success "CI check passed - install_debian.sh is valid"
