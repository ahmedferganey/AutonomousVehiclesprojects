#ifndef SETTINGSMANAGER_H
#define SETTINGSMANAGER_H

#include <QObject>
#include <QSettings>

class SettingsManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString language READ language WRITE setLanguage NOTIFY languageChanged)
    Q_PROPERTY(QString whisperModel READ whisperModel WRITE setWhisperModel NOTIFY whisperModelChanged)
    Q_PROPERTY(int audioDevice READ audioDevice WRITE setAudioDevice NOTIFY audioDeviceChanged)
    Q_PROPERTY(bool darkMode READ darkMode WRITE setDarkMode NOTIFY darkModeChanged)
    Q_PROPERTY(float silenceThreshold READ silenceThreshold WRITE setSilenceThreshold NOTIFY silenceThresholdChanged)
    Q_PROPERTY(int maxRecordingSeconds READ maxRecordingSeconds WRITE setMaxRecordingSeconds NOTIFY maxRecordingSecondsChanged)
    
public:
    explicit SettingsManager(QObject *parent = nullptr);
    
    // Getters
    QString language() const { return m_language; }
    QString whisperModel() const { return m_whisperModel; }
    int audioDevice() const { return m_audioDevice; }
    bool darkMode() const { return m_darkMode; }
    float silenceThreshold() const { return m_silenceThreshold; }
    int maxRecordingSeconds() const { return m_maxRecordingSeconds; }
    
    // Setters
    void setLanguage(const QString &language);
    void setWhisperModel(const QString &model);
    void setAudioDevice(int device);
    void setDarkMode(bool enabled);
    void setSilenceThreshold(float threshold);
    void setMaxRecordingSeconds(int seconds);
    
public slots:
    void resetToDefaults();
    void saveSettings();
    void loadSettings();
    QStringList getAvailableLanguages();
    QStringList getAvailableModels();
    QStringList getAvailableAudioDevices();
    
signals:
    void languageChanged();
    void whisperModelChanged();
    void audioDeviceChanged();
    void darkModeChanged();
    void silenceThresholdChanged();
    void maxRecordingSecondsChanged();
    void settingsSaved();
    
private:
    QSettings *m_settings;
    
    QString m_language;
    QString m_whisperModel;
    int m_audioDevice;
    bool m_darkMode;
    float m_silenceThreshold;
    int m_maxRecordingSeconds;
};

#endif // SETTINGSMANAGER_H

