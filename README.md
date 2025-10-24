# AI Voice Assistant for Autonomous Vehicles using Raspberry Pi 4

![Project Status](https://img.shields.io/badge/status-active-success.svg)
![Platform](https://img.shields.io/badge/platform-Raspberry%20Pi%204-red.svg)
![License](https://img.shields.io/badge/license-Closed-blue.svg)

A comprehensive embedded Linux system featuring an AI-powered voice assistant for autonomous vehicles, built on Raspberry Pi 4 using Yocto Project and Docker containerization.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Hardware Requirements](#hardware-requirements)
- [Software Stack](#software-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Yocto Build Setup](#yocto-build-setup)
  - [Building the Image](#building-the-image)
  - [Flashing to SD Card](#flashing-to-sd-card)
- [Docker Deployment](#docker-deployment)
- [Configuration](#configuration)
  - [WiFi Setup](#wifi-setup)
  - [Bluetooth Configuration](#bluetooth-configuration)
  - [Audio Configuration](#audio-configuration)
- [Development](#development)
  - [SDK Generation](#sdk-generation)
  - [Qt Creator Setup](#qt-creator-setup)
  - [Cross-Compilation](#cross-compilation)
- [Usage](#usage)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [References](#references)
- [License](#license)

---

## 🎯 Overview

This project implements a real-time AI voice assistant for autonomous vehicles using embedded Linux technologies. It leverages OpenAI's Whisper model for speech-to-text transcription, Qt6 for the graphical user interface, and Docker for application containerization. The entire system is built from scratch using the Yocto Project, providing a custom-tailored Linux distribution optimized for Raspberry Pi 4.

### Key Highlights

- **Real-time Speech Recognition**: Uses OpenAI Whisper model for accurate speech-to-text conversion
- **Modern GUI**: Built with Qt6 framework for responsive user interfaces
- **Containerized Architecture**: Docker-based deployment for portability and scalability
- **Custom Linux Distribution**: Built with Yocto Project for complete control over the system
- **Hardware Acceleration**: Leverages VC4 graphics, OpenGL, and Vulkan for optimal performance
- **Comprehensive Multimedia**: Full GStreamer and FFmpeg support for audio/video processing

---

## ✨ Features

### Core Functionality
- ✅ Real-time audio streaming with 60-second ring buffer
- ✅ Speech-to-text transcription using Whisper AI model
- ✅ Natural Language Processing for intent analysis
- ✅ PyQt5-based graphical user interface
- ✅ Silence detection (threshold: 0.01) to optimize processing
- ✅ 16kHz audio sampling rate for speech recognition

### System Features
- ✅ Yocto-based custom Linux distribution (Kirkstone branch)
- ✅ Systemd init system for service management
- ✅ Docker CE integration for container orchestration
- ✅ WiFi connectivity (brcmfmac driver) with WPA2 support
- ✅ Bluetooth support (bluez5 stack)
- ✅ U-Boot bootloader for flexible boot configuration
- ✅ Cross-compilation SDK for development

### Development Tools
- ✅ Qt6 complete suite (20+ modules)
- ✅ GStreamer multimedia framework
- ✅ FFmpeg codec libraries
- ✅ OpenCV 4.5.5 for computer vision
- ✅ Python 3 with AI/ML libraries (numpy, ONNX Runtime)
- ✅ SSH and VNC remote access

---

## 🏗️ Architecture

The system follows a layered architecture design:

```
┌─────────────────────────────────────────────────────────────┐
│                     Application Layer                        │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐│
│  │   Qt6 GUI App   │  │  Audio Backend  │  │ Voice Engine ││
│  │   (Frontend)    │  │   (Docker)      │  │  (Whisper)   ││
│  └─────────────────┘  └─────────────────┘  └──────────────┘│
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                    Processing Layer                          │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────────────┐ │
│  │ Speech-to-   │  │     NLP      │  │  Intent Analysis  │ │
│  │    Text      │  │   Engine     │  │                   │ │
│  └──────────────┘  └──────────────┘  └───────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                   Integration Layer                          │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────────────┐ │
│  │ Vehicle APIs │  │  Docker API  │  │  System Services  │ │
│  └──────────────┘  └──────────────┘  └───────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                      Input/Output Layer                      │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────────────┐ │
│  │USB Microphone│  │   Speakers   │  │    Display        │ │
│  │ (16kHz)      │  │   (ALSA)     │  │   (HDMI/DSI)      │ │
│  └──────────────┘  └──────────────┘  └───────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                      Hardware Layer                          │
│           Raspberry Pi 4 Model B (ARMv8 64-bit)              │
│       BCM2711 (Quad-core Cortex-A72 @ 1.5GHz, 4GB RAM)      │
└─────────────────────────────────────────────────────────────┘
```

### Component Description

1. **Input Layer**: Captures audio via USB microphones with sounddevice library
2. **Processing Layer**: Whisper model for STT, NLP for intent understanding
3. **Integration Layer**: Interfaces with vehicle systems and container orchestration
4. **Output Layer**: Provides audio/visual feedback through speakers and displays

---

## 🔧 Hardware Requirements

### Essential Components

| Component | Specification | Purpose |
|-----------|--------------|---------|
| **Raspberry Pi 4 Model B** | 4GB RAM, Quad-core Cortex-A72 @ 1.5GHz | Main computing platform |
| **MicroSD Card** | 64GB Class 10 (minimum 32GB) | Operating system storage |
| **Power Supply** | USB-C, 5V 3A | Power delivery |
| **USB Microphone** | 16kHz sample rate or higher | Audio input for speech recognition |
| **USB Sound Card** | (Alternative) For 3.5mm microphone | Audio interface |
| **Speakers/Headphones** | 3.5mm jack or USB | Audio output |
| **HDMI Cable** | Micro-HDMI to HDMI | Display connection |
| **Ethernet Cable** | (Optional) Cat5e or better | Wired network connection |

### Recommended USB Microphones

| Brand | Model | Price Range |
|-------|-------|-------------|
| **Blue Microphones** | Yeti | $100 - $130 |
| **Audio-Technica** | AT2020USB+ | $150 - $170 |
| **Razer** | Seiren Mini | $50 - $70 |
| **Samson** | Q2U | $60 - $90 |

### Additional Components (Optional)

- Mouse and keyboard for initial setup
- Cooling fan or heatsink for sustained operation
- Case for physical protection
- GPIO jumper wires for hardware expansion

---

## 💻 Software Stack

### Operating System
- **Distribution**: Custom Poky Linux (Yocto Kirkstone)
- **Kernel**: Linux 6.1.x (rpi-6.1.y branch)
- **Init System**: systemd
- **Bootloader**: U-Boot
- **Architecture**: ARMv8 AArch64 (64-bit)

### Core Technologies

#### AI/ML Stack
- **OpenAI Whisper**: Speech-to-text model (base version)
- **ONNX Runtime**: Machine learning inference
- **Python 3**: Primary programming language
- **NumPy**: Numerical computing

#### GUI Framework
- **Qt6**: Complete application framework
  - QtBase, QtDeclarative, QtMultimedia
  - Qt3D, QtQuick3D, QtQuick3DPhysics
  - QtWebEngine, QtCharts, QtDataVis3D
  - QtSerialPort, QtNetworkAuth, QtMQTT

#### Multimedia
- **GStreamer 1.0**: Multimedia framework
  - Plugins: good, base, bad, ugly, vaapi
- **FFmpeg**: Codec libraries (H.264, Opus, ALSA)
- **ALSA**: Advanced Linux Sound Architecture
- **Mesa**: OpenGL implementation
- **Vulkan**: Graphics API

#### Containerization
- **Docker CE**: Container engine
- **containerd**: Container runtime
- **runc**: OCI runtime

#### Networking
- **wpa_supplicant**: WiFi authentication
- **dhcpcd**: DHCP client
- **iproute2**: Network utilities
- **iptables**: Firewall management

#### Development Tools
- **GCC**: Cross-compilation toolchain
- **CMake**: Build system generator
- **Git**: Version control
- **Python packages**: pip, setuptools, wheel, pyaudio

---

## 📁 Project Structure

```
AutonomousVehiclesprojects/
│
├── AI_Voice_Assistant_using_Raspi4/
│   │
│   ├── audio_transcription_docker/       # Docker-based audio application
│   │   ├── main.py                        # PyQt5 GUI application
│   │   ├── audio_capture.py               # Audio input handler
│   │   ├── whisper_model.py               # Whisper transcription
│   │   ├── ring_buffer.py                 # Circular audio buffer
│   │   ├── requirements.txt               # Python dependencies
│   │   └── Dockerfile                     # Container definition
│   │
│   ├── Documentation/                     # Comprehensive documentation
│   │   ├── general/
│   │   │   ├── Config_RPI4.ipynb          # Raspberry Pi 4 configuration
│   │   │   ├── HW_Req.ipynb               # Hardware requirements
│   │   │   └── automation_hw.sh           # Hardware automation script
│   │   ├── Docker/
│   │   │   └── DockerUsage.ipynb          # Docker integration guide
│   │   ├── EmbeddedSecurity/
│   │   │   └── Security for embedded Linux.ipynb
│   │   ├── AndroidOpenSource/
│   │   │   └── intro.ipynb                # AOSP introduction
│   │   └── preparation/
│   │       ├── boot.cmd                   # U-Boot boot script
│   │       ├── uRamdisk.img               # Initial ramdisk
│   │       └── initramfs/                 # Initial filesystem
│   │
│   ├── BuildRoot/                         # BuildRoot artifacts
│   │   ├── boot/                          # Boot files (DTB, u-boot.bin)
│   │   └── root/                          # Root filesystem
│   │
│   ├── Yocto/                             # Yocto build system
│   │   ├── bblayers.conf                  # Layer configuration
│   │   ├── local.conf                     # Build configuration
│   │   ├── yocto.ipynb                    # Yocto documentation
│   │   │
│   │   ├── meta-userapp/                  # Custom application layer
│   │   │   ├── conf/
│   │   │   │   └── layer.conf             # Layer metadata
│   │   │   ├── classes/
│   │   │   │   └── useradd.bbclass        # User management class
│   │   │   ├── recipes-apps/
│   │   │   │   └── audio-transcription/   # Qt audio app recipe
│   │   │   ├── recipes-connectivity/
│   │   │   │   ├── wpa-supplicant/        # WiFi configuration
│   │   │   │   └── dhcpcd/                # Network management
│   │   │   ├── recipes-core/
│   │   │   │   └── custom/                # User/group management
│   │   │   ├── recipes-docker/
│   │   │   │   └── audio-backend/         # Docker container recipe
│   │   │   ├── recipes-kernel/
│   │   │   │   └── linux/                 # Kernel configuration
│   │   │   ├── recipes-multimedia/
│   │   │   │   ├── ffmpeg/                # FFmpeg configuration
│   │   │   │   └── gstreamer/             # GStreamer plugins
│   │   │   ├── recipes-qt/
│   │   │   │   ├── qt6/                   # Qt6 multimedia config
│   │   │   │   └── qtbase/                # Qt base configuration
│   │   │   └── recipes-support/
│   │   │       └── opencv/                # OpenCV integration
│   │   │
│   │   └── All/                           # Complete Yocto sources
│   │       ├── meta/                      # Core Poky layer
│   │       ├── meta-poky/                 # Poky distro policies
│   │       ├── meta-raspberrypi/          # RPi BSP layer
│   │       ├── meta-openembedded/         # OE layers
│   │       ├── meta-virtualization/       # Docker support
│   │       ├── meta-qt6/                  # Qt6 framework
│   │       └── meta-docker/               # Docker recipes
│   │
│   └── analyze.ipynb                      # Project analysis notebook
│
└── README.md                              # This file
```

---

## 🚀 Getting Started

### Prerequisites

#### Host System Requirements
- **OS**: Ubuntu 20.04/22.04 LTS (recommended) or compatible Linux distribution
- **RAM**: 16GB minimum (32GB recommended)
- **Storage**: 200GB free space for Yocto build
- **CPU**: Quad-core or better (8+ cores recommended)
- **Internet**: High-speed connection for downloading sources

#### Required Host Packages

```bash
# Update package list
sudo apt update

# Install essential build tools
sudo apt install -y \
    build-essential chrpath cpio debianutils diffstat file gawk gcc git \
    iputils-ping libacl1 liblz4-tool locales python3 python3-git \
    python3-jinja2 python3-pexpect python3-pip python3-subunit socat \
    texinfo unzip wget xz-utils zstd

# Install additional tools
sudo apt install -y \
    pylint python3-pyinotify bmap-tools screen
```

---

### Yocto Build Setup

#### 1. Create Working Directory

```bash
# Create project directory
mkdir -p ~/Projects/Yocto/Yocto_sources
cd ~/Projects/Yocto/Yocto_sources

# Configure Git for large repositories
git config --global http.postBuffer 3145728000
git config --global http.lowSpeedLimit 0
git config --global http.lowSpeedTime 999999
```

#### 2. Clone Required Layers

```bash
# Clone Poky (Yocto reference distribution) - Kirkstone branch
git clone -b kirkstone git://git.yoctoproject.org/poky.git

# Clone Raspberry Pi BSP layer
git clone -b kirkstone git://git.yoctoproject.org/meta-raspberrypi

# Clone OpenEmbedded layers
git clone -b kirkstone git://git.openembedded.org/meta-openembedded

# Clone virtualization layer (for Docker)
git clone -b kirkstone git://git.yoctoproject.org/meta-virtualization

# Clone Qt6 layer
git clone -b kirkstone https://github.com/meta-qt5/meta-qt6.git
```

#### 3. Copy Project Configuration Files

```bash
# Copy bblayers.conf
cp /path/to/project/Yocto/bblayers.conf poky/build/conf/

# Copy local.conf
cp /path/to/project/Yocto/local.conf poky/build/conf/

# Copy meta-userapp layer
cp -r /path/to/project/Yocto/meta-userapp poky/
```

#### 4. Update Configuration Paths

Edit `poky/build/conf/bblayers.conf` and update all paths to match your system:

```bash
# Example: Change this
/home/ferganey/Projects/Yocto/Yocto_sources/poky/meta

# To your actual path
/home/YOUR_USERNAME/Projects/Yocto/Yocto_sources/poky/meta
```

---

### Building the Image

#### 1. Initialize Build Environment

```bash
cd ~/Projects/Yocto/Yocto_sources/poky
source oe-init-build-env
```

#### 2. Verify Layer Configuration

```bash
# List all configured layers
bitbake-layers show-layers

# Expected output should include:
# - meta
# - meta-poky
# - meta-raspberrypi
# - meta-oe
# - meta-python
# - meta-networking
# - meta-multimedia
# - meta-filesystems
# - meta-virtualization
# - meta-docker
# - meta-qt6
# - meta-userapp
```

#### 3. Build the Base Image

```bash
# Build the complete image (this will take 4-8 hours on first build)
bitbake core-image-base

# To skip errors and continue building
bitbake -k core-image-base
```

#### 4. Monitor Build Progress

The build output will be located at:
```
~/Projects/Yocto/Yocto_sources/poky/build/tmp/deploy/images/raspberrypi4-64/
```

Expected output files:
- `core-image-base-raspberrypi4-64-YYYYMMDDHHMMSS.rootfs.wic.bz2` (SD card image)
- `core-image-base-raspberrypi4-64-YYYYMMDDHHMMSS.rootfs.tar.bz2` (Root filesystem)
- `core-image-base-raspberrypi4-64-YYYYMMDDHHMMSS.rootfs.wic.bmap` (Block map for fast flashing)

---

### Flashing to SD Card

#### Method 1: Using bmaptool (Recommended)

```bash
# Install bmaptool if not already installed
sudo apt install bmap-tools

# Navigate to image directory
cd ~/Projects/Yocto/Yocto_sources/poky/build/tmp/deploy/images/raspberrypi4-64/

# Flash to SD card (replace /dev/sdX with your actual SD card device)
sudo bmaptool copy core-image-base-raspberrypi4-64-*.rootfs.wic.bz2 /dev/sdX

# ⚠️ WARNING: Double-check the device name to avoid data loss!
# Use 'lsblk' to identify your SD card
```

#### Method 2: Using dd

```bash
# Decompress the image
bunzip2 core-image-base-raspberrypi4-64-*.rootfs.wic.bz2

# Flash to SD card
sudo dd if=core-image-base-raspberrypi4-64-*.rootfs.wic of=/dev/sdX bs=4M status=progress

# Sync to ensure all data is written
sudo sync
```

#### Method 3: Using balenaEtcher (GUI)

1. Download [balenaEtcher](https://www.balena.io/etcher/)
2. Select the `.wic.bz2` image file
3. Select your SD card
4. Click "Flash!"

---

## 🐳 Docker Deployment

### Building Docker Images for ARM64

The project includes Docker containerization for the audio transcription backend.

#### 1. Setup Docker Buildx

```bash
# Create a new builder instance for multi-platform builds
docker buildx create --use --name raspi4 --platform linux/arm64

# Bootstrap the builder
docker buildx inspect --bootstrap

# Enable QEMU for ARM emulation
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
```

#### 2. Build the Docker Image

```bash
# Navigate to the Docker application directory
cd audio_transcription_docker/

# Build for ARM64 and push to Docker Hub
docker buildx build --platform linux/arm64 \
    -t YOUR_DOCKERHUB_USERNAME/raspi4-voice-assistant:v1.0 \
    --push .

# Or build locally without pushing
docker buildx build --platform linux/arm64 \
    -t raspi4-voice-assistant:v1.0 \
    --load .
```

#### 3. Deploy on Raspberry Pi

```bash
# On the Raspberry Pi, pull the image
docker pull YOUR_DOCKERHUB_USERNAME/raspi4-voice-assistant:v1.0

# Run the container
docker run -d \
    --name voice-assistant \
    --device /dev/snd \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e DISPLAY=$DISPLAY \
    YOUR_DOCKERHUB_USERNAME/raspi4-voice-assistant:v1.0
```

---

## ⚙️ Configuration

### WiFi Setup

The system uses `wpa_supplicant` and `dhcpcd` for WiFi management.

#### Configure WiFi Credentials

**Option 1: Before Building (Recommended)**

Edit the WiFi configuration in `meta-userapp/recipes-connectivity/wpa-supplicant/files/wpa_supplicant.conf`:

```bash
# Generate encrypted password
wpa_passphrase 'YOUR_SSID' 'YOUR_PASSWORD' > wpa_supplicant.conf
```

**Option 2: On Running System**

```bash
# SSH into Raspberry Pi
ssh root@raspberrypi.local

# Edit wpa_supplicant configuration
nano /etc/wpa_supplicant/wpa_supplicant.conf

# Add your network
network={
    ssid="YOUR_SSID"
    psk="YOUR_PASSWORD"
}

# Restart services
systemctl restart wpa_supplicant-wlan0
systemctl restart dhcpcd
```

#### Verify WiFi Connection

```bash
# Check interface status
ifconfig wlan0

# Check IP address
ip addr show wlan0

# Ping test
ping -c 4 google.com
```

---

### Bluetooth Configuration

Bluetooth is enabled by default with bluez5 stack.

#### Check Bluetooth Status

```bash
# Check Bluetooth service
systemctl status bluetooth

# List Bluetooth devices
bluetoothctl

# Inside bluetoothctl
[bluetooth]# power on
[bluetooth]# agent on
[bluetooth]# default-agent
[bluetooth]# scan on
```

---

### Audio Configuration

#### List Audio Devices

```bash
# List ALSA playback devices
aplay -l

# List ALSA capture devices
arecord -l

# Test audio recording
arecord -D hw:1,0 -f cd test.wav

# Test audio playback
aplay test.wav
```

#### Configure Default Audio Device

Edit `/etc/asound.conf`:

```conf
pcm.!default {
    type hw
    card 1
}

ctl.!default {
    type hw
    card 1
}
```

---

## 👨‍💻 Development

### SDK Generation

Generate a cross-compilation SDK for application development:

```bash
# Generate SDK
bitbake core-image-base -c populate_sdk

# SDK will be located at:
# tmp/deploy/sdk/poky-glibc-x86_64-core-image-base-cortexa72-raspberrypi4-64-toolchain-4.0.24.sh

# Install the SDK
cd tmp/deploy/sdk
./poky-glibc-x86_64-core-image-base-cortexa72-raspberrypi4-64-toolchain-4.0.24.sh

# Follow prompts to install (default: /opt/poky/4.0.24)
```

---

### Qt Creator Setup

#### 1. Install Qt Creator

```bash
sudo apt install qtcreator
```

#### 2. Configure Cross-Compilation Toolchain

1. Open Qt Creator
2. Go to **Tools → Options → Kits**
3. Add a new kit:
   - **Name**: Raspberry Pi 4 64-bit
   - **Device type**: Generic Linux Device
   - **Compiler**: Browse to SDK compiler
     - C: `/opt/poky/4.0.24/sysroots/x86_64-pokysdk-linux/usr/bin/aarch64-poky-linux/aarch64-poky-linux-gcc`
     - C++: `/opt/poky/4.0.24/sysroots/x86_64-pokysdk-linux/usr/bin/aarch64-poky-linux/aarch64-poky-linux-g++`
   - **Qt version**: Auto-detected from SDK
   - **CMake**: System CMake

#### 3. Source SDK Environment

Before using Qt Creator or command-line compilation:

```bash
# Source the SDK environment
source /opt/poky/4.0.24/environment-setup-cortexa72-poky-linux

# Verify compiler
$CC --version
# Should output: aarch64-poky-linux-gcc

# Check Qt configuration
qmake -query
```

---

### Cross-Compilation

#### Example: Compile a Simple Application

**hello.c:**
```c
#include <stdio.h>

int main(void) {
    printf("Hello from Raspberry Pi 4!\n");
    return 0;
}
```

**Compile:**
```bash
# Source SDK environment
source /opt/poky/4.0.24/environment-setup-cortexa72-poky-linux

# Compile
$CC -o hello hello.c

# Verify architecture
file hello
# Output: hello: ELF 64-bit LSB executable, ARM aarch64...

# Deploy to Raspberry Pi
scp hello root@raspberrypi.local:/home/root/

# Run on Raspberry Pi
ssh root@raspberrypi.local
./hello
```

---

## 📱 Usage

### Starting the Voice Assistant

#### Method 1: Qt GUI Application

```bash
# On Raspberry Pi
cd /usr/share/audio-transcription/
python3 main.py
```

#### Method 2: Docker Container

```bash
# Start the Docker container
docker start voice-assistant

# View logs
docker logs -f voice-assistant
```

### Using the Voice Assistant

1. **Activate**: Say wake word "Hey AutoTalk" or click microphone button
2. **Speak**: Give your command clearly (e.g., "Navigate to nearest charging station")
3. **Processing**: System converts speech to text and analyzes intent
4. **Action**: Command is executed by the vehicle system
5. **Feedback**: Audio/visual confirmation of action

---

## 🔍 Troubleshooting

### Build Errors

**Problem**: BitBake fails with fetch errors
```bash
# Solution: Clean shared state and retry
bitbake -c cleansstate RECIPE_NAME
bitbake RECIPE_NAME
```

**Problem**: Disk space issues during build
```bash
# Solution: Clean build artifacts
bitbake -c clean RECIPE_NAME
rm -rf tmp/
```

---

### WiFi Issues

**Problem**: WiFi not connecting
```bash
# Check driver
lsmod | grep brcmfmac

# Check wpa_supplicant
systemctl status wpa_supplicant-wlan0

# Check logs
journalctl -u wpa_supplicant-wlan0 -f

# Restart services
systemctl restart wpa_supplicant-wlan0
systemctl restart dhcpcd
```

---

### Audio Issues

**Problem**: No audio input/output
```bash
# Check ALSA devices
aplay -l
arecord -l

# Test playback
speaker-test -c2

# Check permissions
ls -l /dev/snd/

# Add user to audio group
usermod -a -G audio ferganey
```

---

### Docker Issues

**Problem**: Docker daemon not starting
```bash
# Check Docker service
systemctl status docker

# Check Docker info
docker info

# Restart Docker
systemctl restart docker

# Check kernel support
/usr/share/docker/check-config.sh
```

---

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/AmazingFeature`)
3. **Commit** your changes (`git commit -m 'Add some AmazingFeature'`)
4. **Push** to the branch (`git push origin feature/AmazingFeature`)
5. **Open** a Pull Request

### Development Guidelines

- Follow Python PEP 8 style guidelines
- Write clear commit messages
- Add documentation for new features
- Test changes on actual hardware
- Update README if needed

---

## 📚 References

### Official Documentation
- [Yocto Project Documentation](https://docs.yoctoproject.org/)
- [Raspberry Pi Documentation](https://www.raspberrypi.org/documentation/)
- [Qt6 Documentation](https://doc.qt.io/qt-6/)
- [Docker Documentation](https://docs.docker.com/)
- [OpenAI Whisper](https://github.com/openai/whisper)

### Useful Resources
- [Yocto Project Quick Start](https://docs.yoctoproject.org/brief-yoctoprojectqs/index.html)
- [Meta-Raspberrypi Layer](https://github.com/agherzan/meta-raspberrypi)
- [Meta-Virtualization](https://git.yoctoproject.org/meta-virtualization/)
- [Using Containers on Embedded Linux](https://sergioprado.blog/using-containers-on-embedded-linux/)

### Video Tutorials
- [Yocto Project Tutorial Series](https://www.youtube.com/playlist?list=PLBn6-C63fDkFBuKHXNnB8TzAoJpdl0AmA)
- [Raspberry Pi Setup Guide](https://www.youtube.com/watch?v=2RHuDKq7ONQ)
- [Docker on Embedded Systems](https://www.youtube.com/watch?v=b3ViCfkU3J4)

---

## 📄 License

This project is **CLOSED** source. All rights reserved.

For licensing inquiries, please contact: [ahmed.ferganey707@gmail.com](mailto:ahmed.ferganey707@gmail.com)

---

## 📧 Contact

**Project Maintainer**: Ahmed Ferganey

- **Email**: ahmed.ferganey707@gmail.com
- **Docker Hub**: [ahmedferganey](https://hub.docker.com/u/ahmedferganey)

---

## 🙏 Acknowledgments

- Raspberry Pi Foundation for hardware platform
- Yocto Project community for build system
- OpenAI for Whisper speech recognition model
- Qt Company for GUI framework
- Docker Inc. for containerization technology

---

**Last Updated**: October 2024  
**Version**: 1.0  
**Status**: Active Development

---

<div align="center">
Made with ❤️ for Autonomous Vehicles
</div>
