#!/bin/bash
# Modul: Konfigurasi Swap Server

echo "Cek kondisi RAM dan Swap saat ini:"
free -h
echo "------------------------------------------------"

# Cek apakah swap sudah ada
if [ "$(swapon --show | tail -n +2 | wc -l)" -gt 0 ]; then
    echo -e "\nPeringatan: Swap sudah aktif di sistem ini!"
    swapon --show
    read -p "Apakah Anda ingin menambahkan file swap lagi? (y/n): " add_more
    if [ "$add_more" != "y" ]; then
        exit 0
    fi
fi

echo "Berapa ukuran Swap yang ingin dibuat? (dalam GB)"
echo "Contoh: Ketik 2 untuk membuat 2GB Swap."
read -p "Ukuran (GB): " size_gb

# Validasi input
if ! [[ "$size_gb" =~ ^[0-9]+$ ]] || [ "$size_gb" -le 0 ]; then
    echo "Error: Input tidak valid! Harus berupa angka lebih dari 0."
    exit 1
fi

SWAP_FILE="/swapfile_${size_gb}g"

echo "[1/5] Membuat file swap ${size_gb}GB... (Ini mungkin memakan waktu beberapa menit)"
# Menggunakan dd lebih aman kompatibilitasnya di berbagai VPS dibanding fallocate
dd if=/dev/zero of=$SWAP_FILE bs=1G count=$size_gb status=progress || { echo "Gagal membuat file swap! Cek disk space."; exit 1; }

echo "[2/5] Mengatur permission file swap..."
chmod 600 $SWAP_FILE || { echo "Gagal mengubah permission!"; exit 1; }

echo "[3/5] Mengatur area swap (mkswap)..."
mkswap $SWAP_FILE || { echo "Gagal format swap!"; exit 1; }

echo "[4/5] Mengaktifkan swap (swapon)..."
swapon $SWAP_FILE || { echo "Gagal mengaktifkan swap!"; exit 1; }

echo "[5/5] Menambahkan ke /etc/fstab agar permanen setelah reboot..."
if ! grep -q "$SWAP_FILE" /etc/fstab; then
    echo "$SWAP_FILE none swap sw 0 0" >> /etc/fstab
fi

# Optimasi Swappiness agar server lebih memilih RAM asli daripada Swap
echo "Mengoptimasi vm.swappiness=10 agar server mengutamakan RAM fisik..."
sysctl vm.swappiness=10
if ! grep -q "vm.swappiness" /etc/sysctl.conf; then
    echo "vm.swappiness=10" >> /etc/sysctl.conf
else
    sed -i 's/vm.swappiness=.*/vm.swappiness=10/' /etc/sysctl.conf
fi

echo -e "\n========================================"
echo "  SWAP BERHASIL DIBUAT & DIOPTIMASI!"
echo "========================================"
free -h

exit 0