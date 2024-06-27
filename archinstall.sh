#!/usr/bin/env bash
setEnvironmentVariables() {
    set -a
    BASE_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
    ASSETS_DIR=${BASE_DIR}/assets
    SCRIPTS_DIR=${BASE_DIR}/scripts
    CONFIGS_DIR=${BASE_DIR}/configs
    LOGS_DIR=${BASE_DIR}/logs
    INSTALL_LOG=${LOGS_DIR}/"$( date "+%Y%m%d-%H%M%S" ).log" 

    echo "$1" 
    PARAM_APP="$1"
    PARAM_STACK="$2"
    PARAM_DEVID="$3"
    PARAM_DEVIP="$4"
    set +a

    if [ ! -d $SCRIPTS_DIR ]; then return 2; fi
    if [ ! -d $CONFIGS_DIR ]; then return 3; fi
    if [ ! -d $ASSETS_DIR ]; then return 4; fi

    if [ ! -d $LOGS_DIR ]; then mkdir $LOGS_DIR; fi
    if [ ! -f $INSTALL_LOG ]; then touch -f $INSTALL_LOG; fi

    return 0
}

# inizializzazione variabili ambiente per procedura di installazione
setEnvironmentVariables

if [ $? -eq 0 ]; then
    # caricamento del file helpers.h
    source "$SCRIPTS_DIR/helpers.sh"

    # esecuzione dello script di pre-installazione
    ( bash ${SCRIPTS_DIR}/0.preinstall.sh )

    # esecuzione dello script di installazione
    #( arch-chroot /mnt ${HOME}/archinstall/scripts/1.core.sh )

    # esecuzione dello script di post-installazione
    #( arch-chroot /mnt ${HOME}/archinstall/scripts/2.finalization.sh )
else
    printf "HELP %d" $?
fi