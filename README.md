# Zsh Setup Script

This repository contains a Zsh setup script that installs and configures essential tools and aliases for a better terminal experience.

## Installed Tools

The script checks and installs the following tools if missing:

- `zsh` – Z Shell
- `eza` – modern replacement for `ls`
- `btop` – advanced replacement for `top`
- `git` – version control
- `wget` – command-line downloader
- `unzip` – extract compressed files
- `fc-cache` / `fontconfig` – for font management
- `nvim` – Neovim editor
- `neofetch` – system information display
- `Powerlevel10k` – display-TTY
## Features

- Automatically sets up aliases and command replacement reminders
- Optionally displays reminders for command replacements at shell startup
- Integrates Neofetch for system info display in interactive shells
- Configures a colorful reminder function `show_replacements` aliased as `remind`

## Installation

Clone this repository:

```bash
git clone https://github.com/sz0g0n/pretty-terminal-script.git
cd pretty-terminal-script
chmod +x pretty-SHELL.sh
./pretty-SHELL.sh
```

## Third-party tools and licenses

This project uses the following third-party software:

- zsh: MIT License - https://www.zsh.org/
- eza: MIT License - https://github.com/eza-community/eza
- btop: GPLv3 - https://github.com/aristocratos/btop
- git: GPLv2 - https://git-scm.com/
- wget: GPLv3 - https://www.gnu.org/software/wget/
- unzip: Info-ZIP License - https://infozip.sourceforge.net/
- fontconfig: MIT License - https://www.freedesktop.org/wiki/Software/fontconfig/
- neovim: Apache License 2.0 - https://neovim.io/
- neofetch: MIT License - https://github.com/dylanaraps/neofetch
- dust: MIT License - https://github.com/bootandy/dust
- dfc: GPLv3 - https://github.com/rolinh/dfc
- Powerlevel10k (p10k) – https://github.com/romkatv/powerlevel10k
