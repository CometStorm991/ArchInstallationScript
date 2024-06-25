#!/bin/bash

I_I_FILES_PATH="/root/Files"
I_I_MOUNT_PATH="/root/Mount"

echo "Enter disk partition with installation files."
read -r installationDisk
umount "$installationDisk"
mount --mkdir "$installationDisk" "$I_I_MOUNT_PATH/"
mkdir -p "$I_I_FILES_PATH"
cp -r "$I_I_MOUNT_PATH"/* "$I_I_FILES_PATH"
chmod +x "$I_I_FILES_PATH"/*.sh
"$I_I_FILES_PATH/Installation.sh" "$@"
