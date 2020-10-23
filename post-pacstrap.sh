#!/bin/bash

set -e

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
passwd


echo TODO: BOOTLOADER
