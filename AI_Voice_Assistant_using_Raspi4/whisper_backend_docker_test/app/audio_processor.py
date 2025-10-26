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
                top_db=30,
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

