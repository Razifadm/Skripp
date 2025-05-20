#!/bin/sh

while true; do
    echo "Select an option:"
    echo "1. Run htop"
    echo "2. Speedtest GBPS"
    echo "3. Nak reboot arca ke?"
    echo "4. Ping 1.1.1.1 and google.com"
    echo "5. Tukar firmware?"
    echo "6. Nyah kau dari sini"
    echo -n "Janda atau Perawan?pilih no: "
    read choice

    case $choice in
        1)
            if command -v htop >/dev/null 2>&1; then
                echo "Periksa kesihatan"
                htop
            else
                echo "htop is not installed. Install it with: opkg install htop"
            fi
            ;;
        2)
            if command -v speedtest >/dev/null 2>&1; then
                echo "Ke bulan duluu"
                speedtest -s 45610
            else
                echo "speedtest-cli not found, installing..."
                cd /tmp
                wget https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-aarch64.tgz && \
                tar -xzf ookla-speedtest-1.2.0-linux-aarch64.tgz && \
                mv speedtest /bin && chmod +x /bin/speedtest && \
                echo "Installed! Now running speedtest..." && speedtest 
            fi
            ;;
        3)
            echo -n "Betul nak reboot Arca? [y/N]: "
            read confirm
            case "$confirm" in
                [yY]|[yY][eE][sS])
                    echo "Rebooting system..."
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
            echo ""
            echo "Tukar firmware ke mana?"
            echo "1. Qwrt Abi"
            echo "2. Qwrt Hongkong"
            echo "3. Sopek FW"
            echo "4. NialWRT"
            echo "5. Shimwrt"
            echo "6. Khairulwrt"
            echo "7. Pakawrt"
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
                *)
                    echo "Pilih bagus2 laa."
                    ;;
            esac
            ;;
        6)
            echo "bubyeeeee"
            break
            ;;
        *)
            echo "salah pilihan hidupmu betulkan."
            continue
            ;;
    esac

    echo ""
    echo "tekan Enter balik menuuu"
    read dummy
done