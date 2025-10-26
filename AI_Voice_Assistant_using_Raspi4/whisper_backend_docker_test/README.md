# 🐳 Whisper ONNX Backend - Docker Testing Environment

**Purpose**: Build and test the Whisper ONNX backend Docker image on your development PC **before** deploying to Raspberry Pi 4.

**Status**: ✅ Ready for testing (Mock mode - works without Whisper model)

---

## 📋 What's Included

```
whisper_backend_docker_test/
├── Dockerfile              # Multi-arch Docker build (x86_64 + ARM64)
├── docker-compose.yml      # Easy testing with Docker Compose
├── requirements.txt        # Python dependencies
├── app/                    # FastAPI application
│   ├── __init__.py
│   ├── main.py            # FastAPI endpoints (✅ Complete)
│   ├── config.py          # Configuration management
│   ├── models.py          # Pydantic models
│   ├── whisper_engine.py  # ONNX Whisper engine
│   └── audio_processor.py # Audio preprocessing
├── scripts/
│   ├── build.sh           # Build Docker image (x86_64/ARM64)
│   └── test.sh            # Test API endpoints
├── models/                # Place Whisper ONNX models here
├── cache/                 # Audio buffers cache
├── test_audio/            # Test audio files
└── README.md             # This file
```

---

## 🚀 Quick Start (5 Minutes)

### Step 1: Build the Image (x86_64 for your PC)

```bash
cd whisper_backend_docker_test

# Build for x86_64 (for testing on your PC)
./scripts/build.sh

# Expected output:
# ✅ Docker image built successfully!
# Image: whisper-backend-onnx:test
```

### Step 2: Run the Container

**Option A: Using docker-compose (Recommended)**
```bash
docker-compose up -d

# Check logs
docker-compose logs -f
```

**Option B: Using docker run**
```bash
docker run -d \
    -p 8000:8000 \
    --name whisper-backend-test \
    whisper-backend-onnx:test
```

### Step 3: Test the API

```bash
./scripts/test.sh

# Expected output:
# 🧪 Testing Whisper ONNX Backend API
# ====================================
# ✓ Backend is running
# ✓ Test 1 passed - Root endpoint
# ✓ Test 2 passed - Backend is healthy
# ✓ Test 3 passed - Detailed status
# ✓ Test 5 passed (mock mode)
# ✅ All tests completed!
```

### Step 4: Manual Testing

```bash
# Health check
curl http://localhost:8000/health

# Root endpoint
curl http://localhost:8000/

# Detailed status
curl http://localhost:8000/status/detailed

# Test transcription (mock mode)
curl -X POST http://localhost:8000/transcribe \
    -F "audio_file=@test_audio/test.wav" \
    -F "language=en"
```

---

## 🎯 Two Modes of Operation

### Mode 1: MOCK MODE (Current - No Model Required) ⚡

**What it does:**
- ✅ All API endpoints work
- ✅ Returns simulated transcriptions
- ✅ Perfect for testing API structure
- ✅ Testing without Raspberry Pi hardware
- ✅ No Whisper model required

**Perfect for:**
- Testing Docker build process
- Verifying API endpoints
- Testing Qt6 GUI connectivity
- CI/CD pipelines

**Example response:**
```json
{
  "text": "[MOCK TRANSCRIPTION] This is a simulated transcription for testing",
  "language": "en",
  "duration": 5.2,
  "inference_time": 2.1,
  "total_time": 2.3,
  "rtf": 0.40,
  "timestamp": 1698345600.456
}
```

---

### Mode 2: PRODUCTION MODE (With Whisper ONNX Model) 🚀

**What it does:**
- ✅ Real audio transcription using Whisper
- ✅ ONNX Runtime optimization
- ✅ Production-ready accuracy

**Requirements:**
1. Convert Whisper model to ONNX (see instructions below)
2. Place model in `models/whisper-base-onnx/`
3. Rebuild Docker image or mount as volume

**To activate production mode:**

```bash
# Option 1: Mount model as volume
docker run -d \
    -p 8000:8000 \
    -v $(pwd)/models/whisper-base-onnx:/app/models/whisper-base-onnx:ro \
    --name whisper-backend-test \
    whisper-backend-onnx:test

# Option 2: Bake model into Docker image
# 1. Copy model to models/whisper-base-onnx/
# 2. Rebuild image: ./scripts/build.sh
```

---

## 🔨 Build Options

### Build for x86_64 (Your PC)
```bash
./scripts/build.sh
# Platform: linux/amd64
# Size: ~1.2GB
# Build time: ~10-15 minutes
```

### Build for ARM64 (Raspberry Pi 4)
```bash
./scripts/build.sh --arm64
# Platform: linux/arm64
# Size: ~1.1GB
# Build time: ~30-45 minutes (cross-compilation)
```

### Build for Both Architectures
```bash
./scripts/build.sh --multi-arch
# Platforms: linux/amd64,linux/arm64
# Creates multi-arch image
# Build time: ~45-60 minutes
```

### Build with Custom Tag
```bash
./scripts/build.sh --tag v1.0.0
# Image: whisper-backend-onnx:v1.0.0
```

---

## 🧪 Testing Scenarios

### Scenario 1: Test API Without Model (Mock Mode)
```bash
# 1. Build and run
./scripts/build.sh
docker-compose up -d

# 2. Test all endpoints
./scripts/test.sh

# ✅ Result: All tests pass, returns mock transcriptions
```

### Scenario 2: Test API With Whisper Model
```bash
# 1. Convert and place model (see Model Conversion section)
mkdir -p models/whisper-base-onnx
# [Copy converted model files here]

# 2. Run with model mounted
docker run -d \
    -p 8000:8000 \
    -v $(pwd)/models/whisper-base-onnx:/app/models/whisper-base-onnx:ro \
    whisper-backend-onnx:test

# 3. Test transcription
curl -X POST http://localhost:8000/transcribe \
    -F "audio_file=@test_audio/real_speech.wav" \
    -F "language=en"

# ✅ Result: Real transcription from Whisper model
```

### Scenario 3: Test Qt6 GUI Connectivity
```bash
# 1. Start backend
docker-compose up -d

# 2. Build and run Qt6 GUI (from main project)
cd ../qt6_voice_assistant_gui
mkdir build && cd build
cmake ..
make
./VoiceAssistant

# ✅ Result: GUI connects to backend, shows "Backend: OK"
```

---

## 📦 Model Conversion (Optional - For Production Mode)

### Convert Whisper to ONNX on Your PC

```bash
# 1. Create conversion environment
mkdir ~/whisper-onnx-conversion
cd ~/whisper-onnx-conversion

python3 -m venv venv
source venv/bin/activate

# 2. Install dependencies
pip install torch transformers optimum[onnxruntime] onnx

# 3. Create conversion script
cat > convert_whisper.py << 'EOF'
from optimum.onnxruntime import ORTModelForSpeechSeq2Seq
from transformers import AutoProcessor

MODEL_NAME = "openai/whisper-base"
OUTPUT_DIR = "./whisper-base-onnx"

print(f"Converting {MODEL_NAME} to ONNX...")

model = ORTModelForSpeechSeq2Seq.from_pretrained(
    MODEL_NAME,
    export=True,
    provider="CPUExecutionProvider",
)

processor = AutoProcessor.from_pretrained(MODEL_NAME)

model.save_pretrained(OUTPUT_DIR)
processor.save_pretrained(OUTPUT_DIR)

print(f"✓ Model saved to {OUTPUT_DIR}")
EOF

# 4. Run conversion
python convert_whisper.py

# 5. Copy to testing directory
cp -r whisper-base-onnx /path/to/whisper_backend_docker_test/models/
```

**Model sizes:**
- Whisper Tiny: 39MB (fastest, 75% accuracy)
- Whisper Base: 74MB (recommended, 85% accuracy)
- Whisper Small: 244MB (best accuracy, 90%)

---

## 🌐 API Endpoints

| Endpoint | Method | Purpose | Mock Mode |
|----------|--------|---------|-----------|
| `/` | GET | Service info | ✅ |
| `/health` | GET | Health check | ✅ |
| `/status/detailed` | GET | Detailed status | ✅ |
| `/model/info` | GET | Model information | ⚠️ (503 in mock) |
| `/transcribe` | POST | File transcription | ✅ (simulated) |
| `/transcribe/base64` | POST | Base64 transcription | ✅ (simulated) |
| `/stream` | WebSocket | Real-time streaming | ✅ (simulated) |

---

## 🐛 Troubleshooting

### Issue: "Failed to build Docker image"
```bash
# Check Docker is running
systemctl status docker  # Linux
# or
docker info              # All platforms

# Check disk space
df -h

# Clean up old images
docker system prune -a
```

### Issue: "Backend not responding"
```bash
# Check if container is running
docker ps

# Check logs
docker logs whisper-backend-test

# Common issue: Port 8000 already in use
netstat -tulpn | grep 8000  # Find process using port
sudo kill -9 <PID>          # Kill it
```

### Issue: "Model not loaded" (in production mode)
```bash
# Check model files exist
ls -la models/whisper-base-onnx/

# Required files:
# - encoder_model.onnx
# - decoder_model.onnx
# - config.json
# - tokenizer/

# Restart container with correct model path
docker run -d \
    -p 8000:8000 \
    -v $(pwd)/models/whisper-base-onnx:/app/models/whisper-base-onnx:ro \
    whisper-backend-onnx:test
```

### Issue: "Slow performance"
```bash
# Check available resources
docker stats whisper-backend-test

# Increase CPU/memory limits in docker-compose.yml:
deploy:
  resources:
    limits:
      cpus: '8.0'      # Increase CPUs
      memory: 4G       # Increase memory
```

---

## 📊 Performance Benchmarks

### On Development PC (x86_64, Intel i7, 16GB RAM)

| Model | Build Time | Image Size | Startup Time | Transcription (5s audio) |
|-------|------------|------------|--------------|--------------------------|
| Mock Mode | 10 min | 1.2GB | 5s | Instant (mock) |
| Whisper Base | 10 min | 1.3GB | 15s | 2.0s (RTF: 0.4x) |

### On Raspberry Pi 4 (ARM64, 4GB RAM) - Expected

| Model | Startup Time | Transcription (5s audio) | Memory Usage |
|-------|--------------|--------------------------|--------------|
| Mock Mode | 10s | Instant | 200MB |
| Whisper Base | 30s | 6-8s (RTF: 1.2-1.6x) | 600MB |

---

## 🚢 Deployment to Raspberry Pi

### Step 1: Save Docker Image
```bash
# On your PC, after building ARM64 image
./scripts/build.sh --arm64

docker save whisper-backend-onnx:test | gzip > whisper-backend-arm64.tar.gz
```

### Step 2: Transfer to Raspberry Pi
```bash
scp whisper-backend-arm64.tar.gz ferganey@raspberrypi.local:~/
```

### Step 3: Load and Run on Raspberry Pi
```bash
# SSH into Raspberry Pi
ssh ferganey@raspberrypi.local

# Load image
gunzip -c whisper-backend-arm64.tar.gz | docker load

# Run container
docker run -d \
    -p 8000:8000 \
    --name whisper-backend \
    --restart unless-stopped \
    whisper-backend-onnx:test

# Check health
curl http://localhost:8000/health
```

---

## 🔐 Security Notes

For testing: Container runs as root for easier debugging  
For production: Set `CREATE_USER=true` in docker-compose.yml

---

## 📚 Documentation References

- **Complete integration plan**: `../Documentation/WHISPER_ONNX_INTEGRATION_PLAN.md`
- **Architecture diagrams**: `../Documentation/WHISPER_ARCHITECTURE.md`
- **GUI refactoring**: `../Documentation/GUI_REFACTORING_SUMMARY.md`
- **Quick start**: `../QUICKSTART_REFACTORED_GUI.md`

---

## ✅ Success Checklist

Before deploying to Raspberry Pi, verify:

- [ ] Docker image builds successfully
- [ ] Container starts without errors
- [ ] Health endpoint returns "healthy"
- [ ] All API endpoints respond
- [ ] Test script passes all tests
- [ ] Qt6 GUI connects (if available)
- [ ] (Optional) Real transcription works with model

---

## 🎉 Next Steps

1. **Test locally** (you are here!)
   ```bash
   ./scripts/build.sh
   docker-compose up -d
   ./scripts/test.sh
   ```

2. **Add Whisper model** (optional, for production)
   - Convert model to ONNX
   - Place in `models/whisper-base-onnx/`
   - Rebuild or mount as volume

3. **Build for ARM64**
   ```bash
   ./scripts/build.sh --arm64
   ```

4. **Deploy to Raspberry Pi**
   - Save image
   - Transfer to RPi
   - Load and run

5. **Integrate with Yocto**
   - Copy to `meta-userapp/recipes-docker/whisper-backend-onnx/files/`
   - Build with Bitbake

---

## 💡 Tips

- **Testing without hardware**: Mock mode lets you test everything without RPi
- **Iterative development**: Test on PC first, deploy to RPi when ready
- **Multi-arch builds**: Build once, run anywhere (x86_64 + ARM64)
- **Model flexibility**: Start with mock, add model later

---

**Happy Testing! 🚀**

For questions or issues, refer to the comprehensive documentation or check the logs:
```bash
docker logs whisper-backend-test -f
```

