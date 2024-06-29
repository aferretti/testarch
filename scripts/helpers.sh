#!/usr/bin/env bash

showHeader() {
    #echo "showHeader - TODO"
    if [ -n "$1" ]; then echo "$1"; fi
}

showInfo() {
    echo "showInfo - TODO"
}

saveLog() {
    messageToLog="$1"
    printf "%s\n" "$messageToLog" | tee -a "${INSTALL_LOG}"
}

saveLogAndExit() {
    saveLog "$1"
    exit
}

checkError() {
    if [ $? -ne 0 ]; then
        if [ -n "$1" ]; then 
            errorMessage="$1"
        else
            errorMessage="Unspecified error"
        fi

        saveLog "$errorMessage"
        if [ -z $2 ]; then exit 1; fi
    fi
}

waitForInput() {
    printf "Waiting for you..."
    read -n 1 -s
}