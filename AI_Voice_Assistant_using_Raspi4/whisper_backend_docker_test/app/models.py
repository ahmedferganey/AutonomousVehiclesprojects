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
    model_name: Optional[str] = Field(None, description="Loaded model name")

class ModelInfoResponse(BaseModel):
    """Model information response"""
    model_name: str
    model_path: str
    sample_rate: int
    onnx_runtime_version: str
    num_threads: int

