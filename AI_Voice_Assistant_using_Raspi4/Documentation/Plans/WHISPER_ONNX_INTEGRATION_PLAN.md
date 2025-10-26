# 🎙️ Whisper ONNX Integration Plan for Raspberry Pi 4
## Complete Implementation Guide for Audio Transcription Backend

**Project**: AI Voice Assistant for Autonomous Vehicles  
**Target**: Raspberry Pi 4 (ARM64) + Yocto Linux + Docker  
**Backend**: Whisper (ONNX Runtime optimized)  
**Frontend**: Qt6 Voice Assistant GUI  
**Date**: October 26, 2025

---

## 📋 Table of Contents

1. [Executive Summary](#executive-summary)
2. [Technology Selection: ONNX vs TensorFlow](#technology-selection)
3. [System Architecture Overview](#system-architecture)
4. [Phase 1: Whisper Model Conversion to ONNX](#phase-1-whisper-model-conversion)
5. [Phase 2: Docker Backend Development](#phase-2-docker-backend)
6. [Phase 3: Frontend-Backend Integration](#phase-3-frontend-backend)
7. [Phase 4: Yocto Integration](#phase-4-yocto-integration)
8. [Phase 5: Performance Optimization](#phase-5-optimization)
9. [Phase 6: Testing & Deployment](#phase-6-testing)
10. [Timeline & Milestones](#timeline)
11. [Resource Requirements](#resources)
12. [Troubleshooting Guide](#troubleshooting)

---

## 1. Executive Summary

### 🎯 Objective
Create a production-ready audio transcription backend using OpenAI Whisper model optimized with ONNX Runtime, running in a Docker container on Raspberry Pi 4, serving a Qt6 GUI frontend.

### 🏆 Key Features
- **Real-time audio transcription** using Whisper Tiny/Base models
- **ONNX Runtime optimization** for ARM64 (3-5x faster than PyTorch)
- **Docker containerization** for isolation and portability
- **REST + WebSocket API** for frontend communication
- **Hardware acceleration** using NEON SIMD instructions
- **Low latency** (<2 seconds transcription time)
- **Memory efficient** (<800MB RAM usage)

### 📊 Expected Performance (Raspberry Pi 4 - 4GB)
| Model | Size | Speed (RTF) | Accuracy | Memory | Latency |
|-------|------|-------------|----------|---------|---------|
| Whisper Tiny | 39MB | 0.8x | ~80% | 400MB | ~1.5s |
| Whisper Base | 74MB | 1.2x | ~85% | 600MB | ~2.0s |
| Whisper Small | 244MB | 2.5x | ~90% | 1.2GB | ~4.0s |

**Recommendation**: Start with **Whisper Base** (best accuracy/speed trade-off)

---

## 2. Technology Selection: ONNX vs TensorFlow

### 🏅 Why ONNX Runtime for Whisper on Raspberry Pi 4?

| Criteria | ONNX Runtime | TensorFlow Lite | Winner |
|----------|--------------|-----------------|--------|
| **Whisper Support** | ✅ Native (via transformers) | ⚠️ Complex conversion | **ONNX** |
| **ARM64 Optimization** | ✅ NEON, quantization | ✅ XNNPACK | **Tie** |
| **Memory Usage** | ✅ 400-600MB | ⚠️ 600-800MB | **ONNX** |
| **Inference Speed** | ✅ 1.5-2s (Base) | ⚠️ 2-3s | **ONNX** |
| **Model Size** | ✅ 74MB (Base) | ⚠️ 90MB | **ONNX** |
| **Quantization** | ✅ INT8, FP16 | ✅ INT8 | **Tie** |
| **Community Support** | ✅ Large (Microsoft) | ✅ Large (Google) | **Tie** |
| **Yocto Integration** | ✅ meta-onnxruntime | ✅ meta-tensorflow-lite | **Tie** |
| **Python API** | ✅ Simple | ✅ Simple | **Tie** |
| **Docker Size** | ✅ 800MB | ⚠️ 1.2GB | **ONNX** |

### ✅ Decision: ONNX Runtime

**Primary Reasons:**
1. **Better Whisper support**: HuggingFace `optimum` library provides direct PyTorch → ONNX conversion
2. **Lower memory footprint**: Critical for 4GB Raspberry Pi 4
3. **Faster inference**: ONNX Runtime has better ARM64 optimizations
4. **Simpler deployment**: No complex TFLite conversion pipeline

**TensorFlow Lite Use Case:**
- Use TFLite for **other** models (gesture recognition, object detection) that have better TFLite support
- Keep ONNX for Whisper specifically

---

## 3. System Architecture Overview

### 🏗️ Three-Tier Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     RASPBERRY PI 4 (Yocto Linux)                │
├─────────────────────────────────────────────────────────────────┤
│  ┌───────────────────────────┐  ┌──────────────────────────┐   │
│  │    Qt6 GUI (Frontend)     │◄─┤   REST/WebSocket API     │   │
│  │  - Voice visualization    │  │   (HTTP + WS Server)     │   │
│  │  - Transcription display  │  └──────────┬───────────────┘   │
│  │  - Settings panel         │             │                    │
│  │  - Audio capture          │             │                    │
│  └───────────┬───────────────┘             │                    │
│              │                              │                    │
│              │ Audio stream (WebSocket)     │                    │
│              │                              │                    │
│  ┌───────────▼──────────────────────────────▼──────────────┐   │
│  │          Docker Container (Backend)                      │   │
│  │  ┌──────────────────────────────────────────────────┐   │   │
│  │  │  FastAPI/Flask Server                            │   │   │
│  │  │  - /transcribe (POST) - Audio → Text            │   │   │
│  │  │  - /stream (WebSocket) - Real-time streaming    │   │   │
│  │  │  - /status (GET) - Health check                 │   │   │
│  │  └─────────────────┬────────────────────────────────┘   │   │
│  │                    │                                     │   │
│  │  ┌─────────────────▼────────────────────────────────┐   │   │
│  │  │  Audio Processing Pipeline                       │   │   │
│  │  │  - VAD (Voice Activity Detection)               │   │   │
│  │  │  - Preprocessing (16kHz, mono, normalize)      │   │   │
│  │  │  - Ring buffer (60s circular buffer)           │   │   │
│  │  └─────────────────┬────────────────────────────────┘   │   │
│  │                    │                                     │   │
│  │  ┌─────────────────▼────────────────────────────────┐   │   │
│  │  │  ONNX Runtime + Whisper Model                    │   │   │
│  │  │  - Whisper Base (74MB, FP16 quantized)         │   │   │
│  │  │  - ARM64 optimized execution provider          │   │   │
│  │  │  - INT8 quantization (future)                   │   │   │
│  │  └──────────────────────────────────────────────────┘   │   │
│  │                                                          │   │
│  │  Storage:                                                │   │
│  │  - /models/whisper-base-onnx/                           │   │
│  │  - /cache/audio_buffers/                                │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
│  System Resources:                                              │
│  - ALSA audio drivers                                           │
│  - Docker CE runtime                                            │
│  - Network bridge (frontend ↔ backend)                         │
└─────────────────────────────────────────────────────────────────┘
```

### 📡 Communication Protocol

**REST API** (Initial/simple requests):
```
Frontend → Backend: POST /transcribe
Body: { "audio_base64": "...", "language": "en" }
Response: { "text": "transcribed text", "confidence": 0.95 }
```

**WebSocket** (Real-time streaming):
```
Frontend → Backend: WS /stream
Send: Audio chunks (8KB every 100ms)
Receive: { "partial": "transcribing...", "final": "done!" }
```

---

## 4. Phase 1: Whisper Model Conversion to ONNX

### 📦 Step 1.1: Setup Conversion Environment (On Development PC)

**Why on PC?**: Model conversion is computationally intensive, better done on x86_64 PC, then deploy to Raspberry Pi

```bash
# On your development PC (Ubuntu 24.04)
cd ~/whisper-conversion

# Create Python virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install --upgrade pip
pip install torch transformers optimum[onnxruntime]
pip install onnx onnxruntime numpy soundfile librosa
```

**Packages explained:**
- `torch`: PyTorch (needed for loading Whisper)
- `transformers`: HuggingFace Transformers (Whisper implementation)
- `optimum[onnxruntime]`: HuggingFace ONNX conversion tools
- `onnx`: ONNX format manipulation
- `onnxruntime`: ONNX inference engine

---

### 📦 Step 1.2: Convert Whisper to ONNX

**Script**: `convert_whisper_to_onnx.py`

```python
#!/usr/bin/env python3
"""
Convert OpenAI Whisper model to ONNX format for Raspberry Pi 4 deployment
"""
import os
from pathlib import Path
from optimum.onnxruntime import ORTModelForSpeechSeq2Seq
from transformers import AutoProcessor
import torch

# Configuration
MODEL_NAME = "openai/whisper-base"  # Options: whisper-tiny, whisper-base, whisper-small
OUTPUT_DIR = "./whisper-base-onnx"
QUANTIZATION = "fp16"  # Options: none, fp16, int8

def convert_whisper():
    print(f"🚀 Converting {MODEL_NAME} to ONNX...")
    
    # Step 1: Load PyTorch model
    print("📥 Loading PyTorch model from HuggingFace...")
    model = ORTModelForSpeechSeq2Seq.from_pretrained(
        MODEL_NAME,
        export=True,  # This triggers ONNX conversion
        provider="CPUExecutionProvider",  # For ARM64
    )
    
    # Step 2: Load processor (tokenizer + feature extractor)
    print("📥 Loading processor...")
    processor = AutoProcessor.from_pretrained(MODEL_NAME)
    
    # Step 3: Optimize for ARM64
    print("⚙️ Optimizing for ARM64...")
    model.model.optimize()
    
    # Step 4: Quantize to FP16 (reduces size by 50%)
    if QUANTIZATION == "fp16":
        print("🔧 Quantizing to FP16...")
        model.model.quantize(quantization_config={
            "is_static": False,
            "format": "QDQ",
            "per_channel": False,
            "reduce_range": False,
            "weight_type": "FP16",
        })
    
    # Step 5: Save ONNX model
    print(f"💾 Saving to {OUTPUT_DIR}...")
    model.save_pretrained(OUTPUT_DIR)
    processor.save_pretrained(OUTPUT_DIR)
    
    # Step 6: Verify ONNX model
    print("✅ Verifying ONNX model...")
    import onnx
    encoder_path = Path(OUTPUT_DIR) / "encoder_model.onnx"
    decoder_path = Path(OUTPUT_DIR) / "decoder_model.onnx"
    
    encoder_model = onnx.load(str(encoder_path))
    decoder_model = onnx.load(str(decoder_path))
    
    onnx.checker.check_model(encoder_model)
    onnx.checker.check_model(decoder_model)
    
    # Step 7: Print model info
    print("\n📊 Model Information:")
    print(f"  Encoder size: {encoder_path.stat().st_size / 1e6:.1f} MB")
    print(f"  Decoder size: {decoder_path.stat().st_size / 1e6:.1f} MB")
    print(f"  Total size: {(encoder_path.stat().st_size + decoder_path.stat().st_size) / 1e6:.1f} MB")
    
    print("\n✅ Conversion complete!")
    print(f"📁 ONNX model saved to: {Path(OUTPUT_DIR).absolute()}")
    
    return OUTPUT_DIR

def test_inference(model_dir):
    """Test ONNX model inference with dummy audio"""
    print("\n🧪 Testing ONNX inference...")
    
    import numpy as np
    from transformers import AutoProcessor
    from optimum.onnxruntime import ORTModelForSpeechSeq2Seq
    
    # Load ONNX model
    model = ORTModelForSpeechSeq2Seq.from_pretrained(
        model_dir,
        provider="CPUExecutionProvider",
    )
    processor = AutoProcessor.from_pretrained(model_dir)
    
    # Generate dummy audio (5 seconds of silence + sine wave)
    sample_rate = 16000
    duration = 5
    audio = np.sin(2 * np.pi * 440 * np.arange(sample_rate * duration) / sample_rate)
    audio = audio.astype(np.float32)
    
    # Process audio
    inputs = processor(audio, sampling_rate=sample_rate, return_tensors="pt")
    
    # Run inference
    print("⏱️ Running inference...")
    import time
    start = time.time()
    generated_ids = model.generate(inputs["input_features"])
    inference_time = time.time() - start
    
    # Decode transcription
    transcription = processor.batch_decode(generated_ids, skip_special_tokens=True)
    
    print(f"✅ Inference completed in {inference_time:.2f} seconds")
    print(f"📝 Transcription: {transcription[0]}")
    print(f"⚡ Real-time factor: {duration / inference_time:.2f}x")

if __name__ == "__main__":
    output_dir = convert_whisper()
    test_inference(output_dir)
```

**Run conversion:**
```bash
python convert_whisper_to_onnx.py
```

**Expected output:**
```
🚀 Converting openai/whisper-base to ONNX...
📥 Loading PyTorch model from HuggingFace...
📥 Loading processor...
⚙️ Optimizing for ARM64...
🔧 Quantizing to FP16...
💾 Saving to ./whisper-base-onnx...
✅ Verifying ONNX model...

📊 Model Information:
  Encoder size: 45.2 MB
  Decoder size: 28.8 MB
  Total size: 74.0 MB

✅ Conversion complete!
📁 ONNX model saved to: /home/user/whisper-conversion/whisper-base-onnx

🧪 Testing ONNX inference...
⏱️ Running inference...
✅ Inference completed in 2.34 seconds
📝 Transcription: (silence or test audio transcribed)
⚡ Real-time factor: 2.14x
```

---

### 📦 Step 1.3: Model Variants and Selection

**Available Whisper models:**

| Model | Parameters | Size (PyTorch) | Size (ONNX FP16) | Speed (RPI4) | Accuracy |
|-------|------------|----------------|------------------|--------------|----------|
| Tiny | 39M | 152 MB | 39 MB | 0.8x RTF | ~75% WER |
| Base | 74M | 290 MB | 74 MB | 1.2x RTF | ~80% WER |
| Small | 244M | 967 MB | 244 MB | 2.5x RTF | ~85% WER |
| Medium | 769M | 3.1 GB | 769 MB | ❌ Too slow | ~90% WER |

**RTF (Real-Time Factor)**: 1.0x = processes audio at same speed as playback

**Recommendation matrix:**

| Use Case | Model | Reason |
|----------|-------|--------|
| **Development/Testing** | Tiny | Fastest iteration, low memory |
| **Production (Recommended)** | **Base** | Best accuracy/speed trade-off |
| **High Accuracy** | Small | If you have 4GB RAM and accept 2.5x latency |
| **Offline Processing** | Small | When real-time is not required |

**Convert all three:**
```bash
# Tiny (39MB)
MODEL_NAME="openai/whisper-tiny" OUTPUT_DIR="./whisper-tiny-onnx" python convert_whisper_to_onnx.py

# Base (74MB) - RECOMMENDED
MODEL_NAME="openai/whisper-base" OUTPUT_DIR="./whisper-base-onnx" python convert_whisper_to_onnx.py

# Small (244MB)
MODEL_NAME="openai/whisper-small" OUTPUT_DIR="./whisper-small-onnx" python convert_whisper_to_onnx.py
```

---

### 📦 Step 1.4: Transfer Models to Raspberry Pi

**Option 1: SCP (Secure Copy)**
```bash
# From your PC
scp -r whisper-base-onnx/ ferganey@raspberrypi.local:/home/ferganey/models/

# Or if using IP address
scp -r whisper-base-onnx/ ferganey@192.168.1.100:/home/ferganey/models/
```

**Option 2: Docker Volume (Recommended)**
```bash
# Package models into Docker image (see Phase 2)
# Models will be baked into the Docker image
```

**Option 3: USB Drive**
```bash
# Copy to USB drive
cp -r whisper-*-onnx/ /media/usb-drive/

# On Raspberry Pi
sudo mount /dev/sda1 /mnt/usb
cp -r /mnt/usb/whisper-*-onnx/ /home/ferganey/models/
```

---

## 5. Phase 2: Docker Backend Development

### 🐳 Step 2.1: Project Structure

```
audio_transcription_backend/
├── Dockerfile                      # Multi-stage ARM64 Docker build
├── requirements.txt               # Python dependencies
├── app/
│   ├── __init__.py
│   ├── main.py                   # FastAPI application entry point
│   ├── models.py                 # Pydantic models (request/response)
│   ├── whisper_engine.py         # ONNX Whisper inference engine
│   ├── audio_processor.py        # Audio preprocessing pipeline
│   ├── config.py                 # Configuration management
│   └── utils.py                  # Helper functions
├── models/                        # ONNX models directory
│   ├── whisper-tiny-onnx/
│   ├── whisper-base-onnx/        # Default model
│   └── whisper-small-onnx/
├── tests/
│   ├── test_api.py
│   ├── test_whisper.py
│   └── test_audio.py
├── scripts/
│   ├── download_models.sh        # Download ONNX models
│   └── benchmark.py              # Performance benchmarking
└── docker-compose.yml            # Optional: for local testing
```

---

### 🐳 Step 2.2: Dockerfile (Multi-stage ARM64 Build)

**`Dockerfile`:**

```dockerfile
# Stage 1: Build environment
FROM arm64v8/python:3.10-slim-bullseye AS builder

LABEL maintainer="Ahmed Ferganey <ahmedferganey707@gmail.com>"
LABEL description="Whisper ONNX Audio Transcription Backend for Raspberry Pi 4"

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    libsndfile1-dev \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Create virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install Python dependencies
COPY requirements.txt /tmp/
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r /tmp/requirements.txt

# Stage 2: Runtime environment
FROM arm64v8/python:3.10-slim-bullseye

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libsndfile1 \
    libgomp1 \
    alsa-utils \
    && rm -rf /var/lib/apt/lists/*

# Copy virtual environment from builder
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Create app directory
WORKDIR /app

# Copy application code
COPY app/ /app/app/
COPY scripts/ /app/scripts/

# Copy ONNX models (or download at runtime)
COPY models/ /app/models/

# Create cache directory for audio buffers
RUN mkdir -p /app/cache/audio_buffers

# Expose API port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:8000/health')"

# Run FastAPI with uvicorn
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1"]
```

---

### 🐳 Step 2.3: Python Dependencies

**`requirements.txt`:**

```txt
# Web framework
fastapi==0.104.1
uvicorn[standard]==0.24.0
python-multipart==0.0.6
websockets==12.0

# ONNX Runtime (ARM64 optimized)
onnxruntime==1.16.3

# HuggingFace
transformers==4.35.2
optimum[onnxruntime]==1.15.0

# Audio processing
numpy==1.24.3
soundfile==0.12.1
librosa==0.10.1
resampy==0.4.2

# Utilities
pydantic==2.5.0
python-dotenv==1.0.0
aiofiles==23.2.1

# Monitoring (optional)
prometheus-fastapi-instrumentator==6.1.0
```

**Install dependencies:**
```bash
pip install -r requirements.txt
```

---

### 🐳 Step 2.4: Configuration Management

**`app/config.py`:**

```python
"""Configuration management for Whisper backend"""
import os
from pathlib import Path
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    # Application
    APP_NAME: str = "Whisper ONNX Transcription Backend"
    VERSION: str = "1.0.0"
    DEBUG: bool = False
    
    # Server
    HOST: str = "0.0.0.0"
    PORT: int = 8000
    WORKERS: int = 1  # Single worker for Raspberry Pi
    
    # Model settings
    MODEL_NAME: str = "whisper-base-onnx"
    MODELS_DIR: Path = Path("/app/models")
    MODEL_PATH: Path = MODELS_DIR / MODEL_NAME
    
    # Audio settings
    SAMPLE_RATE: int = 16000
    CHANNELS: int = 1  # Mono
    CHUNK_SIZE: int = 8192
    MAX_AUDIO_LENGTH: int = 30  # seconds
    
    # ONNX Runtime settings
    ONNX_NUM_THREADS: int = 4  # Use all 4 cores of RPi4
    ONNX_INTRA_OP_NUM_THREADS: int = 4
    ONNX_INTER_OP_NUM_THREADS: int = 1
    
    # Cache
    CACHE_DIR: Path = Path("/app/cache")
    AUDIO_BUFFER_DIR: Path = CACHE_DIR / "audio_buffers"
    MAX_CACHE_SIZE_MB: int = 500
    
    # Logging
    LOG_LEVEL: str = "INFO"
    LOG_FORMAT: str = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
    
    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"

# Global settings instance
settings = Settings()

# Ensure directories exist
settings.MODELS_DIR.mkdir(parents=True, exist_ok=True)
settings.AUDIO_BUFFER_DIR.mkdir(parents=True, exist_ok=True)
```

---

### 🐳 Step 2.5: Whisper ONNX Inference Engine

**`app/whisper_engine.py`:**

```python
"""ONNX Whisper inference engine optimized for Raspberry Pi 4"""
import time
import logging
from pathlib import Path
from typing import Dict, Optional, List
import numpy as np
from optimum.onnxruntime import ORTModelForSpeechSeq2Seq
from transformers import AutoProcessor
import onnxruntime as ort

from .config import settings

logger = logging.getLogger(__name__)

class WhisperONNXEngine:
    """ONNX Runtime Whisper inference engine with ARM64 optimizations"""
    
    def __init__(self, model_path: Optional[Path] = None):
        self.model_path = model_path or settings.MODEL_PATH
        self.model = None
        self.processor = None
        self.session_options = None
        self._initialize()
    
    def _initialize(self):
        """Initialize ONNX Runtime with ARM64 optimizations"""
        logger.info(f"🚀 Initializing Whisper ONNX engine from {self.model_path}")
        
        # Configure ONNX Runtime session options
        self.session_options = ort.SessionOptions()
        self.session_options.intra_op_num_threads = settings.ONNX_INTRA_OP_NUM_THREADS
        self.session_options.inter_op_num_threads = settings.ONNX_INTER_OP_NUM_THREADS
        self.session_options.graph_optimization_level = ort.GraphOptimizationLevel.ORT_ENABLE_ALL
        
        # Enable ARM64 optimizations
        self.session_options.enable_cpu_mem_arena = True
        self.session_options.enable_mem_pattern = True
        
        try:
            # Load ONNX model
            logger.info("📥 Loading ONNX model...")
            self.model = ORTModelForSpeechSeq2Seq.from_pretrained(
                str(self.model_path),
                provider="CPUExecutionProvider",
                session_options=self.session_options,
            )
            
            # Load processor (tokenizer + feature extractor)
            logger.info("📥 Loading processor...")
            self.processor = AutoProcessor.from_pretrained(str(self.model_path))
            
            logger.info("✅ Whisper ONNX engine initialized successfully")
            
            # Warm-up inference
            self._warmup()
            
        except Exception as e:
            logger.error(f"❌ Failed to initialize Whisper engine: {e}")
            raise
    
    def _warmup(self):
        """Warm-up inference with dummy audio"""
        logger.info("🔥 Warming up model...")
        dummy_audio = np.zeros(16000 * 5, dtype=np.float32)  # 5 seconds
        try:
            self.transcribe(dummy_audio, language="en")
            logger.info("✅ Warm-up complete")
        except Exception as e:
            logger.warning(f"⚠️ Warm-up failed: {e}")
    
    def transcribe(
        self,
        audio: np.ndarray,
        language: str = "en",
        task: str = "transcribe",
    ) -> Dict:
        """
        Transcribe audio using Whisper ONNX model
        
        Args:
            audio: Audio array (16kHz, mono, float32)
            language: Language code (e.g., "en", "ar", "fr")
            task: "transcribe" or "translate"
        
        Returns:
            Dictionary with transcription and metadata
        """
        if self.model is None or self.processor is None:
            raise RuntimeError("Whisper engine not initialized")
        
        start_time = time.time()
        
        try:
            # Preprocess audio
            logger.debug(f"🎤 Processing audio: shape={audio.shape}, duration={len(audio)/16000:.2f}s")
            
            inputs = self.processor(
                audio,
                sampling_rate=settings.SAMPLE_RATE,
                return_tensors="pt",
            )
            
            # Run inference
            logger.debug("⚙️ Running inference...")
            inference_start = time.time()
            
            generated_ids = self.model.generate(
                inputs["input_features"],
                language=language,
                task=task,
                max_length=448,  # Whisper's max token length
            )
            
            inference_time = time.time() - inference_start
            
            # Decode transcription
            transcription = self.processor.batch_decode(
                generated_ids,
                skip_special_tokens=True,
            )[0]
            
            total_time = time.time() - start_time
            audio_duration = len(audio) / settings.SAMPLE_RATE
            rtf = inference_time / audio_duration if audio_duration > 0 else 0
            
            result = {
                "text": transcription.strip(),
                "language": language,
                "duration": audio_duration,
                "inference_time": inference_time,
                "total_time": total_time,
                "rtf": rtf,  # Real-time factor
                "timestamp": time.time(),
            }
            
            logger.info(f"✅ Transcription complete: '{transcription[:50]}...' "
                       f"(RTF: {rtf:.2f}x, time: {inference_time:.2f}s)")
            
            return result
            
        except Exception as e:
            logger.error(f"❌ Transcription failed: {e}")
            raise
    
    def transcribe_file(self, audio_file: Path, **kwargs) -> Dict:
        """Transcribe audio from file"""
        import soundfile as sf
        
        logger.info(f"📁 Loading audio file: {audio_file}")
        audio, sr = sf.read(audio_file, dtype=np.float32)
        
        # Resample if needed
        if sr != settings.SAMPLE_RATE:
            import librosa
            audio = librosa.resample(audio, orig_sr=sr, target_sr=settings.SAMPLE_RATE)
        
        # Convert stereo to mono if needed
        if len(audio.shape) > 1:
            audio = audio.mean(axis=1)
        
        return self.transcribe(audio, **kwargs)
    
    def get_model_info(self) -> Dict:
        """Get model information"""
        return {
            "model_name": self.model_path.name,
            "model_path": str(self.model_path),
            "sample_rate": settings.SAMPLE_RATE,
            "onnx_runtime_version": ort.__version__,
            "num_threads": settings.ONNX_NUM_THREADS,
        }

# Global engine instance (singleton)
_engine: Optional[WhisperONNXEngine] = None

def get_engine() -> WhisperONNXEngine:
    """Get or create global Whisper engine instance"""
    global _engine
    if _engine is None:
        _engine = WhisperONNXEngine()
    return _engine
```

---

### 🐳 Step 2.6: Audio Preprocessing Pipeline

**`app/audio_processor.py`:**

```python
"""Audio preprocessing pipeline for Whisper"""
import logging
from typing import Tuple
import numpy as np
import librosa
from .config import settings

logger = logging.getLogger(__name__)

class AudioProcessor:
    """Audio preprocessing for Whisper transcription"""
    
    @staticmethod
    def preprocess(
        audio: np.ndarray,
        sample_rate: int,
        normalize: bool = True,
        trim_silence: bool = True,
    ) -> Tuple[np.ndarray, int]:
        """
        Preprocess audio for Whisper
        
        Args:
            audio: Raw audio array
            sample_rate: Original sample rate
            normalize: Apply normalization
            trim_silence: Remove leading/trailing silence
        
        Returns:
            Preprocessed audio and target sample rate
        """
        # Resample to 16kHz (Whisper's expected sample rate)
        if sample_rate != settings.SAMPLE_RATE:
            logger.debug(f"Resampling from {sample_rate}Hz to {settings.SAMPLE_RATE}Hz")
            audio = librosa.resample(
                audio,
                orig_sr=sample_rate,
                target_sr=settings.SAMPLE_RATE,
            )
        
        # Convert stereo to mono
        if len(audio.shape) > 1:
            logger.debug("Converting stereo to mono")
            audio = audio.mean(axis=1)
        
        # Trim silence
        if trim_silence:
            audio, _ = librosa.effects.trim(
                audio,
                top_db=30,  # Silence threshold in dB
                frame_length=2048,
                hop_length=512,
            )
        
        # Normalize audio
        if normalize:
            audio = AudioProcessor.normalize_audio(audio)
        
        # Ensure float32 dtype
        audio = audio.astype(np.float32)
        
        return audio, settings.SAMPLE_RATE
    
    @staticmethod
    def normalize_audio(audio: np.ndarray, target_level: float = -20.0) -> np.ndarray:
        """Normalize audio to target RMS level"""
        rms = np.sqrt(np.mean(audio**2))
        if rms > 0:
            scalar = 10 ** (target_level / 20) / rms
            audio = audio * scalar
        
        # Clip to [-1, 1]
        audio = np.clip(audio, -1.0, 1.0)
        return audio
    
    @staticmethod
    def detect_voice_activity(audio: np.ndarray, threshold: float = 0.01) -> bool:
        """Simple Voice Activity Detection"""
        energy = np.sqrt(np.mean(audio**2))
        return energy > threshold
    
    @staticmethod
    def chunk_audio(audio: np.ndarray, chunk_duration: float = 30.0) -> list:
        """Split long audio into chunks"""
        chunk_samples = int(chunk_duration * settings.SAMPLE_RATE)
        chunks = []
        
        for i in range(0, len(audio), chunk_samples):
            chunk = audio[i:i + chunk_samples]
            if len(chunk) > 0:
                chunks.append(chunk)
        
        return chunks
```

---

### 🐳 Step 2.7: FastAPI Application

**`app/main.py`:**

```python
"""FastAPI application for Whisper ONNX transcription backend"""
import logging
import time
from pathlib import Path
from typing import Optional
import io
import base64

from fastapi import FastAPI, File, UploadFile, HTTPException, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import numpy as np
import soundfile as sf

from .config import settings
from .whisper_engine import get_engine
from .audio_processor import AudioProcessor
from .models import (
    TranscribeRequest,
    TranscribeResponse,
    HealthResponse,
    ModelInfoResponse,
)

# Configure logging
logging.basicConfig(
    level=settings.LOG_LEVEL,
    format=settings.LOG_FORMAT,
)
logger = logging.getLogger(__name__)

# Create FastAPI app
app = FastAPI(
    title=settings.APP_NAME,
    version=settings.VERSION,
    description="Whisper ONNX audio transcription backend for Raspberry Pi 4",
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify Qt6 app's origin
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize components
audio_processor = AudioProcessor()

@app.on_event("startup")
async def startup_event():
    """Initialize Whisper engine on startup"""
    logger.info("🚀 Starting Whisper ONNX Transcription Backend...")
    try:
        engine = get_engine()
        logger.info(f"✅ Engine initialized: {engine.get_model_info()}")
    except Exception as e:
        logger.error(f"❌ Failed to initialize engine: {e}")
        raise

@app.get("/", response_model=dict)
async def root():
    """Root endpoint"""
    return {
        "name": settings.APP_NAME,
        "version": settings.VERSION,
        "status": "running",
    }

@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Health check endpoint"""
    try:
        engine = get_engine()
        return HealthResponse(
            status="healthy",
            model_loaded=engine.model is not None,
            timestamp=time.time(),
        )
    except Exception as e:
        raise HTTPException(status_code=503, detail=f"Service unhealthy: {e}")

@app.get("/model/info", response_model=ModelInfoResponse)
async def model_info():
    """Get model information"""
    try:
        engine = get_engine()
        info = engine.get_model_info()
        return ModelInfoResponse(**info)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/transcribe", response_model=TranscribeResponse)
async def transcribe_audio(
    audio_file: UploadFile = File(...),
    language: str = "en",
    normalize: bool = True,
    trim_silence: bool = True,
):
    """
    Transcribe audio file
    
    Args:
        audio_file: Audio file (WAV, MP3, FLAC, etc.)
        language: Language code (en, ar, fr, etc.)
        normalize: Apply audio normalization
        trim_silence: Remove silence
    
    Returns:
        Transcription result
    """
    start_time = time.time()
    
    try:
        logger.info(f"📥 Received audio file: {audio_file.filename}")
        
        # Read audio file
        audio_bytes = await audio_file.read()
        audio_io = io.BytesIO(audio_bytes)
        
        # Load audio with soundfile
        audio, sample_rate = sf.read(audio_io, dtype=np.float32)
        
        # Preprocess audio
        audio, sample_rate = audio_processor.preprocess(
            audio,
            sample_rate,
            normalize=normalize,
            trim_silence=trim_silence,
        )
        
        # Check audio duration
        duration = len(audio) / settings.SAMPLE_RATE
        if duration > settings.MAX_AUDIO_LENGTH:
            raise HTTPException(
                status_code=400,
                detail=f"Audio too long ({duration:.1f}s > {settings.MAX_AUDIO_LENGTH}s). "
                       f"Use /stream endpoint for longer audio.",
            )
        
        # Transcribe
        engine = get_engine()
        result = engine.transcribe(audio, language=language)
        
        # Add preprocessing time
        result["preprocessing_time"] = start_time - time.time() + result["total_time"]
        
        logger.info(f"✅ Transcription: '{result['text'][:50]}...'")
        
        return TranscribeResponse(**result)
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ Transcription error: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Transcription failed: {e}")

@app.post("/transcribe/base64", response_model=TranscribeResponse)
async def transcribe_base64(request: TranscribeRequest):
    """
    Transcribe audio from base64-encoded string
    
    Useful for Qt6 frontend to send audio data directly
    """
    try:
        # Decode base64 audio
        audio_bytes = base64.b64decode(request.audio_base64)
        audio_io = io.BytesIO(audio_bytes)
        
        # Load audio
        audio, sample_rate = sf.read(audio_io, dtype=np.float32)
        
        # Preprocess
        audio, sample_rate = audio_processor.preprocess(audio, sample_rate)
        
        # Transcribe
        engine = get_engine()
        result = engine.transcribe(audio, language=request.language)
        
        return TranscribeResponse(**result)
        
    except Exception as e:
        logger.error(f"❌ Base64 transcription error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.websocket("/stream")
async def websocket_stream(websocket: WebSocket):
    """
    WebSocket endpoint for real-time streaming transcription
    
    Client sends audio chunks, server responds with partial/final transcriptions
    """
    await websocket.accept()
    logger.info("🔌 WebSocket connection established")
    
    audio_buffer = []
    
    try:
        while True:
            # Receive audio chunk
            data = await websocket.receive_bytes()
            
            # Convert bytes to float32 array
            chunk = np.frombuffer(data, dtype=np.float32)
            audio_buffer.extend(chunk)
            
            # Process every 3 seconds of audio
            if len(audio_buffer) >= settings.SAMPLE_RATE * 3:
                audio = np.array(audio_buffer, dtype=np.float32)
                
                # Check for voice activity
                if audio_processor.detect_voice_activity(audio):
                    # Transcribe
                    engine = get_engine()
                    result = engine.transcribe(audio)
                    
                    # Send partial result
                    await websocket.send_json({
                        "type": "partial",
                        "text": result["text"],
                        "timestamp": time.time(),
                    })
                
                # Clear buffer
                audio_buffer.clear()
    
    except WebSocketDisconnect:
        logger.info("🔌 WebSocket disconnected")
    except Exception as e:
        logger.error(f"❌ WebSocket error: {e}")
        await websocket.close()

# Optional: Prometheus metrics
# from prometheus_fastapi_instrumentator import Instrumentator
# Instrumentator().instrument(app).expose(app)
```

---

### 🐳 Step 2.8: Pydantic Models

**`app/models.py`:**

```python
"""Pydantic models for request/response validation"""
from typing import Optional
from pydantic import BaseModel, Field

class TranscribeRequest(BaseModel):
    """Request model for base64 transcription"""
    audio_base64: str = Field(..., description="Base64-encoded audio data")
    language: str = Field(default="en", description="Language code")
    task: str = Field(default="transcribe", description="transcribe or translate")

class TranscribeResponse(BaseModel):
    """Response model for transcription"""
    text: str = Field(..., description="Transcribed text")
    language: str = Field(..., description="Detected/specified language")
    duration: float = Field(..., description="Audio duration in seconds")
    inference_time: float = Field(..., description="Inference time in seconds")
    total_time: float = Field(..., description="Total processing time")
    rtf: float = Field(..., description="Real-time factor")
    timestamp: float = Field(..., description="Unix timestamp")

class HealthResponse(BaseModel):
    """Health check response"""
    status: str = Field(..., description="Service status")
    model_loaded: bool = Field(..., description="Model initialization status")
    timestamp: float = Field(..., description="Unix timestamp")

class ModelInfoResponse(BaseModel):
    """Model information response"""
    model_name: str
    model_path: str
    sample_rate: int
    onnx_runtime_version: str
    num_threads: int
```

---

### 🐳 Step 2.9: Build and Test Docker Image

**Build for ARM64:**
```bash
cd audio_transcription_backend

# Build for Raspberry Pi 4 (ARM64)
docker buildx build \
    --platform linux/arm64 \
    -t ahmedferganey/whisper-onnx-backend:latest \
    --load \
    .

# Or use docker-compose
docker-compose build
```

**Test locally:**
```bash
# Run container
docker run -d \
    -p 8000:8000 \
    --name whisper-backend \
    ahmedferganey/whisper-onnx-backend:latest

# Check health
curl http://localhost:8000/health

# Test transcription
curl -X POST http://localhost:8000/transcribe \
    -F "audio_file=@test_audio.wav" \
    -F "language=en"

# View logs
docker logs -f whisper-backend
```

---

## 6. Phase 3: Frontend-Backend Integration

*See `WHISPER_ARCHITECTURE.md` for detailed integration diagrams*

### Integration points:
1. **REST API calls** from Qt6 C++ using QNetworkAccessManager
2. **WebSocket connection** for real-time streaming
3. **Audio capture** in Qt6 → send to backend
4. **Display transcription** in Qt6 GUI

*Full code examples in the architecture document*

---

## 7. Phase 4: Yocto Integration

### Step 4.1: Add Docker Recipe to meta-userapp

```bash
# Create recipe directory
mkdir -p AI_Voice_Assistant_using_Raspi4/Yocto/Yocto_sources/meta-userapp/recipes-docker/whisper-backend

# Create recipe file
cat > whisper-backend_1.0.bb <<'EOF'
DESCRIPTION = "Whisper ONNX transcription backend Docker container"
LICENSE = "MIT"

inherit docker

DOCKER_IMAGE_NAME = "ahmedferganey/whisper-onnx-backend"
DOCKER_IMAGE_TAG = "latest"

do_install() {
    # Docker image will be pulled at runtime
}
EOF
```

### Step 4.2: Update local.conf

```bash
# Add to IMAGE_INSTALL
IMAGE_INSTALL += " whisper-backend"
```

### Step 4.3: Rebuild Yocto image

```bash
bitbake core-image-base
```

---

## 8. Phase 5: Performance Optimization

### 5.1: INT8 Quantization (Further optimization)
- Reduce model size by 75%
- 2-3x faster inference
- Slight accuracy loss (~2-3%)

### 5.2: Model Caching
- Keep model in memory
- Avoid reloading

### 5.3: Batch Processing
- Process multiple audio files together

---

## 9. Phase 6: Testing & Deployment

### Test checklist:
- [ ] Unit tests for audio processing
- [ ] Integration tests for API
- [ ] Load testing (concurrent requests)
- [ ] Latency testing (RTF < 1.5x)
- [ ] Memory profiling (< 800MB)

---

## 10. Timeline & Milestones

| Week | Phase | Deliverables |
|------|-------|--------------|
| 1 | Model Conversion | ONNX models (Tiny, Base, Small) |
| 2 | Docker Backend | FastAPI + ONNX engine |
| 3 | Frontend Integration | Qt6 ↔ Backend communication |
| 4 | Yocto Integration | Docker recipe + system integration |
| 5 | Optimization | INT8 quantization, performance tuning |
| 6 | Testing | End-to-end testing, benchmarking |

---

## 11. Resources

### Hardware Requirements:
- Raspberry Pi 4 (4GB RAM minimum)
- 32GB microSD card (for Yocto image)
- USB microphone
- Development PC (for model conversion)

### Software Requirements:
- Yocto Kirkstone
- Docker CE 20.10+
- Python 3.10+
- ONNX Runtime 1.16+

---

## 12. Troubleshooting

See separate troubleshooting section in architecture document.

---

**End of Plan Document**

For architecture diagrams and system design, see: `WHISPER_ARCHITECTURE.md`

