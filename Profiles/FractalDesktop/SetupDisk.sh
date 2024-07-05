umount /dev/nvme0n1p1
umount /dev/nvme0n1p2
umount /dev/nvme0n1p3
umount /dev/nvme0n1p4
umount /dev/nvme0n1p5

if ! (parted --script /dev/nvme0n1 \
    mklabel gpt \
    mkpart Boot fat32 1MiB 5GiB \
    mkpart Partition1 5GiB 105GiB \
    mkpart Partition2 105GiB 205GiB \
    mkpart Partition3 205GiB 305GiB \
    mkpart Root ext4 305GiB 100%
)
then
    echo "Partitioning failed."
    exit 1
fi

if ! (mkfs.ext4 /dev/nvme0n1p5 && mkfs.fat -F 32 /dev/nvme0n1p1)
then
    echo "Formatting failed."
    exit 1
fi

if ! (mount /dev/nvme0n1p5 /mnt && mount --mkdir /dev/nvme0n1p1 /mnt/boot)
then
    echo "Mounting failed."
    exit 1
fi
