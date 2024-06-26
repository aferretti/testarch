#!/usr/bin/env bash

# Caricamento file setup.conf
source $CONFIGS_DIR/setup.conf

# Caricamento file helpers.sh
source $SCRIPTS_DIR/helpers.sh

isRoot() {
    if [ "$(id -u)" != "0" ]; then
        saveLog "ERROR! This script must be run under the 'root' user"
        exit
    fi
}

isOnline() {
    echo "TODO"
}

isArchOS() {
    if [ ! -e /etc/arch-release ]; then
        saveLog "ERROR! This script must be run in Arch Linux"
        exit
    fi
}

isPacmanOk() {
    if [ -f /var/lib/pacman/db.lck ]; then
        saveLog "ERROR! Pacman is blocked. If not running remove /var/lib/pacman/db.lck"
        exit
    fi
}

doChecks() {
    isRoot
    isArchOS
    isOnline
    isPacmanOk
}

getFirstDiskAvailable() {
    DISK=""

    for dev in $(lsblk -ndo name); do
        devinfo="$(udevadm info --query=property --path=/sys/block/$dev)"

        devname=$( sed -n 's/.*DEVNAME=\([^;]*\).*/\1/p' <<< $devinfo )
        devtype=$( sed -n 's/.*ID_TYPE=\([^;]*\).*/\1/p' <<< $devinfo )
        devbus=$( sed -n 's/.*ID_BUS=\([^;]*\).*/\1/p' <<< $devinfo )

        #devname=$(printf "%s" "$devinfo" | perl -ne 'print "$1" if /^DEVNAME=(.*)/')
        #devtype=$(printf "%s" "$devinfo" | perl -ne 'print "$1" if /^ID_TYPE=(.*)/')
        #devbus=$(printf "%s" "$devinfo" | perl -ne 'print "$1" if /^ID_BUS=(.*)/')

        if [ "${devtype,,}" = "disk" ] && { [ "${devbus,,}" = "ata" ] || [ "${devbus,,}" = "scsi" ]; }; then
            DISK="$devname"
            exit
        fi
    done

    echo "trovato " $DISK
}

getDisk() {
    getFirstDiskAvailable

    if [ -z $DISK ]; then
        saveLog "ERROR! No available disks ata or scsi found"
        exit 
    fi
}

setTime() {
    timedatectl --no-ask-password set-timezone ${TIMEZONE}

    timedatectl --no-ask-password set-ntp 1
}

createVolumes() {
    umount -A --recursive /mnt
    checkError "umount -A --recursive /mnt"

    sgdisk -Z $DISK 
    checkError "sgdisk -Z $DISK"

    sgdisk -a 2048 -o $DISK
    checkError "sgdisk -a 2048 -o $DISK"

    sgdisk -n 1::$UEFI --typecode=1:ef00 --change-name=1:'EFIBOOT' $DISK
    checkError "sgdisk -n 1::$UEFI --typecode=1:ef00 --change-name=1:'EFIBOOT' $DISK"

    sgdisk -n 2::$SWAP --typecode=1:8200 --change-name=2:'SWAP' $DISK
    checkError "sgdisk -n 2::$SWAP --typecode=1:8200 --change-name=2:'SWAP' $DISK"

    sgdisk -n 3::-0 --typecode=3:8300 --change-name=3:'ROOT' $DISK
    checkError "sgdisk -n 3::-0 --typecode=3:8300 --change-name=3:'ROOT' $DISK"

    partprobe $DISK
    checkError "partprobe $DISK"
}

formatVolumes() {
    mkfs.fat -F 32 ${DISK}1
    checkError "mkfs.fat -F 32 ${DISK}1"

    mkswap ${DISK}2
    checkError "mkswap ${DISK}2"

    mkfs.ext4 ${DISK}3
    checkError "mkfs.ext4 ${DISK}3"
}

mountVolumes() {
    mount /dev/${DISK}3 /mnt
    checkError "mount /dev/${DISK}3 /mnt"

    mount --mkdir /dev/${DISK}1 /mnt/boot
    checkError "mount --mkdir /dev/${DISK}1 /mnt/boot"

    swapon /dev/${DISK}2
    checkError "swapon /dev/${DISK}2"
}

setDisk() {
    createVolumes
    formatVolumes
    mountVolumes
}

initPacman() {
    pacman -Syy --noconfirm --needed
    checkError "pacman -Syy --noconfirm --needed"

    pacstrap -i /mnt base base-devel --noconfirm --needed
    checkError "pacstrap -i /mnt base --noconfirm --needed"
}

initFSTable() {
    genfstab -U -p /mnt >> /mnt/etc/fstab
    checkError "genfstab -U -p /mnt >> /mnt/etc/fstab"
}

clone() {
    targetPath="/mnt/root/archinstall"
    configPath="${targetPath}/configs"
    configFile="${configPath}/env.conf"

    cp -R ${BASE_DIR} ${targetPath}
    checkError "cp -R ${BASE_DIR} ${targetPath}"

    touch -f "${configFile}"
    checkError 'touch -f "${configFile}'

    echo "BASE_DIR=${targetPath}" >> ${configFile}
    echo "ASSETS_DIR=${targetPath}/assets" >> ${configFile}
    echo "SCRIPTS_DIR=${targetPath}/scripts" >> ${configFile}
    echo "CONFIGS_DIR=${configPath}" >> ${configFile}
    echo "LOGS_DIR=${targetPath}/logs" >> ${configFile}
    echo "INSTALL_LOG=${targetPath}/logs/$( date "+%Y%m%d-%H%M%S" ).log" >> ${configFile}
}

# Esecuzione verifiche preliminari alla procedura di installazione
clear
showHeader "ciccio"

doChecks
getDisk
waitForInput

# Esecuzione delle operazioni preliminari alla procedura di installazione
: '
clear
showHeader "pluto" 

setTime
setDisk
waitForInput

clear
initPacman
waitForInput

clear
clone
initFSTable
waitForInput
'