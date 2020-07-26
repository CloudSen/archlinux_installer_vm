#!/bin/bash
# Author: CloudS3n https://yangyunsen.com
# Description: Prepare the installation environment in chroot

source /archlinux_installer_vm/conf/config.sh
infoPath="/archlinux_installer_vm/log/info.log"
errorPath="/archlinux_installer_vm/log/error.log"
templatePath="/archlinux_installer_vm/src/template/"

function installSoft() {
    echo "[INSTALL-CORE-SOFT] --------------------"  >> ${infoPath}
    echo "[ PRE-INSTALL ] Install core soft..." >> ${infoPath}
    yes | pacman -S ${coreSoft}
}

function configSystem() {
    echo "[CONFIG-SYSTEM] --------------------"  >> ${infoPath}
    echo "[ PRE-INSTALL ] Setting localtime..." >> ${infoPath}
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    hwclock --systohc

    echo "[ PRE-INSTALL ] Setting locale.gen..." >> ${infoPath}
    mv /etc/locale.gen /etc/locale.gen.bak
    source .${templatePath}/locale_gen_template.sh > etc/locale.gen
    locale-gen &>>${infoPath}
    echo "LANG=\"en_US.UTF-8\"" >> /etc/locale.conf

    echo "[ PRE-INSTALL ] Setting hostname ${hostName} ..." >> ${infoPath}
    echo ${hostName} > /etc/hostname
    cat /etc/hostname >> ${infoPath}

    echo "[ PRE-INSTALL ] Setting hosts ..." >> ${infoPath}
    source ${templatePath}/hosts_template.sh > etc/hosts
    cat /etc/hosts >> ${infoPath}
}

function createUser() {
    echo "[CONFIG-USER] --------------------"  >> ${infoPath}
    if [[ -z ${rootPassword} ]]; then
        echo "[ PRE-INSTALL ] Please specify root password in conf/config.sh" >> ../log/error.log
        exit 127
    fi
    echo "[ PRE-INSTALL ] Changing root passwd to ${rootPassword} ..." >> ${infoPath}
    echo "root:${rootPassword}" | chpasswd 2>${errorPath}
    if [[ -z ${username} ]]; then
        echo "[ PRE-INSTALL ] Please specify new username in conf/config.sh" >> ../log/error.log
        exit 127
    fi
    if [[ -z ${password} ]]; then
        echo "[ PRE-INSTALL ] Please specify new password in conf/config.sh" >> ../log/error.log
        exit 127
    fi
    echo "[ PRE-INSTALL ] Creating user ${username} with passwod ${password} ..." >> ${infoPath}
    useradd -m -G wheel -s /bin/bash ${username} 2>${errorPath}
    echo "${username}:${password}" | chpasswd 2>${errorPath}
    echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
}

function configGrub() {
    echo "[CONFIG-GRUB] --------------------"  >> ${infoPath}
    grub-install --target=i386-pc ${grubDevice} &>> ${infoPath}
    grub-mkconfig -o /boot/grub/grub.cfg &>> ${infoPath}
}

function installDone() {
    echo "[PRE-INSTALL-DONE] --------------------"  >> ${infoPath}
    screenfetch &>> ${infoPath}
    echo "[PRE-INSTALL] Done"  >> ${infoPath}
    echo "[PRE-INSTALL] You can check installation log in /archlinux_installer_vm/log/"  >> ${infoPath}
    echo "[PRE-INSTALL] If everything is ok, then exit chroot and reboot system, and manually run install.sh"  >> ${infoPath}
    clear
    more ${infoPath}
}

function doInstall() {
    installSoft
    configSystem
    createUser
    configGrub
    installDone
}

doInstall