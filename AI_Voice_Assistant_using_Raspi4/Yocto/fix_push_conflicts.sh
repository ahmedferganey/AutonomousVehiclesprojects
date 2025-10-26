#!/bin/bash
################################################################################
# Fix Push Conflicts - Force Push Modified Layers
# 
# When you fork a repository, your fork has the original history.
# But your local copy has YOUR modifications.
# We need to force push to replace the fork's history with yours.
################################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
YOCTO_SOURCES="$SCRIPT_DIR/Yocto_sources"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  Fix Push Conflicts with Force Push${NC}"
echo -e "${CYAN}════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}This will FORCE PUSH your modifications to GitHub.${NC}"
echo -e "${YELLOW}This is SAFE because:${NC}"
echo "  - Your forks are new (just created)"
echo "  - You want YOUR modifications, not the original"
echo "  - Using --force-with-lease for safety"
echo ""
read -p "Press Enter to continue..."
echo ""

cd "$YOCTO_SOURCES"

# Function to force push
force_push_layer() {
    local layer_name="$1"
    local branch="$2"
    
    echo -e "${CYAN}→ Force pushing $layer_name...${NC}"
    
    if [ ! -d "$layer_name/.git" ]; then
        echo -e "${YELLOW}  ⚠ Not a git repo, skipping${NC}"
        return 0
    fi
    
    cd "$layer_name"
    
    echo "  Branch: $branch"
    echo "  Remote: $(git remote get-url origin 2>/dev/null || echo 'No remote')"
    echo ""
    
    # Force push with lease (safer than --force)
    if git push -u origin "$branch" --force-with-lease; then
        echo -e "${GREEN}  ✓ Successfully pushed${NC}"
    else
        echo -e "${RED}  ✗ Failed${NC}"
        echo ""
        echo "  Trying regular force push..."
        if git push -u origin "$branch" --force; then
            echo -e "${GREEN}  ✓ Force push succeeded${NC}"
        else
            echo -e "${RED}  ✗ Still failed${NC}"
            return 1
        fi
    fi
    
    cd "$YOCTO_SOURCES"
    echo ""
}

# Force push all modified layers
echo -e "${YELLOW}Pushing modified layers to your forks...${NC}"
echo ""

force_push_layer "poky" "kirkstone-voiceassistant"
force_push_layer "meta-openembedded" "kirkstone-voiceassistant"
force_push_layer "meta-raspberrypi" "kirkstone-voiceassistant"
force_push_layer "meta-onnxruntime" "main"
force_push_layer "meta-tensorflow-lite" "main"

echo ""
echo -e "${GREEN}════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  ✓ All layers pushed!${NC}"
echo -e "${GREEN}════════════════════════════════════════════════${NC}"
echo ""
echo "Next steps:"
echo "  1. Continue with setup_submodules_safe.sh"
echo "  2. Or if already running, press Ctrl+C and restart it"
echo ""

