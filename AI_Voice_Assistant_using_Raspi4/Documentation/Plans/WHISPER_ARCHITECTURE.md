# 🏗️ Whisper ONNX System Architecture
## Diagrams, Data Flow, and Technical Design

**Project**: AI Voice Assistant for Autonomous Vehicles  
**Version**: 1.0.0  
**Date**: October 26, 2025

---

## 📋 Table of Contents

1. [System Overview](#1-system-overview)
2. [Component Architecture](#2-component-architecture)
3. [Data Flow Diagrams](#3-data-flow-diagrams)
4. [Network Architecture](#4-network-architecture)
5. [Docker Container Architecture](#5-docker-container-architecture)
6. [Qt6 Frontend Architecture](#6-qt6-frontend-architecture)
7. [API Specifications](#7-api-specifications)
8. [Sequence Diagrams](#8-sequence-diagrams)
9. [Deployment Architecture](#9-deployment-architecture)
10. [Performance Architecture](#10-performance-architecture)

---

## 1. System Overview

### 1.1 High-Level Architecture

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                     RASPBERRY PI 4 - YOCTO LINUX SYSTEM                      │
│                                                                               │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                        USER SPACE                                    │    │
│  │                                                                       │    │
│  │  ┌──────────────────────┐         ┌─────────────────────────────┐  │    │
│  │  │   Qt6 GUI Frontend   │◄───────►│  Docker Container Backend   │  │    │
│  │  │  ┌────────────────┐  │   REST  │  ┌────────────────────────┐ │  │    │
│  │  │  │ Audio Capture  │  │   API   │  │   FastAPI Server       │ │  │    │
│  │  │  │ (QAudioInput)  │  │    +    │  │   (Port 8000)          │ │  │    │
│  │  │  └────────┬───────┘  │   WS    │  └──────────┬─────────────┘ │  │    │
│  │  │           │          │         │             │               │  │    │
│  │  │  ┌────────▼───────┐  │         │  ┌──────────▼─────────────┐ │  │    │
│  │  │  │ Visualization  │  │         │  │  Audio Processor      │ │  │    │
│  │  │  │ (Waveform)     │  │         │  │  - VAD                │ │  │    │
│  │  │  └────────────────┘  │         │  │  - Normalize          │ │  │    │
│  │  │                      │         │  │  - Resample           │ │  │    │
│  │  │  ┌────────────────┐  │         │  └──────────┬─────────────┘ │  │    │
│  │  │  │ Transcription  │◄─┼─────────┼─────────────┘               │  │    │
│  │  │  │ Display        │  │  JSON   │  ┌────────────────────────┐ │  │    │
│  │  │  └────────────────┘  │  Result │  │  ONNX Runtime Engine   │ │  │    │
│  │  │                      │         │  │  ┌──────────────────┐  │ │  │    │
│  │  │  ┌────────────────┐  │         │  │  │ Whisper Base     │  │ │  │    │
│  │  │  │ Settings Panel │  │         │  │  │ (74MB, FP16)     │  │ │  │    │
│  │  │  │ - Language     │  │         │  │  └──────────────────┘  │ │  │    │
│  │  │  │ - Model Select │  │         │  │  - ARM64 optimized     │ │  │    │
│  │  │  └────────────────┘  │         │  │  - 4 threads           │ │  │    │
│  │  └──────────────────────┘         │  └────────────────────────┘ │  │    │
│  │                                    │                             │  │    │
│  │                                    │  Storage:                   │  │    │
│  │                                    │  /models/whisper-base-onnx/ │  │    │
│  │                                    │  /cache/audio_buffers/      │  │    │
│  │                                    └─────────────────────────────┘  │    │
│  └───────────────────────────────────────────────────────────────────┘    │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │                        KERNEL SPACE                                  │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────────┐  │  │
│  │  │ ALSA Drivers │  │ Docker Engine│  │ Network Stack (TCP/IP)   │  │  │
│  │  │ (USB Audio)  │  │ (Containers) │  │ (localhost:8000)         │  │  │
│  │  └──────────────┘  └──────────────┘  └──────────────────────────┘  │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │                        HARDWARE                                      │  │
│  │  BCM2711 SoC | 4x Cortex-A72 | 4GB RAM | USB Audio | WiFi | BT     │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────────────────┘
```

### 1.2 Technology Stack

```
┌─────────────────────────────────────────────────────────────────────┐
│                         TECHNOLOGY STACK                            │
├───────────────────┬─────────────────────────────────────────────────┤
│ Frontend (Qt6)    │ - Qt 6.2 (C++)                                  │
│                   │ - QML (UI)                                      │
│                   │ - QAudioInput (Audio capture)                   │
│                   │ - QNetworkAccessManager (HTTP client)           │
│                   │ - QWebSocket (Real-time communication)          │
├───────────────────┼─────────────────────────────────────────────────┤
│ Backend           │ - Python 3.10                                   │
│ (Docker)          │ - FastAPI (Web framework)                       │
│                   │ - Uvicorn (ASGI server)                         │
│                   │ - ONNX Runtime 1.16 (Inference)                 │
│                   │ - Transformers (HuggingFace)                    │
│                   │ - Librosa (Audio processing)                    │
├───────────────────┼─────────────────────────────────────────────────┤
│ ML Model          │ - Whisper Base (74M parameters)                 │
│                   │ - ONNX format (FP16 quantized)                  │
│                   │ - ARM64 optimized                               │
│                   │ - 4-thread execution                            │
├───────────────────┼─────────────────────────────────────────────────┤
│ Operating System  │ - Yocto Linux (Kirkstone)                       │
│                   │ - Kernel 6.1.x                                  │
│                   │ - systemd init                                  │
│                   │ - Docker CE 20.10+                              │
├───────────────────┼─────────────────────────────────────────────────┤
│ Hardware          │ - Raspberry Pi 4 Model B (4GB)                  │
│                   │ - BCM2711 (Quad-core Cortex-A72 @ 1.5GHz)      │
│                   │ - USB Audio device                              │
│                   │ - 32GB microSD card                             │
└───────────────────┴─────────────────────────────────────────────────┘
```

---

## 2. Component Architecture

### 2.1 Layered Architecture

```
┌────────────────────────────────────────────────────────────────────┐
│                        PRESENTATION LAYER                          │
│  ┌──────────────────────────────────────────────────────────────┐ │
│  │              Qt6 QML User Interface                          │ │
│  │  - MainWindow.qml                                            │ │
│  │  - TranscriptionView.qml                                     │ │
│  │  - WaveformVisualization.qml                                 │ │
│  │  - SettingsPanel.qml                                         │ │
│  └──────────────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────────────────┘
                              ▲ │
                              │ │ Qt Signals/Slots
                              │ ▼
┌────────────────────────────────────────────────────────────────────┐
│                        APPLICATION LAYER                           │
│  ┌──────────────────────────────────────────────────────────────┐ │
│  │              Qt6 C++ Business Logic                          │ │
│  │  - AudioEngine (QAudioInput integration)                     │ │
│  │  - TranscriptionModel (Data management)                      │ │
│  │  - NetworkManager (API client)                               │ │
│  │  - SettingsManager (Configuration)                           │ │
│  └──────────────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────────────────┘
                              ▲ │
                              │ │ REST API / WebSocket
                              │ ▼
┌────────────────────────────────────────────────────────────────────┐
│                        SERVICE LAYER (Docker)                      │
│  ┌──────────────────────────────────────────────────────────────┐ │
│  │              FastAPI Web Service                             │ │
│  │  - /transcribe (POST) - File-based transcription             │ │
│  │  - /transcribe/base64 (POST) - Base64 transcription          │ │
│  │  - /stream (WebSocket) - Real-time streaming                 │ │
│  │  - /health (GET) - Health check                              │ │
│  │  - /model/info (GET) - Model information                     │ │
│  └──────────────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────────────────┘
                              ▲ │
                              │ │ Python function calls
                              │ ▼
┌────────────────────────────────────────────────────────────────────┐
│                        PROCESSING LAYER                            │
│  ┌──────────────────────────────────────────────────────────────┐ │
│  │              Audio Processing Pipeline                       │ │
│  │  - AudioProcessor                                            │ │
│  │    • Resampling (to 16kHz)                                   │ │
│  │    • Normalization                                           │ │
│  │    • Stereo → Mono conversion                                │ │
│  │    • Silence trimming                                        │ │
│  │    • Voice Activity Detection (VAD)                          │ │
│  └──────────────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────────────────┘
                              ▲ │
                              │ │ NumPy arrays
                              │ ▼
┌────────────────────────────────────────────────────────────────────┐
│                        INFERENCE LAYER                             │
│  ┌──────────────────────────────────────────────────────────────┐ │
│  │              ONNX Runtime Engine                             │ │
│  │  - WhisperONNXEngine                                         │ │
│  │  - ORTModelForSpeechSeq2Seq                                  │ │
│  │  - CPUExecutionProvider (ARM64)                              │ │
│  │  - 4-thread parallel execution                               │ │
│  └──────────────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────────────────┘
                              ▲ │
                              │ │ ONNX tensors
                              │ ▼
┌────────────────────────────────────────────────────────────────────┐
│                        MODEL LAYER                                 │
│  ┌──────────────────────────────────────────────────────────────┐ │
│  │              Whisper ONNX Models                             │ │
│  │  - encoder_model.onnx (Speech → Features)                    │ │
│  │  - decoder_model.onnx (Features → Text)                      │ │
│  │  - Tokenizer & Feature Extractor                             │ │
│  │  - FP16 quantized (74MB)                                     │ │
│  └──────────────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────────────────┘
```

---

## 3. Data Flow Diagrams

### 3.1 Audio Transcription Flow (File Upload)

```
┌──────────┐
│  User    │
│  (Qt6)   │
└────┬─────┘
     │
     │ 1. Click "Transcribe" button
     │
     ▼
┌─────────────────────┐
│  Qt6 AudioEngine    │
│  - Capture audio    │
│  - Save to WAV file │
└─────────┬───────────┘
          │
          │ 2. Read WAV file → QByteArray
          │
          ▼
┌──────────────────────────┐
│  Qt6 NetworkManager      │
│  - QNetworkAccessManager │
│  - Create multipart POST │
└──────────┬───────────────┘
           │
           │ 3. HTTP POST /transcribe
           │    Content-Type: multipart/form-data
           │    Body: audio_file=<wav_data>
           │
           ▼
     ┌──────────────────────┐
     │  FastAPI Server      │
     │  (Docker Container)  │
     └──────┬───────────────┘
            │
            │ 4. Parse multipart request
            │
            ▼
     ┌────────────────────────┐
     │  AudioProcessor        │
     │  - Read audio bytes    │
     │  - Convert to numpy    │
     └──────┬─────────────────┘
            │
            │ 5. Preprocess audio
            │    - Resample to 16kHz
            │    - Stereo → Mono
            │    - Normalize
            │    - Trim silence
            │
            ▼
     ┌──────────────────────────────┐
     │  WhisperONNXEngine           │
     │  - Load processor            │
     │  - Extract audio features    │
     └──────┬───────────────────────┘
            │
            │ 6. Convert to Mel spectrogram
            │    Shape: (80, N_frames)
            │
            ▼
     ┌─────────────────────────────┐
     │  ONNX Encoder               │
     │  - encoder_model.onnx       │
     │  - Input: Mel spectrogram   │
     │  - Output: Hidden states    │
     └──────┬──────────────────────┘
            │
            │ 7. Audio → Latent representation
            │    Shape: (1, N_frames, 512)
            │
            ▼
     ┌─────────────────────────────┐
     │  ONNX Decoder               │
     │  - decoder_model.onnx       │
     │  - Autoregressive decoding  │
     │  - Generate token IDs       │
     └──────┬──────────────────────┘
            │
            │ 8. Token generation loop
            │    Until <|endoftext|> or max_length
            │
            ▼
     ┌────────────────────────────┐
     │  Tokenizer (Decode)        │
     │  - Token IDs → Text        │
     │  - Remove special tokens   │
     └──────┬─────────────────────┘
            │
            │ 9. Transcribed text: "Hello world"
            │
            ▼
     ┌──────────────────────────────────┐
     │  FastAPI Response                │
     │  {                               │
     │    "text": "Hello world",        │
     │    "duration": 5.2,              │
     │    "inference_time": 2.1,        │
     │    "rtf": 0.40                   │
     │  }                               │
     └──────┬───────────────────────────┘
            │
            │ 10. HTTP 200 OK
            │     Content-Type: application/json
            │
            ▼
     ┌──────────────────────┐
     │  Qt6 NetworkManager  │
     │  - Parse JSON        │
     │  - Emit signal       │
     └──────┬───────────────┘
            │
            │ 11. transcriptionReceived(text)
            │
            ▼
     ┌─────────────────────────┐
     │  Qt6 TranscriptionModel │
     │  - Update model data    │
     │  - Notify QML view      │
     └──────┬──────────────────┘
            │
            │ 12. dataChanged() signal
            │
            ▼
     ┌──────────────────────┐
     │  QML View            │
     │  - Update UI         │
     │  - Display text      │
     └──────────────────────┘
```

### 3.2 Real-Time Streaming Flow (WebSocket)

```
┌──────────┐                    ┌─────────────────┐
│  Qt6 GUI │                    │ Docker Backend  │
└────┬─────┘                    └────┬────────────┘
     │                               │
     │ 1. Connect WebSocket          │
     │ ws://localhost:8000/stream    │
     ├──────────────────────────────►│
     │                               │
     │ 2. Connection accepted         │
     │◄──────────────────────────────┤
     │                               │
     │                               │
     ├─── Audio Capture Loop ────────┤
     │                               │
     │ 3. Capture 100ms audio chunk  │
     │    (QAudioInput)              │
     │                               │
     │ 4. Send audio bytes           │
     │    (binary WebSocket frame)   │
     ├──────────────────────────────►│
     │                               │
     │                               │ 5. Buffer audio
     │                               │    (3 seconds)
     │                               │
     │ 6. Send more chunks...        │
     ├──────────────────────────────►│
     │                               │
     │                               │ 7. Buffer full (3s)
     │                               │    Run VAD
     │                               │
     │                               │ 8. Voice detected
     │                               │    Preprocess audio
     │                               │
     │                               │ 9. ONNX inference
     │                               │    (Whisper Base)
     │                               │
     │ 10. Receive partial result    │
     │     { "type": "partial",      │
     │       "text": "Hello..." }    │
     │◄──────────────────────────────┤
     │                               │
     │ 11. Update UI (partial)       │
     │                               │
     │                               │
     │ 12. Continue streaming...     │
     ├──────────────────────────────►│
     │                               │
     │                               │ 13. Silence detected
     │                               │     Send final result
     │                               │
     │ 14. Receive final result      │
     │     { "type": "final",        │
     │       "text": "Hello world" } │
     │◄──────────────────────────────┤
     │                               │
     │ 15. Update UI (final)         │
     │                               │
     │                               │
     │ 16. User stops recording      │
     │     Close WebSocket           │
     ├──────────────────────────────►│
     │                               │
     │ 17. Connection closed         │
     │◄──────────────────────────────┤
     │                               │
```

---

## 4. Network Architecture

### 4.1 Network Topology

```
┌───────────────────────────────────────────────────────────────────┐
│                  RASPBERRY PI 4 - HOST SYSTEM                     │
│                                                                    │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │                  USER SPACE PROCESSES                       │  │
│  │                                                              │  │
│  │  ┌─────────────────────┐         ┌──────────────────────┐  │  │
│  │  │  Qt6 Application    │         │  Docker Container    │  │  │
│  │  │  Process ID: 1234   │         │  (whisper-backend)   │  │  │
│  │  │                     │         │  Container ID: abc123│  │  │
│  │  │  Network: Host      │         │                      │  │  │
│  │  │  Interface: lo      │         │  Network: bridge     │  │  │
│  │  │                     │         │  Interface: eth0     │  │  │
│  │  │  Client:            │         │  (172.17.0.2)        │  │  │
│  │  │  - HTTP client      │         │                      │  │  │
│  │  │  - WebSocket client │         │  Server:             │  │  │
│  │  └──────────┬──────────┘         │  - FastAPI:8000      │  │  │
│  │             │                     │  - Uvicorn ASGI      │  │  │
│  │             │                     └──────────▲───────────┘  │  │
│  │             │                                │               │  │
│  │             │                                │               │  │
│  └─────────────┼────────────────────────────────┼───────────────┘  │
│                │                                │                  │
│  ┌─────────────▼────────────────────────────────▼───────────────┐ │
│  │              KERNEL NETWORK STACK                            │ │
│  │                                                               │ │
│  │  ┌─────────────────────┐         ┌──────────────────────┐   │ │
│  │  │  Loopback (lo)      │         │  Docker Bridge       │   │ │
│  │  │  127.0.0.1          │         │  docker0             │   │ │
│  │  │  localhost          │         │  172.17.0.1          │   │ │
│  │  └──────────┬──────────┘         └──────────┬───────────┘   │ │
│  │             │                               │                │ │
│  │             └───────────┬───────────────────┘                │ │
│  │                         │                                    │ │
│  │              ┌──────────▼──────────┐                         │ │
│  │              │  NAT / Routing      │                         │ │
│  │              │  Port Forward       │                         │ │
│  │              │  8000 → 172.17.0.2  │                         │ │
│  │              └─────────────────────┘                         │ │
│  └───────────────────────────────────────────────────────────────┘ │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘

Communication Flow:
1. Qt6 → HTTP GET http://localhost:8000/health
2. Kernel → Route to docker0 bridge (172.17.0.1)
3. Docker → Forward to container (172.17.0.2:8000)
4. FastAPI → Process request
5. FastAPI → HTTP 200 OK response
6. Docker → Forward response back
7. Kernel → Route to loopback (127.0.0.1)
8. Qt6 → Receive response
```

### 4.2 Port Mapping

```
┌─────────────────────────────────────────────────────────┐
│              PORT ALLOCATION                            │
├──────────┬──────────────┬──────────────────────────────┤
│ Port     │ Protocol     │ Service                      │
├──────────┼──────────────┼──────────────────────────────┤
│ 8000     │ HTTP         │ FastAPI REST API             │
│ 8000     │ WebSocket    │ Real-time audio streaming    │
│ 22       │ SSH          │ Remote access (optional)     │
│ 5000     │ VNC          │ Remote desktop (optional)    │
└──────────┴──────────────┴──────────────────────────────┘

Docker Run Command:
docker run -d \
    -p 8000:8000 \
    --name whisper-backend \
    --restart unless-stopped \
    ahmedferganey/whisper-onnx-backend:latest
```

---

## 5. Docker Container Architecture

### 5.1 Container Layers

```
┌────────────────────────────────────────────────────────────────┐
│  Docker Image: ahmedferganey/whisper-onnx-backend:latest      │
├────────────────────────────────────────────────────────────────┤
│  Layer 7: Application Layer (50MB)                             │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │  /app/                                                    │ │
│  │  ├── app/                                                 │ │
│  │  │   ├── main.py (FastAPI app)                           │ │
│  │  │   ├── whisper_engine.py (ONNX inference)              │ │
│  │  │   ├── audio_processor.py (preprocessing)              │ │
│  │  │   ├── models.py (Pydantic models)                     │ │
│  │  │   └── config.py (settings)                            │ │
│  │  ├── models/                                              │ │
│  │  │   └── whisper-base-onnx/ (74MB)                       │ │
│  │  │       ├── encoder_model.onnx                          │ │
│  │  │       ├── decoder_model.onnx                          │ │
│  │  │       ├── config.json                                 │ │
│  │  │       └── tokenizer/                                  │ │
│  │  └── cache/ (runtime)                                    │ │
│  └──────────────────────────────────────────────────────────┘ │
├────────────────────────────────────────────────────────────────┤
│  Layer 6: Python Dependencies (400MB)                          │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │  /opt/venv/lib/python3.10/site-packages/                │ │
│  │  ├── fastapi/                                            │ │
│  │  ├── uvicorn/                                            │ │
│  │  ├── onnxruntime/ (ARM64 optimized)                      │ │
│  │  ├── transformers/                                       │ │
│  │  ├── optimum/                                            │ │
│  │  ├── numpy/                                              │ │
│  │  ├── librosa/                                            │ │
│  │  └── ... (other dependencies)                            │ │
│  └──────────────────────────────────────────────────────────┘ │
├────────────────────────────────────────────────────────────────┤
│  Layer 5: Build Dependencies (REMOVED in final image)         │
│  (build-essential, cmake, git) - Multi-stage build            │
├────────────────────────────────────────────────────────────────┤
│  Layer 4: Runtime System Libraries (50MB)                      │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │  /usr/lib/                                               │ │
│  │  ├── libsndfile.so (Audio I/O)                           │ │
│  │  ├── libgomp.so (OpenMP for threading)                   │ │
│  │  ├── libasound.so (ALSA)                                 │ │
│  │  └── ... (other system libraries)                        │ │
│  └──────────────────────────────────────────────────────────┘ │
├────────────────────────────────────────────────────────────────┤
│  Layer 3: Python 3.10 Runtime (100MB)                          │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │  /usr/local/bin/python3.10                               │ │
│  │  /usr/local/lib/python3.10/                              │ │
│  └──────────────────────────────────────────────────────────┘ │
├────────────────────────────────────────────────────────────────┤
│  Layer 2: Debian Base Packages (200MB)                         │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │  Essential system utilities                              │ │
│  │  /bin/, /usr/bin/, /lib/, /usr/lib/                      │ │
│  └──────────────────────────────────────────────────────────┘ │
├────────────────────────────────────────────────────────────────┤
│  Layer 1: Base Image - arm64v8/python:3.10-slim-bullseye      │
│  (Debian 11 Bullseye - ARM64)                                  │
└────────────────────────────────────────────────────────────────┘

Total Image Size: ~900MB (compressed: ~350MB)
Runtime Memory Usage: 400-600MB (with Whisper Base loaded)
```

### 5.2 Container Runtime Environment

```
┌─────────────────────────────────────────────────────────────┐
│  Container: whisper-backend                                 │
├─────────────────────────────────────────────────────────────┤
│  Environment Variables:                                     │
│  ┌───────────────────────────────────────────────────────┐ │
│  │  PATH=/opt/venv/bin:/usr/local/bin:/usr/bin:/bin     │ │
│  │  PYTHONPATH=/app                                      │ │
│  │  MODEL_NAME=whisper-base-onnx                         │ │
│  │  MODELS_DIR=/app/models                               │ │
│  │  CACHE_DIR=/app/cache                                 │ │
│  │  ONNX_NUM_THREADS=4                                   │ │
│  │  LOG_LEVEL=INFO                                       │ │
│  └───────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│  Exposed Ports:                                             │
│  ┌───────────────────────────────────────────────────────┐ │
│  │  8000/tcp → FastAPI HTTP + WebSocket                  │ │
│  └───────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│  Volumes (Optional):                                        │
│  ┌───────────────────────────────────────────────────────┐ │
│  │  /app/models → Host:/home/ferganey/models (ro)        │ │
│  │  /app/cache → Host:/var/cache/whisper (rw)            │ │
│  └───────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│  Health Check:                                              │
│  ┌───────────────────────────────────────────────────────┐ │
│  │  Interval: 30s                                        │ │
│  │  Timeout: 10s                                         │ │
│  │  Retries: 3                                           │ │
│  │  Command: curl http://localhost:8000/health          │ │
│  └───────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│  Resource Limits:                                           │
│  ┌───────────────────────────────────────────────────────┐ │
│  │  Memory: 1GB (soft), 2GB (hard)                       │ │
│  │  CPU: 4 cores (all available on RPi4)                 │ │
│  │  Restart Policy: unless-stopped                       │ │
│  └───────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘

Start Command:
CMD ["uvicorn", "app.main:app", 
     "--host", "0.0.0.0", 
     "--port", "8000", 
     "--workers", "1",
     "--log-level", "info"]
```

---

## 6. Qt6 Frontend Architecture

### 6.1 Qt6 Component Diagram

```
┌────────────────────────────────────────────────────────────────────┐
│                     Qt6 Voice Assistant Application                │
├────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐ │
│  │                    QML Layer (View)                          │ │
│  │  ┌────────────────────────────────────────────────────────┐ │ │
│  │  │  MainWindow.qml                                        │ │ │
│  │  │  ┌─────────────────────────────────────────────────┐  │ │ │
│  │  │  │  TranscriptionView.qml                          │  │ │ │
│  │  │  │  - Display transcribed text                     │  │ │ │
│  │  │  │  - History list                                 │  │ │ │
│  │  │  └─────────────────────────────────────────────────┘  │ │ │
│  │  │  ┌─────────────────────────────────────────────────┐  │ │ │
│  │  │  │  WaveformVisualization.qml                      │  │ │ │
│  │  │  │  - Real-time audio waveform                     │  │ │ │
│  │  │  │  - Volume meter                                 │  │ │ │
│  │  │  └─────────────────────────────────────────────────┘  │ │ │
│  │  │  ┌─────────────────────────────────────────────────┐  │ │ │
│  │  │  │  MicrophoneButton.qml                           │  │ │ │
│  │  │  │  - Start/Stop recording                         │  │ │ │
│  │  │  │  - Visual feedback                              │  │ │ │
│  │  │  └─────────────────────────────────────────────────┘  │ │ │
│  │  │  ┌─────────────────────────────────────────────────┐  │ │ │
│  │  │  │  SettingsPanel.qml                              │  │ │ │
│  │  │  │  - Language selection                           │  │ │ │
│  │  │  │  - Model selection (Tiny/Base/Small)            │  │ │ │
│  │  │  │  - Backend URL configuration                    │  │ │ │
│  │  │  └─────────────────────────────────────────────────┘  │ │ │
│  │  └────────────────────────────────────────────────────────┘ │ │
│  └──────────────────────────────────────────────────────────────┘ │
│                              ▲ │                                   │
│                              │ │ Qt Properties / Signals           │
│                              │ ▼                                   │
│  ┌──────────────────────────────────────────────────────────────┐ │
│  │                    C++ Layer (Controller/Model)              │ │
│  │                                                               │ │
│  │  ┌────────────────────────────────────────────────────────┐ │ │
│  │  │  AudioEngine (QObject)                                 │ │ │
│  │  │  ┌──────────────────────────────────────────────────┐ │ │ │
│  │  │  │  QAudioInput (Audio capture)                     │ │ │ │
│  │  │  │  QIODevice (Audio buffer)                        │ │ │ │
│  │  │  │  - captureAudio()                                │ │ │ │
│  │  │  │  - stopCapture()                                 │ │ │ │
│  │  │  │  Signal: audioDataReady(QByteArray)              │ │ │ │
│  │  │  └──────────────────────────────────────────────────┘ │ │ │
│  │  └────────────────────────────────────────────────────────┘ │ │
│  │                                                               │ │
│  │  ┌────────────────────────────────────────────────────────┐ │ │
│  │  │  TranscriptionModel (QAbstractListModel)               │ │ │
│  │  │  - QList<TranscriptionItem> m_transcriptions          │ │ │ │
│  │  │  - addTranscription(QString text, QDateTime time)     │ │ │ │
│  │  │  - clearHistory()                                      │ │ │ │
│  │  │  Signal: transcriptionAdded(QString text)             │ │ │ │
│  │  └────────────────────────────────────────────────────────┘ │ │
│  │                                                               │ │
│  │  ┌────────────────────────────────────────────────────────┐ │ │
│  │  │  NetworkManager (QObject)                              │ │ │
│  │  │  ┌──────────────────────────────────────────────────┐ │ │ │
│  │  │  │  QNetworkAccessManager (HTTP client)             │ │ │ │
│  │  │  │  - transcribeFile(QString filePath)              │ │ │ │
│  │  │  │  - transcribeBase64(QByteArray audio)            │ │ │ │
│  │  │  │  - checkHealth()                                 │ │ │ │
│  │  │  │  Signal: transcriptionReceived(QString text)     │ │ │ │
│  │  │  │  Signal: errorOccurred(QString error)            │ │ │ │
│  │  │  └──────────────────────────────────────────────────┘ │ │ │
│  │  │  ┌──────────────────────────────────────────────────┐ │ │ │
│  │  │  │  QWebSocket (WebSocket client)                   │ │ │ │
│  │  │  │  - connectToBackend()                            │ │ │ │
│  │  │  │  - sendAudioChunk(QByteArray chunk)              │ │ │ │
│  │  │  │  - disconnect()                                  │ │ │ │
│  │  │  │  Signal: partialTranscription(QString text)      │ │ │ │
│  │  │  │  Signal: finalTranscription(QString text)        │ │ │ │
│  │  │  └──────────────────────────────────────────────────┘ │ │ │
│  │  └────────────────────────────────────────────────────────┘ │ │
│  │                                                               │ │
│  │  ┌────────────────────────────────────────────────────────┐ │ │
│  │  │  SettingsManager (QObject)                             │ │ │
│  │  │  - QSettings m_settings                                │ │ │ │
│  │  │  - QString backendUrl()                                │ │ │ │
│  │  │  - QString language()                                  │ │ │ │
│  │  │  - QString modelName()                                 │ │ │ │
│  │  │  - setBackendUrl(QString url)                          │ │ │ │
│  │  │  Signal: settingsChanged()                             │ │ │ │
│  │  └────────────────────────────────────────────────────────┘ │ │
│  └──────────────────────────────────────────────────────────────┘ │
│                              ▲ │                                   │
│                              │ │ Qt Network API                    │
│                              │ ▼                                   │
│  ┌──────────────────────────────────────────────────────────────┐ │
│  │                    Qt Network Layer                          │ │
│  │  - QNetworkRequest (HTTP requests)                           │ │
│  │  - QNetworkReply (HTTP responses)                            │ │
│  │  - QWebSocket (WebSocket connection)                         │ │
│  └──────────────────────────────────────────────────────────────┘ │
│                              ▲ │                                   │
│                              │ │ TCP/IP                            │
│                              │ ▼                                   │
│  ┌──────────────────────────────────────────────────────────────┐ │
│  │                    Qt Core (Event Loop)                      │ │
│  │  - QCoreApplication event loop                               │ │
│  │  - Signal/Slot mechanism                                     │ │
│  │  - Thread management                                         │ │
│  └──────────────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────────────────┘
```

### 6.2 Qt6 C++ Code Example (NetworkManager)

```cpp
// networkmanager.h
#ifndef NETWORKMANAGER_H
#define NETWORKMANAGER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QWebSocket>
#include <QByteArray>

class NetworkManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString backendUrl READ backendUrl WRITE setBackendUrl NOTIFY backendUrlChanged)
    Q_PROPERTY(bool isConnected READ isConnected NOTIFY isConnectedChanged)

public:
    explicit NetworkManager(QObject *parent = nullptr);
    ~NetworkManager();

    QString backendUrl() const { return m_backendUrl; }
    void setBackendUrl(const QString &url);
    bool isConnected() const { return m_isConnected; }

public slots:
    // REST API methods
    void transcribeFile(const QString &filePath, const QString &language = "en");
    void transcribeBase64(const QByteArray &audioData, const QString &language = "en");
    void checkHealth();
    void getModelInfo();

    // WebSocket methods
    void connectWebSocket();
    void disconnectWebSocket();
    void sendAudioChunk(const QByteArray &chunk);

signals:
    // REST API signals
    void transcriptionReceived(const QString &text, double duration, double inferenceTime);
    void healthCheckResult(bool healthy);
    void errorOccurred(const QString &error);
    void backendUrlChanged();
    void isConnectedChanged();

    // WebSocket signals
    void partialTranscription(const QString &text);
    void finalTranscription(const QString &text);
    void webSocketConnected();
    void webSocketDisconnected();

private slots:
    void handleTranscribeReply();
    void handleHealthReply();
    void onWebSocketConnected();
    void onWebSocketDisconnected();
    void onWebSocketTextMessageReceived(const QString &message);
    void onWebSocketError(QAbstractSocket::SocketError error);

private:
    QNetworkAccessManager *m_networkManager;
    QWebSocket *m_webSocket;
    QString m_backendUrl;
    bool m_isConnected;
};

#endif // NETWORKMANAGER_H
```

```cpp
// networkmanager.cpp
#include "networkmanager.h"
#include <QNetworkRequest>
#include <QHttpMultiPart>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QDebug>

NetworkManager::NetworkManager(QObject *parent)
    : QObject(parent)
    , m_networkManager(new QNetworkAccessManager(this))
    , m_webSocket(new QWebSocket(QString(), QWebSocketProtocol::VersionLatest, this))
    , m_backendUrl("http://localhost:8000")
    , m_isConnected(false)
{
    // Connect WebSocket signals
    connect(m_webSocket, &QWebSocket::connected, 
            this, &NetworkManager::onWebSocketConnected);
    connect(m_webSocket, &QWebSocket::disconnected, 
            this, &NetworkManager::onWebSocketDisconnected);
    connect(m_webSocket, &QWebSocket::textMessageReceived, 
            this, &NetworkManager::onWebSocketTextMessageReceived);
    connect(m_webSocket, QOverload<QAbstractSocket::SocketError>::of(&QWebSocket::error),
            this, &NetworkManager::onWebSocketError);
}

NetworkManager::~NetworkManager()
{
    if (m_webSocket->state() == QAbstractSocket::ConnectedState) {
        m_webSocket->close();
    }
}

void NetworkManager::setBackendUrl(const QString &url)
{
    if (m_backendUrl != url) {
        m_backendUrl = url;
        emit backendUrlChanged();
    }
}

void NetworkManager::transcribeFile(const QString &filePath, const QString &language)
{
    QFile *file = new QFile(filePath);
    if (!file->open(QIODevice::ReadOnly)) {
        emit errorOccurred("Failed to open audio file: " + filePath);
        delete file;
        return;
    }

    // Create multipart request
    QHttpMultiPart *multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);

    // Add audio file part
    QHttpPart audioPart;
    audioPart.setHeader(QNetworkRequest::ContentTypeHeader, QVariant("audio/wav"));
    audioPart.setHeader(QNetworkRequest::ContentDispositionHeader, 
                        QVariant("form-data; name=\"audio_file\"; filename=\"audio.wav\""));
    audioPart.setBodyDevice(file);
    file->setParent(multiPart); // File will be deleted with multiPart
    multiPart->append(audioPart);

    // Add language part
    QHttpPart languagePart;
    languagePart.setHeader(QNetworkRequest::ContentDispositionHeader, 
                           QVariant("form-data; name=\"language\""));
    languagePart.setBody(language.toUtf8());
    multiPart->append(languagePart);

    // Create request
    QNetworkRequest request(QUrl(m_backendUrl + "/transcribe"));
    QNetworkReply *reply = m_networkManager->post(request, multiPart);
    multiPart->setParent(reply); // multiPart will be deleted with reply

    // Connect reply signal
    connect(reply, &QNetworkReply::finished, this, &NetworkManager::handleTranscribeReply);
}

void NetworkManager::handleTranscribeReply()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) return;

    if (reply->error() == QNetworkReply::NoError) {
        QByteArray response = reply->readAll();
        QJsonDocument jsonDoc = QJsonDocument::fromJson(response);
        QJsonObject jsonObj = jsonDoc.object();

        QString text = jsonObj["text"].toString();
        double duration = jsonObj["duration"].toDouble();
        double inferenceTime = jsonObj["inference_time"].toDouble();

        emit transcriptionReceived(text, duration, inferenceTime);
    } else {
        emit errorOccurred("Transcription failed: " + reply->errorString());
    }

    reply->deleteLater();
}

void NetworkManager::connectWebSocket()
{
    QString wsUrl = m_backendUrl;
    wsUrl.replace("http://", "ws://").replace("https://", "wss://");
    m_webSocket->open(QUrl(wsUrl + "/stream"));
}

void NetworkManager::sendAudioChunk(const QByteArray &chunk)
{
    if (m_webSocket->state() == QAbstractSocket::ConnectedState) {
        m_webSocket->sendBinaryMessage(chunk);
    }
}

void NetworkManager::onWebSocketTextMessageReceived(const QString &message)
{
    QJsonDocument jsonDoc = QJsonDocument::fromJson(message.toUtf8());
    QJsonObject jsonObj = jsonDoc.object();

    QString type = jsonObj["type"].toString();
    QString text = jsonObj["text"].toString();

    if (type == "partial") {
        emit partialTranscription(text);
    } else if (type == "final") {
        emit finalTranscription(text);
    }
}
```

---

## 7. API Specifications

### 7.1 REST API Endpoints

```
┌─────────────────────────────────────────────────────────────────────┐
│  BASE URL: http://localhost:8000                                    │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Endpoint: GET /                                                     │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │  Description: Root endpoint (service info)                    │ │
│  │  Response: 200 OK                                             │ │
│  │  {                                                             │ │
│  │    "name": "Whisper ONNX Transcription Backend",             │ │
│  │    "version": "1.0.0",                                        │ │
│  │    "status": "running"                                        │ │
│  │  }                                                             │ │
│  └───────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  Endpoint: GET /health                                               │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │  Description: Health check (liveness probe)                   │ │
│  │  Response: 200 OK                                             │ │
│  │  {                                                             │ │
│  │    "status": "healthy",                                       │ │
│  │    "model_loaded": true,                                      │ │
│  │    "timestamp": 1698345600.123                                │ │
│  │  }                                                             │ │
│  │  Response: 503 Service Unavailable (if unhealthy)             │ │
│  └───────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  Endpoint: GET /model/info                                           │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │  Description: Get model information                           │ │
│  │  Response: 200 OK                                             │ │
│  │  {                                                             │ │
│  │    "model_name": "whisper-base-onnx",                         │ │
│  │    "model_path": "/app/models/whisper-base-onnx",            │ │
│  │    "sample_rate": 16000,                                      │ │
│  │    "onnx_runtime_version": "1.16.3",                          │ │
│  │    "num_threads": 4                                           │ │
│  │  }                                                             │ │
│  └───────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  Endpoint: POST /transcribe                                          │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │  Description: Transcribe audio file (multipart upload)        │ │
│  │  Content-Type: multipart/form-data                            │ │
│  │  Request:                                                      │ │
│  │    audio_file: <binary> (WAV/MP3/FLAC)                        │ │
│  │    language: "en" (optional, default: "en")                   │ │
│  │    normalize: true (optional, default: true)                  │ │
│  │    trim_silence: true (optional, default: true)               │ │
│  │                                                                │ │
│  │  Response: 200 OK                                             │ │
│  │  {                                                             │ │
│  │    "text": "Hello world, this is a test.",                    │ │
│  │    "language": "en",                                          │ │
│  │    "duration": 5.2,                                           │ │
│  │    "inference_time": 2.1,                                     │ │
│  │    "total_time": 2.3,                                         │ │
│  │    "rtf": 0.40,                                               │ │
│  │    "timestamp": 1698345600.456                                │ │
│  │  }                                                             │ │
│  │                                                                │ │
│  │  Error: 400 Bad Request (audio too long)                      │ │
│  │  Error: 500 Internal Server Error (transcription failed)      │ │
│  └───────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  Endpoint: POST /transcribe/base64                                   │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │  Description: Transcribe base64-encoded audio                 │ │
│  │  Content-Type: application/json                               │ │
│  │  Request:                                                      │ │
│  │  {                                                             │ │
│  │    "audio_base64": "UklGRi4AAABXQVZFZm10IBAA...",            │ │
│  │    "language": "en",                                          │ │
│  │    "task": "transcribe"                                       │ │
│  │  }                                                             │ │
│  │                                                                │ │
│  │  Response: Same as /transcribe                                │ │
│  └───────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  Endpoint: WebSocket /stream                                         │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │  Description: Real-time audio streaming transcription         │ │
│  │  Protocol: WebSocket                                          │ │
│  │                                                                │ │
│  │  Client → Server:                                             │ │
│  │    Binary frames: Float32 audio chunks (16kHz, mono)          │ │
│  │                                                                │ │
│  │  Server → Client:                                             │ │
│  │    JSON text frames:                                          │ │
│  │    {                                                           │ │
│  │      "type": "partial",                                       │ │
│  │      "text": "Hello...",                                      │ │
│  │      "timestamp": 1698345600.789                              │ │
│  │    }                                                           │ │
│  │    {                                                           │ │
│  │      "type": "final",                                         │ │
│  │      "text": "Hello world",                                   │ │
│  │      "timestamp": 1698345602.123                              │ │
│  │    }                                                           │ │
│  └───────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 8. Sequence Diagrams

### 8.1 Application Startup Sequence

```
User          Qt6 App       NetworkMgr    Docker Container    ONNX Engine
 │               │               │               │                 │
 │  Launch       │               │               │                 │
 │──────────────>│               │               │                 │
 │               │               │               │                 │
 │               │ Initialize    │               │                 │
 │               │ components    │               │                 │
 │               │──────────────>│               │                 │
 │               │               │               │                 │
 │               │               │ Check health  │                 │
 │               │               │──────────────>│                 │
 │               │               │               │                 │
 │               │               │               │ Load model      │
 │               │               │               │────────────────>│
 │               │               │               │                 │
 │               │               │               │ Model loaded    │
 │               │               │               │<────────────────│
 │               │               │               │                 │
 │               │               │ Health OK     │                 │
 │               │               │<──────────────│                 │
 │               │               │               │                 │
 │               │ Backend ready │               │                 │
 │               │<──────────────│               │                 │
 │               │               │               │                 │
 │  GUI ready    │               │               │                 │
 │<──────────────│               │               │                 │
```

---

## 9. Deployment Architecture

### 9.1 Yocto System Integration

```
┌─────────────────────────────────────────────────────────────────┐
│                   YOCTO IMAGE DEPLOYMENT                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Build Time (Yocto Build System)                                │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  bitbake core-image-base                                   │ │
│  │  ├── meta/recipes-core/images/core-image-base.bb           │ │
│  │  ├── meta-raspberrypi (BSP Layer)                          │ │
│  │  ├── meta-qt6 (Qt6 framework)                              │ │
│  │  ├── meta-docker (Docker CE)                               │ │
│  │  ├── meta-onnxruntime (ONNX Runtime - optional)            │ │
│  │  └── meta-userapp                                          │ │
│  │      ├── qt6-voice-assistant (Qt6 GUI)                     │ │
│  │      └── whisper-backend (Docker image)                    │ │
│  └────────────────────────────────────────────────────────────┘ │
│                           │                                     │
│                           │ bitbake output                      │
│                           ▼                                     │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  Build Artifacts                                           │ │
│  │  ├── core-image-base-raspberrypi4-64.wic.bz2              │ │
│  │  ├── boot/ (kernel8.img, dtbs)                            │ │
│  │  └── rootfs/                                               │ │
│  │      ├── /usr/bin/qt6-voice-assistant                     │ │
│  │      ├── /lib/systemd/system/voice-assistant.service      │ │
│  │      ├── /var/lib/docker/images/whisper-backend.tar       │ │
│  │      └── /etc/docker/daemon.json                          │ │
│  └────────────────────────────────────────────────────────────┘ │
│                           │                                     │
│                           │ Flash to microSD                    │
│                           ▼                                     │
│  Runtime (Raspberry Pi 4)                                       │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  Boot Sequence                                             │ │
│  │  1. Bootloader (U-Boot)                                    │ │
│  │  2. Linux Kernel (6.1.x)                                   │ │
│  │  3. systemd init                                           │ │
│  │     ├── docker.service (start Docker daemon)               │ │
│  │     ├── whisper-backend.service (start container)          │ │
│  │     └── voice-assistant.service (start Qt6 GUI)            │ │
│  └────────────────────────────────────────────────────────────┘ │
│                           │                                     │
│                           │ System running                      │
│                           ▼                                     │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  Running System                                            │ │
│  │  - Docker container: whisper-backend (port 8000)           │ │
│  │  - Qt6 application: /usr/bin/qt6-voice-assistant           │ │
│  │  - User can interact with GUI                              │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

---

## 10. Performance Architecture

### 10.1 Optimization Pipeline

```
┌─────────────────────────────────────────────────────────────────┐
│             PERFORMANCE OPTIMIZATION LAYERS                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Layer 1: Model Optimization                                    │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  PyTorch Whisper (290MB)                                   │ │
│  │         │                                                   │ │
│  │         │ 1. ONNX Export                                    │ │
│  │         ▼                                                   │ │
│  │  ONNX FP32 (290MB)                                         │ │
│  │         │                                                   │ │
│  │         │ 2. FP16 Quantization                              │ │
│  │         ▼                                                   │ │
│  │  ONNX FP16 (74MB) ← Current deployment                     │ │
│  │         │                                                   │ │
│  │         │ 3. INT8 Quantization (future)                     │ │
│  │         ▼                                                   │ │
│  │  ONNX INT8 (19MB) ← Future optimization                    │ │
│  │                                                             │ │
│  │  Result: 75% size reduction, 2-3x faster inference         │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  Layer 2: Runtime Optimization                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  ONNX Runtime Configuration                                │ │
│  │  ┌──────────────────────────────────────────────────────┐ │ │
│  │  │  • ExecutionProvider: CPUExecutionProvider           │ │ │
│  │  │  • GraphOptimizationLevel: ORT_ENABLE_ALL            │ │ │
│  │  │  • IntraOpNumThreads: 4 (use all cores)              │ │ │
│  │  │  • InterOpNumThreads: 1 (sequential ops)             │ │ │
│  │  │  • EnableCpuMemArena: true                           │ │ │
│  │  │  • EnableMemPattern: true                            │ │ │
│  │  └──────────────────────────────────────────────────────┘ │ │
│  │                                                             │ │
│  │  Result: 30-40% inference speedup                          │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  Layer 3: System Optimization                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  Operating System Tuning                                   │ │
│  │  ┌──────────────────────────────────────────────────────┐ │ │
│  │  │  • CPU Governor: performance (1.5GHz locked)         │ │ │
│  │  │  • Swap: disabled (avoid disk I/O)                   │ │ │
│  │  │  • GPU Memory: 256MB (for display)                   │ │ │
│  │  │  • Docker: cgroup limits (1GB RAM max)               │ │ │
│  │  │  • Audio: ALSA period size optimization              │ │ │
│  │  └──────────────────────────────────────────────────────┘ │ │
│  │                                                             │ │
│  │  Result: Consistent performance, no thermal throttling     │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  Layer 4: Application Optimization                              │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  Smart Caching & Buffering                                 │ │
│  │  ┌──────────────────────────────────────────────────────┐ │ │
│  │  │  • Model caching: Keep loaded in memory              │ │ │
│  │  │  • Ring buffer: 60s circular audio buffer            │ │ │
│  │  │  • VAD: Skip inference on silence                    │ │ │
│  │  │  • Batch processing: Process chunks together          │ │ │
│  │  │  • Connection pooling: Reuse HTTP connections        │ │ │
│  │  └──────────────────────────────────────────────────────┘ │ │
│  │                                                             │ │
│  │  Result: 20-30% overall latency reduction                  │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘

Performance Targets:
├── Latency: < 2 seconds (end-to-end)
├── RTF: < 1.2x (faster than real-time)
├── Memory: < 800MB total
├── CPU: < 80% average
└── Accuracy: > 85% WER
```

---

## **📊 Summary**

This architecture document provides:

✅ **Complete system diagrams** (high-level to low-level)  
✅ **Data flow visualization** (REST + WebSocket)  
✅ **Component interactions** (Qt6 ↔ Docker ↔ ONNX)  
✅ **API specifications** (detailed request/response)  
✅ **Deployment architecture** (Yocto integration)  
✅ **Performance optimization** (model → system layers)

---

**For implementation steps, see**: `WHISPER_ONNX_INTEGRATION_PLAN.md`

**Next Steps**:
1. Convert Whisper models to ONNX (using plan document)
2. Build Docker container (using plan document)
3. Integrate Qt6 frontend (using code examples in this doc)
4. Deploy to Raspberry Pi 4 via Yocto
5. Optimize and benchmark

**Questions?** Refer to the integration plan for troubleshooting and detailed procedures.

