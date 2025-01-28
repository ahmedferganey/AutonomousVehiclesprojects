SUMMARY = "Recipe to create user 'ferganey' and group 'netdev'"
DESCRIPTION = "This recipe creates a user 'ferganey' and a group 'netdev'."
LICENSE = "CLOSED"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://file1 \
           file://file2 \
           file://file3"

inherit useradd



# Define the packages that require user and group creation
USERADD_PACKAGES = "${PN}"

# Parameters for user and group creation
USERADD_PARAM:${PN} = "-g netdev -d /home/ferganey -m -s /bin/bash ferganey"

# Parameters for group creation
GROUPADD_PARAM:${PN} = "-g 1001 netdev"

# Group membership
# GROUPMEMS_PARAM:${PN} = "ferganey:netdev"
# GROUPMEMS_PARAM:${PN} = "groupmems -g netdev -a ferganey"
# Ensure runtime dependencies for user and group tools
RDEPENDS:${PN} += "base-passwd shadow bash"

# Define the directory and files to be installed
do_install() {
    # Create the necessary directories
    install -d -m 755 ${D}${datadir}/ferganey

    install -p -m 644 ${WORKDIR}/file1 ${D}${datadir}/ferganey/
    install -p -m 644 ${WORKDIR}/file2 ${D}${datadir}/ferganey/
    install -p -m 644 ${WORKDIR}/file3 ${D}${datadir}/ferganey/
    
    
    # Ensure correct ownership and group settings
    chown -R ferganey:netdev ${D}${datadir}/ferganey
    chgrp -R netdev ${D}${datadir}/ferganey
}



do_rootfs() {
    # This function will add root to the netdev group

    # Ensure the netdev group exists (if not already)
    groupadd -f netdev

    # Add root to the netdev group
    usermod -a -G netdev root
}

# Ensure 'do_rootfs' runs in the correct order
addtask do_rootfs before do_build after do_install


FILES:${PN} = "${datadir}/ferganey/*"

