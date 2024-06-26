#!/usr/bin/env bash

# Caricamento file setup.conf
source $CONFIGS_DIR/setup.conf

# Caricamento file helpers.sh
source $SCRIPTS_DIR/helpers.sh

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

#cleanup
#umountAndReboot