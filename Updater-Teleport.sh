#!/bin/bash

# Variables
TELEPORT_PKG="teleport"  # Pour Teleport Community Edition, ajustez si nécessaire à "teleport-ent"
SYSTEM_ARCH="amd64"  # Ajustez selon votre architecture système
TEMP_DIR="/tmp/updater-teleport"

# Fonction de journalisation
log() {
    echo "[INFO] $1"
}

# Obtenir la dernière version de Teleport depuis GitHub
log "Obtention de la dernière version de Teleport depuis GitHub..."
LATEST_VERSION=$(curl -s https://api.github.com/repos/gravitational/teleport/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
TELEPORT_VERSION=${LATEST_VERSION}
log "Dernière version trouvée: ${TELEPORT_VERSION}"

# Demander à l'utilisateur s'il souhaite mettre à jour
read -p "Souhaitez-vous mettre à jour Teleport vers la version ${TELEPORT_VERSION} ? (y/n): " user_choice

if [[ "$user_choice" != "y" && "$user_choice" != "Y" ]]; then
    log "Mise à jour annulée par l'utilisateur."
    exit 0
fi

# Création du répertoire temporaire
log "Création du répertoire temporaire ${TEMP_DIR}..."
mkdir -p ${TEMP_DIR}
cd ${TEMP_DIR}

# Téléchargement du fichier d'archive et de la checksum
log "Téléchargement de l'archive Teleport version ${TELEPORT_VERSION} pour ${SYSTEM_ARCH}..."
curl -O https://cdn.teleport.dev/${TELEPORT_PKG}-v${TELEPORT_VERSION}-linux-${SYSTEM_ARCH}-bin.tar.gz
curl -O https://cdn.teleport.dev/${TELEPORT_PKG}-v${TELEPORT_VERSION}-linux-${SYSTEM_ARCH}-bin.tar.gz.sha256

# Vérification de la checksum
log "Vérification de la checksum..."
CHECKSUM=$(cat ${TELEPORT_PKG}-v${TELEPORT_VERSION}-linux-${SYSTEM_ARCH}-bin.tar.gz.sha256 | awk '{print $1}')
DOWNLOADED_CHECKSUM=$(sha256sum ${TELEPORT_PKG}-v${TELEPORT_VERSION}-linux-${SYSTEM_ARCH}-bin.tar.gz | awk '{print $1}')
if [ "${CHECKSUM}" != "${DOWNLOADED_CHECKSUM}" ]; then
    echo "[ERROR] La vérification de la checksum a échoué !"
    exit 1
fi

# Extraction des fichiers
log "Extraction des fichiers..."
tar -xvf ${TELEPORT_PKG}-v${TELEPORT_VERSION}-linux-${SYSTEM_ARCH}-bin.tar.gz

# Installation
log "Installation de Teleport..."
cd ${TELEPORT_PKG}
sudo ./install

# Vérification de la version installée
log "Vérification de la version installée..."
teleport version

# Nettoyage
log "Nettoyage..."
cd ~
rm -rf ${TEMP_DIR}

log "Mise à jour terminée avec succès !"
