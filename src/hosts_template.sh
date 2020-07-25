#!/bin/bash
# Author: CloudS3n https://yangyunsen.com
# Description: For Create /etc/hosts file

source ./conf/config.sh

cat << EOF
127.0.0.1 localhost
::1       localhost
127.0.0.1 ${hostName}.localdomain ${hostName}
EOF