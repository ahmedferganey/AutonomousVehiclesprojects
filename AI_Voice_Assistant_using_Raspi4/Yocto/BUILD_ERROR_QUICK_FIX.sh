#!/bin/bash
# Quick Fix Script for Yocto Build Errors
# Date: October 25, 2025 (Updated)
# Purpose: Temporarily disable ML libraries to unblock Phase 2 GUI development

echo "=================================================="
echo "Yocto Build Error Quick Fix Script"
echo "Updated for current directory structure"
echo "=================================================="
echo ""

# Detect current directory and set build directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
YOCTO_SOURCES_DIR="$SCRIPT_DIR/Yocto_sources"
BUILD_DIR="$YOCTO_SOURCES_DIR/poky/building"
POKY_DIR="$YOCTO_SOURCES_DIR/poky"

echo "Script directory: $SCRIPT_DIR"
echo "Yocto sources: $YOCTO_SOURCES_DIR"
echo "Build directory: $BUILD_DIR"
echo "Poky directory: $POKY_DIR"
echo ""

# Check if build directory exists
if [ ! -d "$BUILD_DIR" ]; then
    echo "ERROR: Build directory not found: $BUILD_DIR"
    echo ""
    echo "Please ensure the directory structure is:"
    echo "  Yocto/"
    echo "    └── Yocto_sources/"
    echo "        └── poky/"
    echo "            └── building/"
    exit 1
fi

cd "$BUILD_DIR"

# Backup original local.conf
if [ ! -f "conf/local.conf.backup_$(date +%Y%m%d)" ]; then
    echo "Creating backup of local.conf..."
    cp conf/local.conf "conf/local.conf.backup_$(date +%Y%m%d)"
    echo "Backup created: conf/local.conf.backup_$(date +%Y%m%d)"
else
    echo "Backup already exists for today, skipping..."
fi

echo ""
echo "Checking current configuration..."
echo ""

# Check if fixes are already applied
if grep -q "TEMPORARILY DISABLED: TensorFlow Lite" conf/local.conf; then
    echo "✓ Fixes are already applied to local.conf"
    echo "✓ OpenCV Python bindings: DISABLED"
    echo "✓ TensorFlow Lite: DISABLED"
    echo "✓ ONNXRuntime: DISABLED"
    echo ""
    echo "Your configuration is ready for building!"
else
    echo "⚠ Fixes not found in local.conf"
    echo ""
    echo "Manual fix required:"
    echo "1. Open: $BUILD_DIR/conf/local.conf"
    echo "2. Comment out the following lines:"
    echo "   - PACKAGECONFIG:append:pn-opencv = \" python3\""
    echo "   - IMAGE_INSTALL += \" python3-tensorflow-lite libtensorflow-lite\""
    echo "   - IMAGE_INSTALL += \" onnxruntime flatbuffers\""
    echo ""
    echo "Or apply the remove statements at the end of the file:"
    echo "   IMAGE_INSTALL:remove = \" python3-tensorflow-lite libtensorflow-lite onnxruntime\""
    echo "   PACKAGECONFIG:remove:pn-opencv = \" python3\""
fi

echo ""
echo "=================================================="
echo "Next steps:"
echo "=================================================="
echo ""
echo "1. Source the environment:"
echo "   cd $POKY_DIR"
echo "   source oe-init-build-env $BUILD_DIR"
echo ""
echo "2. Build the SDK:"
echo "   bitbake core-image-base -c populate_sdk"
echo ""
echo "3. Install the SDK when build completes:"
echo "   cd tmp/deploy/sdk"
echo "   ./poky-glibc-x86_64-core-image-base-*.sh"
echo ""
echo "To restore original configuration:"
echo "  cp conf/local.conf.backup_$(date +%Y%m%d) conf/local.conf"
echo ""
echo "=================================================="
