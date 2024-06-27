#!/usr/bin/env bash

# Caricamento file env.conf
source ${HOME}/archinstall/configs/env.conf

# Caricamento file setup.conf
source ${CONFIGS_DIR}/setup.conf

# Caricamento file helpers.sh
source ${SCRIPTS_DIR}/helpers.sh

setUsers() {
    printf "root:${PASSWD}" | chpasswd
    checkError "printf \"root:${PASSWD}\" | chpasswd"

    alreadyExists=$(grep '${USER}' /etc/passwd)
    echo "ae" $alreadyExists
    waitForInput

    if [ "$(grep '${USER}' /etc/passwd)" -eq 1 ]; then
        echo "adduser"
        useradd -m -g users -G wheel ${USER}
        checkError "useradd -m -g users -G wheel ${USER}"
    fi

    printf "${USER}:${PASSWD}" | chpasswd
    checkError "printf \"${USER}:${PASSWD}\" | chpasswd"

    sed -i 's/^%wheel ALL=(ALL:ALL) NOPASSWD: ALL/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers
    checkError "sed -i 's/^%wheel ALL=(ALL:ALL) NOPASSWD: ALL/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers"

    sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
    checkError "sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers"
}

installBasePackages() {
    pacman -S base-devel dosfstools grub efibootmgr mtools less nano networkmanager openssh os-prober net-tools sudo --noconfirm --needed
    checkError "pacman -S base-devel dosfstools grub efibootmgr mtools nano networkmanager openssh os-prober net-tools sudo --noconfirm --needed"

    systemctl enable sshd
    checkError "systemctl enable sshd"

    systemctl enable NetworkManager
    checkError "systemctl enable NetworkManager"
}

installLinuxPackages() {
    pacman -S linux linux-headers linux-firmware --noconfirm --needed
    checkError "pacman -S linux linux-headers linux-firmware --noconfirm --needed"

    mkinitcpio -p linux
    checkError "mkinitcpio -p linux"
}

setTimezoneAndLocale() {
    ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
    checkError "ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime"

    hwclock --systohc
    checkError "hwclock --systohc"

    sed -i "s|^#${LANG} UTF-8|${LANG} UTF-8|" /etc/locale.gen
    checkError "sed -i \"s|^#${LANG} UTF-8|${LANG} UTF-8|\" /etc/locale.gen"

    locale-gen
    checkError "locale-gen"

    localectl --no-ask-password set-locale ${LANG}
    checkError "localectl --no-ask-password set-locale ${LANG}"

    localectl --no-ask-password set-keymap ${KEYMAP}
    checkError "localectl --no-ask-password set-keymap ${KEYMAP}"
}

setupGrubFile() {
    grubFile=/etc/default/grub

    sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' $grubFile
    checkError "sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' $grubFile"

    sed -i "s|^GRUB_DISTRIBUTOR=.*|GRUB_DISTRIBUTOR=${APP,}|" $grubFile
    checkError "sed -i \"s|^GRUB_DISTRIBUTOR=.*|GRUB_DISTRIBUTOR=${APP,}|\" $grubFile"
}

configureGrub() {
    setupGrubFile

    grub-install --target=${PLATFORM} --efi-directory=/boot --bootloader-id=grub ${DISK}
    checkError "grub-install --target=${PLATFORM} --efi-directory=/boot --bootloader-id=grub ${DISK}"

    grub-mkconfig -o /boot/grub/grub.cfg
    checkError "grub-mkconfig -o /boot/grub/grub.cfg"
}

setDefaultEditor() {
    cp ${ASSETS_DIR}/environment /etc
    checkError "cp ${ASSETS_DIR}/environment /etc"
}

setAutologin() {
    mkdir -p /etc/systemd/system/getty@tty1.service.d
    checkError "mkdir -p /etc/systemd/system/getty@tty1.service.d"

    cp ${ASSETS_DIR}/autologin.conf /etc/systemd/system/getty@tty1.service.d/*
    checkError "cp ${ASSETS_DIR}/autologin.conf /etc/systemd/system/getty@tty1.service.d/*"

    sed -i "|s[[USER]]|${USER}|g" /etc/systemd/system/getty@tty1.service.d/autologin.conf
    checkError "sed -i \"|s[[USER]]|${USER}|g\" /etc/systemd/system/getty@tty1.service.d/autologin.conf"

    systemctl enable getty@tty1.service
    checkError "systemctl enable getty@tty1.service"
}

# Inizializzazione degli utenti e delle password e installazione packages sistema operativo e abilitazione servizi
clear
showHeader "Users setup and base/linux packages installation"

setUsers
installBasePackages
installLinuxPackages

# Impostazioni timezone, locale e preparazione GRUB
clear
showHeader "Date/Time, Locales and Grub setup"

setTimezoneAndLocale
configureGrub

# Setup default editor e autologin
: '
clear
showHeader "Default editor and autologin setup"

setDefaultEditor
setAutologin
'