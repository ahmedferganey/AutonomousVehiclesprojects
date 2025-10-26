"""FastAPI application for Whisper ONNX transcription backend"""
import logging
import time
from pathlib import Path
from typing import Optional
import io

from fastapi import FastAPI, File, UploadFile, HTTPException, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import numpy as np

from .config import settings
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

# Global state
whisper_engine = None
model_loaded = False

@app.on_event("startup")
async def startup_event():
    """Initialize Whisper engine on startup"""
    global whisper_engine, model_loaded
    
    logger.info("🚀 Starting Whisper ONNX Transcription Backend...")
    logger.info(f"   Version: {settings.VERSION}")
    logger.info(f"   Model: {settings.MODEL_NAME}")
    logger.info(f"   Model Path: {settings.MODEL_PATH}")
    
    # Check if model exists
    if settings.MODEL_PATH.exists():
        try:
            # Import here to avoid loading if model doesn't exist
            from .whisper_engine import get_engine
            
            whisper_engine = get_engine()
            model_loaded = True
            logger.info(f"✅ Whisper engine initialized: {whisper_engine.get_model_info()}")
        except Exception as e:
            logger.error(f"❌ Failed to initialize Whisper engine: {e}")
            logger.warning("⚠️ Running in MOCK MODE (no model loaded)")
            model_loaded = False
    else:
        logger.warning(f"⚠️ Model not found at: {settings.MODEL_PATH}")
        logger.warning("⚠️ Running in MOCK MODE - API will return simulated results")
        logger.warning("   To use real transcription:")
        logger.warning("   1. Convert Whisper model to ONNX (see documentation)")
        logger.warning(f"   2. Place model files in: {settings.MODEL_PATH}")
        logger.warning("   3. Restart container")
        model_loaded = False

@app.get("/", response_model=dict)
async def root():
    """Root endpoint"""
    return {
        "name": settings.APP_NAME,
        "version": settings.VERSION,
        "status": "running",
        "mode": "production" if model_loaded else "mock",
        "message": "Whisper ONNX backend is ready" if model_loaded else "Running in MOCK mode (no model loaded)"
    }

@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Health check endpoint"""
    return HealthResponse(
        status="healthy",
        model_loaded=model_loaded,
        timestamp=time.time(),
        model_name=settings.MODEL_NAME if model_loaded else "none (mock mode)"
    )

@app.get("/model/info", response_model=ModelInfoResponse)
async def model_info():
    """Get model information"""
    if not model_loaded or whisper_engine is None:
        raise HTTPException(
            status_code=503,
            detail="Model not loaded. Running in mock mode. Please load Whisper ONNX model."
        )
    
    try:
        info = whisper_engine.get_model_info()
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
    """
    start_time = time.time()
    
    try:
        logger.info(f"📥 Received audio file: {audio_file.filename}, language: {language}")
        
        # Read audio file
        audio_bytes = await audio_file.read()
        logger.info(f"   File size: {len(audio_bytes)} bytes")
        
        if not model_loaded or whisper_engine is None:
            # MOCK MODE: Return simulated transcription
            logger.warning("⚠️ MOCK MODE: Returning simulated transcription")
            
            # Simulate processing time
            duration = len(audio_bytes) / (settings.SAMPLE_RATE * 2)  # Rough estimate
            inference_time = duration * 0.5  # Simulate faster than real-time
            
            mock_text = f"[MOCK TRANSCRIPTION] This is a simulated transcription for testing. File: {audio_file.filename}, Language: {language}"
            
            return TranscribeResponse(
                text=mock_text,
                language=language,
                duration=duration,
                inference_time=inference_time,
                total_time=time.time() - start_time,
                rtf=inference_time / duration if duration > 0 else 0,
                timestamp=time.time()
            )
        
        # PRODUCTION MODE: Real transcription
        # Load audio with soundfile
        import soundfile as sf
        audio_io = io.BytesIO(audio_bytes)
        audio, sample_rate = sf.read(audio_io, dtype=np.float32)
        
        # Preprocess audio
        from .audio_processor import AudioProcessor
        audio_processor = AudioProcessor()
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
        result = whisper_engine.transcribe(audio, language=language)
        
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
    """
    try:
        import base64
        
        # Decode base64 audio
        audio_bytes = base64.b64decode(request.audio_base64)
        
        logger.info(f"📥 Received base64 audio: {len(audio_bytes)} bytes, language: {request.language}")
        
        if not model_loaded or whisper_engine is None:
            # MOCK MODE
            logger.warning("⚠️ MOCK MODE: Returning simulated transcription")
            
            duration = len(audio_bytes) / (settings.SAMPLE_RATE * 2)
            inference_time = duration * 0.5
            
            mock_text = f"[MOCK TRANSCRIPTION] Base64 audio transcribed. Language: {request.language}"
            
            return TranscribeResponse(
                text=mock_text,
                language=request.language,
                duration=duration,
                inference_time=inference_time,
                total_time=inference_time,
                rtf=0.5,
                timestamp=time.time()
            )
        
        # PRODUCTION MODE
        import soundfile as sf
        audio_io = io.BytesIO(audio_bytes)
        audio, sample_rate = sf.read(audio_io, dtype=np.float32)
        
        from .audio_processor import AudioProcessor
        audio_processor = AudioProcessor()
        audio, sample_rate = audio_processor.preprocess(audio, sample_rate)
        
        result = whisper_engine.transcribe(audio, language=request.language)
        
        return TranscribeResponse(**result)
        
    except Exception as e:
        logger.error(f"❌ Base64 transcription error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.websocket("/stream")
async def websocket_stream(websocket: WebSocket):
    """
    WebSocket endpoint for real-time streaming transcription
    """
    await websocket.accept()
    logger.info("🔌 WebSocket connection established")
    
    audio_buffer = []
    
    try:
        while True:
            # Receive audio chunk
            data = await websocket.receive_bytes()
            
            logger.debug(f"📦 Received audio chunk: {len(data)} bytes")
            
            # Convert bytes to float32 array
            chunk = np.frombuffer(data, dtype=np.float32)
            audio_buffer.extend(chunk)
            
            # Process every 3 seconds of audio
            if len(audio_buffer) >= settings.SAMPLE_RATE * 3:
                audio = np.array(audio_buffer, dtype=np.float32)
                
                if not model_loaded or whisper_engine is None:
                    # MOCK MODE
                    await websocket.send_json({
                        "type": "partial",
                        "text": f"[MOCK] Processing {len(audio)/settings.SAMPLE_RATE:.1f}s of audio...",
                        "timestamp": time.time(),
                    })
                else:
                    # PRODUCTION MODE
                    from .audio_processor import AudioProcessor
                    audio_processor = AudioProcessor()
                    
                    if audio_processor.detect_voice_activity(audio):
                        result = whisper_engine.transcribe(audio)
                        
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

@app.get("/status/detailed")
async def detailed_status():
    """Detailed status information for debugging"""
    import platform
    import sys
    
    return {
        "application": {
            "name": settings.APP_NAME,
            "version": settings.VERSION,
            "mode": "production" if model_loaded else "mock",
        },
        "model": {
            "name": settings.MODEL_NAME,
            "path": str(settings.MODEL_PATH),
            "loaded": model_loaded,
            "exists": settings.MODEL_PATH.exists(),
        },
        "system": {
            "platform": platform.platform(),
            "python_version": sys.version,
            "architecture": platform.machine(),
        },
        "configuration": {
            "sample_rate": settings.SAMPLE_RATE,
            "max_audio_length": settings.MAX_AUDIO_LENGTH,
            "onnx_threads": settings.ONNX_NUM_THREADS,
        }
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host=settings.HOST, port=settings.PORT)

