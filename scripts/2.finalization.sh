#!/usr/bin/env bash

# Caricamento file env.conf
source ${HOME}/archinstall/configs/env.conf

# Caricamento file setup.conf
source ${CONFIGS_DIR}/setup.conf

# Caricamento file helpers.sh
source ${SCRIPTS_DIR}/helpers.sh

installOpenbox() {
    homePath="/home/${USER}"

    pacman -S openbox xorg-server xorg-xinit xorg-fonts-misc xterm --noconfirm --needed
    checkError "pacman -S openbox xorg-server xorg-xinit xorg-fonts-misc xterm --noconfirm --needed"

    cp "/etc/X11/xinit/xinitrc" "${homePath}/.xinitrc"
    checkError "cp \"/etc/X11/xinit/xinitrc\" \"${homePath}/.xinitrc\""

    mkdir -p "${homePath}/.config/openbox"
    checkError "mkdir -p \"${homePath}/.config/openbox\""

    cp -a "/etc/xdg/openbox/" "${homePath}/.config/"
    checkError "cp -a \"/etc/xdg/openbox/\" \"${homePath}/.config/\""
}

setHostname() {
    hostnameFile="/etc/hostname"

    if [ ! f ${hostnameFile} ]; then 
        rm -f ${hostnameFile}
        checkError "rm -f ${hostnameFile}"
    fi

    touch ${hostnameFile}
    checkError "touch ${hostnameFile}"

    echo ${HOST} >> ${hostnameFile}
}

cleanup() {
    rm -r "${HOME}/ArchInstall"
    checkError "rm -r ${HOME}/ArchInstall"
}

prepareUserScripts() {
    scriptsPath="/home/${USER}/startup"
    configFile="${scriptsPath}/env.conf"

    if [ ! -d $scriptsPath ]; then 
        mkdir $scriptsPath
        checkError "mkdir $scriptsPath"
    fi

    if [ ! -f $configFile ]; then 
        touch $configFile
        checkError "touch $configFile"
    fi

    echo "PROJECT_NAME=${}" >> ${configFile}    
    echo "WORKSPACE_FOLDER=~/workspace/${}" >> ${configFile}
    echo "TTY_SYMLINK_ALIAS=${}" >> ${configFile}
    echo "USE_DOCKER=${}" >> ${configFile}

    #TODO: mettere in bash.rc l'esecuzione dello startup
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

installOpenbox
setHostname

prepareUserScripts

cleanup
umountAndReboot