#include "settings.h"
#include "logger.h"
#include <QCoreApplication>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>

Settings* Settings::s_instance = nullptr;

Settings::Settings(QObject *parent) : QObject(parent) {
    s_instance = this;
    m_settingsFilePath = QCoreApplication::applicationDirPath() + "/megu_settings.json";
    load();
}

Settings::~Settings() {
    save();
    s_instance = nullptr;
}

Settings* Settings::instance() {
    return s_instance;
}

void Settings::setOptimizeImages(bool val) {
    if (m_optimizeImages != val) {
        m_optimizeImages = val;
        emit optimizeImagesChanged(val);
        save();
    }
}

void Settings::setMaxImageResolution(int val) {
    if (m_maxImageResolution != val) {
        m_maxImageResolution = val;
        emit maxImageResolutionChanged(val);
        save();
    }
}

void Settings::setPngToWebp(bool val) {
    if (m_pngToWebp != val) {
        m_pngToWebp = val;
        emit pngToWebpChanged(val);
        save();
    }
}

void Settings::setMinifyJson(bool val) {
    if (m_minifyJson != val) {
        m_minifyJson = val;
        emit minifyJsonChanged(val);
        save();
    }
}

void Settings::setStripJsonComments(bool val) {
    if (m_stripJsonComments != val) {
        m_stripJsonComments = val;
        emit stripJsonCommentsChanged(val);
        save();
    }
}

void Settings::setOptimizeAudio(bool val) {
    if (m_optimizeAudio != val) {
        m_optimizeAudio = val;
        emit optimizeAudioChanged(val);
        save();
    }
}

void Settings::setCreateBackup(bool val) {
    if (m_createBackup != val) {
        m_createBackup = val;
        emit createBackupChanged(val);
        save();
    }
}

void Settings::setDeleteTempFiles(bool val) {
    if (m_deleteTempFiles != val) {
        m_deleteTempFiles = val;
        emit deleteTempFilesChanged(val);
        save();
    }
}

void Settings::setLanguage(const QString &val) {
    if (m_language != val) {
        m_language = val;
        emit languageChanged(val);
        save();
    }
}

void Settings::save() {
    QJsonObject obj;
    obj["optimizeImages"] = m_optimizeImages;
    obj["maxImageResolution"] = m_maxImageResolution;
    obj["pngToWebp"] = m_pngToWebp;
    obj["minifyJson"] = m_minifyJson;
    obj["stripJsonComments"] = m_stripJsonComments;
    obj["optimizeAudio"] = m_optimizeAudio;
    obj["createBackup"] = m_createBackup;
    obj["deleteTempFiles"] = m_deleteTempFiles;
    obj["language"] = m_language;

    QJsonDocument doc(obj);
    QFile file(m_settingsFilePath);
    if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        file.write(doc.toJson(QJsonDocument::Indented));
        file.close();
        Logger::log("Settings saved to megu_settings.json", "DEBUG");
    } else {
        Logger::log("Failed to save settings file", "WARNING");
    }
}

void Settings::load() {
    QFile file(m_settingsFilePath);
    if (!file.exists()) {
        Logger::log("Settings file megu_settings.json not found. Creating with default configurations.", "INFO");
        save();
        return;
    }

    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QByteArray data = file.readAll();
        file.close();

        QJsonDocument doc = QJsonDocument::fromJson(data);
        if (doc.isObject()) {
            QJsonObject obj = doc.object();
            
            if (obj.contains("optimizeImages")) m_optimizeImages = obj["optimizeImages"].toBool();
            if (obj.contains("maxImageResolution")) m_maxImageResolution = obj["maxImageResolution"].toInt();
            if (obj.contains("pngToWebp")) m_pngToWebp = obj["pngToWebp"].toBool();
            if (obj.contains("minifyJson")) m_minifyJson = obj["minifyJson"].toBool();
            if (obj.contains("stripJsonComments")) m_stripJsonComments = obj["stripJsonComments"].toBool();
            if (obj.contains("optimizeAudio")) m_optimizeAudio = obj["optimizeAudio"].toBool();
            if (obj.contains("createBackup")) m_createBackup = obj["createBackup"].toBool();
            if (obj.contains("deleteTempFiles")) m_deleteTempFiles = obj["deleteTempFiles"].toBool();
            if (obj.contains("language")) m_language = obj["language"].toString();

            Logger::log("Settings loaded successfully from megu_settings.json", "INFO");
        } else {
            Logger::log("Settings file contains invalid JSON root", "WARNING");
        }
    } else {
        Logger::log("Failed to open settings file for reading", "WARNING");
    }
}
