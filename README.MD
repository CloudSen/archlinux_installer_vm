# ARCH LINUX INSTALLER FOR VIRTUAL MACHINE

## CAUTION
This script is for:
- Version: Arch Linux 2020.07.01 or later
- Container: VMware or VirtualBox (Not yet tested on hardware)
- Boot Mode: BIOS&UEFI (UEFI is not supported yet)
- Network Status: Online

## HOW TO USE

Load arch linux live ISO, then [download release file](https://github.com/CloudSen/archlinux_installer_vm/releases):  

```
curl -sL https://github.com/CloudSen/archlinux_installer_vm/archive/<release-version>.tar.gz -o <release-version>.tar.gz
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
find . -name "*.sh" -execdir chmod +x {} +
```

Check and modify configuraion file:  

```
vim conf/config.sh
```

Run init shell:  

```
./init.sh
```

After reboot run install shell:

```
cd /archlinux_installer_vm
./install.sh
```

Check log files: `log/info.log` and `log/error.log`

## CONFIGURATION FILE

You must specify:  

- new username
- new user password
- root password
- grub install device

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

# What u want to install, separated by space.
enableGraphic=true
coreSoft="vim dialog wpa_supplicant ntfs-3g networkmanager network-manager-applet screenfetch intel-ucode grub"
dailySoft="git"
graphicEnvironment="xorg plasma kde-applications sddm"
vmTools="gtkmm3 open-vm-tools xf86-input-vmmouse xf86-video-vmware"
```

## WHAT WILL BE INSTALLED

Pre-install:  

- Arch Linux: base base-devel linux linux-firmware
- vim
- dialog
- wpa_supplicant
- ntfs-3g
- networkmanager
- network-manager-applet
- screenfetch
- intel-ucode
- grub

Post-install:  

- The soft list specified in config.sh