#!/bin/bash
# Build script for Whisper ONNX backend Docker image
# Supports both x86_64 (for testing) and ARM64 (for Raspberry Pi 4)

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🐳 Whisper ONNX Backend - Docker Build Script${NC}"
echo "=============================================="
echo ""

# Configuration
IMAGE_NAME="whisper-backend-onnx"
IMAGE_TAG="test"
PLATFORMS="linux/amd64"  # Default to x86_64 for testing

# Parse arguments
BUILD_ARM64=false
PUSH_IMAGE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --arm64)
            BUILD_ARM64=true
            shift
            ;;
        --multi-arch)
            PLATFORMS="linux/amd64,linux/arm64"
            shift
            ;;
        --push)
            PUSH_IMAGE=true
            shift
            ;;
        --tag)
            IMAGE_TAG="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --arm64        Build for ARM64 only (Raspberry Pi 4)"
            echo "  --multi-arch   Build for both x86_64 and ARM64"
            echo "  --push         Push image to Docker Hub after build"
            echo "  --tag TAG      Specify custom image tag (default: test)"
            echo "  --help         Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                    # Build for x86_64 (local testing)"
            echo "  $0 --arm64            # Build for ARM64 only"
            echo "  $0 --multi-arch       # Build for both architectures"
            echo "  $0 --tag v1.0         # Build with custom tag"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

if [ "$BUILD_ARM64" = true ]; then
    PLATFORMS="linux/arm64"
fi

IMAGE_FULL="${IMAGE_NAME}:${IMAGE_TAG}"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed!${NC}"
    echo "Please install Docker first: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if docker buildx is available
if ! docker buildx version &> /dev/null; then
    echo -e "${YELLOW}⚠️  Docker buildx not available, using standard build${NC}"
    USE_BUILDX=false
else
    USE_BUILDX=true
    echo -e "${GREEN}✓ Docker buildx is available${NC}"
fi

# Display build configuration
echo ""
echo "Build Configuration:"
echo "  Image Name:  ${IMAGE_FULL}"
echo "  Platforms:   ${PLATFORMS}"
echo "  Builder:     $([ "$USE_BUILDX" = true ] && echo "buildx" || echo "standard")"
echo "  Push:        $([ "$PUSH_IMAGE" = true ] && echo "yes" || echo "no")"
echo ""

# Check if app directory exists
if [ ! -d "app" ]; then
    echo -e "${RED}❌ Error: 'app' directory not found!${NC}"
    echo "Make sure you're running this script from the whisper_backend_docker_test directory"
    exit 1
fi

# Check if required files exist
REQUIRED_FILES=("Dockerfile" "requirements.txt" "app/main.py" "app/config.py")
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo -e "${RED}❌ Error: Required file not found: $file${NC}"
        exit 1
    fi
done

echo -e "${GREEN}✓ All required files found${NC}"
echo ""

# Create models and cache directories if they don't exist
mkdir -p models cache

# Build the image
echo -e "${GREEN}🔨 Building Docker image...${NC}"
echo ""

if [ "$USE_BUILDX" = true ]; then
    # Create buildx builder if it doesn't exist
    if ! docker buildx ls | grep -q "whisper-builder"; then
        echo "Creating buildx builder..."
        docker buildx create --name whisper-builder --use
    else
        echo "Using existing buildx builder"
        docker buildx use whisper-builder
    fi
    
    # Build command
    BUILD_CMD="docker buildx build"
    BUILD_CMD="$BUILD_CMD --platform $PLATFORMS"
    BUILD_CMD="$BUILD_CMD --tag $IMAGE_FULL"
    BUILD_CMD="$BUILD_CMD --tag ${IMAGE_NAME}:latest"
    
    if [ "$PUSH_IMAGE" = true ]; then
        BUILD_CMD="$BUILD_CMD --push"
    else
        BUILD_CMD="$BUILD_CMD --load"
    fi
    
    BUILD_CMD="$BUILD_CMD ."
    
    echo "Running: $BUILD_CMD"
    echo ""
    eval $BUILD_CMD
else
    # Standard build
    docker build \
        --tag $IMAGE_FULL \
        --tag ${IMAGE_NAME}:latest \
        .
fi

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Docker image built successfully!${NC}"
    echo ""
    echo "Image: $IMAGE_FULL"
    echo ""
    
    if [ "$PUSH_IMAGE" = false ]; then
        # Show image info
        echo "Image details:"
        docker images | grep "$IMAGE_NAME" | head -2
        echo ""
        
        echo -e "${GREEN}🚀 To run the container:${NC}"
        echo "  docker-compose up -d"
        echo ""
        echo "Or manually:"
        echo "  docker run -d -p 8000:8000 --name whisper-backend $IMAGE_FULL"
        echo ""
        echo -e "${GREEN}📝 To test the backend:${NC}"
        echo "  ./scripts/test.sh"
        echo ""
    fi
else
    echo -e "${RED}❌ Docker build failed!${NC}"
    exit 1
fi

