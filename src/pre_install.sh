#!/bin/bash
# Author: CloudS3n https://yangyunsen.com
# Description: Prepare the installation environment

source ./conf/config.sh

# 0: BIOS 1: UEFI
bootMode=0

function checkBootMode() {
    echo "[MODE-CHECK] --------------------"  >> ./log/info.log
    local efiPath="/sys/firmware/efi/efivars"
    if [[ -d $efiPath ]]; then
        bootMode=1
        echo "[ PRE-INSTALL ] Your Boot Mode is UEFI" >> ./log/info.log
    fi
    echo "[ PRE-INSTALL ] Your Boot Mode is BIOS" >> ./log/info.log
}

function checkNetwork() {
    echo "[SET-NET] --------------------"  >> ./log/info.log
    if [[ $netType -eq 0 ]]; then
        echo "[ PRE-INSTALL ] Enable LAN..." >> ./log/info.log
        dhcpcd
    else
        echo "[ PRE-INSTALL ] Enable WIFI..." >> ./log/info.log
        wifi-menu
    fi
    echo "[ PRE-INSTALL ] Connect to www.baidu.com" >> ./log/info.log
    curl -I http://www.baidu.com 1>>./log/info.log 2>>./log/error.log
    curl -Is http://www.baidu.com | head 1 | grep 200
    if [[ $? -eq 0 ]]; then
        echo "[ PRE-INSTALL ] You are online" >> ./log/info.log
    else
        exit 127
    fi
}

function setTime() {
    echo "[SET-TIME] --------------------"  >> ./log/info.log
    echo "[ PRE-INSTALL ] Before set system time:" >> ./log/info.log
    timedatectl status | head -4 | tail -1 >> ./log/info.log
    timedatectl set-timezone Asia/Shanghai
    timedatectl set-ntp true
    echo "[ PRE-INSTALL ] After set system time:" >> ./log/info.log
    timedatectl status | head -4 | tail -1 >> ./log/info.log
}

# https://superuser.com/a/984637
# to create the partitions programatically (rather than manually)
# we're going to simulate the manual input to fdisk
# The sed script strips off all the comments so that we can 
# document what we're doing in-line with the actual commands
# Note that a blank line (commented as "defualt" will send a empty
# line terminated with a newline to take the fdisk default.
function autoPartition() {
    echo "[PARTITION] --------------------"  >> ./log/info.log
    echo "[ PRE-INSTALL ] Automically partitioning ${autoPartitionDevice} ..." >> ./log/info.log
    sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk ${autoPartitionDevice}
    o # clear the in memory partition table
    n # new partition
    p # primary partition
    1 # partition number 1
        # default - start at beginning of disk 
    ${rootPartitionSize} # root partition size
    n # new partition
    p # primary partition
    2 # partion number 2
        # default, start immediately after preceding partition
        # default, home partition size, extend partition to end of disk
    p # print the in-memory partition table
    w # write the partition table
    q # and we're done
    EOF
    echo "[ PRE-INSTALL ] Formating partitions..." >> ./log/info.log
    mkfs.ext4 /dev/sda1
    mkfs.ext4 /dev/sda3
    echo "[ PRE-INSTALL ] Mounting partitions..." >> ./log/info.log
    mount /dev/sda1 /mnt
    mkdir -p /mnt/home
    mount /dev/sda2 /mnt/home
}

function changeMirrorList() {
    echo "[MIRROR-LIST] --------------------"  >> ./log/info.log
    sed -i '1s/^/${mirrorList1}\n/' /etc/pacman.d/mirrorlist
    sed -i '1s/^/${mirrorList2}\n/' /etc/pacman.d/mirrorlist
    head -2 /etc/pacman.d/mirrorlist >> ./log/info.log
}

function doPacstrap() {
    echo "[PACSTRAP] --------------------"  >> ./log/info.log
    pacstrap /mnt base base-devel
    genfstab -U /mnt >> /mnt/etc/fstab
    cat /mnt/etc/fstab >> ./log/info.log
}

function doChroot() {
    echo "[CHROOT] --------------------"  >> ./log/info.log
    arch-chroot /mnt
}

function doInstall() {
    echo "[INSTALL] --------------------"  >> ./log/info.log
    pacman -S vim dialog wpa_supplicant ntfs-3g networkmanager
}

function configSystem() {
    echo "[CONFIG] --------------------"  >> ./log/info.log
    echo "[ PRE-INSTALL ] Setting localtime..." >> ./log/info.log
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    hwclock --systohc
    echo "[ PRE-INSTALL ] Setting locale.gen..." >> ./log/info.log
    mv /etc/locale.gen /etc/locale.gen.bak
    source ./src/locale_gen_template.sh > etc/locale.gen
    locale-gen &>>./log/info.log
    echo "[ PRE-INSTALL ] Setting hostname ${hostName} ..." >> ./log/info.log
    echo ${hostName} > /etc/hostname
    echo "[ PRE-INSTALL ] Setting hosts ..." >> ./log/info.log
    source ./src/hosts_template.sh > etc/hosts
    echo "[ PRE-INSTALL ] Changing root passwd to ${rootPassword} ..." >> ./log/info.log
    echo "root:${rootPassword}" | chpasswd
    echo "[ PRE-INSTALL ] Creating user ${username} with passwod ${password} ..." >> ./log/info.log
    useradd -m -G wheel -s /bin/bash ${username}
    echo "${username}:${password}" | chpasswd
    echo "[ PRE-INSTALL ] Installing grub2..." >> ./log/info.log
    pacman -S intel-ucode grub
    grub-install --target=i386-pc ${grubDevice}
    grub-mkconfig -o /boot/grub/grub.cfg
}

function doPreInstall() {
    checkBootMode
    checkNetwork
    setTime
    autoPartition
    changeMirrorList
    doPacstrap
    doChroot
    doInstall
    configSystem
    echo "[ PRE-INSTALL ] Done" >> ./log/info.log
}
