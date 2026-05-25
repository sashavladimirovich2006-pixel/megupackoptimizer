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
    Q_PROPERTY(bool hibernationActive READ hibernationActive WRITE setHibernationActive NOTIFY hibernationActiveChanged)
    Q_PROPERTY(bool originalHibernationActive READ originalHibernationActive NOTIFY originalHibernationActiveChanged)
    Q_PROPERTY(bool xboxInstalled READ xboxInstalled NOTIFY xboxInstalledChanged)
    Q_PROPERTY(bool xboxAppInstalled READ xboxAppInstalled NOTIFY xboxStatesChanged)
    Q_PROPERTY(bool xboxGamingOverlayInstalled READ xboxGamingOverlayInstalled NOTIFY xboxStatesChanged)
    Q_PROPERTY(bool xboxTcuiInstalled READ xboxTcuiInstalled NOTIFY xboxStatesChanged)
    Q_PROPERTY(bool xboxSpeechWindowInstalled READ xboxSpeechWindowInstalled NOTIFY xboxStatesChanged)
    Q_PROPERTY(bool gamingOverlayActive READ gamingOverlayActive WRITE setGamingOverlayActive NOTIFY gamingOverlayActiveChanged)
    Q_PROPERTY(bool originalGamingOverlayActive READ originalGamingOverlayActive NOTIFY originalGamingOverlayActiveChanged)
    Q_PROPERTY(bool coreIsolationActive READ coreIsolationActive WRITE setCoreIsolationActive NOTIFY coreIsolationActiveChanged)
    Q_PROPERTY(bool originalCoreIsolationActive READ originalCoreIsolationActive NOTIFY originalCoreIsolationActiveChanged)
    Q_PROPERTY(bool mouseAccelerationActive READ mouseAccelerationActive WRITE setMouseAccelerationActive NOTIFY mouseAccelerationActiveChanged)
    Q_PROPERTY(bool originalMouseAccelerationActive READ originalMouseAccelerationActive NOTIFY originalMouseAccelerationActiveChanged)
    Q_PROPERTY(bool gameModeActive READ gameModeActive WRITE setGameModeActive NOTIFY gameModeActiveChanged)
    Q_PROPERTY(bool originalGameModeActive READ originalGameModeActive NOTIFY originalGameModeActiveChanged)
    Q_PROPERTY(bool firewallActive READ firewallActive WRITE setFirewallActive NOTIFY firewallActiveChanged)
    Q_PROPERTY(bool originalFirewallActive READ originalFirewallActive NOTIFY originalFirewallActiveChanged)
    Q_PROPERTY(bool printerActive READ printerActive WRITE setPrinterActive NOTIFY printerActiveChanged)
    Q_PROPERTY(bool originalPrinterActive READ originalPrinterActive NOTIFY originalPrinterActiveChanged)
    Q_PROPERTY(bool bitlockerActive READ bitlockerActive WRITE setBitlockerActive NOTIFY bitlockerActiveChanged)
    Q_PROPERTY(bool originalBitlockerActive READ originalBitlockerActive NOTIFY originalBitlockerActiveChanged)
    Q_PROPERTY(bool bitlockerDriveEncrypted READ bitlockerDriveEncrypted NOTIFY bitlockerDriveEncryptedChanged)
    Q_PROPERTY(bool discordOverlayActive READ discordOverlayActive WRITE setDiscordOverlayActive NOTIFY discordOverlayActiveChanged)
    Q_PROPERTY(bool originalDiscordOverlayActive READ originalDiscordOverlayActive NOTIFY originalDiscordOverlayActiveChanged)
    Q_PROPERTY(bool defenderActive READ defenderActive WRITE setDefenderActive NOTIFY defenderActiveChanged)
    Q_PROPERTY(bool originalDefenderActive READ originalDefenderActive NOTIFY originalDefenderActiveChanged)
    Q_PROPERTY(bool defenderRegistryActive READ defenderRegistryActive WRITE setDefenderRegistryActive NOTIFY defenderRegistryActiveChanged)
    Q_PROPERTY(bool originalDefenderRegistryActive READ originalDefenderRegistryActive NOTIFY originalDefenderRegistryActiveChanged)
    Q_PROPERTY(bool defenderCmdActive READ defenderCmdActive WRITE setDefenderCmdActive NOTIFY defenderCmdActiveChanged)
    Q_PROPERTY(bool originalDefenderCmdActive READ originalDefenderCmdActive NOTIFY originalDefenderCmdActiveChanged)
    Q_PROPERTY(bool defenderServiceActive READ defenderServiceActive WRITE setDefenderServiceActive NOTIFY defenderServiceActiveChanged)
    Q_PROPERTY(bool originalDefenderServiceActive READ originalDefenderServiceActive NOTIFY originalDefenderServiceActiveChanged)
    Q_PROPERTY(QVariantList usbDevices READ usbDevices NOTIFY usbDevicesChanged)
    Q_PROPERTY(QVariantList originalUsbDevices READ originalUsbDevices NOTIFY usbDevicesChanged)
    Q_PROPERTY(bool usbPowerSavingActive READ usbPowerSavingActive WRITE setUsbPowerSavingActive NOTIFY usbPowerSavingActiveChanged)
    Q_PROPERTY(bool originalUsbPowerSavingActive READ originalUsbPowerSavingActive NOTIFY originalUsbPowerSavingActiveChanged)
    Q_PROPERTY(bool usbChanged READ usbChanged NOTIFY usbDevicesChanged)
    Q_PROPERTY(QStringList detectedPrinters READ detectedPrinters NOTIFY detectedPrintersChanged)
    Q_PROPERTY(bool notificationsActive READ notificationsActive WRITE setNotificationsActive NOTIFY notificationsActiveChanged)
    Q_PROPERTY(bool originalNotificationsActive READ originalNotificationsActive NOTIFY originalNotificationsActiveChanged)
    Q_PROPERTY(bool notifGlobalActive READ notifGlobalActive WRITE setNotifGlobalActive NOTIFY notifGlobalActiveChanged)
    Q_PROPERTY(bool originalNotifGlobalActive READ originalNotifGlobalActive NOTIFY originalNotifGlobalActiveChanged)
    Q_PROPERTY(bool notifAppActive READ notifAppActive WRITE setNotifAppActive NOTIFY notifAppActiveChanged)
    Q_PROPERTY(bool originalNotifAppActive READ originalNotifAppActive NOTIFY originalNotifAppActiveChanged)
    Q_PROPERTY(bool notifSoundsActive READ notifSoundsActive WRITE setNotifSoundsActive NOTIFY notifSoundsActiveChanged)
    Q_PROPERTY(bool originalNotifSoundsActive READ originalNotifSoundsActive NOTIFY originalNotifSoundsActiveChanged)
    Q_PROPERTY(bool notifLockscreenActive READ notifLockscreenActive WRITE setNotifLockscreenActive NOTIFY notifLockscreenActiveChanged)
    Q_PROPERTY(bool originalNotifLockscreenActive READ originalNotifLockscreenActive NOTIFY originalNotifLockscreenActiveChanged)
    Q_PROPERTY(QVariantList powerSchemes READ powerSchemes NOTIFY powerSchemesChanged)
    Q_PROPERTY(bool ultimateSchemeUnlocked READ ultimateSchemeUnlocked NOTIFY ultimateSchemeUnlockedChanged)
    Q_PROPERTY(QString activePowerSchemeGuid READ activePowerSchemeGuid NOTIFY activePowerSchemeGuidChanged)
    Q_PROPERTY(QString targetPowerSchemeGuid READ targetPowerSchemeGuid NOTIFY targetPowerSchemeGuidChanged)
    Q_PROPERTY(int mpoValue READ mpoValue NOTIFY mpoValueChanged)
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
    bool hibernationActive() const { return m_hibernationActive; }
    bool originalHibernationActive() const { return m_originalHibernationActive; }
    bool xboxInstalled() const { return m_xboxInstalled; }
    bool xboxAppInstalled() const { return m_xboxAppInstalled; }
    bool xboxGamingOverlayInstalled() const { return m_xboxGamingOverlayInstalled; }
    bool xboxTcuiInstalled() const { return m_xboxTcuiInstalled; }
    bool xboxSpeechWindowInstalled() const { return m_xboxSpeechWindowInstalled; }
    bool gamingOverlayActive() const { return m_gamingOverlayActive; }
    bool originalGamingOverlayActive() const { return m_originalGamingOverlayActive; }
    bool coreIsolationActive() const { return m_coreIsolationActive; }
    bool originalCoreIsolationActive() const { return m_originalCoreIsolationActive; }
    bool mouseAccelerationActive() const { return m_mouseAccelerationActive; }
    bool originalMouseAccelerationActive() const { return m_originalMouseAccelerationActive; }
    bool gameModeActive() const { return m_gameModeActive; }
    bool originalGameModeActive() const { return m_originalGameModeActive; }
    bool firewallActive() const { return m_firewallActive; }
    bool originalFirewallActive() const { return m_originalFirewallActive; }
    bool printerActive() const { return m_printerActive; }
    bool originalPrinterActive() const { return m_originalPrinterActive; }
    bool bitlockerActive() const { return m_bitlockerActive; }
    bool originalBitlockerActive() const { return m_originalBitlockerActive; }
    bool bitlockerDriveEncrypted() const { return m_bitlockerDriveEncrypted; }
    bool discordOverlayActive() const { return m_discordOverlayActive; }
    bool originalDiscordOverlayActive() const { return m_originalDiscordOverlayActive; }
    bool defenderActive() const { return m_defenderActive; }
    bool originalDefenderActive() const { return m_originalDefenderActive; }
    bool defenderRegistryActive() const { return m_defenderRegistryActive; }
    bool originalDefenderRegistryActive() const { return m_originalDefenderRegistryActive; }
    bool defenderCmdActive() const { return m_defenderCmdActive; }
    bool originalDefenderCmdActive() const { return m_originalDefenderCmdActive; }
    bool defenderServiceActive() const { return m_defenderServiceActive; }
    bool originalDefenderServiceActive() const { return m_originalDefenderServiceActive; }
    QVariantList usbDevices() const { return m_usbDevices; }
    QVariantList originalUsbDevices() const { return m_originalUsbDevices; }
    bool usbPowerSavingActive() const { return m_usbPowerSavingActive; }
    bool originalUsbPowerSavingActive() const { return m_originalUsbPowerSavingActive; }
    bool usbChanged() const {
        if (m_usbDevices.size() != m_originalUsbDevices.size()) return true;
        for (int i = 0; i < m_usbDevices.size(); ++i) {
            if (m_usbDevices[i].toMap()["powerSavingActive"].toBool() != m_originalUsbDevices[i].toMap()["powerSavingActive"].toBool()) {
                return true;
            }
        }
        return false;
    }
    QStringList detectedPrinters() const { return m_detectedPrinters; }
    bool notificationsActive() const { return m_notificationsActive; }
    bool originalNotificationsActive() const { return m_originalNotificationsActive; }
    bool notifGlobalActive() const { return m_notifGlobalActive; }
    bool originalNotifGlobalActive() const { return m_originalNotifGlobalActive; }
    bool notifAppActive() const { return m_notifAppActive; }
    bool originalNotifAppActive() const { return m_originalNotifAppActive; }
    bool notifSoundsActive() const { return m_notifSoundsActive; }
    bool originalNotifSoundsActive() const { return m_originalNotifSoundsActive; }
    bool notifLockscreenActive() const { return m_notifLockscreenActive; }
    bool originalNotifLockscreenActive() const { return m_originalNotifLockscreenActive; }
    QVariantList powerSchemes() const { return m_powerSchemes; }
    bool ultimateSchemeUnlocked() const { return m_ultimateSchemeUnlocked; }
    QString activePowerSchemeGuid() const { return m_activePowerSchemeGuid; }
    QString targetPowerSchemeGuid() const { return m_targetPowerSchemeGuid; }
    int mpoValue() const { return m_mpoValue; }
    QStringList fixedDrives() const { return m_fixedDrives; }
    QVariantMap driveStates() const { return m_driveStates; }
    QVariantMap originalDriveStates() const { return m_originalDriveStates; }
    bool isOptimizingSystem() const { return m_isOptimizingSystem; }
    double systemProgress() const { return m_systemProgress; }

    // Setters
    void setWinSearchActive(bool val);
    void setHibernationActive(bool val);
    void setGamingOverlayActive(bool val);
    void setCoreIsolationActive(bool val);
    void setMouseAccelerationActive(bool val);
    void setGameModeActive(bool val);
    void setFirewallActive(bool val);
    void setPrinterActive(bool val);
    void setBitlockerActive(bool val);
    void setDiscordOverlayActive(bool val);
    void setDefenderActive(bool val);
    void setDefenderRegistryActive(bool val);
    void setDefenderCmdActive(bool val);
    void setDefenderServiceActive(bool val);
    void setNotificationsActive(bool val);
    void setNotifGlobalActive(bool val);
    void setNotifAppActive(bool val);
    void setNotifSoundsActive(bool val);
    void setNotifLockscreenActive(bool val);
    void setDriveStates(const QVariantMap &states);
    void setUsbPowerSavingActive(bool val);
    
    Q_INVOKABLE bool isDiscordRunning();
    Q_INVOKABLE void killDiscord();


    // Invokable methods for QML frontend
    Q_INVOKABLE void refreshSystemInfo();
    Q_INVOKABLE void loadSystemStates();
    Q_INVOKABLE void startSystemOptimization();
    Q_INVOKABLE void showPath(const QString &funcName);
    Q_INVOKABLE void removeXboxEntirely();
    Q_INVOKABLE void restoreXboxEntirely();
    Q_INVOKABLE void removeXboxComponent(const QString &componentName);
    Q_INVOKABLE void restoreXboxComponent(const QString &componentName);
    Q_INVOKABLE void applyMpoValue(int value);
    Q_INVOKABLE void selectPowerScheme(const QString &guidStr);
    Q_INVOKABLE void activateUltimatePerformance();
    Q_INVOKABLE void setDevicePowerSavingActive(const QString &subkeyPath, bool active);
    Q_INVOKABLE void revertUsbDevices();



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
    void hibernationActiveChanged(bool val);
    void originalHibernationActiveChanged(bool val);
    void xboxInstalledChanged(bool val);
    void xboxStatesChanged();
    void gamingOverlayActiveChanged(bool val);
    void originalGamingOverlayActiveChanged(bool val);
    void coreIsolationActiveChanged(bool val);
    void originalCoreIsolationActiveChanged(bool val);
    void mouseAccelerationActiveChanged(bool val);
    void originalMouseAccelerationActiveChanged(bool val);
    void gameModeActiveChanged(bool val);
    void originalGameModeActiveChanged(bool val);
    void firewallActiveChanged(bool val);
    void originalFirewallActiveChanged(bool val);
    void printerActiveChanged(bool val);
    void originalPrinterActiveChanged(bool val);
    void bitlockerActiveChanged(bool val);
    void originalBitlockerActiveChanged(bool val);
    void bitlockerDriveEncryptedChanged(bool val);
    void discordOverlayActiveChanged(bool val);
    void originalDiscordOverlayActiveChanged(bool val);
    void defenderActiveChanged(bool val);
    void originalDefenderActiveChanged(bool val);
    void defenderRegistryActiveChanged(bool val);
    void originalDefenderRegistryActiveChanged(bool val);
    void defenderCmdActiveChanged(bool val);
    void originalDefenderCmdActiveChanged(bool val);
    void defenderServiceActiveChanged(bool val);
    void originalDefenderServiceActiveChanged(bool val);
    void detectedPrintersChanged(const QStringList &val);
    void usbDevicesChanged(const QVariantList &val);
    void usbPowerSavingActiveChanged(bool val);
    void originalUsbPowerSavingActiveChanged(bool val);

    void notificationsActiveChanged(bool val);
    void originalNotificationsActiveChanged(bool val);
    void notifGlobalActiveChanged(bool val);
    void originalNotifGlobalActiveChanged(bool val);
    void notifAppActiveChanged(bool val);
    void originalNotifAppActiveChanged(bool val);
    void notifSoundsActiveChanged(bool val);
    void originalNotifSoundsActiveChanged(bool val);
    void notifLockscreenActiveChanged(bool val);
    void originalNotifLockscreenActiveChanged(bool val);
    void powerSchemesChanged(const QVariantList &val);
    void ultimateSchemeUnlockedChanged(bool val);
    void activePowerSchemeGuidChanged(const QString &val);
    void targetPowerSchemeGuidChanged(const QString &val);
    void mpoValueChanged(int val);
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
    bool checkIsDiscordOverlayActive();
    void setDiscordOverlayFilesActive(bool active);

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
    bool m_hibernationActive = false;
    bool m_originalHibernationActive = false;
    bool m_xboxInstalled = false;
    bool m_xboxAppInstalled = false;
    bool m_xboxGamingOverlayInstalled = false;
    bool m_xboxTcuiInstalled = false;
    bool m_xboxSpeechWindowInstalled = false;
    bool m_gamingOverlayActive = true;
    bool m_originalGamingOverlayActive = true;
    bool m_coreIsolationActive = false;
    bool m_originalCoreIsolationActive = false;
    bool m_mouseAccelerationActive = false;
    bool m_originalMouseAccelerationActive = false;
    bool m_gameModeActive = true;
    bool m_originalGameModeActive = true;
    bool m_firewallActive = true;
    bool m_originalFirewallActive = true;
    bool m_printerActive = true;
    bool m_originalPrinterActive = true;
    bool m_bitlockerActive = true;
    bool m_originalBitlockerActive = true;
    bool m_bitlockerDriveEncrypted = false;
    bool m_discordOverlayActive = true;
    bool m_originalDiscordOverlayActive = true;
    bool m_defenderActive = true;
    bool m_originalDefenderActive = true;
    bool m_defenderRegistryActive = true;
    bool m_originalDefenderRegistryActive = true;
    bool m_defenderCmdActive = true;
    bool m_originalDefenderCmdActive = true;
    bool m_defenderServiceActive = true;
    bool m_originalDefenderServiceActive = true;
    QStringList m_detectedPrinters;
    QVariantList m_usbDevices;
    QVariantList m_originalUsbDevices;
    bool m_usbPowerSavingActive = false;
    bool m_originalUsbPowerSavingActive = false;
    bool m_notificationsActive = true;
    bool m_originalNotificationsActive = true;
    bool m_notifGlobalActive = true;
    bool m_originalNotifGlobalActive = true;
    bool m_notifAppActive = true;
    bool m_originalNotifAppActive = true;
    bool m_notifSoundsActive = true;
    bool m_originalNotifSoundsActive = true;
    bool m_notifLockscreenActive = true;
    bool m_originalNotifLockscreenActive = true;
    QVariantList m_powerSchemes;
    bool m_ultimateSchemeUnlocked = false;
    QString m_activePowerSchemeGuid;
    QString m_targetPowerSchemeGuid;
    int m_mpoValue = 0;
    QStringList m_fixedDrives;
    QVariantMap m_driveStates;
    QVariantMap m_originalDriveStates;
    bool m_isOptimizingSystem = false;
    double m_systemProgress = 0.0;
};
