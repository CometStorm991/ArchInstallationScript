sudo cp "$PROFILE_ASSETS_DIRECTORY/Udev/"* /etc/udev/rules.d/
yay -S --needed input-remapper-git picom
mkdir -p "$HOME/.config/"
cp "$PROFILE_ASSETS_DIRECTORY/input-remapper-2/" "$HOME/.config/"
