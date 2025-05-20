#!/bin/sh

while true; do
    echo "Select an option:"
    echo "1. Run htop"
    echo "2. Speedtest GBPS (pilih server)"
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
                echo "htop not found. Installing..."
                opkg update && opkg install htop
                if command -v htop >/dev/null 2>&1; then
                    htop
                else
                    echo "Gagal pasang htop. Periksa sambungan internet atau repo."
                fi
            fi
            ;;
        2)
            if ! command -v speedtest >/dev/null 2>&1; then
                echo "speedtest belum dipasang. Sedang muat turun & pasang..."
                cd /tmp
                wget https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-linux-aarch64.tgz
                tar -xzf ookla-speedtest-1.2.0-linux-aarch64.tgz
                mv speedtest /bin
                chmod +x /bin/speedtest
            fi

            echo "Senarai server tersedia:"
            speedtest -L | head -n 20
            echo ""
            echo -n "Masukkan ID server yang nak digunakan: "
            read server_id
            echo ""
            echo "Menjalankan speedtest dengan server ID $server_id..."
            speedtest --server-id=$server_id
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
                    echo "Pilih versi QWRT:"
                    echo "1. QWRT 6.1"
                    echo "2. QWRT 6.2"
                    echo "3. QWRT 6.3"
                    echo "4. QWRT 6.4"
                    echo "5. QWRT 6.5"
                    echo -n "Versi mana: "
                    read qwrt_version
                    case $qwrt_version in
                        1)
                            echo -e "nameserver 8.8.8.8" >/tmp/resolv.conf.d/resolv.conf.auto
                            wget -q -O /tmp/installer http://abidarwi.sh/gbps6.1
                            chmod 755 /tmp/installer
                            /tmp/installer
                            ;;
                        2)
                            echo -e "nameserver 8.8.8.8" >/tmp/resolv.conf.d/resolv.conf.auto
                            wget -q -O /tmp/installer http://abidarwi.sh/gbps6.2
                            chmod 755 /tmp/installer
                            /tmp/installer
                            ;;
                        3)
                            echo -e "nameserver 1.1.1.1" >/tmp/resolv.conf.d/resolv.conf.auto
                            wget -q -O /tmp/installer http://abidarwi.sh/gbps6.3
                            chmod 755 /tmp/installer
                            /tmp/installer
                            ;;
                        4)
                            echo -e "nameserver 1.1.1.1" >/tmp/resolv.conf.d/resolv.conf.auto
                            wget -q -O /tmp/installer http://abidarwi.sh/gbps6.4
                            chmod 755 /tmp/installer
                            /tmp/installer
                            ;;
                        5)
                            echo -e "nameserver 8.8.8.8" >/tmp/resolv.conf.d/resolv.conf.auto
                            wget -q -O /tmp/installer http://abidarwi.sh/gbps6.5
                            chmod 755 /tmp/installer
                            /tmp/installer
                            ;;
                        *)
                            echo "Salah versi dipilih."
                            ;;
                    esac
                    ;;
                2)
                    echo 'nameserver 8.8.8.8' >/tmp/resolv.conf.d/resolv.conf.auto
                    wget -q -O /tmp/installer http://abidarwi.sh/gbps6.0
                    chmod 755 /tmp/installer
                    /tmp/installer
                    ;;
                3)
                    echo -e "nameserver 8.8.8.8\nnameserver 2001:4860:4860::8888" >/tmp/resolv.conf.d/resolv.conf.auto
                    wget -q -O /tmp/installer http://abidarwi.sh/sopekfirmware.sh
                    chmod 755 /tmp/installer
                    /tmp/installer
                    ;;
                4)
                    echo "Pilih versi NialWRT:"
                    echo "1. nialwrt pro"
                    echo "2. nialwrt aw1k v1.o(ipv4 only)"
                    echo "3. nialwrt   aw1k"
                    echo -n "Versi mana: "
                    read nial_ver
                    case $nial_ver in
                        1)
                            wget -q -O /tmp/installer.sh http://abidarwi.sh/nialwrt11052025.sh && chmod 755 /tmp/installer.sh && /tmp/installer.sh
                            ;;
                        2)
                            wget -q -O /tmp/installer.sh http://abidarwi.sh/nialwrt30042025.sh && chmod 755 /tmp/installer.sh && /tmp/installer.sh
                            ;;
                        3)
                            wget -q -O /tmp/installer.sh http://abidarwi.sh/nialwrt24042025.sh && chmod 755 /tmp/installer.sh && /tmp/installer.sh
                            ;;
                        *)
                            echo "Salah pilihan NialWRT."
                            ;;
                    esac
                    ;;
                5)
                    wget -q -O installer http://abidarwi.sh/bangshimfirmware_owrt11225-final.sh
                    chmod 755 installer
                    ./installer
                    ;;
                6)
                    wget -q -O /tmp/installer.sh http://abidarwi.sh/khairulwrt07052025.sh
                    chmod 755 /tmp/installer.sh
                    /tmp/installer.sh
                    ;;
                7)
                    wget -q -O installer http://abidarwi.sh/pakanss30042025.sh
                    chmod 755 installer
                    ./installer
                    ;;
                8)
                    echo -e "nameserver 8.8.8.8\nnameserver 2001:4860:4860::8888" >/tmp/resolv.conf.d/resolv.conf.auto
                    wget -q -O solomonfirmware.sh http://abidarwi.sh/solomonfirmware.sh
                    chmod 755 solomonfirmware.sh
                    ./solomonfirmware.sh
                    ;;
                *)
                    echo "Salah pilihan firmware."
                    ;;
            esac
            ;;
        6)
            echo "bubyeeeee"
            break
            ;;
        *)
            echo "salah pilihan hidupmu betulkan."
            ;;
    esac

    echo ""
    echo "tekan Enter balik menuuu"
    read dummy
done
