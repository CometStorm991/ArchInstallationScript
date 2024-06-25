#!/bin/bash

R_R_FILES_PATH="/root/Files"

DEVICE_NAME=$(cat "$R_R_FILES_PATH/Information/DeviceName.txt")

function main() {
    ln -sf /usr/share/zoneinfo/US/Eastern /etc/localtime
    hwclock --systohc
    systemctl enable systemd-timesyncd.service
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
    locale-gen
    echo "LANG=en_US.UTF-8" > /etc/locale.conf
    echo "$DEVICE_NAME" > /etc/hostname
    systemctl enable NetworkManager.service

    echo "Enter root password."
    while ! passwd
    do
        echo "Enter root password."
    done

    pacman -S grub efibootmgr --noconfirm
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
    grub-mkconfig -o /boot/grub/grub.cfg

    exit 0
}

main "$@"
