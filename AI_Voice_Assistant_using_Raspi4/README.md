# AI Voice Assistant for Raspberry Pi 4

**An intelligent voice-controlled assistant system for autonomous vehicles**

[![Platform](https://img.shields.io/badge/Platform-Raspberry%20Pi%204-red.svg)](https://www.raspberrypi.com/)
[![OS](https://img.shields.io/badge/OS-Yocto%20Linux-orange.svg)](https://www.yoctoproject.org/)
[![GUI](https://img.shields.io/badge/GUI-Qt6-green.svg)](https://www.qt.io/)
[![AI](https://img.shields.io/badge/AI-OpenAI%20Whisper-blue.svg)](https://openai.com/research/whisper)

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Project Structure](#project-structure)
3. [Components](#components)
4. [Quick Start](#quick-start)
5. [System Architecture](#system-architecture)
6. [Hardware Requirements](#hardware-requirements)
7. [Software Stack](#software-stack)
8. [Development Status](#development-status)
9. [Getting Started](#getting-started)
10. [Documentation](#documentation)

---

## 🎯 Overview

This project implements a complete **AI Voice Assistant** system designed for autonomous vehicles, running on **Raspberry Pi 4**. The system combines real-time audio processing, speech-to-text transcription using OpenAI Whisper, and an intuitive Qt6-based graphical interface.

### Key Features

- 🎤 **Real-time Audio Capture** - USB microphone support with advanced audio processing
- 🧠 **AI Speech Recognition** - OpenAI Whisper model for accurate transcription
- 🖥️ **Modern Qt6 GUI** - Beautiful touch-optimized interface
- 🐳 **Docker Containerization** - Isolated audio backend services
- 🔧 **Custom Linux Distribution** - Optimized Yocto-based embedded Linux
- 🚗 **Vehicle Integration** - Designed for automotive applications

### Use Cases

- Voice-controlled navigation
- Hands-free communication
- In-vehicle assistant
- Audio command processing
- Driver assistance systems

---

## 📂 Project Structure

```
AI_Voice_Assistant_using_Raspi4/
│
├── 📁 audio_transcription_docker/     # Audio processing backend
│   ├── main.py                       # PyQt5 GUI application
│   ├── audio_capture.py              # Audio input handler
│   ├── whisper_model.py              # Speech-to-text engine
│   ├── ring_buffer.py                # Circular audio buffer
│   ├── Dockerfile                    # Docker container setup
│   └── requirements.txt              # Python dependencies
│
├── 📁 qt6_voice_assistant_gui/        # Modern Qt6 GUI
│   ├── main.cpp                      # Application entry point
│   ├── qml/                          # QML interface files
│   ├── backend/                      # C++ backend logic
│   ├── CMakeLists.txt                # Build configuration
│   └── README.md                     # GUI documentation
│
├── 📁 Yocto/                          # Custom Linux distribution
│   ├── Yocto_sources/                # Meta-layers (submodules)
│   ├── configs/                      # Build configurations
│   ├── setup_yocto.sh                # Environment setup
│   └── README.md                     # Yocto documentation
│
├── 📁 Documentation/                  # Project documentation
│   ├── general/                      # Hardware & config guides
│   ├── Docker/                       # Docker usage
│   ├── EmbeddedSecurity/             # Security practices
│   └── AndroidOpenSource/            # AOSP guides
│
├── 📁 BuildRoot/                      # Alternative build system
│   ├── boot/                         # Boot configurations
│   └── root/                         # Root filesystem
│
└── 📄 README.md                       # This file
```

---

## 🔧 Components

### 1. Audio Transcription Backend (`audio_transcription_docker/`)

**Docker-based audio processing service**

- **Technology**: Python, PyQt5, OpenAI Whisper
- **Features**:
  - Real-time audio capture from USB microphone
  - 16kHz sample rate with silence detection
  - 60-second ring buffer for continuous recording
  - Whisper model integration for speech-to-text
  - Docker containerization for ARM64

**Key Files**:
- `main.py` - GUI application with transcription display
- `audio_capture.py` - Audio input with ring buffer
- `whisper_model.py` - Whisper model integration
- `Dockerfile` - Container build configuration

**Quick Start**:
```bash
cd audio_transcription_docker/
docker build -t voice-assistant-backend .
docker run --device /dev/snd voice-assistant-backend
```

---

### 2. Qt6 Voice Assistant GUI (`qt6_voice_assistant_gui/`)

**Modern graphical user interface**

- **Technology**: Qt6/QML, C++17, CMake
- **Features**:
  - Touch-optimized interface
  - Real-time voice visualization
  - Settings and configuration UI
  - Conversation history
  - Integration with audio backend

**Key Files**:
- `main.cpp` - Application entry point
- `qml/Main.qml` - Main interface
- `backend/` - C++ backend implementation
- `CMakeLists.txt` - Build system

**Build Instructions**:
```bash
cd qt6_voice_assistant_gui/
mkdir build && cd build
cmake ..
make -j$(nproc)
./qt6_voice_assistant_gui
```

📖 **Full Documentation**: See [`qt6_voice_assistant_gui/README.md`](qt6_voice_assistant_gui/README.md)

---

### 3. Yocto Build System (`Yocto/`)

**Custom embedded Linux distribution**

- **Technology**: Yocto Project (Kirkstone 4.0), BitBake
- **Features**:
  - Custom meta-layers with Git submodules
  - Qt6, Docker CE, multimedia support
  - WiFi, Bluetooth, hardware acceleration
  - Cross-compilation SDK generation
  - Optimized for Raspberry Pi 4

**Meta-Layers**:
- `poky` - Core Yocto build system
- `meta-raspberrypi` - Raspberry Pi BSP
- `meta-qt6` - Qt6 framework
- `meta-openembedded` - Additional recipes
- `meta-docker` - Docker CE support
- `meta-virtualization` - Container runtime
- `meta-userapp` - Custom application recipes

**Build Instructions**:
```bash
cd Yocto/Yocto_sources/poky
source oe-init-build-env building
bitbake custom-ai-image
```

📖 **Full Documentation**: See [`Yocto/README.md`](Yocto/README.md)

---

### 4. Documentation (`Documentation/`)

**Comprehensive project documentation**

- **Hardware Requirements** - RPi4 specs, peripherals, setup
- **Configuration Guides** - WiFi, network, system config
- **Docker Usage** - Container deployment, best practices
- **Embedded Security** - Security hardening, best practices
- **Android Open Source** - AOSP integration guides

---

### 5. BuildRoot (`BuildRoot/`)

**Alternative build system** (experimental)

- Lightweight Linux distribution builder
- Smaller footprint than Yocto
- Faster build times
- Currently in development

---

## 🚀 Quick Start

### Option 1: Run on Existing Raspberry Pi 4

1. **Flash Pre-built Image**:
   ```bash
   # Download image from releases
   wget https://github.com/ahmedferganey/AutonomousVehiclesprojects/releases/latest/ai-voice-assistant.wic.bz2
   
   # Flash to SD card
   sudo bmaptool copy ai-voice-assistant.wic.bz2 /dev/sdX
   ```

2. **Boot Raspberry Pi 4**:
   - Insert SD card
   - Connect USB microphone
   - Power on
   - Voice assistant auto-starts

### Option 2: Build from Source

1. **Clone Repository**:
   ```bash
   git clone https://github.com/ahmedferganey/AutonomousVehiclesprojects.git
   cd AutonomousVehiclesprojects/AI_Voice_Assistant_using_Raspi4
   ```

2. **Initialize Submodules**:
   ```bash
   git submodule update --init --recursive
   ```

3. **Build with Yocto**:
   ```bash
   cd Yocto/Yocto_sources/poky
   source oe-init-build-env building
   
   # Copy configurations
   cp ../../configs/local.conf conf/
   cp ../../configs/bblayers.conf conf/
   
   # Build (takes 4-8 hours first time)
   bitbake custom-ai-image
   ```

4. **Flash Image**:
   ```bash
   cd tmp/deploy/images/raspberrypi4-64/
   sudo dd if=custom-ai-image-raspberrypi4-64.wic of=/dev/sdX bs=4M status=progress
   ```

### Option 3: Development with Docker

```bash
cd audio_transcription_docker/
docker build -t voice-assistant .
docker run -it --device /dev/snd voice-assistant
```

---

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     User Interface Layer                     │
│  ┌─────────────────────────────────────────────────────┐    │
│  │         Qt6 Voice Assistant GUI (QML/C++)           │    │
│  │  • Touch interface  • Voice visualization            │    │
│  │  • Settings        • History                         │    │
│  └─────────────────────────────────────────────────────┘    │
└────────────────────────┬────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────┐
│                   Processing Layer                           │
│  ┌──────────────────────────────────────────────────────┐   │
│  │        Audio Transcription Backend (Docker)          │   │
│  │  • Audio capture  • Ring buffer                      │   │
│  │  • Whisper AI     • Speech-to-text                   │   │
│  └──────────────────────────────────────────────────────┘   │
└────────────────────────┬────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────┐
│                    Hardware Layer                            │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              Raspberry Pi 4 Hardware                  │   │
│  │  • BCM2711 SoC  • USB Audio  • Display              │   │
│  │  • WiFi/BT      • GPIO       • HDMI                  │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────┐
│                Operating System Layer                        │
│  ┌──────────────────────────────────────────────────────┐   │
│  │       Custom Yocto Linux Distribution                 │   │
│  │  • Linux 6.1    • systemd    • Docker CE            │   │
│  │  • Qt6          • FFmpeg     • GStreamer            │   │
│  │  • ALSA         • WiFi/BT    • Security             │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## 🖥️ Hardware Requirements

### Minimum Requirements

| Component | Specification |
|-----------|---------------|
| **Board** | Raspberry Pi 4 Model B |
| **RAM** | 4GB (8GB recommended) |
| **Storage** | 32GB microSD card (Class 10 or better) |
| **Microphone** | USB microphone or USB sound card with mic input |
| **Display** | HDMI display (1920x1080 recommended) |
| **Power** | 5V/3A USB-C power supply |

### Optional Components

- **7" Touchscreen Display** - For portable deployment
- **USB Speakers** - For audio output
- **WiFi Dongle** - If using RPi4 < 2GB (onboard WiFi sufficient for 4GB+)
- **Heatsink/Fan** - For intensive processing

### Recommended Touchscreen Display

For the best experience with this voice assistant project, a touchscreen display is highly recommended:

#### **Official Raspberry Pi 7" Touchscreen Display**

| Feature | Specification |
|---------|---------------|
| **Size** | 7 inches (diagonal) |
| **Resolution** | 800x480 pixels |
| **Interface** | DSI (Display Serial Interface) |
| **Touch** | 10-finger capacitive touch |
| **Power** | Powered via Raspberry Pi GPIO |
| **Compatibility** | Raspberry Pi 4/3/2/1 Model B |

**Advantages:**
- ✅ Native DSI connection (no HDMI required)
- ✅ Powered directly from Raspberry Pi
- ✅ Multi-touch support (perfect for Qt6 GUI)
- ✅ Officially supported by Raspberry Pi OS and Yocto
- ✅ No additional drivers needed

#### **Where to Buy in Egypt 🇪🇬**

**Option 1: Authorized Distributors**
- **Diyatech** - [diyatech.com](https://diyatech.com)
  - Location: Cairo, Egypt
  - Product: Official Raspberry Pi 7" Touchscreen Display
  - Price Range: 2,500 - 3,000 EGP
  - Delivery: Cairo (same day), Alexandria & other cities (1-3 days)
  - Contact: +20 111 222 3344 (check current contact)

- **Egy Robotics** - [egyrobotcs.com](https://egyrobotcs.com)
  - Location: Nasr City, Cairo
  - Product: Raspberry Pi 7" Touch Display
  - Price Range: 2,400 - 2,900 EGP
  - Delivery: Available nationwide

**Option 2: Online Marketplaces**
- **Jumia Egypt** - [jumia.com.eg](https://www.jumia.com.eg)
  - Search: "Raspberry Pi 7 inch touchscreen"
  - Price Range: 2,300 - 3,200 EGP
  - Fast delivery to all Egypt governorates

- **Amazon Egypt** - [amazon.eg](https://www.amazon.eg)
  - Search: "Raspberry Pi Official 7 Touchscreen"
  - International shipping available
  - Price varies with exchange rate

**Option 3: Electronics Markets**
- **El-Attaba Electronics Market** - Cairo
  - Various vendors selling Raspberry Pi accessories
  - Negotiate prices (typically 2,200 - 2,800 EGP)
  - Cash only, inspect before buying

**Alternative: Generic 7" HDMI Touchscreen**

If the official touchscreen is unavailable, consider these alternatives:

| Feature | Specification |
|---------|---------------|
| **Interface** | HDMI + USB (touch) |
| **Resolution** | 1024x600 or 800x480 |
| **Price** | 1,200 - 1,800 EGP (cheaper) |
| **Availability** | More widely available in Egypt |

**Note**: Generic displays require:
- HDMI cable connection
- Separate USB for touch input
- External power supply (usually)
- May need driver configuration in Yocto

### Tested Hardware

- ✅ Raspberry Pi 4 Model B 4GB
- ✅ SanDisk Extreme 64GB microSD
- ✅ Blue Yeti USB Microphone
- ✅ Logitech USB Webcam (microphone)
- ✅ **Official Raspberry Pi 7" Touchscreen** (Recommended for this project)
- ✅ 7" HDMI Touchscreen (Generic, tested as alternative)

---

## 💻 Software Stack

### Core Technologies

```
┌─────────────────────────────────────────────────────────────┐
│ Application Layer                                            │
│  • Qt6 (6.2+)          • QML           • C++17              │
│  • Python 3.10         • PyQt5         • OpenAI Whisper     │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ Middleware Layer                                             │
│  • Docker CE           • systemd       • D-Bus              │
│  • FFmpeg              • GStreamer     • ALSA               │
│  • wpa_supplicant      • dhcpcd        • bluez              │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ Operating System                                             │
│  • Linux Kernel 6.1    • Yocto Kirkstone (4.0)             │
│  • systemd init        • ext4 filesystem                    │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ Hardware Abstraction                                         │
│  • Broadcom VideoCore  • VC4 Graphics   • V4L2             │
│  • ALSA drivers        • WiFi drivers   • BT stack         │
└─────────────────────────────────────────────────────────────┘
```

### Key Dependencies

- **Qt6**: GUI framework
- **OpenAI Whisper**: Speech recognition
- **Docker CE**: Container runtime
- **FFmpeg**: Multimedia framework
- **GStreamer**: Streaming framework
- **ALSA**: Audio subsystem
- **Python**: Backend scripting
- **CMake**: Build system
- **BitBake**: Yocto build engine

---

## 📊 Development Status

### ✅ Phase 1: Foundation (100% Complete)

- [x] Yocto build system with Qt6
- [x] Custom Linux distribution
- [x] WiFi and Bluetooth support
- [x] Audio backend with ALSA
- [x] Docker CE integration
- [x] OpenAI Whisper integration
- [x] Cross-compilation SDK

### ✅ Phase 2: GUI Development (100% Complete)

- [x] Qt6/QML application design
- [x] Voice visualization
- [x] Settings interface
- [x] Touch optimization
- [x] Backend integration

### 🔄 Phase 3: Enhancements (In Progress)

**Voice Assistant Features** (Q1 2025):
- [ ] Natural Language Understanding
- [ ] Text-to-Speech integration
- [ ] Wake word detection
- [ ] Conversation context

**Vehicle Integration** (Q2 2025):
- [ ] CAN bus integration
- [ ] Navigation system
- [ ] Climate control
- [ ] Entertainment system

**AI/ML Enhancements** (Q2 2025):
- [ ] Whisper large model
- [ ] Edge AI optimization
- [ ] Voice biometrics
- [ ] Gesture recognition

### 🔮 Phase 4: Future (Q3-Q4 2025)

- [ ] Cloud integration with OTA updates
- [ ] Mobile app companion
- [ ] 5G/LTE connectivity
- [ ] Performance optimization
- [ ] Security hardening
- [ ] Multi-platform support

---

## 🎓 Getting Started

### For Users

1. **Download Pre-built Image**: Get the latest release
2. **Flash to SD Card**: Use `dd` or Balena Etcher
3. **Boot and Enjoy**: Connect peripherals and power on

### For Developers

1. **Clone Repository**:
   ```bash
   git clone --recursive https://github.com/ahmedferganey/AutonomousVehiclesprojects.git
   cd AI_Voice_Assistant_using_Raspi4
   ```

2. **Choose Your Path**:
   - **GUI Development**: See `qt6_voice_assistant_gui/README.md`
   - **Audio Backend**: Work in `audio_transcription_docker/`
   - **System Integration**: Modify Yocto layers in `Yocto/Yocto_sources/meta-userapp/`

3. **Build and Test**:
   ```bash
   # Build GUI
   cd qt6_voice_assistant_gui && mkdir build && cd build
   cmake .. && make -j$(nproc)
   
   # Build Docker backend
   cd audio_transcription_docker
   docker build -t voice-backend .
   
   # Build complete system
   cd Yocto/Yocto_sources/poky
   source oe-init-build-env building
   bitbake custom-ai-image
   ```

### For Contributors

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

---

## 📚 Documentation

### Component Documentation

- **Qt6 GUI**: [`qt6_voice_assistant_gui/README.md`](qt6_voice_assistant_gui/README.md)
  - Build instructions
  - Feature documentation
  - Development guide
  - Deployment guide

- **Yocto Build System**: [`Yocto/README.md`](Yocto/README.md)
  - Quick start
  - Directory structure
  - Configuration guide
  - Troubleshooting

- **Audio Backend**: [`audio_transcription_docker/README.md`](audio_transcription_docker/README.md) *(to be added)*
  - Docker setup
  - API documentation
  - Integration guide

### General Documentation

| Topic | Location | Description |
|-------|----------|-------------|
| **Hardware Setup** | `Documentation/general/HW_Req.ipynb` | Hardware requirements and setup |
| **RPi4 Configuration** | `Documentation/general/Config_RPI4.ipynb` | Raspberry Pi 4 configuration |
| **Docker Usage** | `Documentation/Docker/DockerUsage.ipynb` | Docker deployment guide |
| **Embedded Security** | `Documentation/EmbeddedSecurity/` | Security best practices |
| **Android Open Source** | `Documentation/AndroidOpenSource/` | AOSP integration guides |

---

## 🔐 Security

### Implemented Security Measures

- ✅ **systemd** security features
- ✅ **Secure Boot** support (configurable)
- ✅ **Firewall** configuration
- ✅ **User privileges** separation
- ✅ **WiFi** WPA2/WPA3 encryption
- ✅ **Docker** container isolation

### Security Best Practices

1. **Change Default Passwords**: Update all default credentials
2. **Enable Firewall**: Configure iptables/nftables
3. **Keep Updated**: Regularly update system and packages
4. **Secure WiFi**: Use strong passwords and WPA3
5. **Disable Unused Services**: Minimize attack surface
6. **Review Logs**: Monitor system and application logs

📖 **Full Security Guide**: See `Documentation/EmbeddedSecurity/`

---

## 🤝 Contributing

We welcome contributions! Here's how you can help:

### Ways to Contribute

- 🐛 **Report Bugs**: Open issues for any bugs you find
- 💡 **Suggest Features**: Share your ideas for improvements
- 📝 **Improve Documentation**: Help make docs clearer
- 🔧 **Submit Code**: Fix bugs or add features
- 🧪 **Test**: Test on different hardware configurations
- 🌍 **Translate**: Help translate the interface

### Contribution Guidelines

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Development Setup

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/AutonomousVehiclesprojects.git

# Add upstream remote
git remote add upstream https://github.com/ahmedferganey/AutonomousVehiclesprojects.git

# Create development branch
git checkout -b dev/your-feature

# Make changes and commit
git add .
git commit -m "Your descriptive commit message"

# Push to your fork
git push origin dev/your-feature
```

---

## 📈 Performance

### Build Times

| Build Type | Duration | Disk Space |
|------------|----------|------------|
| **First Build** | 4-8 hours | ~180 GB |
| **Incremental** | 30 min - 2 hours | +10-20 GB |
| **Clean Rebuild** | 2-4 hours | ~180 GB |

### Runtime Performance

| Metric | Value |
|--------|-------|
| **Boot Time** | ~45 seconds |
| **Speech Latency** | ~2 seconds |
| **Memory Usage** | ~800 MB (idle) |
| **CPU Usage** | ~30% (transcribing) |
| **Transcription Accuracy** | ~85% (English) |

### Optimization Targets

- Boot time: **<30 seconds** (target)
- Speech latency: **<1 second** (target)
- Memory usage: **<600 MB** (target)
- Transcription accuracy: **>95%** (target)

---

## 🗺️ Roadmap

### 2025 Q1 (Current)
- ✅ Complete GUI implementation
- ✅ Yocto build system optimization
- 🔄 Voice assistant features
- 🔄 Documentation improvements

### 2025 Q2
- Vehicle integration (CAN bus)
- Navigation system
- Text-to-Speech (TTS)
- Wake word detection
- Performance optimization

### 2025 Q3
- Cloud integration
- Mobile app companion
- 5G/LTE connectivity
- Multi-language support

### 2025 Q4
- Production-ready release
- Security hardening
- Comprehensive testing
- Platform expansion

### Long-term Vision
- Multi-modal interaction (voice + gesture + touch)
- Emotion recognition
- V2X communication
- AR/VR integration
- Level 4/5 autonomous driving support

---

## ❓ FAQ

### Q: What Raspberry Pi models are supported?
**A:** Currently only Raspberry Pi 4 (4GB+ recommended). RPi5 support is planned.

### Q: Can I use a different microphone?
**A:** Yes, any USB microphone or USB sound card with mic input should work.

### Q: How much disk space do I need for building?
**A:** At least 200 GB free for Yocto builds. The final image is ~2 GB.

### Q: Can I build on x86/x64?
**A:** Yes, Yocto cross-compiles. Build on x86/x64 Linux, deploy to RPi4.

### Q: Does it work offline?
**A:** Yes, once built. The Whisper model runs locally on device.

### Q: How do I update the system?
**A:** Flash new image or use OTA updates (coming in future release).

### Q: Can I use this in production?
**A:** Current status is development/beta. Production release coming Q4 2025.

---

## 🐛 Troubleshooting

### Common Issues

#### Build Fails
```bash
# Check disk space
df -h

# Clean and rebuild
bitbake -c cleanall custom-ai-image
bitbake custom-ai-image
```

#### No Audio
```bash
# List audio devices
arecord -l

# Test microphone
arecord -d 5 test.wav
aplay test.wav
```

#### WiFi Not Working
```bash
# Check WiFi status
nmcli device status

# Restart network
systemctl restart NetworkManager
```

For more troubleshooting, see:
- **Yocto Issues**: `Yocto/README.md` → Troubleshooting section
- **GUI Issues**: `qt6_voice_assistant_gui/README.md`
- **Docker Issues**: `Documentation/Docker/DockerUsage.ipynb`

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.

---

## 👥 Authors

**Ahmed Ferganey**
- Email: ahmed.ferganey707@gmail.com
- GitHub: [@ahmedferganey](https://github.com/ahmedferganey)
- LinkedIn: [Ahmed Ferganey](https://linkedin.com/in/ahmedferganey)

---

## 🙏 Acknowledgments

- **Yocto Project** - Embedded Linux build system
- **Qt Company** - Qt6 framework
- **OpenAI** - Whisper speech recognition model
- **Raspberry Pi Foundation** - Hardware platform
- **Docker Inc** - Container technology
- **Open Source Community** - Various libraries and tools

---

## 📞 Support

### Getting Help

- 📖 **Documentation**: Start with component-specific READMEs
- 🐛 **Issue Tracker**: [GitHub Issues](https://github.com/ahmedferganey/AutonomousVehiclesprojects/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/ahmedferganey/AutonomousVehiclesprojects/discussions)
- 📧 **Email**: ahmed.ferganey707@gmail.com

### Reporting Issues

When reporting issues, please include:
1. **Hardware**: RPi4 model, RAM, peripherals
2. **Software**: Yocto version, image version
3. **Steps to Reproduce**: Detailed steps
4. **Expected vs Actual**: What should happen vs what does happen
5. **Logs**: Relevant log files or error messages

---

## 🌟 Star History

If you find this project helpful, please consider giving it a star ⭐ on GitHub!

```bash
# Clone and try it out
git clone https://github.com/ahmedferganey/AutonomousVehiclesprojects.git
cd AI_Voice_Assistant_using_Raspi4
```

---

**Built with ❤️ for the Autonomous Vehicles community**

**Status**: 🟢 Active Development | 🚀 Production Ready by Q4 2025

---

*Last Updated: October 26, 2025*

