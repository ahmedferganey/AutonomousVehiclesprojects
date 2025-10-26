#include <QtTest/QtTest>
#include "../src/transcriptionmodel.h"

class TestTranscriptionModel : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void cleanupTestCase();
    void init();
    void cleanup();

    // Test cases
    void testInitialState();
    void testAddTranscription();
    void testRemoveTranscription();
    void testClear();
    void testModelData();
    void testExportToFile();

private:
    TranscriptionModel *model;
};

void TestTranscriptionModel::initTestCase()
{
    qDebug() << "Initializing TranscriptionModel test suite";
}

void TestTranscriptionModel::cleanupTestCase()
{
    qDebug() << "Cleaning up TranscriptionModel test suite";
}

void TestTranscriptionModel::init()
{
    model = new TranscriptionModel(this);
}

void TestTranscriptionModel::cleanup()
{
    delete model;
    model = nullptr;
}

void TestTranscriptionModel::testInitialState()
{
    QCOMPARE(model->count(), 0);
    QCOMPARE(model->rowCount(), 0);
}

void TestTranscriptionModel::testAddTranscription()
{
    QSignalSpy spy(model, &TranscriptionModel::countChanged);
    
    model->addTranscription("Test transcription", QDateTime::currentDateTime());
    
    QCOMPARE(model->count(), 1);
    QCOMPARE(spy.count(), 1);
}

void TestTranscriptionModel::testRemoveTranscription()
{
    model->addTranscription("Test 1", QDateTime::currentDateTime());
    model->addTranscription("Test 2", QDateTime::currentDateTime());
    
    QCOMPARE(model->count(), 2);
    
    QModelIndex index = model->index(0);
    int id = model->data(index, TranscriptionModel::IdRole).toInt();
    
    model->removeTranscription(id);
    
    QCOMPARE(model->count(), 1);
}

void TestTranscriptionModel::testClear()
{
    model->addTranscription("Test 1", QDateTime::currentDateTime());
    model->addTranscription("Test 2", QDateTime::currentDateTime());
    model->addTranscription("Test 3", QDateTime::currentDateTime());
    
    QCOMPARE(model->count(), 3);
    
    model->clear();
    
    QCOMPARE(model->count(), 0);
}

void TestTranscriptionModel::testModelData()
{
    QString testText = "Hello World";
    QDateTime testTime = QDateTime::currentDateTime();
    
    model->addTranscription(testText, testTime);
    
    QModelIndex index = model->index(0);
    
    QCOMPARE(model->data(index, TranscriptionModel::TextRole).toString(), testText);
    QCOMPARE(model->data(index, TranscriptionModel::TimestampRole).toDateTime(), testTime);
}

void TestTranscriptionModel::testExportToFile()
{
    model->addTranscription("Test 1", QDateTime::currentDateTime());
    model->addTranscription("Test 2", QDateTime::currentDateTime());
    
    QString tempFile = QDir::temp().filePath("test_export.txt");
    
    QSignalSpy spy(model, &TranscriptionModel::exportCompleted);
    
    model->exportToFile(tempFile);
    
    QCOMPARE(spy.count(), 1);
    QVERIFY(QFile::exists(tempFile));
    
    // Cleanup
    QFile::remove(tempFile);
}

QTEST_MAIN(TestTranscriptionModel)
#include "test_transcriptionmodel.moc"

