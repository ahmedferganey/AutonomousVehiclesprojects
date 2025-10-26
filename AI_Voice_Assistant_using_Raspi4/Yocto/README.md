# AI Voice Assistant - Yocto Build System

**Project:** AI Voice Assistant for Raspberry Pi 4  
**Build System:** Yocto Project (Kirkstone)  
**Status:** ✅ Production Ready  
**Repository:** https://github.com/ahmedferganey/AutonomousVehiclesprojects

---

## 📋 Table of Contents

1. [Quick Start](#quick-start)
2. [Directory Structure](#directory-structure)
3. [Build Instructions](#build-instructions)
4. [Git Submodules](#git-submodules)
5. [Configuration](#configuration)
6. [Troubleshooting](#troubleshooting)
7. [Repository Information](#repository-information)

---

## 🚀 Quick Start

### On This Machine (Already Set Up)

```bash
cd Yocto_sources/poky
source oe-init-build-env building
bitbake custom-ai-image
```

### On a New Machine (Fresh Clone)

```bash
# 1. Clone the repository
git clone https://github.com/ahmedferganey/AutonomousVehiclesprojects.git
cd AutonomousVehiclesprojects

# 2. Initialize Git submodules
git submodule update --init --recursive

# 3. Copy configuration files
cd AI_Voice_Assistant_using_Raspi4/Yocto
cp configs/local.conf Yocto_sources/poky/building/conf/
cp configs/bblayers.conf Yocto_sources/poky/building/conf/

# 4. Start building
cd Yocto_sources/poky
source oe-init-build-env building
bitbake custom-ai-image
```

---

## 📂 Directory Structure

```
AI_Voice_Assistant_using_Raspi4/Yocto/
│
├── configs/                          # Configuration files (tracked in Git)
│   ├── local.conf                   # Build settings
│   ├── bblayers.conf                # Layer configuration
│   └── README.md                    # Config documentation
│
├── Yocto_sources/                    # All Yocto layers (Git submodules)
│   │
│   ├── poky/                         # Main Yocto build system
│   │   ├── bitbake/                 # Build engine
│   │   ├── meta/                    # Core layer
│   │   ├── meta-poky/               # Poky distribution
│   │   ├── scripts/                 # Build scripts
│   │   └── building/                # Build directory
│   │       ├── conf/                # Active configuration
│   │       ├── downloads/            # Downloaded sources (26GB)
│   │       ├── cache/               # BitBake cache
│   │       ├── tmp/                 # Build output
│   │       └── sstate-cache/        # Shared state cache
│   │
│   ├── meta-openembedded/            # Additional recipes
│   ├── meta-raspberrypi/             # Raspberry Pi BSP
│   ├── meta-qt6/                     # Qt6 framework
│   ├── meta-docker/                  # Docker support
│   ├── meta-virtualization/          # Virtualization
│   ├── meta-onnxruntime/             # ONNX Runtime
│   ├── meta-tensorflow-lite/         # TensorFlow Lite
│   └── meta-userapp/                 # Your custom recipes
│
├── setup_yocto.sh                    # Environment setup script
└── README.md                         # This file

```

### Why This Structure?

**Meta-layers are siblings to poky, not inside it:**
- ✅ CORRECT: `Yocto_sources/{poky, meta-layer1, meta-layer2}`
- ❌ WRONG: `Yocto_sources/poky/{meta-layer1, meta-layer2}`

**Reasoning:**
1. poky is maintained by Yocto Project
2. External layers should not pollute poky
3. Updates to poky won't conflict with your layers
4. Enables proper Git submodule structure

---

## 🔨 Build Instructions

### First Build

```bash
# Navigate to Yocto sources
cd Yocto_sources/poky

# Initialize build environment
source oe-init-build-env building

# Build the image (takes 4-8 hours first time)
bitbake custom-ai-image

# Find the built image
ls tmp/deploy/images/raspberrypi4-64/
```

### Subsequent Builds

```bash
cd Yocto_sources/poky
source oe-init-build-env building
bitbake custom-ai-image
```

### Clean Build

```bash
# Clean everything
bitbake -c cleanall custom-ai-image

# Or remove tmp directory
rm -rf tmp/

# Rebuild
bitbake custom-ai-image
```

### Build Specific Recipes

```bash
# Build just the kernel
bitbake virtual/kernel

# Build Qt6 application
bitbake qt6-voice-assistant

# Clean and rebuild a recipe
bitbake -c cleansstate qt6-voice-assistant
bitbake qt6-voice-assistant
```

---

## 🔄 Git Submodules

### What Are Submodules?

Git submodules allow you to include external Git repositories as subdirectories. Each Yocto meta-layer is a separate Git repository managed as a submodule.

### Submodule Structure

**Your Forks (with custom modifications):**
| Layer | GitHub URL | Branch |
|-------|-----------|--------|
| poky | github.com/ahmedferganey/poky | kirkstone-voiceassistant |
| meta-openembedded | github.com/ahmedferganey/meta-openembedded | kirkstone-voiceassistant |
| meta-raspberrypi | github.com/ahmedferganey/meta-raspberrypi | kirkstone-voiceassistant |
| meta-onnxruntime | github.com/ahmedferganey/meta-onnxruntime | main |
| meta-tensorflow-lite | github.com/ahmedferganey/meta-tensorflow-lite | main |

**Upstream (no modifications):**
| Layer | GitHub URL | Branch |
|-------|-----------|--------|
| meta-qt6 | github.com/YoeDistro/meta-qt6 | 6.2 |
| meta-docker | github.com/L4B-Software/meta-docker | master |
| meta-virtualization | git.yoctoproject.org/meta-virtualization | kirkstone |

### Common Submodule Commands

```bash
# View submodule status
git submodule status

# Update all submodules to latest commits
git submodule update --remote

# Update specific submodule
git submodule update --remote Yocto_sources/meta-raspberrypi

# Pull latest changes (including submodules)
git pull --recurse-submodules

# Execute command in all submodules
git submodule foreach 'git status'
git submodule foreach 'git pull'
```

### Making Changes to Submodules

```bash
# 1. Navigate to submodule
cd Yocto_sources/meta-raspberrypi

# 2. Make your changes
vim recipes-kernel/linux/linux-raspberrypi_%.bbappend

# 3. Commit in the submodule
git add .
git commit -m "Add custom kernel configuration"
git push origin kirkstone-voiceassistant

# 4. Update main repository to point to new commit
cd ../../../
git add Yocto_sources/meta-raspberrypi
git commit -m "Update meta-raspberrypi submodule"
git push
```

---

## ⚙️ Configuration

### Configuration Files

Two main configuration files control the build:

1. **local.conf** - Build settings
   - Location: `configs/local.conf`
   - Active: `Yocto_sources/poky/building/conf/local.conf`
   - Contains: Machine type, parallel builds, features, package settings

2. **bblayers.conf** - Layer paths
   - Location: `configs/bblayers.conf`
   - Active: `Yocto_sources/poky/building/conf/bblayers.conf`
   - Contains: Paths to all meta-layers

### Key Settings in local.conf

```bash
# Machine
MACHINE = "raspberrypi4-64"

# Parallel builds (adjust based on your CPU)
BB_NUMBER_THREADS = "8"
PARALLEL_MAKE = "-j 8"

# Disk space monitoring
BB_DISKMON_DIRS = "STOPTASKS,${TMPDIR},1G,100M STOPTASKS,${DL_DIR},1G,100M"

# Features
DISTRO_FEATURES:append = " systemd virtualization"
INIT_MANAGER = "systemd"

# WiFi settings
WIFI_COUNTRY = "EG"
```

### Layers in bblayers.conf

```bash
BBLAYERS = " \
  ${TOPDIR}/../meta \
  ${TOPDIR}/../meta-poky \
  ${TOPDIR}/../../meta-raspberrypi \
  ${TOPDIR}/../../meta-virtualization \
  ${TOPDIR}/../../meta-openembedded/meta-oe \
  ${TOPDIR}/../../meta-openembedded/meta-filesystems \
  ${TOPDIR}/../../meta-openembedded/meta-python \
  ${TOPDIR}/../../meta-openembedded/meta-networking \
  ${TOPDIR}/../../meta-openembedded/meta-multimedia \
  ${TOPDIR}/../../meta-docker \
  ${TOPDIR}/../../meta-qt6 \
  ${TOPDIR}/../../meta-userapp \
  "
```

**Note:** Paths are relative from `TOPDIR` (poky/building directory).

### Updating Configuration

```bash
# 1. Edit template in configs/
vim configs/local.conf

# 2. Copy to active build directory
cp configs/local.conf Yocto_sources/poky/building/conf/

# 3. Commit template changes
git add configs/local.conf
git commit -m "Update build configuration"
git push
```

---

## 🐛 Troubleshooting

### Common Issues

#### 1. Submodules Not Initialized
```bash
Error: Directory Yocto_sources/poky is empty
Solution: git submodule update --init --recursive
```

#### 2. Build Fails - Disk Space
```bash
Error: No space left on device
Solution: 
  - Free up disk space (need 200GB+ free)
  - Clean tmp directory: rm -rf tmp/
  - Clean sstate-cache: rm -rf sstate-cache/
```

#### 3. Build Fails - Fetch Error
```bash
Error: Fetcher failure for URL...
Solution:
  - Check internet connection
  - Check if file is still available upstream
  - Look in downloads/ directory for cached file
```

#### 4. Layer Not Found
```bash
Error: Unable to find layer meta-raspberrypi
Solution:
  - Check bblayers.conf paths
  - Verify submodule is initialized
  - Run: cd Yocto_sources && ls -d */
```

#### 5. Configuration File Missing
```bash
Error: Unable to find conf/local.conf
Solution:
  cp configs/local.conf Yocto_sources/poky/building/conf/
  cp configs/bblayers.conf Yocto_sources/poky/building/conf/
```

### Debugging Build Issues

```bash
# Show detailed build output
bitbake -v custom-ai-image

# Show what tasks will run
bitbake -n custom-ai-image

# Continue build after fixing issue
bitbake -k custom-ai-image

# Get recipe information
bitbake-layers show-recipes | grep packagename
bitbake-layers show-layers

# Clean specific recipe
bitbake -c cleansstate recipe-name
```

### Verifying Layer Paths

```bash
cd Yocto_sources/poky/building

# Check if all layers exist
TOPDIR=$(pwd)
for path in \
    "$TOPDIR/../meta" \
    "$TOPDIR/../meta-poky" \
    "$TOPDIR/../../meta-raspberrypi" \
    "$TOPDIR/../../meta-openembedded/meta-oe" \
    "$TOPDIR/../../meta-qt6" \
    "$TOPDIR/../../meta-userapp"; do
  if [ -d "$path" ]; then
    echo "✓ $(basename $path)"
  else
    echo "✗ MISSING: $path"
  fi
done
```

---

## 📊 Repository Information

### Main Repository
https://github.com/ahmedferganey/AutonomousVehiclesprojects

### Your Forks (with modifications)
- https://github.com/ahmedferganey/poky
- https://github.com/ahmedferganey/meta-openembedded
- https://github.com/ahmedferganey/meta-raspberrypi
- https://github.com/ahmedferganey/meta-onnxruntime
- https://github.com/ahmedferganey/meta-tensorflow-lite

### Upstream Repositories
- https://github.com/YoeDistro/meta-qt6
- https://github.com/L4B-Software/meta-docker
- https://git.yoctoproject.org/meta-virtualization

---

## 📈 Build Statistics

### Disk Space Requirements
- **downloads/**: ~26 GB (cached source files)
- **tmp/**: ~100 GB (build output)
- **sstate-cache/**: ~50 GB (shared state)
- **Total**: ~180 GB

### Build Times (typical)
- **First build**: 4-8 hours (downloads everything)
- **Incremental build**: 30 minutes - 2 hours
- **Clean rebuild**: 2-4 hours (uses sstate-cache)

### Resource Requirements
- **CPU**: 4+ cores recommended (8 cores optimal)
- **RAM**: 16 GB minimum (32 GB recommended)
- **Disk**: 200 GB free space minimum

---

## 🎯 Custom Recipes

### meta-userapp Layer

Your custom layer contains:

**Applications:**
- `recipes-apps/qt6-voice-assistant/` - Qt6 GUI application
- `recipes-apps/audio-transcription/` - Audio transcription service

**Connectivity:**
- `recipes-connectivity/wpa-supplicant/` - WiFi configuration
- `recipes-connectivity/dhcpcd/` - Network management

**Docker:**
- `recipes-docker/audio-backend/` - Audio backend container

**Kernel:**
- `recipes-kernel/linux/` - Custom kernel configurations

**Qt:**
- `recipes-qt/qt6/` - Qt6 multimedia backend
- `recipes-qt/qtbase/` - Qt base configuration

**Multimedia:**
- `recipes-multimedia/ffmpeg/` - FFmpeg customizations
- `recipes-multimedia/gstreamer/` - GStreamer plugins

---

## 🔐 Security Notes

### What's Tracked in Git
- ✅ Configuration files (`configs/`)
- ✅ Custom recipes (`meta-userapp/`)
- ✅ Submodule references (`.gitmodules`)
- ✅ Documentation (`README.md`)

### What's Ignored (.gitignore)
- ❌ Build output (`tmp/`)
- ❌ Downloads (`downloads/`)
- ❌ Caches (`sstate-cache/`, `cache/`)
- ❌ Backup directories

### WiFi Credentials
⚠️ **WARNING:** Do not commit WiFi passwords to Git!

WiFi credentials should be configured locally in:
- `Yocto_sources/meta-userapp/recipes-connectivity/wpa-supplicant/files/wpa_supplicant.conf`

This file is .gitignored by default.

---

## 📚 Additional Resources

### Yocto Project
- **Documentation**: https://docs.yoctoproject.org/
- **BitBake Manual**: https://docs.yoctoproject.org/bitbake/
- **Layer Index**: https://layers.openembedded.org/
- **Kirkstone Manual**: https://docs.yoctoproject.org/4.0/

### Raspberry Pi
- **meta-raspberrypi**: https://github.com/agherzan/meta-raspberrypi
- **RPi Documentation**: https://www.raspberrypi.com/documentation/

### Qt6
- **meta-qt6**: https://github.com/YoeDistro/meta-qt6
- **Qt Documentation**: https://doc.qt.io/

### Git Submodules
- **Git Book**: https://git-scm.com/book/en/v2/Git-Tools-Submodules
- **Submodules Tutorial**: https://git-scm.com/docs/git-submodule

---

## ✅ Quick Reference

### Daily Commands

```bash
# Start build environment
cd Yocto_sources/poky && source oe-init-build-env building

# Build image
bitbake custom-ai-image

# Check submodule status
git submodule status

# Update submodules
git submodule update --remote

# Pull latest changes
git pull --recurse-submodules
```

### Configuration Updates

```bash
# Update configs
vim configs/local.conf
cp configs/local.conf Yocto_sources/poky/building/conf/

# Commit and push
git add configs/
git commit -m "Update configuration"
git push
```

### Recipe Development

```bash
# Test recipe
bitbake recipe-name

# Clean and rebuild
bitbake -c cleansstate recipe-name
bitbake recipe-name

# Find recipe
bitbake-layers show-recipes | grep recipe-name
```

---

## 🎉 Success!

Your Yocto build system is now:
- ✅ **Version Controlled** - All changes tracked in Git
- ✅ **Professionally Structured** - Standard Yocto layout
- ✅ **Team-Ready** - Easy to clone and collaborate
- ✅ **Fully Documented** - Comprehensive guides
- ✅ **Build-Ready** - All artifacts in place

**Happy Building!** 🚀

---

**Last Updated:** October 26, 2025  
**Maintainer:** Ahmed Ferganey (ahmed.ferganey707@gmail.com)  
**Status:** Production Ready ✅

