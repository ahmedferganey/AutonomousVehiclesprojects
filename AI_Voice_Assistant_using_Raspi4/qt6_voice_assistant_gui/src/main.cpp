#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>
#include "audioengine.h"
#include "transcriptionmodel.h"
#include "settingsmanager.h"

int main(int argc, char *argv[])
{
    // Set application attributes
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication::setAttribute(Qt::AA_UseHighDpiPixmaps);
    
    QGuiApplication app(argc, argv);
    
    // Set application metadata
    app.setApplicationName("AI Voice Assistant");
    app.setApplicationVersion("1.0.0");
    app.setOrganizationName("AutonomousVehicles");
    app.setOrganizationDomain("ai-voice-assistant.local");
    app.setWindowIcon(QIcon(":/resources/voice-assistant.png"));
    
    // Create backend objects
    AudioEngine audioEngine;
    TranscriptionModel transcriptionModel;
    SettingsManager settingsManager;
    
    // Connect signals
    QObject::connect(&audioEngine, &AudioEngine::transcriptionReceived,
                     &transcriptionModel, &TranscriptionModel::addTranscription);
    
    QObject::connect(&audioEngine, &AudioEngine::audioLevelChanged,
                     [](float level) {
                         // Audio level updates for visualization
                         // Handled via Q_PROPERTY bindings
                     });
    
    // Create QML engine
    QQmlApplicationEngine engine;
    
    // Expose C++ objects to QML
    engine.rootContext()->setContextProperty("audioEngine", &audioEngine);
    engine.rootContext()->setContextProperty("transcriptionModel", &transcriptionModel);
    engine.rootContext()->setContextProperty("settingsManager", &settingsManager);
    
    // Load main QML file
    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));
    
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    
    engine.load(url);
    
    if (engine.rootObjects().isEmpty())
        return -1;
    
    return app.exec();
}

