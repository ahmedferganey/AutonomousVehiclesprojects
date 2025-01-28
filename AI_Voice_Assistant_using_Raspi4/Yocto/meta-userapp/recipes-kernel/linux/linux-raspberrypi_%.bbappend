FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"


SRC_URI += "file://wifi-sysfs.cfg"


do_configure:append() {
    echo "Appending wifi-sysfs.cfg to .config"
    cat ${WORKDIR}/wifi-sysfs.cfg >> ${B}/.config
}

