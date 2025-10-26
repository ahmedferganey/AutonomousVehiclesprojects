#ifndef AUDIOENGINE_H
#define AUDIOENGINE_H

#include <QObject>
#include <QTimer>
#include <QProcess>
#include <QQueue>

class AudioEngine : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString status READ status NOTIFY statusChanged)
    Q_PROPERTY(bool isListening READ isListening NOTIFY isListeningChanged)
    Q_PROPERTY(bool isProcessing READ isProcessing NOTIFY isProcessingChanged)
    Q_PROPERTY(float audioLevel READ audioLevel NOTIFY audioLevelChanged)
    Q_PROPERTY(QString currentTranscription READ currentTranscription NOTIFY currentTranscriptionChanged)
    
public:
    explicit AudioEngine(QObject *parent = nullptr);
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
    
public slots:
    void startListening();
    void stopListening();
    void toggleListening();
    void processAudio();
    void cancelProcessing();
    
signals:
    void statusChanged();
    void isListeningChanged();
    void isProcessingChanged();
    void audioLevelChanged(float level);
    void currentTranscriptionChanged();
    void transcriptionReceived(const QString &text, const QDateTime &timestamp);
    void errorOccurred(const QString &error);
    
private slots:
    void updateAudioLevel();
    void handlePythonOutput();
    void handlePythonError();
    void handlePythonFinished(int exitCode);
    
private:
    void setStatus(const QString &status);
    void startPythonBackend();
    void stopPythonBackend();
    void sendCommandToPython(const QString &command);
    
    QString m_statusString;
    bool m_isListening;
    bool m_isProcessing;
    float m_audioLevel;
    QString m_currentTranscription;
    
    QTimer *m_audioLevelTimer;
    QProcess *m_pythonProcess;
    QQueue<float> m_audioLevelHistory;
    
    static constexpr int AUDIO_LEVEL_HISTORY_SIZE = 50;
};

#endif // AUDIOENGINE_H

