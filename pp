#!/bin/sh
# Ini adalah skrip 'pp' yang akan dimuat turun ke /usr/bin/pp.
# Ia berfungsi sebagai 'launcher' untuk sentiasa mendapatkan versi terkini dari GitHub
# dan kemudian menjalankan skrip menu utama yang disertakan di bawah.

# URL sebenar skrip ini di GitHub repo
# (Ini adalah URL yang akan dipanggil untuk mendapatkan versi terkini!)
GITHUB_SCRIPT_URL="https://raw.githubusercontent.com/Razifadm/Skripp/main/pp"

# Laluan sementara untuk menyimpan skrip menu yang dimuat turun sebelum dijalankan
TEMP_RUN_SCRIPT="/tmp/pp_menu_latest.sh"

echo "Memuat turun versi terkini menu dari GitHub repo..."
if wget -qO "$TEMP_RUN_SCRIPT" "$GITHUB_SCRIPT_URL"; then
    chmod +x "$TEMP_RUN_SCRIPT"
    echo "Menjalankan menu..."
    # 'exec' akan menggantikan proses shell semasa dengan skrip yang baru dimuat turun.
    # Ini memastikan skrip yang dijalankan adalah versi yang paling baru.
    exec "$TEMP_RUN_SCRIPT" "$@"
else
    echo "Ralat: Tidak dapat memuat turun skrip menu dari $GITHUB_SCRIPT_URL."
    echo "Sila periksa sambungan internet anda atau URL repo."
    
    # Pilihan: Cuba jalankan versi yang telah dimuat turun sebelumnya jika ada (untuk offline/ralat)
    if [ -f "$TEMP_RUN_SCRIPT" ]; then
        echo "Mencuba menjalankan versi menu yang telah dimuat turun sebelum ini..."
        exec "$TEMP_RUN_SCRIPT" "$@"
    else
        echo "Tiada versi menu sebelumnya ditemui. Perintah 'pp' gagal."
    fi
fi

# --- KOD SKRIP MENU UTAMA ANDA BERMULA DI SINI ---
# Letakkan KESELURUHAN kod skrip menu anda yang lengkap di bawah baris ini.
# Ini termasuklah 'while true; do ... case $choice in ...' dan semua fungsi lain.

# CONTOH START KOD MENU (Anda ganti dengan kod penuh anda!)
while true; do
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
            echo -n "Pilih nombor server(start dari no 5) (atau tekan Enter guna default, 0 untuk kembali): "
            read server_num

            if [ "$server_num" = "0" ]; then
                echo "Kembali ke menu utama..."
                continue
            fi

            if [ -z "$server_num" ]; then
                echo "Jalankan speedtest dengan server default..."
                speedtest
            else
                server_id=$(speedtest -L | sed -n "${server_num}p" | awk '{print $1}')
                if [ -z "$server_id" ]; then
                    echo "Pilihan server tidak sah, jalankan speedtest default..."
                    speedtest
                else
                    echo "Jalankan speedtest dengan server ID $server_id..."
                    speedtest -s $server_id
                fi
            fi
        else
            echo "speedtest-cli not found, installing..."
            cd /tmp || exit
            if wget --spider https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-aarch64.tgz 2>/dev/null; then
                wget https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-aarch64.tgz && \
                tar -xzf ookla-speedtest-1.2.0-linux-aarch64.tgz && \
                mv speedtest /bin && chmod +x /bin/speedtest && \
                echo "Installed! Now running speedtest..."
                speedtest
            else
                echo "Tiada sambungan internet atau fail tidak dijumpai. Tak boleh pasang speedtest."
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
                        echo "1. Qwrt 6.5"
                        echo "2. Qwrt 6.4"
                        echo "3. Qwrt 6.3"
                        echo "4. Qwrt 6.2"
                        echo "5. Qwrt 6.1"
                        echo -n "Pilihan versi: "
                        read qwrt_ver

                        if [ "$qwrt_ver" = "0" ]; then
                            echo "Kembali ke menu firmware..."
                            break
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
                            break
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
                    cd /tmp || { echo "Gagal masuk ke /tmp. Batal pemasangan Solomon."; continue; }
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
done

