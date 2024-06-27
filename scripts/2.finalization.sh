#!/usr/bin/env bash

# Caricamento file env.conf
source ${HOME}/archinstall/configs/env.conf

# Caricamento file setup.conf
source ${CONFIGS_DIR}/setup.conf

# Caricamento file helpers.sh
source ${SCRIPTS_DIR}/helpers.sh

installOpenbox() {
    homePath="/home/${USER}"
    xinitrcFile = "${homePath}/.xinitrc"

    pacman -S openbox xorg-server xorg-xinit xorg-fonts-misc xterm --noconfirm --needed
    checkError "pacman -S openbox xorg-server xorg-xinit xorg-fonts-misc xterm --noconfirm --needed"

    cp "/etc/X11/xinit/xinitrc" "${xinitrcFile}"
    checkError 'cp "/etc/X11/xinit/xinitrc" "${xinitrcFile}"'

    grep -qxF 'exec openbox-session' ${xinitrcFile} || echo 'exec openbox-session' >> ${xinitrcFile}
    checkError "grep -qxF 'exec openbox-session' ${xinitrcFile} || echo 'exec openbox-session' >> ${xinitrcFile}"

    mkdir -p "${homePath}/.config/openbox"
    checkError 'mkdir -p "${homePath}/.config/openbox"'

    cp -a "/etc/xdg/openbox/" "${homePath}/.config/"
    checkError 'cp -a "/etc/xdg/openbox/" "${homePath}/.config/"'
}

setHostname() {
    hostnameFile="/etc/hostname"

    if [ ! f ${hostnameFile} ]; then 
        rm -f ${hostnameFile}
        checkError "rm -f ${hostnameFile}"
    fi

    touch ${hostnameFile}
    checkError "touch ${hostnameFile}"

    echo ${DEVID} >> ${hostnameFile}
}

cleanup() {
    rm -r "${HOME}/ArchInstall"
    checkError 'rm -r "${HOME}/ArchInstall"'
}

prepareUserScripts() {
    scriptsPath="/home/${USER}/startup"
    configFile="${scriptsPath}/env.conf"
    useDocker=true

    if [ ! -d ${scriptsPath} ]; then 
        mkdir "${scriptsPath}"
        checkError 'mkdir "${scriptsPath}"'
    fi

    if [ ! -f ${configFile} ]; then 
        touch "${configFile}"
        checkError 'touch "${configFile}"'
    fi

    if [ "${STACK,,}" != "docker" ]; then useDocker=false; fi

    echo "PROJECT_NAME=${APP,}" >> ${configFile}    
    echo "WORKSPACE_FOLDER=~/workspace/${APP,,}" >> ${configFile}
    if [ "${APP,,}" = "neuron" ]; then echo "TTY_SYMLINK_ALIAS=ttyEUBOX" >> ${configFile}; fi
    echo "USE_DOCKER=${useDocker}" >> ${configFile}

    cp "${SCRIPTS_DIR}/4.app.sh" "${scriptsPath}/"
    checkError 'cp "${SCRIPTS_DIR}/4.app.sh" "${scriptsPath}/"'

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
showHeader "Setup finalization"

#installOpenbox
setHostname

prepareUserScripts

cleanup
umountAndReboot