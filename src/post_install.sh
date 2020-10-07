#!/bin/bash
# Author: CloudS3n https://yangyunsen.com
# Description: post-installation daily soft

infoPath="./log/info.log"

function enableNetwork() {
    echo "[ENABLE-NETWORK] --------------------"  >> ${infoPath}
    systemctl --now enable NetworkManager.service && systemctl start NetworkManager.service
    systemctl status NetworkManager.service &>> ${infoPath}
}

function installSoft() {
    echo "[INSTALL-DAILY-SOFT] --------------------"  >> ${infoPath}
    echo "[ POST-INSTALL ] Install pop-soft..." >> ${infoPath}
    pacman -S ${dailySoft}
    if [[ "${enableGraphic}" == true ]]; then
    echo "[ POST-INSTALL ] Install graphic env..." >> ${infoPath}
        pacman -S ${graphicEnvironment}
    fi
    echo "[ POST-INSTALL ] Install vmware tools..." >> ${infoPath}
    pacman -S ${vmTools}
}

function enableService() {
    echo "[CONFIG-SYSTEMD] --------------------"  >> ${infoPath}

    echo "[ POST-INSTALL ] Enable dhcpcd" >> ${infoPath}
    systemctl enable dhcpcd

    if [[ "${enableGraphic}" == true ]]; then
        echo "[ POST-INSTALL ] Enable sddm" >> ${infoPath}
        systemctl enable sddm
    fi

    echo "[ POST-INSTALL ] Enable NetworkManager" >> ${infoPath}
    systemctl disable netctl
    systemctl enable NetworkManager

    echo "[ POST-INSTALL ] Enable vmtools" >> ${infoPath}
    cat /proc/version > /etc/arch-release
    systemctl  enable vmtoolsd
    systemctl  start vmtoolsd 
    systemctl  enable vmware-vmblock-fuse.service
    systemctl  start vmware-vmblock-fuse.service
}

function installDone() {
    echo "[POST-INSTALL-DONE] --------------------"  >> ${infoPath}
    screenfetch &>> ${infoPath}
    date
    systemctl status dhcpcd.service &>> ${infoPath}
    if [[ "${enableGraphic}" == true ]]; then
        systemctl status sddm.service &>> ${infoPath}
    fi
    systemctl status NetworkManager.service &>> ${infoPath}
    systemctl status vmtoolsd.service &>> ${infoPath}
    systemctl status vmware-vmblock-fuse.service &>> ${infoPath}
    echo "[POST-INSTALL] Done"  >> ${infoPath}
    echo "[POST-INSTALL] You can check installation log in /archlinux_installer_vm/log/"  >> ${infoPath}
    echo "[POST-INSTALL] Enjoy your new system! ;)"  >> ${infoPath}
    clear
    more ${infoPath}
}


function doPostInstall() {
    enableNetwork
    installSoft
    enableService
    installDone
}