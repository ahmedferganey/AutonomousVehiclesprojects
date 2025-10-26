#include "ttsengine.h"
#include <QDebug>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

TTSEngine::TTSEngine(QObject *parent)
    : QObject(parent)
    , m_isSpeaking(false)
    , m_volume(1.0f)
    , m_rate(1.0f)
    , m_voice("default")
    , m_enabled(true)
    , m_ttsProcess(new QProcess(this))
    , m_isProcessing(false)
{
    // Setup TTS process
    connect(m_ttsProcess, &QProcess::readyReadStandardOutput,
            this, &TTSEngine::handleTTSOutput);
    connect(m_ttsProcess, &QProcess::readyReadStandardError,
            this, &TTSEngine::handleTTSError);
    connect(m_ttsProcess, QOverload<int>::of(&QProcess::finished),
            this, &TTSEngine::handleTTSFinished);
    
    // Start TTS backend
    startTTSProcess();
}

TTSEngine::~TTSEngine()
{
    if (m_ttsProcess->state() == QProcess::Running) {
        sendCommandToTTS("QUIT", QVariantMap());
        m_ttsProcess->waitForFinished(2000);
        m_ttsProcess->kill();
    }
}

void TTSEngine::setVolume(float volume)
{
    if (qAbs(m_volume - volume) > 0.01f) {
        m_volume = qBound(0.0f, volume, 1.0f);
        emit volumeChanged();
        
        QVariantMap params;
        params["volume"] = m_volume;
        sendCommandToTTS("SET_VOLUME", params);
    }
}

void TTSEngine::setRate(float rate)
{
    if (qAbs(m_rate - rate) > 0.01f) {
        m_rate = qBound(0.5f, rate, 2.0f);
        emit rateChanged();
        
        QVariantMap params;
        params["rate"] = m_rate;
        sendCommandToTTS("SET_RATE", params);
    }
}

void TTSEngine::setVoice(const QString &voice)
{
    if (m_voice != voice) {
        m_voice = voice;
        emit voiceChanged();
        
        QVariantMap params;
        params["voice"] = m_voice;
        sendCommandToTTS("SET_VOICE", params);
    }
}

void TTSEngine::setEnabled(bool enabled)
{
    if (m_enabled != enabled) {
        m_enabled = enabled;
        emit enabledChanged();
        
        if (!enabled) {
            stop();
            clearQueue();
        }
    }
}

void TTSEngine::speak(const QString &text)
{
    if (!m_enabled || text.trimmed().isEmpty())
        return;
    
    if (m_isSpeaking) {
        stop();
    }
    
    m_currentText = text;
    m_isSpeaking = true;
    emit currentTextChanged();
    emit isSpeakingChanged();
    emit speechStarted(text);
    
    QVariantMap params;
    params["text"] = text;
    sendCommandToTTS("SPEAK", params);
}

void TTSEngine::speakAsync(const QString &text)
{
    if (!m_enabled || text.trimmed().isEmpty())
        return;
    
    m_speechQueue.enqueue(text);
    
    if (!m_isProcessing) {
        processQueue();
    }
}

void TTSEngine::stop()
{
    if (!m_isSpeaking)
        return;
    
    sendCommandToTTS("STOP", QVariantMap());
    
    m_isSpeaking = false;
    m_currentText.clear();
    emit isSpeakingChanged();
    emit currentTextChanged();
    emit speechFinished();
}

void TTSEngine::pause()
{
    if (m_isSpeaking) {
        sendCommandToTTS("PAUSE", QVariantMap());
    }
}

void TTSEngine::resume()
{
    if (m_isSpeaking) {
        sendCommandToTTS("RESUME", QVariantMap());
    }
}

void TTSEngine::clearQueue()
{
    m_speechQueue.clear();
}

QStringList TTSEngine::getAvailableVoices()
{
    // This would be populated from TTS backend
    return QStringList{
        "default",
        "male-en-us",
        "female-en-us",
        "male-en-gb",
        "female-en-gb"
    };
}

void TTSEngine::handleTTSOutput()
{
    QByteArray data = m_ttsProcess->readAllStandardOutput();
    QString output = QString::fromUtf8(data).trimmed();
    
    if (output.isEmpty())
        return;
    
    qDebug() << "TTS output:" << output;
    
    // Parse JSON response
    QJsonDocument doc = QJsonDocument::fromJson(output.toUtf8());
    if (!doc.isObject())
        return;
    
    QJsonObject obj = doc.object();
    QString type = obj["type"].toString();
    
    if (type == "speech_started") {
        // TTS confirmed speech started
    }
    else if (type == "speech_finished") {
        m_isSpeaking = false;
        m_currentText.clear();
        emit isSpeakingChanged();
        emit currentTextChanged();
        emit speechFinished();
        
        // Process next in queue
        if (!m_speechQueue.isEmpty()) {
            processQueue();
        }
    }
    else if (type == "word_boundary") {
        QString word = obj["word"].toString();
        int position = obj["position"].toInt();
        emit wordSpoken(word, position);
    }
    else if (type == "error") {
        QString errorMsg = obj["message"].toString();
        emit speechError(errorMsg);
        
        m_isSpeaking = false;
        emit isSpeakingChanged();
    }
}

void TTSEngine::handleTTSError()
{
    QString error = QString::fromUtf8(m_ttsProcess->readAllStandardError());
    qWarning() << "TTS error:" << error;
    emit speechError(error);
}

void TTSEngine::handleTTSFinished(int exitCode)
{
    qDebug() << "TTS process finished with exit code:" << exitCode;
    
    if (exitCode != 0) {
        emit speechError("TTS backend crashed");
    }
    
    // Restart TTS backend
    QTimer::singleShot(1000, this, &TTSEngine::startTTSProcess);
}

void TTSEngine::processQueue()
{
    if (m_speechQueue.isEmpty() || m_isProcessing)
        return;
    
    m_isProcessing = true;
    QString text = m_speechQueue.dequeue();
    
    m_currentText = text;
    m_isSpeaking = true;
    emit currentTextChanged();
    emit isSpeakingChanged();
    emit speechStarted(text);
    
    QVariantMap params;
    params["text"] = text;
    sendCommandToTTS("SPEAK", params);
}

void TTSEngine::startTTSProcess()
{
    // Start Python TTS backend
    QString pythonScript = "/usr/share/voice-assistant/backend/tts_backend.py";
    
    QStringList arguments;
    arguments << pythonScript;
    
    m_ttsProcess->start("python3", arguments);
    
    if (!m_ttsProcess->waitForStarted(3000)) {
        qWarning() << "Failed to start TTS backend";
        emit speechError("Failed to start TTS backend");
    } else {
        qDebug() << "TTS backend started successfully";
    }
}

void TTSEngine::sendCommandToTTS(const QString &command, const QVariantMap &params)
{
    if (m_ttsProcess->state() != QProcess::Running) {
        qWarning() << "TTS process not running, cannot send command:" << command;
        return;
    }
    
    QJsonObject obj;
    obj["command"] = command;
    
    for (auto it = params.begin(); it != params.end(); ++it) {
        obj[it.key()] = QJsonValue::fromVariant(it.value());
    }
    
    QJsonDocument doc(obj);
    QString jsonStr = doc.toJson(QJsonDocument::Compact);
    
    m_ttsProcess->write(jsonStr.toUtf8() + "\n");
    m_ttsProcess->waitForBytesWritten();
}

