SUMMARY = "A 802.1ab implementation (LLDP) to help you locate neighbors of all your equipments"
SECTION = "net/misc"
LICENSE = "ISC"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/ISC;md5=f3b90e78ea0cffb20bf5cca7947a896d"

DEPENDS = "libbsd libevent"

SRC_URI = "\
    http://media.luffy.cx/files/${BPN}/${BPN}-${PV}.tar.gz \
    file://lldpd.init.d \
    file://lldpd.default \
    file://CVE-2023-41910.patch \
    "

SRC_URI[md5sum] = "000042dbf5b445f750b5ba01ab25c8ba"
SRC_URI[sha256sum] = "98d200e76e30f6262c4a4493148c1840827898329146a57a34f8f0f928ca3def"

inherit autotools update-rc.d useradd systemd pkgconfig bash-completion

USERADD_PACKAGES = "${PN}"
USERADD_PARAM:${PN} = "--system -g lldpd --shell /bin/false lldpd"
GROUPADD_PARAM:${PN} = "--system lldpd"

EXTRA_OECONF += "--without-embedded-libevent \
                 --disable-oldies \
                 --with-privsep-user=lldpd \
                 --with-privsep-group=lldpd \
                 --with-systemdsystemunitdir=${systemd_system_unitdir} \
                 --without-sysusersdir \
"

PACKAGECONFIG ??= "cdp fdp edp sonmp lldpmed dot1 dot3"
PACKAGECONFIG[xml] = "--with-xml,--without-xml,libxm2"
PACKAGECONFIG[snmp] = "--with-snmp,--without-snmp,net-snmp"
PACKAGECONFIG[readline] = "--with-readline,--without-readline,readline"
PACKAGECONFIG[seccomp] = "--with-seccomp,--without-seccomp,libseccomp"
PACKAGECONFIG[cdp] = "--enable-cdp,--disable-cdp"
PACKAGECONFIG[fdp] = "--enable-fdp,--disable-fdp"
PACKAGECONFIG[edp] = "--enable-edp,--disable-edp"
PACKAGECONFIG[sonmp] = "--enable-sonmp,--disable-sonmp"
PACKAGECONFIG[lldpmed] = "--enable-lldpmed,--disable-lldpmed"
PACKAGECONFIG[dot1] = "--enable-dot1,--disable-dot1"
PACKAGECONFIG[dot3] = "--enable-dot3,--disable-dot3"
PACKAGECONFIG[custom] = "--enable-custom,--disable-custom"

INITSCRIPT_NAME = "lldpd"
INITSCRIPT_PARAMS = "defaults"

SYSTEMD_SERVICE:${PN} = "lldpd.service"

do_install:append() {
    install -Dm 0755 ${WORKDIR}/lldpd.init.d ${D}${sysconfdir}/init.d/lldpd
    install -Dm 0644 ${WORKDIR}/lldpd.default ${D}${sysconfdir}/default/lldpd
    # Make an empty configuration file
    touch ${D}${sysconfdir}/lldpd.conf
}

PACKAGES =+ "${PN}-zsh-completion"

FILES:${PN} += "${libdir}/sysusers.d"
RDEPENDS:${PN} += "os-release"

FILES:${PN}-zsh-completion += "${datadir}/zsh/"
# FIXME: zsh is broken in meta-oe so this cannot be enabled for now
#RDEPENDS:${PN}-zsh-completion += "zsh"
