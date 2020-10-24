#!/bin/bash

set -e

IS_UEFI=$1

echo Setting localtime
ln -sf /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime

echo Seting hwclock
hwclock --systohc

echo Setting locale
sed -i "s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g" /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf

echo Setting hostname
hostnamectl set-hostname arch

echo -e "127.0.0.1\tlocalhosti\r\n" > /etc/hosts
echo -e "::1\tlocalhost\r\n" >> /etc/hosts
echo -e "127.0.1.1\tarch.localdomain arch" >> /etc/hosts


echo
echo
echo "Setting password for root"
passwd


echo "Installing GRUB bootloader"
if [ "${IS_UEFI}" -eq "2" ]; then
    echo "GRUB for i386-pc"
    grub-install --target=i386-pc /dev/sda
else
    echo "GRUB for EFI"
    grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
fi
grub-mkconfig -o /boot/grub/grub.cfg
