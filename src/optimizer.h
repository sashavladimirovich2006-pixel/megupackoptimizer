#pragma once
#include <QObject>
#include <QString>

class Optimizer : public QObject {
    Q_OBJECT
    
    Q_PROPERTY(QString packPath READ packPath NOTIFY packPathChanged)
    Q_PROPERTY(QString packName READ packName NOTIFY packNameChanged)
    Q_PROPERTY(qint64 packSize READ packSize NOTIFY packSizeChanged)
    Q_PROPERTY(int imageCount READ imageCount NOTIFY imageCountChanged)
    Q_PROPERTY(int jsonCount READ jsonCount NOTIFY jsonCountChanged)
    Q_PROPERTY(int soundCount READ soundCount NOTIFY soundCountChanged)
    Q_PROPERTY(int otherCount READ otherCount NOTIFY otherCountChanged)
    Q_PROPERTY(bool isProcessing READ isProcessing NOTIFY isProcessingChanged)
    Q_PROPERTY(double progress READ progress NOTIFY progressChanged)

    // System info specs properties
    Q_PROPERTY(QString osName READ osName NOTIFY osNameChanged)
    Q_PROPERTY(QString cpuName READ cpuName NOTIFY cpuNameChanged)
    Q_PROPERTY(QString logicalCores READ logicalCores NOTIFY logicalCoresChanged)
    Q_PROPERTY(QString ramSize READ ramSize NOTIFY ramSizeChanged)
    Q_PROPERTY(QString gpuName READ gpuName NOTIFY gpuNameChanged)
    Q_PROPERTY(QString motherboard READ motherboard NOTIFY motherboardChanged)
    Q_PROPERTY(QString storage READ storage NOTIFY storageChanged)
    Q_PROPERTY(QString display READ display NOTIFY displayChanged)

public:
    explicit Optimizer(QObject *parent = nullptr);
    ~Optimizer();

    // Getters
    QString packPath() const { return m_packPath; }
    QString packName() const { return m_packName; }
    qint64 packSize() const { return m_packSize; }
    int imageCount() const { return m_imageCount; }
    int jsonCount() const { return m_jsonCount; }
    int soundCount() const { return m_soundCount; }
    int otherCount() const { return m_otherCount; }
    bool isProcessing() const { return m_isProcessing; }
    double progress() const { return m_progress; }

    // System info getters
    QString osName() const { return m_osName; }
    QString cpuName() const { return m_cpuName; }
    QString logicalCores() const { return m_logicalCores; }
    QString ramSize() const { return m_ramSize; }
    QString gpuName() const { return m_gpuName; }
    QString motherboard() const { return m_motherboard; }
    QString storage() const { return m_storage; }
    QString display() const { return m_display; }

    // Invokable methods for QML frontend
    Q_INVOKABLE void loadPack(const QString &rawPath);
    Q_INVOKABLE void startOptimization();
    Q_INVOKABLE void cancelOptimization();
    Q_INVOKABLE void refreshSystemInfo();

signals:
    void packPathChanged(const QString &val);
    void packNameChanged(const QString &val);
    void packSizeChanged(qint64 val);
    void imageCountChanged(int val);
    void jsonCountChanged(int val);
    void soundCountChanged(int val);
    void otherCountChanged(int val);
    void isProcessingChanged(bool val);
    void progressChanged(double val);

    // System info signals
    void osNameChanged(const QString &val);
    void cpuNameChanged(const QString &val);
    void logicalCoresChanged(const QString &val);
    void ramSizeChanged(const QString &val);
    void gpuNameChanged(const QString &val);
    void motherboardChanged(const QString &val);
    void storageChanged(const QString &val);
    void displayChanged(const QString &val);

    void scanFinished(bool success);
    void optimizationFinished(bool success);

private:
    void resetStats();
    void scanDirectory(const QString &dirPath);

    QString m_packPath;
    QString m_packName;
    qint64 m_packSize = 0;
    int m_imageCount = 0;
    int m_jsonCount = 0;
    int m_soundCount = 0;
    int m_otherCount = 0;
    
    bool m_isProcessing = false;
    double m_progress = 0.0;
    bool m_cancelRequested = false;

    // System specs variables
    QString m_osName;
    QString m_cpuName;
    QString m_logicalCores;
    QString m_ramSize;
    QString m_gpuName;
    QString m_motherboard;
    QString m_storage;
    QString m_display;
};
