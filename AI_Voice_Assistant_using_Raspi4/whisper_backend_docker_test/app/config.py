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
    WORKERS: int = 1
    
    # Model settings
    MODEL_NAME: str = os.getenv("MODEL_NAME", "whisper-base-onnx")
    MODELS_DIR: Path = Path(os.getenv("MODELS_DIR", "/app/models"))
    MODEL_PATH: Path = MODELS_DIR / MODEL_NAME
    
    # Audio settings
    SAMPLE_RATE: int = 16000
    CHANNELS: int = 1
    CHUNK_SIZE: int = 8192
    MAX_AUDIO_LENGTH: int = 30
    
    # ONNX Runtime settings
    ONNX_NUM_THREADS: int = int(os.getenv("ONNX_NUM_THREADS", "4"))
    ONNX_INTRA_OP_NUM_THREADS: int = 4
    ONNX_INTER_OP_NUM_THREADS: int = 1
    
    # Cache
    CACHE_DIR: Path = Path("/app/cache")
    AUDIO_BUFFER_DIR: Path = CACHE_DIR / "audio_buffers"
    MAX_CACHE_SIZE_MB: int = 500
    
    # Logging
    LOG_LEVEL: str = os.getenv("LOG_LEVEL", "INFO")
    LOG_FORMAT: str = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
    
    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"

# Global settings instance
settings = Settings()

# Ensure directories exist
settings.MODELS_DIR.mkdir(parents=True, exist_ok=True)
settings.AUDIO_BUFFER_DIR.mkdir(parents=True, exist_ok=True)

print(f"✓ Configuration loaded: Model={settings.MODEL_NAME}, Threads={settings.ONNX_NUM_THREADS}")
