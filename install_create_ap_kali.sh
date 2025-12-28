#!/bin/bash

# =================================================================================
# Skrip Instalasi 'create_ap' untuk Kali Linux & Debian-based
#
# Deskripsi:
# Skrip ini mengotomatiskan proses instalasi 'create_ap' beserta
# semua dependensinya di sistem yang tidak memiliki paket ini di repositori
# default, seperti Kali Linux.
#
# Cara Menjalankan:
# 1. Simpan sebagai install_create_ap_kali.sh
# 2. Beri izin eksekusi: chmod +x install_create_ap_kali.sh
# 3. Jalankan dengan sudo: sudo ./install_create_ap_kali.sh
# =================================================================================

# --- Definisi Warna ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Hentikan skrip jika terjadi error
set -e

main() {
    echo -e "${BLUE}--- Skrip Instalasi 'create_ap' untuk Kali Linux ---${NC}"

    # 1. Periksa apakah 'create_ap' sudah terinstal
    if command -v create_ap &> /dev/null; then
        echo -e "${GREEN}'create_ap' sudah terinstal. Tidak ada tindakan yang diperlukan.${NC}"
        exit 0
    fi

    # 2. Perbarui repositori paket dan instal dependensi
    echo -e "${YELLOW}Akan menginstal dependensi yang diperlukan...${NC}"
    DEPS="git make gcc hostapd dnsmasq iptables iw rfkill"
    echo "Dependensi: $DEPS"
    
    sudo apt-get update
    sudo apt-get install -y $DEPS

    echo -e "${GREEN}Semua dependensi berhasil diinstal.${NC}"

    # 3. Clone repositori 'create_ap'
    CLONE_DIR="/tmp/create_ap_repo"
    echo -e "${YELLOW}Mengunduh 'create_ap' dari GitHub ke direktori '$CLONE_DIR'...${NC}"
    
    # Hapus direktori lama jika ada
    if [ -d "$CLONE_DIR" ]; then
        rm -rf "$CLONE_DIR"
    fi
    
    git clone https://github.com/oblique/create_ap.git "$CLONE_DIR"

    # 4. Instal 'create_ap' menggunakan make
    echo -e "${YELLOW}Menjalankan proses instalasi...${NC}"
    cd "$CLONE_DIR"
    sudo make install

    # 5. Membersihkan file instalasi
    echo -e "${YELLOW}Membersihkan direktori instalasi...${NC}"
    cd /
    rm -rf "$CLONE_DIR"

    # 6. Verifikasi instalasi
    if command -v create_ap &> /dev/null; then
        echo -e "\n${GREEN}=====================================================${NC}"
        echo -e "${GREEN}  Instalasi 'create_ap' telah BERHASIL!${NC}"
        echo -e "${GREEN}=====================================================${NC}"
        echo -e "\n${BLUE}Anda sekarang dapat menjalankan skrip 'hotspot_manager_color.sh'.${NC}"
    else
        echo -e "\n${RED}=====================================================${NC}"
        echo -e "${RED}  Instalasi 'create_ap' GAGAL.${NC}"
        echo -e "${RED}=====================================================${NC}"
        echo -e "\n${YELLOW}Silakan periksa kembali error yang muncul di atas.${NC}"
        exit 1
    fi
}

# Jalankan fungsi utama
main
