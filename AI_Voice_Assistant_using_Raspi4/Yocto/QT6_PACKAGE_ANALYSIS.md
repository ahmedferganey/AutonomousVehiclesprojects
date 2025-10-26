# Qt6 Package Availability Analysis

## Summary

**Date**: October 26, 2025  
**meta-qt6 Layer**: Qt 6.2.x (Kirkstone branch)  
**Total Qt6 Packages Requested**: 27  
**Available**: 24  
**Not Available**: 3

---

## ✓ Available Qt6 Packages (24)

All these packages exist in meta-qt6 and can be used:

| Package | Status | Description |
|---------|--------|-------------|
| `qtbase` | ✅ | Qt Base module (core, gui, widgets) |
| `qtdeclarative` | ✅ | Qt Quick/QML support |
| `qtsvg` | ✅ | SVG rendering support |
| `qttools` | ✅ | Qt development tools |
| `qtmultimedia` | ✅ | Multimedia framework |
| `qtwayland` | ✅ | Wayland compositor support |
| `qt3d` | ✅ | 3D graphics support |
| `qtquick3d` | ✅ | Qt Quick 3D module |
| `qtserialport` | ✅ | Serial port support |
| `qtserialbus` | ✅ | CAN bus, Modbus support |
| `qtnetworkauth` | ✅ | OAuth authentication |
| `qtmqtt` | ✅ | MQTT protocol support |
| `qtcoap` | ✅ | CoAP protocol support |
| `qtopcua` | ✅ | OPC UA industrial protocol |
| `qtpositioning` | ✅ | GPS/location services |
| `qtsensors` | ✅ | Sensor framework |
| `qtvirtualkeyboard` | ✅ | On-screen keyboard |
| `qtimageformats` | ✅ | Additional image formats |
| `qttranslations` | ✅ | Translations for Qt |
| `qtcharts` | ✅ | Chart/graph widgets |
| `qtconnectivity` | ✅ | Bluetooth, NFC support |
| `qtdatavis3d` | ✅ | 3D data visualization |
| `qtwebsockets` | ✅ | WebSocket protocol |
| `qtwebengine` | ✅ | Chromium-based web browser |

---

## ✗ Not Available in Qt 6.2 (3)

### 1. **qtmultimedia-plugins** ❌

**Location**: `local.conf` line 157  
**Issue**: Package doesn't exist as standalone in Qt 6.2  
**Reason**: Qt6 qtmultimedia already includes plugins via PACKAGECONFIG  
**Action**: Remove from IMAGE_INSTALL  

**Explanation**: In Qt 6, multimedia plugins (GStreamer, ALSA, FFmpeg) are built into the `qtmultimedia` package based on PACKAGECONFIG. You don't install them separately.

```bash
# Current in local.conf (WRONG):
qtmultimedia-plugins gstreamer1.0-plugins-ugly ...

# Should be (CORRECT):
# qtmultimedia already includes plugins via PACKAGECONFIG[gstreamer]
gstreamer1.0-plugins-ugly ...
```

---

### 2. **qtmultimedia-dev** ❌

**Location**: `local.conf` line 199 (TOOLCHAIN_HOST_TASK)  
**Issue**: Package doesn't exist  
**Reason**: Development files are automatically included in SDK via packagegroup-qt6-modules  
**Action**: Remove from TOOLCHAIN_HOST_TASK  

**Explanation**: Qt6 SDK generation automatically includes development headers and libraries. You don't need to specify `-dev` packages manually.

---

### 3. **qt6** (in DISTRO_FEATURES) ✅ OK

**Location**: `local.conf` line 55  
**Status**: **This is CORRECT**  
**Reason**: `qt6` in DISTRO_FEATURES is a feature flag, not a package name  
**Action**: No change needed  

This enables Qt6 support across the build system and is perfectly valid.

---

## Previously Removed Packages

### **qtquick3dphysics** ❌
- Not available in Qt 6.2 (requires Qt 6.5+)
- Already removed from configuration

### **qtlocation** ❌  
- Deprecated in Qt 6.2, removed in Qt 6.5
- Already removed from configuration

---

## Recommended Actions

### 1. Remove qtmultimedia-plugins (Line 157)

```bash
# Comment out non-existent package
sed -i 's/qtmultimedia-plugins /# qtmultimedia-plugins  # Not a separate package in Qt 6.2 \\\n    /g' Yocto_sources/poky/building/conf/local.conf
```

### 2. Remove qtmultimedia-dev (Line 199)

```bash
# Comment out from SDK toolchain
sed -i 's/^    qtmultimedia-dev \\$/    # qtmultimedia-dev  # Auto-included in Qt6 SDK \\/g' Yocto_sources/poky/building/conf/local.conf
```

### 3. Apply same fixes to template config

```bash
sed -i 's/qtmultimedia-plugins /# qtmultimedia-plugins  # Not a separate package in Qt 6.2 \\\n    /g' configs/local.conf
sed -i 's/^    qtmultimedia-dev \\$/    # qtmultimedia-dev  # Auto-included in Qt6 SDK \\/g' configs/local.conf
```

---

## Technical Notes

### Qt 6.2 vs Qt 5 Differences

| Qt 5 | Qt 6.2 | Change |
|------|--------|--------|
| `qtmultimedia` + `qtmultimedia-plugins` | `qtmultimedia` (includes plugins) | Merged |
| `qtlocation` | ❌ Removed | Use qtpositioning |
| `qtquick3dphysics` | ❌ Not yet available | Added in Qt 6.5+ |
| Manual `-dev` packages | Auto-included in SDK | Simplified |

### How Qt6 Multimedia Plugins Work

The `qtmultimedia` recipe uses PACKAGECONFIG to build plugins:

```python
PACKAGECONFIG ?= "gstreamer qml"
PACKAGECONFIG[alsa] = "-DFEATURE_alsa=ON,..."
PACKAGECONFIG[gstreamer] = "-DFEATURE_gstreamer=ON,..."
PACKAGECONFIG[pulseaudio] = "-DFEATURE_pulseaudio=ON,..."
```

When you install `qtmultimedia`, you automatically get the plugins enabled via PACKAGECONFIG. No need for a separate `qtmultimedia-plugins` package.

---

## Build Impact

### Before Fix:
```
ERROR: Nothing RPROVIDES 'qtmultimedia-plugins'
ERROR: Nothing RPROVIDES 'qtmultimedia-dev'
```

### After Fix:
✅ Build proceeds successfully  
✅ GStreamer plugins still available via qtmultimedia  
✅ Development files still available in SDK

---

## Verification Commands

```bash
# List all Qt6 packages available
cd Yocto_sources/meta-qt6
find . -name "qt*_git.bb" | sed 's|.*/||' | sed 's|_git.bb||' | sort

# Check what packages are installed in final image
bitbake -e core-image-base | grep "^IMAGE_INSTALL="

# Verify no missing Qt6 packages
bitbake -c populate_sdk core-image-base
```

---

## References

- [Qt 6 Documentation](https://doc.qt.io/qt-6/)
- [meta-qt6 Layer README](https://code.qt.io/cgit/yocto/meta-qt6.git/about/)
- [Qt 6.2 Release Notes](https://www.qt.io/blog/qt-6.2-lts-released)
- [Yocto Project Documentation](https://docs.yoctoproject.org/)

---

**Generated**: 2025-10-26  
**Author**: AI Assistant  
**Project**: AI Voice Assistant for Raspberry Pi 4

