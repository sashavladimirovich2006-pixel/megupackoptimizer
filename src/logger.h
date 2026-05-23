#pragma once
#include <QObject>
#include <QString>
#include <QFile>
#include <QTextStream>
#include <QMutex>

class Logger : public QObject {
    Q_OBJECT
public:
    explicit Logger(QObject *parent = nullptr);
    ~Logger();

    static Logger* instance();

    // Invokable methods for QML frontend
    Q_INVOKABLE QString getFullLog();
    Q_INVOKABLE void clearLog();
    Q_INVOKABLE void logMessage(const QString &message, const QString &level = "INFO");

    // Static logging methods accessible anywhere in C++ code
    static void log(const QString &message, const QString &level = "INFO");
    static void qtMessageHandler(QtMsgType type, const QMessageLogContext &context, const QString &msg);

signals:
    void logAdded(const QString &line);

private:
    static Logger* s_instance;
    static QFile s_logFile;
    static QMutex s_mutex;
    static QString s_logFilePath;

    static void writeToFile(const QString &formattedMessage);
};
