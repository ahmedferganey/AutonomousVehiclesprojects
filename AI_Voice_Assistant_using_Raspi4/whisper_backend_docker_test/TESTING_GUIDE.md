# 🧪 Docker Buildx Testing Guide

## 🎯 Purpose

This directory allows you to **build and test the Whisper ONNX backend Docker image** on your development PC **without needing Raspberry Pi hardware**. The backend runs in two modes:

1. **MOCK MODE** (default): API works, returns simulated transcriptions - perfect for testing!
2. **PRODUCTION MODE**: Real Whisper transcription (requires ONNX model)

---

## ⚡ Quick Test (2 Minutes)

```bash
cd whisper_backend_docker_test

# 1. Build image
./scripts/build.sh

# 2. Start container
docker-compose up -d

# 3. Test API
./scripts/test.sh

# Expected: ✅ All tests completed!
```

---

## 📁 What's Inside

```
whisper_backend_docker_test/
├── app/                      ✅ Complete FastAPI application
│   ├── main.py              (400+ lines, production-ready)
│   ├── config.py            (Environment configuration)
│   ├── models.py            (Pydantic models)
│   ├── whisper_engine.py    (ONNX inference engine)
│   └── audio_processor.py   (Audio preprocessing)
├── scripts/
│   ├── build.sh             ✅ Build for x86_64 or ARM64
│   └── test.sh              ✅ Test all API endpoints
├── Dockerfile               ✅ Multi-arch Docker build
├── docker-compose.yml       ✅ Easy testing setup
├── requirements.txt         ✅ Python dependencies
├── env.example              ✅ Configuration template
├── README.md                ✅ Complete documentation
└── TESTING_GUIDE.md         ✅ This file
```

---

## 🚀 Usage Scenarios

### Scenario 1: Test API Structure (No Model)
**Use case**: Verify Docker build, API endpoints, Qt6 GUI connectivity

```bash
./scripts/build.sh          # Build image
docker-compose up -d        # Start backend
./scripts/test.sh           # Test APIs
```

**Result**: 
- ✅ All endpoints work
- ✅ Returns `[MOCK TRANSCRIPTION]` responses
- ✅ Perfect for development/testing

---

### Scenario 2: Test With Real Whisper Model
**Use case**: Full production testing before Raspberry Pi deployment

```bash
# 1. Convert Whisper to ONNX (one-time, see README.md)
# 2. Place model in models/whisper-base-onnx/
# 3. Run with model mounted

docker run -d \
    -p 8000:8000 \
    -v $(pwd)/models/whisper-base-onnx:/app/models/whisper-base-onnx:ro \
    whisper-backend-onnx:test

# 4. Test real transcription
curl -X POST http://localhost:8000/transcribe \
    -F "audio_file=@test_audio/speech.wav" \
    -F "language=en"
```

**Result**:
- ✅ Real Whisper transcription
- ✅ Verify accuracy before RPi deployment

---

### Scenario 3: Build for Raspberry Pi (Cross-compile)
**Use case**: Prepare ARM64 image for Raspberry Pi 4

```bash
# Build for ARM64
./scripts/build.sh --arm64

# Save image
docker save whisper-backend-onnx:test | gzip > whisper-arm64.tar.gz

# Transfer to Raspberry Pi
scp whisper-arm64.tar.gz ferganey@raspberrypi.local:~/

# On Raspberry Pi:
gunzip -c whisper-arm64.tar.gz | docker load
docker run -d -p 8000:8000 --name whisper-backend whisper-backend-onnx:test
```

---

## 🔍 Testing Commands

### Manual API Testing

```bash
# Health check
curl http://localhost:8000/health
# {"status":"healthy","model_loaded":false,"timestamp":...}

# Service info
curl http://localhost:8000/
# {"name":"Whisper ONNX Transcription Backend","mode":"mock",...}

# Detailed status
curl http://localhost:8000/status/detailed | jq
# Full system information

# Test transcription (mock)
curl -X POST http://localhost:8000/transcribe \
    -F "audio_file=@test_audio/test.wav" \
    -F "language=en" | jq
# {"text":"[MOCK TRANSCRIPTION]...","duration":5.2,...}
```

### Docker Commands

```bash
# View logs
docker logs whisper-backend-test -f

# Check container stats
docker stats whisper-backend-test

# Restart container
docker restart whisper-backend-test

# Stop and remove
docker-compose down

# Rebuild from scratch
docker-compose build --no-cache
docker-compose up -d
```

---

## 📊 Expected Output

### Successful Build
```
✅ Docker image built successfully!
Image: whisper-backend-onnx:test
Image details:
whisper-backend-onnx   test     abc123456789   2 minutes ago   1.2GB
whisper-backend-onnx   latest   abc123456789   2 minutes ago   1.2GB
```

### Successful Test
```
🧪 Testing Whisper ONNX Backend API
====================================
✓ Backend is running
Test 1: Root endpoint (/)
✓ Test 1 passed
Test 2: Health check (/health)
✓ Test 2 passed - Backend is healthy
Test 3: Detailed status (/status/detailed)
✓ Test 3 passed
Test 5: Transcribe audio file (POST /transcribe)
✓ Test 5 passed (mock mode)

================================
✅ All tests completed!
================================
```

---

## 🎭 Mock Mode vs Production Mode

### Mock Mode (Default)
- ✅ **No Whisper model required**
- ✅ **Fast testing** (instant responses)
- ✅ **API structure verification**
- ✅ **Docker build testing**
- ✅ **Qt6 GUI connectivity testing**

**When to use:**
- Testing Docker build process
- Verifying API endpoints
- Testing without Raspberry Pi
- CI/CD pipelines
- Initial development

### Production Mode (With Model)
- ✅ **Real Whisper transcription**
- ✅ **Accuracy testing**
- ✅ **Performance benchmarking**
- ✅ **End-to-end validation**

**When to use:**
- Final testing before deployment
- Accuracy verification
- Performance benchmarking
- Production deployment

---

## 🏗️ Build Options

| Command | Platform | Use Case | Build Time |
|---------|----------|----------|------------|
| `./scripts/build.sh` | x86_64 | Test on your PC | 10-15 min |
| `./scripts/build.sh --arm64` | ARM64 | Build for RPi4 | 30-45 min |
| `./scripts/build.sh --multi-arch` | Both | Universal image | 45-60 min |

---

## 🐛 Common Issues & Solutions

### Issue: "Port 8000 already in use"
```bash
# Find process using port 8000
sudo netstat -tulpn | grep 8000

# Kill it
sudo kill -9 <PID>

# Or use a different port
docker run -d -p 8001:8000 whisper-backend-onnx:test
```

### Issue: "Docker build failed"
```bash
# Clean up Docker
docker system prune -a

# Check disk space
df -h

# Rebuild with no cache
docker build --no-cache -t whisper-backend-onnx:test .
```

### Issue: "Container starts but immediately exits"
```bash
# Check logs
docker logs whisper-backend-test

# Common causes:
# 1. Missing dependencies → Check requirements.txt
# 2. Syntax error in Python → Check logs
# 3. Port conflict → Use different port
```

---

## 📈 Performance Expectations

### On Development PC (x86_64, Example: Intel i7)
- **Build time**: 10-15 minutes
- **Image size**: ~1.2GB
- **Startup time**: 5 seconds
- **Mock transcription**: Instant
- **Real transcription** (with model): 1-2 seconds for 5s audio

### On Raspberry Pi 4 (ARM64, 4GB RAM)
- **Image size**: ~1.1GB  
- **Startup time**: 10-15 seconds
- **Mock transcription**: Instant
- **Real transcription** (with model): 6-8 seconds for 5s audio

---

## ✅ Pre-Deployment Checklist

Before deploying to Raspberry Pi, verify:

- [ ] Docker image builds successfully
- [ ] Container starts without errors
- [ ] Health endpoint returns `{"status":"healthy"}`
- [ ] All API endpoints respond correctly
- [ ] Test script passes all tests
- [ ] (Optional) Real transcription works with Whisper model
- [ ] Qt6 GUI can connect (if available)
- [ ] Performance is acceptable

---

## 🔗 Integration with Main Project

This testing environment is integrated with your main project:

1. **Copy to Yocto**: Files ready to copy to `meta-userapp/recipes-docker/`
2. **Qt6 GUI**: Already refactored to connect to this backend
3. **Documentation**: Links to main project documentation

**Next steps:**
1. Test here (mock mode) ✅
2. Add Whisper model (optional)
3. Test production mode
4. Copy to Yocto recipe
5. Build with Bitbake
6. Deploy to Raspberry Pi

---

## 📚 See Also

- **README.md**: Complete documentation
- **../Documentation/WHISPER_ONNX_INTEGRATION_PLAN.md**: Integration guide
- **../Documentation/GUI_REFACTORING_SUMMARY.md**: GUI refactoring details
- **../QUICKSTART_REFACTORED_GUI.md**: Quick start guide

---

## 🎉 Summary

You now have a **complete, self-contained Docker testing environment** for the Whisper ONNX backend!

**Key Benefits:**
- ✅ Test without Raspberry Pi hardware
- ✅ Fast iterative development
- ✅ Mock mode for API testing
- ✅ Production mode for full validation
- ✅ Easy deployment to Raspberry Pi

**Get Started:**
```bash
cd whisper_backend_docker_test
./scripts/build.sh
docker-compose up -d
./scripts/test.sh
```

**Happy Testing! 🚀**

