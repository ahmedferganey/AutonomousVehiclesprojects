# Repositories to Fork on GitHub

## ✅ **CORRECTED Fork URLs** (Based on Your Actual Configuration)

You need to create forks for the **5 layers with modifications**:

---

### **1. poky**
**Fork this:** https://github.com/yoctoproject/poky

**Result:** https://github.com/ahmedferganey/poky

✅ **Status:** URL Correct

---

### **2. meta-openembedded**
**Fork this:** https://github.com/openembedded/meta-openembedded

**Result:** https://github.com/ahmedferganey/meta-openembedded

✅ **Status:** URL Correct

---

### **3. meta-raspberrypi**
**Fork this:** https://github.com/agherzan/meta-raspberrypi

**Result:** https://github.com/ahmedferganey/meta-raspberrypi

✅ **Status:** URL Correct

---

### **4. meta-onnxruntime**
**Fork this:** https://github.com/NobuoTsukamoto/meta-onnxruntime

**Result:** https://github.com/ahmedferganey/meta-onnxruntime

⚠️ **NOTE:** This is **NobuoTsukamoto**, not ArmRyan!

---

### **5. meta-tensorflow-lite**
**Fork this:** https://github.com/NobuoTsukamoto/meta-tensorflow-lite

**Result:** https://github.com/ahmedferganey/meta-tensorflow-lite

⚠️ **NOTE:** This is **NobuoTsukamoto**, not d-trusted!

---

## 📝 **How to Fork:**

1. **Open each URL above** in your browser while logged into GitHub
2. **Click the "Fork" button** (top right)
3. **IMPORTANT:** When forking, **UNCHECK** "Copy the main branch only"
   - This ensures all branches (including kirkstone) are forked
4. **Create fork** in your account (ahmedferganey)

---

## ℹ️ **Clean Layers (No Fork Needed)**

These layers have NO modifications and will use upstream directly:

| Layer | Upstream Repository | Branch |
|-------|---------------------|--------|
| meta-qt6 | https://github.com/YoeDistro/meta-qt6 | kirkstone |
| meta-docker | https://github.com/L4B-Software/meta-docker | master |
| meta-virtualization | https://git.yoctoproject.org/meta-virtualization | kirkstone |

---

## ✨ **After Forking All 5 Repositories:**

Run the setup script:

```bash
cd /media/fragello/06c3ca26-00fe-4e3b-8a98-931188810fc9/00_Embedded/AutonomousVehiclesprojects/AI_Voice_Assistant_using_Raspi4/Yocto

./setup_submodules_interactive.sh
```

The script will:
- ✅ Push your modifications to the forks
- ✅ Set up git submodules
- ✅ Configure build environment
- ✅ Commit everything

---

## 🔍 **Verification:**

Your current remote URLs (what you're actually using):

```
poky:                  git://git.yoctoproject.org/poky.git
meta-openembedded:     git://git.openembedded.org/meta-openembedded
meta-raspberrypi:      git://git.yoctoproject.org/meta-raspberrypi
meta-onnxruntime:      https://github.com/NobuoTsukamoto/meta-onnxruntime.git ✓
meta-tensorflow-lite:  https://github.com/NobuoTsukamoto/meta-tensorflow-lite.git ✓
meta-qt6:              https://github.com/YoeDistro/meta-qt6 ✓
meta-docker:           https://github.com/L4B-Software/meta-docker ✓
meta-virtualization:   git://git.yoctoproject.org/meta-virtualization
```

---

## ⏭️ **Quick Start:**

1. **Fork all 5 repositories** (links above)
2. **Run:** `./setup_submodules_interactive.sh`
3. **Follow the prompts**
4. **Done!** 🎉

---

**Last Updated:** October 26, 2025
**Verified Against:** Actual git remote configurations in Yocto_sources/

