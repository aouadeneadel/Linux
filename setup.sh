#!/bin/bash

# ====================================================================
# SCRIPT D'INSTALLATION D'ENVIRONNEMENT DE DÉVELOPPEMENT COMPLET
# ====================================================================

# Vérification des droits d'administrateur (sudo)
if [ "$EUID" -ne 0 ]; then
  echo "Ce script doit être exécuté avec 'sudo'."
  echo "Utilisation : sudo ./setup.sh"
  exit 1
fi

# --- Section 0: Modifier le Fond d'Écran ---
echo "--- Section 0: Personnalisation de l'environnement : Modification du fond d'écran ---"
WALLPAPER_URL="https://github.com/aouadeneadel/Linux/blob/main/linuxmint-simple-geometric.png"
WALLPAPER_FILE="linuxmint-simple-geometric.png"

echo "Téléchargement d'un fond d'écran de développeur..."
wget -q --show-progress -O "$WALLPAPER_FILE" "$WALLPAPER_URL"

DESKTOP_ENV="$XDG_CURRENT_DESKTOP"

if [[ "$DESKTOP_ENV" =~ "Cinnamon" ]]; then
    echo "Détection de Cinnamon. Application du fond d'écran..."
    sudo -u "$SUDO_USER" gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER_FILE"
elif [[ "$DESKTOP_ENV" =~ "MATE" ]]; then
    echo "Détection de MATE. Application du fond d'écran..."
    sudo -u "$SUDO_USER" gsettings set org.mate.background picture-uri "file://$WALLPAPER_FILE"
elif [[ "$DESKTOP_ENV" =~ "XFCE" ]]; then
    echo "Détection de XFCE. Application du fond d'écran..."
    sudo -u "$SUDO_USER" xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image -s "$WALLPAPER_FILE"
else
    echo "Impossible de détecter l'environnement de bureau. Le fond d'écran n'a pas été modifié."
fi

# --- Section 1: Mise à jour et Outils de Base ---
echo "--- Section 1: Mise à jour du système et installation des outils de base ---"
apt update
apt upgrade -y
apt install build-essential git curl apt-transport-https wget -y

# Ajout d'UTop (un interpréteur interactif pour OCaml)
echo "Installation d'UTop et d'OPAM (le gestionnaire de paquets)..."
apt install opam -y
# Lancer les commandes opam en tant qu'utilisateur pour initialiser son environnement personnel
echo "Initialisation d'OPAM en tant qu'utilisateur..."
sudo -u "$SUDO_USER" opam init --bare
echo "Installation d'UTop..."
sudo -u "$SUDO_USER" opam install utop
echo "Note : UTop est un outil en ligne de commande. Il n'y a pas de raccourci de bureau."
echo "Note : Git est installé par défaut par ce script, car c'est un outil en ligne de commande."

# --- Section 2: Éditeurs de Code et IDE ---
echo "--- Section 2: Installation des éditeurs de code et IDE ---"

# 1. Visual Studio Code
echo "Installation de Visual Studio Code..."
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
apt update
apt install code -y
rm microsoft.gpg
# Création du raccourci
echo "Création du raccourci pour Visual Studio Code..."
cat > /usr/share/applications/visual-studio-code.desktop << EOL
[Desktop Entry]
Name=Visual Studio Code
Comment=Développer et déboguer des applications
Exec=/usr/bin/code
Icon=visual-studio-code
Type=Application
Categories=Development;IDE;
EOL

# 2. Code::Blocks
echo "Installation de Code::Blocks..."
apt install codeblocks -y
# Création du raccourci
echo "Création du raccourci pour Code::Blocks..."
cat > /usr/share/applications/codeblocks.desktop << EOL
[Desktop Entry]
Name=Code::Blocks
Comment=Environnement de développement intégré open-source
Exec=/usr/bin/codeblocks
Icon=codeblocks
Type=Application
Categories=Development;IDE;
EOL

# 3. Sublime Text
echo "Installation de Sublime Text..."
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | apt-key add -
echo "deb https://download.sublimetext.com/ apt/stable/" | tee /etc/apt/sources.list.d/sublime-text.list
apt update
apt install sublime-text -y
# Création du raccourci
echo "Création du raccourci pour Sublime Text..."
cat > /usr/share/applications/sublime-text.desktop << EOL
[Desktop Entry]
Name=Sublime Text
Comment=Éditeur de texte pour code, balisage et prose
Exec=/usr/bin/subl %F
Icon=sublime-text
Type=Application
Categories=TextEditor;Development;
EOL

# 4. Eclipse IDE (pour le développement Java)
echo "Installation d'Eclipse IDE..."
ECLIPSE_URL="https://www.eclipse.org/downloads/download.php?file=/oomph/epp/2024-03/R/eclipse-inst-jre-linux64.tar.gz&mirror_id=1130"
ECLIPSE_FILE="eclipse-inst-jre-linux64.tar.gz"
echo "Téléchargement de l'installeur d'Eclipse..."
wget -q --show-progress -O "$ECLIPSE_FILE" "$ECLIPSE_URL"
echo "Extraction des fichiers d'installation d'Eclipse..."
tar -xzf "$ECLIPSE_FILE"
echo "Lancement de l'installeur d'Eclipse. Suivez les instructions à l'écran pour choisir votre version (ex. Eclipse IDE for Java Developers)."
./eclipse-installer/eclipse-inst
echo "Suppression des fichiers temporaires d'installation..."
rm "$ECLIPSE_FILE"
rm -r eclipse-installer
# Création du raccourci
echo "Création du raccourci pour Eclipse..."
cat > /usr/share/applications/eclipse.desktop << EOL
[Desktop Entry]
Name=Eclipse
Comment=Environnement de développement pour Java
Exec=/opt/eclipse/eclipse
Icon=/opt/eclipse/icon.xpm
Type=Application
Categories=Development;IDE;
EOL
echo "Note : Vous devrez peut-être ajuster le chemin du raccourci si Eclipse est installé ailleurs que dans /opt/eclipse."

# --- Section 3: Logiciels pour PDF & LaTeX ---
echo "--- Section 3: Installation de LaTeX, de visionneuses PDF et d'un traitement de texte ---"
apt install evince okular -y
echo "Note : Les raccourcis pour Evince et Okular sont créés automatiquement via le gestionnaire de paquets."
apt install texlive-full -y
echo "Note : texlive-full est une suite de paquets, il n'y a pas de raccourci de bureau."
# Suppression de LibreOffice et installation de OnlyOffice
echo "Suppression de LibreOffice Writer..."
apt purge libreoffice-writer -y
echo "Installation de OnlyOffice Desktop Editors via Snap..."
apt install snapd -y
snap install onlyoffice-desktopeditors
# Création du raccourci
echo "Création du raccourci pour OnlyOffice Desktop Editors..."
cat > /usr/share/applications/onlyoffice-desktopeditors.desktop << EOL
[Desktop Entry]
Name=OnlyOffice Desktop Editors
Comment=Suite bureautique complète compatible avec les documents Office
Exec=/snap/bin/onlyoffice-desktopeditors
Icon=onlyoffice-desktopeditors
Type=Application
Categories=Office;
EOL

# --- Section 4: Bases de Données et Clients ---
echo "--- Section 4: Installation des SGBD et clients de base de données ---"
apt install mysql-server -y
echo "Note : MySQL Server est un service en arrière-plan, il n'y a pas de raccourci de bureau."
wget -q https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb -O dbeaver.deb
dpkg -i dbeaver.deb
apt --fix-broken install -y
rm dbeaver.deb
# Création du raccourci
echo "Création du raccourci pour DBeaver..."
cat > /usr/share/applications/dbeaver.desktop << EOL
[Desktop Entry]
Name=DBeaver
Comment=Client de base de données universel
Exec=/usr/bin/dbeaver
Icon=/usr/share/icons/hicolor/scalable/apps/dbeaver.svg
Type=Application
Categories=Development;Database;
EOL

# --- Section 5: Virtualisation et Conteneurisation ---
echo "--- Section 5: Installation de Docker et VirtualBox ---"
apt install docker.io -y
systemctl enable --now docker
usermod -aG docker "$SUDO_USER"
echo "Note : Docker est un service en ligne de commande. Il n'y a pas de raccourci de bureau."
echo "Déconnexion/reconnexion nécessaire pour que l'ajout au groupe docker prenne effet."
apt install virtualbox -y
# Création du raccourci
echo "Création du raccourci pour VirtualBox..."
cat > /usr/share/applications/virtualbox.desktop << EOL
[Desktop Entry]
Name=Oracle VM VirtualBox
Comment=Exécuter plusieurs systèmes d'exploitation en même temps
Exec=virtualbox %U
Icon=virtualbox
Type=Application
Categories=System;Emulator;
EOL

# --- Section 6: Développement Web & API ---
echo "--- Section 6: Installation d'outils pour le développement web ---"
curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
apt install nodejs -y
echo "Note : Node.js est un environnement d'exécution pour JavaScript, il n'y a pas de raccourci de bureau."
snap install postman
# Création du raccourci
echo "Création du raccourci pour Postman..."
cat > /usr/share/applications/postman.desktop << EOL
[Desktop Entry]
Name=Postman
Comment=Plateforme d'API pour la conception, le débogage et le test
Exec=/snap/bin/postman
Icon=postman
Type=Application
Categories=Development;
EOL
# Installation de GitHub Desktop
echo "Installation de GitHub Desktop via Snap..."
snap install github-desktop
# Création du raccourci
echo "Création du raccourci pour GitHub Desktop..."
cat > /usr/share/applications/github-desktop.desktop << EOL
[Desktop Entry]
Name=GitHub Desktop
Comment=Client de bureau pour GitHub
Exec=/snap/bin/github-desktop
Icon=github-desktop
Type=Application
Categories=Development;
EOL

# --- Section 7: Serveur Local de Développement ---
echo "--- Section 7: Installation de XAMPP (Serveur Local) ---"
XAMPP_VERSION="8.2.12-0"
XAMPP_FILE="xampp-linux-x64-$XAMPP_VERSION-installer.run"
XAMPP_URL="https://downloads.sourceforge.net/project/xampp/XAMPP-Linux/$XAMPP_VERSION/$XAMPP_FILE"
echo "Téléchargement de l'installeur de XAMPP..."
wget -q --show-progress "$XAMPP_URL" -O "$XAMPP_FILE"
echo "Rendre le fichier d'installation de XAMPP exécutable..."
chmod +x "$XAMPP_FILE"
echo "Lancement de l'installeur de XAMPP. Suivez les instructions à l'écran."
echo "L'interface graphique va s'ouvrir pour vous guider."
./"$XAMPP_FILE"
echo "Suppression du fichier d'installation de XAMPP..."
rm "$XAMPP_FILE"
# Création du raccourci
echo "Création du raccourci pour le gestionnaire XAMPP..."
cat > /usr/share/applications/xampp.desktop << EOL
[Desktop Entry]
Name=XAMPP Control Panel
Comment=Démarrer et gérer le serveur XAMPP
Exec=/opt/lampp/manager-linux-x64.run
Icon=xampp
Type=Application
Categories=Development;
EOL

# --- Section 8: Langages de Programmation ---
echo "--- Section 8: Installation des langages de programmation PHP et Java ---"

# Installation de PHP et extensions courantes
echo "Installation de PHP et des extensions..."
apt install php libapache2-mod-php php-mysql php-cli php-curl php-mbstring php-xml php-zip -y
echo "PHP installé. Version : $(php -v | head -n 1)"

# Installation de Java (OpenJDK)
echo "Installation de Java (OpenJDK 17 LTS)..."
apt install openjdk-17-jdk -y
echo "Java installé. Version : $(java -version 2>&1 | head -n 1)"

# --- Section 9: Prise de Notes ---
echo "--- Section 9: Installation de l'application de prise de notes Simplenote ---"
echo "Installation de Simplenote via Snap..."
snap install simplenote
# Création du raccourci
echo "Création du raccourci pour Simplenote..."
cat > /usr/share/applications/simplenote.desktop << EOL
[Desktop Entry]
Name=Simplenote
Comment=Application de prise de notes simple et synchronisée
Exec=/snap/bin/simplenote
Icon=simplenote
Type=Application
Categories=Office;
EOL

echo "===================================================================="
echo "Installation de votre environnement de développement terminée. 🚀"
echo "Vous pouvez maintenant trouver les applications dans votre menu."
echo "===================================================================="
