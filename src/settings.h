#pragma once
#include <QObject>
#include <QString>

class Settings : public QObject {
    Q_OBJECT
    
    Q_PROPERTY(bool optimizeImages READ optimizeImages WRITE setOptimizeImages NOTIFY optimizeImagesChanged)
    Q_PROPERTY(int maxImageResolution READ maxImageResolution WRITE setMaxImageResolution NOTIFY maxImageResolutionChanged)
    Q_PROPERTY(bool pngToWebp READ pngToWebp WRITE setPngToWebp NOTIFY pngToWebpChanged)
    Q_PROPERTY(bool minifyJson READ minifyJson WRITE setMinifyJson NOTIFY minifyJsonChanged)
    Q_PROPERTY(bool stripJsonComments READ stripJsonComments WRITE setStripJsonComments NOTIFY stripJsonCommentsChanged)
    Q_PROPERTY(bool optimizeAudio READ optimizeAudio WRITE setOptimizeAudio NOTIFY optimizeAudioChanged)
    Q_PROPERTY(bool createBackup READ createBackup WRITE setCreateBackup NOTIFY createBackupChanged)
    Q_PROPERTY(bool deleteTempFiles READ deleteTempFiles WRITE setDeleteTempFiles NOTIFY deleteTempFilesChanged)
    Q_PROPERTY(QString language READ language WRITE setLanguage NOTIFY languageChanged)

public:
    explicit Settings(QObject *parent = nullptr);
    ~Settings();

    static Settings* instance();

    // Getters
    bool optimizeImages() const { return m_optimizeImages; }
    int maxImageResolution() const { return m_maxImageResolution; }
    bool pngToWebp() const { return m_pngToWebp; }
    bool minifyJson() const { return m_minifyJson; }
    bool stripJsonComments() const { return m_stripJsonComments; }
    bool optimizeAudio() const { return m_optimizeAudio; }
    bool createBackup() const { return m_createBackup; }
    bool deleteTempFiles() const { return m_deleteTempFiles; }
    QString language() const { return m_language; }

    // Setters
    void setOptimizeImages(bool val);
    void setMaxImageResolution(int val);
    void setPngToWebp(bool val);
    void setMinifyJson(bool val);
    void setStripJsonComments(bool val);
    void setOptimizeAudio(bool val);
    void setCreateBackup(bool val);
    void setDeleteTempFiles(bool val);
    void setLanguage(const QString &val);

    Q_INVOKABLE void save();
    Q_INVOKABLE void load();

signals:
    void optimizeImagesChanged(bool val);
    void maxImageResolutionChanged(int val);
    void pngToWebpChanged(bool val);
    void minifyJsonChanged(bool val);
    void stripJsonCommentsChanged(bool val);
    void optimizeAudioChanged(bool val);
    void createBackupChanged(bool val);
    void deleteTempFilesChanged(bool val);
    void languageChanged(const QString &val);

private:
    static Settings* s_instance;
    QString m_settingsFilePath;

    bool m_optimizeImages = true;
    int m_maxImageResolution = 256;
    bool m_pngToWebp = false;
    bool m_minifyJson = true;
    bool m_stripJsonComments = true;
    bool m_optimizeAudio = true;
    bool m_createBackup = true;
    bool m_deleteTempFiles = true;
    QString m_language = "en";
};
