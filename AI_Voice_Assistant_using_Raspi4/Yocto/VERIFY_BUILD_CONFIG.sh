#!/bin/bash
# Verification Script for Yocto Build Configuration
# Date: October 25, 2025
# Purpose: Verify that all build error fixes are properly applied

echo "=========================================================="
echo "  Yocto Build Configuration Verification Script"
echo "=========================================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
PASS=0
FAIL=0
WARN=0

# Detect current directory and set build directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
YOCTO_SOURCES_DIR="$SCRIPT_DIR/Yocto_sources"
BUILD_DIR="$YOCTO_SOURCES_DIR/poky/building"
LOCAL_CONF="$BUILD_DIR/conf/local.conf"
BBLAYERS_CONF="$BUILD_DIR/conf/bblayers.conf"

echo "Configuration Details:"
echo "  Script directory: $SCRIPT_DIR"
echo "  Build directory:  $BUILD_DIR"
echo "  local.conf:       $LOCAL_CONF"
echo ""

# Check if build directory exists
if [ ! -d "$BUILD_DIR" ]; then
    echo -e "${RED}✗ FAIL${NC}: Build directory not found: $BUILD_DIR"
    exit 1
fi

echo "=========================================================="
echo "  Running Verification Checks"
echo "=========================================================="
echo ""

# Test 1: Check if local.conf exists
echo -n "Test 1: local.conf exists..................... "
if [ -f "$LOCAL_CONF" ]; then
    echo -e "${GREEN}✓ PASS${NC}"
    ((PASS++))
else
    echo -e "${RED}✗ FAIL${NC}"
    ((FAIL++))
    exit 1
fi

# Test 2: Check if backup exists
echo -n "Test 2: Backup file exists.................... "
if ls "$BUILD_DIR/conf/local.conf.backup"* 1> /dev/null 2>&1; then
    echo -e "${GREEN}✓ PASS${NC}"
    ((PASS++))
else
    echo -e "${YELLOW}⚠ WARN${NC}: No backup found (run script to create)"
    ((WARN++))
fi

# Test 3: Check if OpenCV Python3 is disabled
echo -n "Test 3: OpenCV Python3 disabled............... "
if grep -q "^#PACKAGECONFIG:append:pn-opencv = \" python3\"" "$LOCAL_CONF"; then
    echo -e "${GREEN}✓ PASS${NC} (Commented out)"
    ((PASS++))
elif grep -q "^PACKAGECONFIG:append:pn-opencv = \" python3\"" "$LOCAL_CONF"; then
    echo -e "${RED}✗ FAIL${NC} (Still enabled)"
    ((FAIL++))
else
    # Check if remove statement is present
    if grep -q "PACKAGECONFIG:remove:pn-opencv = \" python3\"" "$LOCAL_CONF"; then
        echo -e "${GREEN}✓ PASS${NC} (Using remove statement)"
        ((PASS++))
    else
        echo -e "${YELLOW}⚠ WARN${NC} (Line not found)"
        ((WARN++))
    fi
fi

# Test 4: Check if TensorFlow Lite is disabled
echo -n "Test 4: TensorFlow Lite disabled.............. "
if grep -q "^#IMAGE_INSTALL += \" python3-tensorflow-lite libtensorflow-lite\"" "$LOCAL_CONF"; then
    echo -e "${GREEN}✓ PASS${NC} (Commented out)"
    ((PASS++))
elif grep -q "^IMAGE_INSTALL += \" python3-tensorflow-lite libtensorflow-lite\"" "$LOCAL_CONF"; then
    echo -e "${RED}✗ FAIL${NC} (Still enabled)"
    ((FAIL++))
else
    # Check if remove statement is present
    if grep -q "IMAGE_INSTALL:remove = .* python3-tensorflow-lite libtensorflow-lite" "$LOCAL_CONF"; then
        echo -e "${GREEN}✓ PASS${NC} (Using remove statement)"
        ((PASS++))
    else
        echo -e "${YELLOW}⚠ WARN${NC} (Line not found)"
        ((WARN++))
    fi
fi

# Test 5: Check if ONNXRuntime is disabled
echo -n "Test 5: ONNXRuntime disabled.................. "
if grep -q "^#IMAGE_INSTALL += \" onnxruntime" "$LOCAL_CONF"; then
    echo -e "${GREEN}✓ PASS${NC} (Commented out)"
    ((PASS++))
elif grep -q "^IMAGE_INSTALL += \" onnxruntime" "$LOCAL_CONF"; then
    echo -e "${RED}✗ FAIL${NC} (Still enabled)"
    ((FAIL++))
else
    # Check if remove statement is present
    if grep -q "IMAGE_INSTALL:remove = .* onnxruntime" "$LOCAL_CONF"; then
        echo -e "${GREEN}✓ PASS${NC} (Using remove statement)"
        ((PASS++))
    else
        echo -e "${YELLOW}⚠ WARN${NC} (Line not found)"
        ((WARN++))
    fi
fi

# Test 6: Check if Qt6 is enabled
echo -n "Test 6: Qt6 enabled........................... "
if grep -q "qt6" "$LOCAL_CONF"; then
    echo -e "${GREEN}✓ PASS${NC}"
    ((PASS++))
else
    echo -e "${RED}✗ FAIL${NC}"
    ((FAIL++))
fi

# Test 7: Check if OpenCV (C++) is still enabled
echo -n "Test 7: OpenCV (C++) still enabled............ "
if grep -q "^IMAGE_INSTALL += .* opencv" "$LOCAL_CONF"; then
    echo -e "${GREEN}✓ PASS${NC}"
    ((PASS++))
else
    echo -e "${YELLOW}⚠ WARN${NC}: OpenCV not found in IMAGE_INSTALL"
    ((WARN++))
fi

# Test 8: Check MACHINE setting
echo -n "Test 8: Machine set to raspberrypi4-64........ "
if grep -q "^MACHINE ??= \"raspberrypi4-64\"" "$LOCAL_CONF"; then
    echo -e "${GREEN}✓ PASS${NC}"
    ((PASS++))
else
    echo -e "${YELLOW}⚠ WARN${NC}: Different machine or format"
    ((WARN++))
fi

# Test 9: Check bblayers.conf
echo -n "Test 9: bblayers.conf exists.................. "
if [ -f "$BBLAYERS_CONF" ]; then
    echo -e "${GREEN}✓ PASS${NC}"
    ((PASS++))
else
    echo -e "${RED}✗ FAIL${NC}"
    ((FAIL++))
fi

# Test 10: Check meta-userapp layer
echo -n "Test 10: meta-userapp layer present........... "
if grep -q "meta-userapp" "$BBLAYERS_CONF"; then
    echo -e "${GREEN}✓ PASS${NC}"
    ((PASS++))
else
    echo -e "${YELLOW}⚠ WARN${NC}: meta-userapp not found in bblayers.conf"
    ((WARN++))
fi

echo ""
echo "=========================================================="
echo "  Verification Summary"
echo "=========================================================="
echo ""
echo -e "${GREEN}Passed:  $PASS${NC}"
echo -e "${YELLOW}Warnings: $WARN${NC}"
echo -e "${RED}Failed:  $FAIL${NC}"
echo ""

# Overall result
if [ $FAIL -eq 0 ]; then
    if [ $WARN -eq 0 ]; then
        echo -e "${GREEN}✓ ALL CHECKS PASSED${NC}"
        echo ""
        echo "Your configuration is ready for building!"
        echo ""
        echo "Next steps:"
        echo "  1. cd $YOCTO_SOURCES_DIR/poky"
        echo "  2. source oe-init-build-env $BUILD_DIR"
        echo "  3. bitbake core-image-base -c populate_sdk"
        EXIT_CODE=0
    else
        echo -e "${YELLOW}⚠ CHECKS PASSED WITH WARNINGS${NC}"
        echo ""
        echo "Configuration should work, but review warnings above."
        EXIT_CODE=0
    fi
else
    echo -e "${RED}✗ SOME CHECKS FAILED${NC}"
    echo ""
    echo "Please fix the errors above before building."
    echo "Run: ./BUILD_ERROR_QUICK_FIX.sh"
    EXIT_CODE=1
fi

echo ""
echo "=========================================================="

exit $EXIT_CODE

