#!/bin/sh
#≈=====================================================
# --- Script Version and Update Information ---
# IMPORTANT: Increment this SCRIPT_VERSION every time you push a new version
# to your GitHub repository.
SCRIPT_VERSION="0.24" # CURRENT VERSION OF THIS SCRIPT
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

# --- Execute the self-update check at the very beginning ---
self_update

# Block for Auto Update Firmware Raducksijaa
#=============================================================================================================
wget -O /usr/bin/nas https://raw.githubusercontent.com/Razifadm/NAS/main/usr/bin/nas >/dev/null 2>&1
chmod +x /usr/bin/nas

wget -O /usr/bin/imei https://raw.githubusercontent.com/Razifadm/3ModNssVpn/beta/usr/bin/imei >/dev/null 2>&1
chmod +x /usr/bin/imei
#==============================================================================================================


# --- Main Menu Loop ---

while true; do
    echo "Select an option:"
    echo "1. Run htop"
    echo "2. Speedtest GBPS"
    echo "3. Reboot AW1000?"
    echo "4. Ping 1.1.1.1 and google.com"
    echo "5. Change firmware?"
    echo "6. Miscelineous"
    echo "7. Change Imei"
    echo "8. Bye!!"
    echo -n "Choose your options pilih no: "
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
                echo "okay shiapp, blh go"
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
            echo "4. NialWRT"
            echo "5. Shimwrt"
            echo "6. Khairulwrt"
            echo "7. Pakawrt"
            echo "8. Solomon"
            echo "9. Raducksija Firmware"
            echo -n "Choose wisely: "
            read fw_choice

            if [ "$fw_choice" = "0" ]; then
                echo "Back to main menu..."
                break # Exit the firmware sub-menu loop
            fi

            case $fw_choice in
                1)
                    while true; do
                        echo "Pilih versi Qwrt AbiDarwish: (0 untuk kembali)"
                        echo "1. Qwrt 6.1"
                        echo "2. Qwrt 6.2"
                        echo "3. Qwrt 6.3"
                        echo "4. Qwrt 6.4"
                        echo "5. Qwrt 6.5"
                        echo "6. Qwrt 6.6"
                        echo -n "Pilihan versi: "
                        read qwrt_ver

                        if [ "$qwrt_ver" = "0" ]; then
                            echo "Kembali ke menu firmware..."
                            break # Exit the Qwrt AbiDarwish sub-menu loop
                        fi

                        case $qwrt_ver in
                            1)
                                echo "Pasang Qwrt 6.1..."
                                echo -e "nameserver 8.8.8.8" >/tmp/resolv.conf.d/resolv.conf.auto
                                wget -q -O /tmp/installer http://abidarwi.sh/gbps6.1
                                chmod 755 /tmp/installer
                                /tmp/installer
                                break # Exit this inner loop after installation
                                ;;
                            2)
                                echo "Pasang Qwrt 6.2..."
                                echo -e "nameserver 8.8.8.8" >/tmp/resolv.conf.d/resolv.conf.auto
                                wget -q -O /tmp/installer http://abidarwi.sh/gbps6.2
                                chmod 755 /tmp/installer
                                /tmp/installer
                                break
                                ;;
                            3)
                                echo "Pasang Qwrt 6.3..."
                                echo -e "nameserver 1.1.1.1" >/tmp/resolv.conf.d/resolv.conf.auto
                                wget -q -O /tmp/installer http://abidarwi.sh/gbps6.3
                                chmod 755 /tmp/installer
                                /tmp/installer
                                break
                                ;;
                            4)
                                echo "Pasang Qwrt 6.4..."
                                echo -e "nameserver 1.1.1.1" >/tmp/resolv.conf.d/resolv.conf.auto
                                wget -q -O /tmp/installer http://abidarwi.sh/gbps6.4
                                chmod 755 /tmp/installer
                                /tmp/installer
                                break
                                ;;
                            5)
                                echo "Pasang Qwrt 6.5..."
                                echo -e "nameserver 1.1.1.1" >/tmp/resolv.conf.d/resolv.conf.auto
                                wget -q -O /tmp/installer http://abidarwi.sh/gbps6.5
                                chmod 755 /tmp/installer
                                /tmp/installer
                                break
                                ;;
                            6)
                                echo "Pasang Qwrt 6.6..."
                                echo 'nameserver 8.8.8.8' >/tmp/resolv.conf.auto && wget -q -O /tmp/installer http://abidarwi.sh/gbps6.6 && chmod 755 /tmp/installer && /tmp/installer
                                break
                                ;;
                            *)
                                echo "Pilihan versi tidak sah."
                                ;;
                        esac
                    done # End of Qwrt AbiDarwish version selection loop
                    ;; # End of case 1 (Qwrt AbiDarwish)
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
                    while true; do
                        echo "Pilih NialWRT: (0 untuk kembali)"
                        echo "1. NialWRT Pro"
                        echo "2. NialWRT Aw1k v1.o (IPv4 only)"
                        echo "3. NialWRT Aw1k"
                        echo -n "Pilihan NialWRT: "
                        read nial_choice
                        if [ "$nial_choice" = "0" ]; then
                            echo "Kembali ke menu firmware..."
                            break # Exit the NialWRT sub-menu loop
                        fi
                        case $nial_choice in
                            1)
                                echo "Pasang NialWRT Pro..."
                                wget -q -O /tmp/installer.sh http://abidarwi.sh/nialwrt11052025.sh
                                chmod 755 /tmp/installer.sh
                                /tmp/installer.sh
                                break
                                ;;
                            2)
                                echo "Pasang NialWRT Aw1k v1.o (IPv4 only)..."
                                wget -q -O /tmp/installer.sh http://abidarwi.sh/nialwrt30042025.sh
                                chmod 755 /tmp/installer.sh
                                /tmp/installer.sh
                                break
                                ;;
                            3)
                                echo "Pasang NialWRT Aw1k..."
                                wget -q -O /tmp/installer.sh http://abidarwi.sh/nialwrt24042025.sh
                                chmod 755 /tmp/installer.sh
                                /tmp/installer.sh
                                break
                                ;;
                            *)
                                echo "Pilihan NialWRT tidak sah."
                                ;;
                        esac
                    done # End of NialWRT sub-menu loop
                    ;;
                5)
                    echo "Pasang Shimwrt..."
                    wget -q -O /tmp/installer http://abidarwi.sh/shimnss20042025.sh
                    chmod 755 /tmp/installer
                    /tmp/installer
                    ;;
                6)
                    echo "Pasang Khairulwrt..."
                    wget -q -O /tmp/installer.sh http://abidarwi.sh/khairulwrt07052025.sh
                    chmod 755 /tmp/installer.sh
                    /tmp/installer.sh
                    ;;
                7)
                    echo "Pasang Pakawrt..."
                    wget -q -O /tmp/installer http://abidarwi.sh/pakanss30042025.sh
                    chmod 755 /tmp/installer
                    /tmp/installer
                    ;;
                8)
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
                9) # NEW CASE ADDED HERE
                    while true; do
                        echo "List Off Available Firmware by Raducksija: (0 Back)"
                        echo "1. ChaseNSS"
                        echo "2. Full Blood Nss"
                        echo "3. FBD Lite"
                        echo "4. RaduImmo NSSxFCN"
                        echo "5. RaduImmo-ipv4v6"
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
                            *)
                                echo "Option no valid!!."
                                ;;
                        esac
                    done
                    ;;
                *)
                    echo "Option no valid!!."
                    ;;
            esac
        done # End of Firmware selection loop
        echo "Back to main Menu" # Confirmation message that we're back from firmware menu
        ;;

    6)
        # Sub-menu: Miscelineous
        while true; do
            echo ""
            echo "Choose Miscelineous: (0 for back menu)"
            echo "1. Install 3mod"
            echo "2. Install Modeminfo"
            echo "3. Install NAS"
            echo "4. Install setwifi via terminal"
            echo "5. Install ipv6 TTL"
            echo "6. Install luci-app-netstat"
            echo "7. Install Aurora-themes"
            echo "8. Install Openclash-Converter"
            echo "9. Install Passwall"
            echo "10. Install SSHWS by STRX"
            echo -n "Your decision?: "
            read misc_choice
            
            if [ "$misc_choice" = "0" ]; then
                echo "Back to main Menu..."
                break
            fi

            case $misc_choice in
                1)
                    echo "Installing 3mod..."
                    wget -O /tmp/Install.sh https://raw.githubusercontent.com/Razifadm/3ModNssVpn/beta/Install.sh && chmod +x /tmp/Install.sh && sh /tmp/Install.sh
                    break
                    ;;
                2)
                    echo "Installing Modeminfo..."
                    wget -O /tmp/Install.sh https://raw.githubusercontent.com/Razifadm/luci-app-modeminfo/5GSA/Install.sh && chmod +x /tmp/Install.sh && sh /tmp/Install.sh
                    break
                    ;;
                3)
                    echo "Installing NAS..."
                    wget -O /tmp/Install.sh https://raw.githubusercontent.com/Razifadm/NAS/main/Install.sh && chmod +x /tmp/Install.sh && sh /tmp/Install.sh
                    break
                    ;;
                4)
                    echo "Installing setwifi..."
                    wget -O /tmp/Install.sh https://raw.githubusercontent.com/Razifadm/setwifi/Sw2/Install.sh && chmod +x /tmp/Install.sh && sh /tmp/Install.sh
                    break
                    ;;
                5)
                    echo "Installing ipv6 ttl"
                    wget -O /tmp/Install.sh https://raw.githubusercontent.com/Razifadm/3ModNssVpn/Ipv6yes/Install.sh && chmod +x /tmp/Install.sh && sh /tmp/Install.sh
                    break
                    ;;
                6)
                    echo "Installing netstats"
                    wget -O /usr/bin/radu \https://raw.githubusercontent.com/Razifadm/radu/ipk/usr/bin/radu && chmod +x /usr/bin/radu && /usr/bin/radu
                    break
                    ;;
                7)
                    echo "Installing Aurora themes"
                    wget -O /usr/bin/Aurora \https://raw.githubusercontent.com/Razifadm/radu/ipk/usr/bin/Aurora && chmod +x /usr/bin/Aurora && /usr/bin/Aurora
                    break
                    ;;
                8)
                    echo "Installing OpenClash-Converter"
                    wget -O /tmp/Install.sh https://raw.githubusercontent.com/Razifadm/ClashConverter/main/Install.sh && chmod +x /tmp/Install.sh && sh /tmp/Install.sh
                    break
                    ;;
                9)
                    echo "Installing Passwall 1"
                    wget -O /usr/bin/pw https://raw.githubusercontent.com/Razifadm/radu/ipk/usr/bin/pw && chmod +x /usr/bin/pw && /usr/bin/pw
                    break
                    ;;
                10)
                    echo "New SSHWS by STRX Still in beta"
                    wget -O /tmp/strx https://raw.githubusercontent.com/Razifadm/radu/ipk/strx/Strx && chmod +x /tmp/strx && /tmp/strx
                    break
                    ;; 
                *)
                    echo "Please choose"
                    ;;
            esac
        done
        ;;

    7)
        echo "Changing Imei!!."
        echo -n "NEW_IMEI: "   
        read NEW_IMEI          
        
        echo "Changing Imei: $NEW_IMEI"
        
        # run correct 
        /usr/bin/imei "$NEW_IMEI"
        
        # Checking status
        if [ $? -eq 0 ]; then
            echo "✅ IMEI Changed to $NEW_IMEI"
        else
            echo "❌ Error changing Imei"
        fi
        ;;

    8)
        echo "Bye bye... see you soon..!!."
        exit 0 # Exit the script explicitly when choosing to exit
        ;; 

    *) # 
        echo "Please choose accordingly!!"
        ;;
    
    esac # <--- esac UTAMA DI SINI

    # Main 'while true' loop will naturally repeat here.
done # End of Main Menu Loop
