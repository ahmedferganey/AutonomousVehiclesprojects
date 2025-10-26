#!/bin/bash
################################################################################
# Yocto Build Environment Setup Script
# 
# This script:
# 1. Initializes git submodules for all meta layers
# 2. Copies configuration files to the build directory
# 3. Creates necessary directories
# 4. Sets up the build environment
################################################################################

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "=================================================="
echo "  Yocto Build Environment Setup"
echo "=================================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Step 1: Initialize submodules
echo -e "${YELLOW}Step 1: Initializing Git submodules...${NC}"
cd "$PROJECT_ROOT"

if [ -f ".gitmodules" ]; then
    git submodule init
    git submodule update --recursive --progress
    echo -e "${GREEN}✓ Submodules initialized${NC}"
else
    echo -e "${RED}⚠ No .gitmodules file found${NC}"
    echo "  You need to add submodules first. See instructions below."
fi

# Step 2: Create build directory structure
echo ""
echo -e "${YELLOW}Step 2: Creating build directory structure...${NC}"
mkdir -p "$SCRIPT_DIR/Yocto_sources/poky/building/conf"
echo -e "${GREEN}✓ Directories created${NC}"

# Step 3: Copy configuration files
echo ""
echo -e "${YELLOW}Step 3: Copying configuration files...${NC}"

if [ -f "$SCRIPT_DIR/configs/local.conf" ]; then
    cp "$SCRIPT_DIR/configs/local.conf" "$SCRIPT_DIR/Yocto_sources/poky/building/conf/"
    echo -e "${GREEN}✓ local.conf copied${NC}"
else
    echo -e "${RED}⚠ configs/local.conf not found${NC}"
fi

if [ -f "$SCRIPT_DIR/configs/bblayers.conf" ]; then
    cp "$SCRIPT_DIR/configs/bblayers.conf" "$SCRIPT_DIR/Yocto_sources/poky/building/conf/"
    echo -e "${GREEN}✓ bblayers.conf copied${NC}"
else
    echo -e "${RED}⚠ configs/bblayers.conf not found${NC}"
fi

# Step 4: Setup complete
echo ""
echo -e "${GREEN}=================================================="
echo "  Setup Complete!"
echo "==================================================${NC}"
echo ""
echo "To start building:"
echo "  cd $SCRIPT_DIR/Yocto_sources/poky"
echo "  source oe-init-build-env building"
echo "  bitbake <your-image-name>"
echo ""

# Check if submodules were added
if [ ! -f "$PROJECT_ROOT/.gitmodules" ]; then
    echo -e "${YELLOW}=================================================="
    echo "  Submodules Not Configured Yet"
    echo "==================================================${NC}"
    echo ""
    echo "You need to add the Yocto meta layers as submodules:"
    echo ""
    echo "  cd $PROJECT_ROOT"
    echo "  git submodule add -b kirkstone https://git.yoctoproject.org/poky AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/poky"
    echo "  git submodule add -b kirkstone https://github.com/openembedded/meta-openembedded.git AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/meta-openembedded"
    echo "  git submodule add -b kirkstone https://github.com/agherzan/meta-raspberrypi.git AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/meta-raspberrypi"
    echo "  # Add other layers as needed..."
    echo ""
    echo "Then run this script again: ./setup_yocto.sh"
    echo ""
fi

