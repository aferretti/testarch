#!/usr/bin/env bash

# Caricamento file env.conf
source ${HOME}/startup/env.conf

waitForInput() {
    printf "Premere un tasto per cleanup e riavvio..."
    read -n 1 -s
}

getEthName() {
    ETHNAME=""

    for name in $(echo f3rt3c | sudo -s nmcli con show) ; do
        echo $name
    done
}

setIpAddress() {
    if [ "${APP,,}" = "neuron" ]; then
        getEthName
    fi
}

cleanupAndReboot() {
    # rimozione della riga che esegue lo startup dal file .bashrc
    sed -i '/source /home/fertec/startup/3\.app\.sh/d' ${HOME}/.bashrc

    # rimozione della cartella contenente gli script di avvio
    rm -r ${HOME}/startup

    #sudo reboot
}

setIpAddress

#####################################
# avenneri: qui...
#####################################

# Pulizia e riavvio
#waitForInput
#cleanupAndReboot
