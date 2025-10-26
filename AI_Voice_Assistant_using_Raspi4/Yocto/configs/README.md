# Yocto Configuration Files

This directory contains the Yocto build configuration files that are tracked in the repository.

## Files

- `local.conf` - Main Yocto build configuration
- `bblayers.conf` - BitBake layers configuration

## Why Configs Are Here

The Yocto meta layers (`poky`, `meta-openembedded`, etc.) are **Git submodules** pointing to external repositories. Git cannot track files inside directories containing `.git` folders, so we store our configuration files here instead.

## Setup Instructions

### First Time Setup

1. **Clone the repository** (if you haven't already):
   ```bash
   git clone https://github.com/ahmedferganey/AutonomousVehiclesprojects.git
   cd AutonomousVehiclesprojects
   ```

2. **Initialize and update submodules**:
   ```bash
   cd AI_Voice_Assistant_using_Raspi4/Yocto
   ./setup_yocto.sh
   ```

This script will:
- Initialize all git submodules (poky, meta-openembedded, etc.)
- Copy configuration files to the correct location
- Set up the build environment

### Manual Setup

If you prefer manual setup:

```bash
# Initialize submodules
git submodule init
git submodule update --recursive

# Copy configs to build directory
mkdir -p Yocto_sources/poky/building/conf
cp configs/local.conf Yocto_sources/poky/building/conf/
cp configs/bblayers.conf Yocto_sources/poky/building/conf/
```

## Updating Configurations

After modifying `local.conf` or `bblayers.conf` in the build directory:

```bash
# Copy updated configs back to trackable location
cp Yocto_sources/poky/building/conf/local.conf configs/
cp Yocto_sources/poky/building/conf/bblayers.conf configs/

# Commit the changes
git add configs/
git commit -m "Update Yocto configuration"
```

## Submodules List

The following external layers are managed as git submodules:

- **poky** - Yocto Project reference distribution
- **meta-openembedded** - Collection of OE layers
- **meta-raspberrypi** - Raspberry Pi BSP layer
- **meta-virtualization** - Virtualization layer (Docker, LXC, etc.)
- **meta-qt6** - Qt6 framework layer
- **meta-docker** - Docker integration layer
- (Add others as needed)

## Custom Layer

Our custom layer `meta-userapp` is tracked directly in the main repository, not as a submodule.
It contains all project-specific recipes and configurations.

## Build Process

```bash
cd Yocto_sources/poky
source oe-init-build-env building
bitbake core-image-minimal  # or your target image
```

## Notes

- Always commit configuration changes to the `configs/` directory
- Submodules track specific commits of external repos
- To update submodules: `git submodule update --remote`

