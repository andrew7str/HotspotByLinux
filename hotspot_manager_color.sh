#!/bin/bash

# =================================================================================
# Skrip Manajer Hotspot Penuh Warna dengan Pemantauan Real-time
#
# Deskripsi:
# Versi yang disempurnakan dari skrip manajer hotspot dengan UI berwarna dan
# kemampuan untuk memantau penggunaan jaringan secara real-time.
#
# Dependensi:
# - create_ap : Untuk membuat hotspot.
# - iftop      : Untuk pemantauan jaringan real-time.
#
# Cara Menjalankan:
# 1. Simpan sebagai hotspot_manager_color.sh
# 2. Beri izin eksekusi: chmod +x hotspot_manager_color.sh
# 3. Jalankan dengan sudo: sudo ./hotspot_manager_color.sh
# =================================================================================

# --- Definisi Warna ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# File untuk menyimpan PID dan nama interface
PID_FILE="/tmp/hotspot.pid"
HOTSPOT_IFACE_FILE="/tmp/hotspot_iface.log"

# Fungsi untuk memeriksa dependensi
check_deps() {
    local missing_deps=0
    if ! command -v create_ap &> /dev/null; then
        echo -e "${RED}KESALAHAN: 'create_ap' tidak ditemukan.${NC}"
        missing_deps=1
    fi
    if ! command -v iftop &> /dev/null; then
        echo -e "${RED}KESALAHAN: 'iftop' tidak ditemukan.${NC}"
        missing_deps=1
    fi

    if [ "$missing_deps" -eq 1 ]; then
        echo -e "${YELLOW}Silakan instal dependensi yang diperlukan. Contoh di Ubuntu/Debian:${NC}"
        echo "sudo apt update && sudo apt install create_ap iftop"
        exit 1
    fi
}

# Fungsi untuk menampilkan antarmuka jaringan
list_interfaces() {
    echo -e "${CYAN}Antarmuka jaringan yang tersedia:${NC}"
    ip -o link show | awk -F': ' '{print "  - " $2}'
}

# Fungsi untuk memulai hotspot
start_hotspot() {
    if [ -f "$PID_FILE" ]; then
        echo -e "${YELLOW}Hotspot sudah aktif. Hentikan terlebih dahulu jika ingin memulai ulang.${NC}"
        return
    fi

    clear
    echo -e "${BLUE}--- Memulai Konfigurasi Hotspot ---${NC}"

    read -p "$(echo -e ${MAGENTA}"Masukkan Nama Hotspot (SSID): "${NC})" SSID
    while [ -z "$SSID" ]; do
        read -p "$(echo -e ${YELLOW}"Nama Hotspot tidak boleh kosong. Masukkan SSID: "${NC})" SSID
    done

    while true; do
        read -s -p "$(echo -e ${MAGENTA}"Masukkan Password (minimal 8 karakter): "${NC})" PASSWORD
        echo
        if [ ${#PASSWORD} -ge 8 ]; then
            break
        else
            echo -e "${YELLOW}Password terlalu pendek. Harap gunakan minimal 8 karakter.${NC}"
        fi
    done

    echo ""
    list_interfaces
    echo ""
    read -p "$(echo -e ${MAGENTA}"Pilih antarmuka Internet (cth: eth0): "${NC})" INTERNET_IFACE
    read -p "$(echo -e ${MAGENTA}"Pilih antarmuka Wi-Fi untuk Hotspot (cth: wlan1): "${NC})" HOTSPOT_IFACE

    if [ -z "$INTERNET_IFACE" ] || [ -z "$HOTSPOT_IFACE" ]; then
        echo -e "${RED}Antarmuka tidak boleh kosong. Proses dibatalkan.${NC}"
        return
    fi

    echo -e "${CYAN}Memulai hotspot...${NC}"
    sudo create_ap "$HOTSPOT_IFACE" "$INTERNET_IFACE" "$SSID" "$PASSWORD" &

    echo $! > "$PID_FILE"
    echo "$HOTSPOT_IFACE" > "$HOTSPOT_IFACE_FILE"

    sleep 2

    if ps -p $(cat "$PID_FILE") > /dev/null; then
        echo -e "${GREEN}Hotspot berhasil dimulai dengan SSID: $SSID${NC}"
        echo "Proses berjalan dengan PID: $(cat "$PID_FILE")"
    else
        echo -e "${RED}Gagal memulai hotspot. Periksa konfigurasi antarmuka Anda.${NC}"
        rm -f "$PID_FILE" "$HOTSPOT_IFACE_FILE"
    fi
}

# Fungsi untuk menghentikan hotspot
stop_hotspot() {
    if [ ! -f "$PID_FILE" ]; then
        echo -e "${YELLOW}Hotspot tidak sedang aktif.${NC}"
        return
    fi

    echo -e "${CYAN}Menghentikan hotspot...${NC}"
    PID=$(cat "$PID_FILE")
    sudo kill "$PID" &> /dev/null
    
    wait "$PID" 2>/dev/null
    rm -f "$PID_FILE" "$HOTSPOT_IFACE_FILE"
    echo -e "${GREEN}Hotspot berhasil dihentikan.${NC}"
}

# Fungsi untuk melihat klien yang terhubung
view_clients() {
    if [ ! -f "$HOTSPOT_IFACE_FILE" ]; then
        echo -e "${YELLOW}Hotspot tidak aktif. Tidak ada klien untuk ditampilkan.${NC}"
        return
    fi
    
HOTSPOT_IFACE=$(cat "$HOTSPOT_IFACE_FILE")
    clear
    echo -e "${BLUE}--- Perangkat yang Terhubung ke Hotspot ---${NC}"
    sudo create_ap --list-clients "$HOTSPOT_IFACE"
    echo -e "${BLUE}------------------------------------------${NC}"
}

# Fungsi untuk melihat total penggunaan jaringan
view_total_usage() {
    if [ ! -f "$HOTSPOT_IFACE_FILE" ]; then
        echo -e "${YELLOW}Hotspot tidak aktif. Tidak ada statistik penggunaan.${NC}"
        return
    fi

    HOTSPOT_IFACE=$(cat "$HOTSPOT_IFACE_FILE")
    clear
    echo -e "${BLUE}--- Statistik Total Penggunaan Jaringan untuk '$HOTSPOT_IFACE' ---${NC}"
    
    stats=$(ip -s link show "$HOTSPOT_IFACE" | grep -A 2 "RX: bytes")
    rx_bytes=$(echo "$stats" | awk 'NR==2 {print $1}')
    tx_bytes=$(echo "$stats" | awk 'NR==3 {print $1}')

    # Fungsi konversi byte ke format yang mudah dibaca
    human_readable() {
        numfmt --to=iec --suffix=B --format="%.2f" $1
    }

    echo -e "  ${CYAN}Data Diterima (RX):${NC} $(human_readable $rx_bytes)"
    echo -e "  ${CYAN}Data Dikirim (TX):  ${NC} $(human_readable $tx_bytes)"
    echo -e "${BLUE}------------------------------------------------------------${NC}"
}

# Fungsi untuk pemantauan real-time dengan iftop
view_usage_realtime() {
    if [ ! -f "$HOTSPOT_IFACE_FILE" ]; then
        echo -e "${YELLOW}Hotspot tidak aktif. Tidak dapat memulai pemantauan.${NC}"
        return
    fi

    HOTSPOT_IFACE=$(cat "$HOTSPOT_IFACE_FILE")
    clear
    echo -e "${CYAN}Memulai pemantauan jaringan real-time untuk '$HOTSPOT_IFACE'...${NC}"
    echo -e "${YELLOW}Tekan 'q' untuk keluar dari layar pemantauan.${NC}"
    sleep 2
    sudo iftop -i "$HOTSPOT_IFACE"
}

# Fungsi untuk membersihkan saat keluar
cleanup_on_exit() {
    echo ""
    if [ -f "$PID_FILE" ]; then
        read -p "$(echo -e ${YELLOW}"Hotspot masih aktif. Hentikan sebelum keluar? (y/n): "${NC})" choice
        if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
            stop_hotspot
        fi
    fi
    echo -e "${BLUE}Keluar dari program. Sampai jumpa!${NC}"
    exit 0
}

# Menu utama
main_menu() {
    trap cleanup_on_exit SIGINT

    while true; do
        clear
        echo -e "${BLUE}===================================${NC}"
        echo -e "${CYAN}      MANAJER HOTSPOT PRO${NC}"
        echo -e "${BLUE}===================================${NC}"
        if [ -f "$PID_FILE" ]; then
            ssid=$(ps -p $(cat $PID_FILE) -o args= | grep -oP '(?<= ).*?(?= )' | sed -n 3p 2>/dev/null)
            echo -e "Status: ${GREEN}AKTIF${NC} | SSID: ${YELLOW}$ssid${NC}"
        else
            echo -e "Status: ${RED}TIDAK AKTIF${NC}"
        fi
        echo -e "${BLUE}-----------------------------------${NC}"
        echo -e "  ${CYAN}1.${NC} Mulai Hotspot"
        echo -e "  ${CYAN}2.${NC} Hentikan Hotspot"
        echo -e "  ${CYAN}3.${NC} Lihat Perangkat Terhubung"
        echo -e "  ${CYAN}4.${NC} Lihat Total Penggunaan"
        echo -e "  ${MAGENTA}5.${NC} Pantau Jaringan (Real-time)"
        echo -e "  ${RED}0.${NC} Keluar"
        echo -e "${BLUE}-----------------------------------${NC}"
        read -p "$(echo -e ${YELLOW}"Pilih opsi: "${NC})" choice

        case $choice in
            1) start_hotspot; sleep 1 ;; 
            2) stop_hotspot; sleep 1 ;; 
            3) view_clients ;; 
            4) view_total_usage ;; 
            5) view_usage_realtime ;; 
            0) cleanup_on_exit ;; 
            *) echo -e "${RED}Pilihan tidak valid.${NC}"; sleep 1 ;; 
        esac
        
        if [[ "$choice" -ge 3 && "$choice" -le 4 ]]; then
            read -n 1 -s -r -p "$(echo -e ${YELLOW}"\nTekan tombol apa saja untuk kembali ke menu..."${NC})"
        fi
    done
}

# --- Eksekusi Utama ---
check_deps
main_menu
