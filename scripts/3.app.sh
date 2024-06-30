#!/usr/bin/env bash

# Caricamento file env.conf
source ${HOME}/startup/env.conf

setConnectionName() {
    ethName="LAN"

    sourceEthName=$(nmcli -g name connection show | head -1)
    checkError "sourceEthName=$(nmcli -g name connection show | head -1)"

    if [ ! -z "${sourceEthName}" ]; then
        nmcli connection modify "${sourceEthName}" con-name "${ethName}"
        checkError "nmcli connection modify \"${sourceEthName}\" con-name \"${ethName}\""
    else 
        return 1
    fi
}

setIpAddress() {
    if [ ! -z $IP ]; then
        su -p ${PASSWD}

        if [ -z $GTW ]; then GTW="192.168.3.1"; fi

        echo ${IP} ${GTW}
        printf "Waiting for you..."
        read -n 1 -s

        setConnectionName
        checkError "setConnectionName"

        if [ ! -z ${ethName} ]; then
            nmcli con mod ${ethName} ipv4.addresses ${IP}/24 ipv4.gateway ${GTW}/24 ipv4.dns 8.8.8.8 ipv4.method manual
            checkError "nmcli con mod ${ethName} ipv4.addresses ${DEVIP}/24 ipv4.gateway ${DEVGTW}/24 ipv4.dns 8.8.8.8 ipv4.method manual"

            systemctl restart NetworkManager.service
            checkError "systemctl restart NetworkManager.service"
        fi

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
