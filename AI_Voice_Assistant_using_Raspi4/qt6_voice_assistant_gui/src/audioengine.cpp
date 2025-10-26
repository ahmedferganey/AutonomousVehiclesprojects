#include "audioengine.h"
#include "networkmanager.h"
#include <QAudioFormat>
#include <QAudioDevice>
#include <QMediaDevices>
#include <QDebug>
#include <QDateTime>
#include <cmath>

AudioEngine::AudioEngine(NetworkManager *networkManager, QObject *parent)
    : QObject(parent)
    , m_statusString("Ready")
    , m_isListening(false)
    , m_isProcessing(false)
    , m_audioLevel(0.0f)
    , m_backendHealthy(false)
    , m_useStreaming(false)
    , m_language("en")
    , m_networkManager(networkManager)
    , m_audioInput(nullptr)
    , m_audioInputDevice(nullptr)
    , m_audioBuffer(new QBuffer(&m_audioData, this))
    , m_tempAudioFile(nullptr)
    , m_audioLevelTimer(new QTimer(this))
    , m_streamingTimer(new QTimer(this))
{
    qDebug() << "🎤 AudioEngine initialized";
    
    if (!m_networkManager) {
        qCritical() << "❌ NetworkManager is null!";
        return;
    }
    
    // Setup audio level update timer (60 FPS for smooth animation)
    m_audioLevelTimer->setInterval(16);
    connect(m_audioLevelTimer, &QTimer::timeout, this, &AudioEngine::updateAudioLevel);
    
    // Setup streaming timer (send audio chunks periodically)
    m_streamingTimer->setInterval(STREAMING_INTERVAL_MS);
    connect(m_streamingTimer, &QTimer::timeout, this, &AudioEngine::readAudioData);
    
    // Connect NetworkManager signals
    connect(m_networkManager, &NetworkManager::transcriptionReceived,
            this, &AudioEngine::handleTranscriptionResult);
    connect(m_networkManager, &NetworkManager::partialTranscription,
            this, &AudioEngine::handlePartialTranscription);
    connect(m_networkManager, &NetworkManager::finalTranscription,
            this, &AudioEngine::handleFinalTranscription);
    connect(m_networkManager, &NetworkManager::errorOccurred,
            this, &AudioEngine::handleBackendError);
    connect(m_networkManager, &NetworkManager::isHealthyChanged,
            this, &AudioEngine::handleBackendHealthChanged);
    connect(m_networkManager, &NetworkManager::webSocketConnected,
            this, &AudioEngine::handleWebSocketConnected);
    connect(m_networkManager, &NetworkManager::webSocketDisconnected,
            this, &AudioEngine::handleWebSocketDisconnected);
    
    // Initialize audio input
    initializeAudio();
    
    // Initial backend health status
    handleBackendHealthChanged();
}

AudioEngine::~AudioEngine()
{
    qDebug() << "🎤 AudioEngine destroyed";
    stopAudioCapture();
    
    if (m_tempAudioFile) {
        delete m_tempAudioFile;
    }
}

void AudioEngine::setUseStreaming(bool enabled)
{
    if (m_useStreaming != enabled) {
        m_useStreaming = enabled;
        qDebug() << "🎤 Streaming mode" << (enabled ? "enabled" : "disabled");
        emit useStreamingChanged();
        
        // If currently listening, restart with new mode
        if (m_isListening) {
            bool wasListening = m_isListening;
            stopListening();
            if (wasListening) {
                QTimer::singleShot(100, this, &AudioEngine::startListening);
            }
        }
    }
}

void AudioEngine::setLanguage(const QString &language)
{
    m_language = language;
    m_networkManager->setLanguage(language);
    qDebug() << "🌐 Language set to:" << language;
}

// ============================================================================
// Audio Control Methods
// ============================================================================

void AudioEngine::startListening()
{
    if (m_isListening) {
        qDebug() << "⚠️ Already listening";
        return;
    }
    
    if (!m_backendHealthy) {
        qWarning() << "❌ Backend is not healthy, cannot start listening";
        emit errorOccurred("Backend Error", "Whisper backend is not available");
        return;
    }
    
    qDebug() << "🎤 Starting to listen...";
    
    m_isListening = true;
    setStatus("Listening");
    
    // Clear previous audio data
    m_audioData.clear();
    
    // Start audio capture
    startAudioCapture();
    
    // Start audio level monitoring
    m_audioLevelTimer->start();
    
    // If streaming mode, connect WebSocket
    if (m_useStreaming) {
        m_networkManager->connectWebSocket();
    }
    
    emit isListeningChanged();
}

void AudioEngine::stopListening()
{
    if (!m_isListening) {
        qDebug() << "⚠️ Not listening";
        return;
    }
    
    qDebug() << "🎤 Stopping listening...";
    
    m_isListening = false;
    setStatus("Ready");
    
    // Stop audio capture
    stopAudioCapture();
    
    // Stop timers
    m_audioLevelTimer->stop();
    m_streamingTimer->stop();
    
    // Reset audio level
    m_audioLevel = 0.0f;
    emit audioLevelChanged(0.0f);
    
    // Disconnect WebSocket if streaming
    if (m_useStreaming) {
        m_networkManager->disconnectWebSocket();
    }
    
    emit isListeningChanged();
}

void AudioEngine::toggleListening()
{
    if (m_isListening) {
        stopListening();
    } else {
        startListening();
    }
}

void AudioEngine::processAudio()
{
    if (!m_isListening || m_isProcessing) {
        qWarning() << "⚠️ Cannot process audio: listening=" << m_isListening << "processing=" << m_isProcessing;
        return;
    }
    
    if (m_audioData.isEmpty()) {
        qWarning() << "⚠️ No audio data to process";
        emit errorOccurred("No Audio", "No audio data captured");
        return;
    }
    
    qDebug() << "🎤 Processing audio..." << m_audioData.size() << "bytes";
    
    m_isProcessing = true;
    m_isListening = false;
    setStatus("Processing");
    
    // Stop audio capture
    stopAudioCapture();
    m_audioLevelTimer->stop();
    
    emit isListeningChanged();
    emit isProcessingChanged();
    
    // Send audio to backend
    sendAudioToBackend();
}

void AudioEngine::cancelProcessing()
{
    if (!m_isProcessing) {
        return;
    }
    
    qDebug() << "🎤 Canceling processing...";
    
    m_isProcessing = false;
    setStatus("Ready");
    
    emit isProcessingChanged();
}

// ============================================================================
// Audio Initialization and Capture
// ============================================================================

void AudioEngine::initializeAudio()
{
    qDebug() << "🎤 Initializing audio input...";
    
    // Setup audio format (16kHz, Mono, 16-bit PCM - Whisper's expected format)
    QAudioFormat format;
    format.setSampleRate(SAMPLE_RATE);
    format.setChannelCount(CHANNELS);
    format.setSampleFormat(QAudioFormat::Int16);
    
    // Get default audio input device
    QAudioDevice audioDevice = QMediaDevices::defaultAudioInput();
    
    if (audioDevice.isNull()) {
        qCritical() << "❌ No audio input device found!";
        setStatus("Error");
        emit errorOccurred("Audio Error", "No microphone detected");
        return;
    }
    
    qDebug() << "🎤 Using audio device:" << audioDevice.description();
    
    // Check if format is supported
    if (!audioDevice.isFormatSupported(format)) {
        qWarning() << "⚠️ Requested audio format not supported, trying to find nearest...";
        format = audioDevice.preferredFormat();
        qDebug() << "   Using format: Sample Rate:" << format.sampleRate() 
                 << "Channels:" << format.channelCount();
    }
    
    // Create audio input
    m_audioInput = new QAudioInput(audioDevice, format, this);
    
    // Connect state changed signal
    connect(m_audioInput, &QAudioInput::stateChanged,
            this, &AudioEngine::handleAudioStateChanged);
    
    qDebug() << "✅ Audio input initialized successfully";
}

void AudioEngine::startAudioCapture()
{
    if (!m_audioInput) {
        qCritical() << "❌ Audio input not initialized!";
        return;
    }
    
    qDebug() << "🎤 Starting audio capture...";
    
    // Open buffer for writing
    m_audioBuffer->open(QIODevice::WriteOnly);
    
    // Start audio input
    m_audioInputDevice = m_audioInput->start();
    
    if (!m_audioInputDevice) {
        qCritical() << "❌ Failed to start audio input!";
        setStatus("Error");
        emit errorOccurred("Audio Error", "Failed to start microphone");
        return;
    }
    
    // Connect readyRead signal for reading audio data
    connect(m_audioInputDevice, &QIODevice::readyRead,
            this, &AudioEngine::readAudioData);
    
    // If streaming mode, start streaming timer
    if (m_useStreaming) {
        m_streamingTimer->start();
    }
    
    qDebug() << "✅ Audio capture started";
}

void AudioEngine::stopAudioCapture()
{
    if (!m_audioInput) {
        return;
    }
    
    qDebug() << "🎤 Stopping audio capture...";
    
    // Stop streaming timer
    m_streamingTimer->stop();
    
    // Stop audio input
    m_audioInput->stop();
    
    // Close buffer
    if (m_audioBuffer->isOpen()) {
        m_audioBuffer->close();
    }
    
    // Disconnect audio device signals
    if (m_audioInputDevice) {
        disconnect(m_audioInputDevice, nullptr, this, nullptr);
        m_audioInputDevice = nullptr;
    }
    
    qDebug() << "✅ Audio capture stopped, captured" << m_audioData.size() << "bytes";
}

void AudioEngine::readAudioData()
{
    if (!m_audioInputDevice) {
        return;
    }
    
    // Read available audio data
    QByteArray newData = m_audioInputDevice->readAll();
    
    if (newData.isEmpty()) {
        return;
    }
    
    // Append to buffer
    m_audioData.append(newData);
    
    // Calculate audio level for visualization
    calculateAudioLevel(newData);
    
    // If streaming mode, send chunk to backend
    if (m_useStreaming && m_networkManager->isConnected()) {
        // Send the new data as a chunk
        if (newData.size() >= CHUNK_SIZE) {
            m_networkManager->sendAudioChunk(newData);
        }
    }
    
    // Log progress every 1 second of audio
    static qint64 lastLogSize = 0;
    if (m_audioData.size() - lastLogSize > SAMPLE_RATE * CHANNELS * 2) {
        double duration = (double)m_audioData.size() / (SAMPLE_RATE * CHANNELS * 2);
        qDebug() << "📊 Captured" << duration << "seconds of audio (" << m_audioData.size() << "bytes)";
        lastLogSize = m_audioData.size();
    }
}

void AudioEngine::handleAudioStateChanged(QAudio::State state)
{
    switch (state) {
        case QAudio::ActiveState:
            qDebug() << "🎤 Audio state: Active";
            break;
        case QAudio::SuspendedState:
            qDebug() << "🎤 Audio state: Suspended";
            break;
        case QAudio::StoppedState:
            qDebug() << "🎤 Audio state: Stopped";
            break;
        case QAudio::IdleState:
            qDebug() << "🎤 Audio state: Idle";
            break;
    }
    
    // Handle errors
    if (state == QAudio::StoppedState && m_audioInput && m_audioInput->error() != QAudio::NoError) {
        QString errorMsg = QString("Audio input error: %1").arg(m_audioInput->error());
        qWarning() << "❌" << errorMsg;
        emit errorOccurred("Audio Error", errorMsg);
        setStatus("Error");
    }
}

// ============================================================================
// Audio Processing
// ============================================================================

void AudioEngine::calculateAudioLevel(const QByteArray &data)
{
    if (data.isEmpty()) {
        return;
    }
    
    // Calculate RMS (Root Mean Square) level
    const int16_t *samples = reinterpret_cast<const int16_t*>(data.constData());
    int sampleCount = data.size() / sizeof(int16_t);
    
    double sum = 0.0;
    for (int i = 0; i < sampleCount; ++i) {
        double sample = samples[i] / 32768.0; // Normalize to [-1, 1]
        sum += sample * sample;
    }
    
    double rms = std::sqrt(sum / sampleCount);
    
    // Add to history for smoothing
    m_audioLevelHistory.enqueue(rms);
    if (m_audioLevelHistory.size() > AUDIO_LEVEL_HISTORY_SIZE) {
        m_audioLevelHistory.dequeue();
    }
    
    // Calculate smoothed level
    double smoothedLevel = 0.0;
    for (float level : m_audioLevelHistory) {
        smoothedLevel += level;
    }
    smoothedLevel /= m_audioLevelHistory.size();
    
    // Update if changed significantly
    if (std::abs(smoothedLevel - m_audioLevel) > 0.01) {
        m_audioLevel = smoothedLevel;
        emit audioLevelChanged(m_audioLevel);
    }
}

void AudioEngine::updateAudioLevel()
{
    // This timer is kept for compatibility, but actual level calculation
    // is now done in calculateAudioLevel() when data arrives
}

void AudioEngine::saveAudioToFile()
{
    // Create temporary WAV file
    if (m_tempAudioFile) {
        delete m_tempAudioFile;
    }
    
    m_tempAudioFile = new QTemporaryFile(QDir::tempPath() + "/voice_XXXXXX.wav", this);
    
    if (!m_tempAudioFile->open()) {
        qWarning() << "❌ Failed to create temporary audio file";
        emit errorOccurred("File Error", "Failed to create temporary audio file");
        return;
    }
    
    // Write WAV header
    QDataStream stream(m_tempAudioFile);
    stream.setByteOrder(QDataStream::LittleEndian);
    
    // RIFF header
    stream.writeRawData("RIFF", 4);
    quint32 fileSize = 36 + m_audioData.size();
    stream << fileSize;
    stream.writeRawData("WAVE", 4);
    
    // fmt chunk
    stream.writeRawData("fmt ", 4);
    quint32 fmtSize = 16;
    stream << fmtSize;
    quint16 audioFormat = 1; // PCM
    stream << audioFormat;
    quint16 numChannels = CHANNELS;
    stream << numChannels;
    quint32 sampleRate = SAMPLE_RATE;
    stream << sampleRate;
    quint32 byteRate = SAMPLE_RATE * CHANNELS * SAMPLE_SIZE / 8;
    stream << byteRate;
    quint16 blockAlign = CHANNELS * SAMPLE_SIZE / 8;
    stream << blockAlign;
    quint16 bitsPerSample = SAMPLE_SIZE;
    stream << bitsPerSample;
    
    // data chunk
    stream.writeRawData("data", 4);
    quint32 dataSize = m_audioData.size();
    stream << dataSize;
    stream.writeRawData(m_audioData.constData(), m_audioData.size());
    
    m_tempAudioFile->flush();
    
    qDebug() << "💾 Audio saved to temporary file:" << m_tempAudioFile->fileName();
}

void AudioEngine::sendAudioToBackend()
{
    if (m_useStreaming) {
        // In streaming mode, we've already sent the data via WebSocket
        // Just wait for final transcription
        qDebug() << "📡 Streaming mode: waiting for final transcription...";
    } else {
        // File upload mode: save to file and send via REST API
        saveAudioToFile();
        
        if (!m_tempAudioFile) {
            qWarning() << "❌ No audio file to send";
            m_isProcessing = false;
            setStatus("Error");
            emit isProcessingChanged();
            return;
        }
        
        qDebug() << "📤 Sending audio file to backend...";
        m_networkManager->transcribeFile(m_tempAudioFile->fileName(), m_language);
    }
}

// ============================================================================
// NetworkManager Response Handlers
// ============================================================================

void AudioEngine::handleTranscriptionResult(const QString &text, double duration, double inferenceTime, double rtf)
{
    qDebug() << "✅ Transcription received:" << text;
    qDebug() << "⏱️ Duration:" << duration << "s, Inference:" << inferenceTime << "s, RTF:" << rtf << "x";
    
    m_currentTranscription = text;
    emit currentTranscriptionChanged();
    emit transcriptionReceived(text, QDateTime::currentDateTime(), duration, rtf);
    
    // Processing complete
    m_isProcessing = false;
    setStatus("Ready");
    emit isProcessingChanged();
}

void AudioEngine::handlePartialTranscription(const QString &text, double timestamp)
{
    qDebug() << "📝 Partial transcription:" << text;
    
    m_currentTranscription = text;
    emit currentTranscriptionChanged();
    emit partialTranscriptionReceived(text);
}

void AudioEngine::handleFinalTranscription(const QString &text, double timestamp)
{
    qDebug() << "✅ Final transcription:" << text;
    
    m_currentTranscription = text;
    emit currentTranscriptionChanged();
    emit transcriptionReceived(text, QDateTime::currentDateTime(), 0.0, 0.0);
    
    // Processing complete
    m_isProcessing = false;
    setStatus("Ready");
    emit isProcessingChanged();
}

void AudioEngine::handleBackendError(const QString &error, const QString &details)
{
    qWarning() << "❌ Backend error:" << error << "-" << details;
    
    // Forward error
    emit errorOccurred(error, details);
    
    // Stop processing if active
    if (m_isProcessing) {
        m_isProcessing = false;
        setStatus("Error");
        emit isProcessingChanged();
    }
}

void AudioEngine::handleBackendHealthChanged()
{
    bool wasHealthy = m_backendHealthy;
    m_backendHealthy = m_networkManager->isHealthy();
    
    if (m_backendHealthy != wasHealthy) {
        qDebug() << "🏥 Backend health changed:" << (m_backendHealthy ? "Healthy" : "Unhealthy");
        emit backendHealthyChanged();
        
        // If backend became unhealthy while listening, stop
        if (!m_backendHealthy && m_isListening) {
            stopListening();
            emit errorOccurred("Backend Unavailable", "Whisper backend is not responding");
        }
    }
}

void AudioEngine::handleWebSocketConnected()
{
    qDebug() << "🔌 WebSocket connected, streaming mode active";
}

void AudioEngine::handleWebSocketDisconnected()
{
    qDebug() << "🔌 WebSocket disconnected";
    
    // If we were listening, this is an error
    if (m_isListening) {
        qWarning() << "⚠️ WebSocket disconnected while listening!";
        stopListening();
        emit errorOccurred("Connection Lost", "WebSocket connection to backend was lost");
    }
}

// ============================================================================
// Utility Methods
// ============================================================================

void AudioEngine::setStatus(const QString &status)
{
    if (m_statusString != status) {
        m_statusString = status;
        emit statusChanged();
    }
}

