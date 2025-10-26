#!/bin/bash
################################################################################
# Finish Submodules Setup - Add Remaining Layers
################################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}════════════════════════════════════════${NC}"
echo -e "${CYAN}  Finishing Submodules Setup${NC}"
echo -e "${CYAN}════════════════════════════════════════${NC}"
echo ""

cd "$PROJECT_ROOT"

# Remove the failed meta-qt6
echo "Removing failed meta-qt6..."
rm -rf AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/meta-qt6

# Add meta-qt6 with correct branch (6.2 for kirkstone compatibility)
echo -e "${CYAN}→ Adding meta-qt6 (branch: 6.2)...${NC}"
git submodule add -b 6.2 \
    https://github.com/YoeDistro/meta-qt6.git \
    AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/meta-qt6
echo -e "${GREEN}  ✓ Added${NC}"
echo ""

# Add meta-docker (using master branch)
echo -e "${CYAN}→ Adding meta-docker (branch: master)...${NC}"
git submodule add -b master \
    https://github.com/L4B-Software/meta-docker.git \
    AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/meta-docker
echo -e "${GREEN}  ✓ Added${NC}"
echo ""

# Add meta-virtualization
echo -e "${CYAN}→ Adding meta-virtualization (branch: kirkstone)...${NC}"
git submodule add -b kirkstone \
    https://git.yoctoproject.org/meta-virtualization \
    AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/meta-virtualization
echo -e "${GREEN}  ✓ Added${NC}"
echo ""

# Initialize all submodules
echo -e "${CYAN}Initializing and updating submodules...${NC}"
git submodule init
git submodule update --recursive --progress
echo -e "${GREEN}✓ Submodules initialized${NC}"
echo ""

# Show status
echo "Submodule status:"
git submodule status
echo ""

# Copy config files
echo -e "${CYAN}Setting up build environment...${NC}"
mkdir -p AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/poky/building/conf
cp AI_Voice_Assistant_using_Raspi4/Yocto/configs/local.conf \
   AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/poky/building/conf/
cp AI_Voice_Assistant_using_Raspi4/Yocto/configs/bblayers.conf \
   AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/poky/building/conf/
echo -e "${GREEN}✓ Configuration files copied${NC}"
echo ""

# Commit
echo -e "${CYAN}Committing submodules...${NC}"
git add .gitmodules AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/
git commit -m "Convert Yocto layers to git submodules

Modified layers (personal forks with custom modifications):
- poky → github.com/ahmedferganey/poky @ kirkstone-voiceassistant
- meta-openembedded → github.com/ahmedferganey/meta-openembedded @ kirkstone-voiceassistant
- meta-raspberrypi → github.com/ahmedferganey/meta-raspberrypi @ kirkstone-voiceassistant
- meta-onnxruntime → github.com/ahmedferganey/meta-onnxruntime @ main
- meta-tensorflow-lite → github.com/ahmedferganey/meta-tensorflow-lite @ main

Clean layers (upstream):
- meta-qt6 → github.com/YoeDistro/meta-qt6 @ 6.2
- meta-docker → github.com/L4B-Software/meta-docker @ master
- meta-virtualization → git.yoctoproject.org/meta-virtualization @ kirkstone

Original Yocto_sources preserved as: Yocto_sources_BACKUP_*"

echo -e "${GREEN}✓ Committed${NC}"
echo ""

echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}  ✓ Setup Complete!${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""
echo "Next steps:"
echo "  1. Test build: cd Yocto_sources/poky && source oe-init-build-env building"
echo "  2. Push to GitHub: git push origin main"
echo "  3. Delete backup: rm -rf Yocto_sources_BACKUP_*"
echo ""
echo -e "${GREEN}Done! 🎉${NC}"

