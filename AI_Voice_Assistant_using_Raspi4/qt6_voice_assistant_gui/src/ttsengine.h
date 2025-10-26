#ifndef TTSENGINE_H
#define TTSENGINE_H

#include <QObject>
#include <QProcess>
#include <QString>
#include <QQueue>

/**
 * @brief Text-to-Speech Engine for voice responses
 * 
 * Integrates with pyttsx3, gTTS, or Festival for voice synthesis
 * Provides queue management for multiple speech requests
 */
class TTSEngine : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isSpeaking READ isSpeaking NOTIFY isSpeakingChanged)
    Q_PROPERTY(QString currentText READ currentText NOTIFY currentTextChanged)
    Q_PROPERTY(float volume READ volume WRITE setVolume NOTIFY volumeChanged)
    Q_PROPERTY(float rate READ rate WRITE setRate NOTIFY rateChanged)
    Q_PROPERTY(QString voice READ voice WRITE setVoice NOTIFY voiceChanged)
    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)
    
public:
    explicit TTSEngine(QObject *parent = nullptr);
    ~TTSEngine();
    
    // Getters
    bool isSpeaking() const { return m_isSpeaking; }
    QString currentText() const { return m_currentText; }
    float volume() const { return m_volume; }
    float rate() const { return m_rate; }
    QString voice() const { return m_voice; }
    bool enabled() const { return m_enabled; }
    
    // Setters
    void setVolume(float volume);
    void setRate(float rate);
    void setVoice(const QString &voice);
    void setEnabled(bool enabled);
    
public slots:
    void speak(const QString &text);
    void speakAsync(const QString &text); // Non-blocking
    void stop();
    void pause();
    void resume();
    void clearQueue();
    QStringList getAvailableVoices();
    
signals:
    void isSpeakingChanged();
    void currentTextChanged();
    void volumeChanged();
    void rateChanged();
    void voiceChanged();
    void enabledChanged();
    void speechStarted(const QString &text);
    void speechFinished();
    void speechError(const QString &error);
    void wordSpoken(const QString &word, int position);
    
private slots:
    void handleTTSOutput();
    void handleTTSError();
    void handleTTSFinished(int exitCode);
    void processQueue();
    
private:
    void startTTSProcess();
    void sendCommandToTTS(const QString &command, const QVariantMap &params);
    
    bool m_isSpeaking;
    QString m_currentText;
    float m_volume;
    float m_rate;
    QString m_voice;
    bool m_enabled;
    
    QProcess *m_ttsProcess;
    QQueue<QString> m_speechQueue;
    bool m_isProcessing;
};

#endif // TTSENGINE_H

