#!/bin/bash

set -e

echo Setting NTP
timedatectl set-ntp true

echo Checking EFI
ls /sys/firmware/efi/efivars &>/dev/null
IS_UEFI=$?



if [ "${IS_UEFI}" -eq "2" ]; then
    echo Setting up for i386
    echo Creating root partition
    parted -s /dev/sda mkpart "Arch_Drive" ext4 0% 100% 1> /dev/null
    parted -s /dev/sda set 1 boot on 1> /dev/null
    mkfs.ext4 /dev/sda1 1> /dev/null
    echo Mounting root partition
    mount /dev/sda1 /mnt
else
    echo Setting up for EFI
    echo Creating EFI partition
    parted -s /dev/sda mkpart primary fat32 1Mib 261Mib 1> /dev/null
    parted -s /dev/sda set 1 esp on 1> /dev/null
    mkfs.fat -F32 /dev/sda1 1> /dev/null
    echo Creating root partition
    parted -s /dev/sda mkpart primary ext4 261Mib 100% 1> /dev/null
    mkfs.ext4 /dev/sda2 1> /dev/null
    echo Mounting root partition
    mount /dev/sda2 /mnt
    echo Mounting EFI partition
    mkdir /mnt/efi
    mount /dev/sda1 /mnt/efi
fi


echo Pacstrapping system
reflector -n 50 > /etc/pacman.d/mirrorlist
pacstrap /mnt base base-devel linux linux-firmware 1> /dev/null

echo Done
