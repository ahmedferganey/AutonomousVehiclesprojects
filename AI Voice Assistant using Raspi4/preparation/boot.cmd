fatload mmc 0:1 ${kernel_addr_r} /Image
fatload mmc 0:1 ${fdt_addr} /bcm2711-rpi-4-b.dtb
fatload mmc 0:1 ${ramdisk_addr_r} /uRamdisk.img
setenv bootargs "console=serial0,115200 console=tty1  root=/dev/mmcblk0p2 rw  rootwait init=/bin/sh"
booti ${kernel_addr_r} ${ramdisk_addr_r} ${fdt_addr}



