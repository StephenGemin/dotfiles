# dotfiles

> One source tree → **Windows, macOS, and Debian-based Linux**. No WSL. Colemak-DH. Personal *and* work.

[![CI](https://github.com/StephenGemin/dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/StephenGemin/dotfiles/actions/workflows/ci.yml)
[![Managed with chezmoi](https://img.shields.io/badge/managed%20with-chezmoi-2088FF)](https://www.chezmoi.io/)
[![Platforms](https://img.shields.io/badge/platforms-Linux%20%C2%B7%20macOS%20%C2%B7%20Windows-informational)](#project-state)
[![License: Unlicense](https://img.shields.io/badge/license-Unlicense-blue.svg)](LICENSE)

My personal, cross-platform machine setup, managed with [chezmoi](https://www.chezmoi.io/).
The repo is the source of truth; `chezmoi apply` renders it into `$HOME` on every machine I
touch, so a fresh laptop is one command away from feeling like home.

<!-- TODO: drop a terminal screenshot/GIF here (WezTerm + oh-my-posh + Colemak-DH) — this is the
     single biggest thing that earns stars on a dotfiles repo. e.g. ![preview](docs/preview.png) -->

## ✨ Highlights

- **One source tree → three OSes.** Windows, macOS, and Debian-based Linux render from the same
  repo — no WSL, no per-machine forks — giving one unified set of apps, tools, and aliases everywhere.
- **Idempotent & convention-driven.** Built on chezmoi templates, `.chezmoidata`, and
  `run_onchange_` scripts; `chezmoi apply` is safe to run twice and CI verifies there's no drift.
- **A cohesive terminal stack.** WezTerm, oh-my-posh, Neovim (NVChad), fzf, ripgrep,
  zoxide, and a `pyenv` + `uv` + `ruff` Python toolchain.
- **Home *and* work aware.** An `install_host = home | work` prompt at init time switches package
  sets and config from the same source.
- **Colemak-DH first.** Keymaps tuned for the [Colemak-DH](https://colemakmods.github.io/mod-dh/) layout.

## Table of contents

- [Highlights](#-highlights)
- [Project state](#project-state)
- [Install](#install)
  - [Debian-based Linux](#debian-based-linux)
  - [macOS](#macos)
  - [Windows (semi-automated)](#windows-semi-automated)
  - [Per-tool setup](#per-tool-setup)
- [Tooling](#tooling)
  - [Terminals](#terminals)
  - [Shells](#shells)
  - [Package managers](#package-managers)
  - [Apps & tools](#apps--tools)
  - [Notes](#notes)
- [License](#license)
- [💡 Inspirations](#-inspirations)

## Project state

_The platforms I've actually verified `chezmoi apply` on:_

| OS | Tested on |
|---|---|
| **Debian-based Linux** | Pop!_OS 22.04 LTS, Ubuntu 22.04 LTS |
| **macOS** | macOS 15 Sequoia |
| **Windows** | Windows 10, 11 — *no WSL support* |

## Install

`chezmoi init` will prompt for a few values the first time (git username, git email,
`work`/`home` install type, and — on Windows — the Git install path), then render and apply
everything.

### Debian-based Linux

```shell
cd ~
sh -c "$(curl -fsLS get.chezmoi.io)"
export PATH="$PATH:$HOME/bin"
export GITHUB_USERNAME="StephenGemin"
chezmoi init --apply -v https://github.com/$GITHUB_USERNAME/dotfiles.git
```

### macOS

> **For Apple Silicon, confirm `brew config` shows `arm64` and NOT `x86_64`.**

```shell
# Install Homebrew first if you don't have it:
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install chezmoi
export GITHUB_USERNAME="StephenGemin"
chezmoi init --apply -v https://github.com/$GITHUB_USERNAME/dotfiles.git
```

### Windows (semi-automated)

<details>
<summary>Expand Windows install steps</summary>

- Run the prerequisite installs in **Windows PowerShell 5.1** (the `powershell`
  that ships with Windows) — pwsh might not be installed by this point.
  - run as non-admin (for scoop)
  - may need to change the execution policy(ies):
    - `Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser`
    - `Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine`
- Install prerequisite dependencies:

  ```pwsh
  get-Command winget  # check winget installed
  # if missing:
  # 1. download winget from MS store
  # 2. If MS store is blocked (typically work env) then install from .msixbundle
  #    - https://github.com/microsoft/winget-cli/releases/latest
  #    - double click downloaded file to install
  #    - if this is also blocked, can install from powershell command `Add-AppxPackage -Path "PATH_TO_FILE"`
  #    - may need to install missing deps for winget based on errors.
  #      - i.e. Github microsoft/winget-cli issue 4916

  winget install -e --id Git.Git
  winget install Microsoft.PowerShell
  winget install twpayne.chezmoi
  $GITHUB_USERNAME = "StephenGemin"
  chezmoi init --apply https://github.com/$GITHUB_USERNAME/dotfiles.git
  ```

- May need to install MSYS2 manually
- NeoVim with NVChad
  - ***Do not start Neovim until NVChad reqs are installed!***
  - Install dependencies for NVChad (use MSYS2)
    - `pacman -S --needed base-devel mingw-w64-ucrt-x86_64-toolchain`
    - `pacman -S make gcc`
- To install fonts go to `~\.local\share\fonts`; find ttf files, right-click desired files, and select **install**
- Install WhatsApp from MS store (unavailable from winget)
  - Ref microsoft/winget-pkgs issue 156231
- Add to PATH (if not there):
  - `%USERPROFILE%\.pyenv\pyenv-win\shims`
  - `C:\Program Files\Git\cmd`
  - `C:\Program Files\Neovim\bin`

</details>

### Per-tool setup

Manual setup steps for individual tools / apps:

- [PyCharm](https://www.jetbrains.com/pycharm/) — Import settings from `~\.config`
- [Neovim](https://neovim.io/) — Run `:MasonInstallAll` on first run

## Tooling

**Legend:** ✅ supported · ❓ may work (untested / unused) · 🚫 not supported

### Terminals

|  | **Deb** | **Win** | **Mac** |
|---|---|---|---|
| [WezTerm](https://wezfurlong.org/wezterm/) | ✅ | ✅ | ✅ |
| [Windows Terminal](https://github.com/microsoft/terminal) | 🚫 | ✅ | 🚫 |

### Shells

|  | **Deb** | **Win** | **Mac** | **Notes** |
|---|---|---|---|---|
| [Zsh](https://www.zsh.org/) | ✅ | 🚫 | ✅ | Slow on Windows, see [Notes](#notes) |
| [Bash](https://www.gnu.org/software/bash/) | ✅ | ✅ | ❓ | Slow on Windows |
| [PowerShell](https://github.com/PowerShell/PowerShell) | 🚫 | ✅ | 🚫 |  |

### Package managers

Language-agnostic managers, per OS:

- **Debian:** [apt](https://wiki.debian.org/Apt) / [snap](https://snapcraft.io/docs) / [flatpak](https://flatpak.org/) / [linuxbrew](https://docs.brew.sh/Homebrew-on-Linux/) / [cargo](https://doc.rust-lang.org/cargo/)
- **Windows:** [winget](https://github.com/microsoft/winget-cli) / [scoop](https://scoop.sh/)
- **macOS:** [brew](https://brew.sh/)

> Full package lists are the source of truth in
> [`.chezmoidata/brew.yaml`](.chezmoidata/brew.yaml) (macOS / Linux brew),
> [`scripts/install_debian.sh`](scripts/install_debian.sh) (apt / snap / cargo), and
> [`.chezmoitemplates/winget_packages_home.json`](.chezmoitemplates/winget_packages_home.json) (Windows).

### Apps & tools

|  | **Deb** | **Win** | **Mac** | **Notes** |
|---|---|---|---|---|
| [Chezmoi](https://www.chezmoi.io/) | ✅ | ✅ | ✅ |  |
| [Git](https://git-scm.com/) | ✅ | ✅ | ✅ | git-lfs / git-extras |
| [Neovim](https://neovim.io/) | ✅ | ✅ | ✅ | [NVChad](https://github.com/NvChad/NvChad) via [nvim-starter](https://github.com/StephenGemin/nvim-starter) |
| [Vim](https://www.vim.org/) | ✅ | ✅ | ✅ |  |
| [Nano](https://www.nano-editor.org/) | ✅ | 🚫 | ✅ |  |
| [Notepad++](https://notepad-plus-plus.org/) | 🚫 | ✅ | 🚫 |  |
| [Visual Studio Code](https://code.visualstudio.com/) | ✅ | ✅ | ✅ |  |
| [JetBrains IDEs](https://www.jetbrains.com/toolbox-app/) | ✅ | ✅ | ✅ |  |
| [Oh-My-Posh](https://ohmyposh.dev/) | ✅ | ✅ | ✅ |  |
| [Zinit](https://github.com/zdharma-continuum/zinit) | ✅ | 🚫 | ✅ | Zsh plugin manager |
| [Oh-My-Zsh](https://ohmyz.sh/) | ✅ | 🚫 | ✅ | Plugins loaded via Zinit |
| [Ripgrep](https://github.com/BurntSushi/ripgrep) | ✅ | ✅ | ✅ |  |
| [fzf](https://github.com/junegunn/fzf) | ✅ | ✅ | ✅ |  |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | ✅ | ✅ | ✅ |  |
| [pyenv](https://github.com/pyenv/pyenv) | ✅ | ✅ | ✅ | Windows uses [pyenv-win](https://github.com/pyenv-win/pyenv-win) |
| [uv](https://github.com/astral-sh/uv) | ✅ | ✅ | ✅ |  |
| [Ruff](https://github.com/astral-sh/ruff) | ✅ | ✅ | ✅ |  |
| [GitHub CLI](https://cli.github.com/) | ✅ | ✅ | ✅ |  |
| [PlantUML](https://plantuml.com/) / [Graphviz](https://graphviz.org/) | ✅ | ❓ | ✅ |  |
| [Double Commander](https://doublecmd.sourceforge.io/) | ✅ | ✅ | ✅ |  |
| [KeePassXC](https://keepassxc.org/) | ✅ | ✅ | ✅ | No chezmoi integration yet |
| [VLC](https://www.videolan.org/vlc/) | ✅ | ✅ | ✅ |  |
| [Firefox](https://www.mozilla.org/firefox/) | ✅ | ✅ | ✅ |  |
| [Opera](https://www.opera.com/) | ✅ | ✅ | ✅ |  |
| [Chromium](https://www.chromium.org/) | ✅ | ❓ | ❓ |  |
| [Notion](https://www.notion.so/) | ✅ | ✅ | ✅ |  |
| [WhatsApp](https://www.whatsapp.com/) | ✅ | ✅ | ❓ | Windows: install from MS Store |
| [F.lux](https://justgetflux.com/) | ✅ | ✅ | ✅ | Linux uses [Redshift](https://github.com/jonls/redshift) |
| [Wireshark](https://www.wireshark.org/) | ❓ | ❓ | ✅ |  |
| [LibreOffice](https://www.libreoffice.org/) | ❓ | ❓ | ✅ |  |
| [MSYS2](https://www.msys2.org/) | 🚫 | ✅ | 🚫 |  |

Platform-specific extras not listed above (e.g. JupyterLab, scrcpy, Java/Temurin, Zoom, 7-Zip,
ShareX, Tesseract OCR, DB Browser for SQLite) live in the data files linked under
[Package managers](#package-managers).

### Notes

#### Windows

- To get zsh working on Windows:
  - Install MSYS2; `pacman -S zsh`
  - Modify `C:\msys64\etc\nsswitch.conf` (see below)
- Initial attempt to use zsh did not go well:
  - terminal was very sluggish
  - tried in MSYS2, MSYS (Git Bash) and Windows Terminal
  - issues accessing Windows tooling
  - difficult working with Windows paths
  - **Decided to use PowerShell on Windows**

```text
# Begin /etc/nsswitch.conf

passwd: files db
group: files db

db_enum: cache builtin

db_shell: /usr/bin/zsh
db_home: /c/Users/USERNAME
db_env: windows
#db_home: cygwin desc
#db_shell: cygwin desc
#db_gecos: cygwin desc

# End /etc/nsswitch.conf
```

## License

Released into the public domain under [The Unlicense](LICENSE). Copy, adapt, and reuse freely.

## 💡 Inspirations

- [renemarc/dotfiles](https://github.com/renemarc/dotfiles)
- [felipecrs/dotfiles](https://github.com/felipecrs/dotfiles)
- [dreamsofcode](https://www.youtube.com/@dreamsofcode)
- [dreamsofautonomy](https://www.youtube.com/@dreamsofautonomy)
- [KevinSilvester/wezterm-config](https://github.com/KevinSilvester/wezterm-config)
- [Phantas0s/.dotfiles](https://github.com/Phantas0s/.dotfiles)
