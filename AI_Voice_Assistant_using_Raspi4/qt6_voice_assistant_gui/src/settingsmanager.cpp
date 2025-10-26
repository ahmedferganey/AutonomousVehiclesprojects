#include "settingsmanager.h"
#include <QDebug>

SettingsManager::SettingsManager(QObject *parent)
    : QObject(parent)
    , m_settings(new QSettings("AutonomousVehicles", "VoiceAssistant", this))
{
    loadSettings();
}

void SettingsManager::setLanguage(const QString &language)
{
    if (m_language != language) {
        m_language = language;
        emit languageChanged();
    }
}

void SettingsManager::setWhisperModel(const QString &model)
{
    if (m_whisperModel != model) {
        m_whisperModel = model;
        emit whisperModelChanged();
    }
}

void SettingsManager::setAudioDevice(int device)
{
    if (m_audioDevice != device) {
        m_audioDevice = device;
        emit audioDeviceChanged();
    }
}

void SettingsManager::setDarkMode(bool enabled)
{
    if (m_darkMode != enabled) {
        m_darkMode = enabled;
        emit darkModeChanged();
    }
}

void SettingsManager::setSilenceThreshold(float threshold)
{
    if (qAbs(m_silenceThreshold - threshold) > 0.001f) {
        m_silenceThreshold = threshold;
        emit silenceThresholdChanged();
    }
}

void SettingsManager::setMaxRecordingSeconds(int seconds)
{
    if (m_maxRecordingSeconds != seconds) {
        m_maxRecordingSeconds = seconds;
        emit maxRecordingSecondsChanged();
    }
}

void SettingsManager::resetToDefaults()
{
    setLanguage("English");
    setWhisperModel("base");
    setAudioDevice(0);
    setDarkMode(false);
    setSilenceThreshold(0.01f);
    setMaxRecordingSeconds(60);
    
    saveSettings();
}

void SettingsManager::saveSettings()
{
    m_settings->setValue("language", m_language);
    m_settings->setValue("whisperModel", m_whisperModel);
    m_settings->setValue("audioDevice", m_audioDevice);
    m_settings->setValue("darkMode", m_darkMode);
    m_settings->setValue("silenceThreshold", m_silenceThreshold);
    m_settings->setValue("maxRecordingSeconds", m_maxRecordingSeconds);
    
    m_settings->sync();
    emit settingsSaved();
    
    qDebug() << "Settings saved";
}

void SettingsManager::loadSettings()
{
    m_language = m_settings->value("language", "English").toString();
    m_whisperModel = m_settings->value("whisperModel", "base").toString();
    m_audioDevice = m_settings->value("audioDevice", 0).toInt();
    m_darkMode = m_settings->value("darkMode", false).toBool();
    m_silenceThreshold = m_settings->value("silenceThreshold", 0.01f).toFloat();
    m_maxRecordingSeconds = m_settings->value("maxRecordingSeconds", 60).toInt();
    
    qDebug() << "Settings loaded";
}

QStringList SettingsManager::getAvailableLanguages()
{
    return QStringList{
        "English",
        "Arabic",
        "Chinese",
        "Spanish",
        "French",
        "German",
        "Japanese",
        "Korean"
    };
}

QStringList SettingsManager::getAvailableModels()
{
    return QStringList{
        "tiny",
        "base",
        "small",
        "medium",
        "large"
    };
}

QStringList SettingsManager::getAvailableAudioDevices()
{
    // In real implementation, this would query actual audio devices
    return QStringList{
        "Default Audio Device",
        "USB Microphone",
        "Built-in Microphone",
        "USB Sound Card"
    };
}

