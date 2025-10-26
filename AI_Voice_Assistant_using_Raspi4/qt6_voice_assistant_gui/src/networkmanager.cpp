#include "networkmanager.h"
#include <QNetworkRequest>
#include <QHttpMultiPart>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QUrl>
#include <QUrlQuery>
#include <QDebug>
#include <QTimer>

NetworkManager::NetworkManager(QObject *parent)
    : QObject(parent)
    , m_networkManager(new QNetworkAccessManager(this))
    , m_webSocket(new QWebSocket(QString(), QWebSocketProtocol::VersionLatest, this))
    , m_backendUrl("http://localhost:8000")
    , m_language("en")
    , m_isConnected(false)
    , m_isHealthy(false)
{
    qDebug() << "🌐 NetworkManager initialized with backend URL:" << m_backendUrl;
    
    // Configure network manager
    m_networkManager->setTransferTimeout(DEFAULT_TIMEOUT_MS);
    
    // Connect WebSocket signals
    connect(m_webSocket, &QWebSocket::connected, 
            this, &NetworkManager::onWebSocketConnected);
    connect(m_webSocket, &QWebSocket::disconnected, 
            this, &NetworkManager::onWebSocketDisconnected);
    connect(m_webSocket, &QWebSocket::textMessageReceived, 
            this, &NetworkManager::onWebSocketTextMessageReceived);
    connect(m_webSocket, &QWebSocket::binaryMessageReceived, 
            this, &NetworkManager::onWebSocketBinaryMessageReceived);
    connect(m_webSocket, QOverload<QAbstractSocket::SocketError>::of(&QWebSocket::error),
            this, &NetworkManager::onWebSocketError);
    
    // Start periodic health checks
    QTimer *healthCheckTimer = new QTimer(this);
    connect(healthCheckTimer, &QTimer::timeout, this, &NetworkManager::checkHealth);
    healthCheckTimer->start(HEALTH_CHECK_INTERVAL_MS);
    
    // Initial health check
    QTimer::singleShot(500, this, &NetworkManager::checkHealth);
}

NetworkManager::~NetworkManager()
{
    qDebug() << "🌐 NetworkManager destroyed";
    
    if (m_webSocket->state() == QAbstractSocket::ConnectedState) {
        m_webSocket->close();
    }
}

void NetworkManager::setBackendUrl(const QString &url)
{
    if (m_backendUrl != url) {
        m_backendUrl = url;
        qDebug() << "🌐 Backend URL changed to:" << url;
        emit backendUrlChanged();
        
        // Reconnect WebSocket if it was connected
        if (m_isConnected) {
            disconnectWebSocket();
            QTimer::singleShot(500, this, &NetworkManager::connectWebSocket);
        }
        
        // Re-check health with new URL
        checkHealth();
    }
}

// ============================================================================
// REST API Methods
// ============================================================================

void NetworkManager::transcribeFile(const QString &filePath, const QString &language)
{
    qDebug() << "🎤 Transcribing file:" << filePath << "Language:" << language;
    
    QFile *file = new QFile(filePath);
    if (!file->open(QIODevice::ReadOnly)) {
        QString error = QString("Failed to open audio file: %1").arg(filePath);
        qWarning() << "❌" << error;
        emit errorOccurred("File Error", error);
        delete file;
        return;
    }
    
    // Create multipart request
    QHttpMultiPart *multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);
    
    // Add audio file part
    QHttpPart audioPart;
    audioPart.setHeader(QNetworkRequest::ContentTypeHeader, QVariant("audio/wav"));
    audioPart.setHeader(QNetworkRequest::ContentDispositionHeader, 
                        QVariant("form-data; name=\"audio_file\"; filename=\"audio.wav\""));
    audioPart.setBodyDevice(file);
    file->setParent(multiPart); // File will be deleted with multiPart
    multiPart->append(audioPart);
    
    // Add language part
    QHttpPart languagePart;
    languagePart.setHeader(QNetworkRequest::ContentDispositionHeader, 
                           QVariant("form-data; name=\"language\""));
    languagePart.setBody(language.toUtf8());
    multiPart->append(languagePart);
    
    // Add normalize flag
    QHttpPart normalizePart;
    normalizePart.setHeader(QNetworkRequest::ContentDispositionHeader, 
                            QVariant("form-data; name=\"normalize\""));
    normalizePart.setBody("true");
    multiPart->append(normalizePart);
    
    // Add trim_silence flag
    QHttpPart trimPart;
    trimPart.setHeader(QNetworkRequest::ContentDispositionHeader, 
                       QVariant("form-data; name=\"trim_silence\""));
    trimPart.setBody("true");
    multiPart->append(trimPart);
    
    // Create request
    QUrl url(m_backendUrl + "/transcribe");
    QNetworkRequest request(url);
    request.setRawHeader("User-Agent", "Qt6VoiceAssistant/2.0");
    
    QNetworkReply *reply = m_networkManager->post(request, multiPart);
    multiPart->setParent(reply); // multiPart will be deleted with reply
    
    // Connect reply signals
    connect(reply, &QNetworkReply::finished, this, &NetworkManager::handleTranscribeReply);
    connect(reply, &QNetworkReply::errorOccurred, this, &NetworkManager::handleNetworkError);
    connect(reply, &QNetworkReply::uploadProgress, this, &NetworkManager::handleUploadProgress);
    
    qDebug() << "📤 Upload started to:" << url.toString();
}

void NetworkManager::transcribeBase64(const QByteArray &audioData, const QString &language)
{
    qDebug() << "🎤 Transcribing base64 audio, size:" << audioData.size() << "bytes, Language:" << language;
    
    // Convert audio data to base64
    QString base64Audio = QString::fromLatin1(audioData.toBase64());
    
    // Create JSON request
    QJsonObject json;
    json["audio_base64"] = base64Audio;
    json["language"] = language;
    json["task"] = "transcribe";
    
    QJsonDocument doc(json);
    QByteArray jsonData = doc.toJson(QJsonDocument::Compact);
    
    // Create request
    QUrl url(m_backendUrl + "/transcribe/base64");
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("User-Agent", "Qt6VoiceAssistant/2.0");
    
    QNetworkReply *reply = m_networkManager->post(request, jsonData);
    
    // Connect reply signals
    connect(reply, &QNetworkReply::finished, this, &NetworkManager::handleTranscribeReply);
    connect(reply, &QNetworkReply::errorOccurred, this, &NetworkManager::handleNetworkError);
    
    qDebug() << "📤 Base64 transcription request sent to:" << url.toString();
}

void NetworkManager::checkHealth()
{
    QUrl url(m_backendUrl + "/health");
    QNetworkRequest request(url);
    request.setRawHeader("User-Agent", "Qt6VoiceAssistant/2.0");
    
    QNetworkReply *reply = m_networkManager->get(request);
    
    connect(reply, &QNetworkReply::finished, this, &NetworkManager::handleHealthReply);
    
    // Don't log every health check to reduce spam
    // qDebug() << "🏥 Health check sent to:" << url.toString();
}

void NetworkManager::getModelInfo()
{
    qDebug() << "ℹ️ Requesting model info...";
    
    QUrl url(m_backendUrl + "/model/info");
    QNetworkRequest request(url);
    request.setRawHeader("User-Agent", "Qt6VoiceAssistant/2.0");
    
    QNetworkReply *reply = m_networkManager->get(request);
    
    connect(reply, &QNetworkReply::finished, this, &NetworkManager::handleModelInfoReply);
    connect(reply, &QNetworkReply::errorOccurred, this, &NetworkManager::handleNetworkError);
}

// ============================================================================
// REST API Response Handlers
// ============================================================================

void NetworkManager::handleTranscribeReply()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) return;
    
    if (reply->error() == QNetworkReply::NoError) {
        QByteArray response = reply->readAll();
        QJsonDocument jsonDoc = QJsonDocument::fromJson(response);
        
        if (!jsonDoc.isObject()) {
            qWarning() << "❌ Invalid JSON response:" << response;
            emit errorOccurred("Parse Error", "Invalid JSON response from backend");
            reply->deleteLater();
            return;
        }
        
        QJsonObject jsonObj = jsonDoc.object();
        
        QString text = jsonObj["text"].toString();
        double duration = jsonObj["duration"].toDouble();
        double inferenceTime = jsonObj["inference_time"].toDouble();
        double rtf = jsonObj["rtf"].toDouble();
        
        qDebug() << "✅ Transcription received:" << text.left(100) << "...";
        qDebug() << "⏱️ Duration:" << duration << "s, Inference:" << inferenceTime << "s, RTF:" << rtf << "x";
        
        emit transcriptionReceived(text, duration, inferenceTime, rtf);
        
    } else {
        QString errorMsg = reply->errorString();
        QString details = QString::fromUtf8(reply->readAll());
        qWarning() << "❌ Transcription failed:" << errorMsg;
        qWarning() << "   Details:" << details;
        emit errorOccurred("Transcription Error", errorMsg + "\n" + details);
    }
    
    reply->deleteLater();
}

void NetworkManager::handleHealthReply()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) return;
    
    bool wasHealthy = m_isHealthy;
    
    if (reply->error() == QNetworkReply::NoError) {
        QByteArray response = reply->readAll();
        QJsonDocument jsonDoc = QJsonDocument::fromJson(response);
        
        if (jsonDoc.isObject()) {
            QJsonObject jsonObj = jsonDoc.object();
            QString status = jsonObj["status"].toString();
            bool modelLoaded = jsonObj["model_loaded"].toBool();
            
            bool healthy = (status == "healthy" && modelLoaded);
            updateHealthStatus(healthy);
            
            if (healthy && !wasHealthy) {
                qDebug() << "✅ Backend is healthy and model is loaded";
            }
            
            emit healthCheckResult(healthy, ""); // Model name not in health response
            
        } else {
            updateHealthStatus(false);
        }
    } else {
        updateHealthStatus(false);
        
        // Only log errors on state change to reduce spam
        if (wasHealthy) {
            qWarning() << "❌ Health check failed:" << reply->errorString();
        }
    }
    
    reply->deleteLater();
}

void NetworkManager::handleModelInfoReply()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) return;
    
    if (reply->error() == QNetworkReply::NoError) {
        QByteArray response = reply->readAll();
        QJsonDocument jsonDoc = QJsonDocument::fromJson(response);
        
        if (jsonDoc.isObject()) {
            QJsonObject jsonObj = jsonDoc.object();
            
            QString modelName = jsonObj["model_name"].toString();
            QString modelPath = jsonObj["model_path"].toString();
            int sampleRate = jsonObj["sample_rate"].toInt();
            QString onnxVersion = jsonObj["onnx_runtime_version"].toString();
            int numThreads = jsonObj["num_threads"].toInt();
            
            qDebug() << "ℹ️ Model Info:";
            qDebug() << "   Name:" << modelName;
            qDebug() << "   Path:" << modelPath;
            qDebug() << "   Sample Rate:" << sampleRate << "Hz";
            qDebug() << "   ONNX Runtime:" << onnxVersion;
            qDebug() << "   Threads:" << numThreads;
            
            emit modelInfoReceived(jsonObj);
            
        } else {
            qWarning() << "❌ Invalid model info response";
            emit errorOccurred("Parse Error", "Invalid model info response");
        }
    } else {
        QString errorMsg = reply->errorString();
        qWarning() << "❌ Model info request failed:" << errorMsg;
        emit errorOccurred("Model Info Error", errorMsg);
    }
    
    reply->deleteLater();
}

void NetworkManager::handleNetworkError(QNetworkReply::NetworkError error)
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) return;
    
    QString errorMsg = errorCodeToString(error);
    QString details = reply->errorString();
    
    qWarning() << "❌ Network error:" << errorMsg << "-" << details;
    emit errorOccurred(errorMsg, details);
}

void NetworkManager::handleUploadProgress(qint64 bytesSent, qint64 bytesTotal)
{
    if (bytesTotal > 0) {
        double progress = (double)bytesSent / bytesTotal * 100.0;
        qDebug() << "📤 Upload progress:" << progress << "% (" << bytesSent << "/" << bytesTotal << "bytes)";
        emit uploadProgress(bytesSent, bytesTotal);
    }
}

// ============================================================================
// WebSocket Methods
// ============================================================================

void NetworkManager::connectWebSocket()
{
    if (m_webSocket->state() == QAbstractSocket::ConnectedState ||
        m_webSocket->state() == QAbstractSocket::ConnectingState) {
        qDebug() << "🔌 WebSocket already connected or connecting";
        return;
    }
    
    QString wsUrl = m_backendUrl;
    wsUrl.replace("http://", "ws://").replace("https://", "wss://");
    wsUrl += "/stream";
    
    qDebug() << "🔌 Connecting WebSocket to:" << wsUrl;
    m_webSocket->open(QUrl(wsUrl));
}

void NetworkManager::disconnectWebSocket()
{
    if (m_webSocket->state() == QAbstractSocket::ConnectedState) {
        qDebug() << "🔌 Disconnecting WebSocket...";
        m_webSocket->close();
    }
}

void NetworkManager::sendAudioChunk(const QByteArray &chunk)
{
    if (m_webSocket->state() == QAbstractSocket::ConnectedState) {
        qint64 bytesSent = m_webSocket->sendBinaryMessage(chunk);
        
        if (bytesSent != chunk.size()) {
            qWarning() << "⚠️ WebSocket: Not all bytes sent!" << bytesSent << "/" << chunk.size();
        }
    } else {
        qWarning() << "❌ WebSocket not connected, cannot send audio chunk";
    }
}

void NetworkManager::onWebSocketConnected()
{
    qDebug() << "✅ WebSocket connected successfully";
    updateConnectionStatus(true);
    emit webSocketConnected();
}

void NetworkManager::onWebSocketDisconnected()
{
    qDebug() << "🔌 WebSocket disconnected";
    updateConnectionStatus(false);
    emit webSocketDisconnected();
}

void NetworkManager::onWebSocketTextMessageReceived(const QString &message)
{
    // Parse JSON message
    QJsonDocument jsonDoc = QJsonDocument::fromJson(message.toUtf8());
    
    if (!jsonDoc.isObject()) {
        qWarning() << "❌ Invalid WebSocket JSON:" << message;
        return;
    }
    
    QJsonObject jsonObj = jsonDoc.object();
    QString type = jsonObj["type"].toString();
    QString text = jsonObj["text"].toString();
    double timestamp = jsonObj["timestamp"].toDouble();
    
    if (type == "partial") {
        qDebug() << "📝 Partial transcription:" << text;
        emit partialTranscription(text, timestamp);
    } else if (type == "final") {
        qDebug() << "✅ Final transcription:" << text;
        emit finalTranscription(text, timestamp);
    } else {
        qWarning() << "❓ Unknown WebSocket message type:" << type;
    }
}

void NetworkManager::onWebSocketBinaryMessageReceived(const QByteArray &message)
{
    qDebug() << "📦 Received binary WebSocket message, size:" << message.size();
    // Not expected in our protocol, but handle gracefully
}

void NetworkManager::onWebSocketError(QAbstractSocket::SocketError error)
{
    QString errorMsg = m_webSocket->errorString();
    qWarning() << "❌ WebSocket error:" << error << "-" << errorMsg;
    
    updateConnectionStatus(false);
    emit webSocketError(errorMsg);
    emit errorOccurred("WebSocket Error", errorMsg);
}

void NetworkManager::onWebSocketSslErrors(const QList<QSslError> &errors)
{
    for (const QSslError &error : errors) {
        qWarning() << "🔒 WebSocket SSL error:" << error.errorString();
    }
    
    // For development, you might want to ignore SSL errors
    // m_webSocket->ignoreSslErrors();
}

// ============================================================================
// Utility Methods
// ============================================================================

void NetworkManager::updateConnectionStatus(bool connected)
{
    if (m_isConnected != connected) {
        m_isConnected = connected;
        emit isConnectedChanged();
    }
}

void NetworkManager::updateHealthStatus(bool healthy)
{
    if (m_isHealthy != healthy) {
        m_isHealthy = healthy;
        emit isHealthyChanged();
    }
}

QString NetworkManager::errorCodeToString(QNetworkReply::NetworkError error) const
{
    switch (error) {
        case QNetworkReply::ConnectionRefusedError:
            return "Connection Refused";
        case QNetworkReply::RemoteHostClosedError:
            return "Remote Host Closed";
        case QNetworkReply::HostNotFoundError:
            return "Host Not Found";
        case QNetworkReply::TimeoutError:
            return "Timeout";
        case QNetworkReply::OperationCanceledError:
            return "Operation Canceled";
        case QNetworkReply::SslHandshakeFailedError:
            return "SSL Handshake Failed";
        case QNetworkReply::TemporaryNetworkFailureError:
            return "Temporary Network Failure";
        case QNetworkReply::NetworkSessionFailedError:
            return "Network Session Failed";
        case QNetworkReply::BackgroundRequestNotAllowedError:
            return "Background Request Not Allowed";
        case QNetworkReply::ContentNotFoundError:
            return "Content Not Found (404)";
        case QNetworkReply::ContentOperationNotPermittedError:
            return "Content Operation Not Permitted";
        case QNetworkReply::ContentAccessDenied:
            return "Content Access Denied (403)";
        case QNetworkReply::InternalServerError:
            return "Internal Server Error (500)";
        case QNetworkReply::ServiceUnavailableError:
            return "Service Unavailable (503)";
        default:
            return QString("Unknown Error (%1)").arg(error);
    }
}

