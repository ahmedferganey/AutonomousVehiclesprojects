FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# Ensure GStreamer detects OpenCV correctly
DEPENDS:append = " opencv opencv-contrib"

# Force meson to find OpenCV
EXTRA_OEMESON += "-Dopencv=enabled"

# Ensure OpenCV support is explicitly enabled
PACKAGECONFIG:append = " vaapi opencv"

# Ensure correct linking and debugging logs
do_configure:append() {
    export CFLAGS="-I${STAGING_INCDIR}/opencv4"
    export LDFLAGS="${STAGING_LIBDIR}/libopencv_objdetect.so"

    # Print meson logs for debugging if issues persist
    cat ${B}/meson-logs/meson-log.txt || true
}

