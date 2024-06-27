#!/usr/bin/env bash
setEnvironmentVariables() {
    set -a
    BASE_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
    ASSETS_DIR=${BASE_DIR}/assets
    SCRIPTS_DIR=${BASE_DIR}/scripts
    CONFIGS_DIR=${BASE_DIR}/configs
    LOGS_DIR=${BASE_DIR}/logs
    INSTALL_LOG=${LOGS_DIR}/"$( date "+%Y%m%d-%H%M%S" ).log" 
    set +a

    if [ ! -d $SCRIPTS_DIR ]; then return 1; fi
    if [ ! -d $CONFIGS_DIR ]; then return 1; fi
    if [ ! -d $ASSETS_DIR ]; then return 1; fi

    if [ ! -d $LOGS_DIR ]; then mkdir $LOGS_DIR; fi
    if [ ! -f $INSTALL_LOG ]; then touch -f $INSTALL_LOG; fi

    return 0
}

setParameters() {
    if [ ! -z "$PARAM_APP" ]; then
        if [ "${PARAM_APP,,}" != "neuron" ] || [ "${PARAM_APP,,}" != "fenice" ]; then checkError "cazzo" ; fi
        sed -i "s|^APP=|APP=${PARAM_APP}|" $CONFIGS_DIR/setup.conf
    fi

    if [ ! -z "$PARAM_STACK" ]; then
        sed -i "s|^STACK=|STACK=${PARAM_STACK}|" $CONFIGS_DIR/setup.conf
    fi

    if [ ! -z "$PARAM_DEVID" ]; then
        sed -i "s|^DEVID=|DEVID=${PARAM_DEVID}|" $CONFIGS_DIR/setup.conf
    fi

    if [ ! -z "$PARAM_DEVIP" ]; then
        sed -i "s|^DEVIP=|DEVIP=${PARAM_DEVIP}|" $CONFIGS_DIR/setup.conf
    fi
}

PARAM_APP="$1"
PARAM_STACK="$2"
PARAM_DEVID="$3"
PARAM_DEVIP="$4"     
    
# inizializzazione variabili ambiente per procedura di installazione
setEnvironmentVariables

if [ $? -eq 0 ]; then
    # caricamento del file helpers.h
    source "$SCRIPTS_DIR/helpers.sh"

    # preparazione dei parametri di lavoro
    setParameters

    # esecuzione dello script di pre-installazione
    ( bash ${SCRIPTS_DIR}/0.preinstall.sh )

    # esecuzione dello script di installazione
    #( arch-chroot /mnt ${HOME}/archinstall/scripts/1.core.sh )

    # esecuzione dello script di post-installazione
    #( arch-chroot /mnt ${HOME}/archinstall/scripts/2.finalization.sh )
else
    printf "HELP %d" $?
fi