## About
My personal dotfiles, managed with [chezmoi](https://www.chezmoi.io/). This project aims to automate my setup.

## Project goals
- Cross-platform == Windows, Mac, Debian-based
- Unified, cross-platform tools, aliases and commands
- Setups for personal vs. work

## TOC
- [Project State | Decisions](#project-state--decisions)
- [Setup Notes](#setup-notes)
- [Tooling](#tooling)
  - [Terminals](#terminals)
  - [Shells](#shells)
  - [Package Managers](#package-managers)
  - [Apps](#apps)
  - [Other Notes](#other-notes)
- [💡 Inspirations](#-inspirations)

## Project State | Decisions
- Windows 
  - fully up and running
  - Decided to support Windows vs WSL. There are times where Windows cannot be avoided.
- Debian
  - in-progress
- MacOS
  - support TBD; when need arises

## Setup Notes
- Windows (semi-automated)
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
  - Install fonts in `~\.local\share\fonts`; right-click and select **install**
  - Install Whatsapp from MS store (unavailable from winget)
    - Ref microsoft/winget-pkgs issue 156231
  - Add to PATH (if not there):
    - %USERPROFILE%\.pyenv\pyenv-win\shims
    - C:\Program Files\Git\cmd
    - C:\Program Files\Neovim\bin
  - Import PyCharm settings from `~\.config`
- Debian
    ```shell
    sh -c "$(curl -fsLS get.chezmoi.io)"
    sudo mv ~/bin/chezmoi /bin/chezmoi
    chezmoi init https://github.com/StephenGemin/dotfiles.git    ```
- [NVChad](https://nvchad.com/docs/quickstart/install/)
  - Run `:MasonInstallAll` on first run

## Tooling
❓ <span>== May support, unused or not tested</span> &nbsp; 🚫 <span>== Never support</span>

### Terminals
|  | **Debian** | **Windows** | **Mac** |
|---|---|---|---|
| Alacritty | ❓ | ✅ | ❓ |
| Win Terminal | 🚫 | ✅ | 🚫 |
| Mac Terminal | 🚫 | 🚫 | ✅ |

### Shells
|  | **Debian** | **Windows** | **Mac** | **Notes** |
|---|---|---|---|---|
| Bash | ❓ | ✅ | ❓ | slow on Windows |
| Zsh | ✅ | ✅ | ✅ | slow on Windows see [Other Notes](#other-notes) |
| PowerShell | ❓ | ✅ | ❓ |  |

### Package Managers
- Debian: dpkg
- Windows: winget
- Mac: brew

### Apps
|  | **Debian** | **Windows** | **Mac** | **Notes** |
|---|---|---|---|---|
| Chezmoi | ✅ | ✅ | ✅ |  |
| Git | ✅ | ✅ | ✅ |  |
| Double Commander | ❓ | ✅ | ❓ |  |
| Oh-My-Posh | ❓ | ✅ | ❓ |  |
| Neovim | ✅ | ✅ | ❓ |  |
| NVChad | ✅ | ✅ | ❓ |  |
| zoxide | ✅ | ✅ | ❓ |  |
| Ripgrep | ✅ | ✅ | ❓ |  |
| Zinit | ✅ | ✅ | ❓ | zsh only |
| Oh-My-Zsh | ✅ | ✅ | ❓ | zsh only |
| pyenv | ✅ | ✅ | ❓ | Windows uses pyenv-win |
| Nano | ✅ | ❓ | ✅ |  |
| VLC | ✅ | ✅ | ❓ |  |
| Firefox | ✅ | ✅ | ❓ |  |
| Opera | ✅ | ✅ | ❓ |  |
| Notion | ❓ | ✅ | ❓ |  |
| JetBrains IDEs | ✅ | ✅ | ❓ |  |
| VSC | ✅ | ✅ | ❓ |  |
| F.lux | ❓ | ✅ | ❓ |  |
| NotePad ++ | 🚫 | ✅ | 🚫 |  |
| MSYS2 | 🚫 | ✅ | 🚫 |  |

## Other Notes

### Windows
- To get zsh working on Windows:
  - Installed MSYS2 then ran `pacman -S zsh`
  - Modified `C:\msys64\etc\nsswitch.conf` (see below)
- Initial attempt to use zsh did not go well
  - terminal was very sluggish
  - tried in Alacritty, MSYS2, MSYS (Git Bash) and Windows Terminal
  - issues accessing Windows tooling 
  - difficult working with Windows paths
  - **Decided to switch to PowerShell for Windows**

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
