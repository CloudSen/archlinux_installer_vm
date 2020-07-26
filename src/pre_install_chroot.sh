#!/bin/bash
# Author: CloudS3n https://yangyunsen.com
# Description: Prepare the installation environment in chroot

source ../conf/config.sh

function installSoft() {
    echo "[INSTALL] --------------------"  >> ../log/info.log
    echo "[ PRE-INSTALL ] Install core soft..." >> ../log/info.log
    pacman -S dialog wpa_supplicant ntfs-3g networkmanager network-manager-applet
    echo "[ PRE-INSTALL ] Install pop-soft..." >> ../log/info.log
    pacman -S ${dailySoft}
    if [[ "${enableGraphic}" == true ]]; then
    echo "[ PRE-INSTALL ] Install graphic env..." >> ../log/info.log
        pacman -S ${graphicEnvironment}
    fi
    echo "[ PRE-INSTALL ] Install vmware tools..." >> ../log/info.log
    pacman -S ${vmTools}
}

function configSystem() {
    echo "[CONFIG-SYSTEM] --------------------"  >> ../log/info.log
    echo "[ PRE-INSTALL ] Setting localtime..." >> ../log/info.log
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    hwclock --systohc

    echo "[ PRE-INSTALL ] Setting locale.gen..." >> ../log/info.log
    mv /etc/locale.gen /etc/locale.gen.bak
    source ./template/locale_gen_template.sh > etc/locale.gen
    locale-gen &>>../log/info.log

    echo "[ PRE-INSTALL ] Setting hostname ${hostName} ..." >> ../log/info.log
    echo ${hostName} > /etc/hostname

    echo "[ PRE-INSTALL ] Setting hosts ..." >> ../log/info.log
    source ./template/hosts_template.sh > etc/hosts
}

function createUser() {
    echo "[CONFIG-USER] --------------------"  >> ../log/info.log
    if [[ -z ${rootPassword} ]]; then
        echo "[ PRE-INSTALL ] Please specify root password in conf/config.sh" >> ../log/error.log
        exit 127
    fi
    echo "[ PRE-INSTALL ] Changing root passwd to ${rootPassword} ..." >> ../log/info.log
    echo "root:${rootPassword}" | chpasswd
    if [[ -z ${username} ]]; then
        echo "[ PRE-INSTALL ] Please specify new username in conf/config.sh" >> ../log/error.log
        exit 127
    fi
    if [[ -z ${password} ]]; then
        echo "[ PRE-INSTALL ] Please specify new password in conf/config.sh" >> ../log/error.log
        exit 127
    fi
    echo "[ PRE-INSTALL ] Creating user ${username} with passwod ${password} ..." >> ../log/info.log
    useradd -m -G wheel -s /bin/bash ${username}
    echo "${username}:${password}" | chpasswd
}

function configGrub() {
    echo "[CONFIG-GRUB] --------------------"  >> ../log/info.log
    grub-install --target=i386-pc ${grubDevice}
    grub-mkconfig -o /boot/grub/grub.cfg
}

function enableService() {
    echo "[CONFIG-SYSTEMD] --------------------"  >> ../log/info.log

    echo "[ PRE-INSTALL ] Enable dhcpcd" >> ../log/info.log
    systemctl enable dhcpcd

    if [[ "${enableGraphic}" == true ]]; then
        echo "[ PRE-INSTALL ] Enable sddm" >> ../log/info.log
        systemctl enable sddm
    fi

    echo "[ PRE-INSTALL ] Enable NetworkManager" >> ../log/info.log
    systemctl disable netctl
    systemctl enable NetworkManager

    echo "[ PRE-INSTALL ] Enable vmtools" >> ../log/info.log
    cat /proc/version > /etc/arch-release
    systemctl  enable vmtoolsd
    systemctl  start vmtoolsd 
    systemctl  enable vmware-vmblock-fuse.service
    systemctl  start vmware-vmblock-fuse.service
}

fucntion installDone() {
    echo "[DONE] --------------------"  >> ../log/info.log
    screenfetch &>> ../log/info.log
    systemctl status dhcpcd.service &>> ../log/info.log
    if [[ "${enableGraphic}" == true ]]; then
        systemctl status sddm.service &>> ../log/info.log
    fi
    systemctl status NetworkManager.service &>> ../log/info.log
    systemctl status vmtoolsd.service &>> ../log/info.log
    systemctl status vmware-vmblock-fuse.service &>> ../log/info.log
    echo echo "[PRE-INSTALL] Done"  >> ../log/info.log
    echo echo "[PRE-INSTALL] You can check installation log in /archlinux_installer_vm/log/"  >> ../log/info.log
    echo echo "[PRE-INSTALL] If everything is ok, then exit chroot and reboot system"  >> ../log/info.log
    clear
    more ../log/info.log
}

function doInstall() {
    installSoft
    configSystem
    createUser
    configGrub
    enableService
    installDone
}

doInstall