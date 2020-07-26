#!/bin/bash
# Author: CloudS3n https://yangyunsen.com
# Description: Install daily soft

source ./conf/config.sh
source ./src/post_install.sh

ROOT_UID=0

function checkConfig() {
    if [[ "$UID" -ne "$ROOT_UID"  ]]; then
        echo "[ POST-INSTALL ] Must be root to run this script!" >> ./log/error.log
        killall tail
        exit 87
    fi
}

function doInstall() {
    clear
    checkConfig
    doPostInstall
}

doInstall