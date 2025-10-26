# Qt6 Voice Assistant GUI

A modern, responsive Qt6/QML graphical user interface for the AI Voice Assistant project running on Raspberry Pi 4.

## Features

### 🎨 Modern UI
- **Automotive-style interface** with sleek design
- **Dark/Light mode** support
- **Responsive layout** adapting to different screen sizes (480x320 to 1280x720+)
- **Smooth animations** and transitions

### 🎙️ Voice Visualization
- **Real-time waveform display** showing audio input
- **Audio level indicator** with percentage
- **Pulsing microphone button** with state-based colors
- **Status indicator** with LED animation

### 📝 Transcription Features
- **Live transcription display** showing current result
- **History view** with all previous transcriptions
- **Search functionality** to filter history
- **Export to file** (.txt format)
- **Delete individual or all transcriptions**

### ⚙️ Settings Panel
- **Language selection** (English, Arabic, Chinese, Spanish, French, German, Japanese, Korean)
- **Whisper model selection** (tiny, base, small, medium, large)
- **Audio device selection** from available inputs
- **Silence threshold adjustment** (0.001 - 0.1)
- **Max recording time** (10-300 seconds)
- **Dark mode toggle**
- **Reset to defaults** option

### 🎯 User Interaction
- **Touch screen support** for Raspberry Pi touchscreen
- **Keyboard shortcuts** for accessibility
- **Mouse/trackpad support** for desktop use
- **Button states**: Ready (green), Listening (blue), Processing (orange), Error (red)

## 🚀 Advanced Features (Phase 3)

### 🔊 Text-to-Speech (TTS)
- **Voice response system** with pyttsx3 integration
- **Real-time speech visualization** showing what the assistant is saying
- **Volume and speed controls** for customizable voice output
- **Multiple voice options** (male/female, different accents)
- **Queue management** for multiple speech requests
- **Word-by-word highlighting** during speech playback
- **Voice Response Panel** with animated speaking indicator

### 🗺️ Navigation System
- **Interactive map display** with OpenStreetMap integration
- **Voice-controlled navigation** ("Navigate to...", "Show nearby...")
- **Real-time route information** (distance, ETA, next turn)
- **POI search** (gas stations, restaurants, hotels, parking)
- **Quick access buttons** for frequently used searches
- **GPS position tracking** with turn-by-turn directions
- **Navigation Panel** with search and voice commands

### ❄️ Climate Control
- **Voice-controlled HVAC** ("Set temperature to 22°C", "Turn on AC")
- **Visual temperature display** with increment/decrement controls
- **Fan speed control** (0-5 levels)
- **Auto mode, A/C, heating controls**
- **Defrost and recirculation** options
- **Real-time temperature monitoring**
- **Climate Control Panel** with intuitive touch controls

### 🎵 Entertainment System
- **Voice-controlled media player** ("Play music", "Next song", "Volume up")
- **Multi-source support** (Spotify, Radio, Bluetooth, USB, Podcast)
- **Album art display** with animated playback
- **Progress bar and time display**
- **Volume control with percentage**
- **Quick access to favorites and genres**
- **Entertainment Panel** with modern media controls

### 📷 Camera & Gesture Recognition
- **Real-time camera feed** for computer vision features
- **Gesture recognition** (Thumbs up/down, OK, Palm stop, Point)
- **Driver monitoring** with drowsiness detection
- **Occupancy detection** for passenger counting
- **Visual alerts** for safety warnings
- **Privacy controls** with camera on/off toggle
- **Camera/Gesture Panel** with live detection overlays

### 👥 User Profiles & Personalization
- **Multi-user support** with individual profiles
- **Voice biometric authentication** for user identification
- **Personalized preferences** (language, temperature, seat position)
- **Usage statistics** tracking drives and commands per user
- **Quick user switching** with visual profile cards
- **Custom avatars** for each user
- **User Profiles Panel** with management interface

### 📊 Performance Dashboard
- **Real-time system monitoring** (CPU, Memory, GPU, Temperature)
- **AI performance metrics** (transcription count, accuracy, avg time)
- **Network status** (WiFi, Bluetooth, GPS signal strength)
- **Session statistics** (uptime, commands, error rate, success rate)
- **Visual progress bars** and trend indicators
- **Export functionality** for performance reports
- **Performance Dashboard** with comprehensive analytics

## Architecture

### Frontend (Qt6/QML)

**C++ Backend Classes:**
- **main.cpp**: Application entry point with context setup
- **audioengine.h/cpp**: Audio capture and processing engine
- **transcriptionmodel.h/cpp**: Transcription history data model
- **settingsmanager.h/cpp**: Settings persistence and management
- **ttsengine.h/cpp**: Text-to-speech engine integration

**Core QML Components:**
- `MainWindow.qml`: Main application layout
- `MicrophoneButton.qml`: Animated microphone control
- `WaveformVisualization.qml`: Real-time audio waveform
- `StatusIndicator.qml`: Status LED with animations
- `TranscriptionView.qml`: Current transcription display
- `SettingsPanel.qml`: Settings configuration
- `HistoryView.qml`: Transcription history with search

**Advanced QML Components:**
- `VoiceResponsePanel.qml`: TTS voice response visualization
- `NavigationPanel.qml`: Map and navigation interface
- `ClimateControlPanel.qml`: HVAC control interface
- `EntertainmentPanel.qml`: Media player controls
- `CameraGesturePanel.qml`: Computer vision and gestures
- `UserProfilesPanel.qml`: User management interface
- `PerformanceDashboard.qml`: System monitoring and analytics

### Backend (Python)
- **audio_backend.py**: Audio capture and Whisper transcription
  - Audio capture via sounddevice
  - Whisper model inference
  - JSON communication with Qt
  - Ring buffer management
  
- **tts_backend.py**: Text-to-speech synthesis
  - pyttsx3 integration
  - Voice management
  - Speech queue handling
  - Volume and rate control

## Building

### Prerequisites

**On Host (Development Machine):**
```bash
# Install Qt6 development packages
sudo apt install qt6-base-dev qt6-declarative-dev qt6-multimedia-dev cmake g++ python3

# Install Python dependencies
pip3 install -r backend/requirements.txt
```

**On Raspberry Pi (Target):**
```bash
# Qt6 and Python should already be installed via Yocto build
# If not, install manually:
sudo apt install qt6-base qt6-declarative qt6-multimedia python3-numpy python3-sounddevice
```

### Compile for Desktop (Development)

```bash
mkdir build
cd build
cmake ..
make -j$(nproc)
./VoiceAssistant
```

### Cross-Compile for Raspberry Pi

```bash
# Source Yocto SDK
source /opt/poky/4.0.24/environment-setup-cortexa72-poky-linux

# Create build directory
mkdir build-rpi
cd build-rpi

# Configure with cross-compilation
cmake \
    -DCMAKE_TOOLCHAIN_FILE=$OECORE_NATIVE_SYSROOT/usr/share/cmake/OEToolchainConfig.cmake \
    ..

# Build
make -j$(nproc)

# Deploy to Raspberry Pi
scp VoiceAssistant root@raspberrypi.local:/usr/bin/
scp -r ../backend root@raspberrypi.local:/usr/share/voice-assistant/
```

### Build with Yocto

A complete Yocto recipe is provided in the Yocto layer:

```bash
cd /path/to/poky/build
bitbake qt6-voice-assistant
```

The recipe is located at:
```
meta-userapp/recipes-apps/qt6-voice-assistant/qt6-voice-assistant_1.0.0.bb
```

## Installation

### Manual Installation on Raspberry Pi

```bash
# Copy executable
sudo cp VoiceAssistant /usr/bin/

# Copy backend
sudo mkdir -p /usr/share/voice-assistant/backend
sudo cp backend/* /usr/share/voice-assistant/backend/

# Install Python dependencies
pip3 install -r /usr/share/voice-assistant/backend/requirements.txt

# Copy desktop file
sudo cp voice-assistant.desktop /usr/share/applications/

# Copy icon (if available)
sudo cp resources/voice-assistant.png /usr/share/icons/hicolor/256x256/apps/
```

### Systemd Service (Auto-start)

Create `/etc/systemd/system/voice-assistant.service`:

```ini
[Unit]
Description=AI Voice Assistant
After=graphical.target

[Service]
Type=simple
User=ferganey
Environment="DISPLAY=:0"
Environment="XDG_RUNTIME_DIR=/run/user/1000"
ExecStart=/usr/bin/VoiceAssistant
Restart=on-failure

[Install]
WantedBy=graphical.target
```

Enable and start:
```bash
sudo systemctl enable voice-assistant
sudo systemctl start voice-assistant
```

## Usage

### Starting the Application

**From Command Line:**
```bash
VoiceAssistant
```

**From Desktop:**
Click the "AI Voice Assistant" icon in the application menu.

### Using the Interface

1. **Start Recording**:
   - Click the large microphone button
   - Or click the "Start" button
   - Status changes to "Listening" (blue)

2. **Recording**:
   - Speak clearly into the microphone
   - Watch the waveform visualization
   - Audio level shows input strength

3. **Process Audio**:
   - Click the microphone button again
   - Or click the "Process" button
   - Status changes to "Processing" (orange)

4. **View Transcription**:
   - Transcription appears in the display area
   - Automatically added to history

5. **Access History**:
   - Click the 📜 icon in the header
   - Search through past transcriptions
   - Export or delete as needed

6. **Adjust Settings**:
   - Click the ⚙️ icon in the header
   - Change language, model, audio device
   - Adjust thresholds and recording time
   - Toggle dark mode

### Keyboard Shortcuts

- `Space`: Toggle listening
- `Enter`: Process audio
- `Esc`: Cancel processing
- `Ctrl+H`: Toggle history
- `Ctrl+S`: Toggle settings

## Screen Size Optimization

The GUI automatically adapts to different screen resolutions:

### 7" Touchscreen (800x480)
- Compact layout
- Larger touch targets
- Simplified animations

### HDMI Display (1280x720)
- Standard layout
- Full feature set
- Smooth animations

### Desktop (1920x1080+)
- Expanded layout
- Additional spacing
- Enhanced visuals

## 🧪 Testing

The project includes comprehensive Qt unit tests for all core components.

### Running Tests

```bash
# Build with tests enabled
mkdir build && cd build
cmake .. -DBUILD_TESTING=ON
make

# Run all tests
ctest

# Or run test executable directly
./tests/test_voice_assistant

# Run with verbose output
ctest --verbose
```

### Test Coverage

Tests cover:
- ✅ AudioEngine initialization and state management
- ✅ TranscriptionModel data operations (add, remove, clear, export)
- ✅ SettingsManager persistence and validation
- ✅ TTSEngine voice control and volume management
- ✅ Signal/slot connections
- ✅ Data validation and bounds checking
- ✅ File I/O operations

### Writing New Tests

Add tests to `tests/test_audioengine.cpp`:

```cpp
void TestAudioEngine::testNewFeature()
{
    // Arrange - setup test data
    AudioEngine engine;
    
    // Act - perform action
    engine.startListening();
    
    // Assert - verify results
    QVERIFY(engine.isListening());
}
```

### Test Results

Expected output:
```
********* Start testing of TestAudioEngine *********
PASS   : TestAudioEngine::initTestCase()
PASS   : TestAudioEngine::testAudioEngineInitialization()
PASS   : TestAudioEngine::testStartStopListening()
PASS   : TestAudioEngine::testTranscriptionSignal()
PASS   : TestAudioEngine::testAddTranscription()
PASS   : TestAudioEngine::testSettingsPersistence()
PASS   : TestAudioEngine::testTTSInitialization()
PASS   : TestAudioEngine::cleanupTestCase()
Totals: 8 passed, 0 failed, 0 skipped
********* Finished testing of TestAudioEngine *********
```

## Troubleshooting

### Audio Not Working

```bash
# Check ALSA devices
arecord -l

# Test audio input
arecord -D hw:1,0 -d 5 test.wav

# Check permissions
sudo usermod -a -G audio $USER
```

### Python Backend Fails

```bash
# Check Python dependencies
pip3 list | grep -E "numpy|sounddevice|whisper"

# Test backend manually
python3 /usr/share/voice-assistant/backend/audio_backend.py
```

### Qt Application Crashes

```bash
# Check Qt installation
qmake -query

# Run with debug output
QT_DEBUG_PLUGINS=1 VoiceAssistant

# Check for missing libraries
ldd /usr/bin/VoiceAssistant
```

### Display Issues

```bash
# Set display variable
export DISPLAY=:0

# Check X11/Wayland
echo $XDG_SESSION_TYPE

# Test with simple Qt app
qmlscene --version
```

## Performance Optimization

### For Raspberry Pi 4

**Reduce CPU Usage:**
- Use "tiny" or "base" Whisper model
- Decrease waveform update rate
- Disable animations in settings

**Reduce Memory Usage:**
- Decrease max recording time
- Limit history size
- Close other applications

**Improve Responsiveness:**
- Use hardware acceleration
- Enable GPU rendering
- Optimize Qt build flags

## Development

### Code Structure

```
qt6_voice_assistant_gui/
├── CMakeLists.txt          # Build configuration
├── qml.qrc                 # QML resources
├── src/                    # C++ source files
│   ├── main.cpp
│   ├── audioengine.h/cpp
│   ├── transcriptionmodel.h/cpp
│   └── settingsmanager.h/cpp
├── qml/                    # QML interface files
│   ├── main.qml
│   ├── MainWindow.qml
│   ├── MicrophoneButton.qml
│   ├── WaveformVisualization.qml
│   ├── StatusIndicator.qml
│   ├── TranscriptionView.qml
│   ├── SettingsPanel.qml
│   └── HistoryView.qml
├── backend/                # Python backend
│   ├── audio_backend.py
│   └── requirements.txt
└── resources/              # Icons and images
    ├── microphone-icon.svg
    ├── settings-icon.svg
    └── history-icon.svg
```

### Adding New Features

1. **New QML Component**: Create in `qml/` directory
2. **New C++ Class**: Add to `src/` with .h and .cpp
3. **Python Backend**: Extend `audio_backend.py`
4. **Update CMakeLists.txt**: Add new source files
5. **Update qml.qrc**: Add new QML files

### Testing

```bash
# Run tests (when implemented)
ctest

# Memory leak check
valgrind --leak-check=full ./VoiceAssistant

# Performance profiling
perf record -g ./VoiceAssistant
perf report
```

## Contributing

Contributions are welcome! Please follow these guidelines:

1. Follow Qt coding standards
2. Use QML best practices
3. Test on actual Raspberry Pi hardware
4. Update documentation
5. Add comments to complex code

## License

This project is part of the AI Voice Assistant for Autonomous Vehicles.  
License: CLOSED SOURCE - All rights reserved.

## Contact

**Maintainer**: Ahmed Ferganey  
**Email**: ahmed.ferganey707@gmail.com

## Acknowledgments

- Qt Company for the Qt6 framework
- OpenAI for Whisper model
- Raspberry Pi Foundation

