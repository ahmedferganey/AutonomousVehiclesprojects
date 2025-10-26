# Building Qt6 Voice Assistant GUI

This document provides detailed instructions for building the Qt6 Voice Assistant GUI application for different platforms.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Building for Desktop (Development)](#building-for-desktop-development)
- [Cross-Compiling for Raspberry Pi](#cross-compiling-for-raspberry-pi)
- [Building with Yocto](#building-with-yocto)
- [Troubleshooting](#troubleshooting)

## Prerequisites

### Host System Requirements
- **OS**: Ubuntu 20.04/22.04 LTS or compatible Linux distribution
- **RAM**: 4GB minimum (8GB+ recommended for development)
- **Storage**: 5GB free space for Qt6 and dependencies
- **CPU**: Dual-core or better

### Required Packages (Ubuntu/Debian)

```bash
# Update package list
sudo apt update

# Install Qt6 development packages
sudo apt install -y \
    qt6-base-dev \
    qt6-declarative-dev \
    qt6-multimedia-dev \
    qt6-svg-dev \
    qml6-module-qtquick \
    qml6-module-qtquick-controls \
    qml6-module-qtquick-layouts \
    qml6-module-qtquick-window

# Install build tools
sudo apt install -y \
    build-essential \
    cmake \
    g++ \
    make \
    git \
    pkg-config

# Install Python and dependencies
sudo apt install -y \
    python3 \
    python3-pip \
    python3-dev \
    python3-numpy \
    portaudio19-dev

# Install Python packages
pip3 install --user \
    numpy \
    sounddevice \
    openai-whisper \
    torch \
    onnxruntime
```

## Building for Desktop (Development)

This is useful for testing and development on your development machine.

### Step 1: Clone/Navigate to Project

```bash
cd /path/to/AI_Voice_Assistant_using_Raspi4/qt6_voice_assistant_gui
```

### Step 2: Create Build Directory

```bash
mkdir build
cd build
```

### Step 3: Configure with CMake

```bash
cmake .. \
    -DCMAKE_BUILD_TYPE=Debug \
    -DCMAKE_INSTALL_PREFIX=/usr/local
```

**Build Type Options:**
- `Debug`: For development with debug symbols
- `Release`: Optimized for production
- `RelWithDebInfo`: Optimized with debug info
- `MinSizeRel`: Minimum size optimization

### Step 4: Build

```bash
# Build with all available CPU cores
make -j$(nproc)

# Or build with specific number of cores
make -j4
```

### Step 5: Run

```bash
# Run directly from build directory
./VoiceAssistant

# Or install system-wide
sudo make install

# Then run
VoiceAssistant
```

### Optional: Enable Qt Debug Output

```bash
# Set environment variables for debugging
export QT_DEBUG_PLUGINS=1
export QT_LOGGING_RULES="*.debug=true;qt.qml.*.debug=false"

./VoiceAssistant
```

## Cross-Compiling for Raspberry Pi

This requires the Yocto SDK to be installed.

### Step 1: Install Yocto SDK

If you haven't already generated and installed the SDK:

```bash
# In your Yocto build directory
cd /path/to/poky/build

# Generate SDK
bitbake core-image-base -c populate_sdk

# Install SDK
cd tmp/deploy/sdk
./poky-glibc-x86_64-core-image-base-cortexa72-raspberrypi4-64-toolchain-4.0.24.sh

# Follow prompts (default installation: /opt/poky/4.0.24)
```

### Step 2: Source SDK Environment

```bash
source /opt/poky/4.0.24/environment-setup-cortexa72-poky-linux
```

Verify the environment:
```bash
echo $CC
# Should output: aarch64-poky-linux-gcc

echo $CXX
# Should output: aarch64-poky-linux-g++
```

### Step 3: Create Build Directory

```bash
cd /path/to/qt6_voice_assistant_gui
mkdir build-rpi
cd build-rpi
```

### Step 4: Configure with CMake

```bash
cmake .. \
    -DCMAKE_TOOLCHAIN_FILE=$OECORE_NATIVE_SYSROOT/usr/share/cmake/OEToolchainConfig.cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr
```

### Step 5: Build

```bash
make -j$(nproc)
```

### Step 6: Deploy to Raspberry Pi

**Option 1: Manual Copy**
```bash
# Copy executable
scp VoiceAssistant root@raspberrypi.local:/usr/bin/

# Copy backend
scp -r ../backend root@raspberrypi.local:/usr/share/voice-assistant/

# Copy desktop file
scp ../voice-assistant.desktop root@raspberrypi.local:/usr/share/applications/
```

**Option 2: Create Deployment Package**
```bash
# Install to staging directory
make install DESTDIR=./install-staging

# Create tarball
tar czf voice-assistant-rpi.tar.gz -C install-staging .

# Copy to Raspberry Pi
scp voice-assistant-rpi.tar.gz root@raspberrypi.local:/tmp/

# On Raspberry Pi
ssh root@raspberrypi.local
cd /
tar xzf /tmp/voice-assistant-rpi.tar.gz
```

### Step 7: Install Python Dependencies on Raspberry Pi

```bash
ssh root@raspberrypi.local

# Install pip packages
pip3 install -r /usr/share/voice-assistant/backend/requirements.txt

# Or if using the Yocto image, they should already be installed
```

## Building with Yocto

This is the recommended method for production deployment.

### Step 1: Copy Recipe to Yocto Layer

```bash
# Copy recipe
cp -r /path/to/qt6_voice_assistant_gui \
    /path/to/poky/meta-userapp/recipes-apps/

# Or if recipe already exists, update it
cp /path/to/qt6-voice-assistant_1.0.0.bb \
    /path/to/poky/meta-userapp/recipes-apps/qt6-voice-assistant/
```

### Step 2: Add to Image Recipe

Edit your image recipe (e.g., `core-image-base.bbappend`):

```bash
IMAGE_INSTALL:append = " qt6-voice-assistant"
```

Or add to `local.conf`:
```bash
IMAGE_INSTALL:append = " qt6-voice-assistant"
```

### Step 3: Build with Bitbake

```bash
cd /path/to/poky/build

# Source environment
source oe-init-build-env

# Build the recipe
bitbake qt6-voice-assistant

# Or build entire image with application included
bitbake core-image-base
```

### Step 4: Deploy Image

```bash
# Navigate to images directory
cd tmp/deploy/images/raspberrypi4-64

# Flash to SD card
sudo bmaptool copy core-image-base-raspberrypi4-64-*.wic.bz2 /dev/sdX

# Or use dd
bunzip2 -c core-image-base-raspberrypi4-64-*.wic.bz2 | sudo dd of=/dev/sdX bs=4M status=progress
sync
```

### Build-Only (Without Full Image)

If you only want to build the application:

```bash
# Clean previous builds
bitbake -c cleansstate qt6-voice-assistant

# Build
bitbake qt6-voice-assistant

# Find output
find tmp/deploy/rpm/ -name "qt6-voice-assistant*"

# Install RPM on running system
scp tmp/deploy/rpm/cortexa72/qt6-voice-assistant-*.rpm root@raspberrypi.local:/tmp/
ssh root@raspberrypi.local
rpm -ivh /tmp/qt6-voice-assistant-*.rpm
```

## Advanced Build Options

### Custom Qt6 Installation

If using a custom Qt6 installation:

```bash
cmake .. \
    -DCMAKE_PREFIX_PATH=/path/to/Qt6/installation \
    -DCMAKE_BUILD_TYPE=Release
```

### Static Linking

For a self-contained executable:

```bash
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=OFF \
    -DQt6_DIR=/path/to/Qt6/lib/cmake/Qt6
```

### Custom Compiler Flags

```bash
cmake .. \
    -DCMAKE_CXX_FLAGS="-O3 -march=native -mtune=native" \
    -DCMAKE_BUILD_TYPE=Release
```

### Build with Clang

```bash
cmake .. \
    -DCMAKE_C_COMPILER=clang \
    -DCMAKE_CXX_COMPILER=clang++ \
    -DCMAKE_BUILD_TYPE=Release
```

## Troubleshooting

### Qt6 Not Found

**Error:**
```
CMake Error: Qt6 not found
```

**Solution:**
```bash
# Install Qt6 packages
sudo apt install qt6-base-dev qt6-declarative-dev

# Or set Qt6 path manually
export Qt6_DIR=/path/to/Qt6/lib/cmake/Qt6
```

### Missing QML Modules

**Error:**
```
module "QtQuick.Controls" is not installed
```

**Solution:**
```bash
sudo apt install \
    qml6-module-qtquick \
    qml6-module-qtquick-controls \
    qml6-module-qtquick-layouts
```

### Compilation Errors

**Error:**
```
fatal error: QGuiApplication: No such file or directory
```

**Solution:**
```bash
# Install Qt6 development headers
sudo apt install qt6-base-dev

# Verify installation
dpkg -L qt6-base-dev | grep include
```

### Linker Errors

**Error:**
```
undefined reference to `Qt6::Core'
```

**Solution:**
```bash
# Clean and rebuild
rm -rf build
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make
```

### Audio Backend Not Starting

**Error:**
```
Failed to start Python backend
```

**Solution:**
```bash
# Check Python path in audioengine.cpp
# Make sure audio_backend.py is installed at:
ls /usr/share/voice-assistant/backend/audio_backend.py

# Test Python backend manually
python3 /usr/share/voice-assistant/backend/audio_backend.py

# Install missing dependencies
pip3 install -r /usr/share/voice-assistant/backend/requirements.txt
```

### Cross-Compilation Issues

**Error:**
```
CMake toolchain file not found
```

**Solution:**
```bash
# Re-source SDK environment
source /opt/poky/4.0.24/environment-setup-cortexa72-poky-linux

# Verify environment
echo $OECORE_NATIVE_SYSROOT

# Check toolchain file exists
ls $OECORE_NATIVE_SYSROOT/usr/share/cmake/OEToolchainConfig.cmake
```

## Performance Optimization

### For Raspberry Pi 4

Add these flags to CMakeLists.txt or command line:

```bash
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_FLAGS="-O3 -march=armv8-a+crc -mtune=cortex-a72 -ftree-vectorize -ffast-math"
```

### Reduce Binary Size

```bash
cmake .. \
    -DCMAKE_BUILD_TYPE=MinSizeRel \
    -DCMAKE_CXX_FLAGS="-Os -ffunction-sections -fdata-sections" \
    -DCMAKE_EXE_LINKER_FLAGS="-Wl,--gc-sections"

strip --strip-all VoiceAssistant
```

## Packaging

### Create DEB Package

```bash
# Install packaging tools
sudo apt install checkinstall

# Build and create package
cd build
sudo checkinstall \
    --pkgname=qt6-voice-assistant \
    --pkgversion=1.0.0 \
    --pkgrelease=1 \
    --maintainer="ahmed.ferganey707@gmail.com" \
    make install
```

### Create AppImage

```bash
# Install linuxdeploy
wget https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
chmod +x linuxdeploy-x86_64.AppImage

# Create AppImage
./linuxdeploy-x86_64.AppImage \
    --executable=./VoiceAssistant \
    --desktop-file=../voice-assistant.desktop \
    --icon-file=../resources/voice-assistant.png \
    --appdir=AppDir \
    --output appimage
```

## Contributing

When submitting build fixes:

1. Test on both desktop and Raspberry Pi
2. Update this BUILD.md documentation
3. Document any new dependencies
4. Provide clear error messages
5. Consider backwards compatibility

## Support

For build issues:
- Email: ahmed.ferganey707@gmail.com
- Check logs: `build/CMakeOutput.log` and `build/CMakeError.log`
- Enable verbose output: `make VERBOSE=1`

---

Last Updated: October 2024

