My computer setup and dotfiles, managed with [chezmoi](https://www.chezmoi.io/)

## Project goals
- Cross-platform == Windows, Mac, Debian-based
- Unified set of apps, tools, commands and aliases
- Personal and work
- keymaps for Colemak-DH 

## TOC
- [Project State](#project-state)
- [Install](#install)
  - [Debian-based](#debian)
  - [Windows](#windows-semi-automated)
- [Tooling](#tooling)
  - [Terminals](#terminals)
  - [Shells](#shells)
  - [Package Managers](#package-managers)
  - [Apps](#apps)
  - [Other Notes](#other-notes)
- [💡 Inspirations](#-inspirations)

## Project State
- Debian-based
  - tested on Pop!_OS 22.04 LTS, Ubuntu 22.04 LTS
- MacOS
  - support TBD; when need arises
- Windows
  - tested on Windows 10, 11
  - No WSL support

## Install

### Debian
```shell
cd ~
curl -sfL https://git.io/chezmoi | sh
export PATH="$PATH:$HOME/bin"
export GITHUB_USERNAME="StephenGemin"
chezmoi init --apply -v https://github.com/$GITHUB_USERNAME/dotfiles.git
```

### MacOS
**For newer MacOS check `brew config` shows arm64 AND NOT x86_64**
`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`

```shell
brew install chezmoi
export GITHUB_USERNAME="StephenGemin"
chezmoi init --apply -v https://github.com/$GITHUB_USERNAME/dotfiles.git
```

### Windows (semi-automated)
- Recommend running in PowerShell (not pwsh)
	- run as non-admin (for scoop)
	- may need to change the execution policy(ies)
	- `Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser`
	- `Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine`
- install prereq dependencies
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
- To install fonts go to `~\.local\share\fonts`; find tff files, right-click desired files, and select**install**
- Install Whatsapp from MS store (unavailable from winget)
  - Ref microsoft/winget-pkgs issue 156231
- Add to PATH (if not there):
  - %USERPROFILE%\.pyenv\pyenv-win\shims
  - C:\Program Files\Git\cmd
  - C:\Program Files\Neovim\bin

### Tool specific
Manual setup steps for individual tools / apps

- [PyCharm](https://www.jetbrains.com/pycharm/)
  - Import settings from `~\.config`
- [neovim](https://neovim.io/)
  - Run `:MasonInstallAll` on first run


## Tooling
<span>✅==Supported</span> &nbsp; <span>❓==May support, unused or not tested</span> &nbsp; 🚫 <span>==Never support</span>

### Terminals
|  | **Deb** | **Win** | **Mac** |
|---|---|---|---|
| [WezTerm](https://wezfurlong.org/wezterm/) | ✅ | ✅ | ✅ |
| [Alacritty](https://github.com/alacritty/alacritty)* | ✅ | ✅ | ❓ |
| [Windows Terminal](https://github.com/microsoft/terminal) | 🚫 | ✅ | 🚫 |

*No tmux yet for Alacritty

### Shells
|  | **Deb** | **Win** | **Mac** | **Notes** |
|---|---|---|---|---|
| [Zsh](https://www.zsh.org/) | ✅ | 🚫 | ✅ | Slow on Windows, see [Other Notes](#other-notes) |
| [Bash](https://www.gnu.org/software/bash/) | ✅ | ✅ | ❓ | Slow on Windows |
| [PowerShell](https://github.com/PowerShell/PowerShell) | 🚫 | ✅ | 🚫 |  |

### Package Managers
- **Debian:** [apt](https://wiki.debian.org/Apt) / [snap](https://snapcraft.io/docs) / [flatpak](https://flatpak.org/) / [linuxbrew](https://docs.brew.sh/Homebrew-on-Linux/) / [cargo](https://doc.rust-lang.org/cargo/)
- **Windows:** [winget](https://github.com/microsoft/winget-cli)
- **Mac:** [brew](https://brew.sh/)

### Apps / Tools
|  | **Deb** | **Win** | **Mac** | **Notes** |
|---|---|---|---|---|
| [Chezmoi](https://www.chezmoi.io/) | ✅ | ✅ | ✅ |  |
| [Git](https://git-scm.com/) | ✅ | ✅ | ✅ |  |
| [Double Commander](https://doublecmd.sourceforge.io/) | ✅ | ✅ | ✅ |  |
| [KeePassXC](https://keepassxc.org/) | ✅ | ✅ | ✅ | No Chezmoi integration yet |
| [Neovim](https://neovim.io/) | ✅ | ✅ | ✅ | [NVChad](https://github.com/NvChad/NvChad) and [nvim-starter](https://github.com/StephenGemin/nvim-starter) |
| [Vim](https://www.vim.org/) | ✅ | ✅ | ✅ |  |
| [Nano](https://www.nano-editor.org/) | ✅ | 🚫 | ✅ |  |
| [Oh-My-Posh](https://ohmyposh.dev/) | ✅ | ✅ | ✅ |  |
| [Zinit](https://zdharma.github.io/zinit/wiki/Home/) | ✅ | ✅ | ✅ |  |
| [Oh-My-Zsh](https://ohmyz.sh/) | ✅ | ✅ | ✅ | Via Zinit |
| [Ripgrep](https://github.com/BurntSushi/ripgrep) | ✅ | ✅ | ✅ |  |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | ✅ | ✅ | ✅ |  |
| [fzf](https://github.com/junegunn/fzf) | ✅ | ✅ | ✅ |  |
| [pyenv](https://github.com/pyenv/pyenv) | ✅ | ✅ | ✅ | Windows uses [pyenv-win](https://github.com/pyenv-win) |
| [VLC](https://www.videolan.org/vlc/) | ✅ | ✅ | ✅ |  |
| [Firefox](https://www.mozilla.org/firefox/) | ✅ | ✅ | ✅ |  |
| [Opera](https://www.opera.com/) | ✅ | ✅ | ✅ |  |
| [Notion](https://www.notion.so/) | ✅ | ✅ | ✅ |  |
| [JetBrains IDEs](https://www.jetbrains.com/toolbox-app/) | ✅ | ✅ | ✅ |  |
| [Visual Studio Code](https://code.visualstudio.com/) | ✅ | ✅ | ✅ |  |
| [F.lux](https://justgetflux.com/) | ✅ | ✅ | ✅ooo | Linux uses [Redshift](https://github.com/jonls/redshift) |
| [Notepad++](https://notepad-plus-plus.org/) | 🚫 | ✅ | 🚫 |  |
| [MSYS2](https://www.msys2.org/) | 🚫 | ✅ | 🚫 |  |

## Other Notes

### Windows
- To get zsh working on Windows:
  - Install MSYS2; `pacman -S zsh`
  - Modified `C:\msys64\etc\nsswitch.conf` (see below)
- Initial attempt to use zsh did not go well
  - terminal was very sluggish
  - tried in Alacritty, MSYS2, MSYS (Git Bash) and Windows Terminal
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

## 💡 Inspirations
- [renemarc/dotfiles](https://github.com/renemarc/dotfiles)
- [felipecrs/dotfiles](https://github.com/felipecrs/dotfiles)
- [dreamsofcode](https://www.youtube.com/@dreamsofcode)
- [dreamsofautonomy](https://www.youtube.com/@dreamsofautonomy)
- [KevinSilvester/wezterm-config](https://github.com/KevinSilvester/wezterm-config)
- [Phantas0s/.dotfiles](https://github.com/Phantas0s/.dotfiles)
