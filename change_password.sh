#!/usr/bin/env bash

set -e

USER="$(whoami)"

echo "=== Linux Mint — Changement du mot de passe ==="
echo "Utilisateur courant : $USER"
echo

# Vérifier que le script est exécuté avec sudo
if [[ "$EUID" -ne 0 ]]; then
  echo "Erreur : ce script doit être exécuté avec sudo."
  exit 1
fi

# Interdire root
if [[ "$USER" == "root" ]]; then
  echo "Erreur : changement de mot de passe root non autorisé ici."
  exit 1
fi

echo "Veuillez entrer le nouveau mot de passe."
echo

passwd "$USER"

echo
echo "Mot de passe modifié avec succès pour '$USER'."

