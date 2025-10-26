SUMMARY = "Recipe to create user 'ferganey' and group 'netdev'"
DESCRIPTION = "This recipe creates a user 'ferganey' and a group 'netdev'."
LICENSE = "CLOSED"

inherit useradd

# Define the packages that require user and group creation
USERADD_PACKAGES = "${PN}"

# Parameters for user and group creation
USERADD_PARAM:${PN} = "-g netdev -d /home/ferganey -m -s /bin/bash ferganey"

# Parameters for group creation
GROUPADD_PARAM:${PN} = "-g 1007 netdev"

# Add root to the netdev group
EXTRA_USERS_PARAMS = "usermod -a -G netdev root"

# Ensure runtime dependencies for user and group tools
RDEPENDS:${PN} += "base-passwd shadow bash"

# Define the directory and files to be installed
do_install() {
    # Create the necessary directories
    install -d -m 755 ${D}${datadir}/ferganey
}

# Ensure files are included in the package
FILES:${PN} += "${datadir}/ferganey"


