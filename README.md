## About
My personal dotfiles, managed with [chezmoi](https://www.chezmoi.io/)

## Project goals
- Cross-platform == Windows, Mac, Linux PopOS/Ubuntu
- Cross-platform toolset
- Unified, cross-platform set of aliases and commands
- Setups for personal vs. work

## TOC
- [Project State | Decisions](#project-state--decisions)
- [Setup Notes](#setup-notes)
- [Tooling](#tooling)
  - [Terminals](#terminals)
  - [Shells](#shells)
  - [Package Managers](#package-managers)
  - [Apps](#apps)
- [💡 Inspirations](#-inspirations)

## Project State | Decisions
- Windows 
  - fully up and running
  - Decided to support Windows vs WSL. There are times where Windows cannot be avoided.
- Linux
  - next on the list
- MacOS
  - support TBD; when need arises

## Setup Notes
- Windows
  - Recommend init commands in PowerShell (not pwsh)
  - [chezmoi install](https://www.chezmoi.io/install)
    - `winget install twpayne.chezmoi`
  - `winget install -e --id Git.Git`
  - May need to install MSYS2 manually
  - Do not start Neovim until NVChad reqs are installed!
  - Install packages for NVChad (use MSYS2)
    - `pacman -S --needed base-devel mingw-w64-ucrt-x86_64-toolchain`
    - `pacman -S make gcc zsh`

## Tooling
❓ <span>== May support; but not right now</span> &nbsp; 🚫 <span>== Never support</span>

### Terminals
|  | **Linux** | **Windows** | **Mac** |
|---|---|---|---|
| Alacritty | ✅ | ✅ | ✅ |
| Win Terminal | 🚫 | ✅ | 🚫 |
| Mac Terminal | 🚫 | 🚫 | ✅ |

### Shells
|  | **Linux** | **Windows** | **Mac** | **Notes** |
|---|---|---|---|---|
| Bash | ❓ | ✅ | ❓ | Bash support limited; slow on Windows |
| Zsh | ❓ | ✅ | ✅ | zsh on Windows is very slow |
| PowerShell | ❌ | ✅ | ❌ |  |

### Package Managers
- Linux: APT/Dpkg
- Windows: winget
- Mac: brew

### Apps
|  | **Linux** | **Windows** | **Mac** | **Notes** |
|---|---|---|---|---|
| Chezmoi | ✅ | ✅ | ✅ |  |
| Git | ✅ | ✅ | ✅ |  |
| Oh-My-Posh | ❓ | ✅ | ❓ |  |
| Neovim | ❓ | ✅ | ❓ |  |
| NVChad | ❓ | ✅ | ❓ |  |
| Nano | ❓ | 🚫 | ✅ | N/A for Windows |
| MSYS2 | 🚫 | ✅ | 🚫 |  |
| Double Commander | ❓ | ✅ | ❓ |  |
| NotePad ++ | 🚫 | ✅ | 🚫 |  |
| zoxide | ❓ | ✅ | ❓ |  |
| Ripgrep | ❓ | ✅ | ❓ |  |
| Zinit | ❓ | ✅ | ❓ | zsh only |
| Oh-My-Zsh | ❓ | ✅ | ❓ | zsh only |

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
