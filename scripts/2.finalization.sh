#!/usr/bin/env bash

# Caricamento file env.conf
source ${HOME}/archinstall/configs/env.conf

# Caricamento file setup.conf
source ${CONFIGS_DIR}/setup.conf

# Caricamento file helpers.sh
source ${SCRIPTS_DIR}/helpers.sh

installOpenbox() {
    homePath="/home/${USERNAME}"
    xinitrcFile="${homePath}/.xinitrc"

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

    if [ -f ${hostnameFile} ]; then 
        rm -f ${hostnameFile}
        checkError "rm -f ${hostnameFile}"
    fi

    touch ${hostnameFile}
    checkError "touch ${hostnameFile}"

    echo ${DEVID} >> ${hostnameFile}
}

prepareUserScripts() {
    scriptsPath="/home/${USERNAME}/startup"
    configFile="${scriptsPath}/env.conf"
    useDocker=true
    bashrcFile="/home/${USERNAME}/.bashrc"

    if [ ! -d ${scriptsPath} ]; then 
        mkdir "${scriptsPath}"
        checkError 'mkdir "${scriptsPath}"'

        chown ${USERNAME} ${scriptsPath}
        checkError "chown ${USERNAME} ${scriptsPath}"
    fi

    if [ ! -f ${configFile} ]; then 
        touch "${configFile}"
        checkError 'touch "${configFile}"'
    fi

    chown ${USERNAME} ${configFile}
    checkError "chown ${USERNAME} ${configFile}"

    chmod 755 ${configFile}
    checkError "chmod 755 ${configFile}"

    if [ "${STACK,,}" != "docker" ]; then useDocker=false; fi

    echo "PASSWORD=${PASSWD,}" >> ${configFile}
    echo "IP=${DEVIP}" >> ${configFile}
    echo "GTW=${DEVGTW}" >> ${configFile}
    echo "PROJECT_NAME=${APP,}" >> ${configFile}
    echo "WORKSPACE_FOLDER=~/workspace/${APP,,}" >> ${configFile}
    if [ "${APP,,}" = "neuron" ]; then echo "TTY_SYMLINK_ALIAS=ttyEUBOX" >> ${configFile}; fi
    echo "USE_DOCKER=${useDocker}" >> ${configFile}

    if [ -f ${scriptsPath}/3.app.sh ]; then
        rm ${scriptsPath}/3.app.sh
        checkError "rm ${scriptsPath}/3.app.sh"
    fi

    cp ${SCRIPTS_DIR}/3.app.sh ${scriptsPath}/
    checkError 'cp ${SCRIPTS_DIR}/3.app.sh ${scriptsPath}/'

    chown ${USERNAME} ${scriptsPath}/3.app.sh
    checkError "chown ${USERNAME} ${scriptsPath}/3.app.sh"

    chmod 755 ${scriptsPath}/3.app.sh
    checkError "chmod 755 ${scriptsPath}/3.app.sh"

    grep -qxF "source ${scriptsPath}/3.app.sh" ${bashrcFile} || echo "source ${scriptsPath}/3.app.sh" >> ${bashrcFile}
    checkError "grep -qxF 'source ${scriptsPath}/3.app.sh' ${bashrcFile} || echo 'source ${scriptsPath}/3.app.sh' >> ${bashrcFile}"
}

cleanup() {
    rm -r "${HOME}/archinstall"
    checkError 'rm -r "${HOME}/archinstall"'
}

# 
clear
#showHeader "Setup finalization"

installOpenbox
setHostname

prepareUserScripts

cleanup
exit