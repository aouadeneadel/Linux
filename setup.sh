#!/bin/bash
set -e

# ==========================================================
# SCRIPT D'INSTALLATION D'UN ENVIRONNEMENT DE DÉVELOPPEMENT
# Linux Mint / Ubuntu
# ==========================================================

# Vérification sudo
if [ "$EUID" -ne 0 ]; then
  echo "Ce script doit être exécuté avec sudo."
  echo "Utilisation : sudo ./setup.sh"
  exit 1
fi

USER_REAL="$SUDO_USER"
HOME_REAL="/home/$USER_REAL"

echo "=================================================="
echo "Installation de l'environnement de développement"
echo "Utilisateur : $USER_REAL"
echo "=================================================="

# --------------------------------------------------
# Section 0 : Fond d'écran
# --------------------------------------------------
echo "--- Section 0 : Fond d'écran ---"

WALLPAPER_URL="https://raw.githubusercontent.com/aouadeneadel/Linux/main/linuxmint-simple-geometric.png"
WALLPAPER_FILE="/usr/share/backgrounds/linuxmint-simple-geometric.png"

wget -q --show-progress -O "$WALLPAPER_FILE" "$WALLPAPER_URL"

DESKTOP_ENV="$XDG_CURRENT_DESKTOP"

if [[ "$DESKTOP_ENV" =~ Cinnamon ]]; then
  sudo -u "$USER_REAL" gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER_FILE"
elif [[ "$DESKTOP_ENV" =~ MATE ]]; then
  sudo -u "$USER_REAL" gsettings set org.mate.background picture-uri "file://$WALLPAPER_FILE"
elif [[ "$DESKTOP_ENV" =~ XFCE ]]; then
  xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image -s "$WALLPAPER_FILE"
else
  echo "Environnement de bureau non reconnu, fond d'écran ignoré."
fi

# --------------------------------------------------
# Section 1 : Mise à jour + outils de base
# --------------------------------------------------
echo "--- Section 1 : Mise à jour système ---"
apt update
apt upgrade -y
apt install -y build-essential git curl wget apt-transport-https ca-certificates gnupg

# --------------------------------------------------
# Section 2 : OCaml / OPAM / UTop
# --------------------------------------------------
echo "--- Section 2 : OCaml / OPAM ---"
apt install -y opam
sudo -u "$USER_REAL" opam init --bare -y
sudo -u "$USER_REAL" opam install -y utop

# --------------------------------------------------
# Section 3 : Éditeurs & IDE
# --------------------------------------------------
echo "--- Section 3 : Éditeurs & IDE ---"

# Visual Studio Code
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.gpg
echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" \
  > /etc/apt/sources.list.d/vscode.list
apt update
apt install -y code

# Code::Blocks
apt install -y codeblocks

# Sublime Text
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg \
  | gpg --dearmor > /etc/apt/trusted.gpg.d/sublime.gpg
echo "deb https://download.sublimetext.com/ apt/stable/" \
  > /etc/apt/sources.list.d/sublime-text.list
apt update
apt install -y sublime-text

# Eclipse (installateur officiel)
echo "--- Eclipse ---"
ECLIPSE_FILE="eclipse-inst-jre-linux64.tar.gz"
wget -q --show-progress -O "$ECLIPSE_FILE" \
  "https://www.eclipse.org/downloads/download.php?file=/oomph/epp/2024-03/R/eclipse-inst-jre-linux64.tar.gz&r=1"
tar -xzf "$ECLIPSE_FILE"
./eclipse-installer/eclipse-inst
rm -rf eclipse-installer "$ECLIPSE_FILE"

# --------------------------------------------------
# Section 4 : PDF / LaTeX / Bureautique
# --------------------------------------------------
echo "--- Section 4 : PDF / LaTeX / FreeOffice ---"

apt install -y evince okular texlive-full

# Suppression LibreOffice s'il existe
if dpkg -l | grep -q libreoffice; then
  echo "Suppression de LibreOffice..."
  apt purge -y libreoffice*
  apt autoremove -y
fi

# Installation FreeOffice
echo "Installation de FreeOffice..."
FREEOFFICE_DEB="softmaker-office-2024_1230-01_amd64.deb"
wget -q --show-progress -O "$FREEOFFICE_DEB" \
  "https://www.softmaker.net/down/softmaker-office-2024_1230-01_amd64.deb"
dpkg -i "$FREEOFFICE_DEB" || apt --fix-broken install -y
rm "$FREEOFFICE_DEB"

# --------------------------------------------------
# Section 5 : Bases de données
# --------------------------------------------------
echo "--- Section 5 : Bases de données ---"
apt install -y mysql-server

wget -q https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb -O dbeaver.deb
dpkg -i dbeaver.deb || apt --fix-broken install -y
rm dbeaver.deb

# --------------------------------------------------
# Section 6 : Docker / VirtualBox
# --------------------------------------------------
echo "--- Section 6 : Docker / VirtualBox ---"
apt install -y docker.io virtualbox
systemctl enable --now docker
usermod -aG docker "$USER_REAL"

# --------------------------------------------------
# Section 7 : Web / API
# --------------------------------------------------
echo "--- Section 7 : Web / API ---"
curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
apt install -y nodejs

apt install -y snapd
snap install postman
snap install github-desktop

# --------------------------------------------------
# Section 9 : Langages
# --------------------------------------------------
echo "--- Section 9 : PHP / Java ---"
apt install -y php libapache2-mod-php php-mysql php-cli php-curl php-mbstring php-xml php-zip
apt install -y openjdk-17-jdk

# --------------------------------------------------
# Section 10 : Notes
# --------------------------------------------------
echo "--- Section 10 : Notes ---"
snap install simplenote

# --------------------------------------------------
# FIN
# --------------------------------------------------
echo "=================================================="
echo "Installation terminée avec succès."
echo "=================================================="
sudo reboot
