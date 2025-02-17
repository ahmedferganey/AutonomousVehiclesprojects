LINUX_VERSION ?= "6.6.2"
LINUX_RPI_BRANCH ?= "rpi-6.6.y"
LINUX_RPI_KMETA_BRANCH ?= "yocto-6.6"

SRCREV_machine = "8a08b4ad6dbd48a826b3052e52a4fdc88c3ac36e"
SRCREV_meta = "078f986aa4c328285abd0181cc21724d832a3ae0"

KMETA = "kernel-meta"
S = "${WORKDIR}/1_6.6.2+gitAUTOINC+078f986aa4-r0/linux-rpi-6.6.y"
#S = "${WORKDIR}/git"


# Modify SRC_URI to use the downloaded tarball instead of git
SRC_URI = " \
    file:///media/ferganey/00_Embedded/Building/downloads/rpi-6.6.y.tar.gz \
    git://git.yoctoproject.org/yocto-kernel-cache;type=kmeta;name=meta;branch=${LINUX_RPI_KMETA_BRANCH};destsuffix=${KMETA} \
    "

require linux-raspberrypicustom.inc

KERNEL_DTC_FLAGS += "-@ -H epapr"

