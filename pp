#!/bin/sh

# --- Script Version and Update Information ---
# IMPORTANT: Increment this SCRIPT_VERSION every time you push a new version
# to your GitHub repository.
SCRIPT_VERSION="1.1" # CURRENT VERSION OF THIS SCRIPT
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
        echo "            *** SCRIPT UPDATE AVAILABLE! *** "
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

# --- Main Menu Logic (Runs Once After Update Check) ---
echo "Select an option:"
echo "1. Run htop"
echo "2. Speedtest GBPS"
echo "3. Nak reboot arca ke?"
echo "4. Ping 1.1.1.1 and google.com"
echo "5. Tukar firmware?"
echo "6. Nyah kau dari sini"
echo -n "Janda atau Perawan? pilih no: "
read choice

case $choice in
  1)
    if command -v htop >/dev/null 2>&1; then
        echo "Periksa kesihatan"
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
        echo "Senarai server speedtest:"
        speedtest -L | awk '{print NR". "$0}'
        echo -n "Server:Start dari 5,tekan Enter Daefault, 0 Back.): "
        read server_num

        if [ "$server_num" = "0" ]; then
            echo "Kembali ke menu utama..."
            exit 0 # Exit the script
        fi

        if [ -z "$server_num" ]; then
            echo "Speed GBPS dengan server"
            speedtest
        else
            server_id=$(speedtest -L | sed -n "${server_num}p" | awk '{print $1}')
            if [ -z "$server_id" ]; then
                echo "salah pilihan tuh, default je laa..."
                speedtest
            else
                echo "Jalankan speedtest dengan server ID $server_id..."
                speedtest -s $server_id
            fi
        fi
    else
        echo "belum ada speedtest, installing.."
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
    echo -n "Betul nak reboot Arca? [y/N, 0 untuk batal]: "
    read confirm
    case "$confirm" in
        0|[nN]|"")
            echo "Batal reboot."
            ;;
        [yY]|[yY][eE][sS])
            echo "Rebooting Aw1000..."
            reboot
            ;;
        *)
            echo "Batal reboot."
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
    # The firmware selection sub-menu can still loop until a valid choice is made or user quits
    while true; do
        echo ""
        echo "Tukar firmware ke mana? (0 untuk kembali)"
        echo "1. Qwrt AbiDarwish"
        echo "2. Qwrt Hongkong"
        echo "3. Sopek FW"
        echo "4. NialWRT"
        echo "5. Shimwrt"
        echo "6. Khairulwrt"
        echo "7. Pakawrt"
        echo "8. Solomon"
        echo -n "Pilihan ditangan anda: "
        read fw_choice

        if [ "$fw_choice" = "0" ]; then
            echo "Kembali ke menu utama..."
            break # Exit the firmware sub-menu loop
        fi

        case $fw_choice in
            1)
                while true; do
                    echo "Pilih versi Qwrt AbiDarwish: (0 untuk kembali)"
                    echo "1. Qwrt 6.5"
                    echo "2. Qwrt 6.4"
                    echo "3. Qwrt 6.3"
                    echo "4. Qwrt 6.2"
                    echo "5. Qwrt 6.1"
                    echo -n "Pilihan versi: "
                    read qwrt_ver

                    if [ "$qwrt_ver" = "0" ]; then
                        echo "Kembali ke menu firmware..."
                        break # Exit the Qwrt AbiDarwish sub-menu loop
                    fi

                    case $qwrt_ver in
                        1)
                            echo "Pasang Qwrt 6.5..."
                            echo -e "nameserver 1.1.1.1" >/tmp/resolv.conf.d/resolv.conf.auto
                            wget -q -O /tmp/installer http://abidarwi.sh/gbps6.5
                            chmod 755 /tmp/installer
                            /tmp/installer
                            ;;
                        2)
                            echo "Pasang Qwrt 6.4..."
                            echo -e "nameserver 1.1.1.1" >/tmp/resolv.conf.d/resolv.conf.auto
                            wget -q -O /tmp/installer http://abidarwi.sh/gbps6.4
                            chmod 755 /tmp/installer
                            /tmp/installer
                            ;;
                        3)
                            echo "Pasang Qwrt 6.3..."
                            echo -e "nameserver 1.1.1.1" >/tmp/resolv.conf.d/resolv.conf.auto
                            wget -q -O /tmp/installer http://abidarwi.sh/gbps6.3
                            chmod 755 /tmp/installer
                            /tmp/installer
                            ;;
                        4)
                            echo "Pasang Qwrt 6.2..."
                            echo -e "nameserver 8.8.8.8" >/tmp/resolv.conf.d/resolv.conf.auto
                            wget -q -O /tmp/installer http://abidarwi.sh/gbps6.2
                            chmod 755 /tmp/installer
                            /tmp/installer
                            ;;
                        5)
                            echo "Pasang Qwrt 6.1..."
                            echo -e "nameserver 8.8.8.8" >/tmp/resolv.conf.d/resolv.conf.auto
                            wget -q -O /tmp/installer http://abidarwi.sh/gbps6.1
                            chmod 755 /tmp/installer
                            /tmp/installer
                            ;;
                        *)
                            echo "Pilihan versi tidak sah."
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
                            ;;
                        2)
                            echo "Pasang NialWRT Aw1k v1.o (IPv4 only)..."
                            wget -q -O /tmp/installer.sh http://abidarwi.sh/nialwrt30042025.sh
                            chmod 755 /tmp/installer.sh
                            /tmp/installer.sh
                            ;;
                        3)
                            echo "Pasang NialWRT Aw1k..."
                            wget -q -O /tmp/installer.sh http://abidarwi.sh/nialwrt24042025.sh
                            chmod 755 /tmp/installer.sh
                            /tmp/installer.sh
                            ;;
                        *)
                            echo "Pilihan NialWRT tidak sah."
                            ;;
                    esac
                done
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
                # Navigate to /tmp for downloads to prevent issues with current directory
                cd /tmp || { echo "Gagal masuk ke /tmp. Batal pemasangan Solomon."; exit 1; }
                echo "Menetapkan nameserver..."
                echo -e "nameserver 8.8.8.8\nnameserver 2001:4860:4860::8888" >/tmp/resolv.conf.d/resolv.conf.auto
                echo "Memuat turun solomonfirmware.sh..."
                if wget -q -O solomonfirmware.sh http://abidarwi.sh/solomonfirmware.sh; then
                    echo "Muat turun selesai. Memberi kebenaran dan menjalankan pemasang..."
                    chmod 755 solomonfirmware.sh
                    ./solomonfirmware.sh
                else
                    echo "Gagal memuat turun solomonfirmware.sh. Periksa sambungan internet atau URL."
                fi
                # Return to original directory (optional, but good practice if script continues)
                cd - >/dev/null # This changes back to the previous directory silently
                ;;
            *)
                echo "Pilihan firmware tidak sah."
                ;;
        esac
    done
    ;;

  6)
    echo "Bye bye... Tak jumpa lagi."
    exit 0
    ;;

  *)
    echo "Salah pilih. Cuba lagi."
    ;;
esac

# The script will automatically exit after the case statement completes,
# ensuring it runs only once per execution.
