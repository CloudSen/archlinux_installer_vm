#!/bin/bash
# Author: CloudS3n https://yangyunsen.com
# Description: Install base system
# 1. Pre-installation
# 2. installation
# 3. configure the system
# 4. reboot

source ./conf/config.sh
source ./src/pre_install.sh

ROOT_UID=0

function checkConfig() {
    if [[ "$UID" -ne "$ROOT_UID"  ]]; then
        echo "[ PRE-INSTALL ] Must be root to run this script!" >> ./log/error.log
        killall tail
        exit 87
    fi
    if [[ -d ./log ]]; then
        rm -f ./log/info.log
        rm -f ./log/error.log
    else
        mkdir ./log
    fi
    if [[ -z ${rootPassword} ]]; then
        echo "[ PRE-INSTALL ] Please specify root password in conf/config.sh" >> ./log/error.log
        exit 127
    fi
    if [[ -z ${username} ]]; then
        echo "[ PRE-INSTALL ] Please specify new username in conf/config.sh" >> ./log/error.log
        exit 127
    fi
    if [[ -z ${password} ]]; then
        echo "[ PRE-INSTALL ] Please specify new password in conf/config.sh" >> ./log/error.log
        exit 127
    fi
}

function doInit() {
    clear
    checkConfig
    doPreInstall
}

doInit
