#!/bin/sh

trap "echo; echo 'Keluar script. Bye!'; exit" INT

while true; do
    echo "=================================="
    echo "          MENU ARCA TOOL          "
    echo "=================================="
    echo "1. Run htop"
    echo "2. Speedtest GBPS"
    echo "3. Nak reboot Arca ke?"
    echo "4. Ping 1.1.1.1 dan google.com"
    echo "5. Tukar firmware?"
    echo "6. Nyah kau dari sini"
    echo -n "Janda atau Perawan? Pilih nombor anda: "
    read choice

    case $choice in
        1)
            if command -v htop >/dev/null 2>&1; then
                echo "Periksa kesihatan..."
                htop
            else
                echo "htop tidak dijumpai. Cuba pasang..."
                if ! opkg update; then
                    echo "Tidak dapat update repo. Semak sambungan internet atau tetapan DNS."
                elif ! opkg install htop; then
                    echo "Gagal pasang htop. Mungkin pakej tiada dalam repo."
                else
                    htop
                fi
            fi
            ;;
        2)
            if command -v speedtest >/dev/null 2>&1; then
                echo "Ke bulan duluuu..."
                speedtest
            else
                echo "speedtest-cli tidak dijumpai. Memasang..."
                cd /tmp || exit
                wget https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-aarch64.tgz && \
                tar -xzf ookla-speedtest-1.2.0-linux-aarch64.tgz && \
                mv speedtest /bin && chmod +x /bin/speedtest && \
                echo "Siap dipasang. Menjalankan ujian kelajuan..." && speedtest
            fi
            ;;
        3)
            echo -n "Betul nak reboot Arca? [y/N]: "
            read confirm
            case "$confirm" in
                [yY]|[yY][eE][sS])
                    echo "Rebooting AW1000..."
                    reboot
                    ;;
                *)
                    echo "Batal reboot."
                    ;;
            esac
            ;;
        4)
            echo "Ping ke 1.1.1.1..."
            ping -c 4 1.1.1.1
            echo ""
            echo "Ping ke google.com..."
            ping -c 4 google.com
            ;;
        5)
            echo ""
            echo "Tukar firmware ke mana?"
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

            case $fw_choice in
                1)
                    echo "Pasang Qwrt Abi..."
                    echo 'nameserver 8.8.8.8' >/tmp/resolv.conf.auto && \
                    wget -q -O /tmp/installer http://abidarwi.sh/gbps6.5 && \
                    chmod 755 /tmp/installer && /tmp/installer
                    ;;
                2)
                    echo "Pasang Qwrt Hongkong..."
                    echo 'nameserver 8.8.8.8' >/tmp/resolv.conf.d/resolv.conf.auto && \
                    wget -q -O /tmp/installer http://abidarwi.sh/gbps6.0 && \
                    chmod 755 /tmp/installer && /tmp/installer
                    ;;
                3)
                    echo "Pasang Sopek FW..."
                    echo -e "nameserver 8.8.8.8\nnameserver 2001:4860:4860::8888" >/tmp/resolv.conf.d/resolv.conf.auto && \
                    wget -q -O /tmp/installer http://abidarwi.sh/sopekfirmware.sh && \
                    chmod 755 /tmp/installer && /tmp/installer
                    ;;
                4)
                    echo "Pasang NialWRT..."
                    wget -q -O /tmp/installer.sh http://abidarwi.sh/nialwrt24042025.sh && \
                    chmod 755 /tmp/installer.sh && /tmp/installer.sh
                    ;;
                5)
                    echo "Pasang Shimwrt..."
                    wget -q -O installer http://abidarwi.sh/bangshimfirmware_owrt11225-final.sh && \
                    chmod 755 installer && ./installer
                    ;;
                6)
                    echo "Pasang Khairulwrt..."
                    wget -q -O /tmp/installer.sh http://abidarwi.sh/khairulwrt07052025.sh && \
                    chmod 755 /tmp/installer.sh && /tmp/installer.sh
                    ;;
                7)
                    echo "Pasang Pakawrt..."
                    wget -q -O installer http://abidarwi.sh/pakanss30042025.sh && \
                    chmod 755 installer && ./installer
                    ;;
                8)
                    echo "Pasang Solomon..."
                    echo -e "nameserver 8.8.8.8\nnameserver 2001:4860:4860::8888" >/tmp/resolv.conf.d/resolv.conf.auto; \
                    wget -q -O solomonfirmware.sh http://abidarwi.sh/solomonfirmware.sh; \
                    chmod 755 solomonfirmware.sh; ./solomonfirmware.sh
                    ;;
                *)
                    echo "Pilih betul-betul laa."
                    ;;
            esac
            ;;
        6)
            echo "Bubyeeeee~"
            break
            ;;
        *)
            echo "Salah pilihan hidupmu, betulkan."
            ;;
    esac

    echo ""
    echo "Tekan Enter untuk kembali ke menu..."
    read dummy
done
