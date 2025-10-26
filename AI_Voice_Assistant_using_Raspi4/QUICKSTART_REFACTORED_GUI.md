# 🚀 Quick Start: Refactored Qt6 GUI + Whisper ONNX Backend

**Status**: ✅ Code refactoring complete, ready for testing

---

## 📋 What Was Done

✅ Created `NetworkManager` class (HTTP + WebSocket client)  
✅ Refactored `AudioEngine` to use real audio capture (QAudioInput)  
✅ Updated `CMakeLists.txt` with Qt6::Network and Qt6::WebSockets  
✅ Created Whisper ONNX backend Docker recipe  
✅ Created systemd service for backend  
✅ Documented complete integration  

---

## 🎯 What You Need to Do (3 Steps)

### Step 1: Create FastAPI Backend Files (5 minutes)

```bash
cd /media/fragello/06c3ca26-00fe-4e3b-8a98-931188810fc9/00_Embedded/AutonomousVehiclesprojects/AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/meta-userapp/recipes-docker/whisper-backend-onnx/files

# Create app directory
mkdir -p app

# Create placeholder files
touch app/__init__.py

# Now copy the COMPLETE code from Documentation/WHISPER_ONNX_INTEGRATION_PLAN.md:
# - Section 2.4 → app/config.py
# - Section 2.5 → app/whisper_engine.py
# - Section 2.6 → app/audio_processor.py
# - Section 2.7 → app/main.py
# - Section 2.8 → app/models.py
# - Create app/utils.py (can be empty for now)
```

**Quick command to create stubs:**
```bash
cat > app/__init__.py << 'EOF'
"""Whisper ONNX Transcription Backend"""
__version__ = "1.0.0"
EOF

# Then manually copy the actual implementation from the PLAN.md
```

---

### Step 2: Update local.conf (2 minutes)

```bash
cd /media/fragello/06c3ca26-00fe-4e3b-8a98-931188810fc9/00_Embedded/AutonomousVehiclesprojects/AI_Voice_Assistant_using_Raspi4/Yocto

nano Yocto_sources/poky/building/conf/local.conf
```

**Add these lines to IMAGE_INSTALL:**
```bash
# Whisper backend Docker container (NEW)
IMAGE_INSTALL += " whisper-backend-onnx"

# Qt6 WebSockets for network communication (NEW)
IMAGE_INSTALL += " qtwebsockets"
```

**Verify Qt6 packages are already there:**
```bash
grep -A 20 "Qt6 components" Yocto_sources/poky/building/conf/local.conf
# Should see: qtbase qtdeclarative qtmultimedia qtsvg qtwebsockets etc.
```

---

### Step 3: Update qt6-voice-assistant Recipe (2 minutes)

```bash
nano Yocto_sources/meta-userapp/recipes-apps/qt6-voice-assistant/qt6-voice-assistant_2.0.0.bb
```

**Add to DEPENDS:**
```bash
DEPENDS = " \
    qtbase \
    qtdeclarative \
    qtmultimedia \
    qtsvg \
    qtwebsockets \    # ADD THIS
    qtcharts \
    python3 \
    python3-numpy \
    alsa-lib \
"
```

**Add to RDEPENDS:**
```bash
RDEPENDS:${PN} = " \
    qtbase \
    qtdeclarative \
    qtmultimedia \
    qtsvg \
    qtwebsockets \              # ADD THIS
    qtcharts \
    python3 \
    python3-numpy \
    alsa-lib \
    alsa-utils \
    whisper-backend-onnx \      # ADD THIS (ensures backend is installed)
"
```

---

## 🔨 Build Commands

```bash
cd /media/fragello/06c3ca26-00fe-4e3b-8a98-931188810fc9/00_Embedded/AutonomousVehiclesprojects/AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/poky/building

# Clean previous builds (optional, but recommended)
bitbake -c cleansstate qt6-voice-assistant whisper-backend-onnx

# Build the Whisper backend Docker container
bitbake whisper-backend-onnx

# Build the Qt6 voice assistant
bitbake qt6-voice-assistant

# Build complete image
bitbake core-image-base
```

**Expected build time:**
- whisper-backend-onnx: ~30-60 minutes (first time, includes Docker image build)
- qt6-voice-assistant: ~10-20 minutes
- core-image-base: Depends on what changed

---

## 🧪 Testing on Development PC (Optional, Recommended)

Before deploying to Raspberry Pi, test locally:

```bash
# 1. Build Docker image for x86_64
cd /path/to/whisper-backend-onnx/files
docker build --platform linux/amd64 -t whisper-backend-test .

# 2. Run container
docker run -d -p 8000:8000 --name whisper-test whisper-backend-test

# 3. Test health
curl http://localhost:8000/health
# Should return: {"status":"healthy","model_loaded":true,...}

# 4. Test transcription (you'll need a WAV file)
curl -X POST http://localhost:8000/transcribe \
  -F "audio_file=@test.wav" \
  -F "language=en"

# 5. Build Qt6 app
cd /path/to/qt6_voice_assistant_gui
mkdir build && cd build
cmake -DCMAKE_PREFIX_PATH=/path/to/Qt/6.2.0/gcc_64 ..
make
./VoiceAssistant
```

---

## 📦 Deployment to Raspberry Pi

```bash
# 1. Flash image to microSD card
cd /media/fragello/06c3ca26-00fe-4e3b-8a98-931188810fc9/00_Embedded/AutonomousVehiclesprojects/AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/poky/building

sudo dd if=tmp/deploy/images/raspberrypi4-64/core-image-base-raspberrypi4-64.wic \
    of=/dev/sdX bs=4M status=progress conv=fsync
sync

# 2. Boot Raspberry Pi and SSH
ssh ferganey@raspberrypi.local

# 3. Check Docker status
systemctl status docker

# 4. Check Whisper backend status
systemctl status whisper-backend

# 5. If backend not started, load image
load-whisper-backend
systemctl start whisper-backend
systemctl enable whisper-backend

# 6. Verify backend is running
curl http://localhost:8000/health

# 7. Start Qt6 GUI (if not auto-started)
/usr/bin/VoiceAssistant &

# Or if installed in different location:
find /usr -name "VoiceAssistant" -type f 2>/dev/null
```

---

## ⚠️ Important: Whisper Model Required!

The backend **will not work** without the Whisper ONNX model. You have two options:

### Option 1: Convert on Your PC (Recommended)

```bash
# On your development PC (not Raspberry Pi!)
mkdir ~/whisper-onnx-models
cd ~/whisper-onnx-models

python3 -m venv venv
source venv/bin/activate

pip install torch transformers optimum[onnxruntime] onnx

# Create conversion script (copy from WHISPER_ONNX_INTEGRATION_PLAN.md Section 1.2)
nano convert_whisper.py

# Run conversion
python convert_whisper.py
# Output: whisper-base-onnx/ (74MB)

# Copy to Raspberry Pi
scp -r whisper-base-onnx/ ferganey@raspberrypi.local:/home/ferganey/models/

# On Raspberry Pi, mount in Docker container:
docker run -d -p 8000:8000 \
  -v /home/ferganey/models/whisper-base-onnx:/app/models/whisper-base-onnx \
  --name whisper-backend \
  whisper-backend-onnx:1.0.0
```

### Option 2: Include in Docker Image

```bash
# On your PC, after conversion:
cp -r whisper-base-onnx/ /path/to/meta-userapp/recipes-docker/whisper-backend-onnx/files/models/

# Update Dockerfile to COPY the models
# Add before CMD:
# COPY models/ /app/models/

# Rebuild Docker image
bitbake -c cleansstate whisper-backend-onnx
bitbake whisper-backend-onnx
```

---

## 🐛 Troubleshooting

### Backend Not Starting?
```bash
# Check Docker logs
docker logs whisper-backend

# Common issues:
# 1. Model not found → Copy whisper-base-onnx to /app/models/
# 2. Port 8000 in use → Check: netstat -tulpn | grep 8000
# 3. Out of memory → Check: free -h (need at least 1GB free)
```

### GUI Not Connecting?
```bash
# Check backend is reachable
curl http://localhost:8000/health

# Check Qt6 app logs
# Run from terminal to see debug output:
/usr/bin/VoiceAssistant

# Look for messages like:
# 🌐 NetworkManager initialized with backend URL: http://localhost:8000
# ✅ Backend is healthy and model is loaded
```

### No Audio Captured?
```bash
# List audio devices
arecord -l

# Test capture
arecord -d 5 -f cd test.wav
aplay test.wav

# Check ALSA
cat /proc/asound/cards
```

---

## 📚 Documentation

- **Complete Implementation Guide**: `Documentation/GUI_REFACTORING_SUMMARY.md`
- **Whisper Integration Plan**: `Documentation/WHISPER_ONNX_INTEGRATION_PLAN.md`
- **Architecture Diagrams**: `Documentation/WHISPER_ARCHITECTURE.md`

---

## ✅ Checklist

Before building, make sure you have:

- [ ] Created FastAPI backend files in `meta-userapp/recipes-docker/whisper-backend-onnx/files/app/`
- [ ] Updated `local.conf` with `whisper-backend-onnx` and `qtwebsockets`
- [ ] Updated `qt6-voice-assistant_2.0.0.bb` DEPENDS and RDEPENDS
- [ ] Converted Whisper model to ONNX (or have a plan to do so)
- [ ] Read `GUI_REFACTORING_SUMMARY.md` for complete details

---

## 🎉 Success Criteria

Your system is working when:

1. ✅ Docker backend starts successfully: `systemctl status whisper-backend` shows "active (running)"
2. ✅ Health check passes: `curl http://localhost:8000/health` returns `"status":"healthy"`
3. ✅ Qt6 GUI shows "Backend: OK" indicator
4. ✅ Recording button is enabled (not grayed out)
5. ✅ You can record audio and see real-time waveform visualization
6. ✅ After clicking "Transcribe", you get text output
7. ✅ (Streaming mode) Partial transcriptions appear in real-time

---

**Good luck! 🚀**

If you encounter issues, check the comprehensive troubleshooting section in `GUI_REFACTORING_SUMMARY.md`.

