#!/bin/bash
# Author: CloudS3n https://yangyunsen.com
# Description: Configuraion file

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