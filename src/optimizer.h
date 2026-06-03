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
    Q_PROPERTY(double cpuLoadPercent READ cpuLoadPercent NOTIFY cpuLoadPercentChanged)
    Q_PROPERTY(double ramLoadPercent READ ramLoadPercent NOTIFY ramLoadPercentChanged)

    // System Optimization properties
    Q_PROPERTY(bool classicContextMenuActive READ classicContextMenuActive WRITE setClassicContextMenuActive NOTIFY classicContextMenuActiveChanged)
    Q_PROPERTY(bool originalClassicContextMenuActive READ originalClassicContextMenuActive NOTIFY originalClassicContextMenuActiveChanged)
    Q_PROPERTY(bool shortcutArrowsActive READ shortcutArrowsActive WRITE setShortcutArrowsActive NOTIFY shortcutArrowsActiveChanged)
    Q_PROPERTY(bool originalShortcutArrowsActive READ originalShortcutArrowsActive NOTIFY originalShortcutArrowsActiveChanged)
    Q_PROPERTY(bool clipboardHistoryActive READ clipboardHistoryActive WRITE setClipboardHistoryActive NOTIFY clipboardHistoryActiveChanged)
    Q_PROPERTY(bool originalClipboardHistoryActive READ originalClipboardHistoryActive NOTIFY originalClipboardHistoryActiveChanged)
    Q_PROPERTY(bool taskbarEndTaskActive READ taskbarEndTaskActive WRITE setTaskbarEndTaskActive NOTIFY taskbarEndTaskActiveChanged)
    Q_PROPERTY(bool originalTaskbarEndTaskActive READ originalTaskbarEndTaskActive NOTIFY originalTaskbarEndTaskActiveChanged)
    Q_PROPERTY(bool taskbarSecondsActive READ taskbarSecondsActive WRITE setTaskbarSecondsActive NOTIFY taskbarSecondsActiveChanged)
    Q_PROPERTY(bool originalTaskbarSecondsActive READ originalTaskbarSecondsActive NOTIFY originalTaskbarSecondsActiveChanged)
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
    Q_PROPERTY(bool bootCoreIsolationActive READ bootCoreIsolationActive CONSTANT)
    Q_PROPERTY(bool hagsActive READ hagsActive WRITE setHagsActive NOTIFY hagsActiveChanged)
    Q_PROPERTY(bool originalHagsActive READ originalHagsActive NOTIFY originalHagsActiveChanged)
    Q_PROPERTY(bool bootHagsActive READ bootHagsActive CONSTANT)
    Q_PROPERTY(bool mouseAccelerationActive READ mouseAccelerationActive WRITE setMouseAccelerationActive NOTIFY mouseAccelerationActiveChanged)
    Q_PROPERTY(bool originalMouseAccelerationActive READ originalMouseAccelerationActive NOTIFY originalMouseAccelerationActiveChanged)
    Q_PROPERTY(bool gameModeActive READ gameModeActive WRITE setGameModeActive NOTIFY gameModeActiveChanged)
    Q_PROPERTY(bool originalGameModeActive READ originalGameModeActive NOTIFY originalGameModeActiveChanged)
    Q_PROPERTY(bool firewallActive READ firewallActive WRITE setFirewallActive NOTIFY firewallActiveChanged)
    Q_PROPERTY(bool originalFirewallActive READ originalFirewallActive NOTIFY originalFirewallActiveChanged)
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
    Q_PROPERTY(QVariantList appNotificationSettings READ appNotificationSettings NOTIFY appNotificationSettingsChanged)
    Q_PROPERTY(QVariantList powerSchemes READ powerSchemes NOTIFY powerSchemesChanged)
    Q_PROPERTY(bool ultimateSchemeUnlocked READ ultimateSchemeUnlocked NOTIFY ultimateSchemeUnlockedChanged)
    Q_PROPERTY(bool deleteUltimateStaged READ deleteUltimateStaged WRITE setDeleteUltimateStaged NOTIFY deleteUltimateStagedChanged)
    Q_PROPERTY(bool deleteDefenderStaged READ deleteDefenderStaged WRITE setDeleteDefenderStaged NOTIFY deleteDefenderStagedChanged)
    Q_PROPERTY(QString activePowerSchemeGuid READ activePowerSchemeGuid NOTIFY activePowerSchemeGuidChanged)
    Q_PROPERTY(QString targetPowerSchemeGuid READ targetPowerSchemeGuid NOTIFY targetPowerSchemeGuidChanged)
    Q_PROPERTY(int mpoValue READ mpoValue NOTIFY mpoValueChanged)
    Q_PROPERTY(bool remoteAccessActive READ remoteAccessActive WRITE setRemoteAccessActive NOTIFY remoteAccessActiveChanged)
    Q_PROPERTY(bool originalRemoteAccessActive READ originalRemoteAccessActive NOTIFY originalRemoteAccessActiveChanged)
    Q_PROPERTY(bool telemetryActive READ telemetryActive WRITE setTelemetryActive NOTIFY telemetryActiveChanged)
    Q_PROPERTY(bool originalTelemetryActive READ originalTelemetryActive NOTIFY originalTelemetryActiveChanged)
    Q_PROPERTY(bool telemetryDiagTrackActive READ telemetryDiagTrackActive WRITE setTelemetryDiagTrackActive NOTIFY telemetryDiagTrackActiveChanged)
    Q_PROPERTY(bool originalTelemetryDiagTrackActive READ originalTelemetryDiagTrackActive NOTIFY originalTelemetryDiagTrackActiveChanged)
    Q_PROPERTY(bool telemetryWapPushActive READ telemetryWapPushActive WRITE setTelemetryWapPushActive NOTIFY telemetryWapPushActiveChanged)
    Q_PROPERTY(bool originalTelemetryWapPushActive READ originalTelemetryWapPushActive NOTIFY originalTelemetryWapPushActiveChanged)
    Q_PROPERTY(bool telemetryCeipActive READ telemetryCeipActive WRITE setTelemetryCeipActive NOTIFY telemetryCeipActiveChanged)
    Q_PROPERTY(bool originalTelemetryCeipActive READ originalTelemetryCeipActive NOTIFY originalTelemetryCeipActiveChanged)
    Q_PROPERTY(bool telemetryWerActive READ telemetryWerActive WRITE setTelemetryWerActive NOTIFY telemetryWerActiveChanged)
    Q_PROPERTY(bool originalTelemetryWerActive READ originalTelemetryWerActive NOTIFY originalTelemetryWerActiveChanged)

    // Ads Optimization properties
    Q_PROPERTY(bool adsTailoredExperiencesActive READ adsTailoredExperiencesActive WRITE setAdsTailoredExperiencesActive NOTIFY adsTailoredExperiencesActiveChanged)
    Q_PROPERTY(bool originalAdsTailoredExperiencesActive READ originalAdsTailoredExperiencesActive NOTIFY originalAdsTailoredExperiencesActiveChanged)
    Q_PROPERTY(bool adsAdvertisingIdActive READ adsAdvertisingIdActive WRITE setAdsAdvertisingIdActive NOTIFY adsAdvertisingIdActiveChanged)
    Q_PROPERTY(bool originalAdsAdvertisingIdActive READ originalAdsAdvertisingIdActive NOTIFY originalAdsAdvertisingIdActiveChanged)
    Q_PROPERTY(bool adsSuggestedContentActive READ adsSuggestedContentActive WRITE setAdsSuggestedContentActive NOTIFY adsSuggestedContentActiveChanged)
    Q_PROPERTY(bool originalAdsSuggestedContentActive READ originalAdsSuggestedContentActive NOTIFY originalAdsSuggestedContentActiveChanged)
    Q_PROPERTY(bool adsSettingsHomeActive READ adsSettingsHomeActive WRITE setAdsSettingsHomeActive NOTIFY adsSettingsHomeActiveChanged)
    Q_PROPERTY(bool originalAdsSettingsHomeActive READ originalAdsSettingsHomeActive NOTIFY originalAdsSettingsHomeActiveChanged)
    Q_PROPERTY(bool adsSuggestedNotificationsActive READ adsSuggestedNotificationsActive WRITE setAdsSuggestedNotificationsActive NOTIFY adsSuggestedNotificationsActiveChanged)
    Q_PROPERTY(bool originalAdsSuggestedNotificationsActive READ originalAdsSuggestedNotificationsActive NOTIFY originalAdsSuggestedNotificationsActiveChanged)
    Q_PROPERTY(bool adsLockScreenTipsActive READ adsLockScreenTipsActive WRITE setAdsLockScreenTipsActive NOTIFY adsLockScreenTipsActiveChanged)
    Q_PROPERTY(bool originalAdsLockScreenTipsActive READ originalAdsLockScreenTipsActive NOTIFY originalAdsLockScreenTipsActiveChanged)
    Q_PROPERTY(bool adsWindowsTipsActive READ adsWindowsTipsActive WRITE setAdsWindowsTipsActive NOTIFY adsWindowsTipsActiveChanged)
    Q_PROPERTY(bool originalAdsWindowsTipsActive READ originalAdsWindowsTipsActive NOTIFY originalAdsWindowsTipsActiveChanged)
    Q_PROPERTY(bool adsWelcomeExperienceActive READ adsWelcomeExperienceActive WRITE setAdsWelcomeExperienceActive NOTIFY adsWelcomeExperienceActiveChanged)
    Q_PROPERTY(bool originalAdsWelcomeExperienceActive READ originalAdsWelcomeExperienceActive NOTIFY originalAdsWelcomeExperienceActiveChanged)
    Q_PROPERTY(bool adsFinishSetupActive READ adsFinishSetupActive WRITE setAdsFinishSetupActive NOTIFY adsFinishSetupActiveChanged)
    Q_PROPERTY(bool originalAdsFinishSetupActive READ originalAdsFinishSetupActive NOTIFY originalAdsFinishSetupActiveChanged)

    // Privacy Optimization properties
    Q_PROPERTY(bool privacyLocationActive READ privacyLocationActive WRITE setPrivacyLocationActive NOTIFY privacyLocationActiveChanged)
    Q_PROPERTY(bool originalPrivacyLocationActive READ originalPrivacyLocationActive NOTIFY originalPrivacyLocationActiveChanged)
    Q_PROPERTY(bool privacyTelemetryActive READ privacyTelemetryActive WRITE setPrivacyTelemetryActive NOTIFY privacyTelemetryActiveChanged)
    Q_PROPERTY(bool originalPrivacyTelemetryActive READ originalPrivacyTelemetryActive NOTIFY originalPrivacyTelemetryActiveChanged)
    Q_PROPERTY(bool privacyCeipActive READ privacyCeipActive WRITE setPrivacyCeipActive NOTIFY privacyCeipActiveChanged)
    Q_PROPERTY(bool originalPrivacyCeipActive READ originalPrivacyCeipActive NOTIFY originalPrivacyCeipActiveChanged)
    Q_PROPERTY(bool privacyAppsTelemetryActive READ privacyAppsTelemetryActive WRITE setPrivacyAppsTelemetryActive NOTIFY privacyAppsTelemetryActiveChanged)
    Q_PROPERTY(bool originalPrivacyAppsTelemetryActive READ originalPrivacyAppsTelemetryActive NOTIFY originalPrivacyAppsTelemetryActiveChanged)
    Q_PROPERTY(bool privacyAppLaunchesActive READ privacyAppLaunchesActive WRITE setPrivacyAppLaunchesActive NOTIFY privacyAppLaunchesActiveChanged)
    Q_PROPERTY(bool originalPrivacyAppLaunchesActive READ originalPrivacyAppLaunchesActive NOTIFY originalPrivacyAppLaunchesActiveChanged)
    Q_PROPERTY(bool privacyImproveInkingActive READ privacyImproveInkingActive WRITE setPrivacyImproveInkingActive NOTIFY privacyImproveInkingActiveChanged)
    Q_PROPERTY(bool originalPrivacyImproveInkingActive READ originalPrivacyImproveInkingActive NOTIFY originalPrivacyImproveInkingActiveChanged)
    Q_PROPERTY(bool privacyPersonalizeInkingActive READ privacyPersonalizeInkingActive WRITE setPrivacyPersonalizeInkingActive NOTIFY privacyPersonalizeInkingActiveChanged)
    Q_PROPERTY(bool originalPrivacyPersonalizeInkingActive READ originalPrivacyPersonalizeInkingActive NOTIFY originalPrivacyPersonalizeInkingActiveChanged)
    Q_PROPERTY(bool privacyErrorReportingActive READ privacyErrorReportingActive WRITE setPrivacyErrorReportingActive NOTIFY privacyErrorReportingActiveChanged)
    Q_PROPERTY(bool originalPrivacyErrorReportingActive READ originalPrivacyErrorReportingActive NOTIFY originalPrivacyErrorReportingActiveChanged)
    Q_PROPERTY(bool privacyLockScreenCameraActive READ privacyLockScreenCameraActive WRITE setPrivacyLockScreenCameraActive NOTIFY privacyLockScreenCameraActiveChanged)
    Q_PROPERTY(bool originalPrivacyLockScreenCameraActive READ originalPrivacyLockScreenCameraActive NOTIFY originalPrivacyLockScreenCameraActiveChanged)
    Q_PROPERTY(bool privacyCameraIndicatorActive READ privacyCameraIndicatorActive WRITE setPrivacyCameraIndicatorActive NOTIFY privacyCameraIndicatorActiveChanged)
    Q_PROPERTY(bool originalPrivacyCameraIndicatorActive READ originalPrivacyCameraIndicatorActive NOTIFY originalPrivacyCameraIndicatorActiveChanged)
    Q_PROPERTY(bool privacyOnlineSpeechActive READ privacyOnlineSpeechActive WRITE setPrivacyOnlineSpeechActive NOTIFY privacyOnlineSpeechActiveChanged)
    Q_PROPERTY(bool originalPrivacyOnlineSpeechActive READ originalPrivacyOnlineSpeechActive NOTIFY originalPrivacyOnlineSpeechActiveChanged)

    // Superuser / More Rights properties
    Q_PROPERTY(bool superuserGodModeActive READ superuserGodModeActive WRITE setSuperuserGodModeActive NOTIFY superuserGodModeActiveChanged)
    Q_PROPERTY(bool originalSuperuserGodModeActive READ originalSuperuserGodModeActive NOTIFY originalSuperuserGodModeActiveChanged)
    Q_PROPERTY(bool superuserDeveloperModeActive READ superuserDeveloperModeActive WRITE setSuperuserDeveloperModeActive NOTIFY superuserDeveloperModeActiveChanged)
    Q_PROPERTY(bool originalSuperuserDeveloperModeActive READ originalSuperuserDeveloperModeActive NOTIFY originalSuperuserDeveloperModeActiveChanged)
    Q_PROPERTY(int superuserUacLevel READ superuserUacLevel WRITE setSuperuserUacLevel NOTIFY superuserUacLevelChanged)
    Q_PROPERTY(int originalSuperuserUacLevel READ originalSuperuserUacLevel NOTIFY originalSuperuserUacLevelChanged)
    Q_PROPERTY(bool superuserUcpdActive READ superuserUcpdActive WRITE setSuperuserUcpdActive NOTIFY superuserUcpdActiveChanged)
    Q_PROPERTY(bool originalSuperuserUcpdActive READ originalSuperuserUcpdActive NOTIFY originalSuperuserUcpdActiveChanged)

    Q_PROPERTY(int windowsUpdateMode READ windowsUpdateMode WRITE setWindowsUpdateMode NOTIFY windowsUpdateModeChanged)
    Q_PROPERTY(int originalWindowsUpdateMode READ originalWindowsUpdateMode NOTIFY originalWindowsUpdateModeChanged)
    Q_PROPERTY(QVariantMap cs2LaunchOptions READ cs2LaunchOptions WRITE setCs2LaunchOptions NOTIFY cs2LaunchOptionsChanged)
    Q_PROPERTY(QVariantMap originalCs2LaunchOptions READ originalCs2LaunchOptions NOTIFY originalCs2LaunchOptionsChanged)
    Q_PROPERTY(bool steamOverlayActive READ steamOverlayActive WRITE setSteamOverlayActive NOTIFY steamOverlayActiveChanged)
    Q_PROPERTY(bool originalSteamOverlayActive READ originalSteamOverlayActive NOTIFY originalSteamOverlayActiveChanged)
    Q_PROPERTY(bool cs2OverlayActive READ cs2OverlayActive WRITE setCs2OverlayActive NOTIFY cs2OverlayActiveChanged)
    Q_PROPERTY(bool originalCs2OverlayActive READ originalCs2OverlayActive NOTIFY originalCs2OverlayActiveChanged)
    Q_PROPERTY(QVariantMap visualEffects READ visualEffects WRITE setVisualEffects NOTIFY visualEffectsChanged)
    Q_PROPERTY(QVariantMap originalVisualEffects READ originalVisualEffects NOTIFY originalVisualEffectsChanged)
    Q_PROPERTY(bool steamInstalled READ steamInstalled NOTIFY steamInstalledChanged)
    Q_PROPERTY(QString steamPath READ steamPath NOTIFY steamInstalledChanged)
    Q_PROPERTY(QVariantList steamInstalledGames READ steamInstalledGames NOTIFY steamInstalledGamesChanged)
    Q_PROPERTY(QVariantMap steamFriendsSettings READ steamFriendsSettings WRITE setSteamFriendsSettings NOTIFY steamFriendsSettingsChanged)
    Q_PROPERTY(QVariantMap originalSteamFriendsSettings READ originalSteamFriendsSettings NOTIFY originalSteamFriendsSettingsChanged)
    Q_PROPERTY(QStringList fixedDrives READ fixedDrives NOTIFY fixedDrivesChanged)
    Q_PROPERTY(QVariantMap driveStates READ driveStates WRITE setDriveStates NOTIFY driveStatesChanged)
    Q_PROPERTY(QVariantMap originalDriveStates READ originalDriveStates NOTIFY originalDriveStatesChanged)
    Q_PROPERTY(int pagefileMin READ pagefileMin WRITE setPagefileMin NOTIFY pagefileMinChanged)
    Q_PROPERTY(int originalPagefileMin READ originalPagefileMin NOTIFY originalPagefileMinChanged)
    Q_PROPERTY(int pagefileMax READ pagefileMax WRITE setPagefileMax NOTIFY pagefileMaxChanged)
    Q_PROPERTY(int originalPagefileMax READ originalPagefileMax NOTIFY originalPagefileMaxChanged)
    Q_PROPERTY(bool pagefileAuto READ pagefileAuto WRITE setPagefileAuto NOTIFY pagefileAutoChanged)
    Q_PROPERTY(bool originalPagefileAuto READ originalPagefileAuto NOTIFY originalPagefileAutoChanged)
    Q_PROPERTY(bool isOptimizingSystem READ isOptimizingSystem NOTIFY isOptimizingSystemChanged)
    Q_PROPERTY(double systemProgress READ systemProgress NOTIFY systemProgressChanged)
    Q_PROPERTY(QVariantList backupList READ backupList NOTIFY backupListChanged)

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
    double cpuLoadPercent() const { return m_cpuLoadPercent; }
    double ramLoadPercent() const { return m_ramLoadPercent; }

    // System Optimization getters
    bool classicContextMenuActive() const { return m_classicContextMenuActive; }
    bool originalClassicContextMenuActive() const { return m_originalClassicContextMenuActive; }
    bool shortcutArrowsActive() const { return m_shortcutArrowsActive; }
    bool originalShortcutArrowsActive() const { return m_originalShortcutArrowsActive; }
    bool clipboardHistoryActive() const { return m_clipboardHistoryActive; }
    bool originalClipboardHistoryActive() const { return m_originalClipboardHistoryActive; }
    bool taskbarEndTaskActive() const { return m_taskbarEndTaskActive; }
    bool originalTaskbarEndTaskActive() const { return m_originalTaskbarEndTaskActive; }
    bool taskbarSecondsActive() const { return m_taskbarSecondsActive; }
    bool originalTaskbarSecondsActive() const { return m_originalTaskbarSecondsActive; }
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
    bool bootCoreIsolationActive() const { return m_bootCoreIsolationActive; }
    bool hagsActive() const { return m_hagsActive; }
    bool originalHagsActive() const { return m_originalHagsActive; }
    bool bootHagsActive() const { return m_bootHagsActive; }
    bool mouseAccelerationActive() const { return m_mouseAccelerationActive; }
    bool originalMouseAccelerationActive() const { return m_originalMouseAccelerationActive; }
    bool gameModeActive() const { return m_gameModeActive; }
    bool originalGameModeActive() const { return m_originalGameModeActive; }
    bool firewallActive() const { return m_firewallActive; }
    bool originalFirewallActive() const { return m_originalFirewallActive; }
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
    QVariantList appNotificationSettings() const { return m_appNotificationSettings; }
    QVariantList powerSchemes() const { return m_powerSchemes; }
    bool ultimateSchemeUnlocked() const { return m_ultimateSchemeUnlocked; }
    bool deleteUltimateStaged() const { return m_deleteUltimateStaged; }
    bool deleteDefenderStaged() const { return m_deleteDefenderStaged; }
    QString activePowerSchemeGuid() const { return m_activePowerSchemeGuid; }
    QString targetPowerSchemeGuid() const { return m_targetPowerSchemeGuid; }
    int mpoValue() const { return m_mpoValue; }
    bool remoteAccessActive() const { return m_remoteAccessActive; }
    bool originalRemoteAccessActive() const { return m_originalRemoteAccessActive; }
    bool telemetryActive() const { return m_telemetryActive; }
    bool originalTelemetryActive() const { return m_originalTelemetryActive; }
    bool telemetryDiagTrackActive() const { return m_telemetryDiagTrackActive; }
    bool originalTelemetryDiagTrackActive() const { return m_originalTelemetryDiagTrackActive; }
    bool telemetryWapPushActive() const { return m_telemetryWapPushActive; }
    bool originalTelemetryWapPushActive() const { return m_originalTelemetryWapPushActive; }
    bool telemetryCeipActive() const { return m_telemetryCeipActive; }
    bool originalTelemetryCeipActive() const { return m_originalTelemetryCeipActive; }
    bool telemetryWerActive() const { return m_telemetryWerActive; }
    bool originalTelemetryWerActive() const { return m_originalTelemetryWerActive; }

    // Ads Getters
    bool adsTailoredExperiencesActive() const { return m_adsTailoredExperiencesActive; }
    bool originalAdsTailoredExperiencesActive() const { return m_originalAdsTailoredExperiencesActive; }
    bool adsAdvertisingIdActive() const { return m_adsAdvertisingIdActive; }
    bool originalAdsAdvertisingIdActive() const { return m_originalAdsAdvertisingIdActive; }
    bool adsSuggestedContentActive() const { return m_adsSuggestedContentActive; }
    bool originalAdsSuggestedContentActive() const { return m_originalAdsSuggestedContentActive; }
    bool adsSettingsHomeActive() const { return m_adsSettingsHomeActive; }
    bool originalAdsSettingsHomeActive() const { return m_originalAdsSettingsHomeActive; }
    bool adsSuggestedNotificationsActive() const { return m_adsSuggestedNotificationsActive; }
    bool originalAdsSuggestedNotificationsActive() const { return m_originalAdsSuggestedNotificationsActive; }
    bool adsLockScreenTipsActive() const { return m_adsLockScreenTipsActive; }
    bool originalAdsLockScreenTipsActive() const { return m_originalAdsLockScreenTipsActive; }
    bool adsWindowsTipsActive() const { return m_adsWindowsTipsActive; }
    bool originalAdsWindowsTipsActive() const { return m_originalAdsWindowsTipsActive; }
    bool adsWelcomeExperienceActive() const { return m_adsWelcomeExperienceActive; }
    bool originalAdsWelcomeExperienceActive() const { return m_originalAdsWelcomeExperienceActive; }
    bool adsFinishSetupActive() const { return m_adsFinishSetupActive; }
    bool originalAdsFinishSetupActive() const { return m_originalAdsFinishSetupActive; }

    // Privacy Getters
    bool privacyLocationActive() const { return m_privacyLocationActive; }
    bool originalPrivacyLocationActive() const { return m_originalPrivacyLocationActive; }
    bool privacyTelemetryActive() const { return m_privacyTelemetryActive; }
    bool originalPrivacyTelemetryActive() const { return m_originalPrivacyTelemetryActive; }
    bool privacyCeipActive() const { return m_privacyCeipActive; }
    bool originalPrivacyCeipActive() const { return m_originalPrivacyCeipActive; }
    bool privacyAppsTelemetryActive() const { return m_privacyAppsTelemetryActive; }
    bool originalPrivacyAppsTelemetryActive() const { return m_originalPrivacyAppsTelemetryActive; }
    bool privacyAppLaunchesActive() const { return m_privacyAppLaunchesActive; }
    bool originalPrivacyAppLaunchesActive() const { return m_originalPrivacyAppLaunchesActive; }
    bool privacyImproveInkingActive() const { return m_privacyImproveInkingActive; }
    bool originalPrivacyImproveInkingActive() const { return m_originalPrivacyImproveInkingActive; }
    bool privacyPersonalizeInkingActive() const { return m_privacyPersonalizeInkingActive; }
    bool originalPrivacyPersonalizeInkingActive() const { return m_originalPrivacyPersonalizeInkingActive; }
    bool privacyErrorReportingActive() const { return m_privacyErrorReportingActive; }
    bool originalPrivacyErrorReportingActive() const { return m_originalPrivacyErrorReportingActive; }
    bool privacyLockScreenCameraActive() const { return m_privacyLockScreenCameraActive; }
    bool originalPrivacyLockScreenCameraActive() const { return m_originalPrivacyLockScreenCameraActive; }
    bool privacyCameraIndicatorActive() const { return m_privacyCameraIndicatorActive; }
    bool originalPrivacyCameraIndicatorActive() const { return m_originalPrivacyCameraIndicatorActive; }
    bool privacyOnlineSpeechActive() const { return m_privacyOnlineSpeechActive; }
    bool originalPrivacyOnlineSpeechActive() const { return m_originalPrivacyOnlineSpeechActive; }

    // Superuser / More Rights Getters
    bool superuserGodModeActive() const { return m_superuserGodModeActive; }
    bool originalSuperuserGodModeActive() const { return m_originalSuperuserGodModeActive; }
    bool superuserDeveloperModeActive() const { return m_superuserDeveloperModeActive; }
    bool originalSuperuserDeveloperModeActive() const { return m_originalSuperuserDeveloperModeActive; }
    int superuserUacLevel() const { return m_superuserUacLevel; }
    int originalSuperuserUacLevel() const { return m_originalSuperuserUacLevel; }
    bool superuserUcpdActive() const { return m_superuserUcpdActive; }
    bool originalSuperuserUcpdActive() const { return m_originalSuperuserUcpdActive; }

    int windowsUpdateMode() const { return m_windowsUpdateMode; }
    int originalWindowsUpdateMode() const { return m_originalWindowsUpdateMode; }
    QVariantMap cs2LaunchOptions() const { return m_cs2LaunchOptions; }
    QVariantMap originalCs2LaunchOptions() const { return m_originalCs2LaunchOptions; }
    bool steamOverlayActive() const { return m_steamOverlayActive; }
    bool originalSteamOverlayActive() const { return m_originalSteamOverlayActive; }
    bool cs2OverlayActive() const { return m_cs2OverlayActive; }
    bool originalCs2OverlayActive() const { return m_originalCs2OverlayActive; }
    QVariantMap visualEffects() const { return m_visualEffects; }
    QVariantMap originalVisualEffects() const { return m_originalVisualEffects; }
    bool steamInstalled() const { return m_steamInstalled; }
    QString steamPath() const;
    QVariantList steamInstalledGames() const { return m_steamInstalledGames; }
    QVariantMap steamFriendsSettings() const { return m_steamFriendsSettings; }
    QVariantMap originalSteamFriendsSettings() const { return m_originalSteamFriendsSettings; }
    QStringList fixedDrives() const { return m_fixedDrives; }
    QVariantMap driveStates() const { return m_driveStates; }
    QVariantMap originalDriveStates() const { return m_originalDriveStates; }
    bool isOptimizingSystem() const { return m_isOptimizingSystem; }
    double systemProgress() const { return m_systemProgress; }
    QVariantList backupList() const { return m_backupList; }
    int pagefileMin() const { return m_pagefileMin; }
    int originalPagefileMin() const { return m_originalPagefileMin; }
    int pagefileMax() const { return m_pagefileMax; }
    int originalPagefileMax() const { return m_originalPagefileMax; }
    bool pagefileAuto() const { return m_pagefileAuto; }
    bool originalPagefileAuto() const { return m_originalPagefileAuto; }

    // Setters
    void setClassicContextMenuActive(bool val);
    void setShortcutArrowsActive(bool val);
    void setClipboardHistoryActive(bool val);
    void setTaskbarEndTaskActive(bool val);
    void setTaskbarSecondsActive(bool val);
    void setWinSearchActive(bool val);
    void setHibernationActive(bool val);
    void setGamingOverlayActive(bool val);
    void setCoreIsolationActive(bool val);
    void setHagsActive(bool val);
    void setMouseAccelerationActive(bool val);
    void setGameModeActive(bool val);
    void setFirewallActive(bool val);
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
    void setRemoteAccessActive(bool val);
    void setTelemetryActive(bool val);
    void setTelemetryDiagTrackActive(bool val);
    void setTelemetryWapPushActive(bool val);
    void setTelemetryCeipActive(bool val);
    void setTelemetryWerActive(bool val);

    // Ads Setters
    void setAdsTailoredExperiencesActive(bool val);
    void setAdsAdvertisingIdActive(bool val);
    void setAdsSuggestedContentActive(bool val);
    void setAdsSettingsHomeActive(bool val);
    void setAdsSuggestedNotificationsActive(bool val);
    void setAdsLockScreenTipsActive(bool val);
    void setAdsWindowsTipsActive(bool val);
    void setAdsWelcomeExperienceActive(bool val);
    void setAdsFinishSetupActive(bool val);

    // Privacy Setters
    void setPrivacyLocationActive(bool val);
    void setPrivacyTelemetryActive(bool val);
    void setPrivacyCeipActive(bool val);
    void setPrivacyAppsTelemetryActive(bool val);
    void setPrivacyAppLaunchesActive(bool val);
    void setPrivacyImproveInkingActive(bool val);
    void setPrivacyPersonalizeInkingActive(bool val);
    void setPrivacyErrorReportingActive(bool val);
    void setPrivacyLockScreenCameraActive(bool val);
    void setPrivacyCameraIndicatorActive(bool val);
    void setPrivacyOnlineSpeechActive(bool val);

    // Superuser / More Rights Setters
    void setSuperuserGodModeActive(bool val);
    void setSuperuserDeveloperModeActive(bool val);
    void setSuperuserUacLevel(int val);
    void setSuperuserUcpdActive(bool val);

    void setWindowsUpdateMode(int mode);
    void setCs2LaunchOptions(const QVariantMap &val);
    void setSteamOverlayActive(bool val);
    void setCs2OverlayActive(bool val);
    void setVisualEffects(const QVariantMap &val);
    void setSteamFriendsSettings(const QVariantMap &val);
    void setDeleteUltimateStaged(bool val);
    void setDeleteDefenderStaged(bool val);
    void setPagefileMin(int val);
    void setPagefileMax(int val);
    void setPagefileAuto(bool val);
    
    Q_INVOKABLE bool isDiscordRunning();
    Q_INVOKABLE void killDiscord();
    Q_INVOKABLE bool isSteamRunning();
    Q_INVOKABLE QString getSteamActiveUserId();
    Q_INVOKABLE void killSteam();
    Q_INVOKABLE void launchSteam();



    // Invokable methods for QML frontend
    Q_INVOKABLE void refreshSystemInfo();
    Q_INVOKABLE void loadSystemStates();
    Q_INVOKABLE void startSystemOptimization();
    Q_INVOKABLE void showPath(const QString &funcName);
    Q_INVOKABLE void runDeepIndexingRemoval();
    Q_INVOKABLE void decryptBitLocker();
    Q_INVOKABLE void removeXboxEntirely();
    Q_INVOKABLE void restoreXboxEntirely();
    Q_INVOKABLE void removeXboxComponent(const QString &componentName);
    Q_INVOKABLE void restoreXboxComponent(const QString &componentName);
    Q_INVOKABLE void applyMpoValue(int value);
    Q_INVOKABLE void selectPowerScheme(const QString &guidStr);
    Q_INVOKABLE void activateUltimatePerformance();
    Q_INVOKABLE void deleteUltimatePerformance();
    Q_INVOKABLE void setDevicePowerSavingActive(const QString &subkeyPath, bool active);
    Q_INVOKABLE void setAppNotificationEnabled(const QString &appKey, bool enabled);
    Q_INVOKABLE void revertUsbDevices();
    Q_INVOKABLE void restartExplorer();
    Q_INVOKABLE void scanSteamInstalledGames();
    Q_INVOKABLE QVariantMap getDriveInfo(const QString &path);
    Q_INVOKABLE bool clearSteamDownloadCache();
    Q_INVOKABLE bool deleteSteamBrowserData();
    Q_INVOKABLE void copyToClipboard(const QString &text);
    Q_INVOKABLE bool createSystemBackup(const QString &backupName = "");
    Q_INVOKABLE bool restoreFromBackup(const QString &backupId);
    Q_INVOKABLE bool deleteBackup(const QString &backupId);
    Q_INVOKABLE void refreshBackupList();



signals:
    void steamCacheLog(const QString &message, const QString &type);
    // System info signals
    void osNameChanged(const QString &val);
    void cpuNameChanged(const QString &val);
    void logicalCoresChanged(const QString &val);
    void ramSizeChanged(const QString &val);
    void gpuNameChanged(const QString &val);
    void motherboardChanged(const QString &val);
    void storageChanged(const QString &val);
    void displayChanged(const QString &val);
    void cpuLoadPercentChanged(double val);
    void ramLoadPercentChanged(double val);

    // System Optimization signals
    void classicContextMenuActiveChanged(bool val);
    void originalClassicContextMenuActiveChanged(bool val);
    void shortcutArrowsActiveChanged(bool val);
    void originalShortcutArrowsActiveChanged(bool val);
    void clipboardHistoryActiveChanged(bool val);
    void originalClipboardHistoryActiveChanged(bool val);
    void taskbarEndTaskActiveChanged(bool val);
    void originalTaskbarEndTaskActiveChanged(bool val);
    void taskbarSecondsActiveChanged(bool val);
    void originalTaskbarSecondsActiveChanged(bool val);
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
    void hagsActiveChanged(bool val);
    void originalHagsActiveChanged(bool val);
    void mouseAccelerationActiveChanged(bool val);
    void originalMouseAccelerationActiveChanged(bool val);
    void gameModeActiveChanged(bool val);
    void originalGameModeActiveChanged(bool val);
    void firewallActiveChanged(bool val);
    void originalFirewallActiveChanged(bool val);
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
    void appNotificationSettingsChanged();
    void powerSchemesChanged(const QVariantList &val);
    void ultimateSchemeUnlockedChanged(bool val);
    void deleteUltimateStagedChanged(bool val);
    void deleteDefenderStagedChanged(bool val);
    void activePowerSchemeGuidChanged(const QString &val);
    void targetPowerSchemeGuidChanged(const QString &val);
    void mpoValueChanged(int val);
    void remoteAccessActiveChanged(bool val);
    void originalRemoteAccessActiveChanged(bool val);
    void telemetryActiveChanged(bool val);
    void originalTelemetryActiveChanged(bool val);
    void telemetryDiagTrackActiveChanged(bool val);
    void originalTelemetryDiagTrackActiveChanged(bool val);
    void telemetryWapPushActiveChanged(bool val);
    void originalTelemetryWapPushActiveChanged(bool val);
    void telemetryCeipActiveChanged(bool val);
    void originalTelemetryCeipActiveChanged(bool val);
    void telemetryWerActiveChanged(bool val);
    void originalTelemetryWerActiveChanged(bool val);

    // Ads Signals
    void adsTailoredExperiencesActiveChanged(bool val);
    void originalAdsTailoredExperiencesActiveChanged(bool val);
    void adsAdvertisingIdActiveChanged(bool val);
    void originalAdsAdvertisingIdActiveChanged(bool val);
    void adsSuggestedContentActiveChanged(bool val);
    void originalAdsSuggestedContentActiveChanged(bool val);
    void adsSettingsHomeActiveChanged(bool val);
    void originalAdsSettingsHomeActiveChanged(bool val);
    void adsSuggestedNotificationsActiveChanged(bool val);
    void originalAdsSuggestedNotificationsActiveChanged(bool val);
    void adsLockScreenTipsActiveChanged(bool val);
    void originalAdsLockScreenTipsActiveChanged(bool val);
    void adsWindowsTipsActiveChanged(bool val);
    void originalAdsWindowsTipsActiveChanged(bool val);
    void adsWelcomeExperienceActiveChanged(bool val);
    void originalAdsWelcomeExperienceActiveChanged(bool val);
    void adsFinishSetupActiveChanged(bool val);
    void originalAdsFinishSetupActiveChanged(bool val);

    // Privacy Signals
    void privacyLocationActiveChanged(bool val);
    void originalPrivacyLocationActiveChanged(bool val);
    void privacyTelemetryActiveChanged(bool val);
    void originalPrivacyTelemetryActiveChanged(bool val);
    void privacyCeipActiveChanged(bool val);
    void originalPrivacyCeipActiveChanged(bool val);
    void privacyAppsTelemetryActiveChanged(bool val);
    void originalPrivacyAppsTelemetryActiveChanged(bool val);
    void privacyAppLaunchesActiveChanged(bool val);
    void originalPrivacyAppLaunchesActiveChanged(bool val);
    void privacyImproveInkingActiveChanged(bool val);
    void originalPrivacyImproveInkingActiveChanged(bool val);
    void privacyPersonalizeInkingActiveChanged(bool val);
    void originalPrivacyPersonalizeInkingActiveChanged(bool val);
    void privacyErrorReportingActiveChanged(bool val);
    void originalPrivacyErrorReportingActiveChanged(bool val);
    void privacyLockScreenCameraActiveChanged(bool val);
    void originalPrivacyLockScreenCameraActiveChanged(bool val);
    void privacyCameraIndicatorActiveChanged(bool val);
    void originalPrivacyCameraIndicatorActiveChanged(bool val);
    void privacyOnlineSpeechActiveChanged(bool val);
    void originalPrivacyOnlineSpeechActiveChanged(bool val);

    // Superuser / More Rights signals
    void superuserGodModeActiveChanged(bool val);
    void originalSuperuserGodModeActiveChanged(bool val);
    void superuserDeveloperModeActiveChanged(bool val);
    void originalSuperuserDeveloperModeActiveChanged(bool val);
    void superuserUacLevelChanged(int val);
    void originalSuperuserUacLevelChanged(int val);
    void superuserUcpdActiveChanged(bool val);
    void originalSuperuserUcpdActiveChanged(bool val);

    void windowsUpdateModeChanged(int mode);
    void originalWindowsUpdateModeChanged(int mode);
    void cs2LaunchOptionsChanged(const QVariantMap &val);
    void originalCs2LaunchOptionsChanged(const QVariantMap &val);
    void steamOverlayActiveChanged(bool val);
    void originalSteamOverlayActiveChanged(bool val);
    void cs2OverlayActiveChanged(bool val);
    void originalCs2OverlayActiveChanged(bool val);
    void visualEffectsChanged(const QVariantMap &val);
    void originalVisualEffectsChanged(const QVariantMap &val);
    void steamInstalledChanged(bool val);
    void steamInstalledGamesChanged(const QVariantList &val);
    void steamFriendsSettingsChanged(const QVariantMap &val);
    void originalSteamFriendsSettingsChanged(const QVariantMap &val);
    void fixedDrivesChanged(const QStringList &val);
    void driveStatesChanged(const QVariantMap &val);
    void originalDriveStatesChanged(const QVariantMap &val);
    void pagefileMinChanged(int val);
    void originalPagefileMinChanged(int val);
    void pagefileMaxChanged(int val);
    void originalPagefileMaxChanged(int val);
    void pagefileAutoChanged(bool val);
    void originalPagefileAutoChanged(bool val);
    void isOptimizingSystemChanged(bool val);
    void systemProgressChanged(double val);
    void backupListChanged(const QVariantList &val);
    
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
    double m_cpuLoadPercent = 0.0;
    double m_ramLoadPercent = 0.0;
    void updateCpuAndRamLoad();
#ifdef Q_OS_WIN
    void* m_prevIdleTime = nullptr;
    void* m_prevKernelTime = nullptr;
    void* m_prevUserTime = nullptr;
#endif

    // System Optimization state
    bool m_classicContextMenuActive = false;
    bool m_originalClassicContextMenuActive = false;
    bool m_shortcutArrowsActive = true;
    bool m_originalShortcutArrowsActive = true;
    bool m_clipboardHistoryActive = false;
    bool m_originalClipboardHistoryActive = false;
    bool m_taskbarEndTaskActive = false;
    bool m_originalTaskbarEndTaskActive = false;
    bool m_taskbarSecondsActive = false;
    bool m_originalTaskbarSecondsActive = false;
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
    bool m_bootCoreIsolationActive = true;
    bool m_hagsActive = false;
    bool m_originalHagsActive = false;
    bool m_bootHagsActive = false;
    bool m_mouseAccelerationActive = false;
    bool m_originalMouseAccelerationActive = false;
    bool m_gameModeActive = true;
    bool m_originalGameModeActive = true;
    bool m_firewallActive = true;
    bool m_originalFirewallActive = true;
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
    QVariantList m_appNotificationSettings;
    QVariantList m_powerSchemes;
    bool m_ultimateSchemeUnlocked = false;
    bool m_deleteUltimateStaged = false;
    bool m_deleteDefenderStaged = false;
    QString m_activePowerSchemeGuid;
    QString m_targetPowerSchemeGuid;
    int m_mpoValue = 0;
    bool m_remoteAccessActive = false;
    bool m_originalRemoteAccessActive = false;
    bool m_telemetryActive = true;
    bool m_originalTelemetryActive = true;
    bool m_telemetryDiagTrackActive = true;
    bool m_originalTelemetryDiagTrackActive = true;
    bool m_telemetryWapPushActive = true;
    bool m_originalTelemetryWapPushActive = true;
    bool m_telemetryCeipActive = true;
    bool m_originalTelemetryCeipActive = true;
    bool m_telemetryWerActive = true;
    bool m_originalTelemetryWerActive = true;

    // Ads variables
    bool m_adsTailoredExperiencesActive = true;
    bool m_originalAdsTailoredExperiencesActive = true;
    bool m_adsAdvertisingIdActive = true;
    bool m_originalAdsAdvertisingIdActive = true;
    bool m_adsSuggestedContentActive = true;
    bool m_originalAdsSuggestedContentActive = true;
    bool m_adsSettingsHomeActive = true;
    bool m_originalAdsSettingsHomeActive = true;
    bool m_adsSuggestedNotificationsActive = true;
    bool m_originalAdsSuggestedNotificationsActive = true;
    bool m_adsLockScreenTipsActive = true;
    bool m_originalAdsLockScreenTipsActive = true;
    bool m_adsWindowsTipsActive = true;
    bool m_originalAdsWindowsTipsActive = true;
    bool m_adsWelcomeExperienceActive = true;
    bool m_originalAdsWelcomeExperienceActive = true;
    bool m_adsFinishSetupActive = true;
    bool m_originalAdsFinishSetupActive = true;

    // Privacy variables
    bool m_privacyLocationActive = true;
    bool m_originalPrivacyLocationActive = true;
    bool m_privacyTelemetryActive = true;
    bool m_originalPrivacyTelemetryActive = true;
    bool m_privacyCeipActive = true;
    bool m_originalPrivacyCeipActive = true;
    bool m_privacyAppsTelemetryActive = true;
    bool m_originalPrivacyAppsTelemetryActive = true;
    bool m_privacyAppLaunchesActive = true;
    bool m_originalPrivacyAppLaunchesActive = true;
    bool m_privacyImproveInkingActive = true;
    bool m_originalPrivacyImproveInkingActive = true;
    bool m_privacyPersonalizeInkingActive = true;
    bool m_originalPrivacyPersonalizeInkingActive = true;
    bool m_privacyErrorReportingActive = true;
    bool m_originalPrivacyErrorReportingActive = true;
    bool m_privacyLockScreenCameraActive = true;
    bool m_originalPrivacyLockScreenCameraActive = true;
    bool m_privacyCameraIndicatorActive = true;
    bool m_originalPrivacyCameraIndicatorActive = true;
    bool m_privacyOnlineSpeechActive = true;
    bool m_originalPrivacyOnlineSpeechActive = true;

    // Superuser / More Rights member variables
    bool m_superuserGodModeActive = false;
    bool m_originalSuperuserGodModeActive = false;
    bool m_superuserDeveloperModeActive = false;
    bool m_originalSuperuserDeveloperModeActive = false;
    int m_superuserUacLevel = 1;
    int m_originalSuperuserUacLevel = 1;
    bool m_superuserUcpdActive = true;
    bool m_originalSuperuserUcpdActive = true;

    int m_windowsUpdateMode = 0;
    int m_originalWindowsUpdateMode = 0;
    QVariantMap m_cs2LaunchOptions;
    QVariantMap m_originalCs2LaunchOptions;
    bool m_steamOverlayActive = true;
    bool m_originalSteamOverlayActive = true;
    bool m_cs2OverlayActive = true;
    bool m_originalCs2OverlayActive = true;
    QVariantMap m_visualEffects;
    QVariantMap m_originalVisualEffects;
    QStringList m_fixedDrives;
    QVariantMap m_driveStates;
    QVariantMap m_originalDriveStates;
    bool m_steamInstalled = false;
    QVariantList m_steamInstalledGames;
    QVariantMap m_steamFriendsSettings;
    QVariantMap m_originalSteamFriendsSettings;
    bool getVdfFriendsSettings(const QString &filePath, const QString &accountId, QVariantMap &settings);
    bool updateVdfFriendsSettings(const QString &filePath, const QString &accountId, const QVariantMap &settings);
    bool m_isOptimizingSystem = false;
    double m_systemProgress = 0.0;
    int m_pagefileMin = 4096;
    int m_originalPagefileMin = 4096;
    int m_pagefileMax = 8192;
    int m_originalPagefileMax = 8192;
    bool m_pagefileAuto = true;
    bool m_originalPagefileAuto = true;
    void loadPagefileSettings();
    bool m_forceApplyAll = false;
    QVariantList m_backupList;
};
