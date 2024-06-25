#!/bin/bash

R_R_FILES_PATH="/root/Files"
R_R_MOUNT_PATH="/root/Mount"

echo "Enter disk partition with installation files."
read -r installationDisk
umount "$installationDisk"
mount --mkdir "$installationDisk" "$R_R_MOUNT_PATH/"
cp -r "$R_R_MOUNT_PATH"/* "$R_R_FILES_PATH"
chmod +x "$R_R_FILES_PATH"/*.sh
userNames=$(awk -F: '($3>=1000)&&($1!="nobody"){print $1}' /etc/passwd)
for userName in $userNames
do
    userdel -r "$userName"
done
echo "root ALL=(ALL:ALL) ALL" > /etc/sudoers
"$R_R_FILES_PATH/ConfigurationRoot.sh" "$@"
