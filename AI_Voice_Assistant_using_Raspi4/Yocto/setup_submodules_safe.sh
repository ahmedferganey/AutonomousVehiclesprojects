#!/bin/bash
################################################################################
# SAFE Submodules Setup - Keeps Original as Backup
# 
# This version:
# 1. Pushes modifications to your forks
# 2. RENAMES (not removes) Yocto_sources to Yocto_sources_backup
# 3. Adds fresh submodules
# 4. You keep the original for comparison/safety
################################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
YOCTO_SOURCES="$SCRIPT_DIR/Yocto_sources"
BACKUP_NAME="Yocto_sources_BACKUP_$(date +%Y%m%d_%H%M%S)"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

GITHUB_USERNAME="ahmedferganey"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║    SAFE Git Submodules Setup (Keeps Backup)               ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}✓ This version KEEPS your original Yocto_sources${NC}"
echo -e "${GREEN}✓ Original will be renamed to: $BACKUP_NAME${NC}"
echo -e "${GREEN}✓ You can compare or restore if needed${NC}"
echo ""
read -p "Press Enter to start, or Ctrl+C to abort..."
echo ""

cd "$PROJECT_ROOT"

################################################################################
# STEP 1: Verify Forks Exist
################################################################################

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  STEP 1: Verify GitHub Forks${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""
echo "Please confirm you have created these forks:"
echo ""
echo "  1. https://github.com/${GITHUB_USERNAME}/poky"
echo "  2. https://github.com/${GITHUB_USERNAME}/meta-openembedded"
echo "  3. https://github.com/${GITHUB_USERNAME}/meta-raspberrypi"
echo "  4. https://github.com/${GITHUB_USERNAME}/meta-onnxruntime"
echo "  5. https://github.com/${GITHUB_USERNAME}/meta-tensorflow-lite"
echo ""
read -p "Have you created ALL 5 forks? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo ""
    echo -e "${RED}Please create the forks first!${NC}"
    echo "See: FORK_THESE_REPOS.md for instructions"
    exit 1
fi

echo -e "${GREEN}✓ Confirmed${NC}"
echo ""

################################################################################
# STEP 2: Push Modifications to Forks
################################################################################

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  STEP 2: Push Your Modifications to Forks${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

push_layer() {
    local layer_name="$1"
    local fork_url="$2"
    local branch="$3"
    local layer_path="$YOCTO_SOURCES/$layer_name"
    
    echo -e "${CYAN}→ Processing $layer_name...${NC}"
    
    if [ ! -d "$layer_path/.git" ]; then
        echo -e "${YELLOW}  ⚠ Not a git repo, skipping${NC}"
        return 0
    fi
    
    cd "$layer_path"
    
    # Check if there are commits to push
    if [ $(git rev-list --count HEAD) -eq 0 ]; then
        echo -e "${YELLOW}  ⚠ No commits, skipping${NC}"
        return 0
    fi
    
    echo "  Setting remote..."
    git remote remove origin 2>/dev/null || true
    git remote add origin "$fork_url"
    
    echo "  Creating branch: $branch"
    current_branch=$(git branch --show-current)
    if [ "$current_branch" != "$branch" ]; then
        git branch -M "$branch" 2>/dev/null || git checkout -b "$branch"
    fi
    
    echo "  Pushing to GitHub..."
    if git push -u origin "$branch" 2>&1; then
        echo -e "${GREEN}  ✓ Pushed successfully${NC}"
    else
        echo -e "${RED}  ✗ Push failed${NC}"
        echo ""
        echo "  Common issues:"
        echo "  - Repository doesn't exist on GitHub"
        echo "  - Authentication failed"
        echo "  - Network issue"
        echo ""
        read -p "  Press Enter to retry, or Ctrl+C to abort..."
        git push -u origin "$branch"
    fi
    
    cd "$PROJECT_ROOT"
    echo ""
}

echo "Pushing modified layers..."
echo ""

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

echo -e "${GREEN}✓ All modifications pushed to GitHub!${NC}"
echo ""

################################################################################
# STEP 3: Rename (Not Remove!) Yocto_sources
################################################################################

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  STEP 3: Rename Yocto_sources (Keep as Backup)${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

if [ -d "$YOCTO_SOURCES" ]; then
    echo "Renaming: Yocto_sources → $BACKUP_NAME"
    mv "$YOCTO_SOURCES" "$SCRIPT_DIR/$BACKUP_NAME"
    echo -e "${GREEN}✓ Renamed (original preserved)${NC}"
    echo -e "${CYAN}  Location: $SCRIPT_DIR/$BACKUP_NAME${NC}"
else
    echo -e "${YELLOW}⚠ Yocto_sources doesn't exist${NC}"
fi

echo ""
echo -e "${YELLOW}NOTE: Your original Yocto_sources is SAFE in $BACKUP_NAME${NC}"
echo -e "${YELLOW}      You can delete it later after verifying submodules work${NC}"
echo ""
read -p "Press Enter to continue..."
echo ""

################################################################################
# STEP 4: Add Submodules
################################################################################

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  STEP 4: Add Git Submodules${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

cd "$PROJECT_ROOT"

add_submodule() {
    local name="$1"
    local url="$2"
    local branch="$3"
    local path="AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/$name"
    
    echo -e "${CYAN}→ Adding $name...${NC}"
    
    if git submodule add -b "$branch" "$url" "$path" 2>&1; then
        echo -e "${GREEN}  ✓ Added${NC}"
    else
        echo -e "${RED}  ✗ Failed${NC}"
        return 1
    fi
    echo ""
}

echo "Adding your forks (modified layers)..."
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

echo "Adding upstream (clean layers)..."
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

git submodule init
git submodule update --recursive --progress

echo -e "${GREEN}✓ Submodules initialized${NC}"
echo ""

################################################################################
# STEP 6: Verify
################################################################################

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  STEP 6: Verify Setup${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

echo "Submodule status:"
git submodule status
echo ""

echo "Directory structure:"
ls -la AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/ | head -15
echo ""

################################################################################
# STEP 7: Setup Build Environment
################################################################################

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  STEP 7: Setup Build Environment${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

cd "$SCRIPT_DIR"
echo "Copying configuration files..."
mkdir -p Yocto_sources/poky/building/conf
cp configs/local.conf Yocto_sources/poky/building/conf/
cp configs/bblayers.conf Yocto_sources/poky/building/conf/
echo -e "${GREEN}✓ Build environment ready${NC}"
echo ""

################################################################################
# STEP 8: Commit
################################################################################

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  STEP 8: Commit Submodules${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

cd "$PROJECT_ROOT"
git add .gitmodules AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/

git commit -m "Convert Yocto layers to git submodules

Modified layers (personal forks):
- poky → github.com/${GITHUB_USERNAME}/poky @ kirkstone-voiceassistant
- meta-openembedded → github.com/${GITHUB_USERNAME}/meta-openembedded @ kirkstone-voiceassistant
- meta-raspberrypi → github.com/${GITHUB_USERNAME}/meta-raspberrypi @ kirkstone-voiceassistant
- meta-onnxruntime → github.com/${GITHUB_USERNAME}/meta-onnxruntime @ main
- meta-tensorflow-lite → github.com/${GITHUB_USERNAME}/meta-tensorflow-lite @ main

Clean layers (upstream):
- meta-qt6 → github.com/YoeDistro/meta-qt6 @ kirkstone
- meta-docker → github.com/L4B-Software/meta-docker @ master
- meta-virtualization → git.yoctoproject.org/meta-virtualization @ kirkstone

Original Yocto_sources preserved as: $BACKUP_NAME"

echo -e "${GREEN}✓ Committed${NC}"
echo ""

################################################################################
# COMPLETION
################################################################################

echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              ✓ SAFE Setup Complete!                       ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}✓ Your original Yocto_sources is SAFE${NC}"
echo -e "${CYAN}  Location: $SCRIPT_DIR/$BACKUP_NAME${NC}"
echo ""
echo -e "${YELLOW}What was done:${NC}"
echo "  1. ✓ Pushed modifications to GitHub forks"
echo "  2. ✓ Renamed Yocto_sources to $BACKUP_NAME"
echo "  3. ✓ Created fresh Yocto_sources with submodules"
echo "  4. ✓ Initialized all submodules"
echo "  5. ✓ Copied configuration files"
echo "  6. ✓ Committed changes"
echo ""
echo -e "${YELLOW}To delete backup (after verifying):${NC}"
echo "  rm -rf $SCRIPT_DIR/$BACKUP_NAME"
echo ""
echo -e "${YELLOW}To restore original (if needed):${NC}"
echo "  rm -rf $SCRIPT_DIR/Yocto_sources"
echo "  mv $SCRIPT_DIR/$BACKUP_NAME $SCRIPT_DIR/Yocto_sources"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Test build: cd Yocto_sources/poky && source oe-init-build-env building"
echo "  2. If everything works: git push origin main"
echo "  3. Then you can delete the backup"
echo ""
echo -e "${GREEN}Done! 🎉${NC}"

