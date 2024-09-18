#!/usr/bin/env bash

# Caricamento file env.conf
source ${HOME}/startup/env.conf

waitForInput() {
    printf "Premere un tasto per cleanup e riavvio..."
    read -n 1 -s
}

getEthName() {
    ETHNAME=""

    for name in $(nmcli -t -f NAME c show --active) ; do
        ETHNAME=${name}
        echo -n ${name}
        #return
    done
}

setIpAddress() {
    if [ "${PROJECT_NAME,,}" = "neuron" ]; then
        getEthName
        if [ -z ${ETHNAME} ]; then 
            echo "ERROR! No active ethernet interface found"; 
            exit
        fi

        #echo f3rt3c | sudo -S nmcli connection modify ${ETHNAME} con-name culo
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
