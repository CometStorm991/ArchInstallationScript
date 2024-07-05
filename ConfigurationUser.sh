#!/bin/bash

R_U_FILES_PATH="/root/Files"
U_U_FILES_PATH="$HOME/Files"

ASSETS_DIRECTORY="$U_U_FILES_PATH/Assets"
PROFILES_DIRECTORY="$U_U_FILES_PATH/Profiles"
CONFIG_USER="$U_U_FILES_PATH/configUser.txt"

HAS_PROFILE=$(cat "$U_U_FILES_PATH/Information/HasProfile.txt")
PROFILE=$(cat "$U_U_FILES_PATH/Information/Profile.txt")

PROFILE_ASSETS_DIRECTORY="$PROFILES_DIRECTORY/$PROFILE/Assets"

USER_NAME=$(whoami)

function main() {
    initialize

    connectToInternet

    verifyMicrocode

    aurHelper

    installZsh

    setupZsh

    installZshPlugins

    setupXorg

    setupScripts

    setupI3

    setupSound

    setupNetworking

    setupApplications

    setupVirtualization

    substituteElements

    terminate
}

function errorMessage() {
    echo "$1"
    exit 1
}

function initialize() {
    shopt -s dotglob
}

function connectToInternet() {
    if ping -q -w 1 -c 1 google.com > /dev/null
    then
        return 0
    fi

    errorMessage "Initializing failed. Run this script again once this device is connected to the Internet."
}

function initializeAction() {
    action=$1
    if [[ ! -e $CONFIG_USER ]]
    then
        touch "$CONFIG_USER"
    fi

    if ! grep -Fq "$action=" "$CONFIG_USER"
    then
        echo "$action=false" >> "$CONFIG_USER"
    fi

    source "$CONFIG_USER"
}

function getAction() {
    action=$1
    initializeAction "$action"

    if ${!action}
    then
        return 0
    else
        return 1
    fi

}

function setAction() {
    action=$1
    value=$2
    initializeAction "$action"

    if $value
    then
        sed -i "s/$action=false/$action=true/" "$CONFIG_USER"
    else
        sed -i "s/$action=true/$action=false/" "$CONFIG_USER"
    fi
}

function verifyMicrocode() {
    action="verifyMicrocode"
    if getAction $action
    then
        return 0
    fi

    echo "Microcode output:"
    sudo journalctl -k --grep="microcode:"
    echo "Is the microcode output correct?"
    select choice in "No" "Yes"
    do
        case $choice in
            "No")
                errorMessage "Verifying microcode failed."
                ;;
            "Yes")
                break
                ;;
        esac
    done

    setAction "$action" true
}

function aurHelper() {
    action="aurHelper"
    if getAction $action
    then
        return 0
    fi


    if ! (
        sudo rm -rf "$HOME/Dev/Aur/" && \
            mkdir -p "$HOME/Dev/" && \
            mkdir -p "$HOME/Dev/Aur/" && \
            sudo pacman -S --needed git base-devel && \
            git clone https://aur.archlinux.org/yay.git "$HOME/Dev/Aur/" && \
            cd "$HOME/Dev/Aur/" && \
            makepkg -sirc --noconfirm --needed && \
            cd .. && \
            yay --noconfirm --save --answerclean All --answerdiff None --answeredit None --answerupgrade None && \
            yay --noconfirm -Y --gendb && \
            yay --noconfirm --needed -Syu --devel && \
            yay --noconfirm -Y --devel --save && \
            cd "$U_U_FILES_PATH" 
        )
    then
        errorMessage "Installing AUR helper yay failed."
    fi

    setAction "$action" true
}

function installZsh() {
    action="installZsh"
    if getAction $action
    then
        return 0
    fi

    if ! (
        sudo rm -rf "$HOME/.config/powerline/" && \
            yay -S --needed terminus-font zsh zsh-completions powerline powerline-fonts fzf && \
            sudo bash -c 'echo "FONT=ter-128b" > /etc/vconsole.conf' && \
            sudo systemctl restart systemd-vconsole-setup.service && \
            git clone https://github.com/ShadowStar019/PowerlineSS019.git "$HOME/.config/powerline/" && \
            cp "$ASSETS_DIRECTORY/.zshenv" "$HOME/" && \
            chsh -s /usr/bin/zsh
        )
    then
        errorMessage "Installing Zsh failed."
    fi


    setAction "$action" true
    reboot
}

function setupZsh() {
    action="setupZsh"
    if getAction $action
    then
        return 0
    fi

    if ! (
        # sh -c ... automatically creates $HOME/.config/zsh/
        sudo rm -rf "$HOME/.config/zsh/" && \
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
            cp "$ASSETS_DIRECTORY/.zshrc" "$HOME/.config/zsh/"
        )
    then
        errorMessage "Setting up Zsh failed."
    fi

    setAction "$action" true
    reboot
}

function installZshPlugins() {
    action="installZshPlugins"
    if getAction $action
    then
        return 0
    fi

    if ! (
        sudo rm -rf "$HOME/.config/zsh/ohMyZsh/custom/plugins/zsh-autosuggestions" && \
            sudo rm -rf "$HOME/.config/zsh/ohMyZsh/custom/plugins/zsh-syntax-highlighting" && \
            git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME/.config/zsh/ohMyZsh/custom/plugins/zsh-autosuggestions" && \
            git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.config/zsh/ohMyZsh/custom/plugins/zsh-syntax-highlighting"
        )
    then
        errorMessage "Installing Zsh plugins failed."
    fi

    setAction "$action" true
}

function setupXorg() {
    action="setupXorg"
    if getAction $action
    then
        return 0
    fi

    echo "Graphics card:"
    lspci -v | grep -A1 -e VGA -e 3D
    echo "Choose your graphics card brand."
    select choice in "Intel" "NVIDIA" "AMD" "None"
    do
        case $choice in
            "Intel")
                if ! (yay -S --needed mesa vulkan-intel intel-media-driver linux-firmware)
                then
                    errorMessage "Installing Intel video drivers failed."
                fi
                break
                ;;
            "NVIDIA")
                if ! (yay -S --needed nvidia)
                then
                    errorMessage "Installing NVIDIA video drivers failed."
                fi
                break
                ;;
            "AMD")
                if ! (yay -S --needed mesa xf86-video-amdgpu vulkan-radeon libva-mesa-driver mesa-vdpau)
                then
                    errorMessage "Installing AMD video drivers failed."
                fi
                break
                ;;
            "None")
                break
                ;;
            *)
                echo "Invalid choice."
                ;;
        esac
    done

    if ! (
        yay -S --needed xorg-server xorg-apps && \
            sudo mkinitcpio -P
        )
    then
        errorMessage "Installing Xorg failed."
    fi

    if $HAS_PROFILE
    then
        local setupXorgFilePath="$U_U_FILES_PATH/Profiles/$PROFILE/SetupXorg.sh"

        if [[ ! -e $setupXorgFilePath ]]        
        then
            errorMessage "Couldn't find file $setupXorgFilePath"
        fi

        source "$setupXorgFilePath"
    fi

    setAction "$action" true
}

function setupScripts() {
    action="setupScripts"
    if getAction $action
    then
        return 0
    fi

    mkdir -p "$HOME/Bin/"
    cp "$ASSETS_DIRECTORY"/Bin/* "$HOME/Bin/"

    if $HAS_PROFILE
    then
        local setupScriptsFilePath="$U_U_FILES_PATH/Profiles/$PROFILE/SetupScripts.sh"

        if [[ ! -e $setupScriptsFilePath ]]        
        then
            errorMessage "Couldn't find file $setupScriptsFilePath"
        fi

        source "$setupScriptsFilePath"
    fi

    setAction "$action" true
}

function setupI3() {
    action="setupI3"
    if getAction $action
    then
        return 0
    fi

    if ! (
        sudo rm -rf "$HOME/.config/i3/" && \
            sudo rm -rf "$HOME/.config/polybar/" && \
            yay -S --needed xorg-xinit xdotool i3-wm i3lock-color polybar dmenu feh redshift xidlehook xclip ttf-fira-code ttf-firacode-nerd noto-fonts && \
            cp /etc/X11/xinit/xinitrc "$HOME/.xinitrc" && \
            head -n -5 "$HOME/.xinitrc" > "$HOME/temp.txt" && \
            mv "$HOME/temp.txt" "$HOME/.xinitrc" && \
            echo "i3" >> "$HOME/.xinitrc" && \
            git clone https://github.com/ShadowStar019/i3wmSS019.git "$HOME/.config/i3/" && \
            git clone https://github.com/ShadowStar019/PolybarSS019.git "$HOME/.config/polybar/" && \
            mkdir -p "$HOME/State/" && \
            mkdir -p "$HOME/Stuff/"
        )
    then
        errorMessage "Installing I3 failed."
    fi

    if $HAS_PROFILE
    then
        local setupI3FilePath="$U_U_FILES_PATH/Profiles/$PROFILE/SetupI3.sh"

        if [[ ! -e $setupI3FilePath ]]        
        then
            errorMessage "Couldn't find file $setupI3FilePath"
        fi

        source "$setupI3FilePath"
    fi

    setAction "$action" true
}

function setupSound() {
    action="setupSound"
    if getAction $action
    then
        return 0
    fi

    if ! (yay -S --needed pipewire pipewire-docs pipewire-audio pipewire-pulse pipewire-jack qpwgraph)
    then
        errorMessage "Setting up sound failed."
    fi

    if $HAS_PROFILE
    then
        local setupSoundFilePath="$U_U_FILES_PATH/Profiles/$PROFILE/SetupSound.sh"

        if [[ ! -e $setupSoundFilePath ]]        
        then
            errorMessage "Couldn't find file $setupSoundFilePath"
        fi

        source "$setupSoundFilePath"
    fi

    setAction "$action" true
}

function setupNetworking() {
    action="setupNetworking"
    if getAction $action
    then
        return 0
    fi

    if ! (
        yay -S --needed ufw openssh && \
            sudo systemctl enable sshd.service && \
            sudo systemctl start sshd.service && \
            ssh-keygen && \
            sudo systemctl enable ufw.service && \
            sudo systemctl start ufw.service && \
            sudo ufw enable && \
            sudo ufw allow ssh && \
            sudo ufw allow 6881 && \
            sudo ufw allow 7881 && \
            sudo ufw allow 8881
        )
    then
        errorMessage "Setting up networking failed."
    fi

    setAction "$action" true
}

function setupApplications() {
    action="setupApplications"
    if getAction $action
    then
        return 0
    fi

    if ! (
        sudo rm -rf "$HOME/.config/kitty/" && \
            sudo rm -rf "$HOME/.config/nvim/" && \
            sudo rm -rf "$HOME/Stuff/FirefoxResources/" && \
            yay -S --needed kitty firefox flameshot obs-studio kdenlive krita ktorrent okular vlc dolphin hwloc breeze breeze-gtk qt6ct && \
            git clone https://github.com/ShadowStar019/KittySS019.git "$HOME/.config/kitty/" && \
            git clone https://github.com/ShadowStar019/NeovimSS019.git "$HOME/.config/nvim/" && \
            mkdir -p "$HOME/Stuff/" && \
            mkdir -p "$HOME/Stuff/FirefoxResources/" && \
            git clone https://github.com/ShadowStar019/FirefoxSS019.git "$HOME/Stuff/FirefoxResources/" && \
            cp "$HOME/Stuff/FirefoxResources/ResetFirefox.sh" "$HOME/Bin/" && \
            sed -i -- "s/<%userName%>/$USER_NAME/g" "$HOME/Bin/ResetFirefox.sh"
                    "$HOME/Bin/ResetFirefox.sh"
                )
            then
                errorMessage "Installing applications failed."
    fi

    echo "Enable dark theme?"
    select choice in "No" "Yes"
    do
        case $choice in
            "No")
                enableDarkTheme=false
                break
                ;;
            "Yes")
                enableDarkTheme=true
                break
                ;;
        esac
    done

    if $enableDarkTheme
    then
        if ! (
            mkdir -p "$HOME/.config/" && \
                mkdir -p "$HOME/.config/gtk-3.0/" && \
                cp "$ASSETS_DIRECTORY/settings.ini" "$HOME/.config/gtk-3.0/" && \
                mkdir -p "$HOME/.config/qt6ct/" && \
                cp "$ASSETS_DIRECTORY/qt6ct.conf" "$HOME/.config/qt6ct/"
            )
        then
            errorMessage "Enabling dark theme failed."
        fi
    fi

    setAction "$action" true
}

function setupVirtualization() {
    action="setupVirtualization"
    if getAction $action
    then
        return 0
    fi

    echo "KVM support output:"
    LC_ALL=C.UTF-8 lscpu | grep Virtualization
    zgrep CONFIG_KVM= /proc/config.gz
    lsmod | grep kvm
    echo "Is the output correct?"
    select choice in "No" "Yes"
    do
        case $choice in
            "No")
                errorMessage "Verifying KVM support failed."
                ;;
            "Yes")
                break
                ;;
        esac
    done

    echo "VIRTIO support output:"
    zgrep VIRTIO /proc/config.gz
    lsmod | grep virtio
    echo "Is the output correct?"
    select choice in "No" "Yes"
    do
        case $choice in
            "No")
                errorMessage "Verifying VIRTIO support failed."
                ;;
            "Yes")
                break
                ;;
        esac
    done

    nestedStr=""
    echo "Choose your CPU brand."
    select choice in "Intel" "AMD"
    do
        case $choice in
            "Intel")
                nestedStr="intel"
                break
                ;;
            "AMD")
                nestedStr="amd"
                break
                ;;
            *)
                echo "Invalid choice."
                ;;
        esac
    done

    if ! (
        sudo bash -c "echo 'options kvm_$nestedStr nested=1' > /etc/modprobe.d/kvm_$nestedStr.conf" && \
            yay -S --needed qemu-full qemu-block-gluster qemu-block-iscsi samba libvirt iptables-nft dnsmasq openbsd-netcat dmidecode virt-manager && \
            sudo bash -c "echo 'firewall_backend=\"iptables\"' > /etc/libvirt/network.conf" && \
            sudo gpasswd -a "$USER_NAME" libvirt && \
            sudo systemctl start libvirtd.service && \
            sudo systemctl start virtlogd.service && \
            sudo systemctl enable libvirtd.service && \
            sudo systemctl start libvirtd.socket && \
            sudo systemctl enable libvirtd.socket && \
            sudo virsh net-autostart default
        )
    then
        errorMessage "Setting up virtualization failed."
    fi

    setAction "$action" true
}

function substituteElements() {
    action="substituteElements"
    if getAction $action
    then
        return 0
    fi

    if $HAS_PROFILE
    then
        local substituteElementsFilePath="$U_U_FILES_PATH/Profiles/$PROFILE/SubstituteElements.sh"

        if [[ ! -e $substituteElementsFilePath ]]        
        then
            errorMessage "Couldn't find file $substituteElementsFilePath"
        fi

        source "$substituteElementsFilePath"
    else
        startx &
        sleep 1
        xrandr -d :0 > xrandrOutput.txt
        sleep 1
        killall xinit
        less xrandrOutput.txt
        echo "Enter monitor name as it appeared in xrandr."
        read -r monitorName
        echo "Enter resolution as it appeared in xrandr."
        read -r resolution
        echo "Enter refresh rate as it appeared in xrandr."
        read -r refreshRate
    fi

    files=$(ls "$HOME/Bin/")
    for file in $files
    do
        sed -i -- "s/<%userName%>/$USER_NAME/g" "$HOME/Bin/$file"
        sed -i -- "s/<%monitorName%>/$monitorName/g" "$HOME/Bin/$file"
        sed -i -- "s/<%resolution%>/$resolution/g" "$HOME/Bin/$file"
        sed -i -- "s/<%refreshRate%>/$refreshRate/g" "$HOME/Bin/$file"
    done

    setAction "$action" true
}

function terminate() {
    action="terminate"
    if getAction $action
    then
        return 0
    fi

    setAction "$action" true
    sudo rm -r "$R_U_FILES_PATH"
    rm -r "$U_U_FILES_PATH"
    reboot
}

main
