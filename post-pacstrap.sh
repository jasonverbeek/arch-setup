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

echo -e "127.0.0.1\tlocalhost\r\n" > /etc/hosts
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

echo Enabling DHCPCD
systemctl enable dhcpcd@enp0s3 #TODO: automatically get interface

useradd -m jason # TODO change vor variable in main script
echo "jason ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers #TODO

VM=1
if [ "${VM}" -eq "1" ]; then
    pacman -Syyu --noconfirm virtualbox-guest-utils
fi
cd /home/jason/
sudo -u jason git clone https://aur.archlinux.org/yay.git
cd -
cd /home/jason/yay
yes '' | sudo -u jason makepkg -si
cd -
rm -rf /home/jason/yay

yes '1' | sudo -u jason yay --noconfirm vi-vim-symlink

sudo -u jason mkdir -p /home/jason/.config/qtile
sudo -u jason cp /usr/share/doc/qtile/default_config.py /home/jason/.config/qtile/config.py

chown jason:jason /home/jason/.config/qtile/config.py
systemctl enable lightdm

