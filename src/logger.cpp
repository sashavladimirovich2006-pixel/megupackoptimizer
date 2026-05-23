#include "logger.h"
#include <QCoreApplication>
#include <QDateTime>
#include <QDir>
#include <iostream>

Logger* Logger::s_instance = nullptr;
QFile Logger::s_logFile;
QMutex Logger::s_mutex;
QString Logger::s_logFilePath;

Logger::Logger(QObject *parent) : QObject(parent) {
    s_instance = this;
    s_logFilePath = QCoreApplication::applicationDirPath() + "/megu_optimizer.log";
    
    // Open the log file in the application directory
    QMutexLocker locker(&s_mutex);
    s_logFile.setFileName(s_logFilePath);
    if (s_logFile.open(QIODevice::WriteOnly | QIODevice::Append | QIODevice::Text)) {
        locker.unlock();
        log("Megu Pack Optimizer started. Logger initialized.", "INFO");
    } else {
        std::cerr << "Failed to open log file at: " << s_logFilePath.toStdString() << std::endl;
    }
}

Logger::~Logger() {
    QMutexLocker locker(&s_mutex);
    if (s_logFile.isOpen()) {
        s_logFile.close();
    }
    s_instance = nullptr;
}

Logger* Logger::instance() {
    return s_instance;
}

QString Logger::getFullLog() {
    QMutexLocker locker(&s_mutex);
    if (s_logFile.isOpen()) {
        s_logFile.flush();
    }
    
    QFile file(s_logFilePath);
    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&file);
        return in.readAll();
    }
    return "Error reading log file.";
}

void Logger::clearLog() {
    QMutexLocker locker(&s_mutex);
    if (s_logFile.isOpen()) {
        s_logFile.close();
    }
    if (s_logFile.open(QIODevice::WriteOnly | QIODevice::Truncate | QIODevice::Text)) {
        locker.unlock();
        log("Log file cleared.", "INFO");
    } else {
        std::cerr << "Failed to truncate log file." << std::endl;
    }
}

void Logger::logMessage(const QString &message, const QString &level) {
    log(message, level);
}

void Logger::log(const QString &message, const QString &level) {
    QString timeStr = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss.zzz");
    QString formatted = QString("[%1] [%2] %3").arg(timeStr, level, message);
    
    // Print to console (standard output)
    std::cout << formatted.toStdString() << std::endl;
    
    // Write to file
    writeToFile(formatted);
    
    // Emit signal to QML if instance is available
    if (s_instance) {
        emit s_instance->logAdded(formatted);
    }
}

void Logger::writeToFile(const QString &formattedMessage) {
    QMutexLocker locker(&s_mutex);
    if (s_logFile.isOpen()) {
        QTextStream out(&s_logFile);
        out << formattedMessage << "\n";
        s_logFile.flush();
    }
}

void Logger::qtMessageHandler(QtMsgType type, const QMessageLogContext &context, const QString &msg) {
    QString level = "INFO";
    switch (type) {
        case QtDebugMsg: level = "DEBUG"; break;
        case QtInfoMsg: level = "INFO"; break;
        case QtWarningMsg: level = "WARNING"; break;
        case QtCriticalMsg: level = "CRITICAL"; break;
        case QtFatalMsg: level = "FATAL"; break;
    }
    
    QString detail = "";
    if (context.file) {
        QString file = QString(context.file);
        int idx = file.lastIndexOf('/');
        if (idx == -1) idx = file.lastIndexOf('\\');
        if (idx != -1) file = file.mid(idx + 1);
        detail = QString(" (%1:%2, %3)").arg(file).arg(context.line).arg(context.function);
    }
    
    log(msg + detail, level);
}
