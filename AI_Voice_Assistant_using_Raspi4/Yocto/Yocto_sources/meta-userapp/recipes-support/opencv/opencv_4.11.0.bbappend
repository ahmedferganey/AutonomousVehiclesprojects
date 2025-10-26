#SRC_URI += "git://github.com/opencv/opencv.git;name=opencv;branch=4.5.5;protocol=https \
#       	    git://github.com/opencv/opencv_contrib.git;destsuffix=git/contrib;name=contrib;branch=4.5.5;protocol=https \
#       	    git://github.com/opencv/opencv_3rdparty.git;branch=ippicv/master_20240904;destsuffix=git/ipp;name=ipp;protocol=https \
#"


EXTRA_OECMAKE += " \
    -DPYTHON3_EXECUTABLE=${STAGING_BINDIR_NATIVE}/python3-native/python3 \
    -DPYTHON3_INCLUDE_DIR=${STAGING_INCDIR}/${PYTHON_DIR}${PYTHON_ABI} \
    -DPYTHON3_NUMPY_INCLUDE_DIR=${STAGING_LIBDIR}/${PYTHON_DIR}/site-packages/numpy/core/include \
"



CMAKE_VERBOSE = "VERBOSE=1"

# Build time dependency
DEPENDS += "python3-native python3-setuptools-native python3-numpy-native python3-numpy"

# Runtime dependency
RDEPENDS:${PN} += " \
    python3-numpy \
    python3-cryptography \
    python3-smbus \
    python3-psutil \
"

