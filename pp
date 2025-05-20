#!/bin/sh

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
                                wget -q -O /tmp
