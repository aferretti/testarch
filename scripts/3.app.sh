#!/usr/bin/env bash

# Caricamento file env.conf
source ${HOME}/startup/env.conf

waitForInput() {
    printf "Premere un tasto per cleanup e riavvio..."
    read -n 1 -s
}

saveLog() {
    messageToLog="$1"
    printf "%s\n" "$messageToLog" | tee -a "${INSTALL_LOG}"
}

saveLogAndExit() {
    saveLog "$1"
    exit
}

getEthName() {
    ETHNAME="eu-lan"    
    echo ${PASSWORD} | sudo -S nmcli connection modify Wired\ connection\ 1 con-name ${ETHNAME} >> /dev/null
}

setIpAddress() {
    if [ "${PROJECT_NAME,,}" = "neuron" ]; then
        getEthName
        if [ -z ${ETHNAME} ]; then saveLogAndExit "ERROR! No active ethernet interface found"; fi

        echo ${PASSWORD} | sudo -S nmcli connection modify ${ETHNAME} ipv4.addresses "${IP}/24" ipv4.gateway "${GTW}" >> /dev/null
        echo ${PASSWORD} | sudo -S nmcli connection modify ${ETHNAME} ipv4.method manual >> /dev/null
        echo ${PASSWORD} | sudo -S nmcli connection modify ${ETHNAME} connection.autoconnect yes >> /dev/null
    fi
}

cleanupAndReboot() {
    # rimozione della riga che esegue lo startup dal file .bashrc
    bashFile="${HOME}/.bashrc"

    grep -v "source /home/fertec/startup/3.app.sh" ${bashFile} > ${bashFile}2 
    mv ${bashFile}2 ${bashFile}

    # rimozione della cartella contenente gli script di avvio
    if [ -d ${HOME}/startup ]; then rm -r ${HOME}/startup; fi

    # riavvio
    echo ${PASSWORD} | sudo -S reboot >> /dev/null
}

#####################################
# avenneri: qui...
#####################################

# Impostazione indirizzo IP statico
setIpAddress
clear

# Pulizia e riavvio
cleanupAndReboot
