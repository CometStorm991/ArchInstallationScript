yay -S --needed nvidia-settings openrazer-daemon polychromatic
sudo gpasswd -a "$USER_NAME" plugdev
sudo cp "$ASSETS_DIRECTORY/razer.conf" /etc/modules-load.d/
