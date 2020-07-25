# ARCH LINUX INSTALLER FOR VIRTUAL MACHINE

## CAUTION
This script is for:
- System: Arch Linux
- Container: VMware or VirtualBox
- Boot Mode: BIOS&UEFI (auto check)
- Network Status: Online

## HOW TO USE

Load arch linux ISO, then [download release file](https://github.com/CloudSen/archlinux_installer_vm/releases):  

```
curl -sL https://github.com/CloudSen/archlinux_installer_vm/archive/<release-version>.tar.gz
```
Decompression `<release-version>.tar.gz`:  

```
tar zxf <path to .tar.gz>
```

Move to shell directory:  

```
cd <path to shell>
```

Give the script permission to execute:  

```
find . -name "*.sh" -exedir chmod +x {} +
```

Check and modify configuraion file:  

```
vim conf/config.sh
```

Run shell:  

```
./install.sh
```

Check log files: `log/info.log` and `log/error.log`

## CONFIGURATION FILE

```
# 0:LAN 1:WIFI
netType=0

# Host name, /etc/hostname
hostName="GLaDOS"

# User info
## new username
username=""
## new user password
password=""
## root password
rootPassword=""

# Where to install grub
grubDevice="/dev/sda"

# Automically Partition
# Defalut partition:
# /        20G
# /home    Remaining capacity
## Whether partition disk automatically
enableAutoPartition=true
## Where to install arch, only work when enableAutoPartition is true
autoPartitionDevice="/dev/sda"
## Partition size
homePartitionSize="+10G"
rootPartitionSize="+20G"

# Mirror List
# By default, aliyun and tuna is preferred
## Whether modify mirror list
enableChangeMirrorList=true
mirrorList1="Server = http:\/\/mirrors.tuna.tsinghua.edu.cn\/archlinux\/$repo\/os\/$arch"
mirrorList2="Server = http:\/\/mirrors.aliyun.com\/archlinux\/$repo\/os\/$arch"
```

## WHAT WILL BE INSTALLED

Pre-install:  

- Arch Linux: base base-devel
- vim
- dialog
- wpa_supplicant
- ntfs-3g
- networkmanager
- intel-ucode
- grub