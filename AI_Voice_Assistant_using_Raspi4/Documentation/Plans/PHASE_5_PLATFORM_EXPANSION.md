# Phase 5: Platform Expansion - Complete Guide

**Status**: ⏳ **NOT STARTED** (0%)  
**Target**: Q4 2025  
**Priority**: Low  
**Effort**: 6-8 weeks

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Multi-Platform Hardware Support](#multi-platform-hardware-support)
3. [Alternative Build Systems](#alternative-build-systems)
4. [Cross-Platform Deployment](#cross-platform-deployment)
5. [Platform-Specific Optimizations](#platform-specific-optimizations)
6. [Migration Guide](#migration-guide)

---

## 🎯 Overview

### Objectives

Phase 5 expands the voice assistant to support multiple hardware platforms and build systems:

- **Hardware Platforms**: Raspberry Pi 5, Jetson Nano, Intel NUC, Generic x86_64
- **Build Systems**: BuildRoot, Debian, Ubuntu Core, Flatpak/Snap
- **Deployment**: Easy migration and multi-platform packages

### Success Criteria

- [ ] Working on Raspberry Pi 5
- [ ] Working on Jetson Nano
- [ ] Working on Intel NUC
- [ ] BuildRoot configuration available
- [ ] Flatpak/Snap packages published
- [ ] Cross-platform compatibility maintained

---

## 🖥️ Multi-Platform Hardware Support

### Supported Platforms

| Platform | CPU | RAM | GPU | Status |
|----------|-----|-----|-----|--------|
| **Raspberry Pi 4** | ARM Cortex-A72 (4 cores @ 1.5GHz) | 4/8 GB | VideoCore VI | ✅ Supported |
| **Raspberry Pi 5** | ARM Cortex-A76 (4 cores @ 2.4GHz) | 4/8 GB | VideoCore VII | 🚧 Planned |
| **Raspberry Pi CM4** | ARM Cortex-A72 (4 cores @ 1.5GHz) | 1-8 GB | VideoCore VI | 🚧 Planned |
| **NVIDIA Jetson Nano** | ARM Cortex-A57 (4 cores @ 1.43GHz) | 2/4 GB | Maxwell (128 CUDA cores) | 🚧 Planned |
| **NVIDIA Jetson Xavier NX** | ARM Carmel (6 cores @ 1.4GHz) | 8/16 GB | Volta (384 CUDA cores) | 🚧 Planned |
| **Intel NUC** | Intel Core i3/i5/i7 | 8-32 GB | Intel UHD | 🚧 Planned |
| **Generic x86_64** | Various | 4+ GB | Various | 🚧 Planned |

---

### Raspberry Pi 5 Support

**Hardware Differences**:
- Faster CPU (2.4 GHz vs 1.5 GHz)
- Better GPU (VideoCore VII)
- PCIe 2.0 support
- Improved I/O performance

**Yocto Configuration**:

`local.conf` additions for RPi5:

```bash
MACHINE = "raspberrypi5-64"

# Kernel configuration
PREFERRED_VERSION_linux-raspberrypi = "6.6%"

# GPU configuration
VC4DTBO = "vc4-kms-v3d"
GPU_MEM = "256"

# Enable PCIe
ENABLE_UART = "1"
ENABLE_I2C = "1"
ENABLE_SPI = "1"

# Additional packages for RPi5
IMAGE_INSTALL:append = " \
    linux-firmware-rpidistro-bcm43456 \
    bluez-firmware-rpidistro-bcm4345c0 \
"
```

**Build**:

```bash
cd /path/to/yocto/build
MACHINE=raspberrypi5-64 bitbake core-image-base
```

---

### Jetson Nano Support

**Advantages**:
- CUDA-accelerated AI inference
- Better performance for Whisper (5-10x faster)
- Hardware video encoding/decoding

**JetPack SDK Setup**:

```bash
# Flash JetPack 4.6.1
sudo ./sdkmanager --cli install \
    --logintype devzone \
    --product Jetson \
    --version 4.6.1 \
    --targetos Linux \
    --target JETSON_NANO_TARGETS \
    --flash all

# Install dependencies
sudo apt-get update
sudo apt-get install python3-pip cuda-toolkit-10-2

# Install PyTorch for Jetson
wget https://nvidia.box.com/shared/static/fjtbno0vpo676a25cgvuqc1wty0fkkg6.whl \
    -O torch-1.10.0-cp36-cp36m-linux_aarch64.whl
pip3 install torch-1.10.0-cp36-cp36m-linux_aarch64.whl
```

**CUDA-Accelerated Whisper**:

```python
import torch
import whisper

class JetsonWhisperModel:
    def __init__(self, model_name="base"):
        self.device = "cuda" if torch.cuda.is_available() else "cpu"
        self.model = whisper.load_model(model_name, device=self.device)
        print(f"Using device: {self.device}")
    
    def transcribe(self, audio_path):
        """Transcribe with CUDA acceleration"""
        result = self.model.transcribe(
            audio_path,
            fp16=True  # Enable FP16 on CUDA
        )
        return result

# Benchmark
import time
model = JetsonWhisperModel("base")

start = time.time()
result = model.transcribe("test.wav")
elapsed = time.time() - start

print(f"Transcription time: {elapsed:.2f}s")
# Expected: ~0.5s (vs ~2s on Raspberry Pi 4)
```

**Docker Configuration for Jetson**:

```dockerfile
# Dockerfile.jetson
FROM nvcr.io/nvidia/l4t-base:r32.7.1

# Install dependencies
RUN apt-get update && apt-get install -y \
    python3-pip \
    libsndfile1 \
    portaudio19-dev

# Install Python packages
RUN pip3 install \
    openai-whisper \
    sounddevice \
    numpy \
    torch torchvision torchaudio

# Copy application
COPY . /app
WORKDIR /app

CMD ["python3", "audio_backend.py"]
```

**Build and Run**:

```bash
# Build for Jetson
docker build -f Dockerfile.jetson -t voice-assistant-jetson .

# Run with GPU access
docker run --runtime nvidia --gpus all \
    --device /dev/snd \
    voice-assistant-jetson
```

---

### Intel NUC / x86_64 Support

**Advantages**:
- Higher CPU performance
- More RAM
- Standard x86_64 architecture
- Easy development environment

**Ubuntu Setup**:

```bash
# Install Ubuntu 22.04 LTS
# Download from: https://ubuntu.com/download

# Install dependencies
sudo apt-get update
sudo apt-get install -y \
    python3-pip \
    python3-pyqt6 \
    libsndfile1 \
    portaudio19-dev \
    alsa-utils \
    docker.io

# Install Whisper
pip3 install openai-whisper

# Clone repository
git clone https://github.com/yourrepo/voice-assistant.git
cd voice-assistant

# Build Qt application
mkdir build && cd build
cmake ..
make -j$(nproc)
sudo make install
```

**Performance Comparison**:

| Task | RPi 4 | Jetson Nano | Intel NUC i5 |
|------|-------|-------------|--------------|
| Boot Time | 45s | 35s | 15s |
| Whisper Base Inference | 2.0s | 0.5s | 0.3s |
| Whisper Large Inference | N/A (OOM) | 3.0s | 1.2s |
| Memory Usage (Idle) | 800 MB | 1.2 GB | 1.5 GB |
| Power Consumption | 7W | 10W | 25W |

---

## 🛠️ Alternative Build Systems

### BuildRoot Configuration

**Why BuildRoot?**:
- Smaller image size (50-100 MB vs 2 GB Yocto)
- Faster build times (30 min vs 6 hours)
- Simpler configuration
- Good for embedded systems

**Setup**:

```bash
# Clone BuildRoot
git clone https://github.com/buildroot/buildroot.git
cd buildroot

# Load Raspberry Pi 4 defconfig
make raspberrypi4_64_defconfig

# Customize configuration
make menuconfig
```

**Configuration** (`configs/voice_assistant_defconfig`):

```make
BR2_aarch64=y
BR2_TOOLCHAIN_EXTERNAL=y
BR2_TOOLCHAIN_EXTERNAL_BOOTLIN=y

# Kernel
BR2_LINUX_KERNEL=y
BR2_LINUX_KERNEL_CUSTOM_TARBALL=y
BR2_LINUX_KERNEL_CUSTOM_TARBALL_LOCATION="$(call github,raspberrypi,linux,rpi-6.1.y)/linux-rpi-6.1.y.tar.gz"

# Filesystem
BR2_TARGET_ROOTFS_EXT2=y
BR2_TARGET_ROOTFS_EXT2_4=y
BR2_TARGET_ROOTFS_EXT2_SIZE="512M"

# Packages
BR2_PACKAGE_PYTHON3=y
BR2_PACKAGE_PYTHON_PIP=y
BR2_PACKAGE_ALSA_UTILS=y
BR2_PACKAGE_DOCKER_CLI=y
BR2_PACKAGE_DOCKER_ENGINE=y

# Qt6
BR2_PACKAGE_QT6=y
BR2_PACKAGE_QT6BASE=y
BR2_PACKAGE_QT6DECLARATIVE=y
BR2_PACKAGE_QT6MULTIMEDIA=y

# Network
BR2_PACKAGE_WPA_SUPPLICANT=y
BR2_PACKAGE_DHCPCD=y

# Custom packages
BR2_PACKAGE_VOICE_ASSISTANT=y
```

**Custom Package** (`package/voice-assistant/voice-assistant.mk`):

```make
VOICE_ASSISTANT_VERSION = 2.0.0
VOICE_ASSISTANT_SOURCE = voice-assistant-$(VOICE_ASSISTANT_VERSION).tar.gz
VOICE_ASSISTANT_SITE = https://github.com/yourrepo/voice-assistant/archive
VOICE_ASSISTANT_LICENSE = MIT
VOICE_ASSISTANT_LICENSE_FILES = LICENSE

VOICE_ASSISTANT_DEPENDENCIES = qt6base qt6declarative qt6multimedia python3

define VOICE_ASSISTANT_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) all
endef

define VOICE_ASSISTANT_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/VoiceAssistant $(TARGET_DIR)/usr/bin/VoiceAssistant
	$(INSTALL) -D -m 0644 $(@D)/voice-assistant.desktop $(TARGET_DIR)/usr/share/applications/
endef

$(eval $(generic-package))
```

**Build**:

```bash
make voice_assistant_defconfig
make -j$(nproc)

# Output: output/images/sdcard.img
sudo dd if=output/images/sdcard.img of=/dev/sdX bs=4M status=progress
```

---

### Flatpak Package

**Why Flatpak?**:
- Sandboxed application
- Distribution-agnostic
- Easy updates
- Portable

**Flatpak Manifest** (`com.voiceassistant.VoiceAssistant.yml`):

```yaml
app-id: com.voiceassistant.VoiceAssistant
runtime: org.kde.Platform
runtime-version: '6.6'
sdk: org.kde.Sdk
command: VoiceAssistant
finish-args:
  - --socket=x11
  - --socket=wayland
  - --socket=pulseaudio
  - --device=all
  - --share=network
  - --filesystem=home

modules:
  - name: VoiceAssistant
    buildsystem: cmake
    sources:
      - type: git
        url: https://github.com/yourrepo/voice-assistant.git
        tag: v2.0.0
    
    build-commands:
      - cmake -DCMAKE_BUILD_TYPE=Release .
      - make -j$(nproc)
      - make install DESTDIR=/app
```

**Build Flatpak**:

```bash
# Install Flatpak builder
sudo apt-get install flatpak-builder

# Build
flatpak-builder --force-clean build-dir com.voiceassistant.VoiceAssistant.yml

# Test locally
flatpak-builder --run build-dir com.voiceassistant.VoiceAssistant.yml VoiceAssistant

# Export to repository
flatpak-builder --repo=repo --force-clean build-dir com.voiceassistant.VoiceAssistant.yml

# Create bundle
flatpak build-bundle repo VoiceAssistant.flatpak com.voiceassistant.VoiceAssistant
```

**Install**:

```bash
flatpak install VoiceAssistant.flatpak
flatpak run com.voiceassistant.VoiceAssistant
```

---

### Snap Package

**Snapcraft Configuration** (`snap/snapcraft.yaml`):

```yaml
name: voice-assistant
base: core22
version: '2.0.0'
summary: AI Voice Assistant for Vehicles
description: |
  Complete voice assistant system with speech recognition,
  natural language understanding, and vehicle integration.

grade: stable
confinement: strict

apps:
  voice-assistant:
    command: usr/bin/VoiceAssistant
    plugs:
      - audio-playback
      - audio-record
      - network
      - network-bind
      - home
      - opengl
      - x11

parts:
  voice-assistant:
    plugin: cmake
    source: https://github.com/yourrepo/voice-assistant.git
    source-tag: v2.0.0
    build-packages:
      - cmake
      - g++
      - qt6-base-dev
      - qt6-declarative-dev
      - qt6-multimedia-dev
    stage-packages:
      - qt6-base-plugins
      - qt6-qpa-plugins
      - libqt6multimedia6
      - alsa-utils
```

**Build Snap**:

```bash
# Install snapcraft
sudo snap install snapcraft --classic

# Build
snapcraft

# Install locally
sudo snap install voice-assistant_2.0.0_amd64.snap --dangerous

# Run
voice-assistant
```

---

## 🔄 Cross-Platform Deployment

### Unified Build Script

**`build.sh`**:

```bash
#!/bin/bash

PLATFORM=$1
BUILD_TYPE=${2:-Release}

case $PLATFORM in
    rpi4)
        echo "Building for Raspberry Pi 4..."
        source /opt/poky/4.0/environment-setup-cortexa72-poky-linux
        cmake -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
              -DTARGET_PLATFORM=RPi4 .
        make -j$(nproc)
        ;;
    
    rpi5)
        echo "Building for Raspberry Pi 5..."
        source /opt/poky/5.0/environment-setup-cortexa76-poky-linux
        cmake -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
              -DTARGET_PLATFORM=RPi5 .
        make -j$(nproc)
        ;;
    
    jetson)
        echo "Building for Jetson Nano..."
        cmake -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
              -DTARGET_PLATFORM=Jetson \
              -DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda .
        make -j$(nproc)
        ;;
    
    x86_64)
        echo "Building for x86_64..."
        cmake -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
              -DTARGET_PLATFORM=x86_64 .
        make -j$(nproc)
        ;;
    
    *)
        echo "Unknown platform: $PLATFORM"
        echo "Supported: rpi4, rpi5, jetson, x86_64"
        exit 1
        ;;
esac
```

**Usage**:

```bash
./build.sh rpi4 Release
./build.sh jetson Debug
./build.sh x86_64
```

---

## ⚙️ Platform-Specific Optimizations

### Raspberry Pi Optimizations

```cmake
# CMakeLists.txt
if(TARGET_PLATFORM STREQUAL "RPi4" OR TARGET_PLATFORM STREQUAL "RPi5")
    # ARM NEON optimizations
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mfpu=neon -mfloat-abi=hard")
    
    # VideoCore GPU
    add_definitions(-DUSE_VC4)
    
    # Optimize for Cortex-A72/A76
    if(TARGET_PLATFORM STREQUAL "RPi4")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mcpu=cortex-a72")
    else()
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mcpu=cortex-a76")
    endif()
endif()
```

### Jetson Optimizations

```cmake
if(TARGET_PLATFORM STREQUAL "Jetson")
    # CUDA support
    find_package(CUDA REQUIRED)
    enable_language(CUDA)
    
    # CUDA flags
    set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} -arch=sm_53")  # Jetson Nano
    
    # Link CUDA libraries
    target_link_libraries(VoiceAssistant ${CUDA_LIBRARIES})
    
    # TensorRT for optimized inference
    find_package(TensorRT REQUIRED)
    target_link_libraries(VoiceAssistant ${TensorRT_LIBRARIES})
endif()
```

### x86_64 Optimizations

```cmake
if(TARGET_PLATFORM STREQUAL "x86_64")
    # AVX2 support
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mavx2 -mfma")
    
    # Intel MKL for optimized math operations
    find_package(MKL)
    if(MKL_FOUND)
        target_link_libraries(VoiceAssistant ${MKL_LIBRARIES})
    endif()
endif()
```

---

## 📖 Migration Guide

### Migrating from Raspberry Pi 4 to Raspberry Pi 5

**1. Backup Configuration**:

```bash
# On RPi4
sudo tar -czf /tmp/voice-assistant-backup.tar.gz \
    /home/ferganey/.voice-assistant \
    /etc/voice-assistant \
    /var/lib/voice-assistant
```

**2. Flash New Image**:

```bash
# Write RPi5 image to SD card
sudo dd if=voice-assistant-rpi5.img of=/dev/sdX bs=4M status=progress
```

**3. Restore Configuration**:

```bash
# On RPi5
sudo tar -xzf /tmp/voice-assistant-backup.tar.gz -C /
```

**4. Update Configuration**:

```bash
# Update for RPi5 hardware
sudo nano /boot/config.txt
# Ensure correct settings for RPi5
```

### Migrating from Raspberry Pi to Jetson Nano

**Key Differences**:

| Aspect | Raspberry Pi 4 | Jetson Nano |
|--------|----------------|-------------|
| OS | Yocto/Raspberry Pi OS | JetPack (Ubuntu) |
| Package Manager | RPM/apt (if Raspberry Pi OS) | apt |
| GPU | VideoCore VI | CUDA-capable Maxwell |
| AI Acceleration | CPU only | GPU (CUDA) |

**Migration Steps**:

1. **Export User Data**:
```bash
# On RPi
./export_user_data.sh > user_data.json
```

2. **Install on Jetson**:
```bash
# Flash JetPack
# Install application
sudo apt-get install ./voice-assistant-jetson_2.0.0_arm64.deb
```

3. **Import User Data**:
```bash
./import_user_data.sh user_data.json
```

4. **Configure for CUDA**:
```bash
# Enable CUDA acceleration
sudo nano /etc/voice-assistant/config.yaml
# Set: use_cuda: true
```

---

**Phase 5 (Platform Expansion) Status**: ⏳ **NOT STARTED** (0%)  
**Next Phase**: [Phase 6: Documentation & Community](PHASE_6_DOCUMENTATION_COMMUNITY.md)

---

*Last Updated: October 2024*  
*Document Version: 1.0*

