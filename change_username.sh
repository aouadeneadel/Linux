#!/usr/bin/env bash

set -e

echo "=== Linux Mint — Changement du nom d'utilisateur ==="

read -rp "Entrer le nom d'utilisateur actuel : " OLD_USER
read -rp "Entrer le nouveau nom d'utilisateur : " NEW_USER

if [[ -z "$OLD_USER" || -z "$NEW_USER" ]]; then
  echo "Erreur : un ou plusieurs champs sont vides."
  exit 1
fi

if [[ "$OLD_USER" == "$NEW_USER" ]]; then
  echo "Erreur : le nouveau nom d'utilisateur doit être différent."
  exit 1
fi

if ! id "$OLD_USER" &>/dev/null; then
  echo "Erreur : l'utilisateur '$OLD_USER' n'existe pas."
  exit 1
fi

if id "$NEW_USER" &>/dev/null; then
  echo "Erreur : l'utilisateur '$NEW_USER' existe déjà."
  exit 1
fi

OLD_HOME="/home/$OLD_USER"
NEW_HOME="/home/$NEW_USER"

echo
echo "Changements à effectuer :"
echo "  Utilisateur : $OLD_USER → $NEW_USER"
echo "  Dossier home : $OLD_HOME → $NEW_HOME"
echo

read -rp "Continuer ? (o/N) : " CONFIRM
[[ "$CONFIRM" =~ ^[OoYy]$ ]] || exit 0

# Renommer l'utilisateur
usermod -l "$NEW_USER" "$OLD_USER"

# Renommer le groupe principal s'il existe
if getent group "$OLD_USER" &>/dev/null; then
  groupmod -n "$NEW_USER" "$OLD_USER"
fi

# Déplacer et mettre à jour le dossier personnel
if [[ -d "$OLD_HOME" ]]; then
  usermod -d "$NEW_HOME" -m "$NEW_USER"
  chown -R "$NEW_USER:$NEW_USER" "$NEW_HOME"
else
  echo "Attention : dossier personnel introuvable."
fi

echo
echo "Changement terminé avec succès."
echo "Le système va redémarrer. Connectez-vous ensuite avec '$NEW_USER'."

sudo reboot
