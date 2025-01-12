#!/bin/bash

MOUNT_DIR="./mnt"
BOOT_PART="$MOUNT_DIR/boot"
ROOTFS_PART="$MOUNT_DIR/rootfs"
RPi_REPO="/home/ferganey/Embedded_Systems/Autonomous_Vhehicle_GradProject/rpirepo"
KERNEL_DIR="/home/ferganey/Embedded_Systems/other_resources/practical/embedded-linux-labs/kernel/Raspi_Linux/linux"
BUSYBOX_DIR="/home/ferganey/Embedded_Systems/busybox"
OUTPUT_DIR="/home/ferganey/Embedded_Systems/busybox/output/minimal_root"
UBOOT_DIR="/home/ferganey/Embedded_Systems/other_resources/practical/embedded-linux-labs/bootloader/u-boot"
MODULES_DIR="/home/ferganey/Embedded_Systems/other_resources/practical/Rpi4/lib/modules/5.15.92-v8+"
BOOT_SCR_PATH="/home/ferganey/Embedded_Systems/Autonomous_Vhehicle_GradProject"

check_error() {
    if [ $? -ne 0 ]; then
        echo "Error during: $1. Exiting."
        exit 1
    fi
}

REQUIRED_CMDS=(dd parted losetup mkfs.vfat mkfs.ext4 mount cp mkdir rsync file sudo)
for cmd in "${REQUIRED_CMDS[@]}"; do
    command -v $cmd > /dev/null || { echo "$cmd not found. Please install it."; exit 1; }
done

ensure_directory() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        echo "$dir does not exist. Creating it..."
        mkdir -p "$dir"
        check_error "creating $dir"
    fi

    if [ ! -r "$dir" ] || [ ! -w "$dir" ]; then
        echo "Ensuring read and write permissions for $dir..."
        sudo chmod -R u+rw "$dir"
        sudo chown -R $(whoami):$(whoami) "$dir"
        check_error "setting permissions for $dir"
    fi
}

sudo umount /media/ferganey/root
sudo umount /media/ferganey/boot
ensure_directory "$MOUNT_DIR"
ensure_directory "$BOOT_PART"
ensure_directory "$ROOTFS_PART"
SD_IMAGE=$(lsblk -o NAME,TYPE,SIZE | grep -E '^mmcblk[0-9]+.*disk' | awk '{print "/dev/" $1}')
if [ -z "$SD_IMAGE" ]; then
    echo "Error: No 64GB SD card detected. Please ensure it is connected and try again."
    exit 1
fi
sudo wipefs -a "$SD_IMAGE"
sudo parted $SD_IMAGE --script mklabel msdos
sudo parted $SD_IMAGE --script mkpart primary fat32 1MiB 256MiB
sudo parted $SD_IMAGE --script mkpart primary ext4 256MiB 100%
sudo parted $SD_IMAGE --script set 1 boot on
sudo mkfs.vfat -F 32 -n boot ${SD_IMAGE}p1
sudo mkfs.ext4 -L root ${SD_IMAGE}p2
sudo mount ${SD_IMAGE}p1 $BOOT_PART
sudo mount ${SD_IMAGE}p2 $ROOTFS_PART
echo "Verifying mounts..."
findmnt -M $BOOT_PART || echo "Boot partition not mounted"
findmnt -M $ROOTFS_PART || echo "Root filesystem not mounted"


sudo cp $RPi_REPO/{bootcode.bin,start4.elf,fixup4.dat} $BOOT_PART/
sudo chmod 644 "$BOOT_SCR_PATH/boot.scr"
sudo cp "$BOOT_SCR_PATH/boot.scr" $BOOT_PART/
sudo chmod 644 $BOOT_PART/boot.scr
sudo touch "$BOOT_PART/uboot.env"

cat <<EOF | sudo tee "$BOOT_PART/config.txt" > /dev/null
enable_uart=1
kernel=u-boot.bin
arm_64bit=1
dtoverlay=disable-bt
dtoverlay=uart0
force_turbo=1
avoid_warnings=1
EOF

sudo cp $KERNEL_DIR/arch/arm64/boot/Image $BOOT_PART/
# sudo mkdir -p $BOOT_PART/broadcom
sudo cp $KERNEL_DIR/arch/arm64/boot/dts/broadcom/bcm2711-rpi-4-b.dtb $BOOT_PART/
sudo cp $UBOOT_DIR/u-boot.bin $BOOT_PART/

sudo mkdir -p $ROOTFS_PART/{lib,etc,tmp,proc,sys,dev,home,lib64,run,usr/{bin,lib,sbin,include},var/log}
sudo rsync -a $OUTPUT_DIR/ $ROOTFS_PART/

STATIC_CHECK=$(file $BUSYBOX_DIR/output/minimal_root/bin/busybox | grep "statically linked")
if [ -z "$STATIC_CHECK" ]; then
    SYSROOT=$(aarch64-rpi4-linux-gnu-gcc -print-sysroot)
    sudo cp -rL ${SYSROOT}/lib/* $ROOTFS_PART/lib/
    sudo cp -rL ${SYSROOT}/lib64/* $ROOTFS_PART/lib64/
    sudo cp -rL ${SYSROOT}/usr/lib/* $ROOTFS_PART/usr/lib/
fi
if [ -z "$STATIC_CHECK" ]; then
    echo "Copying cross-toolchain libraries..."
    sudo cp -r /home/ferganey/x-tools/aarch64-rpi4-linux-gnu/lib/* $ROOTFS_PART/usr/lib/
    check_error "copying cross-toolchain libraries"
else
    echo "BusyBox is statically linked. Skipping cross-toolchain libraries."
fi

echo "copying cross-toolchain binaries..."
sudo cp -r /home/ferganey/x-tools/aarch64-rpi4-linux-gnu/bin/* $ROOTFS_PART/usr/bin/
sudo cp -r /home/ferganey/x-tools/aarch64-rpi4-linux-gnu/include/* $ROOTFS_PART/usr/include/
check_error "copying cross-toolchain binaries"

[ -d "$MODULES_DIR" ] && sudo mkdir -p $ROOTFS_PART/lib/modules && sudo cp -r $MODULES_DIR/* $ROOTFS_PART/lib/modules/

sudo mknod -m 666 $ROOTFS_PART/dev/null c 1 3
sudo mknod -m 600 $ROOTFS_PART/dev/console c 5 1
sudo chmod 600 $ROOTFS_PART/dev/console
sudo chown root:root $ROOTFS_PART/dev/console
sudo chown -R root:root $ROOTFS_PART/home

sudo chmod 755 $ROOTFS_PART/{bin,sbin,etc,usr,lib,lib64,home,var,dev}
sudo chmod 1777 $ROOTFS_PART/tmp

sudo mknod -m 666 $ROOTFS_PART/dev/ttyS0 c 4 64
sudo mknod -m 666 $ROOTFS_PART/dev/ttyAMA0 c 204 64
sudo chmod 666 $ROOTFS_PART/dev/ttyS0
sudo chmod 666 $ROOTFS_PART/dev/ttyAMA0
sudo chown root:root $ROOTFS_PART/dev/ttyS0
sudo chown root:root $ROOTFS_PART/dev/ttyAMA0


[ ! -f "$BOOT_PART/bootcode.bin" ] && echo "Error: bootcode.bin is missing in boot partition"
[ ! -f "$ROOTFS_PART/lib/modules/$(uname -r)" ] && echo "Error: Kernel modules are missing in root filesystem"
ls -ld $ROOTFS_PART/dev/console $ROOTFS_PART/dev/null


if mount | grep $SD_IMAGE > /dev/null; then
    sync
    sudo umount ${SD_IMAGE}p1
    sudo umount ${SD_IMAGE}p2
fi
