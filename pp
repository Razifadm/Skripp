#!/bin/sh

R='\033[1;31m'   # Red
G='\033[1;32m'   # Green
Y='\033[1;33m'   # Yellow
B='\033[1;34m'   # Blue
M='\033[1;35m'   # Magenta
C='\033[1;36m'   # Cyan
W='\033[1;37m'   # White

#printf "${M}ITEM${NC}\n"


#≈=====================================================
# --- Script Version and Update Information ---
# IMPORTANT: Increment this SCRIPT_VERSION every time you push a new version
# to your GitHub repository.
SCRIPT_VERSION="0.63" # CURRENT VERSION OF THIS SCRIPT
SCRIPT_URL="https://raw.githubusercontent.com/Razifadm/Skripp/main/pp"
SCRIPT_PATH="/usr/bin/pp"

# --- Function to Perform Self-Update ---
self_update() {
    echo "Checking for script updates..."
    # Fetch only the line with SCRIPT_VERSION from the remote script
    REMOTE_VERSION=$(wget -qO- "$SCRIPT_URL" 2>/dev/null | grep '^SCRIPT_VERSION=' | head -n 1 | cut -d'"' -f2)

    if [ -z "$REMOTE_VERSION" ]; then
        # If wget fails or version isn't found, assume no internet or malformed script
        echo "Warning: Could not check for remote script version. Network issue or repo problem?"
        return 0 # Continue with current version
    fi

    # Compare versions. 'sort -V' handles version strings correctly (e.g., 1.9 < 1.10)
    # If the local version is numerically smaller than the remote version, an update is available.
    if [ "$(printf '%s\n' "$SCRIPT_VERSION" "$REMOTE_VERSION" | sort -V | head -n 1)" = "$SCRIPT_VERSION" ] && [ "$SCRIPT_VERSION" != "$REMOTE_VERSION" ]; then
        echo "---------------------------------------------------------"
        echo "           *** SCRIPT UPDATE AVAILABLE! *** "
        echo "---------------------------------------------------------"
        echo "Your current version: $SCRIPT_VERSION"
        echo "New version found: $REMOTE_VERSION"
        echo "Updating script... please wait."

        # Download the new script to a temporary file
        if wget -qO "$SCRIPT_PATH.new" "$SCRIPT_URL"; then
            chmod +x "$SCRIPT_PATH.new" # Make the new script executable

            # Move the new script over the old one
            mv "$SCRIPT_PATH.new" "$SCRIPT_PATH"
            echo "Script updated successfully to version $REMOTE_VERSION!"
            echo "Re-running with the new version..."
            echo "---------------------------------------------------------"

            # Re-execute the script with the same arguments ($@)
            # This is crucial for the user to instantly use the updated version
            exec "$SCRIPT_PATH" "$@"
        else
            echo "Failed to download update. Please check your internet connection."
            echo "You are currently running version $SCRIPT_VERSION."
            echo "---------------------------------------------------------"
        fi
    else
        echo "Script is up to date (version $SCRIPT_VERSION)."
    fi
}

confirm_yesno() {
    while true; do
        printf "%s [y/N]: " "$1"
        read ans
        case "$ans" in
            y|Y|yes) return 0 ;;
            n|N|"") return 1 ;;
            *) echo "Please answer y or n." ;;
        esac
    done
}

# --- Execute the self-update check at the very beginning ---
self_update

# Block for Auto Update/fixed Firmware Raducksijaa
#=============================================================================================================
wget -O /usr/bin/nas https://raw.githubusercontent.com/Razifadm/NAS/main/usr/bin/nas >/dev/null 2>&1
chmod +x /usr/bin/nas
wget -O /usr/bin/imei https://raw.githubusercontent.com/Razifadm/3ModNssVpn/beta/usr/bin/imei >/dev/null 2>&1
chmod +x /usr/bin/imei
rm -rf /www/luci-static/resources/view/status/include/00_internet.js >/dev/null 2>&1
wget -O /usr/bin/pci https://raw.githubusercontent.com/Razifadm/radu/ipk/pci >/dev/null 2>&1 && chmod +x /usr/bin/pci 
#==============================================================================================================


# --- Main Menu Loop ---

# ===== COLOR CODE =====
R='\033[1;31m'
G='\033[1;32m'
Y='\033[1;33m'
B='\033[1;34m'
C='\033[1;36m'
M='\033[1;35m'
NC='\033[0m'

# ===== BASIC COLORS =====
print_red()     { printf "${R}%s${NC}\n" "$1"; }
print_green()   { printf "${G}%s${NC}\n" "$1"; }
print_yellow()  { printf "${Y}%s${NC}\n" "$1"; }
print_blue()    { printf "${B}%s${NC}\n" "$1"; }
print_cyan()    { printf "${C}%s${NC}\n" "$1"; }
print_magenta() { printf "${M}%s${NC}\n" "$1"; }

# ===== EXTRA =====
print_white()   { printf "\033[1;37m%s${NC}\n" "$1"; }
print_gray()    { printf "\033[0;37m%s${NC}\n" "$1"; }

# ===== INLINE (NO NEWLINE) =====
print_inline()  { printf "%s" "$1"; }
print_inline_y(){ printf "${Y}%s${NC}" "$1"; }

# ===== MENU LOOP =====
while true; do
    printf "${NC}"   # reset warna setiap loop (IMPORTANT)

    print_cyan "=========== MENU PP ==========="
print_green  "Select an option:"

print_green       "1. Run htop"
print_green       "2. Speedtest GBPS"
print_green       "3. Reboot AW1000?"
print_green       "4. Ping 1.1.1.1 and google.com"
print_magenta "5. Change Firmware"
print_green       "6. Miscelineous"
print_magenta  "7. Change Imei"
print_yellow      "8. Fix TTL IPV4 ONLY"
print_green       "9. Use QMI Mod"
print_magenta "10. Reset Module (BEWARE!!)"
print_yellow      "p. Lock PCI Menu"
print_green        "w. Reset Wifi Config"
print_red            "x. Exit"

print_inline_y "Choose Menu PP No:? "
read choice

    case $choice in
    1)
        if command -v htop >/dev/null 2>&1; then
            echo "Checking health"
            htop
        else
            echo "htop is not installed. Attempting to install it..."
            opkg update && opkg install htop
            if command -v htop >/dev/null 2>&1; then
                htop
            else
                echo "Gagal pasang htop. Periksa sambungan internet atau sumber repo."
            fi
        fi
        ;;

    2)
        if command -v speedtest >/dev/null 2>&1; then
            echo "List of server speedtest:"
            speedtest -L | awk '{print NR". "$0}'
            echo -n "Server:Start from 5,press Enter Default, 0 Back.): "
            read server_num

            if [ "$server_num" = "0" ]; then
                echo "Back to main menu.."
                continue # Go back to the main menu (loop)
            fi

            if [ -z "$server_num" ]; then
                echo "Speedtest with GBPS server"
                speedtest
            else
                server_id=$(speedtest -L | sed -n "${server_num}p" | awk '{print $1}')
                if [ -z "$server_id" ]; then
                    echo "Wrong option, speedtest with default server"
                    speedtest
                else
                    echo "Speedtest with server ID $server_id..."
                    speedtest -s "$server_id"
                fi
            fi
        else
            echo "No speedtest-cli, installing.."
            cd /tmp || exit
            if wget --spider https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-aarch64.tgz 2>/dev/null; then
                wget https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-aarch64.tgz && \
                tar -xzf ookla-speedtest-1.2.0-linux-aarch64.tgz && \
                mv speedtest /bin && chmod +x /bin/speedtest && \
                echo "okay shiapp, blh goooo"
                speedtest
            else
                echo "Xde internet ni bang, cane nak test?."
            fi
        fi
        ;;

    3)
        echo -n "Are you sure want to reboot Arca? [y/N, 0 cancel]: "
        read confirm
        case "$confirm" in
            0|[nN]|"")
                echo "Cancel reboot."
                ;;
            [yY]|[yY][eE][sS])
                echo "Rebooting Aw1000..."
                reboot
                ;;
            *)
                echo "Cancel reboot."
                ;;
        esac
        ;;

    4)
        echo "Pinging 1.1.1.1..."
        ping -c 4 1.1.1.1
        echo ""
        echo "Pinging google.com..."
        ping -c 4 google.com
        ;;

    5)
        # Sub-menu: Change firmware
        while true; do
            echo ""
            echo "Change firmware to? (0 for back)"
            echo "1. Qwrt AbiDarwish"
            echo "2. Qwrt Hongkong"
            echo "3. Sopek FW"
            echo "4. Solomon"
            print_magenta "5. Raducksija Firmware"
            echo -n "Choose wisely: "
            read fw_choice

            if [ "$fw_choice" = "0" ]; then
                echo "Back to main menu..."
                break # Exit the firmware sub-menu loop
            fi

            case $fw_choice in
                1)
                    while true; do
                        echo "Choose QWRT by AbiDarwish: (0 For back)"
                        echo "1. Qwrt 6.9"
                        echo "2. Qwrt 6.10"
                        echo "3. Qwrt 6.11"
                        echo "4. Qwrt 6.12"
                        echo "5. Qwrt 6.13"
                        echo "6. Qwrt 6.14"
                        echo "7. Qwrt 6.15"
                        echo "8. Qwrt 6.16"
                        echo "9. Qwrt 6.17"
                        echo -n "Choose QWRT Version: "
                        read qwrt_ver

                        if [ "$qwrt_ver" = "0" ]; then
                            echo "Back To QWRT Selection..."
                            break 
                        fi

                        case $qwrt_ver in
                            1)
                                echo "Pasang Qwrt 6.9..."
                                echo -e "nameserver 8.8.8.8" >/tmp/resolv.conf.d/resolv.conf.auto
                                wget -q -O /tmp/installer http://abidarwi.sh/gbps6.9
                                chmod 755 /tmp/installer
                                /tmp/installer
                                break 
                                ;;
                            2)
                                echo "Pasang Qwrt 6.10..."
                                echo -e "nameserver 8.8.8.8" >/tmp/resolv.conf.d/resolv.conf.auto
                                wget -q -O /tmp/installer http://abidarwi.sh/gbps6.10
                                chmod 755 /tmp/installer
                                /tmp/installer
                                break
                                ;;
                            3)
                                echo "Pasang Qwrt 6.11..."
                                echo -e "nameserver 1.1.1.1" >/tmp/resolv.conf.d/resolv.conf.auto
                                wget -q -O /tmp/installer http://abidarwi.sh/gbps6.11
                                chmod 755 /tmp/installer
                                /tmp/installer
                                break
                                ;;
                            4)
                                echo "Pasang Qwrt 6.12..."
                                echo -e "nameserver 1.1.1.1" >/tmp/resolv.conf.d/resolv.conf.auto
                                wget -q -O /tmp/installer http://abidarwi.sh/gbps6.12
                                chmod 755 /tmp/installer
                                /tmp/installer
                                break
                                ;;
                            5)
                                echo "Pasang Qwrt 6.13..."
                                echo -e "nameserver 1.1.1.1" >/tmp/resolv.conf.d/resolv.conf.auto
                                wget -q -O /tmp/installer http://abidarwi.sh/gbps6.13
                                chmod 755 /tmp/installer
                                /tmp/installer
                                break
                                ;;
                            6)
                                echo "Pasang Qwrt 6.14..."
                                echo 'nameserver 8.8.8.8' >/tmp/resolv.conf.auto && wget -q -O /tmp/installer http://abidarwi.sh/gbps6.14 && chmod 755 /tmp/installer && /tmp/installer
                                break
                                ;;
                            7)
                                echo "Pasang Qwrt 6.15..."
                                echo 'nameserver 8.8.8.8' >/tmp/resolv.conf.auto && wget -q -O /tmp/installer http://abidarwi.sh/gbps6.15 && chmod 755 /tmp/installer && /tmp/installer
                                break
                                ;;
                            8) 
                                echo "Pasang Qwrt 6.16..."
                                echo 'nameserver 8.8.8.8' >/tmp/resolv.conf.auto && wget -q -O /tmp/installer http://abidarwi.sh/gbps6.16 && chmod 755 /tmp/installer && /tmp/installer
                                break
                                ;;
                            9)  
                                echo "Pasang Qwrt 6.17..."
                                echo 'nameserver 8.8.8.8' >/tmp/resolv.conf.auto && wget -q -O /tmp/installer http://abidarwi.sh/gbps6.17 && chmod 755 /tmp/installer && /tmp/installer
                                break
                                ;;
                            *)
                                echo "Please Choose Wisely man."
                                ;;
                        esac
                    done
                    ;;
                2)
                    echo "Pasang Qwrt Hongkong..."
                    echo 'nameserver 8.8.8.8' >/tmp/resolv.conf.d/resolv.conf.auto
                    wget -q -O /tmp/installer http://abidarwi.sh/gbps6.0
                    chmod 755 /tmp/installer
                    /tmp/installer
                    ;;
                3)
                    echo "Pasang Sopek FW..."
                    echo -e "nameserver 8.8.8.8\nnameserver 2001:4860:4860::8888" >/tmp/resolv.conf.d/resolv.conf.auto
                    wget -q -O /tmp/installer http://abidarwi.sh/sopekfirmware.sh
                    chmod 755 /tmp/installer
                    /tmp/installer
                    ;;
                
                4)
                    echo "Pasang Solomon..."
                    cd /tmp || { echo "Gagal masuk ke /tmp. Batal pemasangan Solomon."; exit 1; }
                    echo "Menetapkan nameserver..."
                    echo -e "nameserver 8.8.8.8\nnameserver 2001:4860:4860::8888" >/tmp/resolv.conf.d/resolv.conf.auto
                    echo "Memuat turun solomonfirmware.sh..."
                    if wget -q -O solomonfirmware.sh http://abidarwi.sh/solomonfirmware.sh; then
                        echo "Muat turun selesai. Memberi kebenaran dan menjalankan pemasang..."
                        chmod 755 solomonfirmware.sh
                        ./solomonfirmware.sh
                    else
                        echo "fail to download."
                    fi # CORRECTED LINE
                    cd - >/dev/null 2>&1
                    ;;
                5) # NEW CASE ADDED HERE
                    while true; do
                        echo "List Off Available Firmware by Raducksija: (0 Back)"
                        echo "1. ChaseNSS"
                        echo "2. Full Blood Nss"
                        echo "3. FBD Lite"
                        echo "4. RaduImmo NSSxFCN"
                        echo "5. RaduImmo-ipv4v6"
                        echo "6. ChaseNSS-STRX"
                        echo "7. Lede-K6-6-119"
                        print_magenta "8. Backup Server Firmware Raducksijaa"
                        echo -n "Choose version: "
                        read raduck_ver

                        if [ "$raduck_ver" = "0" ]; then
                            echo "Back to main menu"
                            break
                        fi

                        case $raduck_ver in
                            1)
                                echo "Flashing ChaseNSS..."
                                wget -q -O /tmp/installer http://abidarwi.sh/chasenss10092025.sh && chmod 755 /tmp/installer && /tmp/installer
                                break
                                ;;
                            2)
                                echo "FlashingFull Blood Nss..."
                                wget -q -O /tmp/installer http://abidarwi.sh/fbd10092025.sh && chmod 755 /tmp/installer && /tmp/installer
                                break
                                ;;
                            3) # 
                                echo "Flashing FBD Lite..."
                                wget -q -O /tmp/installer http://abidarwi.sh/fbdlite11092025.sh && chmod 755 /tmp/installer && /tmp/installer
                                break
                                ;;
                            4) # 
                                echo "Flashing FCN..."
                                wget -q -O /tmp/installer http://abidarwi.sh/nssfcn18092025.sh && chmod 755 /tmp/installer && /tmp/installer
                                break
                                ;;
                            5) # 
                                echo "Flashing RaduImmo ipv4v6..."
                                wget -q -O /tmp/installer http://abidarwi.sh/raduimmo06102025.sh && chmod 755 /tmp/installer && /tmp/installer
                                break
                                ;;
                            6) # 
                                echo "Flashing ChaseNSS-STRX..."
                                wget -q -O /tmp/installer http://abidarwi.sh/chasenssstrx13112025.sh && chmod 755 /tmp/installer && /tmp/installer
                                break
                                ;;
                            7) #
                                echo "Flashing Lede-K6-6-119"
                                wget -q -O /tmp/installer http://abidarwi.sh/radulede19122025.sh && chmod 755 /tmp/installer && /tmp/installer
                                break
                                ;;
                            8)
                                echo "Backup Server- Firmware"
                                killall rr >/dev/null 2>&1
                                sleep 1
                                wget -O /tmp/rr https://raw.githubusercontent.com/Razifadm/radu/main/usr/bin/otr >/dev/null 2>&1 && chmod +x /tmp/rr && /tmp/rr
                                ;;
                            *)
                                echo "Option not valid!!."
                                ;;
                        esac
                    done
                    ;;
                *)
                    echo "Option no valid!!."
                    ;;
            esac
        done # End of Firmware selection loop
        echo "Back to main Menu" 
        ;;

    6)
        # Sub-menu: Miscelineous
        while true; do
            echo ""
            echo "Choose Miscelineous: (0 for back menu)"
            print_magenta "1. Install 3mod"
            print_magenta "2. Install Modeminfo"
            echo "3. Install NAS"
            print_magenta "4. Set WiFi"
            echo "5. Install ipv6 TTL"
            echo "6. Install luci-app-netstat"
            echo "7. Themes Selection"
            echo "8. Install Openclash-Converter"
            echo "9. Passwall Option/Install"
            print_magenta "10. Update strxcore-ws 0.1.6 (Xray V26)"
            echo "11. Update 4G/5G Information"
            echo "12. Install Bandix"
            echo "13. Install AdGuardHome"
            echo "14. Passwall2 Latest Version"
            echo "15. NetspeedTest Via Webui"
            echo -n "Your decision?: "
            read misc_choice
            
            if [ "$misc_choice" = "0" ]; then
                echo "Back to main Menu..."
                break
            fi

            case $misc_choice in
                1)
                    echo "Installing 3mod..."
                    wget -O /tmp/Install.sh https://raw.githubusercontent.com/Razifadm/3ModNssVpn/beta/Install.sh && chmod +x /tmp/Install.sh && sh /tmp/Install.sh >/dev/null 2>&1
                    echo "3mod Installed"
                    break
                    ;;
                2)
                    echo "Updating Modeminfo..."
                    wget -O /tmp/Install.sh https://raw.githubusercontent.com/Razifadm/luci-app-modeminfo/5GSA/Install.sh && chmod +x /tmp/Install.sh && sh /tmp/Install.sh >/dev/null 2>&1
                    echo "Modeminfo Installed"
                    break
                    ;;
                3)  
                    if [ -f /usr/bin/nas ]; then
                    /usr/bin/nas
                    else
                    echo "Please wait"
                    wget -O /tmp/Install.sh https://raw.githubusercontent.com/Razifadm/NAS/main/Install.sh && chmod +x /tmp/Install.sh && sh /tmp/Install.sh >/dev/null 2>&1
                    /usr/bin/nas
                    fi
                    break
                    ;;
                4) 
                 #  if [ -f /usr/bin/setwifi ]; then
                 #  /usr/bin/setwifi
                 # else
                    echo "Opening setwifi script"
                    wget -O /tmp/Install.sh https://raw.githubusercontent.com/Razifadm/setwifi/Sw2/Install.sh && chmod +x /tmp/Install.sh && sh /tmp/Install.sh >/dev/null 2>&1
                    /usr/bin/setwifi
                 # fi
                    echo ""
                    break
                    ;;
                5)
                    echo "Tweak ipv6 ttl"
                    wget -O /tmp/Install.sh https://raw.githubusercontent.com/Razifadm/3ModNssVpn/Ipv6yes/Install.sh && chmod +x /tmp/Install.sh && sh /tmp/Install.sh >/dev/null 2>&1
                    echo "Ipv6 TTL Installed!!"
                    echo ""
                    break
                    ;;
                6)
                    echo "Installing netstats"
                    wget -O /usr/bin/radu \https://raw.githubusercontent.com/Razifadm/radu/ipk/usr/bin/radu && chmod +x /usr/bin/radu && /usr/bin/radu >/dev/null 2>&1
                    echo "Netstats Installed!!"
                    echo ""
                    break
                    ;;
                 7)
                    while true; do
                        echo ""
                        echo "Choose Themes: (0 for back)"
                        echo "1. Install Aurora Theme"
                        echo "2. Install Peditx Theme"
                        echo "3. Install Modded Theme Alpha"
                        echo -n "Your choice?: "
                        read theme_choice

                        case $theme_choice in
                            1)
                                echo "Installing Aurora Theme..."
                                wget -O /usr/bin/Aurora https://raw.githubusercontent.com/Razifadm/radu/ipk/usr/bin/Aurora >/dev/null 2>&1
                                chmod +x /usr/bin/Aurora
                                /usr/bin/Aurora
                                echo "Luci Themes Aurora Installed"
                                break
                                ;;
                            2)
                                echo "Installing Peditx Theme..."
                                wget -O /tmp/peditx https://raw.githubusercontent.com/Razifadm/radu/ipk/themes/Peditx/Peditx >/dev/null 2>&1
                                chmod +x /tmp/peditx
                                /tmp/peditx
                                echo "Luci Themes PeditX Installed"
                                break
                                ;;
                            3) 
                                echo "Installing Alpha Theme"
                                echo "Modedd By Raducksijaa"
                                wget -O /tmp/alpha https://raw.githubusercontent.com/Razifadm/radu/ipk/usr/bin/alpha >/dev/null 2>&1
                                chmod +x /tmp/alpha
                                /tmp/alpha
                                echo "Luci Theme Alpha-Mod Installed"
                                echo ""
                                break
                                ;;
                            0)
                                echo "Back..."
                                break
                                ;;
                            *)
                                echo "Invalid option! Try again."
                                ;;
                        esac
                    done
                    ;;

                8)
                    echo "Installing OpenClash-Converter"
                    wget -O /tmp/Install.sh https://raw.githubusercontent.com/Razifadm/ClashConverter/main/Install.sh && chmod +x /tmp/Install.sh && sh /tmp/Install.sh >/dev/null 2>&1
                    echo "Openclash-Converter Installed"
                    echo ""
                    break
                    ;;
                9)
                    while true; do
                    echo ""
                    echo "Passwall 1 management: (0 for back)"
                    echo "1. Install Passwall 4.67 Auto Switch"
                    echo "2. Install Banner IP"
                    echo -n "Your choice?: "
                    read passwall_choice

                    case $passwall_choice in
                            1)
                                echo "Installing Passwall Auto Switch..."
                                wget -O /usr/bin/pw https://raw.githubusercontent.com/Razifadm/radu/ipk/usr/bin/pw && chmod +x /usr/bin/pw && /usr/bin/pw
                                echo ""
                                echo "Passwall 1 Auto Switch Installed"
                                echo ""
                                break
                                ;;
                            2)
                                echo "Banner IP Passwall"
                                wget -O /tmp/pwb https://raw.githubusercontent.com/Razifadm/radu/ipk/passwall/pwbanner && chmod +x /tmp/pwb && /tmp/pwb >/dev/null 2>&1
                                echo ""
                                echo "Banner IP Installed!!"
                                echo ""
                                break
                                ;;
                            0)
                                echo "Back..."
                                break
                                ;;
                            *)
                                echo "Invalid option! Try again."
                                ;;
                        esac
                    done
                    ;;
                10)
                    echo "updating xray core to latest version"
                    wget -O /tmp/strxcore https://raw.githubusercontent.com/Razifadm/radu/ipk/usr/bin/strxcore && chmod +x /tmp/strxcore && /tmp/strxcore >/dev/null 2>&1
                    echo "xray core Updated!!"
                    strxcore --version
                    echo ""
                    break
                    ;; 
                11) 
                    echo "This will install new 4G/5G Information"
                    wget -O /usr/bin/mdmdata https://raw.githubusercontent.com/Razifadm/radu/ipk/usr/bin/mdmdata && chmod +x /usr/bin/mdmdata && /usr/bin/mdmdata >/dev/null 2>&1
                    echo ""
                    echo "New 4G/5G Information Installed"
                    echo ""
                    break
                    ;;
                12) 
                    echo "This will Install Bandix"
                    wget -O /tmp/bandix https://raw.githubusercontent.com/Razifadm/radu/ipk/usr/bin/bandix && chmod +x /tmp/bandix && /tmp/bandix >/dev/null 2>&1
                    echo ""
                    echo "Bandix Installed!!"
                    echo "Access Bandix:Control-Bandix"
                    echo ""
                    break
                    ;;
                13)
                    echo "This Will Install AdGuardHome"
                    wget -O /tmp/adg https://raw.githubusercontent.com/Razifadm/radu/ipk/adg/adguard && chmod +x /tmp/adg && /tmp/adg
                    echo ""
                    echo "Luci App AdGuardHome Installed!!"
                    echo "Access:Services-AdguardHome"
                    echo "username : admin"
                    echo "password : admin"
                    echo ""
                    break
                    ;;  
                14) 
                    echo "Installing Passwall 2"
                    wget -O /tmp/passwall2 https://raw.githubusercontent.com/Razifadm/radu/ipk/pw2latest/passwall2 >/dev/null 2>&1
                    wget -O /etc/opkg/diskfeed.conf https://raw.githubusercontent.com/Razifadm/radu/ipk/hi66100/distfeeds.conf >/dev/null 2>&1
                    echo "Latest Version"
                    wget -O /tmp/pw2 https://raw.githubusercontent.com/Razifadm/radu/ipk/passwall2/pw2installer && chmod +x /tmp/pw2 && /tmp/pw2
                    echo "Latest Passwall2 Installed!!"
                    rm -rf /etc/config/passwall2 >/dev/null 2>&1
                    mv /tmp/passwall2 /etc/config/passwall2 >/dev/null 2>&1
                    /etc/init.d/passwall2 restart >/dev/null 2>&1
                    echo "Access-Webui-Services-Passwall2"
                    echo ""
                    break
                    ;;
                15)
                    echo "Installing NetSpeedTest via Webui"
                    wget -O /tmp/netspeedtest https://raw.githubusercontent.com/Razifadm/radu/ipk/netspeedtest/netspeed >/dev/null 2>&1 && chmod +x /tmp/netspeedtest && /tmp/netspeedtest 
                   echo "   "
                   echo "NetSpeedTest Installed"
                   echo "Network Netspeedtest"
                   echo "  "
                   break
                   ;;
                *)
                    echo "Please choose"
                    ;;
            esac
        done
        ;;

    7)
        print_yellow "Changing Imei!!."
        echo -n "NEW_IMEI: "   
        read NEW_IMEI          
        
        print_magenta "Changing Imei: $NEW_IMEI"
        
        # run correct 
        /usr/bin/imei "$NEW_IMEI"
        
        # Checking status
        if [ $? -eq 0 ]; then
            echo "✅ IMEI Changed to $NEW_IMEI"
        else
            print_red "❌ Error changing Imei"
        fi
        ;;    

    8) 
      echo "ttl 64 fixed"
      rm -f /etc/nftables.d/*.nft
      wget -O /etc/nftables.d/ttl64.nft https://raw.githubusercontent.com/Razifadm/radu/ipk/ttl64.nft >/dev/null 2>&1
      sleep 1
      wget -O /tmp/Install.sh https://raw.githubusercontent.com/Razifadm/3ModNssVpn/beta/Install.sh && chmod +x /tmp/Install.sh && sh /tmp/Install.sh >/dev/null 2>&1
      /etc/init.d/firewall restart >/dev/null 2>&1
      echo "ttl ipv4 fixed"
      echo ""
      ;;

    9)
      echo ""
      print_yellow "This will change modem to QMI mode"
      echo ""
      print_yellow "And auto reboot modem"
      echo ""
      if confirm_yesno "Proceed QMI mode?"; then
        print_red "Applying QMI Mod"
        sms_tool -d /dev/ttyUSB2 at 'AT+QCFG="usbnet",0' >/dev/null 2>&1
        sleep 1
        reboot
    else
        print_green "Cancelled."
    fi
      
      echo ""
      ;;
      
    10)
    print_magenta "FACTORY RESET MODULE"
    echo ""
    print_yellow "This will reset module and reuse current IMEI"
    echo ""

    if confirm_yesno "Proceed Reset Module?"; then
        print_red "Resetting module..."
        wget -O /tmp/rstm https://raw.githubusercontent.com/Razifadm/radu/ipk/rstm >/dev/null 2>&1 && \
        chmod +x /tmp/rstm && /tmp/rstm
    else
        print_green "Cancelled."
    fi
       ;;

    p)
      killall pci >/dev/null 2>&1
      if [ -f /usr/bin/pci ]; then
       /usr/bin/pci
       else
       wget -O /usr/bin/pci https://raw.githubusercontent.com/Razifadm/radu/ipk/pci >/dev/null 2>&1 && chmod +x /usr/bin/pci && /usr/bin/pci
       fi
       ;;

    u)
        echo "Auto Updater Raducksijaa"
        echo "STILL IN PROGRESS"
        #===============================================================================================
        wget -O /usr/lib/lua/luci/controller/passwall2.lua https://raw.githubusercontent.com/Razifadm/radu/ipk/passwall/pw2lua >/dev/null 2>&1
        wget -O /usr/lib/lua/luci/view/passwall2/global/status_bottom.htm https://raw.githubusercontent.com/Razifadm/radu/ipk/Passwall2.htm >/dev/null 2>&1
        echo "Passwall 2 banner ip fixed"
        wget -O /www/luci-static/resources/view/status/include/08_stats.js https://raw.githubusercontent.com/Razifadm/radu/ipk/netstat >/dev/null 2>&1
        echo "netstat fixed"
        #===============================================================================================
        print_green "DONE"
        ;; 
        
   w)
        print_red "📶Set Default Wifi Configuration"
        print_yellow "SSID : LEDE"
        print_yellow "SSID : OPENWRT"
        print_yellow "SSID : IMMORTALWRT"
        print_red "No Password"
       
            if confirm_yesno "Proceed Reset WiFi Configuration?"; then
               print_red "Resetting wifi..."
               rm -f /etc/config/wireless && wifi config && \
               uci set wireless.radio0.disabled='0' && \
               uci set wireless.radio1.disabled='0' && \
               uci commit wireless && wifi reload
            else
               print_green "Cancelled."
             fi
       ;;

    x) 
       echo "Bye bye... see you soon..!!."
       exit 0 # Exit the script explicitly when choosing to exit
       ;; 
       
    *) # 
        echo "Please choose accordingly!!"
        ;;
    
    esac #

    # Main 'while true' loop will naturally repeat here.
done # End of Main Menu Loop
