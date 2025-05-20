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
            if ! command -v speedtest >/dev/null 2>&1; then
                echo "speedtest belum dipasang. Sedang muat turun & pasang..."
                cd /tmp || { echo "Gagal tukar direktori /tmp"; exit 1; }
                wget https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-aarch64.tgz -O ookla-speedtest.tgz
                if [ $? -ne 0 ]; then
                    echo "Gagal muat turun speedtest. Sila periksa sambungan internet anda."
                    continue
                fi
                tar -xzf ookla-speedtest.tgz
                mv speedtest /bin/
                chmod +x /bin/speedtest
            fi

            echo "Senarai server speedtest:"
            speedtest -L | nl -w4 -s". "

            echo -n "Pilih nombor server (atau tekan Enter guna default): "
            read server_num

            if [ -z "$server_num" ]; then
                echo "Jalankan speedtest dengan server default..."
                speedtest
            else
                server_id=$(speedtest -L | sed -n "${server_num}p" | awk '{print $1}')
                if [ -z "$server_id" ]; then
                    echo "Pilihan server tidak sah, jalankan default..."
                    speedtest
                else
                    echo "Jalankan speedtest dengan server ID $server_id..."
                    speedtest -s $server_id
                fi
            fi
            ;;

        3)
            echo -n "Betul nak reboot Arca? [y/N]: "
            read confirm
            case "$confirm" in
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
                    echo "Pilih versi Qwrt AbiDarwish:"
                    echo "1. Qwrt 6.5"
                    echo "2. Qwrt 6.4"
                    echo "3. Qwrt 6.3"
                    echo "4. Qwrt 6.2"
                    echo "5. Qwrt 6.1"
                    echo -n "Pilih no: "
                    read qwrt_ver
                    case $qwrt_ver in
                        1)
                            echo "Pasang Qwrt 6.5..."
                            echo -e "nameserver 1.1.1.1" >/tmp/resolv.conf.d/resolv.conf.auto
                            wget -q -O /tmp/installer http://abidarwi.sh/gbps6.5
                            chmod 755 /tmp/installer && /tmp/installer
                            ;;
                        2)
                            echo "Pasang Qwrt 6.4..."
                            echo -e "nameserver 1.1.1.1" >/tmp/resolv.conf.d/resolv.conf.auto
                            wget -q -O /tmp/installer http://abidarwi.sh/gbps6.4
                            chmod 755 /tmp/installer && /tmp/installer
                            ;;
                        3)
                            echo "Pasang Qwrt 6.3..."
                            echo -e "nameserver 1.1.1.1" >/tmp/resolv.conf.d/resolv.conf.auto
                            wget -q -O /tmp/installer http://abidarwi.sh/gbps6.3
                            chmod 755 /tmp/installer && /tmp/installer
                            ;;
                        4)
                            echo "Pasang Qwrt 6.2..."
                            echo -e "nameserver 8.8.8.8" >/tmp/resolv.conf.d/resolv.conf.auto
                            wget -q -O /tmp/installer http://abidarwi.sh/gbps6.2
                            chmod 755 /tmp/installer && /tmp/installer
                            ;;
                        5)
                            echo "Pasang Qwrt 6.1..."
                            echo -e "nameserver 8.8.8.8" >/tmp/resolv.conf.d/resolv.conf.auto
                            wget -q -O /tmp/installer http://abidarwi.sh/gbps6.1
                            chmod 755 /tmp/installer && /tmp/installer
                            ;;
                        *)
                            echo "Pilihan versi tidak sah."
                            ;;
                    esac
                    ;;

                2)
                    echo "Pasang Qwrt Hongkong..."
                    echo 'nameserver 8.8.8.8' >/tmp/resolv.conf.d/resolv.conf.auto
                    wget -q -O /tmp/installer http://abidarwi.sh/gbps6.0
                    chmod 755 /tmp/installer && /tmp/installer
                    ;;

                3)
                    echo "Pasang Sopek FW..."
                    echo -e "nameserver 8.8.8.8\nnameserver 2001:4860:4860::8888" >/tmp/resolv.conf.d/resolv.conf.auto
                    wget -q -O /tmp/installer http://abidarwi.sh/sopekfirmware.sh
                    chmod 755 /tmp/installer && /tmp/installer
                    ;;

                4)
                    echo "Pilih versi NialWRT:"
                    echo "1. nialwrt pro"
                    echo "2. nialwrt aw1k v1.0 (ipv4 only)"
                    echo "3. nialwrt aw1k"
                    echo -n "Pilih no: "
                    read nial_choice
                    case $nial_choice in
                        1)
                            wget -q -O /tmp/installer.sh http://abidarwi.sh/nialwrt11052025.sh
                            chmod 755 /tmp/installer.sh && /tmp/installer.sh
                            ;;
                        2)
                            wget -q -O /tmp/installer.sh http://abidarwi.sh/nialwrt30042025.sh
                            chmod 755 /tmp/installer.sh && /tmp/installer.sh
                            ;;
                        3)
                            wget -q -O /tmp/installer.sh http://abidarwi.sh/nialwrt24042025.sh
                            chmod 755 /tmp/installer.sh && /tmp/installer.sh
                            ;;
                        *)
                            echo "Pilihan versi NialWRT tidak sah."
                            ;;
                    esac
                    ;;

                5)
                    echo "Pasang Shimwrt..."
                    wget -q -O installer http://abidarwi.sh/bangshimfirmware_owrt11225-final.sh
                    chmod 755 installer && ./installer
                    ;;

                6)
                    echo "Pasang Khairulwrt..."
                    wget -q -O /tmp/installer.sh http://abidarwi.sh/khairulwrt07052025.sh
                    chmod 755 /tmp/installer.sh && /tmp/installer.sh
                    ;;

                7)
                    echo "Pasang Pakawrt..."
                    wget -q -O installer http://abidarwi.sh/pakanss30042025.sh
                    chmod 755 installer && ./installer
                    ;;

                8)
                    echo "Pasang Solomon..."
                    echo -e "nameserver 8.8.8.8\nnameserver 2001:4860:4860::8888" >/tmp/resolv.conf.d/resolv.conf.auto
                    wget -q -O solomonfirmware.sh http://abidarwi.sh/solomonfirmware.sh
                    chmod 755 solomonfirmware.sh && ./solomonfirmware.sh
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
