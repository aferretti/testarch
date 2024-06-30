#!/usr/bin/env bash

# Caricamento file env.conf
source ${HOME}/startup/env.conf

cleanupAndReboot() {
    # rimozione della riga che esegue lo startup dal file .bashrc
    sed -i '/source /home/fertec/startup/3\.app\.sh/d' ${HOME}/.bashrc

    # rimozione della cartella contenente gli script di avvio
    rm -r ${HOME}/startup

    sudo reboot
}

#####################################
# avenneri: qui...
#####################################

# Pulizia e riavvio
cleanupAndReboot
