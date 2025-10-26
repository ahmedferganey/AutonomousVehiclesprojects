# Phase 3: Voice Assistant Enhancements - Complete Guide

**Status**: 🚧 **IN PROGRESS** (TTS Qt GUI: ✅ Complete, Backend: Partial)  
**Target**: Q2 2025  
**Priority**: High  
**Effort**: 10-12 weeks

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Natural Language Understanding](#natural-language-understanding)
4. [Text-to-Speech Integration](#text-to-speech-integration)
5. [Wake Word Detection](#wake-word-detection)
6. [Conversation Context Management](#conversation-context-management)
7. [Integration Points](#integration-points)
8. [Setup & Configuration](#setup--configuration)
9. [Development Guide](#development-guide)
10. [Testing Strategy](#testing-strategy)
11. [Troubleshooting](#troubleshooting)

---

## 🎯 Overview

### Objectives

Phase 3 transforms the basic transcription system into an intelligent voice assistant with:

- **Natural Language Understanding (NLU)**: Intent recognition and entity extraction
- **Text-to-Speech (TTS)**: Voice responses for user feedback
- **Wake Word Detection**: "Hey AutoTalk" activation phrase
- **Context Management**: Multi-turn conversations with memory
- **Multi-language Support**: English, Arabic, Chinese, and more

### Success Criteria

- ✅ TTS Qt GUI implementation complete
- [ ] NLU accuracy >90% for common automotive commands
- [ ] TTS response latency <500ms
- [ ] Wake word detection accuracy >95%, false alarm rate <1%
- [ ] Context retention for 10+ conversation turns
- [ ] Support for 5+ languages

### Current Status (October 2024)

- ✅ **TTS Qt GUI**: VoiceResponsePanel.qml complete
- ✅ **TTS C++ Backend**: TTSEngine class complete
- ✅ **TTS Python Backend**: tts_backend.py complete
- ✅ **Volume & Rate Controls**: GUI sliders implemented
- ✅ **Voice Selection**: Multiple voice support
- [ ] **NLU**: Not started (0%)
- [ ] **Wake Word**: Not started (0%)
- [ ] **Context**: Not started (0%)

---

## 🏗️ Architecture

### System Overview

```
┌───────────────────────────────────────────────────────────────┐
│                  Voice Assistant Architecture                  │
│                                                                │
│  ┌──────────────┐           ┌──────────────┐                 │
│  │   Wake Word  │           │    Speech    │                 │
│  │   Detection  │           │  Recognition │                 │
│  │  (Porcupine) │◄──────────┤  (Whisper)   │                 │
│  └──────┬───────┘           └──────┬───────┘                 │
│         │ "Hey AutoTalk"           │ Transcribed Text        │
│         │ detected                 │                         │
│         ▼                          ▼                         │
│  ┌──────────────────────────────────────────────────────┐   │
│  │         Natural Language Understanding               │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │   │
│  │  │   Intent    │  │   Entity    │  │  Language   │ │   │
│  │  │Classifier   │  │ Extraction  │  │  Detection  │ │   │
│  │  │  (spaCy)    │  │   (NER)     │  │  (langid)   │ │   │
│  │  └──────┬──────┘  └──────┬──────┘  └─────────────┘ │   │
│  │         │                 │                          │   │
│  │         └────────┬────────┘                          │   │
│  │                  │ Structured Intent                 │   │
│  └──────────────────┼───────────────────────────────────┘   │
│                     │                                        │
│                     ▼                                        │
│  ┌──────────────────────────────────────────────────────┐   │
│  │         Conversation Context Manager                 │   │
│  │  ┌────────────────────────────────────────────────┐ │   │
│  │  │ Dialogue State Tracking                        │ │   │
│  │  │ - Current intent                               │ │   │
│  │  │ - Active entities                              │ │   │
│  │  │ - Conversation history (last 10 turns)         │ │   │
│  │  │ - User preferences                             │ │   │
│  │  │ - Session context                              │ │   │
│  │  └────────────────────────────────────────────────┘ │   │
│  └──────────────────┼───────────────────────────────────┘   │
│                     │                                        │
│                     ▼                                        │
│  ┌──────────────────────────────────────────────────────┐   │
│  │         Command Dispatcher                           │   │
│  │  - Route to appropriate handler                      │   │
│  │  - Execute vehicle commands                          │   │
│  │  - Generate response                                 │   │
│  └──────────────────┼───────────────────────────────────┘   │
│                     │                                        │
│                     ▼                                        │
│  ┌──────────────────────────────────────────────────────┐   │
│  │         Text-to-Speech Engine                        │   │
│  │  ┌────────────────────────────────────────────────┐ │   │
│  │  │ Python: pyttsx3 / gTTS / Festival              │ │   │
│  │  │ - Multi-language support                        │ │   │
│  │  │ - Voice customization (pitch, rate, volume)     │ │   │
│  │  │ - Queue management                              │ │   │
│  │  └────────────────────────────────────────────────┘ │   │
│  └──────────────────┼───────────────────────────────────┘   │
│                     │                                        │
│                     ▼                                        │
│             Audio Output (/dev/snd)                          │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

### Data Flow

```
User: "Hey AutoTalk, set temperature to 22 degrees"
    │
    ▼
Wake Word Detection → "Hey AutoTalk" detected → Activate listening
    │
    ▼
Speech Recognition (Whisper) → "set temperature to 22 degrees"
    │
    ▼
NLU Processing:
    Intent: climate_control
    Action: set_temperature
    Entities: {value: 22, unit: "celsius"}
    │
    ▼
Context Manager:
    Check previous context (climate settings)
    Resolve entity references
    Update dialogue state
    │
    ▼
Command Dispatcher:
    Execute: ClimateControl.setTemperature(22)
    Generate response: "Setting temperature to 22 degrees Celsius"
    │
    ▼
Text-to-Speech:
    Synthesize: "Setting temperature to 22 degrees Celsius"
    │
    ▼
Audio Output → User hears confirmation
```

---

## 🧠 Natural Language Understanding

### Components

#### 1. Intent Classification

**Purpose**: Determine user's goal from spoken input

**Supported Intents**:

| Intent | Example Utterances | Actions |
|--------|-------------------|---------|
| `climate_control` | "Set AC to 22", "Make it warmer", "Turn on heat" | Adjust HVAC |
| `navigation` | "Navigate to home", "Find gas station", "Avoid tolls" | Route planning |
| `media_control` | "Play music", "Next song", "Volume up" | Media playback |
| `phone_call` | "Call John", "Dial 555-1234" | Phone integration |
| `information_query` | "What's the weather?", "How far to destination?" | Info retrieval |
| `vehicle_status` | "Check tire pressure", "Fuel level" | Vehicle diagnostics |
| `general_chat` | "Hello", "Thank you", "How are you?" | Conversational |

**Implementation** (Python with spaCy):

```python
import spacy
from spacy.pipeline.textcat import Config

class IntentClassifier:
    def __init__(self, model_path="models/intent_classifier"):
        self.nlp = spacy.load(model_path)
    
    def classify(self, text):
        """Classify user intent from text"""
        doc = self.nlp(text)
        
        # Get intent scores
        cats = doc.cats
        intent = max(cats, key=cats.get)
        confidence = cats[intent]
        
        return {
            "intent": intent,
            "confidence": confidence,
            "all_scores": cats
        }

# Training data example
TRAINING_DATA = [
    ("set temperature to 22", {"cats": {"climate_control": 1.0, "navigation": 0.0, ...}}),
    ("navigate to home", {"cats": {"navigation": 1.0, "climate_control": 0.0, ...}}),
    # ... more examples
]
```

**Training**:

```bash
# Prepare training data (1000+ examples per intent)
python scripts/prepare_training_data.py

# Train model
python -m spacy train config.cfg \
    --output models/intent_classifier \
    --paths.train train.spacy \
    --paths.dev dev.spacy
```

#### 2. Entity Extraction

**Purpose**: Extract specific values from utterances

**Entity Types**:

| Entity Type | Examples | Use Case |
|------------|----------|----------|
| `TEMPERATURE` | "22", "20 degrees", "warmer" | Climate control |
| `LOCATION` | "home", "123 Main St", "nearest Starbucks" | Navigation |
| `CONTACT` | "John", "Mom", "Dr. Smith" | Phone calls |
| `TIME` | "3 PM", "in 10 minutes", "tomorrow" | Scheduling |
| `MEDIA_TITLE` | "Bohemian Rhapsody", "Beatles" | Music control |
| `NUMBER` | "5", "ten", "a couple" | Various |
| `UNIT` | "mph", "km", "celsius" | Measurements |

**Implementation** (spaCy NER):

```python
from spacy.tokens import Span

class EntityExtractor:
    def __init__(self, model_path="models/entity_extractor"):
        self.nlp = spacy.load(model_path)
    
    def extract(self, text):
        """Extract entities from text"""
        doc = self.nlp(text)
        
        entities = []
        for ent in doc.ents:
            entities.append({
                "text": ent.text,
                "type": ent.label_,
                "start": ent.start_char,
                "end": ent.end_char
            })
        
        return entities

# Example
extractor = EntityExtractor()
entities = extractor.extract("Set temperature to 22 degrees celsius")
# Output: [
#     {"text": "22", "type": "TEMPERATURE", "start": 19, "end": 21},
#     {"text": "degrees celsius", "type": "UNIT", "start": 22, "end": 37}
# ]
```

#### 3. Language Detection

**Purpose**: Support multi-language input

**Supported Languages**:
- English (en)
- Arabic (ar)
- Chinese (zh)
- Spanish (es)
- French (fr)

**Implementation** (langid):

```python
import langid

class LanguageDetector:
    def detect(self, text):
        """Detect language from text"""
        lang, confidence = langid.classify(text)
        return {
            "language": lang,
            "confidence": confidence
        }

# Example
detector = LanguageDetector()
result = detector.detect("اضبط درجة الحرارة على 22")
# Output: {"language": "ar", "confidence": 0.99}
```

### Complete NLU Pipeline

```python
class NLUPipeline:
    def __init__(self):
        self.intent_classifier = IntentClassifier()
        self.entity_extractor = EntityExtractor()
        self.language_detector = LanguageDetector()
    
    def process(self, text):
        """Complete NLU processing"""
        # Detect language
        lang_info = self.language_detector.detect(text)
        
        # Classify intent
        intent_info = self.intent_classifier.classify(text)
        
        # Extract entities
        entities = self.entity_extractor.extract(text)
        
        return {
            "text": text,
            "language": lang_info["language"],
            "intent": intent_info["intent"],
            "confidence": intent_info["confidence"],
            "entities": entities
        }

# Example usage
nlu = NLUPipeline()
result = nlu.process("Set temperature to 22 degrees")
print(result)
# Output:
# {
#     "text": "Set temperature to 22 degrees",
#     "language": "en",
#     "intent": "climate_control",
#     "confidence": 0.95,
#     "entities": [
#         {"text": "22", "type": "TEMPERATURE", ...},
#         {"text": "degrees", "type": "UNIT", ...}
#     ]
# }
```

### Setup Instructions

**1. Install Dependencies**:

```bash
pip install spacy langid
python -m spacy download en_core_web_sm
python -m spacy download ar_core_news_sm
python -m spacy download zh_core_web_sm
```

**2. Prepare Training Data**:

Create `data/intents.json`:
```json
{
  "climate_control": [
    "set temperature to {TEMP}",
    "make it {warmer|cooler}",
    "turn {on|off} AC",
    "adjust climate to {TEMP} degrees"
  ],
  "navigation": [
    "navigate to {LOCATION}",
    "find {nearest|closest} {PLACE}",
    "take me to {LOCATION}",
    "how do I get to {LOCATION}"
  ]
}
```

**3. Train Models**:

```bash
cd backend/nlu
python train_intent_classifier.py --data data/intents.json --output models/
python train_entity_extractor.py --data data/entities.json --output models/
```

**4. Integrate with Application**:

```python
# backend/nlu_backend.py
from nlu_pipeline import NLUPipeline

nlu = NLUPipeline()

def process_command(text):
    result = nlu.process(text)
    return result
```

---

## 🔊 Text-to-Speech Integration

### Implementation Status

✅ **COMPLETED** (October 2024)

### Components

#### 1. TTSEngine Class (C++)

**Location**: `src/ttsengine.h`, `src/ttsengine.cpp`

**Features**:
- Multiple voice support
- Volume control (0.0 - 1.0)
- Rate control (50 - 300 words/min)
- Speech queue management
- Python backend integration

**Usage in QML**:

```qml
import QtQuick

Item {
    TTSEngine {
        id: tts
        currentVoice: "english"
        volume: 0.9
        rate: 150
        
        onSpeechStarted: {
            console.log("Speaking:", text)
        }
        
        onSpeechFinished: {
            console.log("Speech complete")
        }
        
        onError: {
            console.error("TTS error:", message)
        }
    }
    
    Button {
        text: "Speak"
        onClicked: {
            tts.speak("Hello, welcome to the voice assistant")
        }
    }
}
```

#### 2. Python TTS Backend

**Location**: `backend/tts_backend.py`

**Supported Engines**:

| Engine | Library | Pros | Cons |
|--------|---------|------|------|
| **pyttsx3** | pyttsx3 | Offline, fast | Limited voices |
| **gTTS** | gTTS | Good quality | Requires internet |
| **Festival** | festival | Open-source | Complex setup |
| **espeak** | espeak | Lightweight | Robotic voice |

**Implementation** (pyttsx3):

```python
#!/usr/bin/env python3
import sys
import json
import pyttsx3
import threading

class TTSService:
    def __init__(self):
        self.engine = pyttsx3.init()
        self.engine.setProperty('rate', 150)
        self.engine.setProperty('volume', 0.9)
        
        # Get available voices
        self.voices = self.engine.getProperty('voices')
    
    def set_voice(self, voice_id):
        """Set voice by ID or name"""
        for voice in self.voices:
            if voice_id in voice.id or voice_id in voice.name:
                self.engine.setProperty('voice', voice.id)
                return True
        return False
    
    def set_rate(self, rate):
        """Set speech rate (words per minute)"""
        self.engine.setProperty('rate', rate)
    
    def set_volume(self, volume):
        """Set volume (0.0 to 1.0)"""
        self.engine.setProperty('volume', volume)
    
    def speak(self, text):
        """Synthesize speech from text"""
        try:
            self.engine.say(text)
            self.engine.runAndWait()
            return {"success": True}
        except Exception as e:
            return {"success": False, "error": str(e)}

# Main entry point
if __name__ == "__main__":
    service = TTSService()
    
    # Read commands from stdin (JSON)
    for line in sys.stdin:
        try:
            cmd = json.loads(line)
            
            if cmd["action"] == "speak":
                result = service.speak(cmd["text"])
            elif cmd["action"] == "set_voice":
                service.set_voice(cmd["voice"])
                result = {"success": True}
            elif cmd["action"] == "set_rate":
                service.set_rate(cmd["rate"])
                result = {"success": True}
            elif cmd["action"] == "set_volume":
                service.set_volume(cmd["volume"])
                result = {"success": True}
            else:
                result = {"success": False, "error": "Unknown action"}
            
            print(json.dumps(result))
            sys.stdout.flush()
            
        except Exception as e:
            print(json.dumps({"success": False, "error": str(e)}))
            sys.stdout.flush()
```

#### 3. VoiceResponsePanel QML Component

**Location**: `qml/VoiceResponsePanel.qml`

**Features**:
- Live TTS response display
- Audio visualization during speech
- Volume and rate sliders
- Voice selection dropdown
- Speech queue display

**Screenshots (Conceptual)**:

```
┌────────────────────────────────────────────────────────┐
│  Voice Response Panel                          [X]      │
├────────────────────────────────────────────────────────┤
│                                                         │
│  Current Response:                                      │
│  ┌────────────────────────────────────────────────┐   │
│  │ "Setting temperature to 22 degrees Celsius"    │   │
│  │ ████████████████░░░░░░░░░░░░░░░░░░░░░ Speaking │   │
│  └────────────────────────────────────────────────┘   │
│                                                         │
│  Voice: [English (US)          ▼]                      │
│                                                         │
│  Volume:  ███████████████░░░ 75%                       │
│  Rate:    ██████████░░░░░░░ 150 WPM                    │
│                                                         │
│  Speech Queue:                                          │
│  1. "Temperature adjusted"                              │
│  2. "Would you like me to adjust the fan speed?"       │
│                                                         │
│  [Clear Queue]  [Test Voice]  [Settings]               │
│                                                         │
└────────────────────────────────────────────────────────┘
```

### Multi-Language Support

**Supported Languages**:

| Language | Code | Voice Name | Quality |
|----------|------|------------|---------|
| English (US) | en-US | David | High |
| English (UK) | en-GB | Hazel | High |
| Arabic | ar | Laila | Medium |
| Chinese (Mandarin) | zh-CN | Tingting | High |
| Spanish | es-ES | Jorge | High |
| French | fr-FR | Thomas | High |

**Language Selection**:

```qml
ComboBox {
    id: languageSelector
    model: ["English (US)", "Arabic", "Chinese", "Spanish", "French"]
    
    onCurrentTextChanged: {
        var langCodes = {
            "English (US)": "en-US",
            "Arabic": "ar",
            "Chinese": "zh-CN",
            "Spanish": "es-ES",
            "French": "fr-FR"
        }
        tts.setVoice(langCodes[currentText])
    }
}
```

### Response Templates

**Location**: `backend/response_templates.json`

```json
{
  "climate_control": {
    "temperature_set": {
      "en": "Setting temperature to {value} degrees {unit}",
      "ar": "ضبط درجة الحرارة على {value} درجة {unit}",
      "zh": "将温度设置为{value}{unit}",
      "es": "Configurando temperatura a {value} grados {unit}",
      "fr": "Réglage de la température à {value} degrés {unit}"
    },
    "fan_speed_set": {
      "en": "Adjusting fan speed to level {level}",
      "ar": "ضبط سرعة المروحة على المستوى {level}",
      "zh": "将风扇速度调整到{level}档",
      "es": "Ajustando velocidad del ventilador a nivel {level}",
      "fr": "Réglage de la vitesse du ventilateur au niveau {level}"
    }
  },
  "navigation": {
    "route_found": {
      "en": "Route found. Distance: {distance}, ETA: {eta}",
      "ar": "تم العثور على المسار. المسافة: {distance}، الوقت المقدر: {eta}",
      "zh": "找到路线。距离：{distance}，预计到达时间：{eta}",
      "es": "Ruta encontrada. Distancia: {distance}, ETA: {eta}",
      "fr": "Itinéraire trouvé. Distance : {distance}, Heure d'arrivée : {eta}"
    }
  },
  "errors": {
    "not_understood": {
      "en": "Sorry, I didn't understand that. Could you rephrase?",
      "ar": "عذراً، لم أفهم ذلك. هل يمكنك إعادة الصياغة؟",
      "zh": "抱歉，我没有理解。能否重新表达？",
      "es": "Lo siento, no entendí eso. ¿Podrías reformular?",
      "fr": "Désolé, je n'ai pas compris. Pouvez-vous reformuler ?"
    }
  }
}
```

---

## 🎤 Wake Word Detection

### Overview

**Status**: ⏳ **NOT STARTED**

**Wake Phrase**: "Hey AutoTalk"

**Requirements**:
- Always-on listening mode
- Low power consumption (<50 mW)
- Fast detection (<500ms latency)
- High accuracy (>95%)
- Low false alarm rate (<1%)

### Recommended Solutions

#### Option 1: Porcupine (Recommended)

**Pros**:
- High accuracy
- Low CPU usage
- Cross-platform
- Custom wake word training
- Free tier available

**Cons**:
- Requires license for commercial use
- Cloud training for custom words

**Implementation**:

```python
import pvporcupine
import pyaudio
import struct

class WakeWordDetector:
    def __init__(self, keyword_path, sensitivity=0.5):
        self.porcupine = pvporcupine.create(
            access_key="YOUR_ACCESS_KEY",
            keyword_paths=[keyword_path]
        )
        
        self.audio = pyaudio.PyAudio()
        self.stream = self.audio.open(
            rate=self.porcupine.sample_rate,
            channels=1,
            format=pyaudio.paInt16,
            input=True,
            frames_per_buffer=self.porcupine.frame_length
        )
    
    def listen(self, callback):
        """Listen for wake word continuously"""
        print("Listening for 'Hey AutoTalk'...")
        
        while True:
            pcm = self.stream.read(self.porcupine.frame_length)
            pcm = struct.unpack_from("h" * self.porcupine.frame_length, pcm)
            
            keyword_index = self.porcupine.process(pcm)
            
            if keyword_index >= 0:
                print("Wake word detected!")
                callback()
    
    def cleanup(self):
        self.stream.close()
        self.audio.terminate()
        self.porcupine.delete()

# Usage
def on_wake_word():
    print("Assistant activated")
    # Start full speech recognition

detector = WakeWordDetector(keyword_path="Hey_AutoTalk.ppn")
detector.listen(on_wake_word)
```

#### Option 2: Snowboy (Alternative)

**Pros**:
- Open-source
- Custom wake word training
- Good accuracy

**Cons**:
- No longer actively maintained
- Limited to specific platforms

#### Option 3: Precise (Mycroft)

**Pros**:
- Fully open-source
- Active community
- Privacy-focused

**Cons**:
- Requires more computational resources
- Complex training process

### Integration with Qt GUI

**Workflow**:

1. Wake word detector runs in background (Python process)
2. On detection, sends signal to Qt application
3. Qt GUI activates listening state
4. Whisper transcription begins
5. After command processing, return to wake word listening

**Qt Integration**:

```cpp
// In AudioEngine class
void AudioEngine::startWakeWordMode()
{
    if (!m_wakeWordProcess) {
        m_wakeWordProcess = new QProcess(this);
        connect(m_wakeWordProcess, &QProcess::readyReadStandardOutput,
                this, &AudioEngine::handleWakeWordDetected);
    }
    
    m_wakeWordProcess->start("python3", QStringList() 
        << "backend/wake_word_detector.py");
}

void AudioEngine::handleWakeWordDetected()
{
    QString output = m_wakeWordProcess->readAllStandardOutput();
    if (output.contains("WAKE_WORD_DETECTED")) {
        emit wakeWordDetected();
        startRecording();  // Begin voice command capture
    }
}
```

### Setup Instructions

**1. Install Porcupine**:

```bash
pip install pvporcupine pyaudio
```

**2. Get Access Key**:

Register at https://console.picovoice.ai/ and copy access key.

**3. Train Custom Wake Word**:

- Go to https://console.picovoice.ai/
- Navigate to "Porcupine" → "Custom Wake Words"
- Enter phrases: "Hey AutoTalk", "Auto Talk", "Hey Car"
- Download trained model (.ppn file)

**4. Test Detection**:

```bash
python backend/wake_word_detector.py --keyword Hey_AutoTalk.ppn
```

**5. Configure Sensitivity**:

Adjust sensitivity (0.0 - 1.0):
- Higher = more sensitive, more false alarms
- Lower = less sensitive, may miss detections
- Recommended: 0.5

---

## 🧠 Conversation Context Management

### Overview

**Status**: ⏳ **NOT STARTED**

**Purpose**: Enable multi-turn conversations with memory

**Example Conversation**:

```
User: "Set temperature to 22"
Assistant: "Setting temperature to 22 degrees. Would you like me to adjust the fan speed?"

User: "Yes, level 3"  ← Context: knows we're talking about fan speed
Assistant: "Fan speed set to level 3."

User: "Actually, make it warmer"  ← Context: knows we're talking about temperature
Assistant: "Increasing temperature to 23 degrees."
```

### Architecture

```python
class DialogueState:
    def __init__(self):
        self.current_intent = None
        self.entities = {}
        self.history = []  # Last 10 turns
        self.user_preferences = {}
        self.session_id = str(uuid.uuid4())
        self.timestamp = time.time()
    
    def update(self, intent, entities, user_text, response_text):
        """Update dialogue state"""
        self.current_intent = intent
        self.entities.update(entities)
        
        self.history.append({
            "user": user_text,
            "assistant": response_text,
            "intent": intent,
            "entities": entities,
            "timestamp": time.time()
        })
        
        # Keep only last 10 turns
        if len(self.history) > 10:
            self.history.pop(0)
    
    def resolve_reference(self, text):
        """Resolve anaphora (it, that, this, etc.)"""
        if any(word in text.lower() for word in ["it", "that", "this"]):
            # Refer to previous entity
            if self.history:
                prev_entities = self.history[-1]["entities"]
                return prev_entities
        return {}
    
    def get_context_summary(self):
        """Get context for NLU"""
        return {
            "current_intent": self.current_intent,
            "active_entities": self.entities,
            "recent_topics": [h["intent"] for h in self.history[-3:]],
            "user_preferences": self.user_preferences
        }
```

### Context-Aware NLU

```python
class ContextAwareNLU:
    def __init__(self):
        self.nlu = NLUPipeline()
        self.dialogue_state = DialogueState()
    
    def process(self, text):
        """Process text with context"""
        # Get base NLU result
        result = self.nlu.process(text)
        
        # Resolve references using context
        if result["confidence"] < 0.7:
            # Low confidence - use context to help
            context = self.dialogue_state.get_context_summary()
            
            # Check if user is continuing previous topic
            if self.dialogue_state.current_intent:
                result["intent"] = self.dialogue_state.current_intent
                result["confidence"] = 0.8  # Boost confidence
        
        # Resolve entity references ("it", "that", etc.)
        resolved_entities = self.dialogue_state.resolve_reference(text)
        result["entities"].extend(resolved_entities)
        
        return result
    
    def update_context(self, intent, entities, user_text, response):
        """Update dialogue state after interaction"""
        self.dialogue_state.update(intent, entities, user_text, response)
```

### User Preferences

**Storage** (SQLite):

```sql
CREATE TABLE user_preferences (
    user_id INTEGER PRIMARY KEY,
    preferred_temperature INTEGER DEFAULT 22,
    preferred_fan_speed INTEGER DEFAULT 3,
    favorite_locations TEXT,  -- JSON array
    music_preferences TEXT,   -- JSON object
    language VARCHAR(5) DEFAULT 'en',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Usage**:

```python
class UserPreferences:
    def __init__(self, db_path="user_prefs.db"):
        self.conn = sqlite3.connect(db_path)
        self.create_tables()
    
    def get_preference(self, user_id, key):
        """Get user preference"""
        cursor = self.conn.cursor()
        cursor.execute(f"SELECT {key} FROM user_preferences WHERE user_id = ?", (user_id,))
        result = cursor.fetchone()
        return result[0] if result else None
    
    def set_preference(self, user_id, key, value):
        """Set user preference"""
        cursor = self.conn.cursor()
        cursor.execute(f"""
            INSERT INTO user_preferences (user_id, {key})
            VALUES (?, ?)
            ON CONFLICT(user_id) DO UPDATE SET {key} = ?, updated_at = CURRENT_TIMESTAMP
        """, (user_id, value, value))
        self.conn.commit()
```

---

## 🔗 Integration Points

### With Qt GUI

**Signal/Slot Connections**:

```cpp
// Connect NLU results to GUI
connect(nluEngine, &NLUEngine::intentRecognized,
        this, [](const QString &intent, double confidence) {
    qDebug() << "Intent:" << intent << "Confidence:" << confidence;
    // Update GUI to show intent
});

// Connect TTS to GUI
connect(ttsEngine, &TTSEngine::speechStarted,
        voiceResponsePanel, &VoiceResponsePanel::onSpeechStarted);

// Connect wake word detection
connect(audioEngine, &AudioEngine::wakeWordDetected,
        mainWindow, &MainWindow::activateListening);
```

### With Vehicle Systems

**CAN Bus Integration** (Future):

```python
class VehicleCommandExecutor:
    def __init__(self, can_interface="can0"):
        self.bus = can.interface.Bus(channel=can_interface, bustype='socketcan')
    
    def execute_climate_command(self, action, value):
        """Send climate control command via CAN"""
        if action == "set_temperature":
            # CAN message for HVAC system
            msg = can.Message(
                arbitration_id=0x123,
                data=[0x01, value, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00],
                is_extended_id=False
            )
            self.bus.send(msg)
```

---

## 🛠️ Setup & Configuration

### Complete Setup

**1. Install All Dependencies**:

```bash
# NLU
pip install spacy langid
python -m spacy download en_core_web_sm

# TTS
pip install pyttsx3 gTTS

# Wake Word
pip install pvporcupine pyaudio

# Context Management
pip install sqlalchemy
```

**2. Train NLU Models**:

```bash
cd backend/nlu
python train_intent_classifier.py
python train_entity_extractor.py
```

**3. Configure TTS**:

Edit `backend/tts_config.json`:
```json
{
  "engine": "pyttsx3",
  "default_voice": "en-US",
  "rate": 150,
  "volume": 0.9
}
```

**4. Setup Wake Word**:

```bash
# Download trained wake word model
cp trained_models/Hey_AutoTalk.ppn backend/

# Test
python backend/wake_word_detector.py
```

**5. Initialize Database**:

```bash
python backend/init_db.py
```

---

## 📚 Development Guide

### Adding New Intent

**1. Update Training Data**:

```json
// data/intents.json
{
  "new_intent": [
    "example utterance 1",
    "example utterance 2",
    "example utterance 3"
  ]
}
```

**2. Retrain Model**:

```bash
python train_intent_classifier.py
```

**3. Add Command Handler**:

```python
# backend/command_handlers.py
def handle_new_intent(entities):
    # Process command
    result = do_something(entities)
    return generate_response("new_intent_success", result)
```

**4. Update GUI** (if needed):

```qml
// Add new panel or update existing
```

---

## 🧪 Testing Strategy

### Unit Tests

```python
# tests/test_nlu.py
def test_intent_classification():
    nlu = NLUPipeline()
    result = nlu.process("set temperature to 22")
    assert result["intent"] == "climate_control"
    assert result["confidence"] > 0.8

def test_entity_extraction():
    nlu = NLUPipeline()
    result = nlu.process("navigate to 123 Main Street")
    assert any(e["type"] == "LOCATION" for e in result["entities"])
```

### Integration Tests

```python
# tests/test_integration.py
def test_full_conversation_flow():
    # Wake word → Recognition → NLU → Command → TTS → Response
    detector = WakeWordDetector()
    # ... test complete flow
```

### Performance Tests

- Intent classification latency: <100ms
- Entity extraction latency: <50ms
- TTS synthesis latency: <500ms
- Wake word detection latency: <300ms

---

## 🔧 Troubleshooting

### NLU Not Working

```bash
# Check model files
ls -lh models/

# Test intent classification
python -c "from nlu_pipeline import NLUPipeline; nlu = NLUPipeline(); print(nlu.process('test'))"
```

### TTS No Audio Output

```bash
# Check audio devices
aplay -l

# Test TTS directly
echo '{"action": "speak", "text": "test"}' | python backend/tts_backend.py
```

### Wake Word Not Detecting

```bash
# Test microphone
arecord -d 3 test.wav
aplay test.wav

# Check sensitivity
python backend/wake_word_detector.py --sensitivity 0.7
```

---

**Phase 3 (Voice Assistant) Status**: 🚧 **IN PROGRESS** (TTS Qt GUI: ✅ 100%, Backend: 30%)  
**Next Phase**: [Phase 3: Vehicle Integration](PHASE_3_VEHICLE_INTEGRATION.md)

---

*Last Updated: October 2024*  
*Document Version: 1.0*

