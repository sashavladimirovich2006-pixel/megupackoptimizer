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

    // System Optimization properties
    Q_PROPERTY(bool winSearchActive READ winSearchActive WRITE setWinSearchActive NOTIFY winSearchActiveChanged)
    Q_PROPERTY(bool driveCActive READ driveCActive WRITE setDriveCActive NOTIFY driveCActiveChanged)
    Q_PROPERTY(bool detectedDriveActive READ detectedDriveActive WRITE setDetectedDriveActive NOTIFY detectedDriveActiveChanged)
    Q_PROPERTY(QString detectedDriveLetter READ detectedDriveLetter NOTIFY detectedDriveLetterChanged)
    Q_PROPERTY(bool isOptimizingSystem READ isOptimizingSystem NOTIFY isOptimizingSystemChanged)
    Q_PROPERTY(double systemProgress READ systemProgress NOTIFY systemProgressChanged)

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

    // System Optimization getters
    bool winSearchActive() const { return m_winSearchActive; }
    bool driveCActive() const { return m_driveCActive; }
    bool detectedDriveActive() const { return m_detectedDriveActive; }
    QString detectedDriveLetter() const { return m_detectedDriveLetter; }
    bool isOptimizingSystem() const { return m_isOptimizingSystem; }
    double systemProgress() const { return m_systemProgress; }

    // Setters for target system optimization state
    void setWinSearchActive(bool val);
    void setDriveCActive(bool val);
    void setDetectedDriveActive(bool val);

    // Invokable methods for QML frontend
    Q_INVOKABLE void loadPack(const QString &rawPath);
    Q_INVOKABLE void startOptimization();
    Q_INVOKABLE void cancelOptimization();
    Q_INVOKABLE void refreshSystemInfo();

    // System Optimization actions
    Q_INVOKABLE void loadSystemStates();
    Q_INVOKABLE void startSystemOptimization(bool searchVal, bool cVal, bool detectedVal);
    Q_INVOKABLE void showPath(const QString &funcName);

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

    // System Optimization signals
    void winSearchActiveChanged(bool val);
    void driveCActiveChanged(bool val);
    void detectedDriveActiveChanged(bool val);
    void detectedDriveLetterChanged(const QString &val);
    void isOptimizingSystemChanged(bool val);
    void systemProgressChanged(double val);

    void scanFinished(bool success);
    void optimizationFinished(bool success);
    
    // Custom signal to report system optimization steps to LogViewer
    void systemStepReported(const QString &msg, const QString &type);
    void systemOptimizationFinished(bool success);

private:
    void resetStats();
    void scanDirectory(const QString &dirPath);
    void detectSystemDrives();

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

    // System Optimization state
    bool m_winSearchActive = true;
    bool m_driveCActive = true;
    bool m_detectedDriveActive = true;
    QString m_detectedDriveLetter = "C:";
    bool m_isOptimizingSystem = false;
    double m_systemProgress = 0.0;
};
