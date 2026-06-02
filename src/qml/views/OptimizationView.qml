import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeguPackOptimizer 1.0
import Qt5Compat.GraphicalEffects
import "../components"

Item {
    id: root
    anchors.fill: parent
    focus: true

    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: {
            root.forceActiveFocus();
        }
    }

    property string currentSection: "core"

    // Premium reactive entry transition (runs butter-smooth on every tab switch!)
    property bool isActive: opacity > 0.1
    property real yTranslation: isActive ? 0 : 15

    transform: Translate {
        y: root.yTranslation
    }

    Behavior on yTranslation {
        NumberAnimation {
            duration: Theme.animNormal
            easing.type: Easing.OutCubic
        }
    }

    // Tri-State derived logic for main switch based on live states in backend
    property bool allChecked: {
        if (!optimizerBackend.winSearchActive) return false;
        if (!optimizerBackend.driveStates || !optimizerBackend.driveStates["C:"]) return false;
        var drives = optimizerBackend.fixedDrives;
        for (var i = 0; i < drives.length; i++) {
            var letter = drives[i];
            if (!optimizerBackend.driveStates[letter]) return false;
        }
        return true;
    }
    property bool allUnchecked: {
        if (optimizerBackend.winSearchActive) return false;
        if (!optimizerBackend.driveStates || optimizerBackend.driveStates["C:"]) return false;
        var drives = optimizerBackend.fixedDrives;
        for (var i = 0; i < drives.length; i++) {
            var letter = drives[i];
            if (optimizerBackend.driveStates[letter]) return false;
        }
        return true;
    }
    property bool mainChecked: allChecked
    property bool mainIndeterminate: !allChecked && !allUnchecked

    // Tri-State derived logic for Windows Defender
    property bool allDefenderChecked: optimizerBackend.defenderRegistryActive && optimizerBackend.defenderCmdActive && optimizerBackend.defenderServiceActive
    property bool allDefenderUnchecked: !optimizerBackend.defenderRegistryActive && !optimizerBackend.defenderCmdActive && !optimizerBackend.defenderServiceActive
    property bool defenderChecked: allDefenderChecked
    property bool defenderIndeterminate: !allDefenderChecked && !allDefenderUnchecked

    // Tri-State derived logic for Windows Notifications
    property bool allNotificationsChecked: optimizerBackend.notifGlobalActive && optimizerBackend.notifAppActive && optimizerBackend.notifSoundsActive && optimizerBackend.notifLockscreenActive
    property bool allNotificationsUnchecked: !optimizerBackend.notifGlobalActive && !optimizerBackend.notifAppActive && !optimizerBackend.notifSoundsActive && !optimizerBackend.notifLockscreenActive
    property bool notificationsChecked: allNotificationsChecked
    property bool notificationsIndeterminate: !allNotificationsChecked && !allNotificationsUnchecked

    // Tri-State derived logic for Telemetry
    property bool allTelemetryChecked: !optimizerBackend.telemetryDiagTrackActive && !optimizerBackend.telemetryWapPushActive && !optimizerBackend.telemetryCeipActive && !optimizerBackend.telemetryWerActive
    property bool allTelemetryUnchecked: optimizerBackend.telemetryDiagTrackActive && optimizerBackend.telemetryWapPushActive && optimizerBackend.telemetryCeipActive && optimizerBackend.telemetryWerActive
    property bool telemetryChecked: allTelemetryChecked
    property bool telemetryIndeterminate: !allTelemetryChecked && !allTelemetryUnchecked

    // Tri-State derived logic for USB 3.0 Power Saving
    property bool allUsbChecked: {
        var devices = optimizerBackend.usbDevices;
        if (!devices || devices.length === 0) return false;
        for (var i = 0; i < devices.length; i++) {
            if (!devices[i].powerSavingActive) return false;
        }
        return true;
    }
    property bool allUsbUnchecked: {
        var devices = optimizerBackend.usbDevices;
        if (!devices || devices.length === 0) return true;
        for (var i = 0; i < devices.length; i++) {
            if (devices[i].powerSavingActive) return false;
        }
        return true;
    }
    property bool usbChecked: allUsbChecked
    property bool usbIndeterminate: !allUsbChecked && !allUsbUnchecked

    // Reactive computation of changes between current live states and original states
    property bool hasChanges: {
        if (optimizerBackend.classicContextMenuActive !== optimizerBackend.originalClassicContextMenuActive) return true;
        if (optimizerBackend.shortcutArrowsActive !== optimizerBackend.originalShortcutArrowsActive) return true;
        if (optimizerBackend.clipboardHistoryActive !== optimizerBackend.originalClipboardHistoryActive) return true;
        if (optimizerBackend.taskbarEndTaskActive !== optimizerBackend.originalTaskbarEndTaskActive) return true;
        if (optimizerBackend.taskbarSecondsActive !== optimizerBackend.originalTaskbarSecondsActive) return true;
        if (optimizerBackend.winSearchActive !== optimizerBackend.originalWinSearchActive) return true;
        if (optimizerBackend.hibernationActive !== optimizerBackend.originalHibernationActive) return true;
        if (optimizerBackend.gamingOverlayActive !== optimizerBackend.originalGamingOverlayActive) return true;
        if (optimizerBackend.coreIsolationActive !== optimizerBackend.originalCoreIsolationActive) return true;
        if (optimizerBackend.mouseAccelerationActive !== optimizerBackend.originalMouseAccelerationActive) return true;
        if (optimizerBackend.gameModeActive !== optimizerBackend.originalGameModeActive) return true;
        if (optimizerBackend.firewallActive !== optimizerBackend.originalFirewallActive) return true;
        if (optimizerBackend.bitlockerActive !== optimizerBackend.originalBitlockerActive) return true;
        if (optimizerBackend.discordOverlayActive !== optimizerBackend.originalDiscordOverlayActive) return true;
        if (optimizerBackend.notificationsActive !== optimizerBackend.originalNotificationsActive) return true;
        if (optimizerBackend.notifGlobalActive !== optimizerBackend.originalNotifGlobalActive) return true;
        if (optimizerBackend.notifAppActive !== optimizerBackend.originalNotifAppActive) return true;
        if (optimizerBackend.notifSoundsActive !== optimizerBackend.originalNotifSoundsActive) return true;
        if (optimizerBackend.notifLockscreenActive !== optimizerBackend.originalNotifLockscreenActive) return true;
        if (optimizerBackend.targetPowerSchemeGuid !== optimizerBackend.activePowerSchemeGuid) return true;
        if (optimizerBackend.deleteUltimateStaged) return true;
        if (optimizerBackend.deleteDefenderStaged) return true;
        if (optimizerBackend.defenderActive !== optimizerBackend.originalDefenderActive) return true;
        if (optimizerBackend.defenderRegistryActive !== optimizerBackend.originalDefenderRegistryActive) return true;
        if (optimizerBackend.defenderCmdActive !== optimizerBackend.originalDefenderCmdActive) return true;
        if (optimizerBackend.defenderServiceActive !== optimizerBackend.originalDefenderServiceActive) return true;
        if (optimizerBackend.remoteAccessActive !== optimizerBackend.originalRemoteAccessActive) return true;
        if (optimizerBackend.usbChanged) return true;
        if (optimizerBackend.telemetryActive !== optimizerBackend.originalTelemetryActive) return true;
        if (optimizerBackend.telemetryDiagTrackActive !== optimizerBackend.originalTelemetryDiagTrackActive) return true;
        if (optimizerBackend.telemetryWapPushActive !== optimizerBackend.originalTelemetryWapPushActive) return true;
        if (optimizerBackend.telemetryCeipActive !== optimizerBackend.originalTelemetryCeipActive) return true;
        if (optimizerBackend.telemetryWerActive !== optimizerBackend.originalTelemetryWerActive) return true;
        if (optimizerBackend.adsTailoredExperiencesActive !== optimizerBackend.originalAdsTailoredExperiencesActive) return true;
        if (optimizerBackend.adsAdvertisingIdActive !== optimizerBackend.originalAdsAdvertisingIdActive) return true;
        if (optimizerBackend.adsSuggestedContentActive !== optimizerBackend.originalAdsSuggestedContentActive) return true;
        if (optimizerBackend.adsSettingsHomeActive !== optimizerBackend.originalAdsSettingsHomeActive) return true;
        if (optimizerBackend.adsSuggestedNotificationsActive !== optimizerBackend.originalAdsSuggestedNotificationsActive) return true;
        if (optimizerBackend.adsLockScreenTipsActive !== optimizerBackend.originalAdsLockScreenTipsActive) return true;
        if (optimizerBackend.adsWindowsTipsActive !== optimizerBackend.originalAdsWindowsTipsActive) return true;
        if (optimizerBackend.adsWelcomeExperienceActive !== optimizerBackend.originalAdsWelcomeExperienceActive) return true;
        if (optimizerBackend.adsFinishSetupActive !== optimizerBackend.originalAdsFinishSetupActive) return true;
        if (optimizerBackend.windowsUpdateMode !== optimizerBackend.originalWindowsUpdateMode) return true;
        if (cs2Changed) return true;
        if (optimizerBackend.steamOverlayActive !== optimizerBackend.originalSteamOverlayActive) return true;
        if (optimizerBackend.cs2OverlayActive !== optimizerBackend.originalCs2OverlayActive) return true;
        if (steamFriendsSettingsChanged) return true;
        if (visualEffectsChanged) return true;
        if (optimizerBackend.pagefileMin !== optimizerBackend.originalPagefileMin) return true;
        if (optimizerBackend.pagefileMax !== optimizerBackend.originalPagefileMax) return true;
        if (!optimizerBackend.driveStates || !optimizerBackend.originalDriveStates) return false;
        var keys = Object.keys(optimizerBackend.driveStates);
        for (var i = 0; i < keys.length; i++) {
            var key = keys[i];
            if (optimizerBackend.driveStates[key] !== optimizerBackend.originalDriveStates[key]) return true;
        }
        return false;
    }

    property bool pagefileChanged: optimizerBackend.pagefileMin !== optimizerBackend.originalPagefileMin || optimizerBackend.pagefileMax !== optimizerBackend.originalPagefileMax
    property bool classicContextMenuChanged: optimizerBackend.classicContextMenuActive !== optimizerBackend.originalClassicContextMenuActive
    property bool shortcutArrowsChanged: optimizerBackend.shortcutArrowsActive !== optimizerBackend.originalShortcutArrowsActive
    property bool clipboardHistoryChanged: optimizerBackend.clipboardHistoryActive !== optimizerBackend.originalClipboardHistoryActive
    property bool taskbarEndTaskChanged: optimizerBackend.taskbarEndTaskActive !== optimizerBackend.originalTaskbarEndTaskActive
    property bool taskbarSecondsChanged: optimizerBackend.taskbarSecondsActive !== optimizerBackend.originalTaskbarSecondsActive

    property bool indexingChanged: {
        if (optimizerBackend.winSearchActive !== optimizerBackend.originalWinSearchActive) return true;
        if (!optimizerBackend.driveStates || !optimizerBackend.originalDriveStates) return false;
        var keys = Object.keys(optimizerBackend.driveStates);
        for (var i = 0; i < keys.length; i++) {
            var key = keys[i];
            if (optimizerBackend.driveStates[key] !== optimizerBackend.originalDriveStates[key]) return true;
        }
        return false;
    }
    property bool xboxChanged: optimizerBackend.gamingOverlayActive !== optimizerBackend.originalGamingOverlayActive
    property bool coreIsolationChanged: optimizerBackend.coreIsolationActive !== optimizerBackend.originalCoreIsolationActive
    property bool mouseAccelerationChanged: optimizerBackend.mouseAccelerationActive !== optimizerBackend.originalMouseAccelerationActive
    property bool gameModeChanged: optimizerBackend.gameModeActive !== optimizerBackend.originalGameModeActive
    property bool firewallChanged: optimizerBackend.firewallActive !== optimizerBackend.originalFirewallActive
    property bool notificationsChanged: {
        if (optimizerBackend.notificationsActive !== optimizerBackend.originalNotificationsActive) return true;
        if (optimizerBackend.notifGlobalActive !== optimizerBackend.originalNotifGlobalActive) return true;
        if (optimizerBackend.notifAppActive !== optimizerBackend.originalNotifAppActive) return true;
        if (optimizerBackend.notifSoundsActive !== optimizerBackend.originalNotifSoundsActive) return true;
        if (optimizerBackend.notifLockscreenActive !== optimizerBackend.originalNotifLockscreenActive) return true;
        return false;
    }
    property bool hibernationChanged: optimizerBackend.hibernationActive !== optimizerBackend.originalHibernationActive
    property bool powerPlanChanged: optimizerBackend.targetPowerSchemeGuid !== optimizerBackend.activePowerSchemeGuid
    property bool bitlockerChanged: optimizerBackend.bitlockerActive !== optimizerBackend.originalBitlockerActive
    property bool discordOverlayChanged: optimizerBackend.discordOverlayActive !== optimizerBackend.originalDiscordOverlayActive
    property bool defenderChanged: optimizerBackend.defenderActive !== optimizerBackend.originalDefenderActive ||
                                   optimizerBackend.defenderRegistryActive !== optimizerBackend.originalDefenderRegistryActive ||
                                   optimizerBackend.defenderCmdActive !== optimizerBackend.originalDefenderCmdActive ||
                                   optimizerBackend.defenderServiceActive !== optimizerBackend.originalDefenderServiceActive
    property bool usbPowerSavingChanged: optimizerBackend.usbChanged
    property bool remoteAccessChanged: optimizerBackend.remoteAccessActive !== optimizerBackend.originalRemoteAccessActive
    property bool telemetryChanged: {
        if (optimizerBackend.telemetryActive !== optimizerBackend.originalTelemetryActive) return true;
        if (optimizerBackend.telemetryDiagTrackActive !== optimizerBackend.originalTelemetryDiagTrackActive) return true;
        if (optimizerBackend.telemetryWapPushActive !== optimizerBackend.originalTelemetryWapPushActive) return true;
        if (optimizerBackend.telemetryCeipActive !== optimizerBackend.originalTelemetryCeipActive) return true;
        if (optimizerBackend.telemetryWerActive !== optimizerBackend.originalTelemetryWerActive) return true;
        return false;
    }
    property bool adsChanged: {
        if (optimizerBackend.adsTailoredExperiencesActive !== optimizerBackend.originalAdsTailoredExperiencesActive) return true;
        if (optimizerBackend.adsAdvertisingIdActive !== optimizerBackend.originalAdsAdvertisingIdActive) return true;
        if (optimizerBackend.adsSuggestedContentActive !== optimizerBackend.originalAdsSuggestedContentActive) return true;
        if (optimizerBackend.adsSettingsHomeActive !== optimizerBackend.originalAdsSettingsHomeActive) return true;
        if (optimizerBackend.adsSuggestedNotificationsActive !== optimizerBackend.originalAdsSuggestedNotificationsActive) return true;
        if (optimizerBackend.adsLockScreenTipsActive !== optimizerBackend.originalAdsLockScreenTipsActive) return true;
        if (optimizerBackend.adsWindowsTipsActive !== optimizerBackend.originalAdsWindowsTipsActive) return true;
        if (optimizerBackend.adsWelcomeExperienceActive !== optimizerBackend.originalAdsWelcomeExperienceActive) return true;
        if (optimizerBackend.adsFinishSetupActive !== optimizerBackend.originalAdsFinishSetupActive) return true;
        return false;
    }
    property bool windowsUpdateChanged: optimizerBackend.windowsUpdateMode !== optimizerBackend.originalWindowsUpdateMode
    property bool steamOverlayChanged: optimizerBackend.steamOverlayActive !== optimizerBackend.originalSteamOverlayActive
    property bool cs2OverlayChanged: optimizerBackend.cs2OverlayActive !== optimizerBackend.originalCs2OverlayActive
    property bool steamFriendsSettingsChanged: JSON.stringify(optimizerBackend.steamFriendsSettings) !== JSON.stringify(optimizerBackend.originalSteamFriendsSettings)
    property bool visualEffectsChanged: {
        var current = optimizerBackend.visualEffects;
        var original = optimizerBackend.originalVisualEffects;
        if (!current || !original) return false;
        var keys = Object.keys(current);
        for (var i = 0; i < keys.length; i++) {
            var key = keys[i];
            if (current[key] !== original[key]) return true;
        }
        return false;
    }

    property int visualEffectsPreset: {
        var current = optimizerBackend.visualEffects;
        if (!current) return 3;
        var keys = Object.keys(current);
        if (keys.length === 0) return 3;
        
        var allTrue = true;
        var allFalse = true;
        for (var i = 0; i < keys.length; i++) {
            if (current[keys[i]]) {
                allFalse = false;
            } else {
                allTrue = false;
            }
        }
        if (allTrue) return 1;
        if (allFalse) return 2;
        return localVfxPresetState;
    }

    property int localVfxPresetState: 3

    function setPreset(presetId) {
        localVfxPresetState = presetId;
        var current = optimizerBackend.visualEffects;
        if (!current) return;
        var newEffects = {};
        var keys = Object.keys(current);
        
        if (presetId === 1) { // Best appearance
            for (var i = 0; i < keys.length; i++) {
                newEffects[keys[i]] = true;
            }
        } else if (presetId === 2) { // Best performance
            for (var i = 0; i < keys.length; i++) {
                newEffects[keys[i]] = false;
            }
        } else if (presetId === 0) { // Let Windows choose
            var defaults = {
                "animateControls": true,
                "animateWindows": true,
                "animateTaskbar": true,
                "enablePeek": true,
                "fadeMenus": true,
                "fadeTooltips": true,
                "fadeMenuSelection": true,
                "saveThumbnails": true,
                "shadowPointer": true,
                "shadowWindows": true,
                "showThumbnails": true,
                "translucentSelection": true,
                "dragContents": true,
                "slideComboBoxes": true,
                "smoothFonts": true,
                "smoothScroll": true,
                "dropShadowsDesktop": true
            };
            for (var i = 0; i < keys.length; i++) {
                newEffects[keys[i]] = defaults[keys[i]] !== undefined ? defaults[keys[i]] : true;
            }
        } else {
            return;
        }
        optimizerBackend.visualEffects = newEffects;
    }

    function toggleVisualEffect(key, isChecked) {
        var current = optimizerBackend.visualEffects;
        if (current && current[key] !== isChecked) {
            var optMap = {};
            var keys = Object.keys(current);
            for (var i = 0; i < keys.length; i++) {
                optMap[keys[i]] = current[keys[i]];
            }
            optMap[key] = isChecked;
            optimizerBackend.visualEffects = optMap;
            localVfxPresetState = 3; // Custom
        }
    }

    function toggleSteamFriendsSetting(key, isChecked) {
        var current = optimizerBackend.steamFriendsSettings;
        if (current) {
            var optMap = {};
            var keys = Object.keys(current);
            for (var i = 0; i < keys.length; i++) {
                optMap[keys[i]] = current[keys[i]];
            }
            optMap[key] = isChecked;
            optimizerBackend.steamFriendsSettings = optMap;
        }
    }

    property bool cs2Changed: {
        var current = optimizerBackend.cs2LaunchOptions;
        var original = optimizerBackend.originalCs2LaunchOptions;
        if (!current || !original) return false;
        var keys = Object.keys(current);
        for (var i = 0; i < keys.length; i++) {
            var key = keys[i];
            if (current[key] !== original[key]) return true;
        }
        var origKeys = Object.keys(original);
        for (var j = 0; j < origKeys.length; j++) {
            var origKey = origKeys[j];
            if (current[origKey] !== original[origKey]) return true;
        }
        return false;
    }

    property bool isDiscordOpen: false
    Timer {
        id: discordCheckTimer
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root.isDiscordOpen = optimizerBackend.isDiscordRunning();
        }
    }

    // Active sidebar state
    property string activeDrawer: ""
    property bool sidebarOpen: activeDrawer !== ""

    property bool islandExpanded: false
    property string currentIslandPage: "main"
    property string islandDetailCategory: ""

    property int pendingChangesCount: {
        var count = 0;
        if (classicContextMenuChanged) count++;
        if (shortcutArrowsChanged) count++;
        if (clipboardHistoryChanged) count++;
        if (taskbarEndTaskChanged) count++;
        if (taskbarSecondsChanged) count++;
        if (indexingChanged) count++;
        if (xboxChanged) count++;
        if (coreIsolationChanged) count++;
        if (mouseAccelerationChanged) count++;
        if (gameModeChanged) count++;
        if (firewallChanged) count++;
        if (notificationsChanged) count++;
        if (hibernationChanged) count++;
        if (powerPlanChanged || optimizerBackend.deleteUltimateStaged) count++;
        if (bitlockerChanged) count++;
        if (discordOverlayChanged) count++;
        if (defenderChanged || optimizerBackend.deleteDefenderStaged) count++;
        if (usbPowerSavingChanged) count++;
        if (remoteAccessChanged) count++;
        if (telemetryChanged) count++;
        if (windowsUpdateChanged) count++;
        if (cs2Changed) count++;
        if (steamOverlayChanged) count++;
        if (cs2OverlayChanged) count++;
        if (steamFriendsSettingsChanged) count++;
        if (visualEffectsChanged) count++;
        if (pagefileChanged) count++;
        if (adsChanged) count++;
        return count;
    }

    property int mainChangesCount: {
        var count = 0;
        if (optimizerBackend.classicContextMenuActive !== optimizerBackend.originalClassicContextMenuActive) count++;
        if (optimizerBackend.shortcutArrowsActive !== optimizerBackend.originalShortcutArrowsActive) count++;
        if (optimizerBackend.clipboardHistoryActive !== optimizerBackend.originalClipboardHistoryActive) count++;
        if (optimizerBackend.taskbarEndTaskActive !== optimizerBackend.originalTaskbarEndTaskActive) count++;
        if (optimizerBackend.taskbarSecondsActive !== optimizerBackend.originalTaskbarSecondsActive) count++;
        if (optimizerBackend.winSearchActive !== optimizerBackend.originalWinSearchActive) count++;
        if (optimizerBackend.gamingOverlayActive !== optimizerBackend.originalGamingOverlayActive) count++;
        if (optimizerBackend.coreIsolationActive !== optimizerBackend.originalCoreIsolationActive) count++;
        if (optimizerBackend.mouseAccelerationActive !== optimizerBackend.originalMouseAccelerationActive) count++;
        if (optimizerBackend.gameModeActive !== optimizerBackend.originalGameModeActive) count++;
        if (optimizerBackend.firewallActive !== optimizerBackend.originalFirewallActive) count++;
        if (optimizerBackend.notificationsActive !== optimizerBackend.originalNotificationsActive) count++;
        if (optimizerBackend.hibernationActive !== optimizerBackend.originalHibernationActive) count++;
        if (optimizerBackend.bitlockerActive !== optimizerBackend.originalBitlockerActive) count++;
        if (optimizerBackend.discordOverlayActive !== optimizerBackend.originalDiscordOverlayActive) count++;
        if (optimizerBackend.defenderActive !== optimizerBackend.originalDefenderActive) count++;
        if (optimizerBackend.usbPowerSavingActive !== optimizerBackend.originalUsbPowerSavingActive) count++;
        if (optimizerBackend.remoteAccessActive !== optimizerBackend.originalRemoteAccessActive) count++;
        if (optimizerBackend.telemetryActive !== optimizerBackend.originalTelemetryActive) count++;
        if (optimizerBackend.adsTailoredExperiencesActive !== optimizerBackend.originalAdsTailoredExperiencesActive) count++;
        if (optimizerBackend.adsAdvertisingIdActive !== optimizerBackend.originalAdsAdvertisingIdActive) count++;
        if (optimizerBackend.adsSuggestedContentActive !== optimizerBackend.originalAdsSuggestedContentActive) count++;
        if (optimizerBackend.adsSettingsHomeActive !== optimizerBackend.originalAdsSettingsHomeActive) count++;
        if (optimizerBackend.adsSuggestedNotificationsActive !== optimizerBackend.originalAdsSuggestedNotificationsActive) count++;
        if (optimizerBackend.adsLockScreenTipsActive !== optimizerBackend.originalAdsLockScreenTipsActive) count++;
        if (optimizerBackend.adsWindowsTipsActive !== optimizerBackend.originalAdsWindowsTipsActive) count++;
        if (optimizerBackend.adsWelcomeExperienceActive !== optimizerBackend.originalAdsWelcomeExperienceActive) count++;
        if (optimizerBackend.adsFinishSetupActive !== optimizerBackend.originalAdsFinishSetupActive) count++;
        if (pagefileChanged) count++;
        return count;
    }

    property int sidebarChangesCount: {
        var count = 0;
        if (optimizerBackend.driveStates && optimizerBackend.originalDriveStates) {
            var keys = Object.keys(optimizerBackend.driveStates);
            for (var i = 0; i < keys.length; i++) {
                var key = keys[i];
                if (optimizerBackend.driveStates[key] !== optimizerBackend.originalDriveStates[key]) {
                    count++;
                }
            }
        }
        if (optimizerBackend.defenderRegistryActive !== optimizerBackend.originalDefenderRegistryActive) count++;
        if (optimizerBackend.defenderCmdActive !== optimizerBackend.originalDefenderCmdActive) count++;
        if (optimizerBackend.defenderServiceActive !== optimizerBackend.originalDefenderServiceActive) count++;
        if (optimizerBackend.usbDevices && optimizerBackend.originalUsbDevices) {
            for (var j = 0; j < optimizerBackend.usbDevices.length; j++) {
                var currentDev = optimizerBackend.usbDevices[j];
                var originalDev = optimizerBackend.originalUsbDevices[j];
                if (currentDev && originalDev && currentDev.powerSavingActive !== originalDev.powerSavingActive) {
                    count++;
                }
            }
        }
        if (optimizerBackend.notifGlobalActive !== optimizerBackend.originalNotifGlobalActive) count++;
        if (optimizerBackend.notifAppActive !== optimizerBackend.originalNotifAppActive) count++;
        if (optimizerBackend.notifSoundsActive !== optimizerBackend.originalNotifSoundsActive) count++;
        if (optimizerBackend.notifLockscreenActive !== optimizerBackend.originalNotifLockscreenActive) count++;
        if (optimizerBackend.telemetryDiagTrackActive !== optimizerBackend.originalTelemetryDiagTrackActive) count++;
        if (optimizerBackend.telemetryWapPushActive !== optimizerBackend.originalTelemetryWapPushActive) count++;
        if (optimizerBackend.telemetryCeipActive !== optimizerBackend.originalTelemetryCeipActive) count++;
        if (optimizerBackend.telemetryWerActive !== optimizerBackend.originalTelemetryWerActive) count++;
        if (optimizerBackend.targetPowerSchemeGuid !== optimizerBackend.activePowerSchemeGuid) count++;
        if (optimizerBackend.windowsUpdateMode !== optimizerBackend.originalWindowsUpdateMode) count++;
        if (optimizerBackend.cs2LaunchOptions && optimizerBackend.originalCs2LaunchOptions) {
            var cs2Keys = Object.keys(optimizerBackend.cs2LaunchOptions);
            for (var c = 0; c < cs2Keys.length; c++) {
                var ck = cs2Keys[c];
                if (optimizerBackend.cs2LaunchOptions[ck] !== optimizerBackend.originalCs2LaunchOptions[ck]) {
                    count++;
                }
            }
        }
        if (optimizerBackend.steamFriendsSettings && optimizerBackend.originalSteamFriendsSettings) {
            var steamKeys = Object.keys(optimizerBackend.steamFriendsSettings);
            for (var s = 0; s < steamKeys.length; s++) {
                var sk = steamKeys[s];
                if (optimizerBackend.steamFriendsSettings[sk] !== optimizerBackend.originalSteamFriendsSettings[sk]) {
                    count++;
                }
            }
        }
        if (optimizerBackend.visualEffects && optimizerBackend.originalVisualEffects) {
            var vfxKeys = Object.keys(optimizerBackend.visualEffects);
            for (var v = 0; v < vfxKeys.length; v++) {
                var vk = vfxKeys[v];
                if (optimizerBackend.visualEffects[vk] !== optimizerBackend.originalVisualEffects[vk]) {
                    count++;
                }
            }
        }
        return count;
    }

    property var pendingChangesList: {
        var lang = settingsBackend.language;
        var list = [];
        if (classicContextMenuChanged) list.push({
            name: qsTr("Classic Context Menu"),
            icon: "qrc:/MeguPackOptimizer/src/resources/settings.svg",
            hasSidebar: false,
            revert: function() {
                optimizerBackend.classicContextMenuActive = optimizerBackend.originalClassicContextMenuActive;
            }
        });
        if (shortcutArrowsChanged) list.push({
            name: qsTr("Shortcut Arrow Overlays"),
            icon: "qrc:/MeguPackOptimizer/src/resources/arrow.svg",
            hasSidebar: false,
            revert: function() {
                optimizerBackend.shortcutArrowsActive = optimizerBackend.originalShortcutArrowsActive;
            }
        });
        if (clipboardHistoryChanged) list.push({
            name: qsTr("Clipboard History"),
            icon: "qrc:/MeguPackOptimizer/src/resources/settings.svg",
            hasSidebar: false,
            revert: function() {
                optimizerBackend.clipboardHistoryActive = optimizerBackend.originalClipboardHistoryActive;
            }
        });
        if (taskbarEndTaskChanged) list.push({
            name: qsTr("Taskbar 'End task'"),
            icon: "qrc:/MeguPackOptimizer/src/resources/settings.svg",
            hasSidebar: false,
            revert: function() {
                optimizerBackend.taskbarEndTaskActive = optimizerBackend.originalTaskbarEndTaskActive;
            }
        });
        if (taskbarSecondsChanged) list.push({
            name: qsTr("Clock with seconds"),
            icon: "qrc:/MeguPackOptimizer/src/resources/settings.svg",
            hasSidebar: false,
            revert: function() {
                optimizerBackend.taskbarSecondsActive = optimizerBackend.originalTaskbarSecondsActive;
            }
        });
        if (indexingChanged) list.push({
            name: qsTr("File Indexing"),
            icon: "qrc:/MeguPackOptimizer/src/resources/storage.svg",
            hasSidebar: true,
            revert: function() {
                optimizerBackend.winSearchActive = optimizerBackend.originalWinSearchActive;
                optimizerBackend.driveStates = optimizerBackend.originalDriveStates;
            }
        });
        if (xboxChanged) list.push({
            name: qsTr("Xbox App & Game Bar"),
            icon: "qrc:/MeguPackOptimizer/src/resources/play.svg",
            hasSidebar: true,
            revert: function() {
                optimizerBackend.gamingOverlayActive = optimizerBackend.originalGamingOverlayActive;
            }
        });
        if (coreIsolationChanged) list.push({
            name: qsTr("Core Isolation"),
            icon: "qrc:/MeguPackOptimizer/src/resources/info.svg",
            hasSidebar: false,
            revert: function() {
                optimizerBackend.coreIsolationActive = optimizerBackend.originalCoreIsolationActive;
            }
        });
        if (mouseAccelerationChanged) list.push({
            name: qsTr("Mouse Acceleration"),
            icon: "qrc:/MeguPackOptimizer/src/resources/arrow.svg",
            hasSidebar: false,
            revert: function() {
                optimizerBackend.mouseAccelerationActive = optimizerBackend.originalMouseAccelerationActive;
            }
        });
        if (gameModeChanged) list.push({
            name: qsTr("Game Mode"),
            icon: "qrc:/MeguPackOptimizer/src/resources/bolt.svg",
            hasSidebar: false,
            revert: function() {
                optimizerBackend.gameModeActive = optimizerBackend.originalGameModeActive;
            }
        });
        if (firewallChanged) list.push({
            name: qsTr("Windows Defender Firewall"),
            icon: "qrc:/MeguPackOptimizer/src/resources/info.svg",
            hasSidebar: false,
            revert: function() {
                optimizerBackend.firewallActive = optimizerBackend.originalFirewallActive;
            }
        });
        if (notificationsChanged) list.push({
            name: qsTr("Windows Notifications"),
            icon: "qrc:/MeguPackOptimizer/src/resources/info.svg",
            hasSidebar: true,
            revert: function() {
                optimizerBackend.notificationsActive = optimizerBackend.originalNotificationsActive;
                optimizerBackend.notifGlobalActive = optimizerBackend.originalNotifGlobalActive;
                optimizerBackend.notifAppActive = optimizerBackend.originalNotifAppActive;
                optimizerBackend.notifSoundsActive = optimizerBackend.originalNotifSoundsActive;
                optimizerBackend.notifLockscreenActive = optimizerBackend.originalNotifLockscreenActive;
            }
        });
        if (hibernationChanged) list.push({
            name: qsTr("System Hibernation"),
            icon: "qrc:/MeguPackOptimizer/src/resources/folder.svg",
            hasSidebar: false,
            revert: function() {
                optimizerBackend.hibernationActive = optimizerBackend.originalHibernationActive;
            }
        });
        if (powerPlanChanged || optimizerBackend.deleteUltimateStaged) list.push({
            name: qsTr("Power Plan"),
            icon: "qrc:/MeguPackOptimizer/src/resources/bolt.svg",
            hasSidebar: true,
            revert: function() {
                optimizerBackend.deleteUltimateStaged = false;
                optimizerBackend.selectPowerScheme(optimizerBackend.activePowerSchemeGuid);
            }
        });
        if (bitlockerChanged) list.push({
            name: qsTr("BitLocker Drive Encryption"),
            icon: "qrc:/MeguPackOptimizer/src/resources/info.svg",
            hasSidebar: false,
            revert: function() {
                optimizerBackend.bitlockerActive = optimizerBackend.originalBitlockerActive;
            }
        });
        if (discordOverlayChanged) list.push({
            name: qsTr("Discord In-Game Overlay"),
            icon: "qrc:/MeguPackOptimizer/src/resources/folder.svg",
            hasSidebar: false,
            revert: function() {
                optimizerBackend.discordOverlayActive = optimizerBackend.originalDiscordOverlayActive;
            }
        });
        if (defenderChanged || optimizerBackend.deleteDefenderStaged) list.push({
            name: qsTr("Windows Defender"),
            icon: "qrc:/MeguPackOptimizer/src/resources/warning.svg",
            hasSidebar: true,
            revert: function() {
                optimizerBackend.deleteDefenderStaged = false;
                optimizerBackend.defenderActive = optimizerBackend.originalDefenderActive;
                optimizerBackend.defenderRegistryActive = optimizerBackend.originalDefenderRegistryActive;
                optimizerBackend.defenderCmdActive = optimizerBackend.originalDefenderCmdActive;
                optimizerBackend.defenderServiceActive = optimizerBackend.originalDefenderServiceActive;
            }
        });
        if (usbPowerSavingChanged) list.push({
            name: qsTr("USB 3.0 Power Saving"),
            icon: "qrc:/MeguPackOptimizer/src/resources/bolt.svg",
            hasSidebar: true,
            revert: function() {
                optimizerBackend.revertUsbDevices();
            }
        });
        if (remoteAccessChanged) list.push({
            name: qsTr("Remote Access (RDP)"),
            icon: "qrc:/MeguPackOptimizer/src/resources/play.svg",
            hasSidebar: false,
            revert: function() {
                optimizerBackend.remoteAccessActive = optimizerBackend.originalRemoteAccessActive;
            }
        });
        if (telemetryChanged) list.push({
            name: qsTr("Telemetry"),
            icon: "qrc:/MeguPackOptimizer/src/resources/folder.svg",
            hasSidebar: true,
            revert: function() {
                optimizerBackend.telemetryActive = optimizerBackend.originalTelemetryActive;
                optimizerBackend.telemetryDiagTrackActive = optimizerBackend.originalTelemetryDiagTrackActive;
                optimizerBackend.telemetryWapPushActive = optimizerBackend.originalTelemetryWapPushActive;
                optimizerBackend.telemetryCeipActive = optimizerBackend.originalTelemetryCeipActive;
                optimizerBackend.telemetryWerActive = optimizerBackend.originalTelemetryWerActive;
            }
        });
        if (adsChanged) list.push({
            name: qsTr("Ads & Privacy"),
            icon: "qrc:/MeguPackOptimizer/src/resources/ads.svg",
            hasSidebar: false,
            revert: function() {
                optimizerBackend.adsTailoredExperiencesActive = optimizerBackend.originalAdsTailoredExperiencesActive;
                optimizerBackend.adsAdvertisingIdActive = optimizerBackend.originalAdsAdvertisingIdActive;
                optimizerBackend.adsSuggestedContentActive = optimizerBackend.originalAdsSuggestedContentActive;
                optimizerBackend.adsSettingsHomeActive = optimizerBackend.originalAdsSettingsHomeActive;
                optimizerBackend.adsSuggestedNotificationsActive = optimizerBackend.originalAdsSuggestedNotificationsActive;
                optimizerBackend.adsLockScreenTipsActive = optimizerBackend.originalAdsLockScreenTipsActive;
                optimizerBackend.adsWindowsTipsActive = optimizerBackend.originalAdsWindowsTipsActive;
                optimizerBackend.adsWelcomeExperienceActive = optimizerBackend.originalAdsWelcomeExperienceActive;
                optimizerBackend.adsFinishSetupActive = optimizerBackend.originalAdsFinishSetupActive;
            }
        });
        if (windowsUpdateChanged) list.push({
            name: qsTr("Windows Update"),
            icon: "qrc:/MeguPackOptimizer/src/resources/settings.svg",
            hasSidebar: true,
            revert: function() {
                optimizerBackend.windowsUpdateMode = optimizerBackend.originalWindowsUpdateMode;
            }
        });
        if (cs2Changed) list.push({
            name: qsTr("Counter-Strike 2 Launch Options"),
            icon: "qrc:/MeguPackOptimizer/src/resources/play.svg",
            hasSidebar: true,
            revert: function() {
                optimizerBackend.cs2LaunchOptions = optimizerBackend.originalCs2LaunchOptions;
            }
        });
        if (steamOverlayChanged) list.push({
            name: qsTr("Steam Overlay"),
            icon: "qrc:/MeguPackOptimizer/src/resources/monitor.svg",
            hasSidebar: false,
            revert: function() {
                optimizerBackend.steamOverlayActive = optimizerBackend.originalSteamOverlayActive;
            }
        });
        if (cs2OverlayChanged) list.push({
            name: qsTr("CS2 Steam Overlay"),
            icon: "qrc:/MeguPackOptimizer/src/resources/play.svg",
            hasSidebar: false,
            revert: function() {
                optimizerBackend.cs2OverlayActive = optimizerBackend.originalCs2OverlayActive;
            }
        });
        if (steamFriendsSettingsChanged) list.push({
            name: qsTr("Steam Settings"),
            icon: "qrc:/MeguPackOptimizer/src/resources/steam.svg",
            hasSidebar: true,
            revert: function() {
                optimizerBackend.steamFriendsSettings = optimizerBackend.originalSteamFriendsSettings;
            }
        });
        if (visualEffectsChanged) list.push({
            name: qsTr("Visual Effects"),
            icon: "qrc:/MeguPackOptimizer/src/resources/monitor.svg",
            hasSidebar: true,
            revert: function() {
                optimizerBackend.visualEffects = optimizerBackend.originalVisualEffects;
            }
        });
        if (pagefileChanged) list.push({
            name: qsTr("Page File"),
            icon: "qrc:/MeguPackOptimizer/src/resources/ram.svg",
            hasSidebar: false,
            revert: function() {
                optimizerBackend.pagefileMin = optimizerBackend.originalPagefileMin;
                optimizerBackend.pagefileMax = optimizerBackend.originalPagefileMax;
            }
        });
        return list;
    }

    property var pendingSubOptionsList: {
        var lang = settingsBackend.language;
        var _idx = indexingChanged;
        var _ntf = notificationsChanged;
        var _xbc = xboxChanged;
        var _pwr = powerPlanChanged;
        var _btl = bitlockerChanged;
        var _ws = optimizerBackend.winSearchActive;
        var _ds = optimizerBackend.driveStates;
        var _ga = optimizerBackend.gamingOverlayActive;
        var _tg = optimizerBackend.targetPowerSchemeGuid;
        var _ng = optimizerBackend.notifGlobalActive;
        var _na = optimizerBackend.notifAppActive;
        var _ns = optimizerBackend.notifSoundsActive;
        var _nl = optimizerBackend.notifLockscreenActive;
        var _dfa = optimizerBackend.defenderActive;
        var _dfr = optimizerBackend.defenderRegistryActive;
        var _dfc = optimizerBackend.defenderCmdActive;
        var _dfs = optimizerBackend.defenderServiceActive;
        var _usb = usbPowerSavingChanged;
        var _ud = optimizerBackend.usbDevices;
        var _wud = windowsUpdateChanged;
        var _cs2 = cs2Changed;
        var _cs2m = optimizerBackend.cs2LaunchOptions;
        var _so = steamOverlayChanged;
        var _cso = cs2OverlayChanged;

        return getPendingSubOptions(root.islandDetailCategory);
    }

    onPendingChangesCountChanged: {
        if (pendingChangesCount === 0) {
            islandExpanded = false;
            currentIslandPage = "main";
        }
    }

    onPendingSubOptionsListChanged: {
        if (islandExpanded && currentIslandPage === "detail" && pendingSubOptionsList.length === 0) {
            currentIslandPage = "main";
        }
    }

    function getPendingSubOptions(category) {
        var subList = [];
        if (category === qsTr("File Indexing") || category === "File Indexing") {
            if (optimizerBackend.winSearchActive !== optimizerBackend.originalWinSearchActive) {
                subList.push({
                    name: qsTr("Windows Search service") + ": " + (optimizerBackend.originalWinSearchActive ? qsTr("Enabled") : qsTr("Disabled")) + " -> " + (optimizerBackend.winSearchActive ? qsTr("Enabled") : qsTr("Disabled")),
                    revert: function() {
                        optimizerBackend.winSearchActive = optimizerBackend.originalWinSearchActive;
                    }
                });
            }
            if (!!optimizerBackend.driveStates["C:"] !== !!optimizerBackend.originalDriveStates["C:"]) {
                subList.push({
                    name: qsTr("Drive C: indexing") + ": " + (optimizerBackend.originalDriveStates["C:"] ? qsTr("Enabled") : qsTr("Disabled")) + " -> " + (optimizerBackend.driveStates["C:"] ? qsTr("Enabled") : qsTr("Disabled")),
                    revert: function() {
                        var ds = optimizerBackend.driveStates;
                        ds["C:"] = optimizerBackend.originalDriveStates["C:"];
                        optimizerBackend.driveStates = ds;
                    }
                });
            }
            for (var i = 0; i < optimizerBackend.fixedDrives.length; i++) {
                (function(letter) {
                    if (!!optimizerBackend.driveStates[letter] !== !!optimizerBackend.originalDriveStates[letter]) {
                        subList.push({
                            name: qsTr("Drive %1 indexing").arg(letter) + ": " + (optimizerBackend.originalDriveStates[letter] ? qsTr("Enabled") : qsTr("Disabled")) + " -> " + (optimizerBackend.driveStates[letter] ? qsTr("Enabled") : qsTr("Disabled")),
                            revert: function() {
                                var ds = optimizerBackend.driveStates;
                                ds[letter] = optimizerBackend.originalDriveStates[letter];
                                optimizerBackend.driveStates = ds;
                            }
                        });
                    }
                })(optimizerBackend.fixedDrives[i]);
            }
        } else if (category === qsTr("Xbox App & Game Bar") || category === "Xbox App & Game Bar") {
            if (optimizerBackend.gamingOverlayActive !== optimizerBackend.originalGamingOverlayActive) {
                subList.push({
                    name: qsTr("Disable Game Bar Popup") + ": " + (optimizerBackend.originalGamingOverlayActive ? qsTr("Disabled") : qsTr("Enabled")) + " -> " + (optimizerBackend.gamingOverlayActive ? qsTr("Disabled") : qsTr("Enabled")),
                    revert: function() {
                        optimizerBackend.gamingOverlayActive = optimizerBackend.originalGamingOverlayActive;
                    }
                });
            }
        } else if (category === qsTr("Windows Notifications") || category === "Windows Notifications") {
            if (optimizerBackend.notifGlobalActive !== optimizerBackend.originalNotifGlobalActive) {
                subList.push({
                    name: qsTr("Global Toast Notifications") + ": " + (optimizerBackend.originalNotifGlobalActive ? qsTr("Enabled") : qsTr("Disabled")) + " -> " + (optimizerBackend.notifGlobalActive ? qsTr("Enabled") : qsTr("Disabled")),
                    revert: function() {
                        optimizerBackend.notifGlobalActive = optimizerBackend.originalNotifGlobalActive;
                    }
                });
            }
            if (optimizerBackend.notifAppActive !== optimizerBackend.originalNotifAppActive) {
                subList.push({
                    name: qsTr("App Notifications") + ": " + (optimizerBackend.originalNotifAppActive ? qsTr("Enabled") : qsTr("Disabled")) + " -> " + (optimizerBackend.notifAppActive ? qsTr("Enabled") : qsTr("Disabled")),
                    revert: function() {
                        optimizerBackend.notifAppActive = optimizerBackend.originalNotifAppActive;
                    }
                });
            }
            if (optimizerBackend.notifSoundsActive !== optimizerBackend.originalNotifSoundsActive) {
                subList.push({
                    name: qsTr("Notification Sounds") + ": " + (optimizerBackend.originalNotifSoundsActive ? qsTr("Enabled") : qsTr("Disabled")) + " -> " + (optimizerBackend.notifSoundsActive ? qsTr("Enabled") : qsTr("Disabled")),
                    revert: function() {
                        optimizerBackend.notifSoundsActive = optimizerBackend.originalNotifSoundsActive;
                    }
                });
            }
            if (optimizerBackend.notifLockscreenActive !== optimizerBackend.originalNotifLockscreenActive) {
                subList.push({
                    name: qsTr("Lock Screen Notifications") + ": " + (optimizerBackend.originalNotifLockscreenActive ? qsTr("Enabled") : qsTr("Disabled")) + " -> " + (optimizerBackend.notifLockscreenActive ? qsTr("Enabled") : qsTr("Disabled")),
                    revert: function() {
                        optimizerBackend.notifLockscreenActive = optimizerBackend.originalNotifLockscreenActive;
                    }
                });
            }
        } else if (category === qsTr("Power Plan") || category === "Power Plan") {
            if (optimizerBackend.deleteUltimateStaged) {
                subList.push({
                    name: qsTr("Remove Ultimate Performance scheme from system"),
                    revert: function() {
                        optimizerBackend.deleteUltimateStaged = false;
                    }
                });
            }
            if (optimizerBackend.targetPowerSchemeGuid !== optimizerBackend.activePowerSchemeGuid) {
                var originalName = qsTr("Unknown");
                var targetName = qsTr("Unknown");
                for (var j = 0; j < optimizerBackend.powerSchemes.length; j++) {
                    if (optimizerBackend.powerSchemes[j].guid === optimizerBackend.activePowerSchemeGuid) {
                        originalName = optimizerBackend.powerSchemes[j].name.split(' (')[0];
                    }
                    if (optimizerBackend.powerSchemes[j].guid === optimizerBackend.targetPowerSchemeGuid) {
                        targetName = optimizerBackend.powerSchemes[j].name.split(' (')[0];
                    }
                }
                subList.push({
                    name: qsTr("Power Plan") + ": " + originalName + " -> " + targetName,
                    revert: function() {
                        optimizerBackend.selectPowerScheme(optimizerBackend.activePowerSchemeGuid);
                    }
                });
            }
        } else if (category === qsTr("Windows Defender") || category === "Windows Defender") {
            if (optimizerBackend.deleteDefenderStaged) {
                subList.push({
                    name: qsTr("Completely delete Windows Defender from system"),
                    revert: function() {
                        optimizerBackend.deleteDefenderStaged = false;
                    }
                });
            }
            if (optimizerBackend.defenderRegistryActive !== optimizerBackend.originalDefenderRegistryActive) {
                subList.push({
                    name: qsTr("Registry Disablement Policies") + ": " + (optimizerBackend.originalDefenderRegistryActive ? qsTr("Enabled") : qsTr("Disabled")) + " -> " + (optimizerBackend.defenderRegistryActive ? qsTr("Enabled") : qsTr("Disabled")),
                    revert: function() {
                        optimizerBackend.defenderRegistryActive = optimizerBackend.originalDefenderRegistryActive;
                    }
                });
            }
            if (optimizerBackend.defenderCmdActive !== optimizerBackend.originalDefenderCmdActive) {
                subList.push({
                    name: qsTr("PowerShell Preference Adjustments") + ": " + (optimizerBackend.originalDefenderCmdActive ? qsTr("Enabled") : qsTr("Disabled")) + " -> " + (optimizerBackend.defenderCmdActive ? qsTr("Enabled") : qsTr("Disabled")),
                    revert: function() {
                        optimizerBackend.defenderCmdActive = optimizerBackend.originalDefenderCmdActive;
                    }
                });
            }
            if (optimizerBackend.defenderServiceActive !== optimizerBackend.originalDefenderServiceActive) {
                subList.push({
                    name: qsTr("Antivirus Services & Drivers") + ": " + (optimizerBackend.originalDefenderServiceActive ? qsTr("Enabled") : qsTr("Disabled")) + " -> " + (optimizerBackend.defenderServiceActive ? qsTr("Enabled") : qsTr("Disabled")),
                    revert: function() {
                        optimizerBackend.defenderServiceActive = optimizerBackend.originalDefenderServiceActive;
                    }
                });
            }
        } else if (category === qsTr("USB 3.0 Power Saving") || category === "USB 3.0 Power Saving") {
            for (var i = 0; i < optimizerBackend.usbDevices.length; i++) {
                (function(idx) {
                    var currentDev = optimizerBackend.usbDevices[idx];
                    var originalDev = optimizerBackend.originalUsbDevices[idx];
                    if (currentDev && originalDev && currentDev.powerSavingActive !== originalDev.powerSavingActive) {
                        subList.push({
                            name: currentDev.name + ": " + (originalDev.powerSavingActive ? qsTr("Enabled") : qsTr("Disabled")) + " -> " + (currentDev.powerSavingActive ? qsTr("Enabled") : qsTr("Disabled")),
                            revert: function() {
                                optimizerBackend.setDevicePowerSavingActive(currentDev.subkeyPath, originalDev.powerSavingActive);
                            }
                        });
                    }
                })(i);
            }
        } else if (category === qsTr("Telemetry") || category === "Telemetry") {
            if (optimizerBackend.telemetryDiagTrackActive !== optimizerBackend.originalTelemetryDiagTrackActive) {
                subList.push({
                    name: qsTr("Connected User Experiences (DiagTrack)") + ": " + (optimizerBackend.originalTelemetryDiagTrackActive ? qsTr("Enabled") : qsTr("Disabled")) + " -> " + (optimizerBackend.telemetryDiagTrackActive ? qsTr("Enabled") : qsTr("Disabled")),
                    revert: function() {
                        optimizerBackend.telemetryDiagTrackActive = optimizerBackend.originalTelemetryDiagTrackActive;
                    }
                });
            }
            if (optimizerBackend.telemetryWapPushActive !== optimizerBackend.originalTelemetryWapPushActive) {
                subList.push({
                    name: qsTr("Device Management WAP Service (dmwappushservice)") + ": " + (optimizerBackend.originalTelemetryWapPushActive ? qsTr("Enabled") : qsTr("Disabled")) + " -> " + (optimizerBackend.telemetryWapPushActive ? qsTr("Enabled") : qsTr("Disabled")),
                    revert: function() {
                        optimizerBackend.telemetryWapPushActive = optimizerBackend.originalTelemetryWapPushActive;
                    }
                });
            }
            if (optimizerBackend.telemetryCeipActive !== optimizerBackend.originalTelemetryCeipActive) {
                subList.push({
                    name: qsTr("Customer Experience Improvement Program (CEIP)") + ": " + (optimizerBackend.originalTelemetryCeipActive ? qsTr("Enabled") : qsTr("Disabled")) + " -> " + (optimizerBackend.telemetryCeipActive ? qsTr("Enabled") : qsTr("Disabled")),
                    revert: function() {
                        optimizerBackend.telemetryCeipActive = optimizerBackend.originalTelemetryCeipActive;
                    }
                });
            }
            if (optimizerBackend.telemetryWerActive !== optimizerBackend.originalTelemetryWerActive) {
                subList.push({
                    name: qsTr("Windows Error Reporting (WER)") + ": " + (optimizerBackend.originalTelemetryWerActive ? qsTr("Enabled") : qsTr("Disabled")) + " -> " + (optimizerBackend.telemetryWerActive ? qsTr("Enabled") : qsTr("Disabled")),
                    revert: function() {
                        optimizerBackend.telemetryWerActive = optimizerBackend.originalTelemetryWerActive;
                    }
                });
            }
        } else if (category === qsTr("Windows Update") || category === "Windows Update") {
            if (optimizerBackend.windowsUpdateMode !== optimizerBackend.originalWindowsUpdateMode) {
                var originalName = qsTr("Unknown");
                var targetName = qsTr("Unknown");
                var modeNames = [qsTr("Default"), qsTr("Security Only"), qsTr("Manual Check"), qsTr("Disabled")];
                if (optimizerBackend.originalWindowsUpdateMode >= 0 && optimizerBackend.originalWindowsUpdateMode < 4) {
                    originalName = modeNames[optimizerBackend.originalWindowsUpdateMode];
                }
                if (optimizerBackend.windowsUpdateMode >= 0 && optimizerBackend.windowsUpdateMode < 4) {
                    targetName = modeNames[optimizerBackend.windowsUpdateMode];
                }
                subList.push({
                    name: qsTr("Update Mode") + ": " + originalName + " -> " + targetName,
                    revert: function() {
                        optimizerBackend.windowsUpdateMode = optimizerBackend.originalWindowsUpdateMode;
                    }
                });
            }
        } else if (category === qsTr("Counter-Strike 2 Launch Options") || category === "Counter-Strike 2 Launch Options") {
            var current = optimizerBackend.cs2LaunchOptions;
            var original = optimizerBackend.originalCs2LaunchOptions;
            if (current && original) {
                var keys = Object.keys(current);
                for (var idx = 0; idx < keys.length; idx++) {
                    (function(key) {
                        if (current[key] !== original[key]) {
                            subList.push({
                                name: key + ": " + (original[key] ? qsTr("Enabled") : qsTr("Disabled")) + " -> " + (current[key] ? qsTr("Enabled") : qsTr("Disabled")),
                                revert: function() {
                                    var currentNow = optimizerBackend.cs2LaunchOptions;
                                    if (currentNow) {
                                        var optMap = {};
                                        var kList = Object.keys(currentNow);
                                        for (var i = 0; i < kList.length; i++) {
                                            optMap[kList[i]] = currentNow[kList[i]];
                                        }
                                        optMap[key] = original[key];
                                        optimizerBackend.cs2LaunchOptions = optMap;
                                    }
                                }
                            });
                        }
                    })(keys[idx]);
                }
            }
        } else if (category === qsTr("Steam Settings") || category === "Steam Settings") {
            var current = optimizerBackend.steamFriendsSettings;
            var original = optimizerBackend.originalSteamFriendsSettings;
            if (current && original) {
                var keys = Object.keys(current);
                var steamLabels = {
                    "bAppendNicknamesToNames": qsTr("Append nicknames to friends' names"),
                    "bGroupFriendsByGame": qsTr("Group friends together by game"),
                    "bHideOfflineFriendsInCustomCategories": qsTr("Hide offline friends in custom categories"),
                    "bHideCategorizedFriendsInOnlineOffline": qsTr("Hide categorized friends in Online/Offline Friends"),
                    "bIgnoreAwayStatusWhenSorting": qsTr("Ignore 'Away' status when sorting friends"),
                    "bSignInOnStart": qsTr("Sign in to friends when Steam starts"),
                    "bEnableAnimatedAvatars": qsTr("Enable Animated Avatars & Animated Avatar Frames"),
                    "bCompactFriendsListAndChat": qsTr("Compact friends list & chat view"),
                    "bCompactFavorites": qsTr("Compact favorite friends area"),
                    "bDockChats": qsTr("Dock chats to the friends list"),
                    "bOpenNewWindowForNewChats": qsTr("Open a new window for new chats"),
                    "bDontEmbedImages": qsTr("Don't embed images and other media inline"),
                    "bRememberOpenChats": qsTr("Remember my open chats"),
                    "bDisableSpellCheck": qsTr("Disable spellcheck in chat message entry"),
                    "bDisableRoomEffects": qsTr("Disable animated room effects"),
                    "fontSize": qsTr("Chat font size"),
                    "bScaleTextAndIcons": qsTr("Scale text and icons to match monitor settings (requires restart)"),
                    "bRunOnStartup": qsTr("Run Steam when my computer starts"),
                    "bAskAccountOnStart": qsTr("Ask which account to use each time Steam starts"),
                    "bStartInBigPicture": qsTr("Start Steam in Big Picture Mode"),
                    "bSmoothScrolling": qsTr("Enable smooth scrolling in web views (requires restart)"),
                    "bGPUAcceleratedRendering": qsTr("Enable GPU accelerated rendering in web views (requires restart)"),
                    "bHardwareVideoDecoding": qsTr("Enable hardware video decoding, if supported (requires restart)"),
                    "bNotifyGameAdditions": qsTr("Notify me about additions or changes to my games, new releases, and upcoming releases"),
                    "bPlayNotificationSounds": qsTr("Play a sound when a toast is displayed"),
                    "bAchievementShowToast": qsTr("Achievement toast notification"),
                    "bAchievementPlaySound": qsTr("Achievement notification sound"),
                    "bControllerShowToast": qsTr("Controller connection toast notification"),
                    "bControllerPlaySound": qsTr("Controller connection notification sound"),
                    "bControllerLowShowToast": qsTr("Controller low battery toast notification"),
                    "bControllerLowPlaySound": qsTr("Controller low battery notification sound"),
                    "bFriendJoinShowToast": qsTr("Friend joins game toast notification"),
                    "bFriendJoinPlaySound": qsTr("Friend joins game notification sound"),
                    "bFriendOnlineShowToast": qsTr("Friend online toast notification"),
                    "bFriendOnlinePlaySound": qsTr("Friend online notification sound"),
                    "bFriendMsgShowToast": qsTr("Friend message toast notification"),
                    "bFriendMsgPlaySound": qsTr("Friend message notification sound"),
                    "bChatRoomShowToast": qsTr("Chat room toast notification"),
                    "bChatRoomPlaySound": qsTr("Chat room notification sound"),
                    "flashWindowOnMessage": qsTr("Flash window when receive chat message"),
                    "bRestoreOverlayBrowserTabs": qsTr("Restore my previous browser tabs when starting a game"),
                    "bScaleOverlayTextAndIcons": qsTr("Scale Steam Overlay text and icons to match monitor settings"),
                    "bReduceMotion": qsTr("Reduce Motion"),
                    "BackgroundRecordMode": qsTr("Game Recording Mode"),
                    "noiseGateLevel": qsTr("Voice Transmission Threshold"),
                    "echoCancellation": qsTr("Echo cancellation"),
                    "noiseCancellation": qsTr("Noise cancellation"),
                    "autoGainControl": qsTr("Automatic volume/gain control"),
                    "EnableStreaming": qsTr("Enable Remote Play"),
                    "DownloadHighQualityAudio": qsTr("Download high quality audio files")
                };
                for (var idx = 0; idx < keys.length; idx++) {
                    (function(key) {
                        if (current[key] !== original[key]) {
                            var label = steamLabels[key] || key;
                            var fromVal = original[key];
                            var toVal = current[key];
                            if (typeof fromVal === "boolean") fromVal = fromVal ? qsTr("Enabled") : qsTr("Disabled");
                            if (typeof toVal === "boolean") toVal = toVal ? qsTr("Enabled") : qsTr("Disabled");
                            if (key === "BackgroundRecordMode") {
                                var modes = {
                                    0: qsTr("Recording Off"),
                                    1: qsTr("Record in Background"),
                                    2: qsTr("Record Manually")
                                };
                                fromVal = modes[fromVal] || fromVal;
                                toVal = modes[toVal] || toVal;
                            }
                            if (key === "noiseGateLevel") {
                                var voiceModes = {
                                    0: qsTr("Off"),
                                    2: qsTr("Medium (Recommended)"),
                                    3: qsTr("High")
                                };
                                fromVal = voiceModes[fromVal] || fromVal;
                                toVal = voiceModes[toVal] || toVal;
                            }
                            subList.push({
                                name: label + ": " + fromVal + " -> " + toVal,
                                revert: function() {
                                    var optMap = {};
                                    var kList = Object.keys(current);
                                    for (var i = 0; i < kList.length; i++) {
                                        optMap[kList[i]] = current[kList[i]];
                                    }
                                    optMap[key] = original[key];
                                    optimizerBackend.steamFriendsSettings = optMap;
                                }
                            });
                        }
                    })(keys[idx]);
                }
            }
        } else if (category === qsTr("Visual Effects") || category === "Visual Effects") {
            var current = optimizerBackend.visualEffects;
            var original = optimizerBackend.originalVisualEffects;
            if (current && original) {
                var keys = Object.keys(current);
                var vfxLabels = {
                    "animateControls": qsTr("Animate controls inside windows"),
                    "animateWindows": qsTr("Animate windows when minimizing/maximizing"),
                    "animateTaskbar": qsTr("Animations in the taskbar"),
                    "enablePeek": qsTr("Enable Peek"),
                    "fadeMenus": qsTr("Fade or slide menus into view"),
                    "fadeTooltips": qsTr("Fade or slide ToolTips into view"),
                    "fadeMenuSelection": qsTr("Fade out menu items after clicking"),
                    "saveThumbnails": qsTr("Save taskbar thumbnail previews"),
                    "shadowPointer": qsTr("Show shadows under mouse pointer"),
                    "shadowWindows": qsTr("Show shadows under windows"),
                    "showThumbnails": qsTr("Show thumbnails instead of icons"),
                    "translucentSelection": qsTr("Show translucent selection rectangle"),
                    "dragContents": qsTr("Show window contents while dragging"),
                    "slideComboBoxes": qsTr("Slide open combo boxes"),
                    "smoothFonts": qsTr("Smooth edges of screen fonts"),
                    "smoothScroll": qsTr("Smooth-scroll list boxes"),
                    "dropShadowsDesktop": qsTr("Use drop shadows for icon labels on the desktop")
                };
                for (var idx = 0; idx < keys.length; idx++) {
                    (function(key) {
                        if (current[key] !== original[key]) {
                            var label = vfxLabels[key] || key;
                            subList.push({
                                name: label + ": " + (original[key] ? qsTr("Enabled") : qsTr("Disabled")) + " -> " + (current[key] ? qsTr("Enabled") : qsTr("Disabled")),
                                revert: function() {
                                    root.toggleVisualEffect(key, original[key]);
                                }
                            });
                        }
                    })(keys[idx]);
                }
            }
        } else if (category === qsTr("Steam Settings") || category === "Steam Settings") {
            var current = optimizerBackend.steamFriendsSettings;
            var original = optimizerBackend.originalSteamFriendsSettings;
            if (current && original) {
                var keys = Object.keys(current);
                var steamLabels = {
                    "bAppendNicknamesToNames": qsTr("Append nicknames to friends' names"),
                    "bGroupFriendsByGame": qsTr("Group friends together by game"),
                    "bHideOfflineFriendsInCustomCategories": qsTr("Hide offline friends in custom categories"),
                    "bHideCategorizedFriendsInOnlineOffline": qsTr("Hide categorized friends in Online/Offline Friends"),
                    "bIgnoreAwayStatusWhenSorting": qsTr("Ignore 'Away' status when sorting friends"),
                    "bSignInOnStart": qsTr("Sign in to friends when Steam starts"),
                    "bEnableAnimatedAvatars": qsTr("Enable Animated Avatars & Animated Avatar Frames"),
                    "bCompactFriendsListAndChat": qsTr("Compact friends list & chat view"),
                    "bCompactFavorites": qsTr("Compact favorite friends area"),
                    "bDockChats": qsTr("Dock chats to the friends list"),
                    "bOpenNewWindowForNewChats": qsTr("Open a new window for new chats"),
                    "bDontEmbedImages": qsTr("Don't embed images and other media inline"),
                    "bRememberOpenChats": qsTr("Remember my open chats"),
                    "bDisableSpellCheck": qsTr("Disable spellcheck in chat message entry"),
                    "bDisableRoomEffects": qsTr("Disable animated room effects"),
                    "fontSize": qsTr("Chat font size"),
                    "bRestoreOverlayBrowserTabs": qsTr("Restore my previous browser tabs when starting a game"),
                    "bScaleOverlayTextAndIcons": qsTr("Scale Steam Overlay text and icons to match monitor settings"),
                    "bReduceMotion": qsTr("Reduce Motion"),
                    "BackgroundRecordMode": qsTr("Game Recording Mode"),
                    "noiseGateLevel": qsTr("Voice Transmission Threshold"),
                    "echoCancellation": qsTr("Echo cancellation"),
                    "noiseCancellation": qsTr("Noise cancellation"),
                    "autoGainControl": qsTr("Automatic volume/gain control"),
                    "EnableStreaming": qsTr("Enable Remote Play"),
                    "DownloadHighQualityAudio": qsTr("Download high quality audio files")
                };
                for (var idx = 0; idx < keys.length; idx++) {
                    (function(key) {
                        if (current[key] !== original[key]) {
                            var label = steamLabels[key] || key;
                            var fromVal = original[key];
                            var toVal = current[key];
                            if (typeof fromVal === "boolean") fromVal = fromVal ? qsTr("Enabled") : qsTr("Disabled");
                            if (typeof toVal === "boolean") toVal = toVal ? qsTr("Enabled") : qsTr("Disabled");
                            if (key === "BackgroundRecordMode") {
                                var modes = {
                                    0: qsTr("Recording Off"),
                                    1: qsTr("Record in Background"),
                                    2: qsTr("Record Manually")
                                };
                                fromVal = modes[fromVal] || fromVal;
                                toVal = modes[toVal] || toVal;
                            }
                            if (key === "noiseGateLevel") {
                                var voiceModes = {
                                    0: qsTr("Off"),
                                    2: qsTr("Medium (Recommended)"),
                                    3: qsTr("High")
                                };
                                fromVal = voiceModes[fromVal] || fromVal;
                                toVal = voiceModes[toVal] || toVal;
                            }
                            subList.push({
                                name: label + ": " + fromVal + " -> " + toVal,
                                revert: function() {
                                    var optMap = {};
                                    var kList = Object.keys(current);
                                    for (var i = 0; i < kList.length; i++) {
                                        optMap[kList[i]] = current[kList[i]];
                                    }
                                    optMap[key] = original[key];
                                    optimizerBackend.steamFriendsSettings = optMap;
                                }
                            });
                        }
                    })(keys[idx]);
                }
            }
        } else if (category === qsTr("Page File") || category === "Page File") {
            if (optimizerBackend.pagefileMin !== optimizerBackend.originalPagefileMin) {
                subList.push({
                    name: qsTr("Min size: %1 MB -> %2 MB").arg(optimizerBackend.originalPagefileMin).arg(optimizerBackend.pagefileMin),
                    revert: function() {
                        optimizerBackend.pagefileMin = optimizerBackend.originalPagefileMin;
                    }
                });
            }
            if (optimizerBackend.pagefileMax !== optimizerBackend.originalPagefileMax) {
                subList.push({
                    name: qsTr("Max size: %1 MB -> %2 MB").arg(optimizerBackend.originalPagefileMax).arg(optimizerBackend.pagefileMax),
                    revert: function() {
                        optimizerBackend.pagefileMax = optimizerBackend.originalPagefileMax;
                    }
                });
            }
        }
        return subList;
    }

    function getParentCard(name) {
        if (name === qsTr("Visual Effects") || name === "Visual Effects") return visualEffectsPanel;
        if (name === qsTr("Page File") || name === "Page File") return pageFilePanel;
        if (name === qsTr("Counter-Strike 2 Launch Options") || name === "Counter-Strike 2 Launch Options") return cs2Panel;
        if (name === qsTr("File Indexing") || name === "File Indexing") return indexingPanel;
        if (name === qsTr("Xbox App & Game Bar") || name === "Xbox App & Game Bar") return xboxPanel;
        if (name === qsTr("Core Isolation") || name === "Core Isolation") return coreIsolationPanel;
        if (name === qsTr("Mouse Acceleration") || name === "Mouse Acceleration") return mouseAccelerationPanel;
        if (name === qsTr("Game Mode") || name === "Game Mode") return gameModePanel;
        if (name === qsTr("Discord In-Game Overlay") || name === "Discord In-Game Overlay") return discordOverlayPanel;
        if (name === qsTr("Windows Defender Firewall") || name === "Windows Defender Firewall") return firewallPanel;
        if (name === qsTr("Windows Notifications") || name === "Windows Notifications") return notificationsPanel;
        if (name === qsTr("System Hibernation") || name === "System Hibernation") return hibernationPanel;
        if (name === qsTr("Power Plan") || name === "Power Plan") return powerPlanPanel;
        if (name === qsTr("BitLocker Drive Encryption") || name === "BitLocker Drive Encryption") return bitlockerPanel;
        if (name === qsTr("Windows Defender") || name === "Windows Defender") return defenderPanel;
        if (name === qsTr("USB 3.0 Power Saving") || name === "USB 3.0 Power Saving") return usbPanel;
        if (name === qsTr("Remote Access (RDP)") || name === "Remote Access (RDP)") return remoteAccessPanel;
        if (name === qsTr("Telemetry") || name === "Telemetry") return telemetryPanel;
        if (name === qsTr("Windows Update") || name === "Windows Update") return windowsUpdatePanel;
        if (name === qsTr("CS2 Steam Overlay") || name === "CS2 Steam Overlay") return cs2Panel;
        if (name === qsTr("Steam Settings") || name === "Steam Settings") return steamSettingsPanel;
        if (name === qsTr("Classic Context Menu") || name === "Classic Context Menu") return classicContextMenuPanel;
        if (name === qsTr("Shortcut Arrow Overlays") || name === "Shortcut Arrow Overlays") return shortcutArrowsPanel;
        if (name === qsTr("Clipboard History") || name === "Clipboard History") return clipboardHistoryPanel;
        if (name === qsTr("Taskbar 'End task'") || name === "Taskbar 'End task'") return taskbarEndTaskPanel;
        if (name === qsTr("Clock with seconds") || name === "Clock with seconds") return taskbarSecondsPanel;
        if (name === qsTr("Ads & Privacy") || name === "Ads & Privacy" || name === "Ads" || name === "Ad" || name === qsTr("Ads") || name === qsTr("Ad")) return adsPanel;
        return null;
    }

    function locateFunction(categoryName) {
        if (categoryName === qsTr("Telemetry") || categoryName === "Telemetry" || categoryName === qsTr("Ads & Privacy") || categoryName === "Ads & Privacy" || categoryName === "Ads" || categoryName === "Ad" || categoryName === qsTr("Ads") || categoryName === qsTr("Ad")) {
            root.currentSection = "telemetry";
        } else if (categoryName === qsTr("Counter-Strike 2 Launch Options") || categoryName === "Counter-Strike 2 Launch Options" || categoryName === qsTr("CS2 Steam Overlay") || categoryName === "CS2 Steam Overlay" || categoryName === qsTr("Steam Settings") || categoryName === "Steam Settings") {
            root.currentSection = "games";
        } else if (categoryName === qsTr("Classic Context Menu") || categoryName === "Classic Context Menu" || categoryName === qsTr("Shortcut Arrow Overlays") || categoryName === "Shortcut Arrow Overlays" || categoryName === qsTr("Clipboard History") || categoryName === "Clipboard History" || categoryName === qsTr("Taskbar 'End task'") || categoryName === "Taskbar 'End task'" || categoryName === qsTr("Clock with seconds") || categoryName === "Clock with seconds") {
            root.currentSection = "customization";
        } else {
            root.currentSection = "core";
        }

        Qt.callLater(function() {
            var panel = getParentCard(categoryName);
            if (!panel) return;

            var flick = mainScroll.contentItem;
            if (!flick) return;

            scrollAnimation.stop();
            var targetY = panel.mapToItem(mainColumn, 0, 0).y - (mainScroll.height - panel.height) / 2;
            var maxScroll = flick.contentHeight - mainScroll.height;
            if (maxScroll < 0) maxScroll = 0;
            targetY = Math.max(0, Math.min(targetY, maxScroll));
            
            scrollAnimation.target = flick;
            scrollAnimation.to = targetY;
            scrollAnimation.start();

            if (typeof panel.triggerLocateFlash === "function") {
                panel.triggerLocateFlash();
            }
        });
    }

    NumberAnimation {
        id: scrollAnimation
        property: "contentY"
        duration: 500
        easing.type: Easing.InOutQuad
    }

    readonly property string txtChangesPending: qsTr("%1 changes pending")
    readonly property string txtPendingListTitle: qsTr("Pending Changes:")

    // ListModel for live optimization steps
    ListModel {
        id: stepLogModel
    }

    Connections {
        target: optimizerBackend
        function onSystemStepReported(msg, type) {
            stepLogModel.append({ "message": msg, "type": type });
        }
    }

    function toggleMain() {
        var targetVal = (mainIndeterminate || !mainChecked);
        optimizerBackend.winSearchActive = targetVal;
        
        var newStates = {};
        newStates["C:"] = targetVal;
        for (var i = 0; i < optimizerBackend.fixedDrives.length; i++) {
            var letter = optimizerBackend.fixedDrives[i];
            newStates[letter] = targetVal;
        }
        optimizerBackend.driveStates = newStates;
    }

    ScrollView {
        id: mainScroll
        anchors.top: parent.top
        anchors.bottom: bottomActionBar.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 24
        clip: true
        contentHeight: mainColumn.implicitHeight

        MouseArea {
            anchors.fill: parent
            z: -1
            onClicked: {
                root.forceActiveFocus();
            }
        }

        ScrollBar.vertical: MeguScrollBar { }
        ScrollBar.horizontal: MeguScrollBar { }

        Column {
            id: mainColumn
            width: mainScroll.width - 20
            spacing: 24

            Row {
                spacing: 8
                height: 16

                Rectangle {
                    width: 4
                    height: 16
                    radius: 2
                    color: Theme.accent
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: root.currentSection === "telemetry" ? qsTr("Telemetry Settings") : 
                          root.currentSection === "games" ? qsTr("Video Games Optimization") :
                          root.currentSection === "customization" ? qsTr("Customization Settings") :
                          qsTr("System Optimization")
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // 0.5. VIDEO GAMES CATEGORY
            Column {
                visible: root.currentSection === "games"
                width: parent.width
                spacing: 12



                AcrylicPanel {
                    id: cs2Panel
                    width: parent.width
                    height: detailsExpanded ? 76 + detailsContainer.implicitHeight + 24 : 76
                    opacity: optimizerBackend.steamInstalled ? 1.0 : 0.5
                    enabled: optimizerBackend.steamInstalled
                    Behavior on opacity { NumberAnimation { duration: Theme.animNormal } }
                    
                    property bool detailsExpanded: false

                    Behavior on height {
                        NumberAnimation { duration: Theme.animNormal; easing.type: Easing.InOutQuad }
                    }

                    Column {
                        id: mainPanelColumn
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        spacing: 16

                        // CS2 Header card row
                        Row {
                            id: mainLayout
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16
                            spacing: 16

                            // Game Logo placeholder or icon
                            Rectangle {
                                width: 44
                                height: 44
                                radius: 8
                                color: Theme.accentDim
                                border.color: Theme.accent
                                border.width: 1
                                anchors.verticalCenter: parent.verticalCenter

                                Image {
                                    source: "qrc:/MeguPackOptimizer/src/resources/play.svg"
                                    anchors.centerIn: parent
                                    width: 20
                                    height: 20
                                    sourceSize.width: 20
                                    sourceSize.height: 20
                                }
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 2
                                width: parent.width - 44 - 16 - openBtn.width - 16

                                Row {
                                    spacing: 8
                                    Text {
                                        text: "Counter-Strike 2"
                                        color: Theme.textPrimary
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 14
                                        font.bold: true
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Rectangle {
                                        visible: root.cs2Changed
                                        height: 16
                                        width: cs2SelectedText.contentWidth + 10
                                        radius: 4
                                        color: Qt.rgba(Theme.success.r, Theme.success.g, Theme.success.b, 0.15)
                                        border.color: Theme.success
                                        border.width: 1
                                        anchors.verticalCenter: parent.verticalCenter
                                        Text {
                                            id: cs2SelectedText
                                            text: qsTr("Selected for application")
                                            color: Theme.success
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 8
                                            font.bold: true
                                            anchors.centerIn: parent
                                        }
                                    }
                                }

                                Text {
                                    text: qsTr("Launch parameters and performance optimization")
                                    color: Theme.textSecondary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    width: parent.width
                                    elide: Text.ElideRight
                                }
                            }

                            // Open / Close button
                            MeguButton {
                                id: openBtn
                                text: cs2Panel.detailsExpanded ? qsTr("Close") : qsTr("Open")
                                accented: cs2Panel.detailsExpanded
                                flat: !cs2Panel.detailsExpanded
                                height: 30
                                width: 90
                                anchors.verticalCenter: parent.verticalCenter
                                onClicked: {
                                    cs2Panel.detailsExpanded = !cs2Panel.detailsExpanded
                                }
                            }
                        }

                        // Sliding drawer options list
                        Column {
                            id: detailsContainer
                            width: parent.width
                            spacing: 12
                            visible: cs2Panel.detailsExpanded
                            opacity: cs2Panel.detailsExpanded ? 1.0 : 0.0

                            Behavior on opacity {
                                NumberAnimation { duration: Theme.animNormal }
                            }

                            // Horizontal separator line
                            Rectangle {
                                width: parent.width
                                height: 1
                                color: Theme.border
                            }

                            // Steam Not Running Warning Card for CS2
                            Rectangle {
                                width: parent.width
                                height: warningColumn.implicitHeight + 24
                                radius: Theme.radiusNormal
                                color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.05)
                                border.color: Theme.accent
                                border.width: 1
                                visible: !window.steamIsRunning || window.steamActiveUserId === ""

                                Column {
                                    id: warningColumn
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 12

                                    Row {
                                        spacing: 12
                                        width: parent.width

                                        Rectangle {
                                            width: 32
                                            height: 32
                                            radius: 6
                                            color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                                            anchors.verticalCenter: parent.verticalCenter
                                            Text {
                                                text: "⚠️"
                                                font.pixelSize: 16
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Column {
                                            spacing: 2
                                            width: parent.width - 32 - 12 - 16
                                            anchors.verticalCenter: parent.verticalCenter

                                            Text {
                                                text: !window.steamIsRunning ? qsTr("Steam is not running") : qsTr("Steam is running but no user is logged in")
                                                color: Theme.textPrimary
                                                font.family: Theme.fontFamily
                                                font.pixelSize: 13
                                                font.bold: true
                                            }

                                            Text {
                                                text: !window.steamIsRunning ? qsTr("To configure and optimize Counter-Strike 2, please launch the Steam client first.") : qsTr("Please log in to your Steam account to load and configure your Counter-Strike 2 settings.")
                                                color: Theme.textSecondary
                                                font.family: Theme.fontFamily
                                                font.pixelSize: 10
                                                width: parent.width
                                                wrapMode: Text.Wrap
                                            }
                                        }
                                    }

                                    MeguButton {
                                        text: qsTr("Launch Steam")
                                        accented: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        width: 140
                                        height: 28
                                        visible: !window.steamIsRunning
                                        onClicked: {
                                            optimizerBackend.launchSteam();
                                            window.steamIsRunning = true;
                                        }
                                    }
                                }
                            }

                            Column {
                                width: parent.width
                                spacing: 12
                                enabled: window.steamIsRunning && window.steamActiveUserId !== ""
                                opacity: (window.steamIsRunning && window.steamActiveUserId !== "") ? 1.0 : 0.4
                                Behavior on opacity { NumberAnimation { duration: Theme.animNormal } }

                                // Steam Overlay for CS2 Toggle
                                Rectangle {
                                    width: parent.width
                                    height: 52
                                    radius: 6
                                    color: cs2OverlayMouseRow.containsMouse ? Theme.buttonBgHover : "transparent"
                                    border.color: cs2OverlayCheckedState ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3) : (cs2OverlayMouseRow.containsMouse ? Theme.borderHover : "transparent")
                                    border.width: 1
                                    opacity: optimizerBackend.steamInstalled ? 1.0 : 0.5
                                    enabled: optimizerBackend.steamInstalled
                                    Behavior on opacity { NumberAnimation { duration: Theme.animNormal } }
                                    
                                    property bool cs2OverlayCheckedState: optimizerBackend.cs2OverlayActive

                                    Row {
                                        anchors.fill: parent
                                        anchors.leftMargin: 12
                                        anchors.rightMargin: 12
                                        spacing: 12

                                        MeguSwitch {
                                            id: cs2OverlaySwitch
                                            steamStyle: true
                                            checked: parent.parent.cs2OverlayCheckedState
                                            anchors.verticalCenter: parent.verticalCenter
                                            onToggled: (isChecked) => {
                                                optimizerBackend.cs2OverlayActive = isChecked;
                                            }
                                        }

                                        Column {
                                            anchors.verticalCenter: parent.verticalCenter
                                            spacing: 2
                                            width: parent.width - cs2OverlaySwitch.width - 12

                                            Row {
                                                spacing: 8
                                                Text {
                                                    text: qsTr("Steam Overlay for Counter-Strike 2")
                                                    color: parent.parent.parent.parent.cs2OverlayCheckedState ? Theme.accent : Theme.textPrimary
                                                    font.family: Theme.fontFamily
                                                    font.pixelSize: 12
                                                    font.bold: true
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }
                                                Rectangle {
                                                    visible: optimizerBackend.cs2OverlayActive !== optimizerBackend.originalCs2OverlayActive
                                                    height: 14
                                                    width: cs2OverlayStagedText.contentWidth + 8
                                                    radius: 3
                                                    color: Qt.rgba(Theme.success.r, Theme.success.g, Theme.success.b, 0.15)
                                                    border.color: Theme.success
                                                    border.width: 1
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    Text {
                                                        id: cs2OverlayStagedText
                                                        text: qsTr("Selected for application")
                                                        color: Theme.success
                                                        font.family: Theme.fontFamily
                                                        font.pixelSize: 7
                                                        font.bold: true
                                                        anchors.centerIn: parent
                                                    }
                                                }
                                            }

                                            Text {
                                                text: qsTr("Toggle the Steam Overlay exclusively for Counter-Strike 2.")
                                                color: Theme.textSecondary
                                                font.family: Theme.fontFamily
                                                font.pixelSize: 10
                                                elide: Text.ElideRight
                                                width: parent.width
                                            }
                                        }
                                    }

                                    MouseArea {
                                        id: cs2OverlayMouseRow
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            optimizerBackend.cs2OverlayActive = !optimizerBackend.cs2OverlayActive;
                                        }
                                    }
                                }

                                Text {
                                    text: qsTr("Launch Options (Click name to toggle, will apply on 'Optimize')")
                                    color: Theme.yellowAccent
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    font.bold: true
                                }

                                // Repeater of launch options
                                Column {
                                    width: parent.width
                                    spacing: 8
                                    
                                    Repeater {
                                        model: ListModel {
                                            id: launchOptionsModel
                                            Component.onCompleted: {
                                                append({ name: "-allow_third_party_software", desc: qsTr("Allows third-party software (OBS, overlays, etc.) to hook into the game.") })
                                                append({ name: "-noreflex", desc: qsTr("Disables NVIDIA Reflex, useful if you experience stutters with it.") })
                                                append({ name: "-noaafonts", desc: qsTr("Disables anti-aliasing for screen fonts, slightly improving text rendering performance.") })
                                                append({ name: "-language English", desc: qsTr("Forces the game language to English.") })
                                                append({ name: "+fps_max 0", desc: qsTr("Removes the frame rate cap for maximum FPS.") })
                                                append({ name: "-freq 170", desc: qsTr("Forces the monitor refresh rate to 170Hz (adjust to your monitor).") })
                                                append({ name: "-nojoy", desc: qsTr("Disables joystick initialization, freeing up memory and reducing startup time.") })
                                                append({ name: "-high", desc: qsTr("Launches the game in high CPU priority mode.") })
                                                append({ name: "-fullscreen", desc: qsTr("Forces the game to start in fullscreen mode.") })
                                                append({ name: "-forcenovsync", desc: qsTr("Forces V-Sync to be disabled to minimize input lag.") })
                                                append({ name: "-softparticlesdefaultoff", desc: qsTr("Disables soft blending for particles, improving performance near smoke.") })
                                                append({ name: "+r_dynamic 0", desc: qsTr("Disables dynamic lighting, removing FPS drops during gunfights.") })
                                                append({ name: "+cl_interp 0", desc: qsTr("Sets interpolation to minimum, making network hit registration faster.") })
                                                append({ name: "+cl_hideserverip", desc: qsTr("Hides the server IP address in console and status to prevent DDoS.") })
                                                append({ name: "+mat_queue_mode 2", desc: qsTr("Forces multi-threaded material queue mode for multi-core processors.") })
                                            }
                                        }

                                        delegate: Rectangle {
                                            width: parent.width
                                            height: 52
                                            radius: 6
                                            color: mouseRow.containsMouse ? Theme.buttonBgHover : "transparent"
                                            border.color: checkedState ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3) : (mouseRow.containsMouse ? Theme.borderHover : "transparent")
                                            border.width: 1
                                            
                                            property bool checkedState: {
                                                var optMap = optimizerBackend.cs2LaunchOptions;
                                                return optMap && optMap[model.name] === true;
                                            }

                                            Row {
                                                anchors.fill: parent
                                                anchors.leftMargin: 12
                                                anchors.rightMargin: 12
                                                spacing: 12

                                                MeguSwitch {
                                                    id: optSwitch
                                                    steamStyle: true
                                                    checked: parent.parent.checkedState
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    onToggled: (isChecked) => {
                                                        var current = optimizerBackend.cs2LaunchOptions;
                                                        if (current && current[model.name] !== isChecked) {
                                                            var optMap = {};
                                                            var keys = Object.keys(current);
                                                            for (var i = 0; i < keys.length; i++) {
                                                                optMap[keys[i]] = current[keys[i]];
                                                            }
                                                            optMap[model.name] = isChecked;
                                                            optimizerBackend.cs2LaunchOptions = optMap;
                                                        }
                                                    }
                                                }

                                                Column {
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    spacing: 2
                                                    width: parent.width - optSwitch.width - 12

                                                    Text {
                                                        text: model.name
                                                        color: parent.parent.parent.checkedState ? Theme.accent : Theme.textPrimary
                                                        font.family: Theme.fontFamily
                                                        font.pixelSize: 12
                                                        font.bold: true
                                                    }

                                                    Text {
                                                        text: model.desc
                                                        color: Theme.textSecondary
                                                        font.family: Theme.fontFamily
                                                        font.pixelSize: 10
                                                        elide: Text.ElideRight
                                                        width: parent.width
                                                    }
                                                }
                                            }

                                            MouseArea {
                                                id: mouseRow
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    var current = optimizerBackend.cs2LaunchOptions;
                                                    if (current) {
                                                        var cur = current[model.name] === true;
                                                        var optMap = {};
                                                        var keys = Object.keys(current);
                                                        for (var i = 0; i < keys.length; i++) {
                                                            optMap[keys[i]] = current[keys[i]];
                                                        }
                                                        optMap[model.name] = !cur;
                                                        optimizerBackend.cs2LaunchOptions = optMap;
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                AcrylicPanel {
                    id: steamSettingsPanel
                    width: parent.width
                    height: 76
                    opacity: optimizerBackend.steamInstalled ? 1.0 : 0.5
                    enabled: optimizerBackend.steamInstalled
                    Behavior on opacity { NumberAnimation { duration: Theme.animNormal } }

                    Row {
                        id: steamSettingsLayout
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 16

                        Rectangle {
                            width: 44
                            height: 44
                            radius: 8
                            color: optimizerBackend.steamInstalled ? Theme.accentDim : Theme.buttonBg
                            border.color: optimizerBackend.steamInstalled ? Theme.accent : Theme.border
                            border.width: 1
                            anchors.verticalCenter: parent.verticalCenter

                            Image {
                                id: steamLogoImg
                                source: "qrc:/MeguPackOptimizer/src/resources/steam.svg"
                                anchors.centerIn: parent
                                width: 20
                                height: 20
                                sourceSize.width: 20
                                sourceSize.height: 20
                                visible: false
                            }

                            ColorOverlay {
                                anchors.fill: steamLogoImg
                                source: steamLogoImg
                                color: optimizerBackend.steamInstalled ? Theme.accent : Theme.textSecondary
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2
                            width: parent.width - 44 - 16 - openSteamBtn.width - 16

                            Row {
                                spacing: 8
                                Text {
                                    text: qsTr("Steam Settings")
                                    color: Theme.textPrimary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 14
                                    font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Rectangle {
                                    visible: root.steamFriendsSettingsChanged
                                    height: 16
                                    width: steamStagedText.contentWidth + 10
                                    radius: 4
                                    color: Qt.rgba(Theme.success.r, Theme.success.g, Theme.success.b, 0.15)
                                    border.color: Theme.success
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        id: steamStagedText
                                        text: qsTr("Selected for application")
                                        color: Theme.success
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 8
                                        font.bold: true
                                        anchors.centerIn: parent
                                    }
                                }
                            }

                            Text {
                                text: optimizerBackend.steamInstalled ? qsTr("Optimize the Steam client, friends list, and chat interface to reduce background memory and latency.") : qsTr("Steam client not detected on this system.")
                                color: Theme.textSecondary
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                width: parent.width
                                elide: Text.ElideRight
                            }
                        }

                        MeguButton {
                            id: openSteamBtn
                            text: qsTr("Open")
                            flat: true
                            height: 30
                            width: 90
                            enabled: optimizerBackend.steamInstalled
                            anchors.verticalCenter: parent.verticalCenter
                            onClicked: {
                                root.activeDrawer = "steamSettings"
                            }
                        }
                    }
                }

            }

            // 1. DRIVES INDEXING CATEGORY
            Column {
                visible: root.currentSection === "core"
                width: parent.width
                spacing: 8

                Row {
                    spacing: 8
                    height: 16

                    Rectangle {
                        width: 4
                        height: 16
                        radius: 2
                        color: Theme.accent
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: qsTr("Drives & Indexing")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                AcrylicPanel {
                    id: indexingPanel
                    width: parent.width
                    height: 84

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 10
                            color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                            anchors.verticalCenter: parent.verticalCenter

                            Item {
                                width: 20
                                height: 20
                                anchors.centerIn: parent
                                Image {
                                    id: indexingPanel_iconImg
                                    source: "qrc:/MeguPackOptimizer/src/resources/storage.svg"
                                    anchors.fill: parent
                                    sourceSize.width: 20
                                    sourceSize.height: 20
                                    visible: false
                                }
                                ColorOverlay {
                                    anchors.fill: indexingPanel_iconImg
                                    source: indexingPanel_iconImg
                                    color: Theme.accent
                                }
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Row {
                                spacing: 8
                                Text {
                                    text: qsTr("File Indexing")
                                    color: Theme.textPrimary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 14
                                    font.bold: true
                                } 
                                Rectangle {
                                    visible: root.indexingChanged
                                    height: 16
                                    width: selectedText1.contentWidth + 10
                                    radius: 4
                                    color: Qt.rgba(Theme.success.r, Theme.success.g, Theme.success.b, 0.15)
                                    border.color: Theme.success
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        id: selectedText1
                                        text: qsTr("Selected for application")
                                        color: Theme.success
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 8
                                        font.bold: true
                                        anchors.centerIn: parent
                                    }
                                }
                            }

                            Text {
                                text: qsTr("Controls file search indexing services and drive index properties.")
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                            }
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 16

                        MeguSwitch {
                            id: mainIndexingSwitch
                            checked: root.mainChecked
                            indeterminate: root.mainIndeterminate
                            anchors.verticalCenter: parent.verticalCenter
                            onToggled: (isChecked) => {
                                root.toggleMain();
                            }
                        }

                        // Arrow button that slides right on hover & opens sidebar drawer
                        Rectangle {
                            width: 32
                            height: 32
                            radius: 16
                            color: arrowMouseArea.containsMouse ? Theme.accentDim : "transparent"
                            border.color: arrowMouseArea.containsMouse ? Theme.accent : Theme.border
                            border.width: 1
                            anchors.verticalCenter: parent.verticalCenter

                            Behavior on color { ColorAnimation { duration: Theme.animFast } }
                            Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                            Item {
                                width: 14
                                height: 14
                                anchors.centerIn: parent
                                x: arrowMouseArea.containsMouse ? (parent.width/2 - 5) : (parent.width/2 - 7)
                                Behavior on x { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }
                                Image {
                                    id: arrow1Img
                                    source: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"
                                    anchors.fill: parent
                                    sourceSize.width: 14
                                    sourceSize.height: 14
                                    visible: false
                                }
                                ColorOverlay {
                                    anchors.fill: arrow1Img
                                    source: arrow1Img
                                    color: arrowMouseArea.containsMouse ? Theme.accent : Theme.textSecondary
                                }
                            }

                            MouseArea {
                                id: arrowMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.activeDrawer = "indexing";
                                }
                            }
                        }
                    }
                }
            }

            // 2. LATENCY & MOUSE TWEAKS
            Column {
                width: parent.width
                spacing: 8

                Row {
                    spacing: 8
                    height: 16
                    visible: root.currentSection === "core"

                    Rectangle {
                        width: 4
                        height: 16
                        radius: 2
                        color: Theme.accent
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: qsTr("Latency & Mouse Tweaks")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }



                // Xbox app Panel
                AcrylicPanel {
                    id: xboxPanel
                    visible: root.currentSection === "core"
                    width: parent.width
                    height: 84

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 10
                            color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                            anchors.verticalCenter: parent.verticalCenter

                            Item {
                                width: 20
                                height: 20
                                anchors.centerIn: parent
                                Image {
                                    id: xboxPanel_iconImg
                                    source: "qrc:/MeguPackOptimizer/src/resources/settings.svg"
                                    anchors.fill: parent
                                    sourceSize.width: 20
                                    sourceSize.height: 20
                                    visible: false
                                }
                                ColorOverlay {
                                    anchors.fill: xboxPanel_iconImg
                                    source: xboxPanel_iconImg
                                    color: Theme.accent
                                }
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Row {
                                spacing: 8
                                Text {
                                    text: qsTr("Xbox App & Game Bar")
                                    color: Theme.textPrimary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 14
                                    font.bold: true
                                } 
                                Rectangle {
                                    visible: root.xboxChanged
                                    height: 16
                                    width: selectedText2.contentWidth + 10
                                    radius: 4
                                    color: Qt.rgba(Theme.success.r, Theme.success.g, Theme.success.b, 0.15)
                                    border.color: Theme.success
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        id: selectedText2
                                        text: qsTr("Selected for application")
                                        color: Theme.success
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 8
                                        font.bold: true
                                        anchors.centerIn: parent
                                    }
                                }
                            }

                            Text {
                                text: qsTr("Completely remove all Xbox overlays, TCUI, and game bar apps to optimize mouse input latency.")
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                            }
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 16

                        // Status text pill: Installed / Removed
                        Rectangle {
                            height: 24
                            width: 80
                            radius: 12
                            color: optimizerBackend.xboxInstalled ? (Theme.currentTheme === "Белоснежная" || Theme.currentTheme === "Розовая" ? "#0F000000" : "#1A2536") : Theme.accentDim
                            border.color: optimizerBackend.xboxInstalled ? (Theme.currentTheme === "Белоснежная" || Theme.currentTheme === "Розовая" ? "#2B3F5C" : "#2B3F5C") : Theme.accent
                            border.width: 1
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                text: optimizerBackend.xboxInstalled ? qsTr("Installed") : qsTr("Removed")
                                color: optimizerBackend.xboxInstalled ? Theme.textSecondary : Theme.accent
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                                font.bold: true
                                anchors.centerIn: parent
                            }
                        }

                        // Arrow button
                        Rectangle {
                            width: 32
                            height: 32
                            radius: 16
                            color: xboxArrowMouseArea.containsMouse ? Theme.accentDim : "transparent"
                            border.color: xboxArrowMouseArea.containsMouse ? Theme.accent : Theme.border
                            border.width: 1
                            anchors.verticalCenter: parent.verticalCenter

                            Behavior on color { ColorAnimation { duration: Theme.animFast } }
                            Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                            Item {
                                width: 14
                                height: 14
                                anchors.centerIn: parent
                                x: xboxArrowMouseArea.containsMouse ? (parent.width/2 - 5) : (parent.width/2 - 7)
                                Behavior on x { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }
                                Image {
                                    id: arrow2Img
                                    source: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"
                                    anchors.fill: parent
                                    sourceSize.width: 14
                                    sourceSize.height: 14
                                    visible: false
                                }
                                ColorOverlay {
                                    anchors.fill: arrow2Img
                                    source: arrow2Img
                                    color: xboxArrowMouseArea.containsMouse ? Theme.accent : Theme.textSecondary
                                }
                            }

                            MouseArea {
                                id: xboxArrowMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.activeDrawer = "xbox";
                                }
                            }
                        }
                    }
                }

                // Multi-Plane Overlay (MPO) Panel
                AcrylicPanel {
                    id: mpoPanel
                    visible: root.currentSection === "core"
                    width: parent.width
                    height: 84

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 10
                            color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                            anchors.verticalCenter: parent.verticalCenter

                            Item {
                                width: 20
                                height: 20
                                anchors.centerIn: parent
                                Image {
                                    id: mpoPanel_iconImg
                                    source: "qrc:/MeguPackOptimizer/src/resources/monitor.svg"
                                    anchors.fill: parent
                                    sourceSize.width: 20
                                    sourceSize.height: 20
                                    visible: false
                                }
                                ColorOverlay {
                                    anchors.fill: mpoPanel_iconImg
                                    source: mpoPanel_iconImg
                                    color: Theme.accent
                                }
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Row {
                                spacing: 8
                                Text {
                                    text: qsTr("Multi-Plane Overlay (MPO)")
                                    color: Theme.textPrimary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 14
                                    font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                } 
                                ShowPathButton {
                                    anchors.verticalCenter: parent.verticalCenter
                                    onClicked: { optimizerBackend.showPath("mpo"); }
                                }
                            }

                            Text {
                                text: qsTr("Configure DWM multi-plane overlay modes to optimize latency and eliminate game stuttering.")
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                            }
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 16

                        // Current Value indicator pill
                        Rectangle {
                            height: 24
                            width: {
                                if (optimizerBackend.mpoValue === 0) return 90;
                                if (optimizerBackend.mpoValue === 5) return 100;
                                return 85;
                            }
                            radius: 12
                            color: (optimizerBackend.mpoValue === 5) ? Theme.accentDim : (Theme.currentTheme === "Белоснежная" || Theme.currentTheme === "Розовая" ? "#0F000000" : "#1A2536")
                            border.color: (optimizerBackend.mpoValue === 5) ? Theme.accent : "#2B3F5C"
                            border.width: 1
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                text: {
                                    if (optimizerBackend.mpoValue === 5) return qsTr("Disabled (5)");
                                    if (optimizerBackend.mpoValue === 0) return qsTr("Default (0)");
                                    return qsTr("Mode %1").arg(optimizerBackend.mpoValue);
                                }
                                color: (optimizerBackend.mpoValue === 5) ? Theme.accent : Theme.textSecondary
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                                font.bold: true
                                anchors.centerIn: parent
                            }
                        }

                        // Arrow button
                        Rectangle {
                            width: 32
                            height: 32
                            radius: 16
                            color: mpoArrowMouseArea.containsMouse ? Theme.accentDim : "transparent"
                            border.color: mpoArrowMouseArea.containsMouse ? Theme.accent : Theme.border
                            border.width: 1
                            anchors.verticalCenter: parent.verticalCenter

                            Behavior on color { ColorAnimation { duration: Theme.animFast } }
                            Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                            Item {
                                width: 14
                                height: 14
                                anchors.centerIn: parent
                                x: mpoArrowMouseArea.containsMouse ? (parent.width/2 - 5) : (parent.width/2 - 7)
                                Behavior on x { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }
                                Image {
                                    id: arrow3Img
                                    source: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"
                                    anchors.fill: parent
                                    sourceSize.width: 14
                                    sourceSize.height: 14
                                    visible: false
                                }
                                ColorOverlay {
                                    anchors.fill: arrow3Img
                                    source: arrow3Img
                                    color: mpoArrowMouseArea.containsMouse ? Theme.accent : Theme.textSecondary
                                }
                            }

                            MouseArea {
                                id: mpoArrowMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.activeDrawer = "mpo";
                                }
                            }
                        }
                    }
                }

                // Visual Effects Panel
                AcrylicPanel {
                    id: visualEffectsPanel
                    visible: root.currentSection === "core"
                    width: parent.width
                    height: 84

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 10
                            color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                            anchors.verticalCenter: parent.verticalCenter

                            Item {
                                width: 20
                                height: 20
                                anchors.centerIn: parent
                                Image {
                                    id: visualEffectsPanel_iconImg
                                    source: "qrc:/MeguPackOptimizer/src/resources/monitor.svg"
                                    anchors.fill: parent
                                    sourceSize.width: 20
                                    sourceSize.height: 20
                                    visible: false
                                }
                                ColorOverlay {
                                    anchors.fill: visualEffectsPanel_iconImg
                                    source: visualEffectsPanel_iconImg
                                    color: Theme.accent
                                }
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Row {
                                spacing: 8
                                Text {
                                    text: qsTr("Visual Effects")
                                    color: Theme.textPrimary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 14
                                    font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                } 
                                ShowPathButton {
                                    anchors.verticalCenter: parent.verticalCenter
                                    onClicked: { optimizerBackend.showPath("visualeffects"); }
                                }
                                Rectangle {
                                    visible: root.visualEffectsChanged
                                    height: 16
                                    width: selectedTextVfx.contentWidth + 10
                                    radius: 4
                                    color: Qt.rgba(Theme.success.r, Theme.success.g, Theme.success.b, 0.15)
                                    border.color: Theme.success
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        id: selectedTextVfx
                                        text: qsTr("Selected for application")
                                        color: Theme.success
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 8
                                        font.bold: true
                                        anchors.centerIn: parent
                                    }
                                }
                            }

                            Text {
                                text: qsTr("Optimize Windows animations, shadows, and rendering effects to improve system responsiveness.")
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                            }
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 16

                        ShowPathButton {
                            text: qsTr("Open")
                            iconSource: "qrc:/MeguPackOptimizer/src/resources/settings.svg"
                            anchors.verticalCenter: parent.verticalCenter
                            onClicked: { root.activeDrawer = "visualEffects"; }
                        }

                        MeguSwitch {
                            checked: root.visualEffectsPreset === 1
                            indeterminate: root.visualEffectsPreset === 3
                            anchors.verticalCenter: parent.verticalCenter
                            onToggled: (isChecked) => {
                                root.setPreset(isChecked ? 1 : 2);
                            }
                        }
                    }
                }

                // Core Isolation Panel
                AcrylicPanel {
                    id: coreIsolationPanel
                    visible: root.currentSection === "core"
                    width: parent.width
                    height: (optimizerBackend.coreIsolationActive !== optimizerBackend.bootCoreIsolationActive) ? 128 : 84

                    Behavior on height {
                        NumberAnimation { duration: Theme.animNormal; easing.type: Easing.InOutQuad }
                    }

                    Column {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        spacing: 12

                        // Main Row
                        Item {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 40

                            Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 10
                            color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                            anchors.verticalCenter: parent.verticalCenter

                            Item {
                                width: 20
                                height: 20
                                anchors.centerIn: parent
                                Image {
                                    id: coreIsolationPanel_iconImg
                                    source: "qrc:/MeguPackOptimizer/src/resources/cores.svg"
                                    anchors.fill: parent
                                    sourceSize.width: 20
                                    sourceSize.height: 20
                                    visible: false
                                }
                                ColorOverlay {
                                    anchors.fill: coreIsolationPanel_iconImg
                                    source: coreIsolationPanel_iconImg
                                    color: Theme.accent
                                }
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Row {
                                spacing: 8
                                Text {
                                    text: qsTr("Core Isolation")
                                    color: Theme.textPrimary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 14
                                    font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                } 
                                ShowPathButton {
                                    anchors.verticalCenter: parent.verticalCenter
                                    onClicked: { optimizerBackend.showPath("coreisolation"); }
                                }
                                Rectangle {
                                    visible: root.coreIsolationChanged
                                    height: 16
                                    width: selectedTextCoreIsol.contentWidth + 10
                                    radius: 4
                                    color: Qt.rgba(Theme.success.r, Theme.success.g, Theme.success.b, 0.15)
                                    border.color: Theme.success
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        id: selectedTextCoreIsol
                                        text: qsTr("Selected for application")
                                        color: Theme.success
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 8
                                        font.bold: true
                                        anchors.centerIn: parent
                                    }
                                }
                            }

                            Text {
                                text: qsTr("Disabling kernel memory integrity reduces CPU overhead and input latency.")
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                            }
                        }
                    }

                            Row {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 16

                                MeguSwitch {
                                    checked: optimizerBackend.coreIsolationActive
                                    anchors.verticalCenter: parent.verticalCenter
                                    onToggled: (isChecked) => {
                                        optimizerBackend.coreIsolationActive = isChecked;
                                    }
                                }
                            }
                        }

                        // Separator Line
                        Rectangle {
                            width: parent.width
                            height: 1
                            color: Theme.border
                            opacity: 0.3
                            visible: (optimizerBackend.coreIsolationActive !== optimizerBackend.bootCoreIsolationActive)
                        }

                        // Reboot Warning Section
                        Row {
                            width: parent.width
                            visible: (optimizerBackend.coreIsolationActive !== optimizerBackend.bootCoreIsolationActive)
                            spacing: 8

                            Item {
                                width: 16
                                height: 16
                                anchors.verticalCenter: parent.verticalCenter
                                Image {
                                    id: ciWarningIconImg
                                    source: "qrc:/MeguPackOptimizer/src/resources/warning.svg"
                                    anchors.fill: parent
                                    sourceSize.width: 16
                                    sourceSize.height: 16
                                    visible: false
                                }
                                ColorOverlay {
                                    anchors.fill: ciWarningIconImg
                                    source: ciWarningIconImg
                                    color: Theme.warning
                                }
                            }

                            Text {
                                text: qsTr("Please restart your PC to apply Core Isolation changes.")
                                color: Theme.warning
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }

                // Mouse Acceleration Panel
                AcrylicPanel {
                    id: mouseAccelerationPanel
                    visible: root.currentSection === "core"
                    width: parent.width
                    height: 84

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 10
                            color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                            anchors.verticalCenter: parent.verticalCenter

                            Item {
                                width: 20
                                height: 20
                                anchors.centerIn: parent
                                Image {
                                    id: mouseAccelerationPanel_iconImg
                                    source: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"
                                    anchors.fill: parent
                                    sourceSize.width: 20
                                    sourceSize.height: 20
                                    visible: false
                                }
                                ColorOverlay {
                                    anchors.fill: mouseAccelerationPanel_iconImg
                                    source: mouseAccelerationPanel_iconImg
                                    color: Theme.accent
                                }
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Row {
                                spacing: 8
                                Text {
                                    text: qsTr("Mouse Acceleration")
                                    color: Theme.textPrimary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 14
                                    font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                } 
                                ShowPathButton {
                                    anchors.verticalCenter: parent.verticalCenter
                                    onClicked: { optimizerBackend.showPath("mouseacceleration"); }
                                }
                                Rectangle {
                                    visible: root.mouseAccelerationChanged
                                    height: 16
                                    width: selectedTextMouse.contentWidth + 10
                                    radius: 4
                                    color: Qt.rgba(Theme.success.r, Theme.success.g, Theme.success.b, 0.15)
                                    border.color: Theme.success
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        id: selectedTextMouse
                                        text: qsTr("Selected for application")
                                        color: Theme.success
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 8
                                        font.bold: true
                                        anchors.centerIn: parent
                                    }
                                }
                            }

                            Text {
                                text: qsTr("Enhance pointer precision toggle to enable or disable system mouse acceleration.")
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                            }
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 16

                        MeguSwitch {
                            checked: optimizerBackend.mouseAccelerationActive
                            anchors.verticalCenter: parent.verticalCenter
                            onToggled: (isChecked) => {
                                optimizerBackend.mouseAccelerationActive = isChecked;
                            }
                        }
                    }
                }

                // Game Mode Panel
                AcrylicPanel {
                    id: gameModePanel
                    visible: root.currentSection === "core"
                    width: parent.width
                    height: 84

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 10
                            color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                            anchors.verticalCenter: parent.verticalCenter

                            Item {
                                width: 20
                                height: 20
                                anchors.centerIn: parent
                                Image {
                                    id: gameModePanel_iconImg
                                    source: "qrc:/MeguPackOptimizer/src/resources/bolt.svg"
                                    anchors.fill: parent
                                    sourceSize.width: 20
                                    sourceSize.height: 20
                                    visible: false
                                }
                                ColorOverlay {
                                    anchors.fill: gameModePanel_iconImg
                                    source: gameModePanel_iconImg
                                    color: Theme.accent
                                }
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Row {
                                spacing: 8
                                Text {
                                    text: qsTr("Game Mode")
                                    color: Theme.textPrimary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 14
                                    font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                } 
                                ShowPathButton {
                                    anchors.verticalCenter: parent.verticalCenter
                                    onClicked: { optimizerBackend.showPath("gamemode"); }
                                }
                                Rectangle {
                                    visible: root.gameModeChanged
                                    height: 16
                                    width: selectedTextGameMode.contentWidth + 10
                                    radius: 4
                                    color: Qt.rgba(Theme.success.r, Theme.success.g, Theme.success.b, 0.15)
                                    border.color: Theme.success
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        id: selectedTextGameMode
                                        text: qsTr("Selected for application")
                                        color: Theme.success
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 8
                                        font.bold: true
                                        anchors.centerIn: parent
                                    }
                                }
                            }

                            Text {
                                text: qsTr("Enables or disables Windows Game Mode to prioritize gaming performance and stabilize FPS.")
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                            }
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 16

                        MeguSwitch {
                            checked: optimizerBackend.gameModeActive
                            anchors.verticalCenter: parent.verticalCenter
                            onToggled: (isChecked) => {
                                optimizerBackend.gameModeActive = isChecked;
                            }
                        }
                    }
                }

                // Discord Overlay Panel
                AcrylicPanel {
                    id: discordOverlayPanel
                    visible: root.currentSection === "core"
                    width: parent.width
                    height: root.isDiscordOpen ? 92 : 84
                    Behavior on height { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.InOutQuad } }

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        // Rounded square badge
                        Rectangle {
                            width: 40
                            height: 40
                            radius: 10
                            color: Qt.rgba(0.35, 0.4, 0.9, 0.15)
                            anchors.verticalCenter: parent.verticalCenter

                            Item {
                                width: 20
                                height: 20
                                anchors.centerIn: parent

                                Image {
                                    id: discordIconImg
                                    source: "qrc:/MeguPackOptimizer/src/resources/folder.svg"
                                    anchors.fill: parent
                                    sourceSize.width: 20
                                    sourceSize.height: 20
                                    visible: false
                                }
                                ColorOverlay {
                                    anchors.fill: discordIconImg
                                    source: discordIconImg
                                    color: "#5865F2"
                                }
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Row {
                                spacing: 8
                                Text {
                                    text: qsTr("Discord In-Game Overlay")
                                    color: Theme.textPrimary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 14
                                    font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                ShowPathButton {
                                    anchors.verticalCenter: parent.verticalCenter
                                    onClicked: { optimizerBackend.showPath("discord"); }
                                }
                                Rectangle {
                                    visible: root.discordOverlayChanged
                                    height: 16
                                    width: selectedTextDiscord.contentWidth + 10
                                    radius: 4
                                    color: Qt.rgba(Theme.success.r, Theme.success.g, Theme.success.b, 0.15)
                                    border.color: Theme.success
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        id: selectedTextDiscord
                                        text: qsTr("Selected for application")
                                        color: Theme.success
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 8
                                        font.bold: true
                                        anchors.centerIn: parent
                                    }
                                }
                            }

                            Text {
                                text: qsTr("Disable Discord's in-game overlay DLL injection to reduce CPU overhead and eliminate graphics micro-stutters.")
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                            }

                            Text {
                                visible: root.isDiscordOpen
                                text: qsTr("Close Discord before optimization")
                                color: Theme.warning
                                font.family: Theme.fontFamily
                                font.pixelSize: 9
                                font.bold: true
                            }
                        }
                    }

                    Row {
                        id: discordRightControls
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 16

                        MeguSwitch {
                            checked: optimizerBackend.discordOverlayActive
                            anchors.verticalCenter: parent.verticalCenter
                            onToggled: (isChecked) => {
                                optimizerBackend.discordOverlayActive = isChecked;
                            }
                        }
                    }
                }

                // Windows Defender Firewall Panel
                AcrylicPanel {
                    id: firewallPanel
                    visible: root.currentSection === "core"
                    width: parent.width
                    height: 84

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 10
                            color: Qt.rgba(0.9, 0.3, 0.1, 0.15)
                            anchors.verticalCenter: parent.verticalCenter

                            Item {
                                width: 20
                                height: 20
                                anchors.centerIn: parent
                                Image {
                                    id: firewallPanel_iconImg
                                    source: "qrc:/MeguPackOptimizer/src/resources/warning.svg"
                                    anchors.fill: parent
                                    sourceSize.width: 20
                                    sourceSize.height: 20
                                    visible: false
                                }
                                ColorOverlay {
                                    anchors.fill: firewallPanel_iconImg
                                    source: firewallPanel_iconImg
                                    color: "#FF5722"
                                }
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Row {
                                spacing: 8
                                Text {
                                    text: qsTr("Windows Defender Firewall")
                                    color: Theme.textPrimary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 14
                                    font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                } 
                                ShowPathButton {
                                    anchors.verticalCenter: parent.verticalCenter
                                    onClicked: { optimizerBackend.showPath("firewall"); }
                                }
                                Rectangle {
                                    visible: root.firewallChanged
                                    height: 16
                                    width: selectedText6.contentWidth + 10
                                    radius: 4
                                    color: Qt.rgba(Theme.success.r, Theme.success.g, Theme.success.b, 0.15)
                                    border.color: Theme.success
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        id: selectedText6
                                        text: qsTr("Selected for application")
                                        color: Theme.success
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 8
                                        font.bold: true
                                        anchors.centerIn: parent
                                    }
                                }
                            }

                            Text {
                                text: qsTr("Enables or disables Windows Defender Firewall to control network traffic protection.")
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                            }
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 16

                        MeguSwitch {
                            checked: optimizerBackend.firewallActive
                            anchors.verticalCenter: parent.verticalCenter
                            onToggled: (isChecked) => {
                                optimizerBackend.firewallActive = isChecked;
                            }
                        }
                    }
                }


                // Remote Access (RDP) Panel
                AcrylicPanel {
                    id: remoteAccessPanel
                    visible: root.currentSection === "core"
                    width: parent.width
                    height: 84

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 10
                            color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                            anchors.verticalCenter: parent.verticalCenter

                            Item {
                                width: 20
                                height: 20
                                anchors.centerIn: parent
                                Image {
                                    id: remoteAccessPanel_iconImg
                                    source: "qrc:/MeguPackOptimizer/src/resources/monitor.svg"
                                    anchors.fill: parent
                                    sourceSize.width: 20
                                    sourceSize.height: 20
                                    visible: false
                                }
                                ColorOverlay {
                                    anchors.fill: remoteAccessPanel_iconImg
                                    source: remoteAccessPanel_iconImg
                                    color: Theme.accent
                                }
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Row {
                                spacing: 8
                                Text {
                                    text: qsTr("Remote Access (RDP)")
                                    color: Theme.textPrimary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 14
                                    font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                } 
                                ShowPathButton {
                                    anchors.verticalCenter: parent.verticalCenter
                                    onClicked: { optimizerBackend.showPath("remoteaccess"); }
                                }
                                Rectangle {
                                    visible: root.remoteAccessChanged
                                    height: 16
                                    width: selectedTextRemote.contentWidth + 10
                                    radius: 4
                                    color: Qt.rgba(Theme.success.r, Theme.success.g, Theme.success.b, 0.15)
                                    border.color: Theme.success
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        id: selectedTextRemote
                                        text: qsTr("Selected for application")
                                        color: Theme.success
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 8
                                        font.bold: true
                                        anchors.centerIn: parent
                                    }
                                }
                            }

                            Text {
                                text: qsTr("Disable Remote Desktop (RDP) and Remote Assistance services to secure system and save background resources.")
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                            }
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 16

                        MeguSwitch {
                            checked: optimizerBackend.remoteAccessActive
                            anchors.verticalCenter: parent.verticalCenter
                            onToggled: (isChecked) => {
                                optimizerBackend.remoteAccessActive = isChecked;
                            }
                        }
                    }
                }

                // Telemetry Panel
                AcrylicPanel {
                    id: telemetryPanel
                    visible: root.currentSection === "telemetry"
                    width: parent.width
                    height: 84

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 10
                            color: Qt.rgba(0.5, 0.3, 0.9, 0.15)
                            anchors.verticalCenter: parent.verticalCenter

                            Item {
                                width: 20
                                height: 20
                                anchors.centerIn: parent
                                Image {
                                    id: telemetryPanel_iconImg
                                    source: "qrc:/MeguPackOptimizer/src/resources/help.svg"
                                    anchors.fill: parent
                                    sourceSize.width: 20
                                    sourceSize.height: 20
                                    visible: false
                                }
                                ColorOverlay {
                                    anchors.fill: telemetryPanel_iconImg
                                    source: telemetryPanel_iconImg
                                    color: "#8A2BE2"
                                }
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Row {
                                spacing: 8
                                Text {
                                    text: qsTr("Telemetry")
                                    color: Theme.textPrimary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 14
                                    font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                } 
                                ShowPathButton {
                                    anchors.verticalCenter: parent.verticalCenter
                                    onClicked: { optimizerBackend.showPath("telemetry"); }
                                }
                                Rectangle {
                                    visible: root.telemetryChanged
                                    height: 16
                                    width: selectedTextTelemetry.contentWidth + 10
                                    radius: 4
                                    color: Qt.rgba(Theme.success.r, Theme.success.g, Theme.success.b, 0.15)
                                    border.color: Theme.success
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        id: selectedTextTelemetry
                                        text: qsTr("Selected for application")
                                        color: Theme.success
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 8
                                        font.bold: true
                                        anchors.centerIn: parent
                                    }
                                }
                            }

                            Text {
                                text: qsTr("Neutralize diagnostics data collecting tracking, CEIP program and WER error report services to protect privacy.")
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                            }
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 16

                        Rectangle {
                            width: 32
                            height: 32
                            radius: 16
                            color: telemetryArrowMouseArea.containsMouse ? Theme.accentDim : "transparent"
                            border.color: telemetryArrowMouseArea.containsMouse ? Theme.accent : Theme.border
                            border.width: 1
                            anchors.verticalCenter: parent.verticalCenter

                            Behavior on color { ColorAnimation { duration: Theme.animFast } }
                            Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                            Item {
                                width: 14
                                height: 14
                                anchors.centerIn: parent
                                Image {
                                    id: telemetryArrowImg
                                    source: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"
                                    anchors.fill: parent
                                    sourceSize.width: 14
                                    sourceSize.height: 14
                                    visible: false
                                }
                                ColorOverlay {
                                    anchors.fill: telemetryArrowImg
                                    source: telemetryArrowImg
                                    color: telemetryArrowMouseArea.containsMouse ? Theme.accent : Theme.textSecondary
                                }
                            }

                            MouseArea {
                                id: telemetryArrowMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.activeDrawer = "telemetry";
                                }
                            }
                        }

                        MeguSwitch {
                            checked: !optimizerBackend.telemetryActive
                            anchors.verticalCenter: parent.verticalCenter
                            onToggled: (isChecked) => {
                                optimizerBackend.telemetryActive = !isChecked;
                            }
                        }
                    }
                }

                // Ads & Privacy Panel
                AcrylicPanel {
                    id: adsPanel
                    visible: root.currentSection === "telemetry"
                    width: parent.width
                    height: detailsExpanded ? 84 + adsDetailsContainer.implicitHeight + 20 : 84
                    property bool detailsExpanded: false

                    Behavior on height {
                        NumberAnimation { duration: Theme.animNormal; easing.type: Easing.InOutQuad }
                    }

                    Column {
                        id: adsColumn
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        spacing: 16

                        // Header Row
                        Row {
                            width: parent.width
                            height: 84
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16
                            spacing: 12

                            Rectangle {
                                width: 40
                                height: 40
                                radius: 10
                                color: Qt.rgba(0.9, 0.45, 0.1, 0.15)
                                anchors.verticalCenter: parent.verticalCenter

                                Item {
                                    width: 20
                                    height: 20
                                    anchors.centerIn: parent
                                    Image {
                                        id: adsPanel_iconImg
                                        source: "qrc:/MeguPackOptimizer/src/resources/ads.svg"
                                        anchors.fill: parent
                                        sourceSize.width: 20
                                        sourceSize.height: 20
                                        visible: false
                                    }
                                    ColorOverlay {
                                        anchors.fill: adsPanel_iconImg
                                        source: adsPanel_iconImg
                                        color: "#FF8C00"
                                    }
                                }
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 2
                                width: parent.width - 40 - 12 - expandBtn.width - 12

                                Row {
                                    spacing: 8
                                    Text {
                                        text: qsTr("Ads")
                                        color: Theme.textPrimary
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 14
                                        font.bold: true
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    ShowPathButton {
                                        anchors.verticalCenter: parent.verticalCenter
                                        onClicked: { optimizerBackend.showPath("ads"); }
                                    }
                                    Rectangle {
                                        visible: root.adsChanged
                                        height: 16
                                        width: selectedTextAds.contentWidth + 10
                                        radius: 4
                                        color: Qt.rgba(Theme.success.r, Theme.success.g, Theme.success.b, 0.15)
                                        border.color: Theme.success
                                        border.width: 1
                                        anchors.verticalCenter: parent.verticalCenter
                                        Text {
                                            id: selectedTextAds
                                            text: qsTr("Selected for application")
                                            color: Theme.success
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 8
                                            font.bold: true
                                            anchors.centerIn: parent
                                        }
                                    }
                                }

                                Text {
                                    text: qsTr("Change ads related settings that might display content promoting products or new features.")
                                    color: Theme.textMuted
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                    width: parent.width
                                }
                            }

                            // Expand button on top right
                            Rectangle {
                                id: expandBtn
                                width: 32
                                height: 32
                                radius: 16
                                color: expandMouseArea.containsMouse ? Theme.accentDim : "transparent"
                                border.color: expandMouseArea.containsMouse ? Theme.accent : Theme.border
                                border.width: 1
                                anchors.verticalCenter: parent.verticalCenter

                                Behavior on color { ColorAnimation { duration: Theme.animFast } }
                                Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                                Item {
                                    width: 14
                                    height: 14
                                    anchors.centerIn: parent
                                    rotation: adsPanel.detailsExpanded ? 180 : 0
                                    Behavior on rotation { NumberAnimation { duration: Theme.animFast } }

                                    Image {
                                        id: expandArrowImg
                                        source: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"
                                        anchors.fill: parent
                                        sourceSize.width: 14
                                        sourceSize.height: 14
                                        visible: false
                                    }
                                    ColorOverlay {
                                        anchors.fill: expandArrowImg
                                        source: expandArrowImg
                                        color: expandMouseArea.containsMouse ? Theme.accent : Theme.textSecondary
                                    }
                                }

                                MouseArea {
                                    id: expandMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        adsPanel.detailsExpanded = !adsPanel.detailsExpanded;
                                    }
                                }
                            }
                        }

                        // Separator line
                        Rectangle {
                            height: 1
                            width: parent.width - 32
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: Theme.border
                            opacity: adsPanel.detailsExpanded ? 0.2 : 0.0
                            Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
                        }

                        // Expansion Container listing the 9 options
                        Column {
                            id: adsDetailsContainer
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 20
                            anchors.rightMargin: 20
                            spacing: 4
                            visible: adsPanel.detailsExpanded
                            opacity: adsPanel.detailsExpanded ? 1.0 : 0.0
                            Behavior on opacity { NumberAnimation { duration: Theme.animFast } }

                            // 1. Tailored experiences
                            Row {
                                width: parent.width
                                height: 40

                                Row {
                                    spacing: 12
                                    anchors.verticalCenter: parent.verticalCenter
                                    Image {
                                        id: iconTailored
                                        source: "qrc:/MeguPackOptimizer/src/resources/help.svg"
                                        sourceSize.width: 16
                                        sourceSize.height: 16
                                        width: 16
                                        height: 16
                                        visible: false
                                    }
                                    ColorOverlay {
                                        anchors.fill: iconTailored
                                        source: iconTailored
                                        color: optimizerBackend.adsTailoredExperiencesActive !== optimizerBackend.originalAdsTailoredExperiencesActive ? Theme.accent : Theme.textSecondary
                                    }
                                    Text {
                                        text: qsTr("Tailored experiences")
                                        color: Theme.textPrimary
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 12
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                MeguSwitch {
                                    checked: optimizerBackend.adsTailoredExperiencesActive
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    onToggled: (val) => { optimizerBackend.adsTailoredExperiencesActive = val; }
                                }
                            }

                            // 2. Advertising ID
                            Row {
                                width: parent.width
                                height: 40

                                Row {
                                    spacing: 12
                                    anchors.verticalCenter: parent.verticalCenter
                                    Image {
                                        id: iconAdv
                                        source: "qrc:/MeguPackOptimizer/src/resources/settings.svg"
                                        sourceSize.width: 16
                                        sourceSize.height: 16
                                        width: 16
                                        height: 16
                                        visible: false
                                    }
                                    ColorOverlay {
                                        anchors.fill: iconAdv
                                        source: iconAdv
                                        color: optimizerBackend.adsAdvertisingIdActive !== optimizerBackend.originalAdsAdvertisingIdActive ? Theme.accent : Theme.textSecondary
                                    }
                                    Text {
                                        text: qsTr("Advertising ID")
                                        color: Theme.textPrimary
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 12
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                MeguSwitch {
                                    checked: optimizerBackend.adsAdvertisingIdActive
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    onToggled: (val) => { optimizerBackend.adsAdvertisingIdActive = val; }
                                }
                            }

                            // 3. Suggested content in settings
                            Row {
                                width: parent.width
                                height: 40

                                Row {
                                    spacing: 12
                                    anchors.verticalCenter: parent.verticalCenter
                                    Image {
                                        id: iconSuggestedContent
                                        source: "qrc:/MeguPackOptimizer/src/resources/settings.svg"
                                        sourceSize.width: 16
                                        sourceSize.height: 16
                                        width: 16
                                        height: 16
                                        visible: false
                                    }
                                    ColorOverlay {
                                        anchors.fill: iconSuggestedContent
                                        source: iconSuggestedContent
                                        color: optimizerBackend.adsSuggestedContentActive !== optimizerBackend.originalAdsSuggestedContentActive ? Theme.accent : Theme.textSecondary
                                    }
                                    Text {
                                        text: qsTr("Suggested content in settings")
                                        color: Theme.textPrimary
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 12
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                MeguSwitch {
                                    checked: optimizerBackend.adsSuggestedContentActive
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    onToggled: (val) => { optimizerBackend.adsSuggestedContentActive = val; }
                                }
                            }

                            // 4. Home page in settings app
                            Row {
                                width: parent.width
                                height: 40

                                Row {
                                    spacing: 12
                                    anchors.verticalCenter: parent.verticalCenter
                                    Image {
                                        id: iconHome
                                        source: "qrc:/MeguPackOptimizer/src/resources/monitor.svg"
                                        sourceSize.width: 16
                                        sourceSize.height: 16
                                        width: 16
                                        height: 16
                                        visible: false
                                    }
                                    ColorOverlay {
                                        anchors.fill: iconHome
                                        source: iconHome
                                        color: optimizerBackend.adsSettingsHomeActive !== optimizerBackend.originalAdsSettingsHomeActive ? Theme.accent : Theme.textSecondary
                                    }
                                    Text {
                                        text: qsTr("Home page in the settings app")
                                        color: Theme.textPrimary
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 12
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                MeguSwitch {
                                    checked: optimizerBackend.adsSettingsHomeActive
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    onToggled: (val) => { optimizerBackend.adsSettingsHomeActive = val; }
                                }
                            }

                            // 5. Suggested notifications
                            Row {
                                width: parent.width
                                height: 40

                                Row {
                                    spacing: 12
                                    anchors.verticalCenter: parent.verticalCenter
                                    Image {
                                        id: iconSuggestedNotifications
                                        source: "qrc:/MeguPackOptimizer/src/resources/warning.svg"
                                        sourceSize.width: 16
                                        sourceSize.height: 16
                                        width: 16
                                        height: 16
                                        visible: false
                                    }
                                    ColorOverlay {
                                        anchors.fill: iconSuggestedNotifications
                                        source: iconSuggestedNotifications
                                        color: optimizerBackend.adsSuggestedNotificationsActive !== optimizerBackend.originalAdsSuggestedNotificationsActive ? Theme.accent : Theme.textSecondary
                                    }
                                    Text {
                                        text: qsTr("Suggested notifications")
                                        color: Theme.textPrimary
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 12
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                MeguSwitch {
                                    checked: optimizerBackend.adsSuggestedNotificationsActive
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    onToggled: (val) => { optimizerBackend.adsSuggestedNotificationsActive = val; }
                                }
                            }

                            // 6. Lock screen fun facts, tips and tricks
                            Row {
                                width: parent.width
                                height: 40

                                Row {
                                    spacing: 12
                                    anchors.verticalCenter: parent.verticalCenter
                                    Image {
                                        id: iconLockTips
                                        source: "qrc:/MeguPackOptimizer/src/resources/monitor.svg"
                                        sourceSize.width: 16
                                        sourceSize.height: 16
                                        width: 16
                                        height: 16
                                        visible: false
                                    }
                                    ColorOverlay {
                                        anchors.fill: iconLockTips
                                        source: iconLockTips
                                        color: optimizerBackend.adsLockScreenTipsActive !== optimizerBackend.originalAdsLockScreenTipsActive ? Theme.accent : Theme.textSecondary
                                    }
                                    Text {
                                        text: qsTr("Lock screen fun facts, tips and tricks")
                                        color: Theme.textPrimary
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 12
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                MeguSwitch {
                                    checked: optimizerBackend.adsLockScreenTipsActive
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    onToggled: (val) => { optimizerBackend.adsLockScreenTipsActive = val; }
                                }
                            }

                            // 7. Windows tips and suggestions
                            Row {
                                width: parent.width
                                height: 40

                                Row {
                                    spacing: 12
                                    anchors.verticalCenter: parent.verticalCenter
                                    Image {
                                        id: iconWinTips
                                        source: "qrc:/MeguPackOptimizer/src/resources/help.svg"
                                        sourceSize.width: 16
                                        sourceSize.height: 16
                                        width: 16
                                        height: 16
                                        visible: false
                                    }
                                    ColorOverlay {
                                        anchors.fill: iconWinTips
                                        source: iconWinTips
                                        color: optimizerBackend.adsWindowsTipsActive !== optimizerBackend.originalAdsWindowsTipsActive ? Theme.accent : Theme.textSecondary
                                    }
                                    Text {
                                        text: qsTr("Windows tips and suggestions")
                                        color: Theme.textPrimary
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 12
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                MeguSwitch {
                                    checked: optimizerBackend.adsWindowsTipsActive
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    onToggled: (val) => { optimizerBackend.adsWindowsTipsActive = val; }
                                }
                            }

                            // 8. Windows welcome experience
                            Row {
                                width: parent.width
                                height: 40

                                Row {
                                    spacing: 12
                                    anchors.verticalCenter: parent.verticalCenter
                                    Image {
                                        id: iconWelcome
                                        source: "qrc:/MeguPackOptimizer/src/resources/bolt.svg"
                                        sourceSize.width: 16
                                        sourceSize.height: 16
                                        width: 16
                                        height: 16
                                        visible: false
                                    }
                                    ColorOverlay {
                                        anchors.fill: iconWelcome
                                        source: iconWelcome
                                        color: optimizerBackend.adsWelcomeExperienceActive !== optimizerBackend.originalAdsWelcomeExperienceActive ? Theme.accent : Theme.textSecondary
                                    }
                                    Text {
                                        text: qsTr("Windows welcome experience")
                                        color: Theme.textPrimary
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 12
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                MeguSwitch {
                                    checked: optimizerBackend.adsWelcomeExperienceActive
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    onToggled: (val) => { optimizerBackend.adsWelcomeExperienceActive = val; }
                                }
                            }

                            // 9. Finish setting up your device
                            Row {
                                width: parent.width
                                height: 40

                                Row {
                                    spacing: 12
                                    anchors.verticalCenter: parent.verticalCenter
                                    Image {
                                        id: iconFinishSetup
                                        source: "qrc:/MeguPackOptimizer/src/resources/settings.svg"
                                        sourceSize.width: 16
                                        sourceSize.height: 16
                                        width: 16
                                        height: 16
                                        visible: false
                                    }
                                    ColorOverlay {
                                        anchors.fill: iconFinishSetup
                                        source: iconFinishSetup
                                        color: optimizerBackend.adsFinishSetupActive !== optimizerBackend.originalAdsFinishSetupActive ? Theme.accent : Theme.textSecondary
                                    }
                                    Text {
                                        text: qsTr("Finish setting up your device")
                                        color: Theme.textPrimary
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 12
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                MeguSwitch {
                                    checked: optimizerBackend.adsFinishSetupActive
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    onToggled: (val) => { optimizerBackend.adsFinishSetupActive = val; }
                                }
                            }
                        }
                    }
                }

                // Windows Update Panel
                AcrylicPanel {
                    id: windowsUpdatePanel
                    visible: root.currentSection === "core"
                    width: parent.width
                    height: 84

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 10
                            color: Qt.rgba(0.1, 0.6, 0.9, 0.15)
                            anchors.verticalCenter: parent.verticalCenter

                            Item {
                                width: 20
                                height: 20
                                anchors.centerIn: parent
                                Image {
                                    id: windowsUpdatePanel_iconImg
                                    source: "qrc:/MeguPackOptimizer/src/resources/settings.svg"
                                    anchors.fill: parent
                                    sourceSize.width: 20
                                    sourceSize.height: 20
                                    visible: false
                                }
                                ColorOverlay {
                                    anchors.fill: windowsUpdatePanel_iconImg
                                    source: windowsUpdatePanel_iconImg
                                    color: "#03A9F4"
                                }
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Row {
                                spacing: 8
                                Text {
                                    text: qsTr("Windows Update")
                                    color: Theme.textPrimary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 14
                                    font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                } 
                                ShowPathButton {
                                    anchors.verticalCenter: parent.verticalCenter
                                    onClicked: { optimizerBackend.showPath("windowsupdate"); }
                                }
                                Rectangle {
                                    visible: root.windowsUpdateChanged
                                    height: 16
                                    width: selectedTextUpdate.contentWidth + 10
                                    radius: 4
                                    color: Qt.rgba(Theme.success.r, Theme.success.g, Theme.success.b, 0.15)
                                    border.color: Theme.success
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        id: selectedTextUpdate
                                        text: qsTr("Selected for application")
                                        color: Theme.success
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 8
                                        font.bold: true
                                        anchors.centerIn: parent
                                    }
                                }
                            }

                            Text {
                                text: qsTr("Block auto-updates, schedule manual checks, or download security patches only to prevent unexpected reboots.")
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                            }
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 16

                        // Current Mode indicator pill
                        Rectangle {
                            height: 24
                            width: {
                                if (optimizerBackend.windowsUpdateMode === 0) return 80;
                                if (optimizerBackend.windowsUpdateMode === 1) return 110;
                                if (optimizerBackend.windowsUpdateMode === 2) return 100;
                                if (optimizerBackend.windowsUpdateMode === 3) return 85;
                                return 80;
                            }
                            radius: 12
                            color: (optimizerBackend.windowsUpdateMode !== optimizerBackend.originalWindowsUpdateMode) ? Theme.accentDim : (Theme.currentTheme === "Белоснежная" || Theme.currentTheme === "Розовая" ? "#0F000000" : "#1A2536")
                            border.color: (optimizerBackend.windowsUpdateMode !== optimizerBackend.originalWindowsUpdateMode) ? Theme.accent : "#2B3F5C"
                            border.width: 1
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                text: {
                                    if (optimizerBackend.windowsUpdateMode === 0) return qsTr("Default");
                                    if (optimizerBackend.windowsUpdateMode === 1) return qsTr("Security Only");
                                    if (optimizerBackend.windowsUpdateMode === 2) return qsTr("Manual Check");
                                    if (optimizerBackend.windowsUpdateMode === 3) return qsTr("Disabled");
                                    return qsTr("Default");
                                }
                                color: (optimizerBackend.windowsUpdateMode !== optimizerBackend.originalWindowsUpdateMode) ? Theme.accent : Theme.textSecondary
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                                font.bold: true
                                anchors.centerIn: parent
                            }
                        }

                        Rectangle {
                            width: 32
                            height: 32
                            radius: 16
                            color: wuArrowMouseArea.containsMouse ? Theme.accentDim : "transparent"
                            border.color: wuArrowMouseArea.containsMouse ? Theme.accent : Theme.border
                            border.width: 1
                            anchors.verticalCenter: parent.verticalCenter

                            Behavior on color { ColorAnimation { duration: Theme.animFast } }
                            Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                            Item {
                                width: 14
                                height: 14
                                anchors.centerIn: parent
                                Image {
                                    id: wuArrowImg
                                    source: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"
                                    anchors.fill: parent
                                    sourceSize.width: 14
                                    sourceSize.height: 14
                                    visible: false
                                }
                                ColorOverlay {
                                    anchors.fill: wuArrowImg
                                    source: wuArrowImg
                                    color: wuArrowMouseArea.containsMouse ? Theme.accent : Theme.textSecondary
                                }
                            }

                            MouseArea {
                                id: wuArrowMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.activeDrawer = "windowsUpdate";
                                }
                            }
                        }
                    }
                }



                // Notifications Panel
                AcrylicPanel {
                    id: notificationsPanel
                    visible: root.currentSection === "core"
                    width: parent.width
                    height: 84

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 10
                            color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                            anchors.verticalCenter: parent.verticalCenter

                            Item {
                                width: 20
                                height: 20
                                anchors.centerIn: parent
                                Image {
                                    id: notificationsPanel_iconImg
                                    source: "qrc:/MeguPackOptimizer/src/resources/info.svg"
                                    anchors.fill: parent
                                    sourceSize.width: 20
                                    sourceSize.height: 20
                                    visible: false
                                }
                                ColorOverlay {
                                    anchors.fill: notificationsPanel_iconImg
                                    source: notificationsPanel_iconImg
                                    color: Theme.accent
                                }
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Row {
                                spacing: 8
                                Text {
                                    text: qsTr("Windows Notifications")
                                    color: Theme.textPrimary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 14
                                    font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                } 
                                ShowPathButton {
                                    anchors.verticalCenter: parent.verticalCenter
                                    onClicked: { optimizerBackend.showPath("notifications"); }
                                }
                                Rectangle {
                                    visible: root.notificationsChanged
                                    height: 16
                                    width: selectedText8.contentWidth + 10
                                    radius: 4
                                    color: Qt.rgba(Theme.success.r, Theme.success.g, Theme.success.b, 0.15)
                                    border.color: Theme.success
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        id: selectedText8
                                        text: qsTr("Selected for application")
                                        color: Theme.success
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 8
                                        font.bold: true
                                        anchors.centerIn: parent
                                    }
                                }
                            }

                            Text {
                                text: qsTr("Disabling background notifications frees CPU interrupts and stabilizes FPS.")
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                            }
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 16

                        MeguSwitch {
                            checked: root.notificationsChecked
                            indeterminate: root.notificationsIndeterminate
                            anchors.verticalCenter: parent.verticalCenter
                            onToggled: (isChecked) => {
                                optimizerBackend.notificationsActive = isChecked;
                                optimizerBackend.notifGlobalActive = isChecked;
                                optimizerBackend.notifAppActive = isChecked;
                                optimizerBackend.notifSoundsActive = isChecked;
                                optimizerBackend.notifLockscreenActive = isChecked;
                            }
                        }

                        // Arrow button that slides right on hover & opens sidebar drawer for notifications config
                        Rectangle {
                            width: 32
                            height: 32
                            radius: 16
                            color: notificationsArrowMouseArea.containsMouse ? Theme.accentDim : "transparent"
                            border.color: notificationsArrowMouseArea.containsMouse ? Theme.accent : Theme.border
                            border.width: 1
                            anchors.verticalCenter: parent.verticalCenter

                            Behavior on color { ColorAnimation { duration: Theme.animFast } }
                            Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                            Item {
                                width: 14
                                height: 14
                                anchors.centerIn: parent
                                x: notificationsArrowMouseArea.containsMouse ? (parent.width/2 - 5) : (parent.width/2 - 7)
                                Behavior on x { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }
                                Image {
                                    id: notificationsArrowImg
                                    source: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"
                                    anchors.fill: parent
                                    sourceSize.width: 14
                                    sourceSize.height: 14
                                    visible: false
                                }
                                ColorOverlay {
                                    anchors.fill: notificationsArrowImg
                                    source: notificationsArrowImg
                                    color: notificationsArrowMouseArea.containsMouse ? Theme.accent : Theme.textSecondary
                                }
                            }

                            MouseArea {
                                id: notificationsArrowMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.activeDrawer = "notifications";
                                }
                            }
                        }
                    }
                }
            }

            // 2.5 CUSTOMIZATION CATEGORY
            Column {
                visible: root.currentSection === "customization"
                width: parent.width
                spacing: 8



                // Classic Context Menu Panel
                AcrylicPanel {
                    id: classicContextMenuPanel
                    width: parent.width
                    height: optimizerBackend.classicContextMenuActive ? 138 : 84

                    Behavior on height {
                        NumberAnimation { duration: Theme.animNormal; easing.type: Easing.InOutQuad }
                    }

                    Column {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        spacing: 12

                        // Main Row
                        Item {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 52

                            Row {
                                anchors.left: parent.left
                                anchors.leftMargin: 16
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 16

                                Rectangle {
                                    width: 40
                                    height: 40
                                    radius: 10
                                    color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                                    anchors.verticalCenter: parent.verticalCenter

                                    Item {
                                        width: 20
                                        height: 20
                                        anchors.centerIn: parent
                                        Image {
                                            id: classicContextMenuPanel_iconImg
                                            source: "qrc:/MeguPackOptimizer/src/resources/settings.svg"
                                            anchors.fill: parent
                                            sourceSize.width: 20
                                            sourceSize.height: 20
                                            visible: false
                                        }
                                        ColorOverlay {
                                            anchors.fill: classicContextMenuPanel_iconImg
                                            source: classicContextMenuPanel_iconImg
                                            color: Theme.accent
                                        }
                                    }
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 2

                                    Row {
                                        spacing: 8
                                        Text {
                                            text: qsTr("Classic Context Menu")
                                            color: Theme.textPrimary
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 14
                                            font.bold: true
                                            anchors.verticalCenter: parent.verticalCenter
                                        } 
                                        ShowPathButton {
                                            anchors.verticalCenter: parent.verticalCenter
                                            onClicked: { optimizerBackend.showPath("classiccontextmenu"); }
                                        }
                                        Rectangle {
                                            visible: root.classicContextMenuChanged
                                            height: 16
                                            width: selectedTextClassicMenu.contentWidth + 10
                                            radius: 4
                                            color: Qt.rgba(Theme.success.r, Theme.success.g, Theme.success.b, 0.15)
                                            border.color: Theme.success
                                            border.width: 1
                                            anchors.verticalCenter: parent.verticalCenter
                                            Text {
                                                id: selectedTextClassicMenu
                                                text: qsTr("Selected for application")
                                                color: Theme.success
                                                font.family: Theme.fontFamily
                                                font.pixelSize: 8
                                                font.bold: true
                                                anchors.centerIn: parent
                                            }
                                        }
                                    }

                                    Text {
                                        text: qsTr("Disables the modern Windows 11 Fluent context menu and restores the classic Windows 10 style context menu.")
                                        color: Theme.textMuted
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 11
                                    }
                                }
                            }

                            Row {
                                anchors.right: parent.right
                                anchors.rightMargin: 16
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 16

                                MeguSwitch {
                                    checked: optimizerBackend.classicContextMenuActive
                                    anchors.verticalCenter: parent.verticalCenter
                                    onToggled: (isChecked) => {
                                        optimizerBackend.classicContextMenuActive = isChecked;
                                    }
                                }
                            }
                        }

                        // Separator Line
                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16
                            height: 1
                            color: Theme.border
                            opacity: 0.3
                            visible: optimizerBackend.classicContextMenuActive
                        }

                        // Restart Explorer Section
                        Row {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16
                            visible: optimizerBackend.classicContextMenuActive
                            spacing: 12

                            Text {
                                text: qsTr("Restart Windows Explorer to apply context menu changes.")
                                color: Theme.textSecondary
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width - restartBtn.width - 28
                                wrapMode: Text.Wrap
                            }

                            MeguButton {
                                id: restartBtn
                                text: qsTr("Restart Explorer")
                                iconSource: "qrc:/MeguPackOptimizer/src/resources/play.svg"
                                anchors.verticalCenter: parent.verticalCenter
                                height: 28
                                onClicked: {
                                    optimizerBackend.restartExplorer();
                                }
                            }
                        }
                    }
                }

                // Shortcut Arrow Overlays Panel
                AcrylicPanel {
                    id: shortcutArrowsPanel
                    width: parent.width
                    height: !optimizerBackend.shortcutArrowsActive ? 138 : 84

                    Behavior on height {
                        NumberAnimation { duration: Theme.animNormal; easing.type: Easing.InOutQuad }
                    }

                    Column {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        spacing: 12

                        // Main Row
                        Item {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 52

                            Row {
                                anchors.left: parent.left
                                anchors.leftMargin: 16
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 16

                                Rectangle {
                                    width: 40
                                    height: 40
                                    radius: 10
                                    color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                                    anchors.verticalCenter: parent.verticalCenter

                                    Item {
                                        width: 20
                                        height: 20
                                        anchors.centerIn: parent
                                        Image {
                                            id: shortcutArrowsPanel_iconImg
                                            source: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"
                                            anchors.fill: parent
                                            sourceSize.width: 20
                                            sourceSize.height: 20
                                            visible: false
                                        }
                                        ColorOverlay {
                                            anchors.fill: shortcutArrowsPanel_iconImg
                                            source: shortcutArrowsPanel_iconImg
                                            color: Theme.accent
                                        }
                                    }
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 2

                                    Row {
                                        spacing: 8
                                        Text {
                                            text: qsTr("Shortcut Arrow Overlays")
                                            color: Theme.textPrimary
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 14
                                            font.bold: true
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                        ShowPathButton {
                                            anchors.verticalCenter: parent.verticalCenter
                                            onClicked: { optimizerBackend.showPath("shortcutarrows"); }
                                        }
                                        Rectangle {
                                            visible: root.shortcutArrowsChanged
                                            height: 16
                                            width: selectedTextShortcutArrows.contentWidth + 10
                                            radius: 4
                                            color: Qt.rgba(Theme.success.r, Theme.success.g, Theme.success.b, 0.15)
                                            border.color: Theme.success
                                            border.width: 1
                                            anchors.verticalCenter: parent.verticalCenter
                                            Text {
                                                id: selectedTextShortcutArrows
                                                text: qsTr("Selected for application")
                                                color: Theme.success
                                                font.family: Theme.fontFamily
                                                font.pixelSize: 8
                                                font.bold: true
                                                anchors.centerIn: parent
                                            }
                                        }
                                    }

                                    Text {
                                        text: qsTr("Shows or hides the arrow overlay icon on Windows desktop and Explorer shortcuts.")
                                        color: Theme.textMuted
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 11
                                    }
                                }
                            }

                            Row {
                                anchors.right: parent.right
                                anchors.rightMargin: 16
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 16

                                MeguSwitch {
                                    checked: optimizerBackend.shortcutArrowsActive
                                    anchors.verticalCenter: parent.verticalCenter
                                    onToggled: (isChecked) => {
                                        optimizerBackend.shortcutArrowsActive = isChecked;
                                    }
                                }
                            }
                        }

                        // Separator Line
                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16
                            height: 1
                            color: Theme.border
                            opacity: 0.3
                            visible: !optimizerBackend.shortcutArrowsActive
                        }

                        // Restart Explorer Section
                        Row {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16
                            visible: !optimizerBackend.shortcutArrowsActive
                            spacing: 12

                            Text {
                                text: qsTr("Restart Windows Explorer to apply shortcut arrow changes.")
                                color: Theme.textSecondary
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width - restartBtnShortcutArrows.width - 28
                                wrapMode: Text.Wrap
                            }

                            MeguButton {
                                id: restartBtnShortcutArrows
                                text: qsTr("Restart Explorer")
                                iconSource: "qrc:/MeguPackOptimizer/src/resources/play.svg"
                                anchors.verticalCenter: parent.verticalCenter
                                height: 28
                                onClicked: {
                                    optimizerBackend.restartExplorer();
                                }
                            }
                        }
                    }
                }

                // Clipboard History Panel
                AcrylicPanel {
                    id: clipboardHistoryPanel
                    width: parent.width
                    height: 84

                    Column {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        spacing: 12

                        // Main Row
                        Item {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 52

                            Row {
                                anchors.left: parent.left
                                anchors.leftMargin: 16
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 16

                                Rectangle {
                                    width: 40
                                    height: 40
                                    radius: 10
                                    color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                                    anchors.verticalCenter: parent.verticalCenter

                                    Item {
                                        width: 20
                                        height: 20
                                        anchors.centerIn: parent
                                        Image {
                                            id: clipboardHistoryPanel_iconImg
                                            source: "qrc:/MeguPackOptimizer/src/resources/settings.svg"
                                            anchors.fill: parent
                                            sourceSize.width: 20
                                            sourceSize.height: 20
                                            visible: false
                                        }
                                        ColorOverlay {
                                            anchors.fill: clipboardHistoryPanel_iconImg
                                            source: clipboardHistoryPanel_iconImg
                                            color: Theme.accent
                                        }
                                    }
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 2

                                    Row {
                                        spacing: 8
                                        Text {
                                            text: qsTr("Clipboard History")
                                            color: Theme.textPrimary
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 14
                                            font.bold: true
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                        ShowPathButton {
                                            anchors.verticalCenter: parent.verticalCenter
                                            onClicked: { optimizerBackend.showPath("clipboardhistory"); }
                                        }
                                        Rectangle {
                                            visible: root.clipboardHistoryChanged
                                            height: 16
                                            width: selectedTextClipboardHistory.contentWidth + 10
                                            radius: 4
                                            color: Qt.rgba(Theme.success.r, Theme.success.g, Theme.success.b, 0.15)
                                            border.color: Theme.success
                                            border.width: 1
                                            anchors.verticalCenter: parent.verticalCenter
                                            Text {
                                                id: selectedTextClipboardHistory
                                                text: qsTr("Selected for application")
                                                color: Theme.success
                                                font.family: Theme.fontFamily
                                                font.pixelSize: 8
                                                font.bold: true
                                                anchors.centerIn: parent
                                            }
                                        }
                                    }

                                    Text {
                                        text: qsTr("Enables or disables the clipboard history buffer accessed via the Win + V shortcut.")
                                        color: Theme.textMuted
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 11
                                    }
                                }
                            }

                            Row {
                                anchors.right: parent.right
                                anchors.rightMargin: 16
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 16

                                MeguSwitch {
                                    checked: optimizerBackend.clipboardHistoryActive
                                    anchors.verticalCenter: parent.verticalCenter
                                    onToggled: (isChecked) => {
                                        optimizerBackend.clipboardHistoryActive = isChecked;
                                    }
                                }
                            }
                        }
                    }
                }

                // Taskbar End Task Panel
                AcrylicPanel {
                    id: taskbarEndTaskPanel
                    width: parent.width
                    height: (optimizerBackend.taskbarEndTaskActive !== optimizerBackend.originalTaskbarEndTaskActive) ? 132 : 84
                    Behavior on height {
                        NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
                    }

                    Column {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        spacing: 12

                        // Main Row
                        Item {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 52

                            Row {
                                anchors.left: parent.left
                                anchors.leftMargin: 16
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 16

                                Rectangle {
                                    width: 40
                                    height: 40
                                    radius: 10
                                    color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                                    anchors.verticalCenter: parent.verticalCenter

                                    Item {
                                        width: 20
                                        height: 20
                                        anchors.centerIn: parent
                                        Image {
                                            id: taskbarEndTaskPanel_iconImg
                                            source: "qrc:/MeguPackOptimizer/src/resources/settings.svg"
                                            anchors.fill: parent
                                            sourceSize.width: 20
                                            sourceSize.height: 20
                                            visible: false
                                        }
                                        ColorOverlay {
                                            anchors.fill: taskbarEndTaskPanel_iconImg
                                            source: taskbarEndTaskPanel_iconImg
                                            color: Theme.accent
                                        }
                                    }
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 2

                                    Row {
                                        spacing: 8
                                        Text {
                                            text: qsTr("Taskbar 'End task'")
                                            color: Theme.textPrimary
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 14
                                            font.bold: true
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                        ShowPathButton {
                                            anchors.verticalCenter: parent.verticalCenter
                                            onClicked: { optimizerBackend.showPath("taskbarendtask"); }
                                        }
                                        Rectangle {
                                            visible: root.taskbarEndTaskChanged
                                            height: 16
                                            width: selectedTextTaskbarEndTask.contentWidth + 10
                                            radius: 4
                                            color: Qt.rgba(Theme.success.r, Theme.success.g, Theme.success.b, 0.15)
                                            border.color: Theme.success
                                            border.width: 1
                                            anchors.verticalCenter: parent.verticalCenter
                                            Text {
                                                id: selectedTextTaskbarEndTask
                                                text: qsTr("Selected for application")
                                                color: Theme.success
                                                font.family: Theme.fontFamily
                                                font.pixelSize: 8
                                                font.bold: true
                                                anchors.centerIn: parent
                                            }
                                        }
                                    }

                                    Text {
                                        text: qsTr("Enables the 'End task' context menu item on taskbar applications to close them directly.")
                                        color: Theme.textMuted
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 11
                                    }
                                }
                            }

                            Row {
                                anchors.right: parent.right
                                anchors.rightMargin: 16
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 16

                                MeguSwitch {
                                    checked: optimizerBackend.taskbarEndTaskActive
                                    anchors.verticalCenter: parent.verticalCenter
                                    onToggled: (isChecked) => {
                                        optimizerBackend.taskbarEndTaskActive = isChecked;
                                    }
                                }
                            }
                        }

                        // Collapsible Restart Explorer Warning
                        Item {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 48
                            visible: (optimizerBackend.taskbarEndTaskActive !== optimizerBackend.originalTaskbarEndTaskActive)
                            clip: true

                            Rectangle {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16
                                radius: 8
                                color: Qt.rgba(Theme.warning.r, Theme.warning.g, Theme.warning.b, 0.1)
                                border.color: Qt.rgba(Theme.warning.r, Theme.warning.g, Theme.warning.b, 0.2)
                                border.width: 1

                                Text {
                                    id: warningLabelEndTask
                                    anchors.left: parent.left
                                    anchors.leftMargin: 12
                                    text: qsTr("Changes require a Windows Explorer restart to take effect.")
                                    color: Theme.warning
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width - restartBtnEndTask.width - 28
                                    wrapMode: Text.Wrap
                                }

                                MeguButton {
                                    id: restartBtnEndTask
                                    text: qsTr("Restart Explorer")
                                    iconSource: "qrc:/MeguPackOptimizer/src/resources/play.svg"
                                    anchors.right: parent.right
                                    anchors.rightMargin: 12
                                    anchors.verticalCenter: parent.verticalCenter
                                    height: 28
                                    onClicked: {
                                        optimizerBackend.restartExplorer();
                                    }
                                }
                            }
                        }
                    }
                }

                // Taskbar Clock Seconds Panel
                AcrylicPanel {
                    id: taskbarSecondsPanel
                    width: parent.width
                    height: (optimizerBackend.taskbarSecondsActive !== optimizerBackend.originalTaskbarSecondsActive) ? 132 : 84
                    Behavior on height {
                        NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
                    }

                    Column {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        spacing: 12

                        // Main Row
                        Item {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 52

                            Row {
                                anchors.left: parent.left
                                anchors.leftMargin: 16
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 16

                                Rectangle {
                                    width: 40
                                    height: 40
                                    radius: 10
                                    color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                                    anchors.verticalCenter: parent.verticalCenter

                                    Item {
                                        width: 20
                                        height: 20
                                        anchors.centerIn: parent
                                        Image {
                                            id: taskbarSecondsPanel_iconImg
                                            source: "qrc:/MeguPackOptimizer/src/resources/settings.svg"
                                            anchors.fill: parent
                                            sourceSize.width: 20
                                            sourceSize.height: 20
                                            visible: false
                                        }
                                        ColorOverlay {
                                            anchors.fill: taskbarSecondsPanel_iconImg
                                            source: taskbarSecondsPanel_iconImg
                                            color: Theme.accent
                                        }
                                    }
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 2

                                    Row {
                                        spacing: 8
                                        Text {
                                            text: qsTr("Clock with seconds")
                                            color: Theme.textPrimary
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 14
                                            font.bold: true
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                        ShowPathButton {
                                            anchors.verticalCenter: parent.verticalCenter
                                            onClicked: { optimizerBackend.showPath("taskbarseconds"); }
                                        }
                                        Rectangle {
                                            visible: root.taskbarSecondsChanged
                                            height: 16
                                            width: selectedTextTaskbarSeconds.contentWidth + 10
                                            radius: 4
                                            color: Qt.rgba(Theme.success.r, Theme.success.g, Theme.success.b, 0.15)
                                            border.color: Theme.success
                                            border.width: 1
                                            anchors.verticalCenter: parent.verticalCenter
                                            Text {
                                                id: selectedTextTaskbarSeconds
                                                text: qsTr("Selected for application")
                                                color: Theme.success
                                                font.family: Theme.fontFamily
                                                font.pixelSize: 8
                                                font.bold: true
                                                anchors.centerIn: parent
                                            }
                                        }
                                    }

                                    Text {
                                        text: qsTr("Enables or disables showing seconds in the Windows taskbar system clock.")
                                        color: Theme.textMuted
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 11
                                    }
                                }
                            }

                            Row {
                                anchors.right: parent.right
                                anchors.rightMargin: 16
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 16

                                MeguSwitch {
                                    checked: optimizerBackend.taskbarSecondsActive
                                    anchors.verticalCenter: parent.verticalCenter
                                    onToggled: (isChecked) => {
                                        optimizerBackend.taskbarSecondsActive = isChecked;
                                    }
                                }
                            }
                        }

                        // Collapsible Restart Explorer Warning
                        Item {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 48
                            visible: (optimizerBackend.taskbarSecondsActive !== optimizerBackend.originalTaskbarSecondsActive)
                            clip: true

                            Rectangle {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16
                                radius: 8
                                color: Qt.rgba(Theme.warning.r, Theme.warning.g, Theme.warning.b, 0.1)
                                border.color: Qt.rgba(Theme.warning.r, Theme.warning.g, Theme.warning.b, 0.2)
                                border.width: 1

                                Text {
                                    id: warningLabelSeconds
                                    anchors.left: parent.left
                                    anchors.leftMargin: 12
                                    text: qsTr("Changes require a Windows Explorer restart to take effect.")
                                    color: Theme.warning
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width - restartBtnSeconds.width - 28
                                    wrapMode: Text.Wrap
                                }

                                MeguButton {
                                    id: restartBtnSeconds
                                    text: qsTr("Restart Explorer")
                                    iconSource: "qrc:/MeguPackOptimizer/src/resources/play.svg"
                                    anchors.right: parent.right
                                    anchors.rightMargin: 12
                                    anchors.verticalCenter: parent.verticalCenter
                                    height: 28
                                    onClicked: {
                                        optimizerBackend.restartExplorer();
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // 3. HIBERNATION CATEGORY
            Column {
                visible: root.currentSection === "core"
                width: parent.width
                spacing: 8

                Row {
                    spacing: 8
                    height: 16

                    Rectangle {
                        width: 4
                        height: 16
                        radius: 2
                        color: Theme.accent
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: qsTr("Power & Storage")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                AcrylicPanel {
                    id: hibernationPanel
                    width: parent.width
                    height: 84

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 10
                            color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                            anchors.verticalCenter: parent.verticalCenter

                            Item {
                                width: 20
                                height: 20
                                anchors.centerIn: parent
                                Image {
                                    id: hibernationPanel_iconImg
                                    source: "qrc:/MeguPackOptimizer/src/resources/folder.svg"
                                    anchors.fill: parent
                                    sourceSize.width: 20
                                    sourceSize.height: 20
                                    visible: false
                                }
                                ColorOverlay {
                                    anchors.fill: hibernationPanel_iconImg
                                    source: hibernationPanel_iconImg
                                    color: Theme.accent
                                }
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Row {
                                spacing: 8
                                Text {
                                    text: qsTr("System Hibernation")
                                    color: Theme.textPrimary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 14
                                    font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                } 
                                ShowPathButton {
                                    anchors.verticalCenter: parent.verticalCenter
                                    onClicked: { optimizerBackend.showPath("hibernation"); }
                                }
                                Rectangle {
                                    visible: root.hibernationChanged
                                    height: 16
                                    width: selectedTextHibern.contentWidth + 10
                                    radius: 4
                                    color: Qt.rgba(Theme.success.r, Theme.success.g, Theme.success.b, 0.15)
                                    border.color: Theme.success
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        id: selectedTextHibern
                                        text: qsTr("Selected for application")
                                        color: Theme.success
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 8
                                        font.bold: true
                                        anchors.centerIn: parent
                                    }
                                }
                            }

                            Text {
                                text: qsTr("Enables or disables system hibernation to clean storage drive space and optimize SSD lifetime.")
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                            }
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 16

                        MeguSwitch {
                            checked: optimizerBackend.hibernationActive
                            anchors.verticalCenter: parent.verticalCenter
                            onToggled: (isChecked) => {
                                optimizerBackend.hibernationActive = isChecked;
                            }
                        }
                    }
                }

                // Page File Card
                AcrylicPanel {
                    id: pageFilePanel
                    width: parent.width
                    height: 84
                    visible: root.currentSection === "core"

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        // Rounded square badge
                        Rectangle {
                            width: 40
                            height: 40
                            radius: 10
                            color: Qt.rgba(0.9, 0.6, 0.1, 0.15)
                            anchors.verticalCenter: parent.verticalCenter

                            Item {
                                width: 20
                                height: 20
                                anchors.centerIn: parent

                                Image {
                                    id: ramIconImg
                                    source: "qrc:/MeguPackOptimizer/src/resources/ram.svg"
                                    anchors.fill: parent
                                    sourceSize.width: 20
                                    sourceSize.height: 20
                                    visible: false
                                }
                                ColorOverlay {
                                    anchors.fill: ramIconImg
                                    source: ramIconImg
                                    color: "#FFA000"
                                }
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Row {
                                spacing: 8
                                Text {
                                    text: qsTr("Page File")
                                    color: Theme.textPrimary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 14
                                    font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                ShowPathButton {
                                    anchors.verticalCenter: parent.verticalCenter
                                    onClicked: { optimizerBackend.showPath("pagefile"); }
                                }
                                Rectangle {
                                    visible: root.pagefileChanged
                                    height: 16
                                    width: selectedTextPagefile.contentWidth + 10
                                    radius: 4
                                    color: Qt.rgba(Theme.success.r, Theme.success.g, Theme.success.b, 0.15)
                                    border.color: Theme.success
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        id: selectedTextPagefile
                                        text: qsTr("Selected for application")
                                        color: Theme.success
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 8
                                        font.bold: true
                                        anchors.centerIn: parent
                                    }
                                }
                            }

                            Text {
                                text: qsTr("Configure system virtual memory limits (initial/maximum size in MB).")
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                            }
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        // Initial/Min size field
                        Row {
                            spacing: 4
                            anchors.verticalCenter: parent.verticalCenter
                            Text {
                                text: qsTr("Min:")
                                color: Theme.textSecondary
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Rectangle {
                                width: 60
                                height: 24
                                color: Theme.panelBg
                                radius: 4
                                border.color: minInput.activeFocus ? Theme.accent : Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.4)
                                border.width: 1

                                TextInput {
                                    id: minInput
                                    anchors.fill: parent
                                    anchors.leftMargin: 6
                                    anchors.rightMargin: 6
                                    verticalAlignment: TextInput.AlignVCenter
                                    color: Theme.textPrimary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 10
                                    selectByMouse: true
                                    validator: IntValidator { bottom: 1024; top: 99999 }
                                    
                                    Binding on text {
                                        value: optimizerBackend.pagefileMin.toString()
                                    }

                                    onTextChanged: {
                                        var val = parseInt(text);
                                        if (!isNaN(val) && val >= 1024) {
                                            optimizerBackend.pagefileMin = val;
                                        }
                                    }

                                    Keys.onEscapePressed: {
                                        root.forceActiveFocus();
                                    }
                                    Keys.onReturnPressed: {
                                        root.forceActiveFocus();
                                    }
                                }
                            }
                        }

                        // Maximum/Max size field
                        Row {
                            spacing: 4
                            anchors.verticalCenter: parent.verticalCenter
                            Text {
                                text: qsTr("Max:")
                                color: Theme.textSecondary
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Rectangle {
                                width: 60
                                height: 24
                                color: Theme.panelBg
                                radius: 4
                                border.color: maxInput.activeFocus ? Theme.accent : Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.4)
                                border.width: 1

                                TextInput {
                                    id: maxInput
                                    anchors.fill: parent
                                    anchors.leftMargin: 6
                                    anchors.rightMargin: 6
                                    verticalAlignment: TextInput.AlignVCenter
                                    color: Theme.textPrimary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 10
                                    selectByMouse: true
                                    validator: IntValidator { bottom: 1024; top: 99999 }
                                    
                                    Binding on text {
                                        value: optimizerBackend.pagefileMax.toString()
                                    }

                                    onTextChanged: {
                                        var val = parseInt(text);
                                        if (!isNaN(val) && val >= 1024) {
                                            optimizerBackend.pagefileMax = val;
                                        }
                                    }

                                    Keys.onEscapePressed: {
                                        root.forceActiveFocus();
                                    }
                                    Keys.onReturnPressed: {
                                        root.forceActiveFocus();
                                    }
                                }
                            }
                        }

                        // Help/Info question mark icon with hover ToolTip
                        Item {
                            width: 24
                            height: 24
                            anchors.verticalCenter: parent.verticalCenter

                            Image {
                                id: helpIconImg
                                source: "qrc:/MeguPackOptimizer/src/resources/help.svg"
                                anchors.fill: parent
                                sourceSize.width: 14
                                sourceSize.height: 14
                                anchors.centerIn: parent
                                visible: false
                            }
                            ColorOverlay {
                                anchors.fill: helpIconImg
                                source: helpIconImg
                                color: helpMouseArea.containsMouse ? Theme.accentLight : Theme.textSecondary
                            }
                            MouseArea {
                                id: helpMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                ToolTip {
                                    id: helpTooltip
                                    visible: helpMouseArea.containsMouse
                                    delay: 100
                                    timeout: 10000
                                    text: qsTr("Recommended values for RAM sizes:\n• 4 GB RAM: Min = 4096, Max = 8192\n• 8 GB RAM: Min = 4096, Max = 8192\n• 16 GB RAM: Min = 4096, Max = 8192\n• 32 GB+ RAM: Min = 2048, Max = 4096")
                                    
                                    contentItem: Text {
                                        text: helpTooltip.text
                                        color: Theme.textPrimary
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 10
                                        lineHeight: 1.2
                                    }

                                    background: Rectangle {
                                        color: Theme.panelBg
                                        border.color: Theme.accent
                                        border.width: 1
                                        radius: 6
                                    }
                                }
                            }
                        }
                    }
                }

                // BitLocker Card
                AcrylicPanel {
                    id: bitlockerPanel
                    width: parent.width
                    height: 100

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 10
                            color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                            anchors.verticalCenter: parent.verticalCenter

                            Item {
                                width: 20
                                height: 20
                                anchors.centerIn: parent
                                Image {
                                    id: bitlockerPanel_iconImg
                                    source: "qrc:/MeguPackOptimizer/src/resources/info.svg"
                                    anchors.fill: parent
                                    sourceSize.width: 20
                                    sourceSize.height: 20
                                    visible: false
                                }
                                ColorOverlay {
                                    anchors.fill: bitlockerPanel_iconImg
                                    source: bitlockerPanel_iconImg
                                    color: Theme.accent
                                }
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Row {
                                spacing: 8
                                Text {
                                    text: qsTr("BitLocker Drive Encryption")
                                    color: Theme.textPrimary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 14
                                    font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                } 
                                ShowPathButton {
                                    anchors.verticalCenter: parent.verticalCenter
                                    onClicked: { optimizerBackend.showPath("bitlocker"); }
                                }
                                Rectangle {
                                    visible: root.bitlockerChanged
                                    height: 16
                                    width: selectedTextBitl.contentWidth + 10
                                    radius: 4
                                    color: Qt.rgba(Theme.success.r, Theme.success.g, Theme.success.b, 0.15)
                                    border.color: Theme.success
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        id: selectedTextBitl
                                        text: qsTr("Selected for application")
                                        color: Theme.success
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 8
                                        font.bold: true
                                        anchors.centerIn: parent
                                    }
                                }
                            }

                            Text {
                                text: qsTr("Deactivate the BitLocker background monitoring driver/service or decrypt drive C: to recover I/O throughput.")
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                            }
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 16

                        ShowPathButton {
                            id: decryptButton
                            enabled: optimizerBackend.bitlockerDriveEncrypted
                            text: qsTr("Decrypt C:")
                            iconSource: "qrc:/MeguPackOptimizer/src/resources/bolt.svg"
                            anchors.verticalCenter: parent.verticalCenter
                            onClicked: {
                                optimizerBackend.decryptBitLocker();
                            }
                        }

                        MeguSwitch {
                            checked: optimizerBackend.bitlockerActive
                            anchors.verticalCenter: parent.verticalCenter
                            onToggled: (isChecked) => {
                                optimizerBackend.bitlockerActive = isChecked;
                            }
                        }
                    }
                }

                // Windows Defender Card
                AcrylicPanel {
                    id: defenderPanel
                    width: parent.width
                    height: !optimizerBackend.defenderActive ? 96 : 84
                    Behavior on height { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.InOutQuad } }

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 10
                            color: Qt.rgba(0.85, 0.23, 0.0, 0.15)
                            anchors.verticalCenter: parent.verticalCenter

                            Item {
                                width: 20
                                height: 20
                                anchors.centerIn: parent
                                Image {
                                    id: defenderPanel_iconImg
                                    source: "qrc:/MeguPackOptimizer/src/resources/warning.svg"
                                    anchors.fill: parent
                                    sourceSize.width: 20
                                    sourceSize.height: 20
                                    visible: false
                                }
                                ColorOverlay {
                                    anchors.fill: defenderPanel_iconImg
                                    source: defenderPanel_iconImg
                                    color: "#D32F2F"
                                }
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Row {
                                spacing: 8
                                Text {
                                    text: qsTr("Windows Defender")
                                    color: Theme.textPrimary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 14
                                    font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                } 
                                ShowPathButton {
                                    anchors.verticalCenter: parent.verticalCenter
                                    onClicked: { optimizerBackend.showPath("defender"); }
                                }
                                Rectangle {
                                    height: 16
                                    width: devText.contentWidth + 10
                                    radius: 4
                                    color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                                    border.color: Theme.accent
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        id: devText
                                        text: qsTr("разработка")
                                        color: Theme.accent
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 8
                                        font.bold: true
                                        anchors.centerIn: parent
                                    }
                                }
                                Rectangle {
                                    visible: root.defenderChanged
                                    height: 16
                                    width: selectedTextDefender.contentWidth + 10
                                    radius: 4
                                    color: Qt.rgba(Theme.success.r, Theme.success.g, Theme.success.b, 0.15)
                                    border.color: Theme.success
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        id: selectedTextDefender
                                        text: qsTr("Selected for application")
                                        color: Theme.success
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 8
                                        font.bold: true
                                        anchors.centerIn: parent
                                    }
                                }
                            }

                            Text {
                                text: qsTr("Disable Microsoft Defender Antivirus protection, real-time scanning, and services to minimize system latency and resource consumption.")
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                            }
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 16

                        // Arrow button that slides right on hover & opens sidebar drawer for Windows Defender options
                        Rectangle {
                            width: 32
                            height: 32
                            radius: 16
                            color: defenderArrowMouseArea.containsMouse ? Theme.accentDim : "transparent"
                            border.color: defenderArrowMouseArea.containsMouse ? Theme.accent : Theme.border
                            border.width: 1
                            anchors.verticalCenter: parent.verticalCenter

                            Behavior on color { ColorAnimation { duration: Theme.animFast } }
                            Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                            Item {
                                width: 14
                                height: 14
                                anchors.centerIn: parent
                                Image {
                                    id: defenderArrowImg
                                    source: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"
                                    anchors.fill: parent
                                    sourceSize.width: 14
                                    sourceSize.height: 14
                                    visible: false
                                }
                                ColorOverlay {
                                    anchors.fill: defenderArrowImg
                                    source: defenderArrowImg
                                    color: defenderArrowMouseArea.containsMouse ? Theme.accent : Theme.textSecondary
                                    transform: Rotation { origin.x: 7; origin.y: 7; angle: 0 }
                                }
                            }

                            MouseArea {
                                id: defenderArrowMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.activeDrawer = "defender";
                                }
                            }
                        }

                        MeguSwitch {
                            checked: root.defenderChecked
                            indeterminate: root.defenderIndeterminate
                            anchors.verticalCenter: parent.verticalCenter
                            onToggled: (isChecked) => {
                                optimizerBackend.defenderActive = isChecked;
                                optimizerBackend.defenderRegistryActive = isChecked;
                                optimizerBackend.defenderCmdActive = isChecked;
                                optimizerBackend.defenderServiceActive = isChecked;
                            }
                        }
                    }
                }

                // Power Plan Card
                AcrylicPanel {
                    id: powerPlanPanel
                    width: parent.width
                    height: 84

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 10
                            color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                            anchors.verticalCenter: parent.verticalCenter

                            Item {
                                width: 20
                                height: 20
                                anchors.centerIn: parent
                                Image {
                                    id: powerPlanPanel_iconImg
                                    source: "qrc:/MeguPackOptimizer/src/resources/bolt.svg"
                                    anchors.fill: parent
                                    sourceSize.width: 20
                                    sourceSize.height: 20
                                    visible: false
                                }
                                ColorOverlay {
                                    anchors.fill: powerPlanPanel_iconImg
                                    source: powerPlanPanel_iconImg
                                    color: Theme.accent
                                }
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Row {
                                spacing: 8
                                Text {
                                    text: qsTr("Power Plan")
                                    color: Theme.textPrimary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 14
                                    font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                } 
                                ShowPathButton {
                                    anchors.verticalCenter: parent.verticalCenter
                                    onClicked: { optimizerBackend.showPath("powerplan"); }
                                }
                                Rectangle {
                                    visible: root.powerPlanChanged || optimizerBackend.deleteUltimateStaged
                                    height: 16
                                    width: selectedTextPower.contentWidth + 10
                                    radius: 4
                                    color: Qt.rgba(Theme.success.r, Theme.success.g, Theme.success.b, 0.15)
                                    border.color: Theme.success
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        id: selectedTextPower
                                        text: qsTr("Selected for application")
                                        color: Theme.success
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 8
                                        font.bold: true
                                        anchors.centerIn: parent
                                    }
                                }
                            }

                            Text {
                                text: qsTr("Select or deploy custom high-performance energy profiles and unlock the Ultimate Performance plan.")
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                            }
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 16

                        // Current Power Plan status pill
                        Rectangle {
                            height: 24
                            width: {
                                var activeName = "";
                                for (var i = 0; i < optimizerBackend.powerSchemes.length; i++) {
                                    if (optimizerBackend.powerSchemes[i].isActive) {
                                        activeName = optimizerBackend.powerSchemes[i].name;
                                        break;
                                    }
                                }
                                var cleanName = activeName.split(' (')[0];
                                var fontMetricsWidth = cleanName.length * 5.5 + 20;
                                return Math.max(80, Math.min(180, fontMetricsWidth));
                            }
                            radius: 12
                            color: {
                                var activeIsUltimate = false;
                                for (var i = 0; i < optimizerBackend.powerSchemes.length; i++) {
                                    if (optimizerBackend.powerSchemes[i].isActive && optimizerBackend.powerSchemes[i].isUltimate) {
                                        activeIsUltimate = true;
                                        break;
                                    }
                                }
                                return activeIsUltimate ? Theme.accentDim : (Theme.currentTheme === "Белоснежная" || Theme.currentTheme === "Розовая" ? "#0F000000" : "#1A2536");
                            }
                            border.color: {
                                var activeIsUltimate = false;
                                for (var i = 0; i < optimizerBackend.powerSchemes.length; i++) {
                                    if (optimizerBackend.powerSchemes[i].isActive && optimizerBackend.powerSchemes[i].isUltimate) {
                                        activeIsUltimate = true;
                                        break;
                                    }
                                }
                                return activeIsUltimate ? Theme.accent : "#2B3F5C";
                            }
                            border.width: 1
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                text: {
                                    var activeName = "";
                                    for (var i = 0; i < optimizerBackend.powerSchemes.length; i++) {
                                        if (optimizerBackend.powerSchemes[i].isActive) {
                                            activeName = optimizerBackend.powerSchemes[i].name;
                                            break;
                                        }
                                    }
                                    if (activeName === "") return qsTr("Unknown");
                                    var cleanName = activeName.split(' (')[0];
                                    return cleanName;
                                }
                                color: {
                                    var activeIsUltimate = false;
                                    for (var i = 0; i < optimizerBackend.powerSchemes.length; i++) {
                                        if (optimizerBackend.powerSchemes[i].isActive && optimizerBackend.powerSchemes[i].isUltimate) {
                                            activeIsUltimate = true;
                                            break;
                                        }
                                    }
                                    return activeIsUltimate ? Theme.accent : Theme.textSecondary;
                                }
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                                font.bold: true
                                anchors.centerIn: parent
                            }
                        }

                        // Arrow button that slides right on hover & opens sidebar drawer for power plans list
                        Rectangle {
                            width: 32
                            height: 32
                            radius: 16
                            color: powerArrowMouseArea.containsMouse ? Theme.accentDim : "transparent"
                            border.color: powerArrowMouseArea.containsMouse ? Theme.accent : Theme.border
                            border.width: 1
                            anchors.verticalCenter: parent.verticalCenter

                            Behavior on color { ColorAnimation { duration: Theme.animFast } }
                            Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                            Item {
                                width: 14
                                height: 14
                                anchors.centerIn: parent
                                x: powerArrowMouseArea.containsMouse ? (parent.width/2 - 5) : (parent.width/2 - 7)
                                Behavior on x { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }
                                Image {
                                    id: powerArrowImg
                                    source: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"
                                    anchors.fill: parent
                                    sourceSize.width: 14
                                    sourceSize.height: 14
                                    visible: false
                                }
                                ColorOverlay {
                                    anchors.fill: powerArrowImg
                                    source: powerArrowImg
                                    color: powerArrowMouseArea.containsMouse ? Theme.accent : Theme.textSecondary
                                }
                            }

                            MouseArea {
                                id: powerArrowMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.activeDrawer = "power";
                                }
                            }
                        }
                    }
                }

                // USB 3.0 Power Saving Card
                AcrylicPanel {
                    id: usbPanel
                    width: parent.width
                    height: 84

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 10
                            color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                            anchors.verticalCenter: parent.verticalCenter

                            Item {
                                width: 20
                                height: 20
                                anchors.centerIn: parent
                                Image {
                                    id: usbPanel_iconImg
                                    source: "qrc:/MeguPackOptimizer/src/resources/bolt.svg"
                                    anchors.fill: parent
                                    sourceSize.width: 20
                                    sourceSize.height: 20
                                    visible: false
                                }
                                ColorOverlay {
                                    anchors.fill: usbPanel_iconImg
                                    source: usbPanel_iconImg
                                    color: Theme.accent
                                }
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Row {
                                spacing: 8
                                Text {
                                    text: qsTr("USB 3.0 Power Saving")
                                    color: Theme.textPrimary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 14
                                    font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                } 
                                ShowPathButton {
                                    anchors.verticalCenter: parent.verticalCenter
                                    onClicked: { optimizerBackend.showPath("usb"); }
                                }
                                Rectangle {
                                    visible: root.usbPowerSavingChanged
                                    height: 16
                                    width: selectedTextUsb.contentWidth + 10
                                    radius: 4
                                    color: Qt.rgba(Theme.success.r, Theme.success.g, Theme.success.b, 0.15)
                                    border.color: Theme.success
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        id: selectedTextUsb
                                        text: qsTr("Selected for application")
                                        color: Theme.success
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 8
                                        font.bold: true
                                        anchors.centerIn: parent
                                    }
                                }
                            }

                            Text {
                                text: qsTr("Prevent Windows from turning off USB 3.0 ports to save power, avoiding connection dropouts and peripheral latency.")
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                            }
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 16

                        // Arrow button that slides right on hover & opens sidebar drawer for USB device list
                        Rectangle {
                            width: 32
                            height: 32
                            radius: 16
                            color: usbArrowMouseArea.containsMouse ? Theme.accentDim : "transparent"
                            border.color: usbArrowMouseArea.containsMouse ? Theme.accent : Theme.border
                            border.width: 1
                            anchors.verticalCenter: parent.verticalCenter

                            Behavior on color { ColorAnimation { duration: Theme.animFast } }
                            Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                            Item {
                                width: 14
                                height: 14
                                anchors.centerIn: parent
                                x: usbArrowMouseArea.containsMouse ? (parent.width/2 - 5) : (parent.width/2 - 7)
                                Behavior on x { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }
                                Image {
                                    id: usbArrowImg
                                    source: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"
                                    anchors.fill: parent
                                    sourceSize.width: 14
                                    sourceSize.height: 14
                                    visible: false
                                }
                                ColorOverlay {
                                    anchors.fill: usbArrowImg
                                    source: usbArrowImg
                                    color: usbArrowMouseArea.containsMouse ? Theme.accent : Theme.textSecondary
                                }
                            }

                            MouseArea {
                                id: usbArrowMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.activeDrawer = "usb";
                                }
                            }
                        }

                        MeguSwitch {
                            checked: root.usbChecked
                            indeterminate: root.usbIndeterminate
                            anchors.verticalCenter: parent.verticalCenter
                            onToggled: (isChecked) => {
                                optimizerBackend.usbPowerSavingActive = isChecked;
                            }
                        }
                    }
                }
            }
        }
    }

    // Bottom Action Bar
    Item {
        id: bottomActionBar
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 80

        MeguButton {
            id: optimizeButton
            text: qsTr("Optimize")
            iconSource: "qrc:/MeguPackOptimizer/src/resources/play.svg"
            accented: true
            anchors.centerIn: parent
            width: 180
            height: 40
            enabled: !optimizerBackend.isOptimizingSystem && root.hasChanges
            onClicked: {
                if (root.discordOverlayChanged && optimizerBackend.isDiscordRunning()) {
                    discordCloseDialog.open();
                } else {
                    stepLogModel.clear();
                    optimizerBackend.startSystemOptimization();
                }
            }
        }
    }

    // Backdrop for sidebar
    Rectangle {
        id: sidebarBackdrop
        anchors.fill: parent
        color: "#000000"
        opacity: root.sidebarOpen ? 0.5 : 0.0
        visible: opacity > 0.0
        z: 150
        
        Behavior on opacity {
            NumberAnimation { duration: Theme.animNormal }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                root.activeDrawer = "";
            }
        }
    }

    // Sliding Sidebar Drawer for Options
    Rectangle {
        id: optionsSidebar
        width: root.activeDrawer === "steamSettings" ? 600 : 360
        height: parent.height
        anchors.right: parent.right
        anchors.rightMargin: root.sidebarOpen ? 0 : -width
        color: Theme.sidebarBg
        border.color: Theme.border
        border.width: 1
        z: 160

        Behavior on width {
            NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
        }
        Behavior on color { ColorAnimation { duration: Theme.animNormal } }
        Behavior on border.color { ColorAnimation { duration: Theme.animNormal } }
        Behavior on anchors.rightMargin {
            NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
        }

        // Left highlight separator border
        Rectangle {
            width: 1
            height: parent.height
            anchors.left: parent.left
            color: Theme.border
            Behavior on color { ColorAnimation { duration: Theme.animNormal } }
        }

        Item {
            anchors.fill: parent
            anchors.margins: 20
            clip: true

            Column {
                anchors.fill: parent
                spacing: 20

                // Header with Title & Close button
                Item {
                    width: parent.width
                    height: 30

                    Text {
                        text: {
                            if (root.activeDrawer === "indexing") return qsTr("INDEXING OPTIONS");
                            if (root.activeDrawer === "xbox") return qsTr("XBOX APP & GAME BAR");
                            if (root.activeDrawer === "mpo") return qsTr("MPO LATENCY TWEAK");
                            if (root.activeDrawer === "notifications") return qsTr("NOTIFICATION SETTINGS");
                            if (root.activeDrawer === "power") return qsTr("POWER PLANS");
                            if (root.activeDrawer === "defender") return qsTr("WINDOWS DEFENDER");
                            if (root.activeDrawer === "usb") return qsTr("USB 3.0 POWER SAVING");
                            if (root.activeDrawer === "telemetry") return qsTr("TELEMETRY SETTINGS");
                            if (root.activeDrawer === "windowsUpdate") return qsTr("WINDOWS UPDATE");
                            if (root.activeDrawer === "visualEffects") return qsTr("VISUAL EFFECTS");
                            if (root.activeDrawer === "steamSettings") return qsTr("STEAM SETTINGS");
                            return "";
                        }
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        font.bold: true
                        font.letterSpacing: 1.5
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    // Close Button
                    Rectangle {
                        width: 24
                        height: 24
                        radius: 12
                        color: closeMouseArea.containsMouse ? Theme.accentDim : "transparent"
                        border.color: closeMouseArea.containsMouse ? Theme.accent : "transparent"
                        border.width: 1
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter

                        Image {
                            source: "qrc:/MeguPackOptimizer/src/resources/close.svg"
                            width: 10
                            height: 10
                            sourceSize.width: 10
                            sourceSize.height: 10
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            id: closeMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.activeDrawer = "";
                            }
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Theme.border
                }

                // Dynamic options content
                ScrollView {
                    width: parent.width
                    height: parent.height - 60
                    clip: true
                    contentWidth: width

                    ScrollBar.vertical: MeguScrollBar { }
                    ScrollBar.horizontal: MeguScrollBar { }

                    contentHeight: {
                        if (root.activeDrawer === "indexing") return indexingDrawer.implicitHeight;
                        if (root.activeDrawer === "xbox") return xboxDrawer.implicitHeight;
                        if (root.activeDrawer === "mpo") return mpoDrawer.implicitHeight;
                        if (root.activeDrawer === "notifications") return notificationsDrawer.implicitHeight;
                        if (root.activeDrawer === "power") return powerDrawer.implicitHeight;
                        if (root.activeDrawer === "defender") return defenderDrawer.implicitHeight;
                        if (root.activeDrawer === "usb") return usbDrawer.implicitHeight;
                        if (root.activeDrawer === "telemetry") return telemetryDrawer.implicitHeight;
                        if (root.activeDrawer === "windowsUpdate") return windowsUpdateDrawer.implicitHeight;
                        if (root.activeDrawer === "visualEffects") return visualEffectsDrawer.implicitHeight;
                        if (root.activeDrawer === "steamSettings") return steamSettingsDrawer.dynamicHeight;
                        return height;
                    }

                    IndexingDrawer {
                        id: indexingDrawer
                        visible: root.activeDrawer === "indexing"
                        width: visible ? parent.width : 800
                        height: visible ? implicitHeight : 0
                    }

                    // 2. Xbox Options Content
                    XboxDrawer {
                        id: xboxDrawer
                        visible: root.activeDrawer === "xbox"
                        width: visible ? parent.width : 800
                        height: visible ? implicitHeight : 0
                    }

                    // 3. MPO Options Content
                    MpoDrawer {
                        id: mpoDrawer
                        visible: root.activeDrawer === "mpo"
                        width: visible ? parent.width : 800
                        height: visible ? implicitHeight : 0
                    }

                    // 5. Notifications Options Content
                    NotificationsDrawer {
                        id: notificationsDrawer
                        visible: root.activeDrawer === "notifications"
                        width: visible ? parent.width : 800
                        height: visible ? implicitHeight : 0
                    }

                    // 6. Power Plan Options Content
                    PowerDrawer {
                        id: powerDrawer
                        visible: root.activeDrawer === "power"
                        width: visible ? parent.width : 800
                        height: visible ? implicitHeight : 0
                    }

                    // 7. Windows Defender Options Content
                    DefenderDrawer {
                        id: defenderDrawer
                        visible: root.activeDrawer === "defender"
                        width: visible ? parent.width : 800
                        height: visible ? implicitHeight : 0
                    }

                    // 8. USB Power Saving Options Content
                    UsbDrawer {
                        id: usbDrawer
                        visible: root.activeDrawer === "usb"
                        width: visible ? parent.width : 800
                        height: visible ? implicitHeight : 0
                    }

                    // Telemetry Options Content
                    TelemetryDrawer {
                        id: telemetryDrawer
                        visible: root.activeDrawer === "telemetry"
                        width: visible ? parent.width : 800
                        height: visible ? implicitHeight : 0
                    }

                    // 9. Windows Update Options Content
                    WindowsUpdateDrawer {
                        id: windowsUpdateDrawer
                        visible: root.activeDrawer === "windowsUpdate"
                        width: visible ? parent.width : 800
                        height: visible ? implicitHeight : 0
                    }

                    // 10. Visual Effects Options Content
                    VisualEffectsDrawer {
                        id: visualEffectsDrawer
                        visible: root.activeDrawer === "visualEffects"
                        width: visible ? parent.width : 800
                        height: visible ? implicitHeight : 0
                    }

                    // 12. Steam Settings Drawer Content
                    SteamSettingsDrawer {
                        id: steamSettingsDrawer
                        visible: root.activeDrawer === "steamSettings"
                        width: visible ? parent.width : 800
                        height: visible ? dynamicHeight : 0
                    }
                }
            }
        }
    }

    // Dynamic Island Floating Overlay
    Rectangle {
        id: dynamicIsland
        anchors.horizontalCenter: parent.horizontalCenter
        y: (root.pendingChangesCount > 0) ? 20 : -100
        opacity: (root.pendingChangesCount > 0) ? 1.0 : 0.0
        visible: opacity > 0.0
        z: 120

        width: root.islandExpanded ? (root.currentIslandPage === "detail" ? 340 : 320) : 160
        height: root.islandExpanded ? (root.currentIslandPage === "detail" ? (80 + root.pendingSubOptionsList.length * 28) : (80 + root.pendingChangesCount * 28)) : 34
        radius: root.islandExpanded ? 20 : 17

        color: "#F0080B10" // Obsidian background with 94% opacity
        border.color: Theme.accent
        border.width: 1

        // Smooth animations mimicking Apple's Dynamic Island physics
        Behavior on y { NumberAnimation { duration: 350; easing.type: Easing.OutBack } }
        Behavior on opacity { NumberAnimation { duration: 250 } }
        Behavior on width { NumberAnimation { duration: 350; easing.type: Easing.OutBack } }
        Behavior on height { NumberAnimation { duration: 350; easing.type: Easing.OutBack } }
        Behavior on radius { NumberAnimation { duration: 350; easing.type: Easing.OutBack } }

        // Glow backing
        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 4
            radius: 12
            samples: 17
            color: "#66000000"
        }

        // Inner content layout
        Item {
            anchors.fill: parent
            anchors.margins: 10

            // Collapsed content (Pill mode)
            Row {
                id: collapsedRow
                anchors.centerIn: parent
                spacing: 8
                opacity: root.islandExpanded ? 0.0 : 1.0
                visible: opacity > 0.0
                Behavior on opacity { NumberAnimation { duration: 150 } }

                Item {
                    width: 14
                    height: 14
                    anchors.verticalCenter: parent.verticalCenter
                    Image {
                        id: islandBoltIcon
                        source: "qrc:/MeguPackOptimizer/src/resources/bolt.svg"
                        anchors.fill: parent
                        sourceSize.width: 14
                        sourceSize.height: 14
                        visible: false
                    }
                    ColorOverlay {
                        anchors.fill: islandBoltIcon
                        source: islandBoltIcon
                        color: Theme.accent
                    }
                }

                Text {
                    text: root.txtChangesPending.arg(root.mainChangesCount + " (" + root.sidebarChangesCount + ")")
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }

                Item {
                    width: 10
                    height: 10
                    anchors.verticalCenter: parent.verticalCenter
                    Image {
                        id: islandArrowIcon
                        source: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"
                        anchors.fill: parent
                        sourceSize.width: 10
                        sourceSize.height: 10
                        visible: false
                        rotation: 90
                    }
                    ColorOverlay {
                        anchors.fill: islandArrowIcon
                        source: islandArrowIcon
                        color: Theme.textSecondary
                    }
                }
            }

            // Expanded content (Detailed list mode)
            Column {
                id: expandedColumn
                anchors.fill: parent
                spacing: 10
                opacity: root.islandExpanded ? 1.0 : 0.0
                visible: opacity > 0.0
                Behavior on opacity { NumberAnimation { duration: 250 } }

                // PAGE 1: MAIN LIST
                Column {
                    id: page1Layout
                    width: parent.width
                    spacing: 10
                    visible: root.currentIslandPage === "main"
                    opacity: visible ? 1.0 : 0.0
                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    // Header Item
                    Item {
                        width: parent.width
                        height: 20

                        Text {
                            text: root.txtPendingListTitle
                            color: Theme.accent
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.bold: true
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        // Collapse button
                        Rectangle {
                            width: 20
                            height: 20
                            radius: 10
                            color: islandCloseMouse.containsMouse ? Theme.accentDim : "transparent"
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            Behavior on color { ColorAnimation { duration: Theme.animFast } }

                            Image {
                                id: islandCloseImg
                                source: "qrc:/MeguPackOptimizer/src/resources/close.svg"
                                anchors.centerIn: parent
                                width: 8
                                height: 8
                                sourceSize.width: 8
                                sourceSize.height: 8
                                visible: false
                            }
                            ColorOverlay {
                                anchors.fill: islandCloseImg
                                source: islandCloseImg
                                color: islandCloseMouse.containsMouse ? Theme.accent : Theme.textMuted
                            }

                            MouseArea {
                                id: islandCloseMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.islandExpanded = false;
                                }
                            }
                        }
                    }

                    // Divider line
                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Theme.border
                    }

                    // List of pending items
                    Column {
                        width: parent.width
                        spacing: 8

                        Repeater {
                            model: root.pendingChangesList
                            delegate: Row {
                                width: parent.width
                                spacing: 8
                                height: 20

                                // Revert Button (Cross)
                                Rectangle {
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: revertMouse.containsMouse ? Theme.accentDim : "transparent"
                                    border.color: revertMouse.containsMouse ? Theme.accent : "transparent"
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Behavior on color { ColorAnimation { duration: Theme.animFast } }
                                    Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                                    Image {
                                        id: revertCrossImg
                                        source: "qrc:/MeguPackOptimizer/src/resources/close.svg"
                                        anchors.centerIn: parent
                                        width: 6
                                        height: 6
                                        sourceSize.width: 6
                                        sourceSize.height: 6
                                        visible: false
                                    }
                                    ColorOverlay {
                                        anchors.fill: revertCrossImg
                                        source: revertCrossImg
                                        color: revertMouse.containsMouse ? Theme.accent : Theme.textMuted
                                    }

                                    MouseArea {
                                        id: revertMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            modelData.revert();
                                        }
                                    }
                                }

                                // Category Icon
                                Item {
                                    width: 12
                                    height: 12
                                    anchors.verticalCenter: parent.verticalCenter
                                    Image {
                                        id: itemIcon
                                        source: modelData.icon
                                        anchors.fill: parent
                                        sourceSize.width: 12
                                        sourceSize.height: 12
                                        visible: false
                                    }
                                    ColorOverlay {
                                        anchors.fill: itemIcon
                                        source: itemIcon
                                        color: Theme.accent
                                    }
                                }

                                // Name of function/card
                                Text {
                                    text: modelData.name
                                    color: Theme.textPrimary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 10
                                    font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width - 16 - 12 - 16 - (modelData.hasSidebar ? 16 : 0) - 24 // Dynamic sizing based on whether sidebar chevron is shown
                                    elide: Text.ElideRight
                                }

                                // Locate (Eye) button
                                Rectangle {
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: eyeMouse.containsMouse ? Theme.accentDim : "transparent"
                                    border.color: eyeMouse.containsMouse ? Theme.accent : "transparent"
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Behavior on color { ColorAnimation { duration: Theme.animFast } }
                                    Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                                    Image {
                                        id: eyeIconImg
                                        source: "qrc:/MeguPackOptimizer/src/resources/eye.svg"
                                        anchors.centerIn: parent
                                        width: 10
                                        height: 10
                                        sourceSize.width: 10
                                        sourceSize.height: 10
                                        visible: false
                                    }
                                    ColorOverlay {
                                        anchors.fill: eyeIconImg
                                        source: eyeIconImg
                                        color: eyeMouse.containsMouse ? Theme.accent : Theme.textMuted
                                    }

                                    MouseArea {
                                        id: eyeMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            root.locateFunction(modelData.name);
                                        }
                                    }
                                }

                                // Arrow chevron button (for cards with sidebar)
                                Rectangle {
                                    width: 16
                                    height: 16
                                    radius: 8
                                    visible: modelData.hasSidebar
                                    color: arrowMouse.containsMouse ? Theme.accentDim : "transparent"
                                    border.color: arrowMouse.containsMouse ? Theme.accent : "transparent"
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Behavior on color { ColorAnimation { duration: Theme.animFast } }
                                    Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                                    Image {
                                        id: chevronImg
                                        source: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"
                                        anchors.centerIn: parent
                                        width: 8
                                        height: 8
                                        sourceSize.width: 8
                                        sourceSize.height: 8
                                        visible: false
                                        rotation: 90
                                    }
                                    ColorOverlay {
                                        anchors.fill: chevronImg
                                        source: chevronImg
                                        color: arrowMouse.containsMouse ? Theme.accent : Theme.textMuted
                                    }

                                    MouseArea {
                                        id: arrowMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            root.islandDetailCategory = modelData.name;
                                            root.currentIslandPage = "detail";
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // PAGE 2: DETAIL LIST
                Column {
                    id: page2Layout
                    width: parent.width
                    spacing: 10
                    visible: root.currentIslandPage === "detail"
                    opacity: visible ? 1.0 : 0.0
                    Behavior on opacity { NumberAnimation { duration: 150 } }

                    // Header Item
                    Item {
                        width: parent.width
                        height: 20

                        // Back arrow
                        Rectangle {
                            id: backBtn
                            width: 20
                            height: 20
                            radius: 10
                            color: backMouse.containsMouse ? Theme.accentDim : "transparent"
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            Behavior on color { ColorAnimation { duration: Theme.animFast } }

                            Image {
                                id: backArrowImg
                                source: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"
                                anchors.centerIn: parent
                                width: 8
                                height: 8
                                sourceSize.width: 8
                                sourceSize.height: 8
                                visible: false
                                rotation: 270 // Point left (arrow points right normally, so rotate 270)
                            }
                            ColorOverlay {
                                anchors.fill: backArrowImg
                                source: backArrowImg
                                color: backMouse.containsMouse ? Theme.accent : Theme.textMuted
                            }

                            MouseArea {
                                id: backMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.currentIslandPage = "main";
                                }
                            }
                        }

                        Text {
                            text: qsTr("%1 Details").arg(root.islandDetailCategory)
                            color: Theme.accent
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.bold: true
                            anchors.left: backBtn.right
                            anchors.leftMargin: 6
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 50
                            elide: Text.ElideRight
                        }

                        // Close button (returns to collapsed state)
                        Rectangle {
                            width: 20
                            height: 20
                            radius: 10
                            color: detailCloseMouse.containsMouse ? Theme.accentDim : "transparent"
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            Behavior on color { ColorAnimation { duration: Theme.animFast } }

                            Image {
                                id: detailCloseImg
                                source: "qrc:/MeguPackOptimizer/src/resources/close.svg"
                                anchors.centerIn: parent
                                width: 8
                                height: 8
                                sourceSize.width: 8
                                sourceSize.height: 8
                                visible: false
                            }
                            ColorOverlay {
                                anchors.fill: detailCloseImg
                                source: detailCloseImg
                                color: detailCloseMouse.containsMouse ? Theme.accent : Theme.textMuted
                            }

                            MouseArea {
                                id: detailCloseMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.islandExpanded = false;
                                }
                            }
                        }
                    }

                    // Divider line
                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Theme.border
                    }

                    // List of pending sub-options
                    Column {
                        width: parent.width
                        spacing: 8

                        Repeater {
                            model: root.pendingSubOptionsList
                            delegate: Row {
                                width: parent.width
                                spacing: 8
                                height: 20

                                // Revert Button (Cross)
                                Rectangle {
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: subRevertMouse.containsMouse ? Theme.accentDim : "transparent"
                                    border.color: subRevertMouse.containsMouse ? Theme.accent : "transparent"
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Behavior on color { ColorAnimation { duration: Theme.animFast } }
                                    Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                                    Image {
                                        id: subRevertCrossImg
                                        source: "qrc:/MeguPackOptimizer/src/resources/close.svg"
                                        anchors.centerIn: parent
                                        width: 6
                                        height: 6
                                        sourceSize.width: 6
                                        sourceSize.height: 6
                                        visible: false
                                    }
                                    ColorOverlay {
                                        anchors.fill: subRevertCrossImg
                                        source: subRevertCrossImg
                                        color: subRevertMouse.containsMouse ? Theme.accent : Theme.textMuted
                                    }

                                    MouseArea {
                                        id: subRevertMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            modelData.revert();
                                        }
                                    }
                                }

                                // Sub-option text description
                                Text {
                                    text: modelData.name
                                    color: Theme.textPrimary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 9
                                    font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width - 16 - 8 - 16 - 12 // Space for cross, eye, margin
                                    elide: Text.ElideRight
                                }

                                // Locate (Eye) button
                                Rectangle {
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: subEyeMouse.containsMouse ? Theme.accentDim : "transparent"
                                    border.color: subEyeMouse.containsMouse ? Theme.accent : "transparent"
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Behavior on color { ColorAnimation { duration: Theme.animFast } }
                                    Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                                    Image {
                                        id: subEyeIconImg
                                        source: "qrc:/MeguPackOptimizer/src/resources/eye.svg"
                                        anchors.centerIn: parent
                                        width: 10
                                        height: 10
                                        sourceSize.width: 10
                                        sourceSize.height: 10
                                        visible: false
                                    }
                                    ColorOverlay {
                                        anchors.fill: subEyeIconImg
                                        source: subEyeIconImg
                                        color: subEyeMouse.containsMouse ? Theme.accent : Theme.textMuted
                                    }

                                    MouseArea {
                                        id: subEyeMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            root.locateFunction(root.islandDetailCategory);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Tap area to toggle expanded state (only when clicking the main body)
        MouseArea {
            anchors.fill: parent
            z: -1 // Behind close button to let close button click handle separately
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.islandExpanded = !root.islandExpanded;
            }
        }
    }

    // Progress Overlay Modal for System Optimization
    Rectangle {
        id: progressOverlay
        anchors.fill: parent
        color: "#E0000000"
        visible: optimizerBackend.isOptimizingSystem || showFinishedOverlay
        z: 200

        property bool showFinishedOverlay: false

        Connections {
            target: optimizerBackend
            function onIsOptimizingSystemChanged(val) {
                if (val) {
                    progressOverlay.showFinishedOverlay = true;
                }
            }
        }

        MouseArea {
            anchors.fill: parent
        }

        Rectangle {
            id: modalContainer
            width: 440
            height: 320
            anchors.centerIn: parent
            color: "#0F0F11" // Sleek dark charcoal panel background
            radius: 16
            border.color: Theme.accent // Glowing orange/amber border
            border.width: 1.5

            // Glowing border layers (soft inner/outer outline)
            Rectangle {
                anchors.fill: parent
                anchors.margins: -4
                radius: parent.radius + 4
                color: "transparent"
                border.color: Theme.accent
                border.width: 1.5
                opacity: 0.15
            }
            Rectangle {
                anchors.fill: parent
                anchors.margins: -2
                radius: parent.radius + 2
                color: "transparent"
                border.color: Theme.accent
                border.width: 1.0
                opacity: 0.3
            }

            Item {
                anchors.fill: parent
                anchors.margins: 24

                Column {
                    anchors.fill: parent
                    spacing: 24

                    // Header
                    Column {
                        width: parent.width
                        spacing: 6
                        
                        Text {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            text: optimizerBackend.isOptimizingSystem ? qsTr("Optimization in Progress") : qsTr("Optimization Complete")
                            color: "#FFFFFF"
                            font.family: Theme.fontFamily
                            font.pixelSize: 18
                            font.bold: true
                        }

                        Text {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            text: optimizerBackend.isOptimizingSystem ? qsTr("Applying system configuration adjustments...") : qsTr("Finished system modifications.")
                            color: Theme.textMuted
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                        }
                    }

                    // Steps Checklist
                    Column {
                        id: stepsCol
                        width: parent.width
                        spacing: 14
                        anchors.horizontalCenter: parent.horizontalCenter

                        property int activeIndex: {
                            if (!optimizerBackend.isOptimizingSystem) return 3; // All completed
                            var p = optimizerBackend.systemProgress;
                            if (p === 0.0) return 0;
                            if (p > 0.0 && p < 0.90) return 1;
                            return 2;
                        }

                        readonly property var stepsList: [
                            { text: qsTr("Analyzing optimization plan...") },
                            { text: qsTr("Applying system configuration adjustments...") },
                            { text: qsTr("Verifying changes and syncing state...") }
                        ]

                        Repeater {
                            model: stepsCol.stepsList
                            delegate: Row {
                                spacing: 12
                                anchors.horizontalCenter: parent.horizontalCenter

                                property int stepIndex: index
                                property bool isActive: stepIndex === stepsCol.activeIndex
                                property bool isCompleted: stepIndex < stepsCol.activeIndex
                                property bool isPending: stepIndex > stepsCol.activeIndex

                                // Bullet circle
                                Rectangle {
                                    width: 8
                                    height: 8
                                    radius: 4
                                    anchors.verticalCenter: parent.verticalCenter
                                    color: isActive ? Theme.accent : (isCompleted ? Theme.success : "transparent")
                                    border.color: (isActive || isCompleted) ? "transparent" : "#4A5568"
                                    border.width: (isActive || isCompleted) ? 0 : 1.5
                                }

                                Text {
                                    text: modelData.text
                                    color: isActive ? "#FFFFFF" : Theme.textMuted
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 12
                                    font.bold: isActive
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }
                    }

                    // Spacer/Bottom area container
                    Item {
                        width: parent.width
                        height: 60
                        
                        Column {
                            anchors.fill: parent
                            spacing: 12
                            
                            // Bottom active action status
                            Text {
                                width: parent.width
                                horizontalAlignment: Text.AlignHCenter
                                text: {
                                    if (optimizerBackend.isOptimizingSystem) {
                                        return stepLogModel.count > 0 ? stepLogModel.get(stepLogModel.count - 1).message : qsTr("Analyzing optimization plan...");
                                    } else {
                                        return qsTr("Optimization completed successfully!");
                                    }
                                }
                                color: Theme.accent
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                font.bold: true
                                font.italic: true
                                elide: Text.ElideRight
                            }

                            // Close button
                            MeguButton {
                                text: qsTr("Close")
                                accented: true
                                anchors.horizontalCenter: parent.horizontalCenter
                                visible: !optimizerBackend.isOptimizingSystem
                                height: 28
                                width: 90
                                onClicked: {
                                    progressOverlay.showFinishedOverlay = false;
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // DISCORD CLOSE PROCESS PROMPT OVERLAY
    Rectangle {
        id: discordCloseDialog
        anchors.fill: parent
        color: "#CC05070B"
        z: 9999
        visible: false
        opacity: 0.0
        
        Behavior on opacity { NumberAnimation { duration: Theme.animNormal } }
        
        function open() {
            visible = true;
            opacity = 1.0;
        }
        
        function close() {
            opacity = 0.0;
            closeTimer.start();
        }
        
        Timer {
            id: closeTimer
            interval: Theme.animNormal
            onTriggered: discordCloseDialog.visible = false;
        }

        MouseArea {
            anchors.fill: parent
            onClicked: discordCloseDialog.close();
        }

        AcrylicPanel {
            anchors.centerIn: parent
            width: 320
            height: 180
            radius: 12
            
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.AllButtons
            }

            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 16

                Row {
                    spacing: 10
                    width: parent.width
                    Item {
                        width: 24
                        height: 24
                        Image {
                            id: warnImg
                            source: "qrc:/MeguPackOptimizer/src/resources/warning.svg"
                            anchors.fill: parent
                            sourceSize.width: 24
                            sourceSize.height: 24
                            visible: false
                        }
                        ColorOverlay {
                            anchors.fill: warnImg
                            source: warnImg
                            color: Theme.accent
                        }
                    }
                    Text {
                        text: qsTr("Discord Process Detected")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 14
                        font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Text {
                    text: qsTr("Discord is currently running. It must be closed to safely lock/unlock overlay files.\n\nWould you like to close Discord now and proceed?")
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    width: parent.width
                    wrapMode: Text.WordWrap
                }

                Row {
                    width: parent.width
                    spacing: 10
                    layoutDirection: Qt.RightToLeft

                    MeguButton {
                        text: qsTr("Close & Optimize")
                        accented: true
                        width: 120
                        height: 30
                        onClicked: {
                            discordCloseDialog.close();
                            stepLogModel.clear();
                            optimizerBackend.killDiscord();
                            optimizerBackend.startSystemOptimization();
                        }
                    }

                    MeguButton {
                        text: qsTr("Skip Overlay")
                        accented: false
                        width: 100
                        height: 30
                        onClicked: {
                            discordCloseDialog.close();
                            optimizerBackend.discordOverlayActive = optimizerBackend.originalDiscordOverlayActive;
                            stepLogModel.clear();
                            optimizerBackend.startSystemOptimization();
                        }
                    }

                    MeguButton {
                        text: qsTr("Cancel")
                        accented: false
                        flat: true
                        width: 60
                        height: 30
                        onClicked: {
                            discordCloseDialog.close();
                        }
                    }
                }
            }
        }
    }
}
