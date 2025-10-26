SUMMARY = "Network Configuration Service for wlan0"
DESCRIPTION = "This recipe configures and manages the network interface for wlan0"
LICENSE = "CLOSED"
inherit systemd


FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://wpa_supplicant.conf \
    file://dhcpcd.service \
"

SYSTEMD_AUTO_ENABLE = "enable"
# SYSTEMD_SERVICE:${PN}:append = " wpa_supplicant-wlan0.service  "
SYSTEMD_SERVICE_${PN} = "dhcpcd.service"

do_install() {
    # Create necessary directories
    install -d ${D}${sysconfdir}/systemd/system/
    install -d ${D}${sysconfdir}/wpa_supplicant/

    # Install the dhcpcd service
    install -m 0644 ${WORKDIR}/dhcpcd.service ${D}${sysconfdir}/systemd/system/
    
    # Enable the service to start on boot
    install -d ${D}${sysconfdir}/systemd/system/multi-user.target.wants/
    ln -sf ${sysconfdir}/systemd/system/dhcpcd.service ${D}${sysconfdir}/systemd/system/multi-user.target.wants/

    # Install wpa_supplicant.conf
    install -m 0644 ${WORKDIR}/wpa_supplicant.conf ${D}${sysconfdir}/wpa_supplicant/
}

do_postinst() {
    # Start dhcpcd service after installation (if you want immediate effect)
    systemctl start dhcpcd.service || true
}

# Ensure dhcpcd gets installed if not already
RDEPENDS_${PN} += " dhcpcd wpa-supplicant coreutils util-linux"
