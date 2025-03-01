SUMMARY = "GStreamer 1.0 multimedia framework"
DESCRIPTION = "GStreamer is a multimedia framework for encoding and decoding video and sound. \
It supports a wide range of formats including mp3, ogg, avi, mpeg and quicktime."
HOMEPAGE = "http://gstreamer.freedesktop.org/"
BUGTRACKER = "https://bugzilla.gnome.org/enter_bug.cgi?product=Gstreamer"
SECTION = "multimedia"
LICENSE = "LGPL-2.1-or-later"

DEPENDS = "glib-2.0 glib-2.0-native libxml2 bison-native flex-native"

inherit meson pkgconfig gettext upstream-version-is-even gobject-introspection ptest-gnome

LIC_FILES_CHKSUM = "file://COPYING;md5=69333daa044cb77e486cc36129f7a770 \
                    file://gst/gst.h;beginline=1;endline=21;md5=e059138481205ee2c6fc1c079c016d0d"

S = "${WORKDIR}/gstreamer-${PV}"

SRC_URI = "https://gstreamer.freedesktop.org/src/gstreamer/gstreamer-${PV}.tar.xz \
           file://run-ptest \
           file://0001-tests-respect-the-idententaion-used-in-meson.patch;striplevel=3 \
           file://0002-tests-add-support-for-install-the-tests.patch;striplevel=3 \
           file://0003-tests-use-a-dictionaries-for-environment.patch;striplevel=3 \
           file://0004-tests-add-helper-script-to-run-the-installed_tests.patch;striplevel=3 \
           file://CVE-2024-47606.patch \
           "
SRC_URI[sha256sum] = "1757184a07b9703219e8b1961f81cb1dd64320d147fc045ac8eb499efbea79be"

PACKAGECONFIG ??= "${@bb.utils.contains('PTEST_ENABLED', '1', 'tests', '', d)} \
                   check \
                   debug \
                   tools"

PACKAGECONFIG[debug] = "-Dgst_debug=true,-Dgst_debug=false"
PACKAGECONFIG[tracer-hooks] = "-Dtracer_hooks=true,-Dtracer_hooks=false"
PACKAGECONFIG[coretracers] = "-Dcoretracers=enabled,-Dcoretracers=disabled"
PACKAGECONFIG[check] = "-Dcheck=enabled,-Dcheck=disabled"
PACKAGECONFIG[tests] = "-Dtests=enabled -Dinstalled_tests=true,-Dtests=disabled -Dinstalled_tests=false"
PACKAGECONFIG[unwind] = "-Dlibunwind=enabled,-Dlibunwind=disabled,libunwind"
PACKAGECONFIG[dw] = "-Dlibdw=enabled,-Dlibdw=disabled,elfutils"
PACKAGECONFIG[bash-completion] = "-Dbash-completion=enabled,-Dbash-completion=disabled,bash-completion"
PACKAGECONFIG[tools] = "-Dtools=enabled,-Dtools=disabled"
PACKAGECONFIG[setcap] = "-Dptp-helper-permissions=capabilities,,libcap libcap-native"

# TODO: put this in a gettext.bbclass patch
def gettext_oemeson(d):
    if d.getVar('USE_NLS') == 'no':
        return '-Dnls=disabled'
    # Remove the NLS bits if USE_NLS is no or INHIBIT_DEFAULT_DEPS is set
    if d.getVar('INHIBIT_DEFAULT_DEPS') and not oe.utils.inherits(d, 'cross-canadian'):
        return '-Dnls=disabled'
    return '-Dnls=enabled'

EXTRA_OEMESON += " \
    -Ddoc=disabled \
    -Dexamples=disabled \
    -Ddbghelp=disabled \
    ${@gettext_oemeson(d)} \
"

GIR_MESON_ENABLE_FLAG = "enabled"
GIR_MESON_DISABLE_FLAG = "disabled"

PACKAGES += "${PN}-bash-completion"

# Add the core element plugins to the main package
FILES:${PN} += "${libdir}/gstreamer-1.0/*.so"
FILES:${PN}-dev += "${libdir}/gstreamer-1.0/*.a ${libdir}/gstreamer-1.0/include"
FILES:${PN}-bash-completion += "${datadir}/bash-completion/completions/ ${datadir}/bash-completion/helpers/gst*"
FILES:${PN}-dbg += "${datadir}/gdb ${datadir}/gstreamer-1.0/gdb"

CVE_PRODUCT = "gstreamer"

# these CVEs are patched in gstreamer1.0-plugins-bad
CVE_CHECK_IGNORE += "CVE-2023-40474 CVE-2023-40475 CVE-2023-40476 CVE-2023-44429 CVE-2023-44446 CVE-2023-50186 CVE-2024-0444"
# these CVEs are patched in gstreamer1.0-plugins-base
CVE_CHECK_IGNORE += "CVE-2024-47538 CVE-2024-47541 CVE-2024-47542 CVE-2024-47600 CVE-2024-47607 CVE-2024-47615 CVE-2024-47835"
# these CVEs are patched in gstreamer1.0-plugins-good
CVE_CHECK_IGNORE += " \
    CVE-2024-47537 CVE-2024-47539 CVE-2024-47540 CVE-2024-47543 CVE-2024-47544 CVE-2024-47545 \
    CVE-2024-47546 CVE-2024-47596 CVE-2024-47597 CVE-2024-47598 CVE-2024-47599 CVE-2024-47601 \
    CVE-2024-47602 CVE-2024-47603 CVE-2024-47613 CVE-2024-47774 CVE-2024-47775 CVE-2024-47776 \
    CVE-2024-47777 CVE-2024-47778 CVE-2024-47834 \
"

PTEST_BUILD_HOST_FILES = ""
