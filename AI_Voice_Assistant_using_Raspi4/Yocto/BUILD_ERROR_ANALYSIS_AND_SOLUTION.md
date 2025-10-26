# Yocto Build Error Analysis and Solution Plan

**Date**: February 11, 2025  
**Build Command**: `bitbake core-image-base -c populate_sdk`  
**Target**: Raspberry Pi 4 (aarch64)  
**Environment**: `/media/ferganey/00_Embedded/Building`

---

## Executive Summary

The build encountered **4 critical errors** when attempting to generate the SDK:
1. **onnxruntime_1.20.1** - Compilation failure
2. **python3-tensorflow-lite_2.18.0** - Compilation failure
3. **opencv_4.11.0** - Missing numpy headers
4. **libtensorflow-lite_2.18.0** - CMake configuration failure (missing absl::absl_check target)

**Root Cause**: Dependency conflicts between machine learning libraries and missing/incompatible NumPy headers.

---

## Error Analysis Process

### Step 1: Identify All Failed Tasks

```bash
# From the error log, identify failed tasks:
bitbake-layers show-appends | grep -E "(onnxruntime|tensorflow|opencv)"
```

**Failed Tasks**:
- `onnxruntime_1.20.1.bb:do_compile`
- `python3-tensorflow-lite_2.18.0.bb:do_compile`
- `opencv_4.11.0.bb:do_compile`
- `libtensorflow-lite_2.18.0.bb:do_configure`

### Step 2: Examine Build Logs

```bash
# Navigate to error logs
cd /media/ferganey/00_Embedded/Building

# For each failed task, examine the log:
cat tmp/work/cortexa72-poky-linux/onnxruntime/1.20.1-r0/temp/log.do_compile | tail -100
cat tmp/work/cortexa72-poky-linux/opencv/4.11.0-r0/temp/log.do_compile | tail -100
cat tmp/work/cortexa72-poky-linux/libtensorflow-lite/2.18.0-r0/temp/log.do_configure | tail -100
```

### Step 3: Root Cause Analysis

#### Error 1: OpenCV - NumPy Headers Missing
```
fatal error: numpy/ndarrayobject.h: No such file or directory
```

**Problem**: OpenCV's Python bindings cannot find NumPy header files during compilation.

**Root Cause**: 
- NumPy was built for target (`python3-numpy-native`), but headers are not in the expected location
- Incorrect include path: `/usr/lib/python3.10/site-packages/numpy/_core/include` instead of standard NumPy headers

#### Error 2: TensorFlow Lite - Missing ABSEIL Target
```
Target "libprotobuf-lite" links to:
  absl::absl_check
but the target was not found.
```

**Problem**: Protobuf is trying to link against ABSEIL library, but the CMake target doesn't exist in the build environment.

**Root Cause**:
- ABSEIL library version mismatch
- CMake configuration for protobuf expects newer ABSEIL
- Missing or incorrect ABSEIL dependency declaration

#### Error 3: ONNXRuntime & Python TensorFlow - Cascading Failures
- Depend on OpenCV and TensorFlow Lite
- Fail due to upstream dependency issues

---

## Solution Plan

### Phase 1: Immediate Fixes (Priority: Critical)

#### Solution 1.1: Fix OpenCV NumPy Dependency

**Approach A: Patch OpenCV Recipe** (Recommended)

Create a bbappend file to fix the NumPy include paths:

```bash
# Create directory structure
mkdir -p meta-userapp/recipes-support/opencv
```

Create file: `meta-userapp/recipes-support/opencv/opencv_4.11.0.bbappend`

```bitbake
# Fix numpy include path for OpenCV Python bindings
EXTRA_OECONF:append:pn-opencv = " \
    -DPYTHON3_NUMPY_INCLUDE_DIRS:PATH=${STAGING_LIBDIR}/${PYTHON_DIR}/site-packages/numpy/core/include \
    -DCMAKE_PYTHON3_INCLUDE_DIR=${STAGING_INCDIR}/${PYTHON_DIR}${PYTHON_ABI} \
"

# Ensure numpy is properly installed before OpenCV
DEPENDS:append:pn-opencv = " python3-numpy-native"
```

**Approach B: Remove Python3 from OpenCV** (Quick workaround)

If Python bindings are not needed:

```bitbake
# In local.conf or opencv bbappend
PACKAGECONFIG:remove:pn-opencv = " python3"
```

#### Solution 1.2: Fix ABSEIL-TensorFlow Lite Dependency

**Create bbappend for TensorFlow Lite**:

File: `meta-userapp/recipes-framework/tensorflow-lite/libtensorflow-lite_2.18.0.bbappend`

```bitbake
# Fix ABSEIL dependency issue
DEPENDS += " abseil-cpp-native"
DEPENDS:append = " abseil-cpp"

# Disable problematic features
PACKAGECONFIG:remove = " xnnpack_neon_fp16"

# Add workaround for protobuf linking
EXTRA_OECMAKE:append = " \
    -Dtflite_ENABLE_XNNPACK=OFF \
    -DTFLITE_BUILD_WITH_GPU_DELEGATE=OFF \
    -Dtflite_ENABLE_GPU=OFF \
"
```

#### Solution 1.3: Temporary ML Library Exclusion (Quick Fix)

For Phase 2 GUI development (Qt6), ML libraries may not be immediately needed:

**Modify `local.conf`**:

```bitbake
# Temporarily exclude problematic ML libraries
IMAGE_INSTALL:remove = " python3-tensorflow-lite libtensorflow-lite onnxruntime"

# Keep OpenCV but without Python bindings
PACKAGECONFIG:remove:pn-opencv = " python3"
```

### Phase 2: Long-term Solutions

#### Solution 2.1: Update Layer Priorities

```bash
# Check layer priorities
bitbake-layers show-layers

# Ensure meta-userapp has higher priority
vim conf/bblayers.conf
```

#### Solution 2.2: Use Specific Package Versions

Update `local.conf` to pin compatible versions:

```bitbake
# Pin specific versions for compatibility
PREFERRED_VERSION_opencv = "4.8.%"
PREFERRED_VERSION_numpy = "1.24.0"
PREFERRED_VERSION_abseil-cpp = "20230125.1"
```

#### Solution 2.3: Separate ML Build

Create a separate machine configuration for ML features:

```bash
# Create new machine config
mkdir -p meta-userapp/conf/machine
cp conf/machine/raspberrypi4-64.conf meta-userapp/conf/machine/raspberrypi4-64-ml.conf

# Modify the new config to include ML features conditionally
```

---

## Immediate Action Plan

### Step 1: Quick Fix for Phase 2 GUI Development

Since the goal is to start Phase 2 (GUI development with Qt6), ML libraries can be temporarily disabled:

```bash
# Navigate to build directory
cd /media/ferganey/00_Embedded/Building
source ~/Projects/Yocto/Yocto_sources/poky/oe-init-build-env .

# Edit local.conf
vim conf/local.conf

# Add these lines at the end:
PACKAGECONFIG:remove:pn-opencv = " python3"
IMAGE_INSTALL:remove = " python3-tensorflow-lite libtensorflow-lite onnxruntime"

# Save and rebuild
bitbake core-image-base -c populate_sdk
```

**Expected Result**: Build completes without ML libraries, enabling Qt6 SDK generation for GUI development.

### Step 2: Build SDK for Qt6 Development

```bash
# Generate SDK
bitbake core-image-base -c populate_sdk

# Install SDK
cd tmp/deploy/sdk
./poky-glibc-x86_64-core-image-base-cortexa72-poky-linux-armv8-toolchain-*.sh
```

### Step 3: Configure Qt Creator

```bash
# After SDK installation, configure Qt Creator:
# 1. Tools > Options > Kits > Add
# 2. Set compiler to SDK's g++
# 3. Set Qt version to SDK's Qt6 installation
# 4. Configure build paths
```

### Step 4: Address ML Libraries (Later)

Once GUI is functional, return to ML library integration:

1. Update ABSEIL-CPP to latest version
2. Patch TensorFlow Lite for proper ABSEIL linking
3. Fix OpenCV NumPy include paths
4. Rebuild entire image with ML support

---

## Testing Plan

### Test 1: SDK Functionality
```bash
# After SDK installation
source /opt/poky/*/environment-setup-cortexa72-poky-linux

# Test compiler
$CC --version
$CXX --version

# Test Qt6
qmake6 --version
pkg-config --modversion Qt6Core
```

### Test 2: Simple Qt6 Application
```bash
# Create test application
mkdir test_app && cd test_app
cat > main.cpp << 'EOF'
#include <QApplication>
#include <QLabel>
int main(int argc, char *argv[]) {
    QApplication app(argc, argv);
    QLabel label("Qt6 Works!");
    label.show();
    return app.exec();
}
EOF

# Build
qmake6 -project
qmake6
make

# Verify cross-compilation
file test_app
```

### Test 3: Deployment
```bash
# Copy to Raspberry Pi 4
scp test_app root@raspberrypi:/home/root/

# Execute on target
ssh root@raspberrypi ./test_app
```

---

## Monitoring and Debugging

### Useful Commands for Debugging

```bash
# Check dependency tree
bitbake -g core-image-base

# View package dependencies
bitbake-graph tool

# Check configuration
bitbake -e opencv | grep ^EXTRA_OECONF

# Clean specific package
bitbake -c cleansstate opencv
bitbake -c clean tensorflow-lite

# Rebuild with verbose output
bitbake opencv -v

# Check recipe variables
bitbake -e opencv | grep ^DEPENDS
bitbake -e opencv | grep ^RDEPENDS
```

### Log Analysis

```bash
# View detailed error logs
tail -f tmp/work/*/opencv/*/temp/log.do_compile
tail -f tmp/work/*/tensorflow-lite/*/temp/log.do_configure

# Search for specific errors
grep -r "numpy/ndarrayobject.h" tmp/log/
grep -r "absl_check" tmp/log/
```

---

## Risk Assessment

| Solution | Risk Level | Impact | Effort |
|----------|-----------|---------|---------|
| Remove ML libraries | Low | Can't use ML features | 5 min |
| Patch NumPy paths | Medium | May affect other packages | 1 hour |
| Fix ABSEIL linking | High | Complex dependency resolution | 2-3 hours |
| Downgrade versions | Medium | May lose new features | 1 hour |

**Recommendation**: Implement Phase 1 - Quick Fix first to unblock GUI development, then address ML libraries incrementally.

---

## Success Criteria

- [ ] SDK builds successfully
- [ ] Qt Creator can configure project with SDK
- [ ] Test Qt6 application compiles
- [ ] Test application runs on Raspberry Pi 4
- [ ] GUI development can proceed
- [ ] (Later) ML libraries integrated successfully

---

## References

- Yocto Project Documentation: https://docs.yoctoproject.org
- OpenCV Build Instructions: https://docs.opencv.org/4.x/d7/d9f/tutorial_linux_install.html
- TensorFlow Lite Build: https://www.tensorflow.org/lite/guide/build_arm
- ABSEIL CMake Integration: https://abseil.io/docs/cpp/quickstart-cmake

---

**Document Version**: 1.0  
**Last Updated**: February 11, 2025  
**Status**: Active Development 