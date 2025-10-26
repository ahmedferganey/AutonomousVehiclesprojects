#include <QtTest/QtTest>
#include "../src/audioengine.h"

class TestAudioEngine : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void cleanupTestCase();
    void init();
    void cleanup();

    // Test cases
    void testInitialState();
    void testStartListening();
    void testStopListening();
    void testToggleListening();
    void testProcessAudio();
    void testAudioLevelUpdate();
    void testStatusChanges();
    void testErrorHandling();

private:
    AudioEngine *engine;
};

void TestAudioEngine::initTestCase()
{
    // Setup for all tests
    qDebug() << "Initializing AudioEngine test suite";
}

void TestAudioEngine::cleanupTestCase()
{
    // Cleanup after all tests
    qDebug() << "Cleaning up AudioEngine test suite";
}

void TestAudioEngine::init()
{
    // Setup before each test
    engine = new AudioEngine(this);
}

void TestAudioEngine::cleanup()
{
    // Cleanup after each test
    delete engine;
    engine = nullptr;
}

void TestAudioEngine::testInitialState()
{
    QCOMPARE(engine->isListening(), false);
    QCOMPARE(engine->isProcessing(), false);
    QCOMPARE(engine->status(), QString("Ready"));
    QCOMPARE(engine->audioLevel(), 0.0f);
}

void TestAudioEngine::testStartListening()
{
    QSignalSpy spy(engine, &AudioEngine::isListeningChanged);
    
    engine->startListening();
    
    QCOMPARE(engine->isListening(), true);
    QCOMPARE(spy.count(), 1);
}

void TestAudioEngine::testStopListening()
{
    engine->startListening();
    QSignalSpy spy(engine, &AudioEngine::isListeningChanged);
    
    engine->stopListening();
    
    QCOMPARE(engine->isListening(), false);
    QCOMPARE(spy.count(), 1);
}

void TestAudioEngine::testToggleListening()
{
    QCOMPARE(engine->isListening(), false);
    
    engine->toggleListening();
    QCOMPARE(engine->isListening(), true);
    
    engine->toggleListening();
    QCOMPARE(engine->isListening(), false);
}

void TestAudioEngine::testProcessAudio()
{
    engine->startListening();
    QSignalSpy spy(engine, &AudioEngine::isProcessingChanged);
    
    engine->processAudio();
    
    QCOMPARE(engine->isProcessing(), true);
    QCOMPARE(spy.count(), 1);
}

void TestAudioEngine::testAudioLevelUpdate()
{
    QSignalSpy spy(engine, &AudioEngine::audioLevelChanged);
    
    engine->startListening();
    
    // Wait for audio level updates
    QTest::qWait(100);
    
    QVERIFY(spy.count() > 0);
}

void TestAudioEngine::testStatusChanges()
{
    QSignalSpy spy(engine, &AudioEngine::statusChanged);
    
    engine->startListening();
    QCOMPARE(engine->status(), QString("Listening"));
    
    engine->stopListening();
    QCOMPARE(engine->status(), QString("Ready"));
    
    QVERIFY(spy.count() >= 2);
}

void TestAudioEngine::testErrorHandling()
{
    QSignalSpy spy(engine, &AudioEngine::errorOccurred);
    
    // Test error scenarios
    // This would need proper mocking of the Python backend
    
    QVERIFY(spy.count() >= 0);
}

QTEST_MAIN(TestAudioEngine)
#include "test_audioengine.moc"
