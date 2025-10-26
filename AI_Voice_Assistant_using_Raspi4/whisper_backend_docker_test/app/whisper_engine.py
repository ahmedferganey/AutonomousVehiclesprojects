"""ONNX Whisper inference engine optimized for Raspberry Pi 4"""
import time
import logging
from pathlib import Path
from typing import Dict, Optional
import numpy as np

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
        
        try:
            import onnxruntime as ort
            from optimum.onnxruntime import ORTModelForSpeechSeq2Seq
            from transformers import AutoProcessor
            
            # Configure ONNX Runtime session options
            self.session_options = ort.SessionOptions()
            self.session_options.intra_op_num_threads = settings.ONNX_INTRA_OP_NUM_THREADS
            self.session_options.inter_op_num_threads = settings.ONNX_INTER_OP_NUM_THREADS
            self.session_options.graph_optimization_level = ort.GraphOptimizationLevel.ORT_ENABLE_ALL
            self.session_options.enable_cpu_mem_arena = True
            self.session_options.enable_mem_pattern = True
            
            # Load ONNX model
            logger.info("📥 Loading ONNX model...")
            self.model = ORTModelForSpeechSeq2Seq.from_pretrained(
                str(self.model_path),
                provider="CPUExecutionProvider",
                session_options=self.session_options,
            )
            
            # Load processor
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
        dummy_audio = np.zeros(16000 * 5, dtype=np.float32)
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
        """
        if self.model is None or self.processor is None:
            raise RuntimeError("Whisper engine not initialized")
        
        start_time = time.time()
        
        try:
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
                max_length=448,
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
                "rtf": rtf,
                "timestamp": time.time(),
            }
            
            logger.info(f"✅ Transcription complete: '{transcription[:50]}...' "
                       f"(RTF: {rtf:.2f}x, time: {inference_time:.2f}s)")
            
            return result
            
        except Exception as e:
            logger.error(f"❌ Transcription failed: {e}")
            raise
    
    def get_model_info(self) -> Dict:
        """Get model information"""
        import onnxruntime as ort
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

