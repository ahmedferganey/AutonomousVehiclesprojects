#include <QtTest/QtTest>
#include "../src/settingsmanager.h"

class TestSettingsManager : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void cleanupTestCase();
    void init();
    void cleanup();

    // Test cases
    void testDefaultValues();
    void testLanguageSetting();
    void testWhisperModelSetting();
    void testAudioDeviceSetting();
    void testDarkModeSetting();
    void testSilenceThresholdSetting();
    void testMaxRecordingSecondsSetting();
    void testResetToDefaults();
    void testPersistence();

private:
    SettingsManager *settings;
};

void TestSettingsManager::initTestCase()
{
    qDebug() << "Initializing SettingsManager test suite";
    // Clear any existing settings
    QSettings testSettings("AutonomousVehicles", "VoiceAssistantTest");
    testSettings.clear();
}

void TestSettingsManager::cleanupTestCase()
{
    qDebug() << "Cleaning up SettingsManager test suite";
}

void TestSettingsManager::init()
{
    settings = new SettingsManager(this);
}

void TestSettingsManager::cleanup()
{
    delete settings;
    settings = nullptr;
}

void TestSettingsManager::testDefaultValues()
{
    QCOMPARE(settings->language(), QString("English"));
    QCOMPARE(settings->whisperModel(), QString("base"));
    QCOMPARE(settings->audioDevice(), 0);
    QCOMPARE(settings->darkMode(), false);
    QVERIFY(qAbs(settings->silenceThreshold() - 0.01f) < 0.001f);
    QCOMPARE(settings->maxRecordingSeconds(), 60);
}

void TestSettingsManager::testLanguageSetting()
{
    QSignalSpy spy(settings, &SettingsManager::languageChanged);
    
    settings->setLanguage("Spanish");
    
    QCOMPARE(settings->language(), QString("Spanish"));
    QCOMPARE(spy.count(), 1);
}

void TestSettingsManager::testWhisperModelSetting()
{
    QSignalSpy spy(settings, &SettingsManager::whisperModelChanged);
    
    settings->setWhisperModel("large");
    
    QCOMPARE(settings->whisperModel(), QString("large"));
    QCOMPARE(spy.count(), 1);
}

void TestSettingsManager::testAudioDeviceSetting()
{
    QSignalSpy spy(settings, &SettingsManager::audioDeviceChanged);
    
    settings->setAudioDevice(2);
    
    QCOMPARE(settings->audioDevice(), 2);
    QCOMPARE(spy.count(), 1);
}

void TestSettingsManager::testDarkModeSetting()
{
    QSignalSpy spy(settings, &SettingsManager::darkModeChanged);
    
    settings->setDarkMode(true);
    
    QCOMPARE(settings->darkMode(), true);
    QCOMPARE(spy.count(), 1);
}

void TestSettingsManager::testSilenceThresholdSetting()
{
    QSignalSpy spy(settings, &SettingsManager::silenceThresholdChanged);
    
    settings->setSilenceThreshold(0.05f);
    
    QVERIFY(qAbs(settings->silenceThreshold() - 0.05f) < 0.001f);
    QCOMPARE(spy.count(), 1);
}

void TestSettingsManager::testMaxRecordingSecondsSetting()
{
    QSignalSpy spy(settings, &SettingsManager::maxRecordingSecondsChanged);
    
    settings->setMaxRecordingSeconds(120);
    
    QCOMPARE(settings->maxRecordingSeconds(), 120);
    QCOMPARE(spy.count(), 1);
}

void TestSettingsManager::testResetToDefaults()
{
    // Change all settings
    settings->setLanguage("French");
    settings->setWhisperModel("large");
    settings->setDarkMode(true);
    
    // Reset
    settings->resetToDefaults();
    
    // Verify defaults
    QCOMPARE(settings->language(), QString("English"));
    QCOMPARE(settings->whisperModel(), QString("base"));
    QCOMPARE(settings->darkMode(), false);
}

void TestSettingsManager::testPersistence()
{
    // Set values
    settings->setLanguage("German");
    settings->setWhisperModel("medium");
    settings->saveSettings();
    
    // Delete and recreate
    delete settings;
    settings = new SettingsManager(this);
    
    // Verify persistence
    QCOMPARE(settings->language(), QString("German"));
    QCOMPARE(settings->whisperModel(), QString("medium"));
}

QTEST_MAIN(TestSettingsManager)
#include "test_settingsmanager.moc"

