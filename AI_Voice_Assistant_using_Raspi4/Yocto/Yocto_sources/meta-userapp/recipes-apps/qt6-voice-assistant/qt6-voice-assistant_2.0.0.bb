SUMMARY = "Qt6 Voice Assistant GUI Application - Full Feature Suite"
DESCRIPTION = "Comprehensive Qt6/QML graphical user interface for AI voice assistant with TTS, Navigation, Climate Control, Entertainment, Camera Vision, User Profiles, and Performance Dashboard"
AUTHOR = "Ahmed Ferganey <ahmed.ferganey707@gmail.com>"
HOMEPAGE = "https://github.com/ahmedferganey/ai-voice-assistant"
LICENSE = "CLOSED"
LIC_FILES_CHKSUM = ""

DEPENDS = " \
    qtbase \
    qtdeclarative \
    qtmultimedia \
    qtsvg \
    qtlocation \
    qtpositioning \
    qtcharts \
    python3 \
    python3-numpy \
    python3-sounddevice \
    python3-pyttsx3 \
"

RDEPENDS:${PN} = " \
    qtbase \
    qtdeclarative \
    qtmultimedia \
    qtsvg \
    qtquickcontrols2 \
    qtlocation \
    qtpositioning \
    qtcharts \
    python3 \
    python3-numpy \
    python3-sounddevice \
    python3-pip \
    python3-pyttsx3 \
    alsa-lib \
    alsa-utils \
"

SRC_URI = " \
    file://CMakeLists.txt \
    file://qml.qrc \
    file://voice-assistant.desktop \
    file://src/main.cpp \
    file://src/audioengine.h \
    file://src/audioengine.cpp \
    file://src/transcriptionmodel.h \
    file://src/transcriptionmodel.cpp \
    file://src/settingsmanager.h \
    file://src/settingsmanager.cpp \
    file://src/ttsengine.h \
    file://src/ttsengine.cpp \
    file://qml/main.qml \
    file://qml/MainWindow.qml \
    file://qml/MicrophoneButton.qml \
    file://qml/WaveformVisualization.qml \
    file://qml/StatusIndicator.qml \
    file://qml/TranscriptionView.qml \
    file://qml/SettingsPanel.qml \
    file://qml/HistoryView.qml \
    file://qml/VoiceResponsePanel.qml \
    file://qml/NavigationPanel.qml \
    file://qml/ClimateControlPanel.qml \
    file://qml/EntertainmentPanel.qml \
    file://qml/CameraPanel.qml \
    file://qml/UserProfilePanel.qml \
    file://qml/PerformanceDashboard.qml \
    file://backend/audio_backend.py \
    file://backend/tts_backend.py \
    file://backend/requirements.txt \
    file://resources/microphone-icon.svg \
    file://resources/settings-icon.svg \
    file://resources/history-icon.svg \
    file://resources/voice-assistant.png \
    file://tests/CMakeLists.txt \
    file://tests/test_audioengine.cpp \
    file://tests/test_transcriptionmodel.cpp \
    file://tests/test_settingsmanager.cpp \
"

S = "${WORKDIR}"

inherit qt6-cmake

# Qt6 specific configurations
EXTRA_OECMAKE += " \
    -DQT_HOST_PATH=${STAGING_DIR_NATIVE}/usr \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_TESTING=OFF \
"

# Compiler flags for optimization
TARGET_CXXFLAGS += " \
    -O2 \
    -march=armv8-a+crc \
    -mtune=cortex-a72 \
    -ftree-vectorize \
    -ffast-math \
"

do_install:append() {
    # Install Python backend
    install -d ${D}${datadir}/voice-assistant/backend
    install -m 0755 ${WORKDIR}/backend/audio_backend.py ${D}${datadir}/voice-assistant/backend/
    install -m 0755 ${WORKDIR}/backend/tts_backend.py ${D}${datadir}/voice-assistant/backend/
    install -m 0644 ${WORKDIR}/backend/requirements.txt ${D}${datadir}/voice-assistant/backend/
    
    # Create config directory
    install -d ${D}${sysconfdir}/voice-assistant
    
    # Install systemd service (optional)
    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -d ${D}${systemd_system_unitdir}
        cat > ${D}${systemd_system_unitdir}/voice-assistant.service <<EOF
[Unit]
Description=AI Voice Assistant
After=graphical.target

[Service]
Type=simple
User=root
Environment="DISPLAY=:0"
Environment="XDG_RUNTIME_DIR=/run/user/0"
ExecStart=/usr/bin/VoiceAssistant
Restart=on-failure
RestartSec=5

[Install]
WantedBy=graphical.target
EOF
    fi
}

# Package files
FILES:${PN} += " \
    ${bindir}/VoiceAssistant \
    ${datadir}/applications/voice-assistant.desktop \
    ${datadir}/icons/hicolor/256x256/apps/voice-assistant.png \
    ${datadir}/voice-assistant/backend/* \
    ${sysconfdir}/voice-assistant \
    ${systemd_system_unitdir}/voice-assistant.service \
"

# Runtime dependencies for Python packages
RDEPENDS:${PN} += " \
    python3-core \
    python3-modules \
    python3-numpy \
    python3-json \
    python3-threading \
    python3-queue \
    python3-datetime \
"

# Install Python requirements at runtime
pkg_postinst:${PN}() {
    #!/bin/sh
    if [ -n "$D" ]; then
        exit 1
    fi
    
    # Install Whisper and dependencies via pip
    echo "Installing Python dependencies..."
    pip3 install --no-cache-dir -r ${datadir}/voice-assistant/backend/requirements.txt || true
    
    echo "Qt6 Voice Assistant v2.0 installed successfully"
}

# Increase shared state cache
SSTATE_SCAN_FILES += "*.cmake"

# Enable parallel compilation
PARALLEL_MAKE = "-j ${@oe.utils.cpu_count()}"

# Add systemd integration
inherit ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'systemd', '', d)}

SYSTEMD_SERVICE:${PN} = "voice-assistant.service"
SYSTEMD_AUTO_ENABLE:${PN} = "disable"

