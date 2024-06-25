umount /dev/vda1
umount /dev/vda2

parted --script /dev/vda \
    mklabel gpt \
    mkpart Boot fat32 1MiB 1GiB \
    mkpart Root ext4 1GiB 100%

if [[ $? -ne 0 ]]
then
    echo "Partitioning failed."
    exit 1
fi

mkfs.ext4 /dev/vda2 && mkfs.fat -F 32 /dev/vda1

if [[ $? -ne 0 ]]
then
    echo "Formatting failed."
    exit 1
fi

mount /dev/vda2 /mnt && mount --mkdir /dev/vda1 /mnt/boot

if [[ $? -ne 0 ]]
then
    echo "Mounting failed."
    exit 1
fi
