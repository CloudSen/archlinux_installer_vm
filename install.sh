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

clean
doPreInstall
