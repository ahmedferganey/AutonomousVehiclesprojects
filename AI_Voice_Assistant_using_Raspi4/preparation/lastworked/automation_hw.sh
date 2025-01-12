#!/bin/bash

# Variables
# SD_IMAGE="sd.img"
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


############################################################################################################

# calling process  - bootcode.bin 
#                  - start4.elf  
#                  - fixup4.dat   
#                  - config.txt  
#                  - boot.scr 
#                  - u-boot.bin  
#                  - Image  
#                  - bcm2711-rpi-4-b.dtb  
#                  - overlays  
#                  - uboot.env  
#                  - busybox  
#                  - modules  
#                  - cross-toolchain


# Verify Boot Process:
##  Firmware Stage:
    ###  Ensure bootcode.bin, start4.elf, and fixup4.dat are correctly placed in the boot partition.
    ###  config.txt points to u-boot.bin as the next bootloader.

##  U-Boot Stage:
    ###  U-Boot loads the kernel (Image) and device tree (bcm2711-rpi-4-b.dtb) based on boot.scr.

##  Kernel Stage:
    ###  The kernel uses the bootargs from U-Boot or cmdline.txt to initialize the system.


## to be noted after botting first time check to set .dtb located under boot dir directly 
        ### setenv fdtfile bcm2711-rpi-4-b.dtb
        ### saveenv


############################################################################################################


# Function to check command success
check_error() {
    if [ $? -ne 0 ]; then
        echo "Error during: $1. Exiting."
        exit 1
    fi
}

# Check for required commands
REQUIRED_CMDS=(dd parted losetup mkfs.vfat mkfs.ext4 mount cp mkdir)
for cmd in "${REQUIRED_CMDS[@]}"; do
    command -v $cmd > /dev/null || { echo "$cmd not found. Please install it."; exit 1; }
done

# Ensure directory permissions
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

############################################################################################################

# Unmount existing mounts
sudo umount /media/ferganey/root
sudo umount /media/ferganey/boot
# sudo umount /dev/mmcblk0p1
# sudo umount /dev/mmcblk0p2
# Function to detect the SD card and its partitions
# detect_sd_card() {
#     # Check for the connected SD card (assuming mmcblk devices)
#     sd_card=$(lsblk -d -o NAME,TYPE,SIZE | grep 'mmcblk' | awk '{print $1}')

#     if [[ -z "$sd_card" ]]; then
#         echo "No SD card detected."
#         exit 1
#     else
#         echo "SD card detected: /dev/$sd_card"
#         partitions=$(lsblk /dev/$sd_card -o NAME | grep -E 'p[0-9]+')
#         echo "Partitions found: $partitions"
#     fi
# }

# # Function to unmount partitions
# umount_partitions() {
#     for partition in $partitions; do
#         echo "Unmounting /dev/$partition..."
#         sudo umount "/dev/$partition" 2>/dev/null
#         if [[ $? -eq 0 ]]; then
#             echo "/dev/$partition unmounted."
#         else
#             echo "/dev/$partition is not mounted or failed to unmount."
#         fi
#     done
# }

# # Function to zero out the partition data
# delete_and_zero_partition() {
#     for partition in $partitions; do
#         echo "Zeroing out /dev/$partition..."
#         sudo dd if=/dev/zero of="/dev/$partition" bs=1M status=progress
        
#         echo "Data wiped and partition zeroed: /dev/$partition"
#     done
# }

# # Main script execution
# detect_sd_card && \
# umount_partitions && \
# delete_and_zero_partition

# echo "All data on the SD card has been deleted and zeroed out."


############################################################################################################

# Ensure permissions for required directories
ensure_directory "$MOUNT_DIR"
ensure_directory "$BOOT_PART"
ensure_directory "$ROOTFS_PART"

# Create virtual SD card image
# echo "Creating SD card image..."
# sudo dd if=/dev/zero of=$SD_IMAGE bs=1M count=16384 status=progress
# check_error "creating SD card image"

# Detect the SD card device (physical SD card)
echo "Detecting physical SD card device..."
# Identify the SD card device based on size (assuming a 16GB card for this example)
    ## SD_IMAGE=$(lsblk -o NAME,SIZE | grep -E '.*16G.*' | awk '{print "/dev/" $1}')
    ## SD_IMAGE=$(lsblk -o NAME,SIZE,TYPE,MOUNTPOINT | grep -E '.*disk' | grep -v "loop" | awk '{print "/dev/" $1}')
SD_IMAGE=$(lsblk -o NAME,TYPE,SIZE | grep -E '^mmcblk[0-9]+.*disk' | awk '{print "/dev/" $1}')

if [ -z "$SD_IMAGE" ]; then
    echo "Error: No 64GB SD card detected. Please ensure it is connected and try again."
    exit 1
fi
echo "Physical SD card device detected: $SD_IMAGE"



# Step 4: Cleanup, Partition, and Format the SD Card
echo "Cleaning SD card..."
sudo wipefs -a "$SD_IMAGE"

if [[ $? -ne 0 ]]; then
    echo "Failed to clean the SD card. Ensure the device is not in use and try again."
    exit 1
fi

# Partition the SD card
echo "Partitioning the SD card..."

# Create a new partition table (msdos type)
if ! sudo parted $SD_IMAGE --script mklabel msdos; then
    echo "Error: Failed to create partition table."
    exit 1  
fi
echo "Partition table created successfully."

# Create the first partition (FAT32, 1MiB to 256MiB)
if ! sudo parted $SD_IMAGE --script mkpart primary fat32 1MiB 256MiB; then
    echo "Error: Failed to create boot partition."
    exit 1
fi
echo "Boot partition created successfully."

# Create the second partition (ext4, 256MiB to end of the SD card)
if ! sudo parted $SD_IMAGE --script mkpart primary ext4 256MiB 100%; then
    echo "Error: Failed to create root partition."
    exit 1
fi
echo "Root partition created successfully."

# Set the boot flag on the first partition
if ! sudo parted $SD_IMAGE --script set 1 boot on; then
    echo "Error: Failed to set boot flag on the boot partition."
    exit 1
fi
echo "Boot flag set successfully."

# # Map the SD card image to loop devices
# echo "Mapping SD card image to loop devices..."
# LOOP_DEVICE=$(sudo losetup -Pf --show $SD_IMAGE)
# check_error "mapping SD card image"
# echo "Mapped to $LOOP_DEVICE"

# # Check if LOOP_DEVICE is valid
# if [ -z "$LOOP_DEVICE" ]; then
#     echo "Error: Failed to map SD card image to loop device."
#     exit 1
# fi

# Format the partitions
echo "Formatting partitions..."
sudo mkfs.vfat -F 32 -n boot ${SD_IMAGE}p1
check_error "formatting boot partition"
sudo mkfs.ext4 -L root ${SD_IMAGE}p2
check_error "formatting root partition"

# Mount the partitions
echo "Mounting partitions..."
sudo mount ${SD_IMAGE}p1 $BOOT_PART
check_error "mounting boot partition"
sudo mount ${SD_IMAGE}p2 $ROOTFS_PART
check_error "mounting root partition"

# Verify mounts
echo "Verifying mounts..."
findmnt -M $BOOT_PART > /dev/null || { echo "$BOOT_PART is not mounted."; exit 1; }
findmnt -M $ROOTFS_PART > /dev/null || { echo "$ROOTFS_PART is not mounted."; exit 1; }

############################################################################################################

# Copy boot files
# https://github.com/raspberrypi/firmware/tree/stable/boot
echo "Copying boot files..."
sudo cp $RPi_REPO/{bootcode.bin,start4.elf,fixup4.dat} $BOOT_PART/
check_error "copying boot files"

############################################################################################################


# Copy bootscr to boot partition
echo "Copying bootscr..."
if [ -f "$BOOT_SCR_PATH/boot.scr" ]; then
    sudo chmod 644 "$BOOT_SCR_PATH/boot.scr"
    check_error "setting permissions on bootscr"
    sudo cp "$BOOT_SCR_PATH/boot.scr" $BOOT_PART/
    # Ensure the file on the boot partition has the correct permissions (644)
    sudo chmod 644 $BOOT_PART/boot.scr
    check_error "setting permissions on copied bootscr"

    echo "bootscr copied and permissions set successfully."
else
    echo "Error: bootscr file not found at $BOOT_SCR_PATH."
    exit 1
fi

############################################################################################################

# # Create cmdline.txt
# echo "Creating cmdline.txt..."
# echo "console=serial0,115200 root=/dev/mmcblk0p2 rootfstype=ext4 fsck.repair=yes rootwait earlyprintk=serial,ttyAMA0,115200" | sudo tee "$BOOT_PART/cmdline.txt" > /dev/null
# check_error "creating cmdline.txt"
# # This option is used for outputting the boot messages to the first serial port (ttyS0), which could be connected to a serial terminal or a serial debug console.


# # Create uboot.env
echo "Creating uboot.env..."
# Create an empty uboot.env file
sudo touch "$BOOT_PART/uboot.env"
# Check if the file was created successfully
check_error "creating empty uboot.env"


# Create config.txt
# Create config.txt
# https://www.raspberrypi.com/documentation/computers/config_txt.html#boot-options
# https://www.raspberrypi.com/documentation/computers/legacy_config_txt.html
echo "Creating config.txt..."
cat <<EOF | sudo tee "$BOOT_PART/config.txt" > /dev/null
enable_uart=1
kernel=u-boot.bin
arm_64bit=1
dtoverlay=disable-bt
dtoverlay=uart0
force_turbo=1
avoid_warnings=1
EOF
check_error "creating config.txt"


############################################################################################################

# Copy kernel, device tree, U-Boot files, and overlays
echo "Copying kernel, U-Boot, device tree files..."
sudo cp $KERNEL_DIR/arch/arm64/boot/Image $BOOT_PART/
sudo mkdir  -p $BOOT_PART/broadcom
sudo cp $KERNEL_DIR/arch/arm64/boot/dts/broadcom/bcm2711-rpi-4-b.dtb $BOOT_PART/broadcom
sudo cp $UBOOT_DIR/u-boot.bin $BOOT_PART/

# Ensure kernel and U-Boot files were copied successfully
if [ -f "$BOOT_PART/u-boot.bin" ] && [ -f "$BOOT_PART/Image" ]; then
    echo "U-Boot and Kernel images were copied successfully."
else
    echo "Error: U-Boot or Kernel images were not copied."
    exit 1
fi

# # Copy overlays
# echo "Copying overlays..."
#     # Ensure the target directory exists
# sudo mkdir -p $BOOT_PART/overlays
#     # Copy the overlays using rsync, and suppress ownership and group errors
# sudo rsync -av --copy-links --no-owner --no-group $KERNEL_DIR/arch/arm64/boot/dts/overlays/*.dtb* $BOOT_PART/overlays/
#     # Check if the rsync command was successful
# if [ $? -eq 0 ]; then
#     echo "Overlays copied successfully."
# else
#     echo "Error: Failed to copy overlays."
# fi

############################################################################################################


# Set up root filesystem
echo "Setting up root filesystem..."
sudo mkdir -p $ROOTFS_PART/{lib,etc,tmp,proc,sys,dev,home,lib64,run,usr/{bin,lib,sbin,include},var/log}
sudo rsync -a $OUTPUT_DIR/ $ROOTFS_PART/
check_error "setting up root filesystem"
# Check if BusyBox was copied successfully
if [ -f "$ROOTFS_PART/bin/busybox" ]; then
    echo "BusyBox was copied successfully via --install -s"
else
    echo "Error: BusyBox was not copied."
    exit 1
fi

# Copy shared libraries if needed
STATIC_CHECK=$(file $BUSYBOX_DIR/output/minimal_root/bin/busybox | grep "statically linked")
if [ -z "$STATIC_CHECK" ]; then
    # Copy shared libraries (if BusyBox is dynamically linked):
    echo "Copying shared libraries..."
    SYSROOT=$(aarch64-rpi4-linux-gnu-gcc -print-sysroot)
    sudo cp -rL ${SYSROOT}/lib/* $ROOTFS_PART/lib/
    sudo cp -rL ${SYSROOT}/lib64/* s$ROOTFS_PART/lib64/
    sudo cp -rL ${SYSROOT}/usr/lib/* $ROOTFS_PART/usr/lib/
    check_error "copying shared libraries"
else
    echo "BusyBox is statically linked. Skipping shared libraries."
fi


if [ -z "$STATIC_CHECK" ]; then
    # If BusyBox is dynamically linked, copy toolchain libraries
    echo "Copying cross-toolchain libraries..."
    # this line if you use busy box as static linked {Static linking means that all 
    #   necessary libraries are bundled into the BusyBox binary itself. Therefore, there is no need 
    #   to copy the shared libraries from the toolchain}
    sudo cp -r /home/ferganey/x-tools/aarch64-rpi4-linux-gnu/lib/* $ROOTFS_PART/usr/lib/
    check_error "copying cross-toolchain libraries"
else
    # If BusyBox is statically linked, skip copying toolchain libraries
    echo "BusyBox is statically linked. Skipping cross-toolchain libraries."
fi

# Copy optional binaries
echo "copying cross-toolchain binaries..."
sudo cp -r /home/ferganey/x-tools/aarch64-rpi4-linux-gnu/bin/* $ROOTFS_PART/usr/bin/
sudo cp -r /home/ferganey/x-tools/aarch64-rpi4-linux-gnu/include/* $ROOTFS_PART/usr/include/
check_error "copying cross-toolchain binaries"

############################################################################################################


# Copy kernel modules if directory exists
if [ -d "$MODULES_DIR" ]; then
    echo "Copying kernel modules..."
    sudo mkdir -p $ROOTFS_PART/lib/modules
    sudo cp -r $MODULES_DIR/* $ROOTFS_PART/lib/modules/
    # Check if kernel modules were copied
    if [ -d "$ROOTFS_PART/lib/modules" ]; then
        echo "Kernel modules were copied successfully."
    else
        echo "Error: Kernel modules were not copied."
        exit 1
    fi
fi

############################################################################################################

# Final setup
echo "Creating device nodes for /dev/null and /dev/console..."
sudo mknod -m 666 $ROOTFS_PART/dev/null c 1 3
sudo mknod -m 600 $ROOTFS_PART/dev/console c 5 1
check_error "creating /dev/null and /dev/console device nodes"

# Set ownership and permissions for console
echo "Setting ownership and permissions for /dev/console..."
sudo chmod 600 $ROOTFS_PART/dev/console
sudo chown root:root $ROOTFS_PART/dev/console
check_error "setting ownership and permissions for /dev/console"



# Set correct ownership for home directory
echo "Setting ownership for home directory..."
sudo chown -R root:root $ROOTFS_PART/home
check_error "setting ownership for home directory"






# Ensure read-write permissions for specific directories in rootfs
echo "Ensuring secure permissions for directories in root filesystem..."

# Set restrictive permissions on sensitive directories
# sudo chmod 700 $ROOTFS_PART/root      # root directory
sudo chmod 755 $ROOTFS_PART/bin       # executable files in bin
sudo chmod 755 $ROOTFS_PART/sbin      # executable files in sbin
sudo chmod 755 $ROOTFS_PART/etc       # configuration files
sudo chmod 755 $ROOTFS_PART/usr       # user binaries
sudo chmod 755 $ROOTFS_PART/lib       # libraries
sudo chmod 755 $ROOTFS_PART/lib64     # 64-bit libraries
sudo chmod 1777 $ROOTFS_PART/tmp      # world-writable directory (tmp)

# Ensure proper read/write/execute permissions for others
sudo chmod 755 $ROOTFS_PART/home      # Home directory should be accessible
sudo chmod 755 $ROOTFS_PART/var       # Variable data (logs, etc.)
sudo chmod 755 $ROOTFS_PART/dev       # Device files

check_error "setting secure permissions for rootfs directories"




# Create additional device nodes
echo "Creating device nodes for serial devices (/dev/ttyS0, /dev/ttyAMA0)..."
sudo mknod -m 666 $ROOTFS_PART/dev/ttyS0 c 4 64
sudo mknod -m 666 $ROOTFS_PART/dev/ttyAMA0 c 204 64
check_error "creating additional device nodes for serial devices"

# Set ownership and permissions for serial devices
echo "Setting permissions and ownership for serial devices..."
sudo chmod 666 $ROOTFS_PART/dev/ttyS0
sudo chmod 666 $ROOTFS_PART/dev/ttyAMA0
sudo chown root:root $ROOTFS_PART/dev/ttyS0
sudo chown root:root $ROOTFS_PART/dev/ttyAMA0
check_error "setting permissions and ownership for serial devices"


############################################################################################################


# Unmount if mounted
if mount | grep $SD_IMAGE > /dev/null; then
    echo "Unmounting SD card partitions..."
    sync
    sudo umount ${SD_IMAGE}p1
    sudo umount ${SD_IMAGE}p2
    echo "SD card partitions unmounted."
else
    echo "SD card partitions are not mounted."
fi


# # Detach the loop device
# echo "Detaching loop device..."
# LOOP_DEVICE=$(losetup | grep $SD_IMAGE | awk '{print $1}')
# if [ -n "$LOOP_DEVICE" ]; then
#     sudo losetup -d $LOOP_DEVICE
#     check_error "detaching loop device"
# else
#     echo "No loop device associated with $SD_IMAGE"
# fi

echo "SD card setup completed successfully and cleaned up.for Raspberry Pi 4B!"

