#!/bin/bash
################################################################################
# Interactive Submodules Setup - Complete Implementation
# 
# This script will:
# 1. Guide you to create GitHub forks
# 2. Push your modifications to the forks
# 3. Remove old directories
# 4. Add proper git submodules
# 5. Commit and push everything
################################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
YOCTO_SOURCES="$SCRIPT_DIR/Yocto_sources"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

GITHUB_USERNAME="ahmedferganey"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║    Complete Git Submodules Setup - Implementation         ║${NC}"
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo ""
echo -e "${CYAN}This will convert your Yocto layers to git submodules${NC}"
echo -e "${CYAN}while preserving all your custom modifications.${NC}"
echo ""
echo -e "${YELLOW}GitHub Username: ${GITHUB_USERNAME}${NC}"
echo ""
read -p "Press Enter to start, or Ctrl+C to abort..."
echo ""

cd "$PROJECT_ROOT"

################################################################################
# STEP 1: Create GitHub Repositories
################################################################################

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  STEP 1: Create GitHub Repositories (Forks)${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""
echo "You need to create forks for the modified layers."
echo ""
echo -e "${YELLOW}Open these URLs and click 'Fork':${NC}"
echo ""
echo "1. https://github.com/yoctoproject/poky"
echo "   → Fork to: https://github.com/${GITHUB_USERNAME}/poky"
echo ""
echo "2. https://github.com/openembedded/meta-openembedded"
echo "   → Fork to: https://github.com/${GITHUB_USERNAME}/meta-openembedded"
echo ""
echo "3. https://github.com/agherzan/meta-raspberrypi"
echo "   → Fork to: https://github.com/${GITHUB_USERNAME}/meta-raspberrypi"
echo ""
echo "4. https://github.com/NobuoTsukamoto/meta-onnxruntime"
echo "   → Fork to: https://github.com/${GITHUB_USERNAME}/meta-onnxruntime"
echo ""
echo "5. https://github.com/NobuoTsukamoto/meta-tensorflow-lite"
echo "   → Fork to: https://github.com/${GITHUB_USERNAME}/meta-tensorflow-lite"
echo ""
echo -e "${CYAN}Note: When forking, uncheck 'Copy the main branch only'${NC}"
echo -e "${CYAN}      to ensure all branches are forked.${NC}"
echo ""
read -p "Press Enter when ALL forks are created..."
echo ""

################################################################################
# STEP 2: Push Modifications to Forks
################################################################################

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  STEP 2: Push Your Modifications to Forks${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

# Function to push layer
push_layer() {
    local layer_name="$1"
    local fork_url="$2"
    local branch="$3"
    local layer_path="$YOCTO_SOURCES/$layer_name"
    
    echo -e "${CYAN}→ Processing $layer_name...${NC}"
    
    if [ ! -d "$layer_path" ]; then
        echo -e "${RED}✗ Directory not found: $layer_path${NC}"
        return 1
    fi
    
    cd "$layer_path"
    
    # Check if it's a git repo
    if [ ! -d ".git" ]; then
        echo -e "${RED}✗ Not a git repository${NC}"
        return 1
    fi
    
    # Set remote
    echo "  Setting remote to your fork..."
    git remote remove origin 2>/dev/null || true
    git remote add origin "$fork_url"
    
    # Create and push branch
    echo "  Creating branch: $branch"
    git branch -M "$branch" 2>/dev/null || git checkout -b "$branch"
    
    echo "  Pushing to GitHub..."
    if git push -u origin "$branch" 2>&1 | tee /tmp/git_push_output.txt; then
        echo -e "${GREEN}✓ Successfully pushed $layer_name${NC}"
    else
        echo -e "${RED}✗ Failed to push $layer_name${NC}"
        echo "  Check the error above. Common issues:"
        echo "  - Repository doesn't exist on GitHub yet"
        echo "  - Wrong credentials"
        echo "  - Permission denied"
        echo ""
        read -p "  Fix the issue and press Enter to retry, or Ctrl+C to abort..."
        git push -u origin "$branch"
    fi
    
    cd "$PROJECT_ROOT"
    echo ""
}

# Push all modified layers
push_layer "poky" \
    "https://github.com/${GITHUB_USERNAME}/poky.git" \
    "kirkstone-voiceassistant"

push_layer "meta-openembedded" \
    "https://github.com/${GITHUB_USERNAME}/meta-openembedded.git" \
    "kirkstone-voiceassistant"

push_layer "meta-raspberrypi" \
    "https://github.com/${GITHUB_USERNAME}/meta-raspberrypi.git" \
    "kirkstone-voiceassistant"

push_layer "meta-onnxruntime" \
    "https://github.com/${GITHUB_USERNAME}/meta-onnxruntime.git" \
    "main"

push_layer "meta-tensorflow-lite" \
    "https://github.com/${GITHUB_USERNAME}/meta-tensorflow-lite.git" \
    "main"

echo -e "${GREEN}✓ All modifications pushed to your GitHub forks!${NC}"
echo ""
read -p "Press Enter to continue..."
echo ""

################################################################################
# STEP 3: Backup and Remove Yocto_sources
################################################################################

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  STEP 3: Backup and Remove Yocto_sources${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

BACKUP_DIR="/tmp/yocto_sources_backup_$(date +%Y%m%d_%H%M%S)"
echo "Creating backup at: $BACKUP_DIR"
cp -r "$YOCTO_SOURCES" "$BACKUP_DIR"
echo -e "${GREEN}✓ Backup created${NC}"
echo ""

echo "Removing Yocto_sources directory..."
rm -rf "$YOCTO_SOURCES"
echo -e "${GREEN}✓ Removed${NC}"
echo ""

################################################################################
# STEP 4: Add Submodules
################################################################################

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  STEP 4: Add Git Submodules${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

cd "$PROJECT_ROOT"

# Function to add submodule
add_submodule() {
    local name="$1"
    local url="$2"
    local branch="$3"
    local path="AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/$name"
    
    echo -e "${CYAN}→ Adding $name as submodule...${NC}"
    
    if git submodule add -b "$branch" "$url" "$path" 2>&1; then
        echo -e "${GREEN}✓ $name added${NC}"
    else
        echo -e "${RED}✗ Failed to add $name${NC}"
        echo "  This might be because:"
        echo "  - Repository doesn't exist"
        echo "  - Branch doesn't exist"
        echo "  - Network issue"
        return 1
    fi
    echo ""
}

echo "Adding modified layers (your forks)..."
echo ""

add_submodule "poky" \
    "https://github.com/${GITHUB_USERNAME}/poky.git" \
    "kirkstone-voiceassistant"

add_submodule "meta-openembedded" \
    "https://github.com/${GITHUB_USERNAME}/meta-openembedded.git" \
    "kirkstone-voiceassistant"

add_submodule "meta-raspberrypi" \
    "https://github.com/${GITHUB_USERNAME}/meta-raspberrypi.git" \
    "kirkstone-voiceassistant"

add_submodule "meta-onnxruntime" \
    "https://github.com/${GITHUB_USERNAME}/meta-onnxruntime.git" \
    "main"

add_submodule "meta-tensorflow-lite" \
    "https://github.com/${GITHUB_USERNAME}/meta-tensorflow-lite.git" \
    "main"

echo "Adding clean layers (upstream repositories)..."
echo ""

add_submodule "meta-qt6" \
    "https://github.com/YoeDistro/meta-qt6.git" \
    "kirkstone"

add_submodule "meta-docker" \
    "https://github.com/L4B-Software/meta-docker.git" \
    "master"

add_submodule "meta-virtualization" \
    "https://git.yoctoproject.org/meta-virtualization" \
    "kirkstone"

echo -e "${GREEN}✓ All submodules added!${NC}"
echo ""

################################################################################
# STEP 5: Initialize Submodules
################################################################################

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  STEP 5: Initialize Submodules${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

echo "Initializing and updating submodules..."
git submodule init
git submodule update --recursive --progress

echo -e "${GREEN}✓ Submodules initialized${NC}"
echo ""

################################################################################
# STEP 6: Show Status
################################################################################

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  STEP 6: Verify Submodules${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

echo "Submodule status:"
git submodule status
echo ""

echo "Checking Yocto_sources structure:"
ls -la AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/
echo ""

################################################################################
# STEP 7: Commit Changes
################################################################################

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  STEP 7: Commit Submodule Configuration${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

echo "Staging changes..."
git add .gitmodules AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/

echo ""
echo "Committing..."
git commit -m "Convert Yocto layers to git submodules

Modified layers (personal forks with custom modifications):
- poky → github.com/${GITHUB_USERNAME}/poky @ kirkstone-voiceassistant
- meta-openembedded → github.com/${GITHUB_USERNAME}/meta-openembedded @ kirkstone-voiceassistant
- meta-raspberrypi → github.com/${GITHUB_USERNAME}/meta-raspberrypi @ kirkstone-voiceassistant
- meta-onnxruntime → github.com/${GITHUB_USERNAME}/meta-onnxruntime @ main
- meta-tensorflow-lite → github.com/${GITHUB_USERNAME}/meta-tensorflow-lite @ main

Clean layers (upstream):
- meta-qt6 → github.com/YoeDistro/meta-qt6.git @ kirkstone
- meta-docker → github.com/L4B-Software/meta-docker.git @ master
- meta-virtualization → git.yoctoproject.org/meta-virtualization @ kirkstone

All modifications preserved in personal forks.
Submodules track specific commits for reproducible builds."

echo -e "${GREEN}✓ Changes committed${NC}"
echo ""

################################################################################
# STEP 8: Setup Build Environment
################################################################################

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  STEP 8: Setup Build Environment${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

cd "$SCRIPT_DIR"
if [ -f "setup_yocto.sh" ]; then
    echo "Running setup_yocto.sh..."
    ./setup_yocto.sh
else
    echo "Copying configuration files manually..."
    mkdir -p Yocto_sources/poky/building/conf
    cp configs/local.conf Yocto_sources/poky/building/conf/
    cp configs/bblayers.conf Yocto_sources/poky/building/conf/
    echo -e "${GREEN}✓ Configuration files copied${NC}"
fi

echo ""

################################################################################
# COMPLETION
################################################################################

echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              Setup Complete! ✓                             ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}Summary:${NC}"
echo "  ✓ All modifications pushed to your GitHub forks"
echo "  ✓ Git submodules configured and initialized"
echo "  ✓ Build environment ready"
echo "  ✓ Backup created at: $BACKUP_DIR"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo ""
echo "1. Review git status:"
echo "   git status"
echo ""
echo "2. Push to GitHub:"
echo "   git push origin main"
echo ""
echo "3. To build:"
echo "   cd Yocto_sources/poky"
echo "   source oe-init-build-env building"
echo "   bitbake your-image-name"
echo ""
echo -e "${CYAN}For others to clone with submodules:${NC}"
echo "   git clone --recurse-submodules https://github.com/${GITHUB_USERNAME}/AutonomousVehiclesprojects.git"
echo ""
echo -e "${GREEN}Done! 🎉${NC}"

