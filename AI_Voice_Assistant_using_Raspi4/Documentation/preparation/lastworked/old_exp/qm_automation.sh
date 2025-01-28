#!/bin/bash

# Variables
SD_IMAGE="./qemuhost/sd.img"
MOUNT_DIR="./qemuhost/mnt"
BOOT_PART="$MOUNT_DIR/boot"
ROOTFS_PART="$MOUNT_DIR/rootfs"
RPi_REPO="/home/ferganey/Embedded_Systems/Autonomous_Vhehicle_GradProject/rpirepo"
KERNEL_DIR="/home/ferganey/Embedded_Systems/other_resources/practical/embedded-linux-labs/kernel/Raspi_Linux/linux"
BUSYBOX_DIR="/home/ferganey/Embedded_Systems/busybox"
OUTPUT_DIR="/home/ferganey/Embedded_Systems/busybox/output/minimal_root"
UBOOT_DIR="/home/ferganey/Embedded_Systems/other_resources/practical/embedded-linux-labs/bootloader/u-boot"
MODULES_DIR="/home/ferganey/Embedded_Systems/other_resources/practical/Rpi4/lib/modules/5.15.92-v8+"
BOOT_SCR_PATH="/home/ferganey/Embedded_Systems/Autonomous_Vhehicle_GradProject"

# Function to check command success
check_error() {
    if [ $? -ne 0 ]; then
        echo "Error occurred at: $1"
        exit 1
    fi
}

# Ensure necessary directories
ensure_directory() {
    local dir="$1"
    [ ! -d "$dir" ] && mkdir -p "$dir" && check_error "creating $dir"
    [ ! -r "$dir" ] || [ ! -w "$dir" ] && sudo chmod -R u+rw "$dir" && sudo chown -R $(whoami):$(whoami) "$dir" && check_error "setting permissions for $dir"
}

ensure_directory "$MOUNT_DIR"
ensure_directory "$BOOT_PART"
ensure_directory "$ROOTFS_PART"

# Create the SD card image
sudo dd if=/dev/zero of=$SD_IMAGE bs=1M count=2048 status=progress
check_error "creating SD image"

sudo parted $SD_IMAGE --script mklabel msdos
sudo parted $SD_IMAGE --script mkpart primary fat32 1MiB 128MiB
sudo parted $SD_IMAGE --script mkpart primary ext4 128MiB 100%
sudo parted $SD_IMAGE --script set 1 boot on
check_error "partitioning SD image"

LOOP_DEVICE=$(sudo losetup -Pf --show $SD_IMAGE)
check_error "setting up loop device"

sudo mkfs.vfat -F 32 -n boot ${LOOP_DEVICE}p1
check_error "formatting boot partition"
sudo mkfs.ext4 -L root ${LOOP_DEVICE}p2
check_error "formatting rootfs partition"

sudo mount ${LOOP_DEVICE}p1 $BOOT_PART
check_error "mounting boot partition"
sudo mount ${LOOP_DEVICE}p2 $ROOTFS_PART
check_error "mounting rootfs partition"

# Copy bootloader and kernel
sudo cp $UBOOT_DIR/u-boot.bin $BOOT_PART/
sudo cp $KERNEL_DIR/arch/arm64/boot/Image $BOOT_PART/
sudo cp $KERNEL_DIR/arch/arm64/boot/dts/broadcom/bcm2711-rpi-4-b.dtb $BOOT_PART/
check_error "copying bootloader and kernel"

# Create cmdline.txt
echo "console=ttyAMA0,115200 root=/dev/mmcblk0p2 rootfstype=ext4 fsck.repair=yes rootwait" | sudo tee "$BOOT_PART/cmdline.txt" > /dev/null
check_error "creating cmdline.txt"

# Create config.txt for QEMU
cat <<EOF | sudo tee "$BOOT_PART/config.txt" > /dev/null
arm_64bit=1
disable_kernel=1
kernel=u-boot.bin
device_tree=bcm2711-rpi-4-b.dtb
enable_uart=1
EOF
check_error "creating config.txt"

# Set up root filesystem
sudo mkdir -p $ROOTFS_PART/{lib,etc,tmp,proc,sys,dev,home,lib64,run,usr/{bin,lib,sbin},var/log}
sudo rsync -a $OUTPUT_DIR/ $ROOTFS_PART/
check_error "setting up root filesystem"

# Handle modules if available
if [ -d "$MODULES_DIR" ]; then
    sudo mkdir -p $ROOTFS_PART/lib/modules
    sudo cp -r $MODULES_DIR/* $ROOTFS_PART/lib/modules/
    check_error "copying kernel modules"
fi

# Create device nodes
sudo mknod -m 666 $ROOTFS_PART/dev/null c 1 3
sudo mknod -m 600 $ROOTFS_PART/dev/console c 5 1
sudo chmod 600 $ROOTFS_PART/dev/console
sudo chown root:root $ROOTFS_PART/dev/console
check_error "creating device nodes"

# Unmount and clean up
sudo umount $BOOT_PART
sudo umount $ROOTFS_PART
sudo losetup -d $LOOP_DEVICE
check_error "cleaning up"

echo "SD card image for QEMU with BusyBox is ready!"
