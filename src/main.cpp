#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>
#include <QTranslator>
#include <iostream>
#include "logger.h"
#include "settings.h"
#include "optimizer.h"

int main(int argc, char* argv[]) {
    // Instantiate QGuiApplication first so QCoreApplication properties (like applicationDirPath) are available
    QGuiApplication app(argc, argv);
    app.setApplicationName("Megu Pack Optimizer");
    app.setApplicationVersion("1.0.0");
    app.setOrganizationName("MeguStudio");

    // Instantiate logger next
    Logger loggerInstance;
    
    // Install custom log message handler to capture all QML and Qt core logs
    qInstallMessageHandler(Logger::qtMessageHandler);

    Logger::log("Initializing backend engines...", "INFO");

    // Instantiate settings and optimizer
    Settings settingsInstance;
    Optimizer optimizerInstance;

    QQmlApplicationEngine engine;
    engine.addImportPath("qrc:/");

    // Translator setup
    QTranslator translator;
    auto loadLanguage = [&app, &engine, &translator](const QString &lang) {
        app.removeTranslator(&translator);
        if (lang == "uk") {
            if (translator.load(":/MeguPackOptimizer/translations/megu_pack_optimizer_uk.qm")) {
                app.installTranslator(&translator);
                Logger::log("Ukrainian translation loaded successfully", "INFO");
            } else {
                Logger::log("Failed to load Ukrainian translation from resource path", "WARNING");
            }
        } else {
            Logger::log("Default language (English) selected", "INFO");
        }
        engine.retranslate();
    };

    // Load initial language
    loadLanguage(settingsInstance.language());

    // Connect language change signal to reload language dynamically
    QObject::connect(&settingsInstance, &Settings::languageChanged, &app, loadLanguage);

    // Register backend contexts to QML for reactive bindings
    engine.rootContext()->setContextProperty("loggerBackend", &loggerInstance);
    engine.rootContext()->setContextProperty("settingsBackend", &settingsInstance);
    engine.rootContext()->setContextProperty("optimizerBackend", &optimizerInstance);

    // QML Module Entry point path
    const QUrl url(QStringLiteral("qrc:/MeguPackOptimizer/src/qml/main.qml"));
    
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl) {
            Logger::log("QML Engine failed to create root ApplicationWindow!", "FATAL");
            QCoreApplication::exit(-1);
        }
    }, Qt::QueuedConnection);

    Logger::log("Loading QML engine...", "INFO");
    engine.load(url);

    Logger::log("Application event loop started.", "INFO");
    return app.exec();
}
