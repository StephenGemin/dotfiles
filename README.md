## About
My computer setup and dotfiles, managed with [chezmoi](https://www.chezmoi.io/)

## Project goals
- Cross-platform == Windows, Mac, Debian-based
- Unified set of apps, tools, commands and aliases
- Personal and work

## TOC
- [Project State | Decisions](#project-state--decisions)
- [Setup Notes](#setup-notes)
  - [Debian-based](#debian)
  - [Windows](#windows-semi-automated)
- [Tooling](#tooling)
  - [Terminals](#terminals)
  - [Shells](#shells)
  - [Package Managers](#package-managers)
  - [Apps](#apps)
  - [Other Notes](#other-notes)
- [💡 Inspirations](#-inspirations)

## Project State | Decisions
- Debian-based
  - tested on Pop!_OS 22.04 LTS, Ubuntu 22.04 LTS
- MacOS
  - support TBD; when need arises
- Windows
  - tested on Windows10
  - decided to support Windows vs WSL. There are times where Windows cannot be avoided.

## Install

### Debian
```shell
cd ~
curl -sfL https://git.io/chezmoi | sh
export PATH="$PATH:$HOME/bin"
export GITHUB_USERNAME="StephenGemin"
chezmoi init --apply https://github.com/$GITHUB_USERNAME/dotfiles.git
```

### Windows (semi-automated)
- Recommend init commands in PowerShell (not pwsh)
- **Must have `winget`**
- `winget install twpayne.chezmoi`
- `winget install -e --id Git.Git`
- May need to install MSYS2 manually
- NeoVim with NVChad
  - ***Do not start Neovim until NVChad reqs are installed!***
  - Install dependencies for NVChad (use MSYS2)
    - `pacman -S --needed base-devel mingw-w64-ucrt-x86_64-toolchain`
    - `pacman -S make gcc zsh`
- To install fonts go to `~\.local\share\fonts`; find tff files, right-click desired files, and select**install**
- Install Whatsapp from MS store (unavailable from winget)
  - Ref microsoft/winget-pkgs issue 156231
- Add to PATH (if not there):
  - %USERPROFILE%\.pyenv\pyenv-win\shims
  - C:\Program Files\Git\cmd
  - C:\Program Files\Neovim\bin

### Tool specific 
- PyCharm
  - Import settings from `~\.config`
- [NVChad](https://nvchad.com/docs/quickstart/install/)
  - Run `:MasonInstallAll` on first run

## Tooling
<span>✅==Supported</span> &nbsp; <span>❓==May support, unused or not tested</span> &nbsp; 🚫 <span>==Never support</span>

### Terminals
|  | **Debian** | **Windows** | **Mac** |
|---|---|---|---|
| Alacritty | ✅ | ✅ | ❓ |
| GNOME Terminal | ✅ | 🚫 | 🚫 |
| Mac Terminal | 🚫 | 🚫 | ✅ |
| Win Terminal | 🚫 | ✅ | 🚫 |

### Shells
|  | **Debian** | **Windows** | **Mac** | **Notes** |
|---|---|---|---|---|
| Zsh | ✅ | 🚫 | ❓ | slow on Windows see [Other Notes](#other-notes) |
| Bash | ❓ | ✅ | ❓ | slow on Windows |
| PowerShell | ❓ | ✅ | ❓ |  |

### Package Managers
- Debian: apt/snap/brew/cargo
- Windows: winget
- Mac: brew

### Apps / Tools
|  | **Debian** | **Windows** | **Mac** | **Notes** |
|---|---|---|---|---|
| Chezmoi | ✅ | ✅ | ✅ |  |
| Git | ✅ | ✅ | ✅ |  |
| Double Commander | ✅ | ✅ | ❓ |  |
| KeePassXC | ✅ | ✅ | ❓ | no integration with chezmoi yet  |
| Neovim | ✅ | ✅ | ❓ | with NVChad |
| Vim | ✅ | ✅ | ❓ |  |
| Nano | ✅ | ❓ | ✅ |  |
| Oh-My-Posh | ✅ | ✅ | ❓ |  |
| Zinit | ✅ | ✅ | ❓ |  |
| Oh-My-Zsh | ✅ | ✅ | ❓ | via Zinit |
| Ripgrep | ✅ | ✅ | ❓ |  |
| zoxide | ✅ | ✅ | ❓ |  |
| fzf | ✅ | ✅ | ❓ |  |
| pyenv | ✅ | ✅ | ❓ | Windows uses pyenv-win |
| VLC | ✅ | ✅ | ❓ |  |
| Firefox | ✅ | ✅ | ❓ |  |
| Opera | ✅ | ✅ | ❓ |  |
| Notion | ✅ | ✅ | ❓ |  |
| JetBrains IDEs | ✅ | ✅ | ❓ |  |
| VSC | ✅ | ✅ | ❓ |  |
| F.lux | ✅ | ✅ | ❓ | Linux uses Redshift |
| NotePad ++ | 🚫 | ✅ | 🚫 |  |
| MSYS2 | 🚫 | ✅ | 🚫 |  |

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
