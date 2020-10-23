#!/bin/bash

ls /sys/firmware/efi/efivars 2>/dev/null
IS_UEFI=$?

timedatectl set-ntp true


if [ "${IS_UEFI}" -eq "2" ]; then
    parted /dev/sda mkpart "Arch_Drive" ext4 0% 100%
    parted /dev/sda set 1 boot on
    mkfs.ext4 /dev/sda1
    mount /dev/sda1 /mnt
else
    parted /dev/sda mkpart "EFI_Partition" fat32 1Mib 261Mib
    parted /dev/sda set 1 esp on
    mkfs.fat -F32 /dev/sda1
    parted /dev/sda mkpart "Arch_Drive" ext4 261Mib 100%
    mkfs.ext4 /dev/sda2
    mount /dev/sda2 /mnt
    mkdir /mnt/efi
    mount /dev/sda1 /mnt/efi
fi


reflector -n 50 > /etc/pacman.d/mirrorlist
pacstrap /mnt base base-devel linux linux-firmware

