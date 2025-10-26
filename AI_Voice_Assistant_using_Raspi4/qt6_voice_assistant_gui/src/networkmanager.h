#ifndef NETWORKMANAGER_H
#define NETWORKMANAGER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QWebSocket>
#include <QByteArray>
#include <QString>
#include <QJsonObject>

class NetworkManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString backendUrl READ backendUrl WRITE setBackendUrl NOTIFY backendUrlChanged)
    Q_PROPERTY(bool isConnected READ isConnected NOTIFY isConnectedChanged)
    Q_PROPERTY(bool isHealthy READ isHealthy NOTIFY isHealthyChanged)
    
public:
    explicit NetworkManager(QObject *parent = nullptr);
    ~NetworkManager();
    
    // Getters
    QString backendUrl() const { return m_backendUrl; }
    bool isConnected() const { return m_isConnected; }
    bool isHealthy() const { return m_isHealthy; }
    
    // Setters
    void setBackendUrl(const QString &url);

public slots:
    // REST API methods
    void transcribeFile(const QString &filePath, const QString &language = "en");
    void transcribeBase64(const QByteArray &audioData, const QString &language = "en");
    void checkHealth();
    void getModelInfo();
    
    // WebSocket methods
    void connectWebSocket();
    void disconnectWebSocket();
    void sendAudioChunk(const QByteArray &chunk);
    
    // Utility
    void setLanguage(const QString &language) { m_language = language; }

signals:
    // REST API signals
    void transcriptionReceived(const QString &text, double duration, double inferenceTime, double rtf);
    void healthCheckResult(bool healthy, const QString &modelName);
    void modelInfoReceived(const QJsonObject &info);
    void errorOccurred(const QString &error, const QString &details);
    void backendUrlChanged();
    void isConnectedChanged();
    void isHealthyChanged();
    
    // WebSocket signals
    void partialTranscription(const QString &text, double timestamp);
    void finalTranscription(const QString &text, double timestamp);
    void webSocketConnected();
    void webSocketDisconnected();
    void webSocketError(const QString &error);
    
    // Progress signals
    void uploadProgress(qint64 bytesSent, qint64 bytesTotal);

private slots:
    // REST API handlers
    void handleTranscribeReply();
    void handleHealthReply();
    void handleModelInfoReply();
    void handleNetworkError(QNetworkReply::NetworkError error);
    void handleUploadProgress(qint64 bytesSent, qint64 bytesTotal);
    
    // WebSocket handlers
    void onWebSocketConnected();
    void onWebSocketDisconnected();
    void onWebSocketTextMessageReceived(const QString &message);
    void onWebSocketBinaryMessageReceived(const QByteArray &message);
    void onWebSocketError(QAbstractSocket::SocketError error);
    void onWebSocketSslErrors(const QList<QSslError> &errors);

private:
    void updateConnectionStatus(bool connected);
    void updateHealthStatus(bool healthy);
    QString errorCodeToString(QNetworkReply::NetworkError error) const;
    
    QNetworkAccessManager *m_networkManager;
    QWebSocket *m_webSocket;
    QString m_backendUrl;
    QString m_language;
    bool m_isConnected;
    bool m_isHealthy;
    
    // Configuration
    static constexpr int DEFAULT_TIMEOUT_MS = 30000; // 30 seconds
    static constexpr int HEALTH_CHECK_INTERVAL_MS = 10000; // 10 seconds
};

#endif // NETWORKMANAGER_H

