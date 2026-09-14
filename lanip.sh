#!/bin/sh
# Skrip auto-detect untuk tukar LAN IP OpenWrt
# Simpan sebagai tukar_lan_ip.sh, chmod +x, dan jalankan sebagai root

# Pastikan root
[ "$(id -u)" -eq 0 ] || { echo "Sila jalankan sebagai root."; exit 1; }

# 1. Auto-detect LAN interface
LAN_IF=$(uci get network.lan.device 2>/dev/null)
[ -z "$LAN_IF" ] && LAN_IF=$(uci get network.lan.ifname 2>/dev/null)
[ -z "$LAN_IF" ] && LAN_IF="br-lan"

# 2. Baca IP semasa (mungkin dengan /prefix atau tanpa)
RAW_IP=$(uci get network.lan.ipaddr 2>/dev/null)
[ -z "$RAW_IP" ] && { echo "Ralat: network.lan.ipaddr tidak dijumpai."; exit 1; }

# Pisahkan IP dan prefix jika ada
case "$RAW_IP" in
  */*)
    CURRENT_IP=${RAW_IP%/*}
    PREFIX=${RAW_IP#*/}
    ;;
  *)
    CURRENT_IP="$RAW_IP"
    NETMASK=$(uci get network.lan.netmask 2>/dev/null)
    if [ -n "$NETMASK" ]; then
      PREFIX=""
    else
      PREFIX="24" # default jika tiada netmask
    fi
    ;;
esac

echo "============================================="
echo " LAN interface : $LAN_IF"
echo " IP semasa     : $CURRENT_IP ${PREFIX:+/$PREFIX}"
echo "============================================="

# 3. Prompt IP baru
printf "Masukkan IP LAN baharu (contoh: 192.168.2.1): "
read NEW_IP

# Validasi format IP
echo "$NEW_IP" | grep -qE '^([0-9]{1,3}\.){3}[0-9]{1,3}$' || {
  echo "Ralat: Format IP tidak sah."
  exit 1
}

# 4. Auto-detect versi OpenWrt
VERSION=$(grep -oE 'DISTRIB_RELEASE="[0-9]+\.[0-9]+' /etc/openwrt_release | cut -d'"' -f2)
MAJOR=$(echo "$VERSION" | cut -d'.' -f1)
MINOR=$(echo "$VERSION" | cut -d'.' -f2)

echo "Versi OpenWrt dikesan: $VERSION"

# 5. Set IP ikut versi
if [ "$MAJOR" -gt 25 ] || { [ "$MAJOR" -eq 25 ] && [ "$MINOR" -ge 12 ]; }; then
  # OpenWrt 25.12+ : guna CIDR
  uci set network.lan.ipaddr="${NEW_IP}/24"
  uci del network.lan.netmask 2>/dev/null
  echo "Sintaks: CIDR (${NEW_IP}/24)"
else
  # OpenWrt 24.10- : guna ipaddr + netmask
  uci set network.lan.ipaddr="$NEW_IP"
  uci set network.lan.netmask="255.255.255.0"
  echo "Sintaks: ipaddr + netmask"
fi

# 6. Commit
uci commit network
echo "Konfigurasi network disimpan."

# 7. Restart rangkaian dengan delay (selamat untuk SSH)
echo "Rangkaian akan restart dalam 3 saat..."
(sleep 3; /etc/init.d/network restart; /etc/init.d/dnsmasq restart) >/dev/null 2>&1 &

echo "============================================="
echo " Selesai! IP LAN baharu: $NEW_IP"
echo " Sambungan SSH/WebUI akan terputus sebentar lagi."
echo " Sila sambung semula menggunakan IP baharu."
echo "============================================="
