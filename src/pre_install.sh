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
    curl -Is http://www.baidu.com | head -1 | grep 200
    if [[ $? -eq 0 ]]; then
        echo "[ PRE-INSTALL ] You are online" >> ./log/info.log
    else
        echo "[ PRE-INSTALL ] You are offline, please check your internet" >> ./log/error.log
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
    echo "[ PRE-INSTALL ] Automically partitioning ${autoPartitionDevice}..." >> ./log/info.log
    echo "[ PRE-INSTALL ] rootPartitionSize = ${rootPartitionSize}..." >> ./log/info.log
    sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' <<- EOF | fdisk ${autoPartitionDevice}
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
    w # write the partition table and exit
EOF
    echo "[ PRE-INSTALL ] Formating partitions..." >> ./log/info.log
    mkfs.ext4 /dev/sda1 &>> ./log/info.log
    mkfs.ext4 /dev/sda2 &>> ./log/info.log
    echo "[ PRE-INSTALL ] Mounting partitions..." >> ./log/info.log
    mount /dev/sda1 /mnt
    mkdir -p /mnt/home
    mount /dev/sda2 /mnt/home
}

function changeMirrorList() {
    echo "[MIRROR-LIST] --------------------"  >> ./log/info.log
    local success=127
    pacman -Syy
    local updatePid=$!
    wait $updatePid
    if [[ -f /etc/pacman.d/mirrorlist.bak ]]; then
        cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
    fi
    while [[ ${success} -ne 0 ]]; do
        echo "[ PRE-INSTALL ] Sort mirror list..." >> ./log/error.log
        reflector --verbose --country China --sort rate --save /etc/pacman.d/mirrorlist 2>>./log/error.log 1>>./log/info.log
        success=$?
    done
    head -30 /etc/pacman.d/mirrorlist >> ./log/info.log
}

function doPacstrap() {
    echo "[PACSTRAP] --------------------"  >> ./log/info.log
    pacstrap /mnt base base-devel linux linux-firmware
    genfstab -U /mnt >> /mnt/etc/fstab
    cat /mnt/etc/fstab >> ./log/info.log
}

function copySecondScriptToChroot() {
    local path="/mnt/archlinux_installer_vm"
    echo "[COPY-SCRIPT] --------------------"  >> ./log/info.log
    echo "[ PRE-INSTALL ] Copy shell to ${path}" >> ./log/info.log
    mkdir -p ${path}
    cp -r . ${path}
    find ${path} -name "*.sh" -execdir chmod +x {} +
}

function doChroot() {
    echo "[CHROOT] --------------------"  >> ./log/info.log
    arch-chroot /mnt ./archlinux_installer_vm/src/pre_install_chroot.sh
}

function doPreInstall() {
    checkBootMode
    checkNetwork
    setTime
    if [[ "${enableAutoPartition}" == true ]]; then
        autoPartition
    fi
    changeMirrorList
    doPacstrap
    copySecondScriptToChroot
    doChroot
    echo "[ PRE-INSTALL ] Done" >> ./log/info.log
}
