#!/bin/bash

R_R_FILES_PATH="/root/Files"
U_R_FILES_PATH=""
PROFILE=$(cat "$R_R_FILES_PATH/Information/Profile.txt")

function main() {
    initialize
    clearFiles
    installPlatformPackages
    addUsers
    rebootComputer
}

function initialize() {
    shopt -s dotglob
}

function clearFiles() {
    echo "root ALL=(ALL:ALL) ALL" > /etc/sudoers
}

function installPlatformPackages() {
    if [[ $PROFILE = "GrayLaptop" ]]
    then
        pacman -S sof-firmware 
    fi
}

function addUsers() {
    addUser

    addedUsers=false
    while ! $addedUsers
    do
        echo "Add more users?"
        select choice in "No" "Yes"
        do
            case $choice in
                "No")
                    addedUsers=true
                    break
                    ;;
                "Yes")
                    addUser
                    break
                    ;;
            esac
        done
    done
}

function addUser() {
    echo "Enter user name: "
    read -r userName

    useradd -m "$userName"

    echo "Enter password for user $userName."
    while ! passwd "$userName"
    do
        echo "Enter password for user $userName."
    done

    U_R_FILES_PATH="/home/$userName/Files"
    
    cp -r "$R_R_FILES_PATH/" "$U_R_FILES_PATH/"
    find "$U_R_FILES_PATH" -type d -exec chmod 755 {} \;
    find "$U_R_FILES_PATH" -type f -exec chmod 644 {} \;
    find "$U_R_FILES_PATH" -type f -name "*.sh" -exec chmod 744 {} \;
    chown -R "$userName:$userName" "$U_R_FILES_PATH/"

    echo "$userName ALL=(ALL:ALL) ALL" | EDITOR="tee -a" visudo 
    usermod -aG video $userName
}

function rebootComputer() {
    reboot
}

main
