#!/bin/bash

I_I_FILES_PATH="/root/Files"

R_I_FILES_PATH="/mnt/root/Files"
R_R_FILES_PATH="/root/Files"

HAS_PROFILE=false
PROFILE=""
DEVICE_NAME=""

function main() {
    initialize

    getInformation

    checkBootMode 
    connectToInternet

    timedatectl

    setupDisk 

    runPacstrap 

    setupSystem 

    rebootComputer 
}

function errorMessage() {
    echo "$1"
    exit 1
}

function initialize() {
    setfont ter-128b
    shopt -s dotglob
}

function getInformation() {
    gotProfile=false
    while ! $gotProfile
    do
        echo "Is a profile available?"
        select choice in "No" "Yes"
        do
            case $choice in
                "No")
                    HAS_PROFILE=false
                    PROFILE=""
                    gotProfile=true
                    break
                    ;;
                "Yes")
                    echo "Enter profile name."
                    read -r PROFILE
                    if [[ -d "$I_I_FILES_PATH/Profiles/$PROFILE/" ]]
                    then
                        HAS_PROFILE=true
                        gotProfile=true
                    else
                        echo "Invalid profile."
                    fi
                    break
                    ;;
                *)
                    echo "Invalid choice."
                    ;;
            esac
        done
    done

    echo "Enter device name."
    read -r DEVICE_NAME
}

function checkBootMode() {
    BOOT_MODE=$(cat /sys/firmware/efi/fw_platform_size)
    if [[ $BOOT_MODE -ne 64 ]]
    then
        errorMessage "Boot mode is not 64."
    fi
}

function connectToInternet() {
    if ping -q -w 1 -c 1 google.com > /dev/null
    then
        return 0
    fi

    connected=false
    while ! $connected
    do
        echo "Is a WiFi connection available?"
        select choice in "No" "Yes"
        do
            case $choice in
                "No")
                    errorMessage "Internet is not available."
                    ;;
                "Yes")
                    iwctl
                    break
                    ;;
            esac
        done

        if ping -q -w 1 -c 1 google.com > /dev/null
        then
            connected=true
        fi
    done
}

function setupDisk() {
    if $HAS_PROFILE
    then
        setupDiskFilePath="$I_I_FILES_PATH/Profiles/$PROFILE/SetupDisk.sh"

        if [[ ! -e $setupDiskFilePath ]]        
        then
            errorMessage "Couldn't find file $setupDiskFilePath"
        fi

        source "$setupDiskFilePath"

        return 0        
    fi

    # Manually partition a disk
    echo "Disks:"
    lsblk
    echo "Enter disk name: "
    read -r disk

    if ! (fdisk "$disk")
    then
        errorMessage "Partitioning failed."
    fi

    # Manually format partitions
    echo "Enter root partition name: "
    read -r rootPartition
    echo "Enter boot partition name: "
    read -r bootPartition


    if (mkfs.ext4 "$rootPartition" && mkfs.fat -F 32 "$bootPartition") 
    then
        errorMessage "Formatting failed."
    fi

    # Manually mount partitions


    if ! (mount "$rootPartition" /mnt && mount --mkdir "$bootPartition" /mnt/boot)
    then
        errorMessage "Mounting failed."
    fi
}

function runPacstrap() {
    if ! pacstrap -K /mnt base linux linux-firmware intel-ucode networkmanager dkms linux-headers polkit polkit-kde-agent polkit polkit-kde-agent \
        vi vim neovim bash-language-server lua-language-server rust-analyzer vscode-html-languageserver vscode-css-languageserver typescript-language-server pyright\
        man-db man-pages texinfo \
        htop neofetch ncdu \
        base-devel git bc cmake bear cdrtools shellcheck \
        pacman-contrib unzip ifuse fuse2 wget rsync yt-dlp imagemagick libheif libreoffice-fresh usbutils
        then
            errorMessage "Running pacstrap failed."
    fi
}

function setupSystem() {
    genfstab -U /mnt >> /mnt/etc/fstab

    mkdir -p "$R_I_FILES_PATH/"
    mkdir -p "$R_I_FILES_PATH/Information/"

    # Copying these files to /mnt/root MUST occur before arch-chroot because SetupSystem.sh depends on these files being in /mnt/root
    echo "$HAS_PROFILE" > "$R_I_FILES_PATH/Information/HasProfile.txt"
    echo "$PROFILE" > "$R_I_FILES_PATH/Information/Profile.txt"
    echo "$DEVICE_NAME" > "$R_I_FILES_PATH/Information/DeviceName.txt"
    cp -r "$I_I_FILES_PATH/"* "$R_I_FILES_PATH/"

    arch-chroot /mnt bash -c "
    chmod +x $R_R_FILES_PATH/SetupSystem.sh
    $R_R_FILES_PATH/SetupSystem.sh
    "
}

function rebootComputer() {
    umount -R /mnt
    reboot
}

main 
