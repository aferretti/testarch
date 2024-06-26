#!/usr/bin/env bash

# Caricamento file env.conf
source ${HOME}/archinstall/configs/env.conf

# Caricamento file setup.conf
source $CONFIGS_DIR/setup.conf

# Caricamento file helpers.sh
source $SCRIPTS_DIR/helpers.sh

installOpenbox() {
    pacman -S openbox xorg-server xorg-xinit xorg-fonts-misc xterm --noconfirm --needed

    
}

cleanup() {
    rm -r ${HOME}/ArchInstall
    checkError "rm -r ${HOME}/ArchInstall"
}

umountAndReboot() {
    exit

    umount /mnt/boot
    umount /mnt

    reboot now
}

# 
clear
showHeader "finalization"

cleanup
umountAndReboot