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

clear
if [[ -d ./log ]]; then
    rm -f ./log/info.log
    rm -f ./log/error.log
else
    mkdir ./log
fi
doPreInstall
