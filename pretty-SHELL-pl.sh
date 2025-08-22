#!/bin/bash

set -e

# ===== 1. Potwierdzenie =====

echo ""
echo ""
echo -e "\033[0;32mTen skrypt zainstaluje zsh, powerlevel10k, eza (lub exa), btop,\033[0m"
echo -e "\033[0;32moraz ustawi zsh jako domyślną powłokę.\033[0m"
echo ""
echo ""
read -p $'Czy chcesz kontynuować? (\033[0;32mtak\033[0m/\033[0;31mnie\033[0m): ' CONFIRM
if [[ "$CONFIRM" != "tak" ]]; then
    echo "Przerwano."
    exit 0
fi

# ===== 2. Wykrycie dystrybucji i instalacja =====
# ===== 2. Wykrycie dystrybucji i instalacja =====
if [ -f /etc/os-release ]; then
    . /etc/os-release
else
    echo "Nie wykryto /etc/os-release"
    exit 1
fi
echo ""

DIST_NAME="$ID"
# jeśli Arch, dodaj "(btw)"
if [[ "$ID" == "arch" ]]; then
    DIST_NAME="$DIST_NAME (btw)"
fi

# Kolorowanie nazwy dystrybucji na niebiesko (34)
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
        echo "$PKG już zainstalowany, pomijam."
    fi
}

# Sprawdzenie i instalacja pakietów
install_if_missing zsh zsh
install_if_missing eza eza
install_if_missing btop btop
install_if_missing git git
install_if_missing wget wget
install_if_missing unzip unzip
install_if_missing fc-cache fontconfig
install_if_missing nvim neovim
install_if_missing neofetch neofetch
# ===== 2b. Instalacja czcionki w konsoli (Ubuntu Server) =====
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
        echo "Ustawiono czcionkę konsoli na MesloLGS NF."
         echo "-----------------------------------------------------------------------------"
        echo ""
        echo -e "\033[1;31m---------------------- Może być wymagany reboot---------------------.\033[0m"
        echo -e "\033[1;31mJeżeli kożystasz z ssh pamiętaj o zainstalowaniu czcionki w systemie.\033[0m"
        echo ""
        echo "-----------------------------------------------------------------------------"

    else
        echo "Czcionka konsoli MesloLGS NF już ustawiona, pomijam."
         echo "-----------------------------------------------------------------------------"
        echo ""
        echo -e "\033[1;31m---------------------- Może być wymagany reboot---------------------.\033[0m"
        echo -e "\033[1;31mJeżeli kożystasz z ssh pamiętaj o zainstalowaniu czcionki w systemie.\033[0m"
        echo ""
        echo "-----------------------------------------------------------------------------"

        if [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
            PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d \')
            gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/" font "MesloLGLDZNerdFont->
            gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/" use-system-font false
        fi
    fi
fi


# ===== 3. Instalacja powerlevel10k =====
if [ ! -d "${HOME}/.p10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.p10k
    echo "Zainstalowano powerlevel10k."
    echo ""
else
    echo "Powerlevel10k już istnieje, pomijam instalację."
    echo ""
fi

# Dodanie do .zshrc (jeśli brak wpisu)
if ! grep -q "powerlevel10k" ~/.zshrc 2>/dev/null; then
    echo 'source ~/.p10k/powerlevel10k.zsh-theme' >> ~/.zshrc
    echo "Dodano powerlevel10k do .zshrc."
    echo ""
else
    echo "Wpis do .zshrc już istnieje, pomijam."
    echo ""
fi

# ===== 4. Instalacja czcionki MesloLGS NF =====

if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
    echo "Ubuntu/Debian – pomijam instalację czcionki do GUI/terminala, użyj ustawień konsoli."
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
	    echo "Zainstalowano czcionkę MesloLGS NF."
	    echo ""
	else
	    echo "Czcionka MesloLGS NF już istnieje, pomijam."
	    echo ""
	fi
	echo "-----------------------------------------------------------------------------"
	echo ""
	echo -e "\033[1;31mPamiętaj, aby w ustawieniach terminala wybrać czcionkę 'MesloLGS NF'.\033[0m"
	echo -e "\033[1;31m---------------------- Może być wymagany reboot---------------------.\033[0m"
	echo -e "\033[1;31mJeżeli kożystasz z ssh pamiętaj o zainstalowaniu czcionki w systemie.\033[0m"
	echo ""
	echo "-----------------------------------------------------------------------------"
fi
#czekaj aż urzytkownik przeczyta

for i in {10..1}; do
    echo -ne "\rOdliczanie: $i s"
    sleep 1
done
echo -e "\rCzas minął!       "

# ===== 5. Zmiana powłoki =====
CURRENT_SHELL=$(getent passwd $USER | cut -d: -f7)
if [[ "$CURRENT_SHELL" != "$(command -v zsh)" ]]; then
    chsh -s "$(command -v zsh)"
    echo "Powłoka bieżącego użytkownika została zmieniona na zsh."
else
    echo "Użytkownik już ma zsh jako domyślną powłokę, pomijam."
fi
# zmiany w pliku .zshrc
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

# Uruchamianie neofetch tylko w interaktywnej sesji, poziom powłoki = 1
if [[ $- == *i* ]] && [ "$SHLVL" -eq 1 ] && command -v neofetch >/dev/null 2>&1; then
    echo -e "\n"
    neofetch
fi
EOF
fi
# 
echo ""
echo ""
echo -e "\033[0;32mCzy chcesz ustawić notatkę przypominającą o zamiennikach komend?\033[0m"
echo -e "\033[0;32mBędzie się ona wyświetlać przy uruchomieniu systemu (można zawsze wyłączyć w .zshrc).\033[0m"
echo ""
read -p $'Czy chcesz ustawić? (\033[0;32mtak\033[0m/\033[0;31mnie\033[0m): ' CONFIRM

if [[ "$CONFIRM" == "tak" ]]; then
    if ! grep -q "Przypominajka zamienników komend" ~/.zshrc; then
        cat <<'EOF' >> ~/.zshrc

# ===== Przypominajka zamienników komend =====
if [[ $- == *i* ]] && [ "$SHLVL" -eq 1 ]; then
    echo -e "\033[1;33m------ Zamienniki komend ------\033[0m"
    echo -e "\033[0;36remind -> przypomina komendy\033[0m"
    echo -e "\033[0;36mtop   -> btop\033[0m"
    echo -e "\033[0;36mls    -> e / ee (alias eza)\033[0m"
    echo -e "\033[0;36mcat   -> bat\033[0m"
    echo -e "\033[1;33m-------------------------------\033[0m"
fi

# ===== Alias do wyświetlania przypominajki zamienników =====
show_replacements() {
    echo -e "\033[1;33m------ Zamienniki komend ------\033[0m"
    echo -e "\033[0;36mtop   -> btop\033[0m"
    echo -e "\033[0;36mls    -> e / ee (alias eza)\033[0m"
    echo -e "\033[0;36mcat   -> bat\033[0m"
    echo -e "\033[1;33m-------------------------------\033[0m"
}
alias remind="show_replacements"
EOF
        echo -e "\033[0;32mDodano przypominajkę zamienników do .zshrc.\033[0m"
    else
        echo -e "\033[0;33mPrzypominajka zamienników już istnieje w .zshrc, pomijam.\033[0m"
    fi
fi
# dodanie wzmianki do .zshrc która wyłączy powidaomienia związane z instant prompt
if ! grep -q "POWERLEVEL9K_INSTANT_PROMPT" ~/.zshrc; then
    echo "typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet" >> ~/.zshrc
    echo -e "\033[0;32mDodano POWERLEVEL9K_INSTANT_PROMPT=off do .zshrc\033[0m"
else
    echo -e "\033[0;33mPOWERLEVEL9K_INSTANT_PROMPT już istnieje w .zshrc, pomijam.\033[0m"
fi

# ===== 6. Zakończenie skryptu =====
echo -e "\033[0;32mAby wszystko działało poprawnie, może być wymagany reboot.\033[0m"
echo -e "\033[0;32mCo chcesz zrobić?\033[0m"
echo "1) Nic / wyłączyć skrypt"
echo -e "2) Wykonać reboot (\033[0;31mrekomendowane\033[0m)"
echo "3) Uruchomić konfigurator powerlevel10k"

read -rp "Wybierz opcję [1-3]: " choice

case "$choice" in
    1)
        echo "Kończę skrypt."
        exit 0
        ;;
    2)
        echo "Restart systemu..."
        sudo reboot
        ;;
    3)
        echo "Uruchamiam konfigurator powerlevel10k..."
        exec zsh -c 'exec zsh -l -i -c "p10k configure"'
        ;;
    *)
        echo "Nieprawidłowy wybór, kończę skrypt."
        exit 1
        ;;
esac

	
