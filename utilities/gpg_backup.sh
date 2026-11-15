#!/bin/sh

set -euo pipefail

# GnuPG Backup Automation Script

if [[ $# -ne 1 ]]; then
	echo "Usage: $0 <key-fingerprint-or-keyID>"
	exit 1
fi

KEY="$1"

# Validate the key existance
#
 if ! gpg --list-keys "$KEY" >/dev/null 2>&1; then
	 echo "Error: No such key found: $KEY"
	 exit 1
 fi

 # Timestamp for directory
 TS=$(date +"%Y-%m-%d_%H-%M-%S")
 BACKUP_DIR="gpg-backup-${TS}"

 mkdir -p "$BACKUP_DIR"

 echo "backup directory: $BACKUP_DIR"
 echo "Key: $KEY"
 echo

 # Export full secret key (master + subkeys)
 #
echo "[1/5] Exporting full secret key (master + subkeys)..."
gpg --export-secret-keys "$KEY" > "${BACKUP_DIR}/secret-master-and-subkeys.gpg"

echo "[2/5] Exporting secret subkeys only..."
gpg --export-secret-keys "$KEY" > "${BACKUP_DIR}/secret-subkeys-only.gpg"

echo "[3/5] Exporting public key..."
gpg --export "$KEY" > "${BACKUP_DIR}/public.asc"

echo "[4/5] Exporting ownertrust..."
gpg --export-ownertrust > "${BACKUP_DIR}/ownertrust.txt"

echo "[5/5] Generating SHA256 checksums..."

{
	cd "$BACKUP_DIR"
	sha256sum	secret-master-and-subkeys.gpg \
			secret-subkeys-only.gpg \
			public.asc \
			ownertrust.txt \
			> SHA256SUMS
}

# Summary
#
echo
echo "Backup completed successfuly."
echo "Files:"
ls -l "$BACKUP_DIR"
echo
echo "Next steps:"
echo " - store secret-master-and-subkeys.gpg OFFLINE."
echo 
echo " - import secret-subkeys-only.gpg onto new systems: "
echo "		gpg --import secret-subkeys-only.gpg"
echo " - Verify later:"
echo "		sha256sum -c SHA256SUMS"

		
