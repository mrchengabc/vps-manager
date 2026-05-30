#!/bin/bash
echo "[1/3] Memperbarui daftar paket..."
apt update -y || { echo "Gagal apt update!"; exit 1; }
echo "[2/3] Mengupgrade paket sistem..."
DEBIAN_FRONTEND=noninteractive apt upgrade -y || { echo "Gagal apt upgrade!"; exit 1; }
echo "[3/3] Menginstall paket dasar..."
apt install curl wget software-properties-common rsync git -y || { echo "Gagal install paket dasar!"; exit 1; }
exit 0