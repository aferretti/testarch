#!/usr/bin/env bash

# Caricamento file env.conf
source ${HOME}/startup/env.conf

getEthName() {
    ethName="enp1s0"
}
setIpAddress() {
    if [ ! -z $IP ]; then
        if [ -z $GTW ]; then GTW="192.168.3.1"; fi

        echo ${IP} ${GTW}
        printf "Waiting for you..."
        read -n 1 -s

        getEthName
        if [ ! -z ${ethName} ]; then
            nmcli con mod ${ethName} ipv4.addresses ${IP}/24
            nmcli con mod ${ethName} ipv4.gateway ${GTW}/24
            nmcli con mod ${ethName} ipv4.dns "8.8.8.8"
            nmcli con mod ${ethName} ipv4.method manual
            nmcli con up ${ethName}
        fi
    fi
}

cleanupAndReboot() {
    # rimozione della riga che esegue lo startup dal file .bashrc
    
    rm -r ${HOME}/startup
    reboot now
}

# Impostazione indirizzo IP
setIpAddress

#####################################
# avenneri: qui...
#####################################

# Pulizia e riavvio
cleanupAndReboot
