#!/bin/bash


########################################################################################
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
# Unmount any existing mounts related to mmcblk0
existing_mounts=$(findmnt -ln | grep mmcblk0 | awk '{print $1}')
for mount in $existing_mounts; do
    sudo umount "$mount"
    check_error "unmounting $mount"
done
ensure_directory() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        echo "$dir does not exist. Creating it..."
        mkdir -p "$dir"
        check_error "creating $dir"
    fi
}

########################################################################################
MOUNT_DIR="/mnt"
BOOT_PART="$MOUNT_DIR/boot"
ROOTFS_PART="$MOUNT_DIR/root"

echo "Unmounting existing partitions..."
sudo umount /mnt/root 2>/dev/null
sudo umount /mnt/boot 2>/dev/null
ensure_directory "$MOUNT_DIR"
ensure_directory "$BOOT_PART"
ensure_directory "$ROOTFS_PART"

SD_IMAGE=/dev/mmcblk0
if [ -z "$SD_IMAGE" ]; then
    echo "Error: No SD card detected. Please ensure it is connected and try again."
    exit 1
fi
echo "SD card detected: $SD_IMAGE"

mount /dev/mmcblk0p1 /mnt/boot
mount /dev/mmcblk0p2 /mnt/root

########################################################################################
UBOOT_DIR="/home/ferganey/Embedded_Systems/other_resources/practical/embedded-linux-labs/bootloader/u-boot"
RPi_REPO="/home/ferganey/Embedded_Systems/Autonomous_Vhehicle_GradProject/rpirepo"
BOOT_SCR_PATH="/home/ferganey/Embedded_Systems/Autonomous_Vhehicle_GradProject"
KERNEL_DIR="/home/ferganey/Embedded_Systems/other_resources/practical/embedded-linux-labs/kernel/Raspi_Linux/linux"

# Copy bootloader files
echo "Copying bootloader files..."
cp $RPi_REPO/{bootcode.bin,start4.elf,fixup4.dat} $BOOT_PART/
cp "$BOOT_SCR_PATH/boot.scr" $BOOT_PART/
chmod 644 $BOOT_PART/boot.scr
touch "$BOOT_PART/uboot.env"

cat <<EOF | tee "$BOOT_PART/config.txt" > /dev/null
enable_uart=1
kernel=u-boot.bin
arm_64bit=1
dtoverlay=disable-bt
dtoverlay=uart0
gpu_mem=512
force_turbo=1
avoid_warnings=1
EOF

cp $KERNEL_DIR/arch/arm64/boot/Image $BOOT_PART/
cp $KERNEL_DIR/arch/arm64/boot/dts/broadcom/bcm2711-rpi-4-b.dtb $BOOT_PART/
cp $UBOOT_DIR/u-boot.bin $BOOT_PART/
cp /home/ferganey/Embedded_Systems/Autonomous_Vhehicle_GradProject/uRamdisk.img $BOOT_PART/

########################################################################################
BUSYBOX_DIR="/home/ferganey/Embedded_Systems/busybox"
OUTPUT_DIR="/home/ferganey/Embedded_Systems/busybox/output/minimal_root"
MODULES_DIR="/home/ferganey/Embedded_Systems/other_resources/practical/Rpi4/lib/modules/5.15.92-v8+"


mkdir -p ${ROOTFS_PART}/{bin,lib64,rootfs/{bin,lib,lib64,sbin,usr},sbin,usr/{bin,lib,sbin},home,media,mnt,opt,proc,var,sys,tmp,dev}

# 1. bin contain busybox binary
cp -a ${OUTPUT_DIR}/bin/*  ${ROOTFS_PART}/bin/

# 2. lib64 contains shared libraries, it is empty case static busybox

# 3. rootfs
## 3.1 rootfs/ {lib64 ,lib} contain shared libraries, it is empty case static busybox

## 3.2 rootfs/ bin --> Contains BusyBox binaries, statically linked binaries (busybox)
cp -a ${OUTPUT_DIR}/bin/* ${ROOTFS_PART}/rootfs/bin/
## 3.3 rootfs/ sbin contains essential system binaries {ifconfig, insmod, modprobe, reboot...}
cp -a ${OUTPUT_DIR}/sbin/* ${ROOTFS_PART}/rootfs/sbin/
## 3.4 rootfs/ usr/ contains {/bin, /sbin, /lib64} lib64 here not needed
cp -a ${OUTPUT_DIR}/usr/bin  ${ROOTFS_PART}/rootfs/usr/
cp -a ${OUTPUT_DIR}/usr/sbin  ${ROOTFS_PART}/rootfs/usr/


# ln -s ${ROOTFS_PART}/bin/busybox ${ROOTFS_PART}/rootfs/linuxrc
sudo ln -s bin/busybox ${ROOTFS_PART}/rootfs/linuxrc

chmod -R 755 ${ROOTFS_PART}/rootfs
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


# 4. sbin contains essential system binaries {ifconfig, insmod, modprobe, reboot...}
cp -a ${OUTPUT_DIR}/sbin/* ${ROOTFS_PART}/sbin/


# 5. usr/ contains {/bin, /sbin, /lib} lib64 here not needed
[ -d "$MODULES_DIR" ] && sudo mkdir -p $ROOTFS_PART/usr/lib/modules/5.15.92-v8+ && sudo cp -r $MODULES_DIR/* $ROOTFS_PART/usr/lib/modules/5.15.92-v8+ 
sudo rm $ROOTFS_PART/usr/lib/modules/5.15.92-v8+/build
sudo rm $ROOTFS_PART/usr/lib/modules/5.15.92-v8+/source
cp -a ${OUTPUT_DIR}/sbin/* ${ROOTFS_PART}/usr/sbin/
cp -a ${OUTPUT_DIR}/bin/* ${ROOTFS_PART}/usr/bin/

# Set ownership for root directory and all subdirectories in rootfs
echo "Setting ownership for rootfs..."
sudo chown -R root:root $ROOTFS_PART
sudo chown -R root:root $ROOTFS_PART/rootfs

# 6. other directories
mknod -m 666 $ROOTFS_PART/dev/null c 1 3
mknod -m 600 $ROOTFS_PART/dev/console c 5 1
chmod 600 $ROOTFS_PART/dev/console
sudo chown root:root $ROOTFS_PART/dev/console
sudo chown -R root:root $ROOTFS_PART/home

chmod 1777 $ROOTFS_PART/tmp
mknod -m 666 $ROOTFS_PART/dev/ttyS0 c 4 64
mknod -m 666 $ROOTFS_PART/dev/ttyAMA0 c 204 64
chmod 666 $ROOTFS_PART/dev/ttyS0
chmod 666 $ROOTFS_PART/dev/ttyAMA0
sudo chown root:root $ROOTFS_PART/dev/ttyS0
sudo chown root:root $ROOTFS_PART/dev/ttyAMA0


[ ! -f "$BOOT_PART/bootcode.bin" ] && echo "Error: bootcode.bin is missing in boot partition"
ls -ld $ROOTFS_PART/dev/console $ROOTFS_PART/dev/null



umount /dev/mmcblk0p1
umount /dev/mmcblk0p2

