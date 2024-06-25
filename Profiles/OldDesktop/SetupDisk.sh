umount /dev/sda1
umount /dev/sda2

if ! (
    parted --script /dev/sda \
        mklabel gpt \
        mkpart Boot fat32 1MiB 1GiB \
        mkpart Root ext4 1GiB 100%
    )
then
    echo "Partitioning failed."
    exit 1
fi

if ! (mkfs.ext4 /dev/sda2 && mkfs.fat -F 32 /dev/sda1)
then
    echo "Formatting failed."
    exit 1
fi

if ! (mount /dev/sda2 /mnt && mount --mkdir /dev/sda1 /mnt/boot)
then
    echo "Mounting failed."
    exit 1
fi
