#!/usr/bin/env python3
"""
Text-to-Speech Backend Bridge for Qt6 GUI
Handles voice synthesis using pyttsx3
Communicates with Qt frontend via JSON over stdin/stdout
"""

import sys
import json
import threading
import queue
from datetime import datetime

try:
    import pyttsx3
    TTS_AVAILABLE = True
except ImportError:
    TTS_AVAILABLE = False
    print(json.dumps({"type": "error", "message": "pyttsx3 not installed"}), flush=True)

class TTSBackend:
    def __init__(self):
        self.engine = None
        self.is_speaking = False
        self.command_queue = queue.Queue()
        
        # Default settings
        self.volume = 1.0
        self.rate = 150
        self.voice = None
        
        # Initialize TTS engine
        if TTS_AVAILABLE:
            try:
                self.engine = pyttsx3.init()
                self.engine.setProperty('rate', self.rate)
                self.engine.setProperty('volume', self.volume)
                
                # Setup callbacks
                self.engine.connect('started-utterance', self.on_start)
                self.engine.connect('finished-utterance', self.on_end)
                self.engine.connect('started-word', self.on_word)
                
                self.send_log("TTS engine initialized")
            except Exception as e:
                self.send_error(f"Failed to initialize TTS engine: {str(e)}")
    
    def on_start(self, name):
        """Called when speech starts"""
        self.is_speaking = True
        self.send_json({
            "type": "speech_started",
            "timestamp": datetime.now().isoformat()
        })
    
    def on_end(self, name, completed):
        """Called when speech ends"""
        self.is_speaking = False
        self.send_json({
            "type": "speech_finished",
            "completed": completed,
            "timestamp": datetime.now().isoformat()
        })
    
    def on_word(self, name, location, length):
        """Called when a word is spoken"""
        self.send_json({
            "type": "word_boundary",
            "word": name,
            "position": location,
            "length": length
        })
    
    def speak(self, text):
        """Speak the given text"""
        if not TTS_AVAILABLE or not self.engine:
            self.send_error("TTS engine not available")
            return
        
        try:
            self.engine.say(text)
            self.engine.runAndWait()
        except Exception as e:
            self.send_error(f"Speech error: {str(e)}")
    
    def stop(self):
        """Stop current speech"""
        if not TTS_AVAILABLE or not self.engine:
            return
        
        try:
            self.engine.stop()
            self.is_speaking = False
        except Exception as e:
            self.send_error(f"Stop error: {str(e)}")
    
    def set_volume(self, volume):
        """Set volume (0.0 - 1.0)"""
        if not TTS_AVAILABLE or not self.engine:
            return
        
        self.volume = max(0.0, min(1.0, volume))
        self.engine.setProperty('volume', self.volume)
        self.send_log(f"Volume set to {self.volume}")
    
    def set_rate(self, rate):
        """Set speech rate"""
        if not TTS_AVAILABLE or not self.engine:
            return
        
        self.rate = int(rate * 150)  # Convert 0.5-2.0 to 75-300 words per minute
        self.engine.setProperty('rate', self.rate)
        self.send_log(f"Rate set to {self.rate}")
    
    def set_voice(self, voice_id):
        """Set voice"""
        if not TTS_AVAILABLE or not self.engine:
            return
        
        try:
            voices = self.engine.getProperty('voices')
            if voice_id == "default" and voices:
                self.engine.setProperty('voice', voices[0].id)
            else:
                for voice in voices:
                    if voice_id in voice.id or voice_id in voice.name:
                        self.engine.setProperty('voice', voice.id)
                        break
            self.send_log(f"Voice set to {voice_id}")
        except Exception as e:
            self.send_error(f"Voice setting error: {str(e)}")
    
    def get_voices(self):
        """Get available voices"""
        if not TTS_AVAILABLE or not self.engine:
            return []
        
        try:
            voices = self.engine.getProperty('voices')
            voice_list = []
            for voice in voices:
                voice_list.append({
                    "id": voice.id,
                    "name": voice.name,
                    "languages": voice.languages
                })
            return voice_list
        except Exception as e:
            self.send_error(f"Get voices error: {str(e)}")
            return []
    
    def send_json(self, obj):
        """Send JSON message to Qt frontend"""
        try:
            json_str = json.dumps(obj)
            print(json_str, flush=True)
        except Exception as e:
            print(json.dumps({"type": "error", "message": f"JSON encoding error: {str(e)}"}),
                  flush=True, file=sys.stderr)
    
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
        
        if cmd == "SPEAK":
            text = command.get("text", "")
            if text:
                # Run in separate thread to avoid blocking
                thread = threading.Thread(target=self.speak, args=(text,))
                thread.daemon = True
                thread.start()
        
        elif cmd == "STOP":
            self.stop()
        
        elif cmd == "PAUSE":
            # pyttsx3 doesn't support pause/resume
            self.send_log("Pause not supported by pyttsx3")
        
        elif cmd == "RESUME":
            self.send_log("Resume not supported by pyttsx3")
        
        elif cmd == "SET_VOLUME":
            volume = float(command.get("volume", 1.0))
            self.set_volume(volume)
        
        elif cmd == "SET_RATE":
            rate = float(command.get("rate", 1.0))
            self.set_rate(rate)
        
        elif cmd == "SET_VOICE":
            voice = command.get("voice", "default")
            self.set_voice(voice)
        
        elif cmd == "GET_VOICES":
            voices = self.get_voices()
            self.send_json({
                "type": "voices_list",
                "voices": voices
            })
        
        elif cmd == "QUIT":
            self.send_log("TTS backend shutting down")
            sys.exit(0)
        
        else:
            self.send_error(f"Unknown command: {cmd}")
    
    def run(self):
        """Main loop - read commands from stdin"""
        self.send_log("TTS backend started")
        
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

if __name__ == "__main__":
    backend = TTSBackend()
    backend.run()
