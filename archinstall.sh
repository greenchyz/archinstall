#!/bin/bash

echo -e "\e[92mInstalling prereq packages\e[0m"
pacman -Qi dosfstools arch-install-scripts dhcpcd git grub efibootmgr iw wpa_supplicant dialog
#if [[ $? -eq 0 ]]
#then
#	echo -e "\e[92mPackages installed proceeding\e[0m"
#else	
#	echo "\e[91mPackages not installed, installing\e[0m"
#	pacman -S dosfstools
#fi
function pause(){
	read -p "$*"
}

if [[ $EUID -ne 0 ]]; then
	echo "Need to run as r00t"
	exit 1
fi

mkdir -v -p /mnt/arch
mkdir -v /mnt/arch/boot

hoast=arch
boot=/dev/sda1
bootinstall=/mnt/arch/boot
rootdisk=/dev/sda2
rootinstall=/mnt/arch

echo "Format Drives using disk tool:" 
echo "make sure to use appropriate boot ie:" 
echo "500MB EFI System or 10MB BIOS boot"

pause "Press enter once complete..."

#read boot "Enter EFI/BIOS Boot disk ie: /dev/sda1"
echo "Formating boot partition"
mkfs.fat -F32 $boot
echo "Mounting boot partition"
mount $boot /mnt/arch/boot

#read rootdisk "Enter root disk ie: /dev/sda2"
echo "Formatting root Partition"
mkfs.ext4 $rootdisk
echo "Mounting root Partition"
mount $rootdisk /mnt/arch
echo "Done"
echo "##############################################"
echo "installing main system"
pacstrap $rootinstall linux linux-firmware base base-devel vim
echo "Finished install... Now generating fstab"
genfstab -U $rootinstall > $rootinstall/etc/fstab
cat $rootinstall/etc/fstab
pause "Proceeding to chroot into new system. Enter to proceed"
arch-chroot $rootinstall
echo "setting up locales and clocks"
ln -sf /usr/share/zoneinfo/Australia/Sydney /etc/localtime
hwclock --systohc
echo en_US.UTF-8 UTF-8 > /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
read hoast "Enter a hostname"
echo $hoast > /etc/hostname
ln -s /dev/null /etc/udev/rules.d/80-net-setup-link.rules
echo "Installing grub bootloader"
#make option for bios or uefi
grub-install target=x86_64-efi --efi-directory $bootinstall --boot-directory $bootinstall
grub-mkconfig -o $bootinstall/grub/grub.cfg






