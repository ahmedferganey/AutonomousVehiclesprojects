SUMMARY = "Seamless operability between C++11 and Python"
HOMEPAGE = "https://github.com/wjakob/pybind11"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://LICENSE;md5=774f65abd8a7fe3124be2cdf766cd06f"

DEPENDS = "boost"

SRC_URI = "git://github.com/pybind/pybind11.git;branch=master;protocol=https \
           file://0001-Do-not-strip-binaries.patch \
           file://0001-Do-not-check-pointer-size-when-cross-compiling.patch \
"
SRCREV = "f7b499615e14d70ab098a20deb0cdb3889998a1a"

S = "${WORKDIR}/git"

BBCLASSEXTEND = "native"

EXTRA_OECMAKE =  "-DPYBIND11_TEST=OFF"

inherit cmake setuptools3 python3native

PIP_INSTALL_DIST_PATH = "${S}/dist"
PIP_INSTALL_PACKAGE = "pybind11"

do_configure() {
	cmake_do_configure
}

do_compile() {
	setuptools3_do_compile
	cmake_do_compile
}

do_install() {
	setuptools3_do_install
	cmake_do_install
}

BBCLASSEXTEND = "native nativesdk"
