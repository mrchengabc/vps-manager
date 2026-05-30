#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

if [ ! -d "$BASE_DIR/.git" ]; then
    echo "Error: Ini bukan repository Git. Clone ulang menggunakan 'git clone'."; exit 1
fi

cd "$BASE_DIR" || exit 1
BRANCH=$(git rev-parse --abbrev-ref HEAD)
git fetch origin $BRANCH
UPDATES=$(git diff --name-only origin/$BRANCH)

if [ -z "$UPDATES" ]; then echo "Sudah versi terbaru!"; exit 0; fi

echo "Update tersedia untuk file:"; echo "$UPDATES"
read -p "Lanjutkan update? File lokal akan ditimpa (y/n): " confirm
[[ "$confirm" != "y" ]] && { echo "Dibatalkan."; exit 0; }

git reset --hard origin/$BRANCH || { echo "Gagal update!"; exit 1; }
chmod +x "$BASE_DIR/main.sh" && chmod +x "$BASE_DIR/modules/"*.sh

echo "Update berhasil! Harap jalankan ulang ./main.sh"
exit 99