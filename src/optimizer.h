#pragma once
#include <QObject>
#include <QString>
#include <QStringList>
#include <QVariantMap>

class Optimizer : public QObject {
    Q_OBJECT

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
    Q_PROPERTY(bool originalWinSearchActive READ originalWinSearchActive NOTIFY originalWinSearchActiveChanged)
    Q_PROPERTY(QStringList fixedDrives READ fixedDrives NOTIFY fixedDrivesChanged)
    Q_PROPERTY(QVariantMap driveStates READ driveStates WRITE setDriveStates NOTIFY driveStatesChanged)
    Q_PROPERTY(QVariantMap originalDriveStates READ originalDriveStates NOTIFY originalDriveStatesChanged)
    Q_PROPERTY(bool isOptimizingSystem READ isOptimizingSystem NOTIFY isOptimizingSystemChanged)
    Q_PROPERTY(double systemProgress READ systemProgress NOTIFY systemProgressChanged)

public:
    explicit Optimizer(QObject *parent = nullptr);
    ~Optimizer();

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
    bool originalWinSearchActive() const { return m_originalWinSearchActive; }
    QStringList fixedDrives() const { return m_fixedDrives; }
    QVariantMap driveStates() const { return m_driveStates; }
    QVariantMap originalDriveStates() const { return m_originalDriveStates; }
    bool isOptimizingSystem() const { return m_isOptimizingSystem; }
    double systemProgress() const { return m_systemProgress; }

    // Setters
    void setWinSearchActive(bool val);
    void setDriveStates(const QVariantMap &states);

    // Invokable methods for QML frontend
    Q_INVOKABLE void refreshSystemInfo();
    Q_INVOKABLE void loadSystemStates();
    Q_INVOKABLE void startSystemOptimization();
    Q_INVOKABLE void showPath(const QString &funcName);

signals:
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
    void originalWinSearchActiveChanged(bool val);
    void fixedDrivesChanged(const QStringList &val);
    void driveStatesChanged(const QVariantMap &val);
    void originalDriveStatesChanged(const QVariantMap &val);
    void isOptimizingSystemChanged(bool val);
    void systemProgressChanged(double val);
    
    // Custom signal to report system optimization steps to LogViewer
    void systemStepReported(const QString &msg, const QString &type);
    void systemOptimizationFinished(bool success);

private:
    void scanDrives();

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
    bool m_originalWinSearchActive = true;
    QStringList m_fixedDrives;
    QVariantMap m_driveStates;
    QVariantMap m_originalDriveStates;
    bool m_isOptimizingSystem = false;
    double m_systemProgress = 0.0;
};
