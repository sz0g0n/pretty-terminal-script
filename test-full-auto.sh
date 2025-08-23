#!/bin/bash

set -e

# ===== 1. Potwierdzenie =====

echo ""
echo -e '\033[0;32mTen skrypt automatycznie skonfiguruje wygląd terminala i ustawi zsh jako domyślną powłokę.\033[0m'
echo -e '\033[0;32mMoże zmienić Twoje konfiguracje w niektórych plikach (zrobiony zostanie backup).\033[0m'
echo -e '\033[0;31mPAMIĘTAJ: ustaw czcionkę w terminalu na MERLO po zakończeniu!\033[0m'
echo ""
read -p $'Czy chcesz kontynuować? (\033[0;32mtak\033[0m/\033[0;31mnie\033[0m): ' CONFIRM
if [[ "$CONFIRM" != "tak" ]]; then
    echo "Przerwano."
    exit 0
fi

# ===== 2. Wykrycie dystrybucji =====
if [ -f /etc/os-release ]; then
    . /etc/os-release
else
    echo "Nie wykryto /etc/os-release"
    exit 1
fi

DIST_NAME="$ID"
[[ "$ID" == "arch" ]] && DIST_NAME="$DIST_NAME (btw)"
echo -e "Wykryta dystrybucja: \033[0;34m$DIST_NAME\033[0m"
echo ""

install_if_missing() {
    CMD=$1
    PKG=$2
    if ! command -v "$CMD" &>/dev/null; then
        echo "Instaluję $PKG..."
        case "$ID" in
            ubuntu|debian|linuxmint|pop)
                sudo apt update
                sudo apt install -y "$PKG"
                ;;
            fedora|rhel|centos|rocky|almalinux)
                sudo dnf install -y "$PKG"
                ;;
            arch|manjaro)
                sudo pacman -Syu --noconfirm "$PKG"
                ;;
            opensuse*|sles)
                sudo zypper refresh
                sudo zypper install -y "$PKG"
                ;;
        esac
    else
        echo "$PKG już zainstalowany, pomijam."
    fi
}

# ===== 2a. Instalacja pakietów =====
install_if_missing zsh zsh
install_if_missing eza eza
install_if_missing btop btop
install_if_missing git git
install_if_missing wget wget
install_if_missing unzip unzip
install_if_missing fc-cache fontconfig
install_if_missing nvim neovim
install_if_missing neofetch neofetch
install_if_missing bat bat

# ===== 2b. Czcionki konsoli (Debian/Ubuntu) =====
if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
    CONSOLE_FONT="/usr/share/consolefonts/MesloLGLDZNerdFontMono-Regular.psf"
    if [ ! -f "$CONSOLE_FONT" ]; then
        PSF_DIR="/usr/share/consolefonts"
        PSF_FILE="$PSF_DIR/MesloLGLDZNerdFontMono-Regular.psf"
        sudo mkdir -p "$PSF_DIR"
        sudo wget -q -O "$PSF_FILE" "https://github.com/sz0g0n/pretty-terminal-script/raw/refs/heads/main/font_psf/MesloLGLDZNerdFontMono-Regular.psf"
        sudo sed -i "s|^FONT=.*|FONT=\"$PSF_FILE\"|" /etc/default/console-setup

        mkdir -p ~/.local/share/fonts
        wget -q -O ~/.local/share/fonts/MesloLGLDZNerdFont-Regular.ttf "https://github.com/sz0g0n/pretty-terminal-script/raw/refs/heads/main/font_ttf/MesloLGLDZNerdFont-Regular.ttf"
        fc-cache -fv

        if [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
            PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d \')
            gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/" font "MesloLGLDZNerdFont-Regular 12"
            gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/" use-system-font false
        fi
    fi
fi

# ===== 3. Powerlevel10k =====
if [ ! -d "${HOME}/.p10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.p10k
fi
#    wget -O ~/.p10k.zsh https://github.com/sz0g0n/pretty-terminal-script/raw/refs/heads/main/.p10k.zsh
if ! grep -q ".p10.zsh" ~/.zshrc 2>/dev/null; then
    echo 'source ~/.p10k.zsh' >> ~/.zshrc
fi
# ===== 6. Powerlevel10k automatycznie =====
# Pobierz motyw, jeśli brak lub brak wzmianki 'pretty-terminal'
if [ ! -f ~/.p10k/powerlevel10k.zsh-theme ] || \
   ! grep -q "pretty-terminal" ~/.p10k/powerlevel10k.zsh-theme 2>/dev/null; then
    cp ~/.p10k/powerlevel10k.zsh-theme ~/.p10k/powerlevel10k.zsh-theme.org 2>/dev/null
    wget -O ~/.p10k/powerlevel10k.zsh-theme \
    https://raw.githubusercontent.com/sz0g0n/pretty-terminal-script/refs/heads/main/powerlevel10k.zsh-theme
fi

# Pobierz plik konfiguracyjny, jeśli brak
if [ ! -f ~/.p10k.zsh ]; then
    wget -O ~/.p10k.zsh \
    https://raw.githubusercontent.com/sz0g0n/pretty-terminal-script/refs/heads/main/.p10k.zsh
else
    cp ~/.p10k.zsh ~/.p10k.zsh.org 2>/dev/null
    wget -O ~/.p10k.zsh \
    https://raw.githubusercontent.com/sz0g0n/pretty-terminal-script/refs/heads/main/.p10k.zsh
fi
# ===== 4. Czcionki GUI/Terminal (inne dystrybucje) =====
if [[ "$ID" != "ubuntu" && "$ID" != "debian" ]]; then
    FONT_DIR="$HOME/.local/share/fonts"
    mkdir -p "$FONT_DIR"
    if [ ! -f "$FONT_DIR/MesloLGS NF Regular.ttf" ]; then
        cd "$FONT_DIR" || exit 1
        wget -q https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip -O Meslo.zip
        unzip -o -q Meslo.zip -d Meslo
        cp Meslo/*.ttf "$FONT_DIR"
        rm -rf Meslo Meslo.zip
        fc-cache -fv > /dev/null
    fi
fi

# ===== 5. Zmiana powłoki =====
CURRENT_SHELL=$(getent passwd $USER | cut -d: -f7)
[[ "$CURRENT_SHELL" != "$(command -v zsh)" ]] && chsh -s "$(command -v zsh)"

# ===== 5b. Alias, neofetch, przypominajka =====
grep -qxF 'alias ee="eza -lha --header --total-size --sort=name --icons --group-directories-first --grid --octal-permissions --no-permissions --classify"' ~/.zshrc || \
    echo 'alias ee="eza -lha --header --total-size --sort=name --icons --group-directories-first --grid --octal-permissions --no-permissions --classify"' >> ~/.zshrc
grep -qxF 'alias e="eza -lha --header --sort=name --icons --group-directories-first --grid --octal-permissions --no-permissions --classify"' ~/.zshrc || \
    echo 'alias e="eza -lha --header --sort=name --icons --group-directories-first --grid --octal-permissions --no-permissions --classify"' >> ~/.zshrc

if ! grep -q "neofetch" ~/.zshrc 2>dev/null; then
    cat <<'EOF' >> ~/.zshrc

if [[ $- == *i* ]] && [ "$SHLVL" -eq 1 ] && command -v neofetch >/dev/null 2>&1; then
    echo -e "\n"
    neofetch
fi
EOF
fi

if ! grep -q "Przypominajka zamienników komend" ~/.zshrc; then
    cat <<'EOF' >> ~/.zshrc

# ===== Przypominajka zamienników komend =====
show_replacements() {
    echo -e "\033[1;33m------ Zamienniki komend ------\033[0m"
    echo -e "\033[0;36mtop   -> btop\033[0m"
    echo -e "\033[0;36mls    -> e / ee (alias eza)\033[0m"
    echo -e "\033[0;36mcat   -> bat\033[0m"
    echo -e "\033[1;33m-------------------------------\033[0m"
}
alias remind="show_replacements"
EOF
fi

# ===== 7. Zakończenie =====
echo -e '\033[0;31mPAMIĘTAJ: ustaw czcionkę w terminalu na MESLO po zakończeniu!\033[0m'
read -p "Chcesz zrestartować teraz? (tak/nie): " REBOOT
[[ "$REBOOT" == "tak" ]] && sudo reboot
 
