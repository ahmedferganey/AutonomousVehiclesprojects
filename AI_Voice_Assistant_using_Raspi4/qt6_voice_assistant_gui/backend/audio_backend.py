#!/usr/bin/env python3
"""
Audio Backend Bridge for Qt6 GUI
Handles audio capture, processing, and Whisper transcription
Communicates with Qt frontend via JSON over stdin/stdout
"""

import sys
import json
import threading
import queue
import time
import numpy as np
import sounddevice as sd
import whisper
from datetime import datetime

class AudioBackend:
    def __init__(self):
        self.sample_rate = 16000
        self.channels = 1
        self.dtype = np.float32
        self.block_size = 1024
        
        self.is_listening = False
        self.is_processing = False
        
        # Audio buffer (ring buffer)
        self.max_recording_seconds = 60
        self.audio_buffer = []
        self.buffer_lock = threading.Lock()
        
        # Whisper model
        self.model = None
        self.model_name = "base"
        
        # Command queue
        self.command_queue = queue.Queue()
        
        # Audio stream
        self.stream = None
        
        # Silence detection
        self.silence_threshold = 0.01
        
    def load_model(self):
        """Load Whisper model"""
        try:
            self.send_log(f"Loading Whisper model: {self.model_name}")
            self.model = whisper.load_model(self.model_name)
            self.send_log(f"Model loaded successfully")
        except Exception as e:
            self.send_error(f"Failed to load Whisper model: {str(e)}")
    
    def audio_callback(self, indata, frames, time_info, status):
        """Audio input callback"""
        if status:
            self.send_log(f"Audio callback status: {status}")
        
        if self.is_listening:
            with self.buffer_lock:
                self.audio_buffer.extend(indata.copy())
                
                # Calculate audio level
                audio_level = float(np.abs(indata).mean())
                self.send_audio_level(audio_level)
                
                # Limit buffer size
                max_samples = self.max_recording_seconds * self.sample_rate
                if len(self.audio_buffer) > max_samples:
                    self.audio_buffer = self.audio_buffer[-max_samples:]
    
    def start_listening(self):
        """Start audio capture"""
        if self.is_listening:
            return
        
        try:
            self.is_listening = True
            self.audio_buffer = []
            
            if self.stream is None:
                self.stream = sd.InputStream(
                    samplerate=self.sample_rate,
                    channels=self.channels,
                    dtype=self.dtype,
                    blocksize=self.block_size,
                    callback=self.audio_callback
                )
            
            self.stream.start()
            self.send_log("Started listening")
            
        except Exception as e:
            self.send_error(f"Failed to start listening: {str(e)}")
            self.is_listening = False
    
    def stop_listening(self):
        """Stop audio capture"""
        if not self.is_listening:
            return
        
        self.is_listening = False
        
        if self.stream is not None:
            self.stream.stop()
        
        self.send_log("Stopped listening")
    
    def process_audio(self):
        """Process captured audio with Whisper"""
        if self.is_processing:
            return
        
        self.is_processing = True
        self.stop_listening()
        
        # Run in separate thread to avoid blocking
        thread = threading.Thread(target=self._process_audio_thread)
        thread.daemon = True
        thread.start()
    
    def _process_audio_thread(self):
        """Process audio in background thread"""
        try:
            # Load model if not loaded
            if self.model is None:
                self.load_model()
            
            # Get audio data
            with self.buffer_lock:
                if len(self.audio_buffer) == 0:
                    self.send_error("No audio data to process")
                    self.is_processing = False
                    return
                
                audio_data = np.array(self.audio_buffer, dtype=np.float32).flatten()
            
            self.send_log(f"Processing {len(audio_data)/self.sample_rate:.2f} seconds of audio")
            
            # Trim silence from beginning and end
            audio_data = self.trim_silence(audio_data)
            
            if len(audio_data) < self.sample_rate * 0.5:  # Less than 0.5 seconds
                self.send_error("Audio too short after silence trimming")
                self.is_processing = False
                return
            
            # Transcribe with Whisper
            result = self.model.transcribe(
                audio_data,
                fp16=False,
                language=None,  # Auto-detect
                task="transcribe"
            )
            
            text = result["text"].strip()
            
            if text:
                self.send_transcription(text)
                self.send_log(f"Transcription: {text}")
            else:
                self.send_error("No speech detected")
            
        except Exception as e:
            self.send_error(f"Processing error: {str(e)}")
        
        finally:
            self.is_processing = False
    
    def trim_silence(self, audio):
        """Remove silence from audio"""
        # Calculate energy
        energy = np.abs(audio)
        
        # Find start
        start_idx = 0
        for i in range(len(energy)):
            if energy[i] > self.silence_threshold:
                start_idx = max(0, i - int(0.1 * self.sample_rate))  # Keep 0.1s before
                break
        
        # Find end
        end_idx = len(energy)
        for i in range(len(energy) - 1, -1, -1):
            if energy[i] > self.silence_threshold:
                end_idx = min(len(energy), i + int(0.1 * self.sample_rate))  # Keep 0.1s after
                break
        
        return audio[start_idx:end_idx]
    
    def cancel_processing(self):
        """Cancel ongoing processing"""
        self.is_processing = False
        self.send_log("Processing cancelled")
    
    def send_json(self, obj):
        """Send JSON message to Qt frontend"""
        try:
            json_str = json.dumps(obj)
            print(json_str, flush=True)
        except Exception as e:
            print(json.dumps({"type": "error", "message": f"JSON encoding error: {str(e)}"}), 
                  flush=True, file=sys.stderr)
    
    def send_transcription(self, text):
        """Send transcription result"""
        self.send_json({
            "type": "transcription",
            "text": text,
            "timestamp": datetime.now().isoformat()
        })
    
    def send_audio_level(self, level):
        """Send audio level update"""
        self.send_json({
            "type": "audio_level",
            "level": float(level)
        })
    
    def send_log(self, message):
        """Send log message"""
        self.send_json({
            "type": "log",
            "message": message,
            "timestamp": datetime.now().isoformat()
        })
    
    def send_error(self, message):
        """Send error message"""
        self.send_json({
            "type": "error",
            "message": message,
            "timestamp": datetime.now().isoformat()
        })
    
    def handle_command(self, command):
        """Handle command from Qt frontend"""
        cmd = command.get("command", "")
        
        if cmd == "START_LISTENING":
            self.start_listening()
        elif cmd == "STOP_LISTENING":
            self.stop_listening()
        elif cmd == "PROCESS_AUDIO":
            self.process_audio()
        elif cmd == "CANCEL_PROCESSING":
            self.cancel_processing()
        elif cmd == "SET_MODEL":
            self.model_name = command.get("model", "base")
            self.model = None  # Reload on next use
            self.send_log(f"Model set to: {self.model_name}")
        elif cmd == "SET_SILENCE_THRESHOLD":
            self.silence_threshold = float(command.get("threshold", 0.01))
            self.send_log(f"Silence threshold set to: {self.silence_threshold}")
        elif cmd == "QUIT":
            self.stop_listening()
            if self.stream is not None:
                self.stream.close()
            self.send_log("Backend shutting down")
            sys.exit(0)
        else:
            self.send_error(f"Unknown command: {cmd}")
    
    def run(self):
        """Main loop - read commands from stdin"""
        self.send_log("Audio backend started")
        
        # Start command reader thread
        def read_commands():
            for line in sys.stdin:
                try:
                    command = json.loads(line.strip())
                    self.command_queue.put(command)
                except json.JSONDecodeError as e:
                    self.send_error(f"Invalid JSON: {str(e)}")
        
        reader_thread = threading.Thread(target=read_commands)
        reader_thread.daemon = True
        reader_thread.start()
        
        # Process commands
        while True:
            try:
                command = self.command_queue.get(timeout=0.1)
                self.handle_command(command)
            except queue.Empty:
                pass
            except KeyboardInterrupt:
                break
        
        # Cleanup
        self.stop_listening()
        if self.stream is not None:
            self.stream.close()

if __name__ == "__main__":
    backend = AudioBackend()
    backend.run()

