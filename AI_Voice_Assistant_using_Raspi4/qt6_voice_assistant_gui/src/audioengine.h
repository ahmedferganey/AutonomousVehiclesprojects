#ifndef AUDIOENGINE_H
#define AUDIOENGINE_H

#include <QObject>
#include <QTimer>
#include <QQueue>
#include <QAudioInput>
#include <QIODevice>
#include <QBuffer>
#include <QFile>
#include <QTemporaryFile>

// Forward declaration
class NetworkManager;

class AudioEngine : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString status READ status NOTIFY statusChanged)
    Q_PROPERTY(bool isListening READ isListening NOTIFY isListeningChanged)
    Q_PROPERTY(bool isProcessing READ isProcessing NOTIFY isProcessingChanged)
    Q_PROPERTY(float audioLevel READ audioLevel NOTIFY audioLevelChanged)
    Q_PROPERTY(QString currentTranscription READ currentTranscription NOTIFY currentTranscriptionChanged)
    Q_PROPERTY(bool backendHealthy READ backendHealthy NOTIFY backendHealthyChanged)
    Q_PROPERTY(bool useStreaming READ useStreaming WRITE setUseStreaming NOTIFY useStreamingChanged)
    
public:
    explicit AudioEngine(NetworkManager *networkManager, QObject *parent = nullptr);
    ~AudioEngine();
    
    enum Status {
        Ready,
        Listening,
        Processing,
        Error
    };
    Q_ENUM(Status)
    
    // Getters
    QString status() const { return m_statusString; }
    bool isListening() const { return m_isListening; }
    bool isProcessing() const { return m_isProcessing; }
    float audioLevel() const { return m_audioLevel; }
    QString currentTranscription() const { return m_currentTranscription; }
    bool backendHealthy() const { return m_backendHealthy; }
    bool useStreaming() const { return m_useStreaming; }
    
    // Setters
    void setUseStreaming(bool enabled);
    
public slots:
    void startListening();
    void stopListening();
    void toggleListening();
    void processAudio();
    void cancelProcessing();
    void setLanguage(const QString &language);
    
signals:
    void statusChanged();
    void isListeningChanged();
    void isProcessingChanged();
    void audioLevelChanged(float level);
    void currentTranscriptionChanged();
    void backendHealthyChanged();
    void useStreamingChanged();
    void transcriptionReceived(const QString &text, const QDateTime &timestamp, double duration, double rtf);
    void partialTranscriptionReceived(const QString &text);
    void errorOccurred(const QString &error, const QString &details);
    
private slots:
    void updateAudioLevel();
    void readAudioData();
    void handleAudioStateChanged(QAudio::State state);
    
    // NetworkManager response handlers
    void handleTranscriptionResult(const QString &text, double duration, double inferenceTime, double rtf);
    void handlePartialTranscription(const QString &text, double timestamp);
    void handleFinalTranscription(const QString &text, double timestamp);
    void handleBackendError(const QString &error, const QString &details);
    void handleBackendHealthChanged();
    void handleWebSocketConnected();
    void handleWebSocketDisconnected();
    
private:
    void setStatus(const QString &status);
    void initializeAudio();
    void startAudioCapture();
    void stopAudioCapture();
    void saveAudioToFile();
    void sendAudioToBackend();
    void calculateAudioLevel(const QByteArray &data);
    
    QString m_statusString;
    bool m_isListening;
    bool m_isProcessing;
    float m_audioLevel;
    QString m_currentTranscription;
    bool m_backendHealthy;
    bool m_useStreaming;
    QString m_language;
    
    NetworkManager *m_networkManager;
    QAudioInput *m_audioInput;
    QIODevice *m_audioInputDevice;
    QBuffer *m_audioBuffer;
    QByteArray m_audioData;
    QTemporaryFile *m_tempAudioFile;
    
    QTimer *m_audioLevelTimer;
    QTimer *m_streamingTimer;
    QQueue<float> m_audioLevelHistory;
    
    static constexpr int AUDIO_LEVEL_HISTORY_SIZE = 50;
    static constexpr int SAMPLE_RATE = 16000;
    static constexpr int CHANNELS = 1; // Mono
    static constexpr int SAMPLE_SIZE = 16; // 16-bit
    static constexpr int CHUNK_SIZE = 8192; // Bytes to send per WebSocket message
    static constexpr int STREAMING_INTERVAL_MS = 100; // Send chunks every 100ms
};

#endif // AUDIOENGINE_H

