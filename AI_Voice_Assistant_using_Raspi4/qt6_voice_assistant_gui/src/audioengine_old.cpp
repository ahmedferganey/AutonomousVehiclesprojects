#include "audioengine.h"
#include <QDebug>
#include <QJsonDocument>
#include <QJsonObject>
#include <QDateTime>
#include <cmath>

AudioEngine::AudioEngine(QObject *parent)
    : QObject(parent)
    , m_statusString("Ready")
    , m_isListening(false)
    , m_isProcessing(false)
    , m_audioLevel(0.0f)
    , m_audioLevelTimer(new QTimer(this))
    , m_pythonProcess(new QProcess(this))
{
    // Setup audio level update timer (60 FPS for smooth animation)
    m_audioLevelTimer->setInterval(16);
    connect(m_audioLevelTimer, &QTimer::timeout, this, &AudioEngine::updateAudioLevel);
    
    // Setup Python process
    connect(m_pythonProcess, &QProcess::readyReadStandardOutput,
            this, &AudioEngine::handlePythonOutput);
    connect(m_pythonProcess, &QProcess::readyReadStandardError,
            this, &AudioEngine::handlePythonError);
    connect(m_pythonProcess, QOverload<int>::of(&QProcess::finished),
            this, &AudioEngine::handlePythonFinished);
    
    // Start Python backend
    startPythonBackend();
}

AudioEngine::~AudioEngine()
{
    stopPythonBackend();
}

void AudioEngine::startListening()
{
    if (m_isListening)
        return;
    
    m_isListening = true;
    setStatus("Listening");
    m_audioLevelTimer->start();
    
    // Send command to Python backend
    sendCommandToPython("START_LISTENING");
    
    emit isListeningChanged();
}

void AudioEngine::stopListening()
{
    if (!m_isListening)
        return;
    
    m_isListening = false;
    setStatus("Ready");
    m_audioLevelTimer->stop();
    m_audioLevel = 0.0f;
    
    // Send command to Python backend
    sendCommandToPython("STOP_LISTENING");
    
    emit isListeningChanged();
    emit audioLevelChanged(0.0f);
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
    if (!m_isListening || m_isProcessing)
        return;
    
    m_isProcessing = true;
    m_isListening = false;
    setStatus("Processing");
    
    // Send command to Python backend to process captured audio
    sendCommandToPython("PROCESS_AUDIO");
    
    emit isListeningChanged();
    emit isProcessingChanged();
}

void AudioEngine::cancelProcessing()
{
    if (!m_isProcessing)
        return;
    
    m_isProcessing = false;
    setStatus("Ready");
    
    sendCommandToPython("CANCEL_PROCESSING");
    
    emit isProcessingChanged();
}

void AudioEngine::updateAudioLevel()
{
    // Simulate audio level (in real implementation, get from Python backend)
    // Generate smooth waveform using sine wave + noise
    static float phase = 0.0f;
    phase += 0.1f;
    
    float baseLevel = 0.3f + 0.3f * std::sin(phase);
    float noise = (float)(qrand() % 100) / 500.0f;
    float newLevel = baseLevel + noise;
    
    // Clamp to [0, 1]
    newLevel = qMax(0.0f, qMin(1.0f, newLevel));
    
    // Add to history for smoothing
    m_audioLevelHistory.enqueue(newLevel);
    if (m_audioLevelHistory.size() > AUDIO_LEVEL_HISTORY_SIZE)
        m_audioLevelHistory.dequeue();
    
    // Calculate smoothed level
    float smoothedLevel = 0.0f;
    for (float level : m_audioLevelHistory)
        smoothedLevel += level;
    smoothedLevel /= m_audioLevelHistory.size();
    
    if (std::abs(smoothedLevel - m_audioLevel) > 0.01f) {
        m_audioLevel = smoothedLevel;
        emit audioLevelChanged(m_audioLevel);
    }
}

void AudioEngine::handlePythonOutput()
{
    QByteArray data = m_pythonProcess->readAllStandardOutput();
    QString output = QString::fromUtf8(data).trimmed();
    
    if (output.isEmpty())
        return;
    
    qDebug() << "Python output:" << output;
    
    // Parse JSON response
    QJsonDocument doc = QJsonDocument::fromJson(output.toUtf8());
    if (!doc.isObject())
        return;
    
    QJsonObject obj = doc.object();
    QString type = obj["type"].toString();
    
    if (type == "transcription") {
        QString text = obj["text"].toString();
        m_currentTranscription = text;
        emit currentTranscriptionChanged();
        emit transcriptionReceived(text, QDateTime::currentDateTime());
        
        m_isProcessing = false;
        setStatus("Ready");
        emit isProcessingChanged();
    }
    else if (type == "audio_level") {
        float level = obj["level"].toDouble(0.0);
        m_audioLevel = level;
        emit audioLevelChanged(level);
    }
    else if (type == "error") {
        QString errorMsg = obj["message"].toString();
        emit errorOccurred(errorMsg);
        
        m_isProcessing = false;
        m_isListening = false;
        setStatus("Error");
        emit isProcessingChanged();
        emit isListeningChanged();
    }
}

void AudioEngine::handlePythonError()
{
    QString error = QString::fromUtf8(m_pythonProcess->readAllStandardError());
    qWarning() << "Python error:" << error;
    emit errorOccurred(error);
}

void AudioEngine::handlePythonFinished(int exitCode)
{
    qDebug() << "Python process finished with exit code:" << exitCode;
    
    if (exitCode != 0) {
        emit errorOccurred("Python backend crashed");
        setStatus("Error");
    }
    
    // Restart Python backend
    QTimer::singleShot(1000, this, &AudioEngine::startPythonBackend);
}

void AudioEngine::setStatus(const QString &status)
{
    if (m_statusString != status) {
        m_statusString = status;
        emit statusChanged();
    }
}

void AudioEngine::startPythonBackend()
{
    // Start Python backend script
    QString pythonScript = "/usr/share/voice-assistant/backend/audio_backend.py";
    
    QStringList arguments;
    arguments << pythonScript;
    
    m_pythonProcess->start("python3", arguments);
    
    if (!m_pythonProcess->waitForStarted(3000)) {
        qWarning() << "Failed to start Python backend";
        emit errorOccurred("Failed to start audio backend");
    } else {
        qDebug() << "Python backend started successfully";
    }
}

void AudioEngine::stopPythonBackend()
{
    if (m_pythonProcess->state() == QProcess::Running) {
        sendCommandToPython("QUIT");
        m_pythonProcess->waitForFinished(2000);
        m_pythonProcess->kill();
    }
}

void AudioEngine::sendCommandToPython(const QString &command)
{
    if (m_pythonProcess->state() != QProcess::Running) {
        qWarning() << "Python process not running, cannot send command:" << command;
        return;
    }
    
    QJsonObject obj;
    obj["command"] = command;
    
    QJsonDocument doc(obj);
    QString jsonStr = doc.toJson(QJsonDocument::Compact);
    
    m_pythonProcess->write(jsonStr.toUtf8() + "\n");
    m_pythonProcess->waitForBytesWritten();
}

