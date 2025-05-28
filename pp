#!/bin/sh

# --- Script Version and Update Information ---
# IMPORTANT: Increment this SCRIPT_VERSION every time you push a new version
# to your GitHub repository.
SCRIPT_VERSION="0.1" # CURRENT VERSION OF THIS SCRIPT
SCRIPT_URL="https://raw.githubusercontent.com/Razifadm/Skripp/main/pp"
SCRIPT_PATH="/usr/bin/pp"

# --- Function to Perform Self-Update ---
self_update() {
    echo "Checking for script updates..."
    REMOTE_VERSION=$(wget -qO- "$SCRIPT_URL" 2>/dev/null | grep '^SCRIPT_VERSION=' | head -n 1 | cut -d'"' -f2)

    if [ -z "$REMOTE_VERSION" ]; then
        echo "Warning: Could not check for remote script version. Network issue or repo problem?"
        return 0
    fi

    if [ "$(printf '%s\n' "$SCRIPT_VERSION" "$REMOTE_VERSION" | sort -V | head -n 1)" = "$SCRIPT_VERSION" ] && [ "$SCRIPT_VERSION" != "$REMOTE_VERSION" ]; then
        echo "---------------------------------------------------------"
        echo "           *** SCRIPT UPDATE AVAILABLE! *** "
        echo "---------------------------------------------------------"
        echo "Your current version: $SCRIPT_VERSION"
        echo "New version found: $REMOTE_VERSION"
        echo "Updating script... please wait."

        if wget -qO "$SCRIPT_PATH.new" "$SCRIPT_URL"; then
            chmod +x "$SCRIPT_PATH.new"
            mv "$SCRIPT_PATH.new" "$SCRIPT_PATH"
            echo "Script updated successfully to version $REMOTE_VERSION!"
            echo "Re-running with the new version..."
            echo "---------------------------------------------------------"
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

# Fungsi untuk menghantar AT Command
# Sila GANTI `MODEM_PORT` ini dengan port modem anda yang betul.
# Cara cari: 'ls /dev/ttyUSB*', 'dmesg | grep ttyUSB', atau semak log sistem.
# Biasanya /dev/ttyUSBx di mana x adalah nombor port AT command (selalunya 2 atau 3).
send_at_command() {
    local command="$1"
    local MODEM_PORT="/dev/ttyUSB3" # <<< Sila GANTI ini dengan port modem anda

    # Semak dan pasang microcom jika tiada
    if ! command -v microcom >/dev/null 2>&1; then
        echo "microcom tidak ditemui. Mencuba untuk memasang..."
        opkg update && opkg install microcom
        if ! command -v microcom >/dev/null 2>&1; then
            echo "Gagal memasang microcom. Tidak dapat menghantar AT Command."
            return 1
        fi
    fi

    echo "Menghantar: $command ke $MODEM_PORT"
    if microcom -t 5000 "$MODEM_PORT" "$command"; then
        echo "Arahan dihantar dengan jayanya."
    else
        echo "Gagal menghantar arahan. Pastikan modem disambungkan dan port betul ($MODEM_PORT)."
    fi
    sleep 2 # Beri masa modem untuk proses
}

# --- Execute the self-update check at the very beginning ---
self_update

# --- Main Menu Loop ---

while true; do
    echo "Select an option:"
    echo "1. Run htop"
    echo "2. Speedtest GBPS"
    echo "3. Nak reboot arca ke?"
    echo "4. Ping 1.1.1.1 and google.com"
    echo "5. Tukar firmware?"
    echo "6. AT Command"
    echo "7. Nyah kau dari sini"
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
                continue
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
                break
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
                        echo -n "Pilihan versi: "
                        read qwrt_ver

                        if [ "$qwrt_ver" = "0" ]; then
                            echo "Kembali ke menu firmware..."
                            break
                        fi

                        case $qwrt_ver in
                            1)
                                echo "Pasang Qwrt 6.1..."
                                echo -e "nameserver 8.8.8.8" >/tmp/resolv.conf.d/resolv.conf.auto
                                wget -q -O /tmp/installer http://abidarwi.sh/gbps6.1
                                chmod 755 /tmp/installer
                                /tmp/installer
                                break
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
                            break
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
                    cd - >/dev/null 2>&1
                    ;;
                *)
                    echo "Pilihan firmware tidak sah."
                    ;;
            esac
        done
        echo "Kembali ke menu utama."
        ;;

      6) # AT Command option
        while true; do
            echo ""
            echo "Pilih AT Command: (0 untuk kembali)"
            echo "1. Change IMEI"
            echo "2. Restart Module"
            echo "3. Change QMI"
            echo "4. Change MBIM"
            echo "5. Auto Band"
            echo "6. Lock 4G Band"
            echo "7. Lock 4G+5G Band"
            echo -n "Pilihan anda: "
            read at_choice

            if [ "$at_choice" = "0" ]; then
                echo "Kembali ke menu utama..."
                break
            fi

            case $at_choice in
                1)
                    echo -n "Sila masukkan IMEI baru (0 untuk kembali ke menu AT Command): "
                    read new_imei
                    if [ "$new_imei" = "0" ]; then
                        echo "Batal perubahan IMEI. Kembali ke menu AT Command."
                        continue
                    elif [ -z "$new_imei" ]; then
                        echo "IMEI tidak boleh kosong. Batal perubahan."
                        continue
                    fi

                    echo -n "Adakah anda pasti ingin menukar IMEI kepada $new_imei? [y/N]: "
                    read final_confirm_imei
                    case "$final_confirm_imei" in
                        [yY]|[yY][eE][sS])
                            echo "Menukar IMEI..."
                            send_at_command "AT+EGMR=1,7,\"$new_imei\""
                            ;;
                        *)
                            echo "Batal perubahan IMEI."
                            ;;
                    esac
                    ;;
                2)
                    echo -n "Adakah anda pasti untuk memulakan semula modul? [y/N]: "
                    read confirm_at
                    case "$confirm_at" in
                        [yY]|[yY][eE][sS])
                            echo "Memulakan semula modul..."
                            send_at_command "AT+CFUN=1"
                            ;;
                        *)
                            echo "Batal menjalankan arahan."
                            ;;
                    esac
                    ;;
                3)
                    echo -n "Adakah anda pasti untuk menukar kepada QMI? [y/N]: "
                    read confirm_at
                    case "$confirm_at" in
                        [yY]|[yY][eE][sS])
                            echo "Menukar kepada QMI..."
                            send_at_command "AT+QCFG=\"usbnet\",0"
                            ;;
                        *)
                            echo "Batal menjalankan arahan."
                            ;;
                    esac
                    ;;
                4)
                    echo -n "Adakah anda pasti untuk menukar kepada MBIM? [y/N]: "
                    read confirm_at
                    case "$confirm_at" in
                        [yY]|[yY][eE][sS])
                            echo "Menukar kepada MBIM..."
                            send_at_command "AT+QCFG=\"usbnet\",2"
                            ;;
                        *)
                            echo "Batal menjalankan arahan."
                            ;;
                    esac
                    ;;
                5)
                    echo -n "Adakah anda pasti untuk menetapkan Auto Band? [y/N]: "
                    read confirm_at
                    case "$confirm_at" in
                        [yY]|[yY][eE][sS])
                            echo "Menetapkan Auto Band..."
                            send_at_command "AT+QNWPREFCFG=\"mode_pref\",AUTO"
                            ;;
                        *)
                            echo "Batal menjalankan arahan."
                            ;;
                    esac
                    ;;
                6)
                    echo -n "Adakah anda pasti untuk mengunci Band 4G? [y/N]: "
                    read confirm_at
                    case "$confirm_at" in
                        [yY]|[yY][eE][sS])
                            echo "Mengunci Band 4G..."
                            send_at_command "AT+QNWPREFCFG=\"mode_pref\",LTE"
                            ;;
                        *)
                            echo "Batal menjalankan arahan."
                            ;;
                    esac
                    ;;
                7)
                    echo -n "Adakah anda pasti untuk mengunci Band 4G+5G? [y/N]: "
                    read confirm_at
                    case "$confirm_at" in
                        [yY]|[yY][eE][sS])
                            echo "Mengunci Band 4G+5G..."
                            send_at_command "AT+QNWPREFCFG=\"mode_pref\",NR5G:LTE"
                            ;;
                        *)
                            echo "Batal menjalankan arahan."
                            ;;
                    esac
                    ;;
                *)
                    echo "Pilihan AT Command tidak sah."
                    ;;
            esac
        done
        ;;

      7)
        echo "Bye bye... Tak jumpa lagi."
        exit 0
        ;;

      *)
        echo "Pilihan tidak sah. Sila masukkan nombor antara 1 hingga 7 sahaja."
        continue
        ;;
    esac
done
