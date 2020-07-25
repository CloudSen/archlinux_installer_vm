#!/bin/bash
# Author: CloudS3n https://yangyunsen.com
# Description: Just run arch linux installer
# 1. Pre-installation
# 2. installation
# 3. configure the system
# 4. reboot
# 5. post-installation

source ./conf/config.sh
source ./src/pre_install.sh

function checkConfig() {
    if [[ -d ./log ]]; then
        rm -f ./log/info.log
        rm -f ./log/error.log
    else
        mkdir ./log
    fi
    if [[ -z ${rootPassword} ]]; then
        echo "[ PRE-INSTALL ] Please specify root password in conf/config.sh"
        exit 127
    fi
    if [[ -z ${username} ]]; then
        echo "[ PRE-INSTALL ] Please specify new username in conf/config.sh"
        exit 127
    fi
    if [[ -z ${password} ]]; then
        echo "[ PRE-INSTALL ] Please specify new password in conf/config.sh"
        exit 127
    fi
}

function doInstall() {
    clear
    checkConfig
    doPreInstall
}

doInstall
