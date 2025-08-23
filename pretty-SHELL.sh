#!/bin/bash

set -e

# ===== 1. Confirmation =====

echo ""
echo ""
echo -e "\033[0;32mThis script will install zsh, powerlevel10k, eza (or exa), btop,\033[0m"
echo -e "\033[0;32mand set zsh as the default shell.\033[0m"
echo ""
echo ""
read -p $'Do you want to continue? (\033[0;32myes\033[0m/\033[0;31mno\033[0m): ' CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
    echo "Aborted."
    exit 0
fi

# ===== 2. Detecting distribution and installation =====
if [ -f /etc/os-release ]; then
    . /etc/os-release
else
    echo "No /etc/os-release detected"
    exit 1
fi
echo ""

DIST_NAME="$ID"
# if Arch, add "(btw)"
if [[ "$ID" == "arch" ]]; then
    DIST_NAME="$DIST_NAME (btw)"
fi

# Color the distribution name in blue (34)
echo -e "Detected distribution: \033[0;34m$DIST_NAME\033[0m"
echo ""


install_if_missing() {
    CMD=$1
    PKG=$2
 if ! command -v "$CMD" &>/dev/null; then
        echo "Installing $PKG..."
        case "$ID" in
            ubuntu|debian|linuxmint|pop)
                sudo apt update
                sudo apt install -y "$PKG"
                ;;
            fedora)
                sudo dnf install -y "$PKG"
                ;;
            rhel|centos|rocky|almalinux)
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
        echo "$PKG is already installed, skipping."
    fi
}

# Package check and installation
install_if_missing zsh zsh
install_if_missing eza eza
install_if_missing btop btop
install_if_missing git git
install_if_missing wget wget
install_if_missing unzip unzip
install_if_missing fc-cache fontconfig
install_if_missing nvim neovim
install_if_missing neofetch neofetch

# ===== 2b. Console font installation (Ubuntu Server) =====
if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
    CONSOLE_FONT="/usr/share/consolefonts/MesloLGLDZNerdFontMono-Regular.psf"
    if [ ! -f "$CONSOLE_FONT" ]; then
        PSF_DIR="/usr/share/consolefonts"
        PSF_FILE="$PSF_DIR/MesloLGLDZNerdFontMono-Regular.psf"
        sudo mkdir -p "$PSF_DIR"
        sudo wget -q -O "$PSF_FILE" "https://github.com/sz0g0n/pretty-terminal-script/raw/refs/heads/main/font_psf/MesloLGLDZNerdFontMo>
        sudo sed -i "s|^FONT=.*|FONT=\"$PSF_FILE\"|" /etc/default/console-setup

        mkdir -p ~/.local/share/fonts
        wget -q -O ~/.local/share/fonts/MesloLGLDZNerdFont-Regular.ttf "https://github.com/sz0g0n/pretty-terminal-script/raw/refs/heads>
        fc-cache -fv
        echo "Console font set to MesloLGS NF."
        echo "-----------------------------------------------------------------------------"
        echo ""
        echo -e "\033[1;31m---------------------- A reboot may be required ---------------------.\033[0m"
        echo -e "\033[1;31mIf using SSH, remember to install the font on your system.\033[0m"
        echo ""
        echo "-----------------------------------------------------------------------------"

    else
        echo "Console font MesloLGS NF is already set, skipping."
        echo "-----------------------------------------------------------------------------"
        echo ""
        echo -e "\033[1;31m---------------------- A reboot may be required ---------------------.\033[0m"
        echo -e "\033[1;31mIf using SSH, remember to install the font on your system.\033[0m"
        echo ""
        echo "-----------------------------------------------------------------------------"

        if [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
            PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d \')
            gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/" font "MesloLGLDZNerdFont->
            gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/" use-system-font false
        fi
    fi
fi


# ===== 3. Install powerlevel10k =====
if [ ! -d "${HOME}/.p10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.p10k
    echo "Powerlevel10k installed."
    echo ""
else
    echo "Powerlevel10k already exists, skipping installation."
    echo ""
fi

# Add to .zshrc (if missing)
if ! grep -q "powerlevel10k" ~/.zshrc 2>/dev/null; then
    echo 'source ~/.p10k/powerlevel10k.zsh-theme' >> ~/.zshrc
    echo "Added powerlevel10k to .zshrc."
    echo ""
else
    echo "Entry already exists in .zshrc, skipping."
    echo ""
fi
wget -O ~/.p10k.zsh https://github.com/sz0g0n/pretty-terminal-script/raw/refs/heads/main/.p10k.zsh
# ===== 4. Install MesloLGS NF font =====

if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
    echo "Ubuntu/Debian – skipping GUI/terminal font installation, use console settings."
else

        FONT_DIR="$HOME/.local/share/fonts"
        mkdir -p "$FONT_DIR"

        if [ ! -f "$FONT_DIR/MesloLGS NF Regular.ttf" ]; then
            cd "$FONT_DIR" || exit 1
            wget -q https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip -O Meslo.zip
            unzip -o -q Meslo.zip -d Meslo
            cp Meslo/*.ttf "$FONT_DIR"
            rm -rf Meslo Meslo.zip
            fc-cache -fv > /dev/null
            echo "MesloLGS NF font installed."
            echo ""
        else
            echo "MesloLGS NF font already exists, skipping."
            echo ""
        fi
        echo "-----------------------------------------------------------------------------"
        echo ""
        echo -e "\033[1;31mRemember to select 'MesloLGS NF' font in your terminal settings.\033[0m"
        echo -e "\033[1;31m---------------------- A reboot may be required ---------------------.\033[0m"
        echo -e "\033[1;31mIf using SSH, remember to install the font on your system.\033[0m"
        echo ""
        echo "-----------------------------------------------------------------------------"
fi
# Wait for user to read

for i in {10..1}; do
    echo -ne "\rCountdown: $i s"
    sleep 1
done
echo -e "\rTime's up!       "

# ===== 5. Change shell =====
CURRENT_SHELL=$(getent passwd $USER | cut -d: -f7)
if [[ "$CURRENT_SHELL" != "$(command -v zsh)" ]]; then
    chsh -s "$(command -v zsh)"
    echo "The current user's shell has been changed to zsh."
else
    echo "User already has zsh as the default shell, skipping."
fi
# changes in .zshrc
# alias ee
if ! grep -Fxq 'alias ee="eza -lha --header --total-size --sort=name --icons --group-directories-first --grid --octal-permissions --no-permissions --classify"' ~/.zshrc; then
    echo 'alias ee="eza -lha --header --total-size --sort=name --icons --group-directories-first --grid --octal-permissions --no-permissions --classify"' >> ~/.zshrc
fi

# alias e
if ! grep -Fxq 'alias e="eza -lha --header --sort=name --icons --group-directories-first --grid --octal-permissions --no-permissions --classify"' ~/.zshrc; then
    echo 'alias e="eza -lha --header --sort=name --icons --group-directories-first --grid --octal-permissions --no-permissions --classify"' >> ~/.zshrc
fi
# neofetch
if ! grep -q "neofetch" ~/.zshrc; then
    cat <<'EOF' >> ~/.zshrc

# Run neofetch only in interactive session, shell level = 1
if [[ $- == *i* ]] && [ "$SHLVL" -eq 1 ] && command -v neofetch >/dev/null 2>&1; then
    echo -e "\n"
    neofetch
fi
EOF
fi

echo ""
echo ""
echo -e "\033[0;32mWould you like to set a reminder note for command replacements?\033[0m"
echo -e "\033[0;32mIt will appear at system startup (can always be disabled in .zshrc).\033[0m"
echo ""
read -p $'Would you like to set it? (\033[0;32myes\033[0m/\033[0;31mno\033[0m): ' CONFIRM

if [[ "$CONFIRM" == "yes" ]]; then
    if ! grep -q "Command replacement reminder" ~/.zshrc; then
        cat <<'EOF' >> ~/.zshrc

# ===== Command replacement reminder =====
if [[ $- == *i* ]] && [ "$SHLVL" -eq 1 ]; then
    echo -e "\033[1;33m------ Command Replacements ------\033[0m"
    echo -e "\033[0;36remind -> shows command replacements\033[0m"
    echo -e "\033[0;36mtop   -> btop\033[0m"
    echo -e "\033[0;36mls    -> e / ee (alias eza)\033[0m"
    echo -e "\033[0;36mcat   -> bat\033[0m"
    echo -e "\033[1;33m----------------------------------\033[0m"
fi

# ===== Alias to display command replacement reminder =====
show_replacements() {
    echo -e "\033[1;33m------ Command Replacements ------\033[0m"
    echo -e "\033[0;36mtop   -> btop\033[0m"
    echo -e "\033[0;36mls    -> e / ee (alias eza)\033[0m"
    echo -e "\033[0;36mcat   -> bat\033[0m"
    echo -e "\033[1;33m----------------------------------\033[0m"
}
alias remind="show_replacements"
EOF
        echo -e "\033[0;32mCommand replacement reminder added to .zshrc.\033[0m"
    else
        echo -e "\033[0;33mCommand replacement reminder already exists in .zshrc, skipping.\033[0m"
    fi
fi

# add note to .zshrc to disable instant prompt notifications
if ! grep -q "POWERLEVEL9K_INSTANT_PROMPT" ~/.zshrc; then
    echo "typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet" >> ~/.zshrc
    echo -e "\033[0;32mAdded POWERLEVEL9K_INSTANT_PROMPT=off to .zshrc\033[0m"
else
    echo -e "\033[0;33mPOWERLEVEL9K_INSTANT_PROMPT already exists in .zshrc, skipping.\033[0m"
fi
# question about automated p10k configuration

echo ""
echo ""
echo -e "\033[0;32Do you want to set automated p10k() configuration?\033[0m"
echo ""
echo ""
read -p $'Czy chcesz kontynuować? (tak/nie): ' CONFIRM
if [[ "$CONFIRM" != "tak" ]]; then
cp ~/.p10k.zsh ~/.p10kzsh.org
rm -f ~/.p10k.zsh
wget -O ~/.p10k.zsh https://github.com/sz0g0n/pretty-terminal-script/raw/refs/heads/main/.p10k.zsh

fi



# ===== 6. End of script =====
echo -e "\033[0;32mA reboot may be required for everything to work correctly.\033[0m"
echo -e "\033[0;32mWhat do you want to do?\033[0m"
echo "1) Nothing / exit script"
echo -e "2) Reboot system (\033[0;31mrecommended\033[0m)"
echo "3) Launch powerlevel10k configurator"

read -rp "Choose an option [1-3]: " choice

case "$choice" in
    1)
        echo "Exiting script."
        exit 0
        ;;
    2)
        echo "Restarting system..."
        sudo reboot
        ;;
    3)
        echo "Launching powerlevel10k configurator..."
        exec zsh -c 'exec zsh -l -i -c "p10k configure"'
        ;;
    *)
        echo "Invalid choice, exiting script."
        exit 1
        ;;
esac
