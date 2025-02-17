FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://wpa_supplicant.conf \
    file://wpa_supplicant-wlan0.service \
"

SYSTEMD_AUTO_ENABLE = "enable"
SYSTEMD_SERVICE:${PN}:append = " wpa_supplicant-wlan0.service "

do_install:append () {
    
   # Install wpa_supplicant configuration
   install -d ${D}${sysconfdir}/wpa_supplicant/
   install -m 0644 ${WORKDIR}/wpa_supplicant.conf ${D}${sysconfdir}/wpa_supplicant/


   # Install custom systemd service file
   install -d ${D}${systemd_system_unitdir}
   install -m 644 ${WORKDIR}/wpa_supplicant-wlan0.service ${D}${systemd_system_unitdir}/


   # Ensure multi-user target wants directory
   install -d ${D}${sysconfdir}/systemd/system/multi-user.target.wants/
    
   
   # Link to enable the service
   ln -sf ${systemd_system_unitdir}/wpa_supplicant-wlan0.service \
	${D}${sysconfdir}/systemd/system/multi-user.target.wants/wpa_supplicant-wlan0.service
}



