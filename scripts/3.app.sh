#!/usr/bin/env bash

# Caricamento file env.conf
source ${HOME}/startup/env.conf

waitForInput() {
    printf "Premere un tasto per continuare..."
    read -n 1 -s
}

setConnectionName() {
    ethName="LAN"

    sourceEthName=$(nmcli -g name connection show | head -1)
    echo "Name" ${sourceEthName}

    if [ ! -z "${sourceEthName}" ]; then
        waitForInput
        sudo nmcli connection modify "${sourceEthName}" con-name "${ethName}"
        #echo ${PASSWD} | sudo -S nmcli connection modify "${sourceEthName}" con-name "${ethName}"
    else 
        return 1
    fi
}

setIpAddress() {
    if [ ! -z $IP ]; then
        #su -p ${PASSWD}

        if [ -z $GTW ]; then GTW="192.168.3.1"; fi

        setConnectionName

: '
        if [ ! -z ${ethName} ]; then
            echo ${ethName}
            waitForInput

            echo ${PASSWD} | sudo -S nmcli con mod ${ethName} ipv4.addresses ${IP}/24 ipv4.gateway ${GTW} ipv4.dns 8.8.8.8 ipv4.method manual
            waitForInput

            echo "riavvio networkmanager"
            systemctl restart NetworkManager.service
        fi
'
        exit
    fi
}

cleanupAndReboot() {
    # rimozione della riga che esegue lo startup dal file .bashrc
    sed -i '/source /home/fertec/startup/3\.app\.sh/d' ${HOME}/.bashrc

    # rimozione della cartella contenente gli script di avvio
    rm -r ${HOME}/startup

    #sudo reboot
}

# Impostazione indirizzo IP statico
setIpAddress

#####################################
# avenneri: qui...
#####################################

# Pulizia e riavvio
#cleanupAndReboot
