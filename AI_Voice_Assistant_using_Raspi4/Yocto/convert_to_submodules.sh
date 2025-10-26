#!/bin/bash
################################################################################
# Convert Existing Yocto Layers to Git Submodules
# 
# This script handles existing Yocto layers that may have local modifications:
# 1. Detects if layers are git repositories
# 2. Preserves any local modifications
# 3. Sets up proper git submodules
# 4. Handles both pristine and modified layers
################################################################################

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
YOCTO_SOURCES="$SCRIPT_DIR/Yocto_sources"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=================================================="
echo "  Convert Yocto Layers to Git Submodules"
echo "==================================================${NC}"
echo ""

# Your GitHub username (UPDATE THIS!)
GITHUB_USERNAME="ahmedferganey"

echo -e "${YELLOW}IMPORTANT: Before proceeding:${NC}"
echo "1. Make sure you have push access to https://github.com/${GITHUB_USERNAME}"
echo "2. You may need to fork repositories on GitHub first"
echo "3. Any local modifications will be preserved and pushed to your forks"
echo ""
read -p "Press Enter to continue or Ctrl+C to abort..."
echo ""

cd "$PROJECT_ROOT"

# Function to check if directory is a git repo
is_git_repo() {
    local dir="$1"
    if [ -d "$dir/.git" ]; then
        return 0
    else
        return 1
    fi
}

# Function to check if repo has uncommitted changes
has_uncommitted_changes() {
    local dir="$1"
    cd "$dir"
    if [ -n "$(git status --porcelain)" ]; then
        return 0
    else
        return 1
    fi
}

# Function to handle a layer
handle_layer() {
    local layer_name="$1"
    local layer_path="$YOCTO_SOURCES/$layer_name"
    local upstream_url="$2"
    local branch="$3"
    local your_fork_url="https://github.com/${GITHUB_USERNAME}/${layer_name}.git"
    
    echo -e "${BLUE}-------------------------------------------${NC}"
    echo -e "${BLUE}Processing: $layer_name${NC}"
    echo -e "${BLUE}-------------------------------------------${NC}"
    
    if [ ! -d "$layer_path" ]; then
        echo -e "${YELLOW}⚠ Directory does not exist: $layer_path${NC}"
        echo "  Will be added as clean submodule"
        return 0
    fi
    
    if ! is_git_repo "$layer_path"; then
        echo -e "${RED}✗ Not a git repository${NC}"
        echo "  Creating git repository..."
        cd "$layer_path"
        git init
        git checkout -b "$branch"
        git add .
        git commit -m "Initial commit: preserve existing $layer_name"
        echo -e "${GREEN}✓ Git repository created${NC}"
    fi
    
    cd "$layer_path"
    
    # Check for uncommitted changes
    if has_uncommitted_changes "$layer_path"; then
        echo -e "${YELLOW}⚠ Found uncommitted changes${NC}"
        echo "  Committing changes..."
        git add .
        git commit -m "Preserve local modifications before submodule conversion"
        echo -e "${GREEN}✓ Changes committed${NC}"
    fi
    
    # Check if there are custom commits
    local commit_count=$(git rev-list --count HEAD 2>/dev/null || echo "0")
    
    if [ "$commit_count" -gt 0 ]; then
        echo -e "${YELLOW}⚠ This layer has local commits (count: $commit_count)${NC}"
        echo ""
        echo "  Options:"
        echo "    1. Push to your fork: ${your_fork_url}"
        echo "    2. Use upstream (will LOSE your changes)"
        echo "    3. Skip this layer for now"
        echo ""
        read -p "  Choose option (1/2/3): " choice
        
        case $choice in
            1)
                echo "  Setting up remote..."
                git remote remove origin 2>/dev/null || true
                git remote add origin "$your_fork_url"
                
                echo ""
                echo -e "${YELLOW}  ACTION REQUIRED:${NC}"
                echo "  1. Go to GitHub: https://github.com/${GITHUB_USERNAME}"
                echo "  2. Create a new repository named: ${layer_name}"
                echo "  3. DO NOT initialize it (no README, no .gitignore)"
                echo ""
                read -p "  Press Enter when repository is created..."
                
                echo "  Pushing to your fork..."
                git push -u origin "$branch" || {
                    echo -e "${RED}✗ Push failed. Repository might not exist yet.${NC}"
                    echo "  Please create it on GitHub first."
                    return 1
                }
                echo -e "${GREEN}✓ Pushed to fork${NC}"
                LAYER_URL="$your_fork_url"
                ;;
            2)
                echo -e "${RED}  WARNING: Your changes will be discarded!${NC}"
                read -p "  Are you sure? (yes/no): " confirm
                if [ "$confirm" == "yes" ]; then
                    LAYER_URL="$upstream_url"
                    echo -e "${YELLOW}  Will use upstream repository${NC}"
                else
                    echo "  Skipping..."
                    return 1
                fi
                ;;
            3)
                echo "  Skipping..."
                return 1
                ;;
            *)
                echo -e "${RED}  Invalid option${NC}"
                return 1
                ;;
        esac
    else
        echo -e "${GREEN}✓ No custom commits found${NC}"
        echo "  Will use upstream repository"
        LAYER_URL="$upstream_url"
    fi
    
    cd "$PROJECT_ROOT"
    
    # Move the directory temporarily
    echo "  Moving $layer_name to temporary location..."
    mv "$layer_path" "${layer_path}.tmp"
    
    # Add as submodule
    echo "  Adding as git submodule..."
    if git submodule add -b "$branch" "$LAYER_URL" "$layer_path"; then
        echo -e "${GREEN}✓ Submodule added successfully${NC}"
        rm -rf "${layer_path}.tmp"
    else
        echo -e "${RED}✗ Failed to add submodule${NC}"
        echo "  Restoring original directory..."
        rm -rf "$layer_path"
        mv "${layer_path}.tmp" "$layer_path"
        return 1
    fi
    
    echo ""
}

# Main conversion process
echo -e "${BLUE}Starting conversion process...${NC}"
echo ""

# Layer definitions: name, upstream_url, branch
declare -A layers=(
    ["poky"]="https://git.yoctoproject.org/poky|kirkstone"
    ["meta-openembedded"]="https://github.com/openembedded/meta-openembedded.git|kirkstone"
    ["meta-raspberrypi"]="https://github.com/agherzan/meta-raspberrypi.git|kirkstone"
    ["meta-virtualization"]="https://git.yoctoproject.org/meta-virtualization|kirkstone"
    ["meta-qt6"]="https://code.qt.io/yocto/meta-qt6.git|kirkstone"
    ["meta-docker"]="https://github.com/mendersoftware/meta-docker.git|kirkstone"
    ["meta-onnxruntime"]="https://github.com/ArmRyan/meta-onnxruntime.git|kirkstone"
)

# Process each layer
for layer in "${!layers[@]}"; do
    IFS='|' read -r upstream branch <<< "${layers[$layer]}"
    handle_layer "$layer" "$upstream" "$branch" || {
        echo -e "${YELLOW}Continuing with next layer...${NC}"
        echo ""
    }
done

echo ""
echo -e "${BLUE}=================================================="
echo "  Conversion Summary"
echo "==================================================${NC}"
echo ""

# Show submodules status
if [ -f ".gitmodules" ]; then
    echo -e "${GREEN}Git submodules configured:${NC}"
    git submodule status
    echo ""
    
    echo "Next steps:"
    echo "  1. Review changes: git status"
    echo "  2. Test build environment: cd AI_Voice_Assistant_using_Raspi4/Yocto && ./setup_yocto.sh"
    echo "  3. Commit submodules: git commit -m 'Add Yocto layers as submodules'"
    echo "  4. Push changes: git push origin main"
else
    echo -e "${YELLOW}No submodules were added${NC}"
    echo "Review the output above for any errors"
fi

echo ""
echo -e "${GREEN}Done!${NC}"

