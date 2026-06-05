import QtQuick



import QtQuick.Controls



import QtQuick.Layouts



import MeguPackOptimizer 1.0



import Qt5Compat.GraphicalEffects



import "../components"
import QtQuick.Shapes







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







    onCurrentSectionChanged: {



        var flick = mainScroll.contentItem;



        if (flick) {



            flick.contentY = 0;



        }



    }







    onVisibleChanged: {



        if (visible) {



            var flick = mainScroll.contentItem;



            if (flick) {



                flick.contentY = 0;



            }



        }



    }







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
        if (root.hibernationChanged) return true;
        if (root.fastStartupChanged) return true;
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
        if (telemetryChanged) return true;
        if (adsChanged) return true;
        if (privacyChanged) return true;
        if (windowsUpdateChanged) return true;
        if (storageSenseChanged) return true;
        if (driveOptimizationChanged) return true;
        if (cs2Changed) return true;
        if (optimizerBackend.steamOverlayActive !== optimizerBackend.originalSteamOverlayActive) return true;
        if (optimizerBackend.cs2OverlayActive !== optimizerBackend.originalCs2OverlayActive) return true;
        if (steamFriendsSettingsChanged) return true;
        if (visualEffectsChanged) return true;
        if (optimizerBackend.pagefileMin !== optimizerBackend.originalPagefileMin) return true;
        if (optimizerBackend.pagefileMax !== optimizerBackend.originalPagefileMax) return true;
        if (moreRightsChanged) return true;
        if (explorerChanged) return true;
        if (startMenuChanged) return true;
        if (desktopChanged) return true;
        if (optimizerBackend.coinstallersActive !== optimizerBackend.originalCoinstallersActive) return true;

        if (optimizerBackend.driveStates && optimizerBackend.originalDriveStates) {
            var keys = Object.keys(optimizerBackend.driveStates);
            for (var d = 0; d < keys.length; d++) {
                var key = keys[d];
                if (optimizerBackend.driveStates[key] !== optimizerBackend.originalDriveStates[key]) {
                    return true;
                }
            }
        }
        return false;
    }







    property bool pagefileChanged: optimizerBackend.pagefileMin !== optimizerBackend.originalPagefileMin || optimizerBackend.pagefileMax !== optimizerBackend.originalPagefileMax



    property real estimatedFreeGBAfterPagefile: {



        var currentMax = optimizerBackend.pagefileMax;



        var info = optimizerBackend.getDriveInfo("C:");



        var freeGB = info && info.freeSize !== undefined ? info.freeSize : 50.0;



        var pagefileGB = info && info.pagefileSize !== undefined ? info.pagefileSize : 0.0;



        var totalSpaceWithoutPagefile = freeGB + pagefileGB;



        return totalSpaceWithoutPagefile - (currentMax / 1024.0);



    }



    property bool isPagefileInputValid: {



        if (!pagefileChanged) return true;



        var minVal = optimizerBackend.pagefileMin;



        var maxVal = optimizerBackend.pagefileMax;



        if (minVal < 1024 || maxVal < 1024 || minVal > 99999 || maxVal > 99999) return false;



        return minVal <= maxVal && estimatedFreeGBAfterPagefile >= 0;



    }



    property bool isPagefileSpaceLow: {



        if (!pagefileChanged) return false;



        var currentMax = optimizerBackend.pagefileMax;



        var info = optimizerBackend.getDriveInfo("C:");



        var freeGB = info && info.freeSize !== undefined ? info.freeSize : 50.0;



        var conservativeSpaceLeft = freeGB - (currentMax / 1024.0);



        return isPagefileInputValid && conservativeSpaceLeft < 10.0;



    }



    property bool classicContextMenuChanged: optimizerBackend.classicContextMenuActive !== optimizerBackend.originalClassicContextMenuActive



    property bool shortcutArrowsChanged: optimizerBackend.shortcutArrowsActive !== optimizerBackend.originalShortcutArrowsActive



    property bool clipboardHistoryChanged: optimizerBackend.clipboardHistoryActive !== optimizerBackend.originalClipboardHistoryActive



    property bool taskbarEndTaskChanged: optimizerBackend.taskbarEndTaskActive !== optimizerBackend.originalTaskbarEndTaskActive



    property bool taskbarSecondsChanged: optimizerBackend.taskbarSecondsActive !== optimizerBackend.originalTaskbarSecondsActive



    property bool moreRightsChanged: {



        if (optimizerBackend.superuserGodModeActive !== optimizerBackend.originalSuperuserGodModeActive) return true;



        if (optimizerBackend.superuserDeveloperModeActive !== optimizerBackend.originalSuperuserDeveloperModeActive) return true;



        if (optimizerBackend.superuserUacLevel !== optimizerBackend.originalSuperuserUacLevel) return true;



        if (optimizerBackend.superuserUcpdActive !== optimizerBackend.originalSuperuserUcpdActive) return true;



        return false;



    }







    property bool explorerChanged: {



        if (optimizerBackend.explorerShowExtensions !== optimizerBackend.originalExplorerShowExtensions) return true;



        if (optimizerBackend.explorerShowHidden !== optimizerBackend.originalExplorerShowHidden) return true;



        if (optimizerBackend.explorerShowExtractFiles !== optimizerBackend.originalExplorerShowExtractFiles) return true;



        if (optimizerBackend.explorerClassicRibbon !== optimizerBackend.originalExplorerClassicRibbon) return true;



        if (optimizerBackend.explorerShowPreviewPane !== optimizerBackend.originalExplorerShowPreviewPane) return true;



        if (optimizerBackend.explorerPinRecycleBin !== optimizerBackend.originalExplorerPinRecycleBin) return true;



        if (optimizerBackend.explorerPinHome !== optimizerBackend.originalExplorerPinHome) return true;



        if (optimizerBackend.explorerPinGallery !== optimizerBackend.originalExplorerPinGallery) return true;



        if (optimizerBackend.explorerUseCheckboxes !== optimizerBackend.originalExplorerUseCheckboxes) return true;



        if (optimizerBackend.explorerSyncNotifications !== optimizerBackend.originalExplorerSyncNotifications) return true;



        if (optimizerBackend.explorerLaunchTo !== optimizerBackend.originalExplorerLaunchTo) return true;



        return false;



    }







    property bool desktopChanged: {



        if (optimizerBackend.desktopShowThisPC !== optimizerBackend.originalDesktopShowThisPC) return true;



        if (optimizerBackend.explorerShowRecycleBin !== optimizerBackend.originalExplorerShowRecycleBin) return true;



        if (optimizerBackend.desktopShowWidgets !== optimizerBackend.originalDesktopShowWidgets) return true;



        if (optimizerBackend.shortcutArrowsActive !== optimizerBackend.originalShortcutArrowsActive) return true;



        if (optimizerBackend.desktopIconShadows !== optimizerBackend.originalDesktopIconShadows) return true;



        if (optimizerBackend.desktopShowDesktopButton !== optimizerBackend.originalDesktopShowDesktopButton) return true;



        if (optimizerBackend.desktopAeroShake !== optimizerBackend.originalDesktopAeroShake) return true;



        if (optimizerBackend.classicContextMenuActive !== optimizerBackend.originalClassicContextMenuActive) return true;



        if (optimizerBackend.desktopWallpaperQuality !== optimizerBackend.originalDesktopWallpaperQuality) return true;



        return false;



    }







    property bool startMenuChanged: {



        if (optimizerBackend.startMenuWebResults !== optimizerBackend.originalStartMenuWebResults) return true;



        if (optimizerBackend.startMenuAutoinstall !== optimizerBackend.originalStartMenuAutoinstall) return true;



        if (optimizerBackend.startMenuAccountNotifications !== optimizerBackend.originalStartMenuAccountNotifications) return true;



        if (optimizerBackend.startMenuShowHibernate !== optimizerBackend.originalStartMenuShowHibernate) return true;



        return false;



    }







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



    property bool hibernationChanged: (optimizerBackend.hibernationActive !== optimizerBackend.originalHibernationActive) || (optimizerBackend.hibernationActive && (optimizerBackend.hibernationSize !== optimizerBackend.originalHibernationSize))
    property bool fastStartupChanged: optimizerBackend.fastStartupActive !== optimizerBackend.originalFastStartupActive



    property bool coinstallersChanged: optimizerBackend.coinstallersActive !== optimizerBackend.originalCoinstallersActive



    property bool storageSenseChanged: optimizerBackend.storageSenseActive !== optimizerBackend.originalStorageSenseActive
    property bool driveOptimizationChanged: optimizerBackend.driveOptimizationActive !== optimizerBackend.originalDriveOptimizationActive



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



    property bool privacyChanged: {



        if (optimizerBackend.privacyLocationActive !== optimizerBackend.originalPrivacyLocationActive) return true;



        if (optimizerBackend.privacyTelemetryActive !== optimizerBackend.originalPrivacyTelemetryActive) return true;



        if (optimizerBackend.privacyCeipActive !== optimizerBackend.originalPrivacyCeipActive) return true;



        if (optimizerBackend.privacyAppsTelemetryActive !== optimizerBackend.originalPrivacyAppsTelemetryActive) return true;



        if (optimizerBackend.privacyAppLaunchesActive !== optimizerBackend.originalPrivacyAppLaunchesActive) return true;



        if (optimizerBackend.privacyImproveInkingActive !== optimizerBackend.originalPrivacyImproveInkingActive) return true;



        if (optimizerBackend.privacyPersonalizeInkingActive !== optimizerBackend.originalPrivacyPersonalizeInkingActive) return true;



        if (optimizerBackend.privacyErrorReportingActive !== optimizerBackend.originalPrivacyErrorReportingActive) return true;



        if (optimizerBackend.privacyLockScreenCameraActive !== optimizerBackend.originalPrivacyLockScreenCameraActive) return true;



        if (optimizerBackend.privacyCameraIndicatorActive !== optimizerBackend.originalPrivacyCameraIndicatorActive) return true;



        if (optimizerBackend.privacyOnlineSpeechActive !== optimizerBackend.originalPrivacyOnlineSpeechActive) return true;



        return false;



    }



    property bool windowsUpdateChanged: {



        if (optimizerBackend.windowsUpdateMode !== optimizerBackend.originalWindowsUpdateMode) return true;



        if (optimizerBackend.driverUpdatesEnabled !== optimizerBackend.originalDriverUpdatesEnabled) return true;



        if (optimizerBackend.appUpdatesEnabled !== optimizerBackend.originalAppUpdatesEnabled) return true;



        return false;



    }



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



        if (desktopChanged) count++;



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



        if (coinstallersChanged) count++;



        if (storageSenseChanged) count++;
        if (driveOptimizationChanged) count++;



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



        if (privacyChanged) count++;



        if (explorerChanged) count++;



        if (startMenuChanged) count++;



        return count;



    }







    property int mainChangesCount: {



        var count = 0;



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



        if (optimizerBackend.privacyLocationActive !== optimizerBackend.originalPrivacyLocationActive) count++;



        if (optimizerBackend.privacyTelemetryActive !== optimizerBackend.originalPrivacyTelemetryActive) count++;



        if (optimizerBackend.privacyCeipActive !== optimizerBackend.originalPrivacyCeipActive) count++;



        if (optimizerBackend.privacyAppsTelemetryActive !== optimizerBackend.originalPrivacyAppsTelemetryActive) count++;



        if (optimizerBackend.privacyAppLaunchesActive !== optimizerBackend.originalPrivacyAppLaunchesActive) count++;



        if (optimizerBackend.privacyImproveInkingActive !== optimizerBackend.originalPrivacyImproveInkingActive) count++;



        if (optimizerBackend.privacyPersonalizeInkingActive !== optimizerBackend.originalPrivacyPersonalizeInkingActive) count++;



        if (optimizerBackend.privacyErrorReportingActive !== optimizerBackend.originalPrivacyErrorReportingActive) count++;



        if (optimizerBackend.privacyLockScreenCameraActive !== optimizerBackend.originalPrivacyLockScreenCameraActive) count++;



        if (optimizerBackend.privacyCameraIndicatorActive !== optimizerBackend.originalPrivacyCameraIndicatorActive) count++;



        if (optimizerBackend.privacyOnlineSpeechActive !== optimizerBackend.originalPrivacyOnlineSpeechActive) count++;



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



        if (optimizerBackend.driverUpdatesEnabled !== optimizerBackend.originalDriverUpdatesEnabled) count++;



        if (optimizerBackend.appUpdatesEnabled !== optimizerBackend.originalAppUpdatesEnabled) count++;



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



        if (optimizerBackend.superuserGodModeActive !== optimizerBackend.originalSuperuserGodModeActive) count++;



        if (optimizerBackend.superuserDeveloperModeActive !== optimizerBackend.originalSuperuserDeveloperModeActive) count++;



        if (optimizerBackend.superuserUacLevel !== optimizerBackend.originalSuperuserUacLevel) count++;



        if (optimizerBackend.superuserUcpdActive !== optimizerBackend.originalSuperuserUcpdActive) count++;



        if (optimizerBackend.explorerShowExtensions !== optimizerBackend.originalExplorerShowExtensions) count++;



        if (optimizerBackend.explorerShowHidden !== optimizerBackend.originalExplorerShowHidden) count++;



        if (optimizerBackend.explorerShowExtractFiles !== optimizerBackend.originalExplorerShowExtractFiles) count++;



        if (optimizerBackend.explorerClassicRibbon !== optimizerBackend.originalExplorerClassicRibbon) count++;



        if (optimizerBackend.explorerShowPreviewPane !== optimizerBackend.originalExplorerShowPreviewPane) count++;



        if (optimizerBackend.explorerShowRecycleBin !== optimizerBackend.originalExplorerShowRecycleBin) count++;



        if (optimizerBackend.explorerPinRecycleBin !== optimizerBackend.originalExplorerPinRecycleBin) count++;



        if (optimizerBackend.explorerPinHome !== optimizerBackend.originalExplorerPinHome) count++;



        if (optimizerBackend.explorerPinGallery !== optimizerBackend.originalExplorerPinGallery) count++;



        if (optimizerBackend.explorerUseCheckboxes !== optimizerBackend.originalExplorerUseCheckboxes) count++;



        if (optimizerBackend.explorerSyncNotifications !== optimizerBackend.originalExplorerSyncNotifications) count++;



        if (optimizerBackend.explorerLaunchTo !== optimizerBackend.originalExplorerLaunchTo) count++;



        if (optimizerBackend.startMenuWebResults !== optimizerBackend.originalStartMenuWebResults) count++;



        if (optimizerBackend.startMenuAutoinstall !== optimizerBackend.originalStartMenuAutoinstall) count++;



        if (optimizerBackend.startMenuAccountNotifications !== optimizerBackend.originalStartMenuAccountNotifications) count++;



        if (optimizerBackend.startMenuShowHibernate !== optimizerBackend.originalStartMenuShowHibernate) count++;



        if (optimizerBackend.desktopShowThisPC !== optimizerBackend.originalDesktopShowThisPC) count++;



        if (optimizerBackend.desktopShowWidgets !== optimizerBackend.originalDesktopShowWidgets) count++;



        if (optimizerBackend.desktopIconShadows !== optimizerBackend.originalDesktopIconShadows) count++;



        if (optimizerBackend.desktopShowDesktopButton !== optimizerBackend.originalDesktopShowDesktopButton) count++;



        if (optimizerBackend.desktopAeroShake !== optimizerBackend.originalDesktopAeroShake) count++;



        if (optimizerBackend.desktopWallpaperQuality !== optimizerBackend.originalDesktopWallpaperQuality) count++;



        if (optimizerBackend.classicContextMenuActive !== optimizerBackend.originalClassicContextMenuActive) count++;



        if (optimizerBackend.shortcutArrowsActive !== optimizerBackend.originalShortcutArrowsActive) count++;



        if (optimizerBackend.storageSenseActive !== optimizerBackend.originalStorageSenseActive) count++;



        return count;



    }







    property var pendingChangesList: {



        var lang = settingsBackend.language;



        var list = [];



        if (desktopChanged) list.push({



            name: qsTr("Desktop Customization"),



            icon: "qrc:/MeguPackOptimizer/src/resources/monitor.svg",



            hasSidebar: true,



            revert: function() {



                optimizerBackend.desktopShowThisPC = optimizerBackend.originalDesktopShowThisPC;



                optimizerBackend.explorerShowRecycleBin = optimizerBackend.originalExplorerShowRecycleBin;



                optimizerBackend.desktopShowWidgets = optimizerBackend.originalDesktopShowWidgets;



                optimizerBackend.shortcutArrowsActive = optimizerBackend.originalShortcutArrowsActive;



                optimizerBackend.desktopIconShadows = optimizerBackend.originalDesktopIconShadows;



                optimizerBackend.desktopShowDesktopButton = optimizerBackend.originalDesktopShowDesktopButton;



                optimizerBackend.desktopAeroShake = optimizerBackend.originalDesktopAeroShake;



                optimizerBackend.classicContextMenuActive = optimizerBackend.originalClassicContextMenuActive;



                optimizerBackend.desktopWallpaperQuality = optimizerBackend.originalDesktopWallpaperQuality;



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



        if (fastStartupChanged) list.push({
            name: qsTr("Fast Startup"),
            icon: "qrc:/MeguPackOptimizer/src/resources/power.svg",
            hasSidebar: false,
            revert: function() {
                optimizerBackend.fastStartupActive = optimizerBackend.originalFastStartupActive;
            }
        });

        if (hibernationChanged) list.push({



            name: qsTr("System Hibernation"),



            icon: "qrc:/MeguPackOptimizer/src/resources/folder.svg",



            hasSidebar: false,



            revert: function() {



                optimizerBackend.hibernationActive = optimizerBackend.originalHibernationActive;
                optimizerBackend.hibernationSize = optimizerBackend.originalHibernationSize;



            }



        });



        if (coinstallersChanged) list.push({



            name: qsTr("Co-installers"),



            icon: "qrc:/MeguPackOptimizer/src/resources/settings.svg",



            hasSidebar: false,



            revert: function() {



                optimizerBackend.coinstallersActive = optimizerBackend.originalCoinstallersActive;



            }



        });



        if (storageSenseChanged) list.push({



            name: qsTr("Storage sense"),



            icon: "qrc:/MeguPackOptimizer/src/resources/storage.svg",



            hasSidebar: false,



            revert: function() {



                optimizerBackend.storageSenseActive = optimizerBackend.originalStorageSenseActive;



            }



        });

        if (driveOptimizationChanged) list.push({



            name: qsTr("Drive optimization"),



            icon: "qrc:/MeguPackOptimizer/src/resources/storage.svg",



            hasSidebar: false,



            revert: function() {



                optimizerBackend.driveOptimizationActive = optimizerBackend.originalDriveOptimizationActive;



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



        if (moreRightsChanged) list.push({



            name: qsTr("More Privileges"),



            icon: "qrc:/MeguPackOptimizer/src/resources/settings.svg",



            hasSidebar: true,



            revert: function() {



                optimizerBackend.superuserGodModeActive = optimizerBackend.originalSuperuserGodModeActive;



                optimizerBackend.superuserDeveloperModeActive = optimizerBackend.originalSuperuserDeveloperModeActive;



                optimizerBackend.superuserUacLevel = optimizerBackend.originalSuperuserUacLevel;



                optimizerBackend.superuserUcpdActive = optimizerBackend.originalSuperuserUcpdActive;



            }



        });



        if (explorerChanged) list.push({



            name: qsTr("File Explorer Customization"),



            icon: "qrc:/MeguPackOptimizer/src/resources/folder.svg",



            hasSidebar: true,



            revert: function() {



                optimizerBackend.explorerShowExtensions = optimizerBackend.originalExplorerShowExtensions;



                optimizerBackend.explorerShowHidden = optimizerBackend.originalExplorerShowHidden;



                optimizerBackend.explorerShowExtractFiles = optimizerBackend.originalExplorerShowExtractFiles;



                optimizerBackend.explorerClassicRibbon = optimizerBackend.originalExplorerClassicRibbon;



                optimizerBackend.explorerShowPreviewPane = optimizerBackend.originalExplorerShowPreviewPane;



                optimizerBackend.explorerPinRecycleBin = optimizerBackend.originalExplorerPinRecycleBin;



                optimizerBackend.explorerPinHome = optimizerBackend.originalExplorerPinHome;



                optimizerBackend.explorerPinGallery = optimizerBackend.originalExplorerPinGallery;



                optimizerBackend.explorerUseCheckboxes = optimizerBackend.originalExplorerUseCheckboxes;



                optimizerBackend.explorerSyncNotifications = optimizerBackend.originalExplorerSyncNotifications;



                optimizerBackend.explorerLaunchTo = optimizerBackend.originalExplorerLaunchTo;



            }



        });



        if (startMenuChanged) list.push({



            name: qsTr("Start Menu Customization"),



            icon: "qrc:/MeguPackOptimizer/src/resources/settings.svg",



            hasSidebar: true,



            revert: function() {



                optimizerBackend.startMenuWebResults = optimizerBackend.originalStartMenuWebResults;



                optimizerBackend.startMenuAutoinstall = optimizerBackend.originalStartMenuAutoinstall;



                optimizerBackend.startMenuAccountNotifications = optimizerBackend.originalStartMenuAccountNotifications;



                optimizerBackend.startMenuShowHibernate = optimizerBackend.originalStartMenuShowHibernate;



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



        if (privacyChanged) list.push({



            name: qsTr("Privacy"),



            icon: "qrc:/MeguPackOptimizer/src/resources/privacy.svg",



            hasSidebar: false,



            revert: function() {



                optimizerBackend.privacyLocationActive = optimizerBackend.originalPrivacyLocationActive;



                optimizerBackend.privacyTelemetryActive = optimizerBackend.originalPrivacyTelemetryActive;



                optimizerBackend.privacyCeipActive = optimizerBackend.originalPrivacyCeipActive;



                optimizerBackend.privacyAppsTelemetryActive = optimizerBackend.originalPrivacyAppsTelemetryActive;



                optimizerBackend.privacyAppLaunchesActive = optimizerBackend.originalPrivacyAppLaunchesActive;



                optimizerBackend.privacyImproveInkingActive = optimizerBackend.originalPrivacyImproveInkingActive;



                optimizerBackend.privacyPersonalizeInkingActive = optimizerBackend.originalPrivacyPersonalizeInkingActive;



                optimizerBackend.privacyErrorReportingActive = optimizerBackend.originalPrivacyErrorReportingActive;



                optimizerBackend.privacyLockScreenCameraActive = optimizerBackend.originalPrivacyLockScreenCameraActive;



                optimizerBackend.privacyCameraIndicatorActive = optimizerBackend.originalPrivacyCameraIndicatorActive;



                optimizerBackend.privacyOnlineSpeechActive = optimizerBackend.originalPrivacyOnlineSpeechActive;



            }



        });



        if (windowsUpdateChanged) list.push({



            name: qsTr("Windows Update"),



            icon: "qrc:/MeguPackOptimizer/src/resources/settings.svg",



            hasSidebar: true,



            revert: function() {



                optimizerBackend.windowsUpdateMode = optimizerBackend.originalWindowsUpdateMode;



                optimizerBackend.driverUpdatesEnabled = optimizerBackend.originalDriverUpdatesEnabled;



                optimizerBackend.appUpdatesEnabled = optimizerBackend.originalAppUpdatesEnabled;



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



            if (optimizerBackend.driverUpdatesEnabled !== optimizerBackend.originalDriverUpdatesEnabled) {



                subList.push({



                    name: qsTr("Driver Updates") + ": " + (optimizerBackend.originalDriverUpdatesEnabled ? qsTr("Enabled") : qsTr("Disabled")) + " -> " + (optimizerBackend.driverUpdatesEnabled ? qsTr("Enabled") : qsTr("Disabled")),



                    revert: function() {



                        optimizerBackend.driverUpdatesEnabled = optimizerBackend.originalDriverUpdatesEnabled;



                    }



                });



            }



            if (optimizerBackend.appUpdatesEnabled !== optimizerBackend.originalAppUpdatesEnabled) {



                subList.push({



                    name: qsTr("App Updates") + ": " + (optimizerBackend.originalAppUpdatesEnabled ? qsTr("Enabled") : qsTr("Disabled")) + " -> " + (optimizerBackend.appUpdatesEnabled ? qsTr("Enabled") : qsTr("Disabled")),



                    revert: function() {



                        optimizerBackend.appUpdatesEnabled = optimizerBackend.originalAppUpdatesEnabled;



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



        } else if (category === qsTr("More Privileges") || category === "More Privileges") {



            if (optimizerBackend.superuserGodModeActive !== optimizerBackend.originalSuperuserGodModeActive) {



                subList.push({



                    name: qsTr("God Mode") + ": " + (optimizerBackend.originalSuperuserGodModeActive ? qsTr("Enabled") : qsTr("Disabled")) + " -> " + (optimizerBackend.superuserGodModeActive ? qsTr("Enabled") : qsTr("Disabled")),



                    revert: function() {



                        optimizerBackend.superuserGodModeActive = optimizerBackend.originalSuperuserGodModeActive;



                    }



                });



            }



            if (optimizerBackend.superuserDeveloperModeActive !== optimizerBackend.originalSuperuserDeveloperModeActive) {



                subList.push({



                    name: qsTr("Developer Mode") + ": " + (optimizerBackend.originalSuperuserDeveloperModeActive ? qsTr("Enabled") : qsTr("Disabled")) + " -> " + (optimizerBackend.superuserDeveloperModeActive ? qsTr("Enabled") : qsTr("Disabled")),



                    revert: function() {



                        optimizerBackend.superuserDeveloperModeActive = optimizerBackend.originalSuperuserDeveloperModeActive;



                    }



                });



            }



            if (optimizerBackend.superuserUacLevel !== optimizerBackend.originalSuperuserUacLevel) {



                var uacLabels = [qsTr("Always notify"), qsTr("Changes dim"), qsTr("Changes no dim"), qsTr("Never notify")];



                subList.push({



                    name: qsTr("UAC Level") + ": " + uacLabels[optimizerBackend.originalSuperuserUacLevel] + " -> " + uacLabels[optimizerBackend.superuserUacLevel],



                    revert: function() {



                        optimizerBackend.superuserUacLevel = optimizerBackend.originalSuperuserUacLevel;



                    }



                });



            }



            if (optimizerBackend.superuserUcpdActive !== optimizerBackend.originalSuperuserUcpdActive) {



                subList.push({



                    name: qsTr("UCPD Driver") + ": " + (optimizerBackend.originalSuperuserUcpdActive ? qsTr("Enabled") : qsTr("Disabled")) + " -> " + (optimizerBackend.superuserUcpdActive ? qsTr("Enabled") : qsTr("Disabled")),



                    revert: function() {



                        optimizerBackend.superuserUcpdActive = optimizerBackend.originalSuperuserUcpdActive;



                    }



                });



            }



        } else if (category === qsTr("File Explorer Customization") || category === "File Explorer Customization") {



            if (optimizerBackend.explorerShowExtensions !== optimizerBackend.originalExplorerShowExtensions) {



                subList.push({



                    name: qsTr("Show file extensions") + ": " + (optimizerBackend.originalExplorerShowExtensions ? qsTr("Enabled") : qsTr("Disabled")) + " -> " + (optimizerBackend.explorerShowExtensions ? qsTr("Enabled") : qsTr("Disabled")),



                    revert: function() {



                        optimizerBackend.explorerShowExtensions = optimizerBackend.originalExplorerShowExtensions;



                    }



                });



            }



            if (optimizerBackend.explorerShowHidden !== optimizerBackend.originalExplorerShowHidden) {



                subList.push({



                    name: qsTr("Show hidden files") + ": " + (optimizerBackend.originalExplorerShowHidden ? qsTr("Enabled") : qsTr("Disabled")) + " -> " + (optimizerBackend.explorerShowHidden ? qsTr("Enabled") : qsTr("Disabled")),



                    revert: function() {



                        optimizerBackend.explorerShowHidden = optimizerBackend.originalExplorerShowHidden;



                    }



                });



            }



            if (optimizerBackend.explorerShowExtractFiles !== optimizerBackend.originalExplorerShowExtractFiles) {



                subList.push({



                    name: qsTr("Show extracted files") + ": " + (optimizerBackend.originalExplorerShowExtractFiles ? qsTr("Enabled") : qsTr("Disabled")) + " -> " + (optimizerBackend.explorerShowExtractFiles ? qsTr("Enabled") : qsTr("Disabled")),



                    revert: function() {



                        optimizerBackend.explorerShowExtractFiles = optimizerBackend.originalExplorerShowExtractFiles;



                    }



                });



            }



            if (optimizerBackend.explorerClassicRibbon !== optimizerBackend.originalExplorerClassicRibbon) {



                subList.push({



                    name: qsTr("Classic Windows 10 Ribbon") + ": " + (optimizerBackend.originalExplorerClassicRibbon ? qsTr("Enabled") : qsTr("Disabled")) + " -> " + (optimizerBackend.explorerClassicRibbon ? qsTr("Enabled") : qsTr("Disabled")),



                    revert: function() {



                        optimizerBackend.explorerClassicRibbon = optimizerBackend.originalExplorerClassicRibbon;



                    }



                });



            }



            if (optimizerBackend.explorerShowPreviewPane !== optimizerBackend.originalExplorerShowPreviewPane) {



                subList.push({



                    name: qsTr("Show preview pane") + ": " + (optimizerBackend.originalExplorerShowPreviewPane ? qsTr("Enabled") : qsTr("Disabled")) + " -> " + (optimizerBackend.explorerShowPreviewPane ? qsTr("Enabled") : qsTr("Disabled")),



                    revert: function() {



                        optimizerBackend.explorerShowPreviewPane = optimizerBackend.originalExplorerShowPreviewPane;



                    }



                });



            }



            if (optimizerBackend.explorerShowRecycleBin !== optimizerBackend.originalExplorerShowRecycleBin) {



                subList.push({



                    name: qsTr("Show Recycle Bin") + ": " + (optimizerBackend.originalExplorerShowRecycleBin ? qsTr("Enabled") : qsTr("Disabled")) + " -> " + (optimizerBackend.explorerShowRecycleBin ? qsTr("Enabled") : qsTr("Disabled")),



                    revert: function() {



                        optimizerBackend.explorerShowRecycleBin = optimizerBackend.originalExplorerShowRecycleBin;



                    }



                });



            }



            if (optimizerBackend.explorerPinRecycleBin !== optimizerBackend.originalExplorerPinRecycleBin) {



                subList.push({



                    name: qsTr("Show Recycle Bin in navigation") + ": " + (optimizerBackend.originalExplorerPinRecycleBin ? qsTr("Enabled") : qsTr("Disabled")) + " -> " + (optimizerBackend.explorerPinRecycleBin ? qsTr("Enabled") : qsTr("Disabled")),



                    revert: function() {



                        optimizerBackend.explorerPinRecycleBin = optimizerBackend.originalExplorerPinRecycleBin;



                    }



                });



            }



            if (optimizerBackend.explorerPinHome !== optimizerBackend.originalExplorerPinHome) {



                subList.push({



                    name: qsTr("Show Home in navigation") + ": " + (optimizerBackend.originalExplorerPinHome ? qsTr("Enabled") : qsTr("Disabled")) + " -> " + (optimizerBackend.explorerPinHome ? qsTr("Enabled") : qsTr("Disabled")),



                    revert: function() {



                        optimizerBackend.explorerPinHome = optimizerBackend.originalExplorerPinHome;



                    }



                });



            }



            if (optimizerBackend.explorerPinGallery !== optimizerBackend.originalExplorerPinGallery) {



                subList.push({



                    name: qsTr("Show Gallery in navigation") + ": " + (optimizerBackend.originalExplorerPinGallery ? qsTr("Enabled") : qsTr("Disabled")) + " -> " + (optimizerBackend.explorerPinGallery ? qsTr("Enabled") : qsTr("Disabled")),



                    revert: function() {



                        optimizerBackend.explorerPinGallery = optimizerBackend.originalExplorerPinGallery;



                    }



                });



            }



            if (optimizerBackend.explorerUseCheckboxes !== optimizerBackend.originalExplorerUseCheckboxes) {



                subList.push({



                    name: qsTr("Use checkboxes") + ": " + (optimizerBackend.originalExplorerUseCheckboxes ? qsTr("Enabled") : qsTr("Disabled")) + " -> " + (optimizerBackend.explorerUseCheckboxes ? qsTr("Enabled") : qsTr("Disabled")),



                    revert: function() {



                        optimizerBackend.explorerUseCheckboxes = optimizerBackend.originalExplorerUseCheckboxes;



                    }



                });



            }



            if (optimizerBackend.explorerSyncNotifications !== optimizerBackend.originalExplorerSyncNotifications) {



                subList.push({



                    name: qsTr("Sync notifications") + ": " + (optimizerBackend.originalExplorerSyncNotifications ? qsTr("Enabled") : qsTr("Disabled")) + " -> " + (optimizerBackend.explorerSyncNotifications ? qsTr("Enabled") : qsTr("Disabled")),



                    revert: function() {



                        optimizerBackend.explorerSyncNotifications = optimizerBackend.originalExplorerSyncNotifications;



                    }



                });



            }



            if (optimizerBackend.explorerLaunchTo !== optimizerBackend.originalExplorerLaunchTo) {



                var openLabels = { 1: qsTr("This PC"), 2: qsTr("Home"), 3: qsTr("Downloads") };



                subList.push({



                    name: qsTr("Open File Explorer to") + ": " + (openLabels[optimizerBackend.originalExplorerLaunchTo] || optimizerBackend.originalExplorerLaunchTo) + " -> " + (openLabels[optimizerBackend.explorerLaunchTo] || optimizerBackend.explorerLaunchTo),



                    revert: function() {



                        optimizerBackend.explorerLaunchTo = optimizerBackend.originalExplorerLaunchTo;



                    }



                });



            }



        } else if (category === qsTr("Start Menu Customization") || category === "Start Menu Customization") {



            if (optimizerBackend.startMenuWebResults !== optimizerBackend.originalStartMenuWebResults) {



                subList.push({



                    name: qsTr("Include web results when searching") + ": " + (optimizerBackend.originalStartMenuWebResults ? qsTr("Enabled") : qsTr("Disabled")) + " -> " + (optimizerBackend.startMenuWebResults ? qsTr("Enabled") : qsTr("Disabled")),



                    revert: function() {



                        optimizerBackend.startMenuWebResults = optimizerBackend.originalStartMenuWebResults;



                    }



                });



            }



            if (optimizerBackend.startMenuAutoinstall !== optimizerBackend.originalStartMenuAutoinstall) {



                subList.push({



                    name: qsTr("Autoinstall suggestions") + ": " + (optimizerBackend.originalStartMenuAutoinstall ? qsTr("Enabled") : qsTr("Disabled")) + " -> " + (optimizerBackend.startMenuAutoinstall ? qsTr("Enabled") : qsTr("Disabled")),



                    revert: function() {



                        optimizerBackend.startMenuAutoinstall = optimizerBackend.originalStartMenuAutoinstall;



                    }



                });



            }



            if (optimizerBackend.startMenuAccountNotifications !== optimizerBackend.originalStartMenuAccountNotifications) {



                subList.push({



                    name: qsTr("Account notifications") + ": " + (optimizerBackend.originalStartMenuAccountNotifications ? qsTr("Enabled") : qsTr("Disabled")) + " -> " + (optimizerBackend.startMenuAccountNotifications ? qsTr("Enabled") : qsTr("Disabled")),



                    revert: function() {



                        optimizerBackend.startMenuAccountNotifications = optimizerBackend.originalStartMenuAccountNotifications;



                    }



                });



            }



            if (optimizerBackend.startMenuShowHibernate !== optimizerBackend.originalStartMenuShowHibernate) {



                subList.push({



                    name: qsTr("Show hibernate in power menu") + ": " + (optimizerBackend.originalStartMenuShowHibernate ? qsTr("Enabled") : qsTr("Disabled")) + " -> " + (optimizerBackend.startMenuShowHibernate ? qsTr("Enabled") : qsTr("Disabled")),



                    revert: function() {



                        optimizerBackend.startMenuShowHibernate = optimizerBackend.originalStartMenuShowHibernate;



                    }



                });



            }



        } else if (category === qsTr("Desktop Customization") || category === "Desktop Customization") {



            if (optimizerBackend.desktopShowThisPC !== optimizerBackend.originalDesktopShowThisPC) {



                subList.push({



                    name: qsTr("Show \"This PC\" icon") + ": " + (optimizerBackend.originalDesktopShowThisPC ? qsTr("Enabled") : qsTr("Disabled")) + " -> " + (optimizerBackend.desktopShowThisPC ? qsTr("Enabled") : qsTr("Disabled")),



                    revert: function() {



                        optimizerBackend.desktopShowThisPC = optimizerBackend.originalDesktopShowThisPC;



                    }



                });



            }



            if (optimizerBackend.explorerShowRecycleBin !== optimizerBackend.originalExplorerShowRecycleBin) {



                subList.push({



                    name: qsTr("Show Recycle Bin") + ": " + (optimizerBackend.originalExplorerShowRecycleBin ? qsTr("Enabled") : qsTr("Disabled")) + " -> " + (optimizerBackend.explorerShowRecycleBin ? qsTr("Enabled") : qsTr("Disabled")),



                    revert: function() {



                        optimizerBackend.explorerShowRecycleBin = optimizerBackend.originalExplorerShowRecycleBin;



                    }



                });



            }



            if (optimizerBackend.desktopShowWidgets !== optimizerBackend.originalDesktopShowWidgets) {



                subList.push({



                    name: qsTr("Show Widgets") + ": " + (optimizerBackend.originalDesktopShowWidgets ? qsTr("Enabled") : qsTr("Disabled")) + " -> " + (optimizerBackend.desktopShowWidgets ? qsTr("Enabled") : qsTr("Disabled")),



                    revert: function() {



                        optimizerBackend.desktopShowWidgets = optimizerBackend.originalDesktopShowWidgets;



                    }



                });



            }



            if (optimizerBackend.shortcutArrowsActive !== optimizerBackend.originalShortcutArrowsActive) {



                subList.push({



                    name: qsTr("Shortcut Arrow Overlays") + ": " + (optimizerBackend.originalShortcutArrowsActive ? qsTr("Enabled") : qsTr("Disabled")) + " -> " + (optimizerBackend.shortcutArrowsActive ? qsTr("Enabled") : qsTr("Disabled")),



                    revert: function() {



                        optimizerBackend.shortcutArrowsActive = optimizerBackend.originalShortcutArrowsActive;



                    }



                });



            }



            if (optimizerBackend.desktopIconShadows !== optimizerBackend.originalDesktopIconShadows) {



                subList.push({



                    name: qsTr("Drop shadows for icon labels") + ": " + (optimizerBackend.originalDesktopIconShadows ? qsTr("Enabled") : qsTr("Disabled")) + " -> " + (optimizerBackend.desktopIconShadows ? qsTr("Enabled") : qsTr("Disabled")),



                    revert: function() {



                        optimizerBackend.desktopIconShadows = optimizerBackend.originalDesktopIconShadows;



                    }



                });



            }



            if (optimizerBackend.desktopShowDesktopButton !== optimizerBackend.originalDesktopShowDesktopButton) {



                subList.push({



                    name: qsTr("Show desktop button") + ": " + (optimizerBackend.originalDesktopShowDesktopButton ? qsTr("Enabled") : qsTr("Disabled")) + " -> " + (optimizerBackend.desktopShowDesktopButton ? qsTr("Enabled") : qsTr("Disabled")),



                    revert: function() {



                        optimizerBackend.desktopShowDesktopButton = optimizerBackend.originalDesktopShowDesktopButton;



                    }



                });



            }



            if (optimizerBackend.desktopAeroShake !== optimizerBackend.originalDesktopAeroShake) {



                subList.push({



                    name: qsTr("Titlebar window shake (Aero Shake)") + ": " + (optimizerBackend.originalDesktopAeroShake ? qsTr("Enabled") : qsTr("Disabled")) + " -> " + (optimizerBackend.desktopAeroShake ? qsTr("Enabled") : qsTr("Disabled")),



                    revert: function() {



                        optimizerBackend.desktopAeroShake = optimizerBackend.originalDesktopAeroShake;



                    }



                });



            }



            if (optimizerBackend.classicContextMenuActive !== optimizerBackend.originalClassicContextMenuActive) {



                subList.push({



                    name: qsTr("Classic Context Menu") + ": " + (optimizerBackend.originalClassicContextMenuActive ? qsTr("Enabled") : qsTr("Disabled")) + " -> " + (optimizerBackend.classicContextMenuActive ? qsTr("Enabled") : qsTr("Disabled")),



                    revert: function() {



                        optimizerBackend.classicContextMenuActive = optimizerBackend.originalClassicContextMenuActive;



                    }



                });



            }



            if (optimizerBackend.desktopWallpaperQuality !== optimizerBackend.originalDesktopWallpaperQuality) {



                subList.push({



                    name: qsTr("Wallpaper quality") + ": " + optimizerBackend.originalDesktopWallpaperQuality + "% -> " + optimizerBackend.desktopWallpaperQuality + "%",



                    revert: function() {



                        optimizerBackend.desktopWallpaperQuality = optimizerBackend.originalDesktopWallpaperQuality;



                    }



                });



            }



        }



        return subList;



    }







        function getDrawerName(name) {
        name = name.toLowerCase();
        if (name.indexOf("explorer") !== -1 || name.indexOf("classic context menu") !== -1 || name.indexOf("shortcut arrow") !== -1) {
            return "explorerCustomization";
        }
        if (name.indexOf("start menu") !== -1) {
            return "startMenuCustomization";
        }
        if (name.indexOf("desktop") !== -1) {
            return "desktopCustomization";
        }
        if (name.indexOf("visual effects") !== -1 || name.indexOf("visualeffects") !== -1) {
            return "visualEffects";
        }
        if (name.indexOf("indexing") !== -1) {
            return "indexing";
        }
        if (name.indexOf("xbox") !== -1) {
            return "xbox";
        }
        if (name.indexOf("notification") !== -1) {
            return "notifications";
        }
        if (name.indexOf("power plan") !== -1 || name.indexOf("powerplan") !== -1) {
            return "power";
        }
        if (name.indexOf("defender") !== -1) {
            return "defender";
        }
        if (name.indexOf("usb") !== -1) {
            return "usb";
        }
        if (name.indexOf("telemetry") !== -1) {
            return "telemetry";
        }
        if (name.indexOf("windows update") !== -1 || name.indexOf("windowsupdate") !== -1) {
            return "windowsUpdate";
        }
        if (name.indexOf("privileges") !== -1 || name.indexOf("more rights") !== -1 || name.indexOf("morerights") !== -1) {
            return "moreRights";
        }
        if (name.indexOf("steam") !== -1 || name.indexOf("cs2") !== -1 || name.indexOf("counter-strike") !== -1 || name.indexOf("remote play") !== -1 || name.indexOf("remoteplay") !== -1) {
            return "steamSettings";
        }
        if (name.indexOf("sleeping pill") !== -1 || name.indexOf("sleepingpill") !== -1) {
            return "sleepingPill";
        }
        if (name.indexOf("health") !== -1) {
            return "health";
        }
        if (name.indexOf("cleanup") !== -1) {
            return "cleanup";
        }
        if (name.indexOf("repair") !== -1) {
            return "repair";
        }
        if (name.indexOf("mpo") !== -1) {
            return "mpo";
        }
        return "";
    }

    function getDrawerObject(drawerName) {
        if (drawerName === "explorerCustomization") return explorerDrawer;
        if (drawerName === "startMenuCustomization") return startMenuDrawer;
        if (drawerName === "desktopCustomization") return desktopDrawer;
        if (drawerName === "visualEffects") return visualEffectsDrawer;
        if (drawerName === "indexing") return indexingDrawer;
        if (drawerName === "xbox") return xboxDrawer;
        if (drawerName === "notifications") return notificationsDrawer;
        if (drawerName === "power") return powerDrawer;
        if (drawerName === "defender") return defenderDrawer;
        if (drawerName === "usb") return usbDrawer;
        if (drawerName === "telemetry") return telemetryDrawer;
        if (drawerName === "windowsUpdate") return windowsUpdateDrawer;
        if (drawerName === "moreRights") return moreRightsDrawer;
        if (drawerName === "steamSettings") return steamSettingsDrawer;
        if (drawerName === "sleepingPill") return sleepingPillDrawer;
        if (drawerName === "health") return healthDrawer;
        if (drawerName === "cleanup") return cleanupDrawer;
        if (drawerName === "repair") return repairDrawer;
        if (drawerName === "mpo") return mpoDrawer;
        return null;
    }

    function getParentCardForDrawer(drawerName) {
        if (drawerName === "explorerCustomization") return explorerCustomizationPanel;
        if (drawerName === "startMenuCustomization") return startMenuCustomizationPanel;
        if (drawerName === "desktopCustomization") return desktopCustomizationPanel;
        if (drawerName === "visualEffects") return visualEffectsPanel;
        if (drawerName === "indexing") return indexingPanel;
        if (drawerName === "xbox") return xboxPanel;
        if (drawerName === "notifications") return notificationsPanel;
        if (drawerName === "power") return powerPlanPanel;
        if (drawerName === "defender") return defenderPanel;
        if (drawerName === "usb") return usbPanel;
        if (drawerName === "telemetry") return telemetryPanel;
        if (drawerName === "windowsUpdate") return windowsUpdatePanel;
        if (drawerName === "moreRights") return moreRightsPanel;
        if (drawerName === "steamSettings") return steamSettingsPanel;
        if (drawerName === "mpo") return mpoPanel;
        return null;
    }

    function getSteamSubPageForName(name) {
        name = name.toLowerCase();
        if (name.indexOf("remote play") !== -1 || name.indexOf("remoteplay") !== -1 || name.indexOf("pairing") !== -1) {
            return "remoteplay";
        }
        if (name.indexOf("friend") !== -1 || name.indexOf("avatar") !== -1 || name.indexOf("profile name") !== -1 || name.indexOf("profilename") !== -1) {
            return "friends";
        }
        if (name.indexOf("chat") !== -1) {
            return "chat";
        }
        if (name.indexOf("broadcast") !== -1) {
            return "broadcast";
        }
        if (name.indexOf("interface") !== -1 || name.indexOf("language") !== -1 || name.indexOf("start page") !== -1 || name.indexOf("run on startup") !== -1) {
            return "interface";
        }
        if (name.indexOf("in-game") !== -1 || name.indexOf("ingame") !== -1 || name.indexOf("overlay") !== -1) {
            return "ingame";
        }
        if (name.indexOf("notification") !== -1) {
            return "notifications";
        }
        if (name.indexOf("library") !== -1) {
            return "library";
        }
        if (name.indexOf("download") !== -1) {
            return "download";
        }
        if (name.indexOf("storage") !== -1) {
            return "storage";
        }
        if (name.indexOf("toolbar") !== -1) {
            return "toolbarPrefs";
        }
        if (name.indexOf("accessibility") !== -1) {
            return "accessibility";
        }
        if (name.indexOf("recording") !== -1 || name.indexOf("record") !== -1) {
            return "gamerecording";
        }
        if (name.indexOf("voice") !== -1) {
            return "voice";
        }
        if (name.indexOf("music") !== -1) {
            return "music";
        }
        return "main";
    }

    function getSectionForDrawerOrCategory(name) {
        name = name.toLowerCase();
        if (name.indexOf("explorer") !== -1 ||
            name.indexOf("classic context menu") !== -1 ||
            name.indexOf("shortcut arrow") !== -1 ||
            name.indexOf("clipboard") !== -1 ||
            name.indexOf("end task") !== -1 ||
            name.indexOf("clock") !== -1 ||
            name.indexOf("privileges") !== -1 ||
            name.indexOf("start menu") !== -1 ||
            name.indexOf("desktop") !== -1) {
            return "customization";
        }
        if (name.indexOf("telemetry") !== -1 ||
            name.indexOf("ads") !== -1 ||
            name.indexOf("privacy") !== -1 ||
            name.indexOf("location") !== -1 ||
            name.indexOf("speech") !== -1 ||
            name.indexOf("camera") !== -1) {
            return "telemetry";
        }
        if (name.indexOf("steam") !== -1 ||
            name.indexOf("cs2") !== -1 ||
            name.indexOf("counter-strike") !== -1 ||
            name.indexOf("remote play") !== -1 ||
            name.indexOf("remoteplay") !== -1) {
            return "games";
        }
        return "core";
    }

    function findDrawerChild(item, searchText) {
        if (!item) return null;
        if (item.text !== undefined && typeof item.text === "string") {
            var cleanItemText = item.text.replace(/\r?\n|\r/g, " ").trim().toLowerCase();
            var cleanSearch = searchText.toLowerCase();
            if (cleanItemText === cleanSearch || cleanItemText.indexOf(cleanSearch) !== -1 || cleanSearch.indexOf(cleanItemText) !== -1) {
                return item;
            }
        }
        if (item.children) {
            for (var i = 0; i < item.children.length; i++) {
                var found = findDrawerChild(item.children[i], searchText);
                if (found) return found;
            }
        }
        return null;
    }

    function getParentCard(name) {



        if (name === qsTr("File Explorer Customization") || name === "File Explorer Customization") return explorerCustomizationPanel;



        if (name === qsTr("Start Menu Customization") || name === "Start Menu Customization") return startMenuCustomizationPanel;



        if (name === qsTr("Desktop Customization") || name === "Desktop Customization") return desktopCustomizationPanel;



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
        if (name === qsTr("Fast Startup") || name === "Fast Startup") return fastStartupPanel;



        if (name === qsTr("Power Plan") || name === "Power Plan") return powerPlanPanel;



        if (name === qsTr("BitLocker Drive Encryption") || name === "BitLocker Drive Encryption") return bitlockerPanel;



        if (name === qsTr("Windows Defender") || name === "Windows Defender") return defenderPanel;



        if (name === qsTr("USB 3.0 Power Saving") || name === "USB 3.0 Power Saving") return usbPanel;



        if (name === qsTr("Co-installers") || name === "Co-installers") return coinstallersPanel;



        if (name === qsTr("Remote Access (RDP)") || name === "Remote Access (RDP)") return remoteAccessPanel;



        if (name === qsTr("Telemetry") || name === "Telemetry") return telemetryPanel;



        if (name === qsTr("Windows Update") || name === "Windows Update") return windowsUpdatePanel;



        if (name === qsTr("CS2 Steam Overlay") || name === "CS2 Steam Overlay") return cs2Panel;



        if (name === qsTr("More Privileges") || name === "More Privileges") return moreRightsPanel;



        if (name === qsTr("Steam Settings") || name === "Steam Settings") return steamSettingsPanel;



        if (name === qsTr("Classic Context Menu") || name === "Classic Context Menu") return desktopCustomizationPanel;



        if (name === qsTr("Shortcut Arrow Overlays") || name === "Shortcut Arrow Overlays") return desktopCustomizationPanel;



        if (name === qsTr("Clipboard History") || name === "Clipboard History") return clipboardHistoryPanel;



        if (name === qsTr("Taskbar 'End task'") || name === "Taskbar 'End task'") return taskbarEndTaskPanel;



        if (name === qsTr("Clock with seconds") || name === "Clock with seconds") return taskbarSecondsPanel;



        if (name === qsTr("Ads & Privacy") || name === "Ads & Privacy" || name === "Ads" || name === "Ad" || name === qsTr("Ads") || name === qsTr("Ad")) return adsPanel;



        if (name === qsTr("Privacy") || name === "Privacy") return privacyPanel;



        return null;



    }







        function locateFunction(categoryName) {
        var cleanName = categoryName.split(":")[0].trim();
        
        var section = getSectionForDrawerOrCategory(cleanName);
        if (section === "core" && cleanName !== categoryName) {
            var targetDrawerName = "";
            var allDrawers = [
                "explorerCustomization", "startMenuCustomization", "desktopCustomization",
                "visualEffects", "indexing", "xbox", "notifications", "power", "defender",
                "usb", "telemetry", "windowsUpdate", "moreRights", "steamSettings",
                "sleepingPill", "health", "cleanup", "repair", "mpo"
            ];
            for (var i = 0; i < allDrawers.length; i++) {
                var drObj = getDrawerObject(allDrawers[i]);
                if (drObj && findDrawerChild(drObj, cleanName)) {
                    targetDrawerName = allDrawers[i];
                    break;
                }
            }
            if (targetDrawerName) {
                section = getSectionForDrawerOrCategory(targetDrawerName);
            }
        }
        
        root.currentSection = section;
        
        Qt.callLater(function() {
            var targetDrawerName = "";
            var directDrawer = getDrawerName(cleanName);
            if (directDrawer) {
                targetDrawerName = directDrawer;
            } else {
                var allDrawers = [
                    "explorerCustomization", "startMenuCustomization", "desktopCustomization",
                    "visualEffects", "indexing", "xbox", "notifications", "power", "defender",
                    "usb", "telemetry", "windowsUpdate", "moreRights", "steamSettings",
                    "sleepingPill", "health", "cleanup", "repair", "mpo"
                ];
                for (var i = 0; i < allDrawers.length; i++) {
                    var drObj = getDrawerObject(allDrawers[i]);
                    if (drObj && findDrawerChild(drObj, cleanName)) {
                        targetDrawerName = allDrawers[i];
                        break;
                    }
                }
            }
            
            var panel = getParentCard(cleanName);
            if (!panel && targetDrawerName) {
                panel = getParentCardForDrawer(targetDrawerName);
            }
            
            if (panel) {
                var flick = mainScroll.contentItem;
                if (flick) {
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
                }
            }
            
            if (targetDrawerName) {
                root.activeDrawer = targetDrawerName;
                
                Qt.callLater(function() {
                    var drawerObj = getDrawerObject(targetDrawerName);
                    if (!drawerObj) return;
                    
                    if (targetDrawerName === "steamSettings") {
                        var steamSubPage = getSteamSubPageForName(cleanName);
                        drawerObj.subPage = steamSubPage;
                    }
                    
                    Qt.callLater(function() {
                        var targetControl = findDrawerChild(drawerObj, cleanName);
                        if (targetControl) {
                            var pt = targetControl.mapToItem(drawerObj, 0, 0);
                            var targetScrollY = pt.y - (drawerScroll.height - targetControl.height) / 2;
                            var maxScrollY = drawerScroll.contentItem.contentHeight - drawerScroll.height;
                            if (maxScrollY < 0) maxScrollY = 0;
                            targetScrollY = Math.max(0, Math.min(targetScrollY, maxScrollY));
                            
                            drawerScrollAnimation.stop();
                            drawerScrollAnimation.target = drawerScroll.contentItem;
                            drawerScrollAnimation.to = targetScrollY;
                            drawerScrollAnimation.start();
                            
                            if (typeof targetControl.triggerLocateFlash === "function") {
                                targetControl.triggerLocateFlash();
                            }
                        }
                    });
                });
            }
        });
    }







    NumberAnimation {



        id: scrollAnimation



        property: "contentY"



        duration: 500



        easing.type: Easing.InOutQuad



    }

    NumberAnimation {
        id: drawerScrollAnimation
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



        anchors.topMargin: 112

        anchors.bottomMargin: 24

        anchors.leftMargin: 24

        anchors.rightMargin: 24



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



            width: mainScroll.width > 20 ? mainScroll.width - 20 : 800



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



                    height: detailsExpanded ? 94 + detailsContainer.implicitHeight + 24 : 94



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



                                        font.pixelSize: 16



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



                                    font.pixelSize: 12



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



                                    font.pixelSize: 12



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



                    height: 94



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



                                    font.pixelSize: 16



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



                                font.pixelSize: 12



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



                    height: 104







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



                                    font.pixelSize: 16



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



                                font.pixelSize: 12



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



                    height: 104







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



                                    font.pixelSize: 16



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



                                font.pixelSize: 12



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



                    height: 104







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



                                    font.pixelSize: 16



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



                                font.pixelSize: 12



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



                    height: 104







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



                                    font.pixelSize: 16



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



                                font.pixelSize: 12



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



                    height: (optimizerBackend.coreIsolationActive !== optimizerBackend.bootCoreIsolationActive) ? 152 : 104







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



                                    font.pixelSize: 16



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



                                font.pixelSize: 12



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



                                font.pixelSize: 12



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



                    height: 104







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



                                    font.pixelSize: 16



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



                                font.pixelSize: 12



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



                    height: 104







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



                                    font.pixelSize: 16



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



                                font.pixelSize: 12



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



                    height: root.isDiscordOpen ? 116 : 104



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



                                    font.pixelSize: 16



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



                                font.pixelSize: 12



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



                    height: 104







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



                                    font.pixelSize: 16



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



                                font.pixelSize: 12



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



                    height: 104







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



                                    font.pixelSize: 16



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



                                font.pixelSize: 12



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



                    height: 104







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



                                    font.pixelSize: 16



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



                                font.pixelSize: 12



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



                // Ads & Privacy Panel



                AcrylicPanel {



                    id: adsPanel



                    visible: root.currentSection === "telemetry"



                    width: parent.width



                    height: detailsExpanded ? adsColumn.implicitHeight + 16 : 104



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



                        Item {



                            id: adsHeaderRow



                            anchors.left: parent.left



                            anchors.right: parent.right



                            anchors.leftMargin: 16



                            anchors.rightMargin: 16



                            height: 104







                            Rectangle {



                                id: adsHeaderIconRect



                                width: 40



                                height: 40



                                radius: 10



                                color: Qt.rgba(0.9, 0.45, 0.1, 0.15)



                                anchors.left: parent.left



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



                                id: adsHeaderTexts



                                anchors.left: adsHeaderIconRect.right



                                anchors.leftMargin: 12



                                anchors.right: expandBtn.left



                                anchors.rightMargin: 12



                                anchors.verticalCenter: parent.verticalCenter



                                spacing: 2







                                Row {



                                    spacing: 8



                                    Text {



                                        text: qsTr("Ads")



                                        color: Theme.textPrimary



                                        font.family: Theme.fontFamily



                                        font.pixelSize: 16



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



                                    font.pixelSize: 12



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



                                anchors.right: parent.right



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



                            anchors.left: parent.left



                            anchors.right: parent.right



                            anchors.leftMargin: 16



                            anchors.rightMargin: 16



                            color: Theme.border



                            opacity: adsPanel.detailsExpanded ? 0.2 : 0.0



                            Behavior on opacity { NumberAnimation { duration: Theme.animFast } }



                        }







                        // Expansion Container listing the 9 options



                        Column {



                            id: adsDetailsContainer



                            anchors.left: parent.left



                            anchors.right: parent.right



                            anchors.leftMargin: 28



                            anchors.rightMargin: 16



                            spacing: 4



                            visible: adsPanel.detailsExpanded



                            opacity: adsPanel.detailsExpanded ? 1.0 : 0.0



                            Behavior on opacity { NumberAnimation { duration: Theme.animFast } }







                            // 1. Tailored experiences



                            Item {



                                anchors.left: parent.left



                                anchors.right: parent.right



                                height: 40







                                Item {



                                    id: iconTailoredContainer



                                    width: 16



                                    height: 16



                                    anchors.left: parent.left



                                    anchors.verticalCenter: parent.verticalCenter







                                    Image {



                                        id: iconTailored



                                        source: "qrc:/MeguPackOptimizer/src/resources/help.svg"



                                        anchors.fill: parent



                                        sourceSize.width: 16



                                        sourceSize.height: 16



                                        visible: false



                                    }



                                    ColorOverlay {



                                        anchors.fill: parent



                                        source: iconTailored



                                        color: optimizerBackend.adsTailoredExperiencesActive !== optimizerBackend.originalAdsTailoredExperiencesActive ? Theme.accent : Theme.textSecondary



                                    }



                                }







                                Text {



                                    text: qsTr("Tailored experiences")



                                    color: Theme.textPrimary



                                    font.family: Theme.fontFamily



                                    font.pixelSize: 12



                                    anchors.left: iconTailoredContainer.right



                                    anchors.leftMargin: 24



                                    anchors.verticalCenter: parent.verticalCenter



                                }







                                MeguSwitch {



                                    checked: optimizerBackend.adsTailoredExperiencesActive



                                    anchors.right: parent.right



                                    anchors.verticalCenter: parent.verticalCenter



                                    onToggled: (val) => { optimizerBackend.adsTailoredExperiencesActive = val; }



                                }



                            }







                            // 2. Advertising ID



                            Item {



                                anchors.left: parent.left



                                anchors.right: parent.right



                                height: 40







                                Item {



                                    id: iconAdvContainer



                                    width: 16



                                    height: 16



                                    anchors.left: parent.left



                                    anchors.verticalCenter: parent.verticalCenter







                                    Image {



                                        id: iconAdv



                                        source: "qrc:/MeguPackOptimizer/src/resources/settings.svg"



                                        anchors.fill: parent



                                        sourceSize.width: 16



                                        sourceSize.height: 16



                                        visible: false



                                    }



                                    ColorOverlay {



                                        anchors.fill: parent



                                        source: iconAdv



                                        color: optimizerBackend.adsAdvertisingIdActive !== optimizerBackend.originalAdsAdvertisingIdActive ? Theme.accent : Theme.textSecondary



                                    }



                                }







                                Text {



                                    text: qsTr("Advertising ID")



                                    color: Theme.textPrimary



                                    font.family: Theme.fontFamily



                                    font.pixelSize: 12



                                    anchors.left: iconAdvContainer.right



                                    anchors.leftMargin: 24



                                    anchors.verticalCenter: parent.verticalCenter



                                }







                                MeguSwitch {



                                    checked: optimizerBackend.adsAdvertisingIdActive



                                    anchors.right: parent.right



                                    anchors.verticalCenter: parent.verticalCenter



                                    onToggled: (val) => { optimizerBackend.adsAdvertisingIdActive = val; }



                                }



                            }







                            // 3. Suggested content in settings



                            Item {



                                anchors.left: parent.left



                                anchors.right: parent.right



                                height: 40







                                Item {



                                    id: iconSuggestedContentContainer



                                    width: 16



                                    height: 16



                                    anchors.left: parent.left



                                    anchors.verticalCenter: parent.verticalCenter







                                    Image {



                                        id: iconSuggestedContent



                                        source: "qrc:/MeguPackOptimizer/src/resources/settings.svg"



                                        anchors.fill: parent



                                        sourceSize.width: 16



                                        sourceSize.height: 16



                                        visible: false



                                    }



                                    ColorOverlay {



                                        anchors.fill: parent



                                        source: iconSuggestedContent



                                        color: optimizerBackend.adsSuggestedContentActive !== optimizerBackend.originalAdsSuggestedContentActive ? Theme.accent : Theme.textSecondary



                                    }



                                }







                                Text {



                                    text: qsTr("Suggested content in settings")



                                    color: Theme.textPrimary



                                    font.family: Theme.fontFamily



                                    font.pixelSize: 12



                                    anchors.left: iconSuggestedContentContainer.right



                                    anchors.leftMargin: 24



                                    anchors.verticalCenter: parent.verticalCenter



                                }







                                MeguSwitch {



                                    checked: optimizerBackend.adsSuggestedContentActive



                                    anchors.right: parent.right



                                    anchors.verticalCenter: parent.verticalCenter



                                    onToggled: (val) => { optimizerBackend.adsSuggestedContentActive = val; }



                                }



                            }







                            // 4. Home page in settings app



                            Item {



                                anchors.left: parent.left



                                anchors.right: parent.right



                                height: 40







                                Item {



                                    id: iconHomeContainer



                                    width: 16



                                    height: 16



                                    anchors.left: parent.left



                                    anchors.verticalCenter: parent.verticalCenter







                                    Image {



                                        id: iconHome



                                        source: "qrc:/MeguPackOptimizer/src/resources/monitor.svg"



                                        anchors.fill: parent



                                        sourceSize.width: 16



                                        sourceSize.height: 16



                                        visible: false



                                    }



                                    ColorOverlay {



                                        anchors.fill: parent



                                        source: iconHome



                                        color: optimizerBackend.adsSettingsHomeActive !== optimizerBackend.originalAdsSettingsHomeActive ? Theme.accent : Theme.textSecondary



                                    }



                                }







                                Text {



                                    text: qsTr("Home page in the settings app")



                                    color: Theme.textPrimary



                                    font.family: Theme.fontFamily



                                    font.pixelSize: 12



                                    anchors.left: iconHomeContainer.right



                                    anchors.leftMargin: 24



                                    anchors.verticalCenter: parent.verticalCenter



                                }







                                MeguSwitch {



                                    checked: optimizerBackend.adsSettingsHomeActive



                                    anchors.right: parent.right



                                    anchors.verticalCenter: parent.verticalCenter



                                    onToggled: (val) => { optimizerBackend.adsSettingsHomeActive = val; }



                                }



                            }







                            // 5. Suggested notifications



                            Item {



                                anchors.left: parent.left



                                anchors.right: parent.right



                                height: 40







                                Item {



                                    id: iconSuggestedNotificationsContainer



                                    width: 16



                                    height: 16



                                    anchors.left: parent.left



                                    anchors.verticalCenter: parent.verticalCenter







                                    Image {



                                        id: iconSuggestedNotifications



                                        source: "qrc:/MeguPackOptimizer/src/resources/warning.svg"



                                        anchors.fill: parent



                                        sourceSize.width: 16



                                        sourceSize.height: 16



                                        visible: false



                                    }



                                    ColorOverlay {



                                        anchors.fill: parent



                                        source: iconSuggestedNotifications



                                        color: optimizerBackend.adsSuggestedNotificationsActive !== optimizerBackend.originalAdsSuggestedNotificationsActive ? Theme.accent : Theme.textSecondary



                                    }



                                }







                                Text {



                                    text: qsTr("Suggested notifications")



                                    color: Theme.textPrimary



                                    font.family: Theme.fontFamily



                                    font.pixelSize: 12



                                    anchors.left: iconSuggestedNotificationsContainer.right



                                    anchors.leftMargin: 24



                                    anchors.verticalCenter: parent.verticalCenter



                                }







                                MeguSwitch {



                                    checked: optimizerBackend.adsSuggestedNotificationsActive



                                    anchors.right: parent.right



                                    anchors.verticalCenter: parent.verticalCenter



                                    onToggled: (val) => { optimizerBackend.adsSuggestedNotificationsActive = val; }



                                }



                            }







                            // 6. Lock screen fun facts, tips and tricks



                            Item {



                                anchors.left: parent.left



                                anchors.right: parent.right



                                height: 40







                                Item {



                                    id: iconLockTipsContainer



                                    width: 16



                                    height: 16



                                    anchors.left: parent.left



                                    anchors.verticalCenter: parent.verticalCenter







                                    Image {



                                        id: iconLockTips



                                        source: "qrc:/MeguPackOptimizer/src/resources/monitor.svg"



                                        anchors.fill: parent



                                        sourceSize.width: 16



                                        sourceSize.height: 16



                                        visible: false



                                    }



                                    ColorOverlay {



                                        anchors.fill: parent



                                        source: iconLockTips



                                        color: optimizerBackend.adsLockScreenTipsActive !== optimizerBackend.originalAdsLockScreenTipsActive ? Theme.accent : Theme.textSecondary



                                    }



                                }







                                Text {



                                    text: qsTr("Lock screen fun facts, tips and tricks")



                                    color: Theme.textPrimary



                                    font.family: Theme.fontFamily



                                    font.pixelSize: 12



                                    anchors.left: iconLockTipsContainer.right



                                    anchors.leftMargin: 24



                                    anchors.verticalCenter: parent.verticalCenter



                                }







                                MeguSwitch {



                                    checked: optimizerBackend.adsLockScreenTipsActive



                                    anchors.right: parent.right



                                    anchors.verticalCenter: parent.verticalCenter



                                    onToggled: (val) => { optimizerBackend.adsLockScreenTipsActive = val; }



                                }



                            }







                            // 7. Windows tips and suggestions



                            Item {



                                anchors.left: parent.left



                                anchors.right: parent.right



                                height: 40







                                Item {



                                    id: iconWinTipsContainer



                                    width: 16



                                    height: 16



                                    anchors.left: parent.left



                                    anchors.verticalCenter: parent.verticalCenter







                                    Image {



                                        id: iconWinTips



                                        source: "qrc:/MeguPackOptimizer/src/resources/help.svg"



                                        anchors.fill: parent



                                        sourceSize.width: 16



                                        sourceSize.height: 16



                                        visible: false



                                    }



                                    ColorOverlay {



                                        anchors.fill: parent



                                        source: iconWinTips



                                        color: optimizerBackend.adsWindowsTipsActive !== optimizerBackend.originalAdsWindowsTipsActive ? Theme.accent : Theme.textSecondary



                                    }



                                }







                                Text {



                                    text: qsTr("Windows tips and suggestions")



                                    color: Theme.textPrimary



                                    font.family: Theme.fontFamily



                                    font.pixelSize: 12



                                    anchors.left: iconWinTipsContainer.right



                                    anchors.leftMargin: 24



                                    anchors.verticalCenter: parent.verticalCenter



                                }







                                MeguSwitch {



                                    checked: optimizerBackend.adsWindowsTipsActive



                                    anchors.right: parent.right



                                    anchors.verticalCenter: parent.verticalCenter



                                    onToggled: (val) => { optimizerBackend.adsWindowsTipsActive = val; }



                                }



                            }







                            // 8. Windows welcome experience



                            Item {



                                anchors.left: parent.left



                                anchors.right: parent.right



                                height: 40







                                Item {



                                    id: iconWelcomeContainer



                                    width: 16



                                    height: 16



                                    anchors.left: parent.left



                                    anchors.verticalCenter: parent.verticalCenter







                                    Image {



                                        id: iconWelcome



                                        source: "qrc:/MeguPackOptimizer/src/resources/bolt.svg"



                                        anchors.fill: parent



                                        sourceSize.width: 16



                                        sourceSize.height: 16



                                        visible: false



                                    }



                                    ColorOverlay {



                                        anchors.fill: parent



                                        source: iconWelcome



                                        color: optimizerBackend.adsWelcomeExperienceActive !== optimizerBackend.originalAdsWelcomeExperienceActive ? Theme.accent : Theme.textSecondary



                                    }



                                }







                                Text {



                                    text: qsTr("Windows welcome experience")



                                    color: Theme.textPrimary



                                    font.family: Theme.fontFamily



                                    font.pixelSize: 12



                                    anchors.left: iconWelcomeContainer.right



                                    anchors.leftMargin: 24



                                    anchors.verticalCenter: parent.verticalCenter



                                }







                                MeguSwitch {



                                    checked: optimizerBackend.adsWelcomeExperienceActive



                                    anchors.right: parent.right



                                    anchors.verticalCenter: parent.verticalCenter



                                    onToggled: (val) => { optimizerBackend.adsWelcomeExperienceActive = val; }



                                }



                            }







                            // 9. Finish setting up your device



                            Item {



                                anchors.left: parent.left



                                anchors.right: parent.right



                                height: 40







                                Item {



                                    id: iconFinishSetupContainer



                                    width: 16



                                    height: 16



                                    anchors.left: parent.left



                                    anchors.verticalCenter: parent.verticalCenter







                                    Image {



                                        id: iconFinishSetup



                                        source: "qrc:/MeguPackOptimizer/src/resources/settings.svg"



                                        anchors.fill: parent



                                        sourceSize.width: 16



                                        sourceSize.height: 16



                                        visible: false



                                    }



                                    ColorOverlay {



                                        anchors.fill: parent



                                        source: iconFinishSetup



                                        color: optimizerBackend.adsFinishSetupActive !== optimizerBackend.originalAdsFinishSetupActive ? Theme.accent : Theme.textSecondary



                                    }



                                }







                                Text {



                                    text: qsTr("Finish setting up your device")



                                    color: Theme.textPrimary



                                    font.family: Theme.fontFamily



                                    font.pixelSize: 12



                                    anchors.left: iconFinishSetupContainer.right



                                    anchors.leftMargin: 24



                                    anchors.verticalCenter: parent.verticalCenter



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







                // Privacy Panel



                AcrylicPanel {



                    id: privacyPanel



                    visible: root.currentSection === "telemetry"



                    width: parent.width



                    height: detailsExpanded ? privacyColumn.implicitHeight + 16 : 104



                    property bool detailsExpanded: false







                    Behavior on height {



                        NumberAnimation { duration: Theme.animNormal; easing.type: Easing.InOutQuad }



                    }







                    Column {



                        id: privacyColumn



                        anchors.left: parent.left



                        anchors.right: parent.right



                        anchors.top: parent.top



                        spacing: 16







                        // Header Row



                        Item {



                            id: privacyHeaderRow



                            anchors.left: parent.left



                            anchors.right: parent.right



                            anchors.leftMargin: 16



                            anchors.rightMargin: 16



                            height: 104







                            Rectangle {



                                id: privacyHeaderIconRect



                                width: 40



                                height: 40



                                radius: 10



                                color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)



                                anchors.left: parent.left



                                anchors.verticalCenter: parent.verticalCenter







                                Item {



                                    width: 20



                                    height: 20



                                    anchors.centerIn: parent



                                    Image {



                                        id: privacyPanel_iconImg



                                        source: "qrc:/MeguPackOptimizer/src/resources/privacy.svg"



                                        anchors.fill: parent



                                        sourceSize.width: 20



                                        sourceSize.height: 20



                                        visible: false



                                    }



                                    ColorOverlay {



                                        anchors.fill: privacyPanel_iconImg



                                        source: privacyPanel_iconImg



                                        color: Theme.accent



                                    }



                                }



                            }







                            Column {



                                id: privacyHeaderTexts



                                anchors.left: privacyHeaderIconRect.right



                                anchors.leftMargin: 12



                                anchors.right: privacyExpandBtn.left



                                anchors.rightMargin: 12



                                anchors.verticalCenter: parent.verticalCenter



                                spacing: 2







                                Row {



                                    spacing: 8



                                    Text {



                                        text: qsTr("Privacy")



                                        color: Theme.textPrimary



                                        font.family: Theme.fontFamily



                                        font.pixelSize: 16



                                        font.bold: true



                                        anchors.verticalCenter: parent.verticalCenter



                                    }



                                    ShowPathButton {



                                        anchors.verticalCenter: parent.verticalCenter



                                        onClicked: { optimizerBackend.showPath("privacy"); }



                                    }



                                    Rectangle {



                                        visible: root.privacyChanged



                                        height: 16



                                        width: selectedTextPrivacy.contentWidth + 10



                                        radius: 4



                                        color: Qt.rgba(Theme.success.r, Theme.success.g, Theme.success.b, 0.15)



                                        border.color: Theme.success



                                        border.width: 1



                                        anchors.verticalCenter: parent.verticalCenter



                                        Text {



                                            id: selectedTextPrivacy



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



                                    text: qsTr("Change privacy related settings that send data to Microsoft about your usage patterns.")



                                    color: Theme.textMuted



                                    font.family: Theme.fontFamily



                                    font.pixelSize: 12



                                    elide: Text.ElideRight



                                    width: parent.width



                                }



                            }







                            // Expand button on top right



                            Rectangle {



                                id: privacyExpandBtn



                                width: 32



                                height: 32



                                radius: 16



                                color: privacyExpandMouseArea.containsMouse ? Theme.accentDim : "transparent"



                                border.color: privacyExpandMouseArea.containsMouse ? Theme.accent : Theme.border



                                border.width: 1



                                anchors.right: parent.right



                                anchors.verticalCenter: parent.verticalCenter







                                Behavior on color { ColorAnimation { duration: Theme.animFast } }



                                Behavior on border.color { ColorAnimation { duration: Theme.animFast } }







                                Item {



                                    width: 14



                                    height: 14



                                    anchors.centerIn: parent



                                    rotation: privacyPanel.detailsExpanded ? 180 : 0



                                    Behavior on rotation { NumberAnimation { duration: Theme.animFast } }







                                    Image {



                                        id: privacyExpandArrowImg



                                        source: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"



                                        anchors.fill: parent



                                        sourceSize.width: 14



                                        sourceSize.height: 14



                                        visible: false



                                    }



                                    ColorOverlay {



                                        anchors.fill: privacyExpandArrowImg



                                        source: privacyExpandArrowImg



                                        color: privacyExpandMouseArea.containsMouse ? Theme.accent : Theme.textSecondary



                                    }



                                }







                                MouseArea {



                                    id: privacyExpandMouseArea



                                    anchors.fill: parent



                                    hoverEnabled: true



                                    cursorShape: Qt.PointingHandCursor



                                    onClicked: {



                                        privacyPanel.detailsExpanded = !privacyPanel.detailsExpanded;



                                    }



                                }



                            }



                        }







                        // Separator line



                        Rectangle {



                            height: 1



                            anchors.left: parent.left



                            anchors.right: parent.right



                            anchors.leftMargin: 16



                            anchors.rightMargin: 16



                            color: Theme.border



                            opacity: privacyPanel.detailsExpanded ? 0.2 : 0.0



                            Behavior on opacity { NumberAnimation { duration: Theme.animFast } }



                        }







                        // Expansion Container listing the 11 options



                        Column {



                            id: privacyDetailsContainer



                            anchors.left: parent.left



                            anchors.right: parent.right



                            anchors.leftMargin: 28



                            anchors.rightMargin: 16



                            spacing: 4



                            visible: privacyPanel.detailsExpanded



                            opacity: privacyPanel.detailsExpanded ? 1.0 : 0.0



                            Behavior on opacity { NumberAnimation { duration: Theme.animFast } }







                            // 1. Location



                            Item {



                                anchors.left: parent.left



                                anchors.right: parent.right



                                height: 40







                                Item {



                                    id: iconLocationContainer



                                    width: 16



                                    height: 16



                                    anchors.left: parent.left



                                    anchors.verticalCenter: parent.verticalCenter







                                    Image {



                                        id: iconLocation



                                        source: "qrc:/MeguPackOptimizer/src/resources/location.svg"



                                        anchors.fill: parent



                                        sourceSize.width: 16



                                        sourceSize.height: 16



                                        visible: false



                                    }



                                    ColorOverlay {



                                        anchors.fill: parent



                                        source: iconLocation



                                        color: optimizerBackend.privacyLocationActive !== optimizerBackend.originalPrivacyLocationActive ? Theme.accent : Theme.textSecondary



                                    }



                                }







                                Text {



                                    text: qsTr("Location")



                                    color: Theme.textPrimary



                                    font.family: Theme.fontFamily



                                    font.pixelSize: 12



                                    anchors.left: iconLocationContainer.right



                                    anchors.leftMargin: 24



                                    anchors.verticalCenter: parent.verticalCenter



                                }







                                MeguSwitch {



                                    checked: optimizerBackend.privacyLocationActive



                                    anchors.right: parent.right



                                    anchors.verticalCenter: parent.verticalCenter



                                    onToggled: (val) => { optimizerBackend.privacyLocationActive = val; }



                                }



                            }







                            // 2. Telemetry



                            Item {



                                anchors.left: parent.left



                                anchors.right: parent.right



                                height: 40







                                Item {



                                    id: iconPrivacyTelemetryContainer



                                    width: 16



                                    height: 16



                                    anchors.left: parent.left



                                    anchors.verticalCenter: parent.verticalCenter







                                    Image {



                                        id: iconPrivacyTelemetry



                                        source: "qrc:/MeguPackOptimizer/src/resources/telemetry.svg"



                                        anchors.fill: parent



                                        sourceSize.width: 16



                                        sourceSize.height: 16



                                        visible: false



                                    }



                                    ColorOverlay {



                                        anchors.fill: parent



                                        source: iconPrivacyTelemetry



                                        color: optimizerBackend.privacyTelemetryActive !== optimizerBackend.originalPrivacyTelemetryActive ? Theme.accent : Theme.textSecondary



                                    }



                                }







                                Text {



                                    text: qsTr("Telemetry")



                                    color: Theme.textPrimary



                                    font.family: Theme.fontFamily



                                    font.pixelSize: 12



                                    anchors.left: iconPrivacyTelemetryContainer.right



                                    anchors.leftMargin: 24



                                    anchors.verticalCenter: parent.verticalCenter



                                }







                                MeguSwitch {



                                    checked: optimizerBackend.privacyTelemetryActive



                                    anchors.right: parent.right



                                    anchors.verticalCenter: parent.verticalCenter



                                    onToggled: (val) => { optimizerBackend.privacyTelemetryActive = val; }



                                }



                            }







                            // 3. CEIP



                            Item {



                                anchors.left: parent.left



                                anchors.right: parent.right



                                height: 40







                                Item {



                                    id: iconPrivacyCeipContainer



                                    width: 16



                                    height: 16



                                    anchors.left: parent.left



                                    anchors.verticalCenter: parent.verticalCenter







                                    Image {



                                        id: iconPrivacyCeip



                                        source: "qrc:/MeguPackOptimizer/src/resources/telemetry.svg"



                                        anchors.fill: parent



                                        sourceSize.width: 16



                                        sourceSize.height: 16



                                        visible: false



                                    }



                                    ColorOverlay {



                                        anchors.fill: parent



                                        source: iconPrivacyCeip



                                        color: optimizerBackend.privacyCeipActive !== optimizerBackend.originalPrivacyCeipActive ? Theme.accent : Theme.textSecondary



                                    }



                                }







                                Text {



                                    text: qsTr("CEIP")



                                    color: Theme.textPrimary



                                    font.family: Theme.fontFamily



                                    font.pixelSize: 12



                                    anchors.left: iconPrivacyCeipContainer.right



                                    anchors.leftMargin: 24



                                    anchors.verticalCenter: parent.verticalCenter



                                }







                                MeguSwitch {



                                    checked: optimizerBackend.privacyCeipActive



                                    anchors.right: parent.right



                                    anchors.verticalCenter: parent.verticalCenter



                                    onToggled: (val) => { optimizerBackend.privacyCeipActive = val; }



                                }



                            }







                            // 4. Apps telemetry



                            Item {



                                anchors.left: parent.left



                                anchors.right: parent.right



                                height: 40







                                Item {



                                    id: iconPrivacyAppsTelemetryContainer



                                    width: 16



                                    height: 16



                                    anchors.left: parent.left



                                    anchors.verticalCenter: parent.verticalCenter







                                    Image {



                                        id: iconPrivacyAppsTelemetry



                                        source: "qrc:/MeguPackOptimizer/src/resources/telemetry.svg"



                                        anchors.fill: parent



                                        sourceSize.width: 16



                                        sourceSize.height: 16



                                        visible: false



                                    }



                                    ColorOverlay {



                                        anchors.fill: parent



                                        source: iconPrivacyAppsTelemetry



                                        color: optimizerBackend.privacyAppsTelemetryActive !== optimizerBackend.originalPrivacyAppsTelemetryActive ? Theme.accent : Theme.textSecondary



                                    }



                                }







                                Text {



                                    text: qsTr("Apps telemetry")



                                    color: Theme.textPrimary



                                    font.family: Theme.fontFamily



                                    font.pixelSize: 12



                                    anchors.left: iconPrivacyAppsTelemetryContainer.right



                                    anchors.leftMargin: 24



                                    anchors.verticalCenter: parent.verticalCenter



                                }







                                MeguSwitch {



                                    checked: optimizerBackend.privacyAppsTelemetryActive



                                    anchors.right: parent.right



                                    anchors.verticalCenter: parent.verticalCenter



                                    onToggled: (val) => { optimizerBackend.privacyAppsTelemetryActive = val; }



                                }



                            }







                            // 5. App launches



                            Item {



                                anchors.left: parent.left



                                anchors.right: parent.right



                                height: 40







                                Item {



                                    id: iconPrivacyAppLaunchesContainer



                                    width: 16



                                    height: 16



                                    anchors.left: parent.left



                                    anchors.verticalCenter: parent.verticalCenter







                                    Image {



                                        id: iconPrivacyAppLaunches



                                        source: "qrc:/MeguPackOptimizer/src/resources/settings.svg"



                                        anchors.fill: parent



                                        sourceSize.width: 16



                                        sourceSize.height: 16



                                        visible: false



                                    }



                                    ColorOverlay {



                                        anchors.fill: parent



                                        source: iconPrivacyAppLaunches



                                        color: optimizerBackend.privacyAppLaunchesActive !== optimizerBackend.originalPrivacyAppLaunchesActive ? Theme.accent : Theme.textSecondary



                                    }



                                }







                                Text {



                                    text: qsTr("App launches")



                                    color: Theme.textPrimary



                                    font.family: Theme.fontFamily



                                    font.pixelSize: 12



                                    anchors.left: iconPrivacyAppLaunchesContainer.right



                                    anchors.leftMargin: 24



                                    anchors.verticalCenter: parent.verticalCenter



                                }







                                MeguSwitch {



                                    checked: optimizerBackend.privacyAppLaunchesActive



                                    anchors.right: parent.right



                                    anchors.verticalCenter: parent.verticalCenter



                                    onToggled: (val) => { optimizerBackend.privacyAppLaunchesActive = val; }



                                }



                            }







                            // 6. Improve inking & typing



                            Item {



                                anchors.left: parent.left



                                anchors.right: parent.right



                                height: 40







                                Item {



                                    id: iconPrivacyImproveInkingContainer



                                    width: 16



                                    height: 16



                                    anchors.left: parent.left



                                    anchors.verticalCenter: parent.verticalCenter







                                    Image {



                                        id: iconPrivacyImproveInking



                                        source: "qrc:/MeguPackOptimizer/src/resources/microphone.svg"



                                        anchors.fill: parent



                                        sourceSize.width: 16



                                        sourceSize.height: 16



                                        visible: false



                                    }



                                    ColorOverlay {



                                        anchors.fill: parent



                                        source: iconPrivacyImproveInking



                                        color: optimizerBackend.privacyImproveInkingActive !== optimizerBackend.originalPrivacyImproveInkingActive ? Theme.accent : Theme.textSecondary



                                    }



                                }







                                Text {



                                    text: qsTr("Improve inking & typing")



                                    color: Theme.textPrimary



                                    font.family: Theme.fontFamily



                                    font.pixelSize: 12



                                    anchors.left: iconPrivacyImproveInkingContainer.right



                                    anchors.leftMargin: 24



                                    anchors.verticalCenter: parent.verticalCenter



                                }







                                MeguSwitch {



                                    checked: optimizerBackend.privacyImproveInkingActive



                                    anchors.right: parent.right



                                    anchors.verticalCenter: parent.verticalCenter



                                    onToggled: (val) => { optimizerBackend.privacyImproveInkingActive = val; }



                                }



                            }







                            // 7. Personalize inking & typing



                            Item {



                                anchors.left: parent.left



                                anchors.right: parent.right



                                height: 40







                                Item {



                                    id: iconPrivacyPersonalizeInkingContainer



                                    width: 16



                                    height: 16



                                    anchors.left: parent.left



                                    anchors.verticalCenter: parent.verticalCenter







                                    Image {



                                        id: iconPrivacyPersonalizeInking



                                        source: "qrc:/MeguPackOptimizer/src/resources/microphone.svg"



                                        anchors.fill: parent



                                        sourceSize.width: 16



                                        sourceSize.height: 16



                                        visible: false



                                    }



                                    ColorOverlay {



                                        anchors.fill: parent



                                        source: iconPrivacyPersonalizeInking



                                        color: optimizerBackend.privacyPersonalizeInkingActive !== optimizerBackend.originalPrivacyPersonalizeInkingActive ? Theme.accent : Theme.textSecondary



                                    }



                                }







                                Text {



                                    text: qsTr("Personalize inking & typing")



                                    color: Theme.textPrimary



                                    font.family: Theme.fontFamily



                                    font.pixelSize: 12



                                    anchors.left: iconPrivacyPersonalizeInkingContainer.right



                                    anchors.leftMargin: 24



                                    anchors.verticalCenter: parent.verticalCenter



                                }







                                MeguSwitch {



                                    checked: optimizerBackend.privacyPersonalizeInkingActive



                                    anchors.right: parent.right



                                    anchors.verticalCenter: parent.verticalCenter



                                    onToggled: (val) => { optimizerBackend.privacyPersonalizeInkingActive = val; }



                                }



                            }







                            // 8. Error reporting



                            Item {



                                anchors.left: parent.left



                                anchors.right: parent.right



                                height: 40







                                Item {



                                    id: iconPrivacyErrorReportingContainer



                                    width: 16



                                    height: 16



                                    anchors.left: parent.left



                                    anchors.verticalCenter: parent.verticalCenter







                                    Image {



                                        id: iconPrivacyErrorReporting



                                        source: "qrc:/MeguPackOptimizer/src/resources/warning.svg"



                                        anchors.fill: parent



                                        sourceSize.width: 16



                                        sourceSize.height: 16



                                        visible: false



                                    }



                                    ColorOverlay {



                                        anchors.fill: parent



                                        source: iconPrivacyErrorReporting



                                        color: optimizerBackend.privacyErrorReportingActive !== optimizerBackend.originalPrivacyErrorReportingActive ? Theme.accent : Theme.textSecondary



                                    }



                                }







                                Text {



                                    text: qsTr("Error reporting")



                                    color: Theme.textPrimary



                                    font.family: Theme.fontFamily



                                    font.pixelSize: 12



                                    anchors.left: iconPrivacyErrorReportingContainer.right



                                    anchors.leftMargin: 24



                                    anchors.verticalCenter: parent.verticalCenter



                                }







                                MeguSwitch {



                                    checked: optimizerBackend.privacyErrorReportingActive



                                    anchors.right: parent.right



                                    anchors.verticalCenter: parent.verticalCenter



                                    onToggled: (val) => { optimizerBackend.privacyErrorReportingActive = val; }



                                }



                            }







                            // 9. Camera on lock screen



                            Item {



                                anchors.left: parent.left



                                anchors.right: parent.right



                                height: 40







                                Item {



                                    id: iconPrivacyLockScreenCameraContainer



                                    width: 16



                                    height: 16



                                    anchors.left: parent.left



                                    anchors.verticalCenter: parent.verticalCenter







                                    Image {



                                        id: iconPrivacyLockScreenCamera



                                        source: "qrc:/MeguPackOptimizer/src/resources/camera.svg"



                                        anchors.fill: parent



                                        sourceSize.width: 16



                                        sourceSize.height: 16



                                        visible: false



                                    }



                                    ColorOverlay {



                                        anchors.fill: parent



                                        source: iconPrivacyLockScreenCamera



                                        color: optimizerBackend.privacyLockScreenCameraActive !== optimizerBackend.originalPrivacyLockScreenCameraActive ? Theme.accent : Theme.textSecondary



                                    }



                                }







                                Text {



                                    text: qsTr("Camera on lock screen")



                                    color: Theme.textPrimary



                                    font.family: Theme.fontFamily



                                    font.pixelSize: 12



                                    anchors.left: iconPrivacyLockScreenCameraContainer.right



                                    anchors.leftMargin: 24



                                    anchors.verticalCenter: parent.verticalCenter



                                }







                                MeguSwitch {



                                    checked: optimizerBackend.privacyLockScreenCameraActive



                                    anchors.right: parent.right



                                    anchors.verticalCenter: parent.verticalCenter



                                    onToggled: (val) => { optimizerBackend.privacyLockScreenCameraActive = val; }



                                }



                            }







                            // 10. Camera indicator



                            Item {



                                anchors.left: parent.left



                                anchors.right: parent.right



                                height: 40







                                Item {



                                    id: iconPrivacyCameraIndicatorContainer



                                    width: 16



                                    height: 16



                                    anchors.left: parent.left



                                    anchors.verticalCenter: parent.verticalCenter







                                    Image {



                                        id: iconPrivacyCameraIndicator



                                        source: "qrc:/MeguPackOptimizer/src/resources/camera.svg"



                                        anchors.fill: parent



                                        sourceSize.width: 16



                                        sourceSize.height: 16



                                        visible: false



                                    }



                                    ColorOverlay {



                                        anchors.fill: parent



                                        source: iconPrivacyCameraIndicator



                                        color: optimizerBackend.privacyCameraIndicatorActive !== optimizerBackend.originalPrivacyCameraIndicatorActive ? Theme.accent : Theme.textSecondary



                                    }



                                }







                                Text {



                                    text: qsTr("Camera indicator")



                                    color: Theme.textPrimary



                                    font.family: Theme.fontFamily



                                    font.pixelSize: 12



                                    anchors.left: iconPrivacyCameraIndicatorContainer.right



                                    anchors.leftMargin: 24



                                    anchors.verticalCenter: parent.verticalCenter



                                }







                                MeguSwitch {



                                    checked: optimizerBackend.privacyCameraIndicatorActive



                                    anchors.right: parent.right



                                    anchors.verticalCenter: parent.verticalCenter



                                    onToggled: (val) => { optimizerBackend.privacyCameraIndicatorActive = val; }



                                }



                            }







                            // 11. Online speech



                            Item {



                                anchors.left: parent.left



                                anchors.right: parent.right



                                height: 40







                                Item {



                                    id: iconPrivacyOnlineSpeechContainer



                                    width: 16



                                    height: 16



                                    anchors.left: parent.left



                                    anchors.verticalCenter: parent.verticalCenter







                                    Image {



                                        id: iconPrivacyOnlineSpeech



                                        source: "qrc:/MeguPackOptimizer/src/resources/microphone.svg"



                                        anchors.fill: parent



                                        sourceSize.width: 16



                                        sourceSize.height: 16



                                        visible: false



                                    }



                                    ColorOverlay {



                                        anchors.fill: parent



                                        source: iconPrivacyOnlineSpeech



                                        color: optimizerBackend.privacyOnlineSpeechActive !== optimizerBackend.originalPrivacyOnlineSpeechActive ? Theme.accent : Theme.textSecondary



                                    }



                                }







                                Text {



                                    text: qsTr("Online speech")



                                    color: Theme.textPrimary



                                    font.family: Theme.fontFamily



                                    font.pixelSize: 12



                                    anchors.left: iconPrivacyOnlineSpeechContainer.right



                                    anchors.leftMargin: 24



                                    anchors.verticalCenter: parent.verticalCenter



                                }







                                MeguSwitch {



                                    checked: optimizerBackend.privacyOnlineSpeechActive



                                    anchors.right: parent.right



                                    anchors.verticalCenter: parent.verticalCenter



                                    onToggled: (val) => { optimizerBackend.privacyOnlineSpeechActive = val; }



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



                    height: 104







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



                                    font.pixelSize: 16



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



                                font.pixelSize: 12



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



                    height: 104







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



                                    font.pixelSize: 16



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



                                font.pixelSize: 12



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















                // Desktop Customization Panel



                AcrylicPanel {



                    id: desktopCustomizationPanel



                    width: parent.width



                    height: 104







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



                                            id: desktopPanel_iconImg



                                            source: "qrc:/MeguPackOptimizer/src/resources/monitor.svg"



                                            anchors.fill: parent



                                            sourceSize.width: 20



                                            sourceSize.height: 20



                                            visible: false



                                        }



                                        ColorOverlay {



                                            anchors.fill: desktopPanel_iconImg



                                            source: desktopPanel_iconImg



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



                                            text: qsTr("Desktop Customization")



                                            color: Theme.textPrimary



                                            font.family: Theme.fontFamily



                                            font.pixelSize: 16



                                            font.bold: true



                                            anchors.verticalCenter: parent.verticalCenter



                                        }



                                        Rectangle {



                                            visible: root.desktopChanged



                                            height: 16



                                            width: selectedTextDesktop.contentWidth + 10



                                            radius: 4



                                            color: Qt.rgba(Theme.success.r, Theme.success.g, Theme.success.b, 0.15)



                                            border.color: Theme.success



                                            border.width: 1



                                            anchors.verticalCenter: parent.verticalCenter



                                            Text {



                                                id: selectedTextDesktop



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



                                        text: qsTr("Customize desktop icons, taskbar elements, window shake, and wallpaper quality.")



                                        color: Theme.textMuted



                                        font.family: Theme.fontFamily



                                        font.pixelSize: 12



                                    }



                                }



                            }







                            Row {



                                anchors.right: parent.right



                                anchors.verticalCenter: parent.verticalCenter



                                spacing: 16







                                // Arrow button to open drawer



                                Rectangle {



                                    width: 32



                                    height: 32



                                    radius: 8



                                    color: desktopArrowMouse.containsMouse ? Theme.buttonBgHover : "transparent"



                                    border.color: desktopArrowMouse.containsMouse ? Theme.borderHover : "transparent"



                                    border.width: 1



                                    anchors.verticalCenter: parent.verticalCenter







                                    Behavior on color { ColorAnimation { duration: Theme.animFast } }







                                    Item {



                                        anchors.fill: parent



                                        Image {



                                            id: desktopArrowIcon



                                            source: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"



                                            anchors.centerIn: parent



                                            width: 12



                                            height: 12



                                            visible: false



                                        }



                                        ColorOverlay {



                                            anchors.fill: desktopArrowIcon



                                            source: desktopArrowIcon



                                            color: desktopArrowMouse.containsMouse ? Theme.accent : Theme.textSecondary



                                        }



                                    }







                                    MouseArea {



                                        id: desktopArrowMouse



                                        anchors.fill: parent



                                        hoverEnabled: true



                                        cursorShape: Qt.PointingHandCursor



                                        onClicked: {



                                            root.activeDrawer = "desktopCustomization";



                                        }



                                    }



                                }



                            }



                        }



                    }



                }







                // Clipboard History Panel



                AcrylicPanel {



                    id: clipboardHistoryPanel



                    width: parent.width



                    height: 104







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



                                            font.pixelSize: 16



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



                                        font.pixelSize: 12



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



                    height: 104



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



                                            font.pixelSize: 16



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



                                        font.pixelSize: 12



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



                            visible: false



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



                                    font.pixelSize: 12



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



                    height: 104



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



                                            font.pixelSize: 16



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



                                        font.pixelSize: 12



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



                            visible: false



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



                                    font.pixelSize: 12



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







                // More Rights Panel (More Privileges)



                AcrylicPanel {



                    id: moreRightsPanel



                    width: parent.width



                    height: visible ? 84 : 0



                    visible: settingsBackend.showExpertFeatures







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



                                            id: moreRightsPanel_iconImg



                                            source: "qrc:/MeguPackOptimizer/src/resources/development.svg"



                                            anchors.fill: parent



                                            sourceSize.width: 20



                                            sourceSize.height: 20



                                            visible: false



                                        }



                                        ColorOverlay {



                                            anchors.fill: moreRightsPanel_iconImg



                                            source: moreRightsPanel_iconImg



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



                                            text: qsTr("More Privileges")



                                            color: Theme.textPrimary



                                            font.family: Theme.fontFamily



                                            font.pixelSize: 16



                                            font.bold: true



                                            anchors.verticalCenter: parent.verticalCenter



                                        }



                                        Rectangle {



                                            height: 16



                                            width: expertBadgeText.contentWidth + 10



                                            radius: 4



                                            color: Qt.rgba(Theme.warning.r, Theme.warning.g, Theme.warning.b, 0.15)



                                            border.color: Theme.warning



                                            border.width: 1



                                            anchors.verticalCenter: parent.verticalCenter



                                            Text {



                                                id: expertBadgeText



                                                text: qsTr("Expert feature")



                                                color: Theme.warning



                                                font.family: Theme.fontFamily



                                                font.pixelSize: 8



                                                font.bold: true



                                                anchors.centerIn: parent



                                            }



                                        }



                                        Rectangle {



                                            visible: root.moreRightsChanged



                                            height: 16



                                            width: selectedTextMoreRights.contentWidth + 10



                                            radius: 4



                                            color: Qt.rgba(Theme.success.r, Theme.success.g, Theme.success.b, 0.15)



                                            border.color: Theme.success



                                            border.width: 1



                                            anchors.verticalCenter: parent.verticalCenter



                                            Text {



                                                id: selectedTextMoreRights



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



                                        text: qsTr("Manage advanced system privileges and Windows security settings.")



                                        color: Theme.textMuted



                                        font.family: Theme.fontFamily



                                        font.pixelSize: 12



                                    }



                                }



                            }







                            Row {



                                anchors.right: parent.right



                                anchors.verticalCenter: parent.verticalCenter



                                spacing: 16







                                // Arrow button to open drawer



                                Rectangle {



                                    width: 32



                                    height: 32



                                    radius: 8



                                    color: moreRightsArrowMouse.containsMouse ? Theme.buttonBgHover : "transparent"



                                    border.color: moreRightsArrowMouse.containsMouse ? Theme.borderHover : "transparent"



                                    border.width: 1



                                    anchors.verticalCenter: parent.verticalCenter







                                    Behavior on color { ColorAnimation { duration: Theme.animFast } }







                                    Item {



                                        anchors.fill: parent



                                        Image {



                                            id: moreRightsArrowIcon



                                            source: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"



                                            anchors.centerIn: parent



                                            width: 12



                                            height: 12



                                            visible: false



                                        }



                                        ColorOverlay {



                                            anchors.fill: moreRightsArrowIcon



                                            source: moreRightsArrowIcon



                                            color: moreRightsArrowMouse.containsMouse ? Theme.accent : Theme.textSecondary



                                        }



                                    }







                                    MouseArea {



                                        id: moreRightsArrowMouse



                                        anchors.fill: parent



                                        hoverEnabled: true



                                        cursorShape: Qt.PointingHandCursor



                                        onClicked: {



                                            root.activeDrawer = "moreRights";



                                        }



                                    }



                                }



                            }



                        }



                    }



                }







                // File Explorer Customization Panel



                AcrylicPanel {



                    id: explorerCustomizationPanel



                    width: parent.width



                    height: 104







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



                                            id: explorerPanel_iconImg



                                            source: "qrc:/MeguPackOptimizer/src/resources/folder.svg"



                                            anchors.fill: parent



                                            sourceSize.width: 20



                                            sourceSize.height: 20



                                            visible: false



                                        }



                                        ColorOverlay {



                                            anchors.fill: explorerPanel_iconImg



                                            source: explorerPanel_iconImg



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



                                            text: qsTr("File Explorer Customization")



                                            color: Theme.textPrimary



                                            font.family: Theme.fontFamily



                                            font.pixelSize: 16



                                            font.bold: true



                                            anchors.verticalCenter: parent.verticalCenter



                                        }



                                        Rectangle {



                                            visible: root.explorerChanged



                                            height: 16



                                            width: selectedTextExplorer.contentWidth + 10



                                            radius: 4



                                            color: Qt.rgba(Theme.success.r, Theme.success.g, Theme.success.b, 0.15)



                                            border.color: Theme.success



                                            border.width: 1



                                            anchors.verticalCenter: parent.verticalCenter



                                            Text {



                                                id: selectedTextExplorer



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



                                        text: qsTr("Customize File Explorer settings, navigation pane, and system view defaults.")



                                        color: Theme.textMuted



                                        font.family: Theme.fontFamily



                                        font.pixelSize: 12



                                    }



                                }



                            }







                            Row {



                                anchors.right: parent.right



                                anchors.verticalCenter: parent.verticalCenter



                                spacing: 16







                                // Arrow button to open drawer



                                Rectangle {



                                    width: 32



                                    height: 32



                                    radius: 8



                                    color: explorerArrowMouse.containsMouse ? Theme.buttonBgHover : "transparent"



                                    border.color: explorerArrowMouse.containsMouse ? Theme.borderHover : "transparent"



                                    border.width: 1



                                    anchors.verticalCenter: parent.verticalCenter







                                    Behavior on color { ColorAnimation { duration: Theme.animFast } }







                                    Item {



                                        anchors.fill: parent



                                        Image {



                                            id: explorerArrowIcon



                                            source: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"



                                            anchors.centerIn: parent



                                            width: 12



                                            height: 12



                                            visible: false



                                        }



                                        ColorOverlay {



                                            anchors.fill: explorerArrowIcon



                                            source: explorerArrowIcon



                                            color: explorerArrowMouse.containsMouse ? Theme.accent : Theme.textSecondary



                                        }



                                    }







                                    MouseArea {



                                        id: explorerArrowMouse



                                        anchors.fill: parent



                                        hoverEnabled: true



                                        cursorShape: Qt.PointingHandCursor



                                        onClicked: {



                                            root.activeDrawer = "explorerCustomization";



                                        }



                                    }



                                }



                            }



                        }



                    }



                }







                // Start Menu Customization Panel



                AcrylicPanel {



                    id: startMenuCustomizationPanel



                    width: parent.width



                    height: 104







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



                                            id: startMenuPanel_iconImg



                                            source: "qrc:/MeguPackOptimizer/src/resources/settings.svg"



                                            anchors.fill: parent



                                            sourceSize.width: 20



                                            sourceSize.height: 20



                                            visible: false



                                        }



                                        ColorOverlay {



                                            anchors.fill: startMenuPanel_iconImg



                                            source: startMenuPanel_iconImg



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



                                            text: qsTr("Start Menu Customization")



                                            color: Theme.textPrimary



                                            font.family: Theme.fontFamily



                                            font.pixelSize: 16



                                            font.bold: true



                                            anchors.verticalCenter: parent.verticalCenter



                                        }



                                        Rectangle {



                                            visible: root.startMenuChanged



                                            height: 16



                                            width: selectedTextStartMenu.contentWidth + 10



                                            radius: 4



                                            color: Qt.rgba(Theme.success.r, Theme.success.g, Theme.success.b, 0.15)



                                            border.color: Theme.success



                                            border.width: 1



                                            anchors.verticalCenter: parent.verticalCenter



                                            Text {



                                                id: selectedTextStartMenu



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



                                        text: qsTr("Customize Start Menu search web results, apps autoinstall, notifications, and power menu.")



                                        color: Theme.textMuted



                                        font.family: Theme.fontFamily



                                        font.pixelSize: 12



                                    }



                                }



                            }







                            Row {



                                anchors.right: parent.right



                                anchors.verticalCenter: parent.verticalCenter



                                spacing: 16







                                // Arrow button to open drawer



                                Rectangle {



                                    width: 32



                                    height: 32



                                    radius: 8



                                    color: startMenuArrowMouse.containsMouse ? Theme.buttonBgHover : "transparent"



                                    border.color: startMenuArrowMouse.containsMouse ? Theme.borderHover : "transparent"



                                    border.width: 1



                                    anchors.verticalCenter: parent.verticalCenter







                                    Behavior on color { ColorAnimation { duration: Theme.animFast } }







                                    Item {



                                        anchors.fill: parent



                                        Image {



                                            id: startMenuArrowIcon



                                            source: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"



                                            anchors.centerIn: parent



                                            width: 12



                                            height: 12



                                            visible: false



                                        }



                                        ColorOverlay {



                                            anchors.fill: startMenuArrowIcon



                                            source: startMenuArrowIcon



                                            color: startMenuArrowMouse.containsMouse ? Theme.accent : Theme.textSecondary



                                        }



                                    }







                                    MouseArea {



                                        id: startMenuArrowMouse



                                        anchors.fill: parent



                                        hoverEnabled: true



                                        cursorShape: Qt.PointingHandCursor



                                        onClicked: {



                                            root.activeDrawer = "startMenuCustomization";



                                        }



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



                    height: 104







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



                                    font.pixelSize: 16



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



                                font.pixelSize: 12



                            }



                        }



                    }







                    Row {
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 16

                        // Hibernation Size Button
                        Rectangle {
                            id: hiberSizeBtn
                            width: 52
                            height: 28
                            radius: 6
                            color: isEnabled ? (hiberSizeMouse.containsMouse ? "#1AFFFFFF" : "#0AFFFFFF") : "#03FFFFFF"
                            border.color: isEnabled ? (hiberSizeMouse.containsMouse ? Theme.accent : Theme.border) : Theme.border
                            border.width: 1
                            opacity: isEnabled ? 1.0 : 0.4
                            anchors.verticalCenter: parent.verticalCenter
                            
                            property bool isEnabled: optimizerBackend.hibernationActive

                            Behavior on color { ColorAnimation { duration: Theme.animFast } }
                            Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
                            Behavior on opacity { NumberAnimation { duration: Theme.animFast } }

                            Text {
                                anchors.centerIn: parent
                                text: hiberSizeBtn.isEnabled ? (optimizerBackend.hibernationSize + "%") : "0%"
                                color: hiberSizeBtn.isEnabled ? Theme.textPrimary : Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                font.bold: true
                            }

                            MouseArea {
                                id: hiberSizeMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                enabled: hiberSizeBtn.isEnabled
                                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: {
                                    var current = optimizerBackend.hibernationSize;
                                    var next = 40;
                                    if (current === 40) next = 50;
                                    else if (current === 50) next = 75;
                                    else if (current === 75) next = 100;
                                    else next = 40;
                                    optimizerBackend.hibernationSize = next;
                                }
                            }
                        }

                        MeguSwitch {
                            checked: optimizerBackend.hibernationActive
                            anchors.verticalCenter: parent.verticalCenter
                            onToggled: (isChecked) => {
                                optimizerBackend.hibernationActive = isChecked;
                            }
                        }
                    }



                }


                // Fast Startup Card
                // Fast Startup Card
                AcrylicPanel {
                    id: fastStartupPanel
                    width: parent.width
                    height: 104

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
                            opacity: optimizerBackend.hibernationActive ? 1.0 : 0.4
                            Behavior on opacity { NumberAnimation { duration: Theme.animFast } }

                            Item {
                                width: 20
                                height: 20
                                anchors.centerIn: parent
                                Image {
                                    id: fastStartupPanel_iconImg
                                    source: "qrc:/MeguPackOptimizer/src/resources/power.svg"
                                    anchors.fill: parent
                                    sourceSize.width: 20
                                    sourceSize.height: 20
                                    visible: false
                                }
                                ColorOverlay {
                                    anchors.fill: fastStartupPanel_iconImg
                                    source: fastStartupPanel_iconImg
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
                                    text: qsTr("Fast startup")
                                    color: Theme.textPrimary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 16
                                    font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                    opacity: optimizerBackend.hibernationActive ? 1.0 : 0.4
                                    Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
                                }
                                ShowPathButton {
                                    anchors.verticalCenter: parent.verticalCenter
                                    enabled: optimizerBackend.hibernationActive
                                    opacity: enabled ? 1.0 : 0.4
                                    Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
                                    onClicked: { optimizerBackend.showPath("fastStartup"); }
                                }
                                Rectangle {
                                    visible: root.fastStartupChanged
                                    height: 16
                                    width: selectedTextFastStart.contentWidth + 10
                                    radius: 4
                                    color: Qt.rgba(Theme.success.r, Theme.success.g, Theme.success.b, 0.15)
                                    border.color: Theme.success
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        id: selectedTextFastStart
                                        text: qsTr("Selected for application")
                                        color: Theme.success
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 8
                                        font.bold: true
                                        anchors.centerIn: parent
                                    }
                                }
                            }

                            // Description when Hibernation is enabled
                            Text {
                                text: qsTr("Allows the device to open faster after a shutdown, reducing up to 50% of boot-time")
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                visible: optimizerBackend.hibernationActive
                            }

                            // Warning and Eye when Hibernation is disabled
                            Row {
                                spacing: 8
                                visible: !optimizerBackend.hibernationActive

                                Item {
                                    width: 14
                                    height: 14
                                    anchors.verticalCenter: parent.verticalCenter
                                    Image {
                                        id: fastStartupWarningIcon
                                        source: "qrc:/MeguPackOptimizer/src/resources/warning.svg"
                                        anchors.fill: parent
                                        sourceSize.width: 14
                                        sourceSize.height: 14
                                        visible: false
                                    }
                                    ColorOverlay {
                                        anchors.fill: fastStartupWarningIcon
                                        source: fastStartupWarningIcon
                                        color: Theme.warning
                                    }
                                }

                                Text {
                                    text: qsTr("To enable Fast startup, system hibernation must be enabled.")
                                    color: Theme.warning
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 12
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                // Eye / Locate button
                                Rectangle {
                                    width: 24
                                    height: 20
                                    radius: 4
                                    color: fastStartupEyeMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15) : "transparent"
                                    border.color: fastStartupEyeMouse.containsMouse ? Theme.accent : "transparent"
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Behavior on color { ColorAnimation { duration: Theme.animFast } }
                                    Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                                    Item {
                                        width: 14
                                        height: 14
                                        anchors.centerIn: parent
                                        Image {
                                            id: fastStartupEyeIconImg
                                            source: "qrc:/MeguPackOptimizer/src/resources/eye.svg"
                                            anchors.fill: parent
                                            sourceSize.width: 14
                                            sourceSize.height: 14
                                            visible: false
                                        }
                                        ColorOverlay {
                                            anchors.fill: fastStartupEyeIconImg
                                            source: fastStartupEyeIconImg
                                            color: fastStartupEyeMouse.containsMouse ? Theme.accent : Theme.textSecondary
                                        }
                                    }

                                    MouseArea {
                                        id: fastStartupEyeMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            // Scroll to and highlight hibernationPanel
                                            var panel = hibernationPanel;
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
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 16

                        MeguSwitch {
                            checked: optimizerBackend.fastStartupActive
                            enabled: optimizerBackend.hibernationActive
                            opacity: enabled ? 1.0 : 0.4
                            Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
                            anchors.verticalCenter: parent.verticalCenter
                            onToggled: (isChecked) => {
                                optimizerBackend.fastStartupActive = isChecked;
                            }
                        }
                    }
                }







                // Page File Card



                AcrylicPanel {



                    id: pageFilePanel



                    width: parent.width



                    height: 104



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



                                    font.pixelSize: 16



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



                                text: !root.isPagefileInputValid ? 



                                          (optimizerBackend.pagefileMin > optimizerBackend.pagefileMax ? 



                                              qsTr("Warning: Minimum size cannot be greater than maximum size!") : 



                                              (optimizerBackend.pagefileMin < 1024 || optimizerBackend.pagefileMax < 1024 || optimizerBackend.pagefileMin > 99999 || optimizerBackend.pagefileMax > 99999) ?



                                                  qsTr("Warning: Size must be between 1024 and 99999 MB!") :



                                                  qsTr("Error: Not enough disk space! C: drive will be overfilled.")) :



                                      root.isPagefileSpaceLow ? 



                                          qsTr("Warning: C: drive will have less than 10 GB of free space left. Continue anyway?") :



                                          qsTr("Configure system virtual memory limits (initial/maximum size in MB).")



                                color: !root.isPagefileInputValid ? Theme.error : 



                                       root.isPagefileSpaceLow ? Theme.warning : 



                                       Theme.textMuted



                                font.family: Theme.fontFamily



                                font.pixelSize: 12



                                font.bold: !root.isPagefileInputValid || root.isPagefileSpaceLow



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



                                border.color: !root.isPagefileInputValid ? Theme.error : root.isPagefileSpaceLow ? Theme.warning : (minInput.activeFocus ? Theme.accent : Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.4))



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



                                    validator: IntValidator { bottom: 0; top: 99999 }



                                    



                                    Binding on text {



                                        value: optimizerBackend.pagefileMin.toString()



                                    }







                                    onTextChanged: {



                                        var val = parseInt(text);



                                        optimizerBackend.pagefileMin = isNaN(val) ? 0 : val;



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



                                border.color: !root.isPagefileInputValid ? Theme.error : root.isPagefileSpaceLow ? Theme.warning : (maxInput.activeFocus ? Theme.accent : Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.4))



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



                                    validator: IntValidator { bottom: 0; top: 99999 }



                                    



                                    Binding on text {



                                        value: optimizerBackend.pagefileMax.toString()



                                    }







                                    onTextChanged: {



                                        var val = parseInt(text);



                                        optimizerBackend.pagefileMax = isNaN(val) ? 0 : val;



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



                    height: 120







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



                                    font.pixelSize: 16



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



                                font.pixelSize: 12



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



                    height: !optimizerBackend.defenderActive ? 120 : 104



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



                                    font.pixelSize: 16



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



                                font.pixelSize: 12



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



                    height: 104







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



                                    font.pixelSize: 16



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



                                font.pixelSize: 12



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



                    height: 104







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



                                    font.pixelSize: 16



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



                                font.pixelSize: 12



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







                // Co-installers Panel



                AcrylicPanel {



                    id: coinstallersPanel



                    width: parent.width



                    height: 104







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



                                    id: coinstallersPanel_iconImg



                                    source: "qrc:/MeguPackOptimizer/src/resources/settings.svg"



                                    anchors.fill: parent



                                    sourceSize.width: 20



                                    sourceSize.height: 20



                                    visible: false



                                }



                                ColorOverlay {



                                    anchors.fill: coinstallersPanel_iconImg



                                    source: coinstallersPanel_iconImg



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



                                    text: qsTr("Co-installers")



                                    color: Theme.textPrimary



                                    font.family: Theme.fontFamily



                                    font.pixelSize: 16



                                    font.bold: true



                                    anchors.verticalCenter: parent.verticalCenter



                                }



                                ShowPathButton {



                                    anchors.verticalCenter: parent.verticalCenter



                                    onClicked: { optimizerBackend.showPath("coinstallers"); }



                                }



                                Rectangle {



                                    visible: root.coinstallersChanged



                                    height: 16



                                    width: selectedTextCoinstallers.contentWidth + 10



                                    radius: 4



                                    color: Qt.rgba(Theme.success.r, Theme.success.g, Theme.success.b, 0.15)



                                    border.color: Theme.success



                                    border.width: 1



                                    anchors.verticalCenter: parent.verticalCenter



                                    Text {



                                        id: selectedTextCoinstallers



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



                                text: qsTr("Block or allow vendor-specific companion applications from automatically installing when connecting new hardware devices.")



                                color: Theme.textMuted



                                font.family: Theme.fontFamily



                                font.pixelSize: 12



                            }



                        }



                    }







                    Row {



                        anchors.right: parent.right



                        anchors.rightMargin: 16



                        anchors.verticalCenter: parent.verticalCenter



                        spacing: 16







                        MeguSwitch {



                            checked: optimizerBackend.coinstallersActive



                            anchors.verticalCenter: parent.verticalCenter



                            onToggled: (isChecked) => {



                                optimizerBackend.coinstallersActive = isChecked;



                            }



                        }



                    }



                }







                // Sleeping Pill Panel



                AcrylicPanel {



                    id: sleepingPillPanel



                    width: parent.width



                    height: 104







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



                                    id: sleepingPillPanel_iconImg



                                    source: "qrc:/MeguPackOptimizer/src/resources/bolt.svg"



                                    anchors.fill: parent



                                    sourceSize.width: 20



                                    sourceSize.height: 20



                                    visible: false



                                }



                                ColorOverlay {



                                    anchors.fill: sleepingPillPanel_iconImg



                                    source: sleepingPillPanel_iconImg



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



                                    text: qsTr("Sleeping Pill")



                                    color: Theme.textPrimary



                                    font.family: Theme.fontFamily



                                    font.pixelSize: 16



                                    font.bold: true



                                    anchors.verticalCenter: parent.verticalCenter



                                }



                            }







                            Text {



                                text: qsTr("Prevent background scheduled tasks from waking up your computer from sleep.")



                                color: Theme.textMuted



                                font.family: Theme.fontFamily



                                font.pixelSize: 12



                            }



                        }



                    }







                    Row {



                        anchors.right: parent.right



                        anchors.rightMargin: 16



                        anchors.verticalCenter: parent.verticalCenter



                        spacing: 16







                        // Arrow button that opens drawer



                        Rectangle {



                            width: 32



                            height: 32



                            radius: 16



                            color: sleepingPillArrowMouseArea.containsMouse ? Theme.accentDim : "transparent"



                            border.color: sleepingPillArrowMouseArea.containsMouse ? Theme.accent : Theme.border



                            border.width: 1



                            anchors.verticalCenter: parent.verticalCenter







                            Behavior on color { ColorAnimation { duration: Theme.animFast } }



                            Behavior on border.color { ColorAnimation { duration: Theme.animFast } }







                            Item {



                                width: 14



                                height: 14



                                anchors.centerIn: parent



                                x: sleepingPillArrowMouseArea.containsMouse ? (parent.width/2 - 5) : (parent.width/2 - 7)



                                Behavior on x { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }



                                Image {



                                    id: sleepingPillArrowImg



                                    source: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"



                                    anchors.fill: parent



                                    sourceSize.width: 14



                                    sourceSize.height: 14



                                    visible: false



                                }



                                ColorOverlay {



                                    anchors.fill: sleepingPillArrowImg



                                    source: sleepingPillArrowImg



                                    color: sleepingPillArrowMouseArea.containsMouse ? Theme.accent : Theme.textSecondary



                                }



                            }







                            MouseArea {



                                id: sleepingPillArrowMouseArea



                                anchors.fill: parent



                                hoverEnabled: true



                                cursorShape: Qt.PointingHandCursor



                                onClicked: {



                                    root.activeDrawer = "sleepingPill";



                                }



                            }



                        }



                    }



                }



            }







            // 4. HEALTH CATEGORY



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



                        text: qsTr("System Health")



                        color: Theme.textPrimary



                        font.family: Theme.fontFamily



                        font.pixelSize: 13



                        font.bold: true



                        anchors.verticalCenter: parent.verticalCenter



                    }



                }







                // Health Card



                AcrylicPanel {



                    id: healthPanel



                    width: parent.width



                    height: 104







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



                            color: Qt.rgba(0.1, 0.8, 0.4, 0.15)



                            anchors.verticalCenter: parent.verticalCenter







                            Item {



                                width: 20



                                height: 20



                                anchors.centerIn: parent







                                Image {



                                    id: healthIconImg



                                    source: "qrc:/MeguPackOptimizer/src/resources/bolt.svg"



                                    anchors.fill: parent



                                    sourceSize.width: 20



                                    sourceSize.height: 20



                                    visible: false



                                }



                                ColorOverlay {



                                    anchors.fill: healthIconImg



                                    source: healthIconImg



                                    color: "#00E676"



                                }



                            }



                        }







                        Column {



                            anchors.verticalCenter: parent.verticalCenter



                            spacing: 2







                            Text {



                                text: qsTr("Health")



                                color: Theme.textPrimary



                                font.family: Theme.fontFamily



                                font.pixelSize: 16



                                font.bold: true



                            }







                            Text {



                                text: qsTr("Restart graphics driver or rebuild icon cache to fix display issues.")



                                color: Theme.textMuted



                                font.family: Theme.fontFamily



                                font.pixelSize: 12



                            }



                        }



                    }







                    Row {



                        anchors.right: parent.right



                        anchors.rightMargin: 16



                        anchors.verticalCenter: parent.verticalCenter



                        spacing: 16







                        // Arrow button that opens drawer



                        Rectangle {



                            width: 32



                            height: 32



                            radius: 16



                            color: healthArrowMouseArea.containsMouse ? Theme.accentDim : "transparent"



                            border.color: healthArrowMouseArea.containsMouse ? Theme.accent : Theme.border



                            border.width: 1



                            anchors.verticalCenter: parent.verticalCenter







                            Behavior on color { ColorAnimation { duration: Theme.animFast } }



                            Behavior on border.color { ColorAnimation { duration: Theme.animFast } }







                            Item {



                                width: 14



                                height: 14



                                anchors.centerIn: parent



                                x: healthArrowMouseArea.containsMouse ? (parent.width/2 - 5) : (parent.width/2 - 7)



                                Behavior on x { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }



                                Image {



                                    id: healthArrowImg



                                    source: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"



                                    anchors.fill: parent



                                    sourceSize.width: 14



                                    sourceSize.height: 14



                                    visible: false



                                }



                                ColorOverlay {



                                    anchors.fill: healthArrowImg



                                    source: healthArrowImg



                                    color: healthArrowMouseArea.containsMouse ? Theme.accent : Theme.textSecondary



                                }



                            }







                            MouseArea {



                                id: healthArrowMouseArea



                                anchors.fill: parent



                                hoverEnabled: true



                                cursorShape: Qt.PointingHandCursor



                                onClicked: {



                                    root.activeDrawer = "health";



                                }



                            }



                        }



                    }



                }







                // Cleanup Card
                AcrylicPanel {
                    id: cleanupPanel
                    width: parent.width
                    height: 104

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
                            color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                            anchors.verticalCenter: parent.verticalCenter
                            Item {
                                width: 20
                                height: 20
                                anchors.centerIn: parent
                                Image {
                                    id: cleanupIconImg
                                    source: "qrc:/MeguPackOptimizer/src/resources/broom.svg"
                                    anchors.fill: parent
                                    sourceSize.width: 20
                                    sourceSize.height: 20
                                    visible: false
                                }
                                ColorOverlay {
                                    anchors.fill: cleanupIconImg
                                    source: cleanupIconImg
                                    color: Theme.accent
                                }
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2
                            Text {
                                text: qsTr("Cleanup")
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: 16
                                font.bold: true
                            }
                            Text {
                                text: qsTr("Free up storage space, clear cache, delete system restore points and more.")
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                            }
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 16

                        // Arrow button that opens drawer
                        Rectangle {
                            width: 32
                            height: 32
                            radius: 16
                            color: cleanupArrowMouseArea.containsMouse ? Theme.accentDim : "transparent"
                            border.color: cleanupArrowMouseArea.containsMouse ? Theme.accent : Theme.border
                            border.width: 1
                            anchors.verticalCenter: parent.verticalCenter

                            Behavior on color { ColorAnimation { duration: Theme.animFast } }
                            Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                            Item {
                                width: 14
                                height: 14
                                anchors.centerIn: parent
                                x: cleanupArrowMouseArea.containsMouse ? (parent.width/2 - 5) : (parent.width/2 - 7)
                                Behavior on x { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }
                                Image {
                                    id: cleanupArrowImg
                                    source: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"
                                    anchors.fill: parent
                                    sourceSize.width: 14
                                    sourceSize.height: 14
                                    visible: false
                                }
                                ColorOverlay {
                                    anchors.fill: cleanupArrowImg
                                    source: cleanupArrowImg
                                    color: cleanupArrowMouseArea.containsMouse ? Theme.accent : Theme.textSecondary
                                    }
                            }

                            MouseArea {
                                id: cleanupArrowMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.activeDrawer = "cleanup";
                                }
                            }
                        }
                    }
                }



                // Repair Card



                AcrylicPanel {



                    id: repairPanel



                    width: parent.width



                    height: 104







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



                            color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)



                            anchors.verticalCenter: parent.verticalCenter







                            Item {



                                width: 20



                                height: 20



                                anchors.centerIn: parent







                                Image {



                                    id: repairIconImg



                                    source: "qrc:/MeguPackOptimizer/src/resources/settings.svg"



                                    anchors.fill: parent



                                    sourceSize.width: 20



                                    sourceSize.height: 20



                                    visible: false



                                }



                                ColorOverlay {



                                    anchors.fill: repairIconImg



                                    source: repairIconImg



                                    color: Theme.accent



                                }



                            }



                        }







                        Column {



                            anchors.verticalCenter: parent.verticalCenter



                            spacing: 2







                            Text {



                                text: qsTr("Repair")



                                color: Theme.textPrimary



                                font.family: Theme.fontFamily



                                font.pixelSize: 16



                                font.bold: true



                            }







                            Text {



                                text: qsTr("Scan and repair system file corruption, windows image integrity, or filesystem errors.")



                                color: Theme.textMuted



                                font.family: Theme.fontFamily



                                font.pixelSize: 12



                            }



                        }



                    }







                    Row {



                        anchors.right: parent.right



                        anchors.rightMargin: 16



                        anchors.verticalCenter: parent.verticalCenter



                        spacing: 16







                        // Arrow button that opens drawer



                        Rectangle {



                            width: 32



                            height: 32



                            radius: 16



                            color: repairArrowMouseArea.containsMouse ? Theme.accentDim : "transparent"



                            border.color: repairArrowMouseArea.containsMouse ? Theme.accent : Theme.border



                            border.width: 1



                            anchors.verticalCenter: parent.verticalCenter







                            Behavior on color { ColorAnimation { duration: Theme.animFast } }



                            Behavior on border.color { ColorAnimation { duration: Theme.animFast } }







                            Item {



                                width: 14



                                height: 14



                                anchors.centerIn: parent



                                x: repairArrowMouseArea.containsMouse ? (parent.width/2 - 5) : (parent.width/2 - 7)



                                Behavior on x { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }



                                Image {



                                    id: repairArrowImg



                                    source: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"



                                    anchors.fill: parent



                                    sourceSize.width: 14



                                    sourceSize.height: 14



                                    visible: false



                                }



                                ColorOverlay {



                                    anchors.fill: repairArrowImg



                                    source: repairArrowImg



                                    color: repairArrowMouseArea.containsMouse ? Theme.accent : Theme.textSecondary



                                }



                            }







                            MouseArea {



                                id: repairArrowMouseArea



                                anchors.fill: parent



                                hoverEnabled: true



                                cursorShape: Qt.PointingHandCursor



                                onClicked: {



                                    root.activeDrawer = "repair";



                                }



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







        // Warning row when page file validation fails



        RowLayout {



            visible: !root.isPagefileInputValid || root.isPagefileSpaceLow



            anchors.right: optimizeButton.left



            anchors.rightMargin: 16



            anchors.verticalCenter: parent.verticalCenter



            spacing: 8







            // Warning icon



            Item {



                width: 14



                height: 14



                Image {



                    id: warnIconImg



                    source: "qrc:/MeguPackOptimizer/src/resources/warning.svg"



                    anchors.fill: parent



                    sourceSize.width: 14



                    sourceSize.height: 14



                    visible: false



                }



                ColorOverlay {



                    anchors.fill: warnIconImg



                    source: warnIconImg



                    color: !root.isPagefileInputValid ? Theme.error : Theme.warning



                }



            }







            Text {



                text: !root.isPagefileInputValid ? 



                          (optimizerBackend.pagefileMin > optimizerBackend.pagefileMax ? 



                              qsTr("Invalid limits: Min size exceeds Max!") : 



                              (optimizerBackend.pagefileMin < 1024 || optimizerBackend.pagefileMax < 1024 || optimizerBackend.pagefileMin > 99999 || optimizerBackend.pagefileMax > 99999) ?



                                  qsTr("Invalid limits: Size must be 1024-99999 MB!") :



                                  qsTr("Not enough disk space for page file!")) : 



                          qsTr("C: drive space will be less than 10 GB. Continue?")



                color: !root.isPagefileInputValid ? Theme.error : Theme.warning



                font.family: Theme.fontFamily



                font.pixelSize: 12



                font.bold: true



            }







            // Clickable eye icon button to locate Page File option



            Item {



                width: 24



                height: 24







                Rectangle {



                    anchors.fill: parent



                    radius: 12



                    color: eyeMouseArea.containsMouse ? "#1AFFFFFF" : "transparent"



                    Behavior on color { ColorAnimation { duration: Theme.animFast } }



                }







                Item {



                    width: 14



                    height: 14



                    anchors.centerIn: parent



                    Image {



                        id: eyeIconImg



                        source: "qrc:/MeguPackOptimizer/src/resources/eye.svg"



                        anchors.fill: parent



                        sourceSize.width: 14



                        sourceSize.height: 14



                        visible: false



                    }



                    ColorOverlay {



                        anchors.fill: eyeIconImg



                        source: eyeIconImg



                        color: eyeMouseArea.containsMouse ? Theme.accent : Theme.textSecondary



                    }



                }







                MouseArea {



                    id: eyeMouseArea



                    anchors.fill: parent



                    hoverEnabled: true



                    cursorShape: Qt.PointingHandCursor



                    onClicked: {



                        root.locateFunction("Page File");



                    }



                }



                



                ToolTip {



                    visible: eyeMouseArea.containsMouse



                    delay: 200



                    text: qsTr("Locate Page File option")



                }



            }



        }







        MeguButton {



            id: optimizeButton



            text: qsTr("Optimize")



            iconSource: "qrc:/MeguPackOptimizer/src/resources/play.svg"



            accented: true



            anchors.centerIn: parent



            width: 180



            height: 40



            enabled: !optimizerBackend.isOptimizingSystem && root.hasChanges && root.isPagefileInputValid



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



                            if (root.activeDrawer === "moreRights") return qsTr("More Privileges");



                            if (root.activeDrawer === "explorerCustomization") return qsTr("File Explorer Customization");



                            if (root.activeDrawer === "startMenuCustomization") return qsTr("Start Menu Customization");



                            if (root.activeDrawer === "desktopCustomization") return qsTr("Desktop Customization");



                            if (root.activeDrawer === "health") return qsTr("HEALTH");
                            if (root.activeDrawer === "cleanup") return qsTr("CLEANUP");






                            if (root.activeDrawer === "sleepingPill") return qsTr("SLEEPING PILL");



                            if (root.activeDrawer === "repair") return qsTr("REPAIR SYSTEM");



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



                    id: drawerScroll



                    width: parent.width



                    height: parent.height - 60



                    clip: true



                    contentWidth: width







                    ScrollBar.vertical: MeguScrollBar { }



                    ScrollBar.horizontal: MeguScrollBar { }







                    MouseArea {



                        anchors.fill: parent



                        acceptedButtons: Qt.NoButton



                        onWheel: (wheel) => {



                            var speedMultiplier = 2.5;



                            var angle = wheel.angleDelta.y;



                            if (angle !== 0) {



                                var newY = drawerScroll.contentItem.contentY - (angle * speedMultiplier);



                                drawerScroll.contentItem.contentY = Math.max(drawerScroll.contentItem.originY, 



                                    Math.min(newY, drawerScroll.contentItem.contentHeight - drawerScroll.contentItem.height));



                            }



                        }



                    }







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



                        if (root.activeDrawer === "moreRights") return moreRightsDrawer.implicitHeight;



                        if (root.activeDrawer === "explorerCustomization") return explorerDrawer.implicitHeight;



                        if (root.activeDrawer === "startMenuCustomization") return startMenuDrawer.implicitHeight;



                        if (root.activeDrawer === "desktopCustomization") return desktopDrawer.implicitHeight;



                        if (root.activeDrawer === "health") return healthDrawer.implicitHeight;
                        if (root.activeDrawer === "cleanup") return cleanupDrawer.implicitHeight;






                        if (root.activeDrawer === "sleepingPill") return sleepingPillDrawer.implicitHeight;



                        if (root.activeDrawer === "repair") return repairDrawer.implicitHeight;



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







                    // 13. More Rights Drawer Content



                    MoreRightsDrawer {



                        id: moreRightsDrawer



                        visible: root.activeDrawer === "moreRights"



                        width: visible ? parent.width : 800



                        height: visible ? implicitHeight : 0



                    }







                    // 14. File Explorer Customization Drawer Content



                    ExplorerDrawer {



                        id: explorerDrawer



                        visible: root.activeDrawer === "explorerCustomization"



                        width: visible ? parent.width : 800



                        height: visible ? implicitHeight : 0



                    }







                    // 15. Start Menu Customization Drawer Content



                    StartMenuDrawer {



                        id: startMenuDrawer



                        visible: root.activeDrawer === "startMenuCustomization"



                        width: visible ? parent.width : 800



                        height: visible ? implicitHeight : 0



                    }







                    // 16. Desktop Customization Drawer Content



                    DesktopDrawer {



                        id: desktopDrawer



                        visible: root.activeDrawer === "desktopCustomization"



                        width: visible ? parent.width : 800



                        height: visible ? implicitHeight : 0



                    }







                    // 17. Health Drawer Content



                    HealthDrawer {



                        id: healthDrawer



                        visible: root.activeDrawer === "health"



                        width: visible ? parent.width : 800



                        height: visible ? implicitHeight : 0



                    }




                    // Cleanup Drawer Content
                    CleanupDrawer {
                        id: cleanupDrawer
                        visible: root.activeDrawer === "cleanup"
                        width: visible ? parent.width : 800
                        height: visible ? implicitHeight : 0
                    }







                    // 18. Sleeping Pill Drawer Content



                    SleepingPillDrawer {



                        id: sleepingPillDrawer



                        visible: root.activeDrawer === "sleepingPill"



                        width: visible ? parent.width : 800



                        height: visible ? implicitHeight : 0



                    }







                    // 19. Repair Drawer Content



                    RepairDrawer {



                        id: repairDrawer



                        visible: root.activeDrawer === "repair"



                        width: visible ? parent.width : 800



                        height: visible ? implicitHeight : 0



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



                            font.pixelSize: 12



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



                            font.pixelSize: 12



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



                                            root.locateFunction(modelData.name);



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



    // Helper StatCard component for completion overlay
    component StatCard: Rectangle {
        id: statCardRoot
        property string title: ""
        property string value: ""
        property string iconSource: ""
        property color accentColor: Theme.accent

        height: 72
        color: "#12141A"
        radius: 10
        border.color: Qt.rgba(255, 255, 255, 0.05)
        border.width: 1

        Row {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12
            
            // Icon container
            Rectangle {
                width: 48
                height: 48
                radius: 24
                color: Qt.rgba(statCardRoot.accentColor.r, statCardRoot.accentColor.g, statCardRoot.accentColor.b, 0.1)
                anchors.verticalCenter: parent.verticalCenter
                
                Item {
                    width: 20
                    height: 20
                    anchors.centerIn: parent
                    
                    Image {
                        id: statIcon
                        source: statCardRoot.iconSource
                        anchors.fill: parent
                        sourceSize.width: 20
                        sourceSize.height: 20
                        visible: false
                    }
                    
                    ColorOverlay {
                        anchors.fill: statIcon
                        source: statIcon
                        color: statCardRoot.accentColor
                    }
                }
            }
            
            // Text values
            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4
                width: parent.width - 64 // Fill remaining space
                
                Text {
                    text: statCardRoot.title
                    color: Theme.textMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    elide: Text.ElideRight
                    width: parent.width
                }
                
                Text {
                    text: statCardRoot.value
                    color: "#FFFFFF"
                    font.family: Theme.fontFamily
                    font.pixelSize: 15
                    font.bold: true
                    elide: Text.ElideRight
                    width: parent.width
                }
            }
        }
    }

    Rectangle {
        id: progressOverlay
        anchors.fill: parent
        color: "#E0000000"
        visible: optimizerBackend.isOptimizingSystem || showFinishedOverlay
        z: 200

        property bool showFinishedOverlay: false

        // Statistics capture variables
        property int settingsAppliedCount: 0
        property int servicesDisabledCount: 0
        property int appsRemovedCount: 0
        property int drivesOptimizedCount: 0
        property int totalTasksCount: 0

        // Completed speedometer progress animation
        property real completedProgress: 0.0

        // Running logo pulse animation
        property real pulseValue: 0.0

        NumberAnimation on pulseValue {
            from: 0.0
            to: 2.0 * Math.PI
            duration: 2000
            loops: Animation.Infinite
            running: optimizerBackend.isOptimizingSystem
        }

        NumberAnimation {
            id: completedProgressAnim
            target: progressOverlay
            property: "completedProgress"
            from: 0.0
            to: 1.0
            duration: 1200
            easing.type: Easing.OutBack
        }

        Connections {
            target: optimizerBackend
            
            function onIsOptimizingSystemChanged(val) {
                if (val) {
                    // Capture changes count before baselines are synced by C++
                    window.optimizationPercentageBeforeRun = window.optimizationPercentage;
                    window.showDelta = false;

                    progressOverlay.settingsAppliedCount = root.mainChangesCount + root.sidebarChangesCount;
                    
                    var svcCount = 0;
                    if (optimizerBackend.originalWinSearchActive && !optimizerBackend.winSearchActive) svcCount++;
                    if (optimizerBackend.originalDefenderServiceActive && !optimizerBackend.defenderServiceActive) svcCount++;
                    if (optimizerBackend.originalTelemetryDiagTrackActive && !optimizerBackend.telemetryDiagTrackActive) svcCount++;
                    if (optimizerBackend.originalTelemetryWapPushActive && !optimizerBackend.telemetryWapPushActive) svcCount++;
                    if (optimizerBackend.originalSuperuserUcpdActive && !optimizerBackend.superuserUcpdActive) svcCount++;
                    if (optimizerBackend.originalWindowsUpdateMode !== 3 && optimizerBackend.windowsUpdateMode === 3) svcCount++;
                    if (optimizerBackend.originalCoinstallersActive && !optimizerBackend.coinstallersActive) svcCount++;
                    progressOverlay.servicesDisabledCount = svcCount;

                    var appsCount = 0;
                    if (optimizerBackend.originalXboxAppInstalled && !optimizerBackend.xboxAppInstalled) appsCount++;
                    if (optimizerBackend.originalXboxGamingOverlayInstalled && !optimizerBackend.xboxGamingOverlayInstalled) appsCount++;
                    if (optimizerBackend.originalXboxSpeechWindowInstalled && !optimizerBackend.xboxSpeechWindowInstalled) appsCount++;
                    if (root.steamFriendsSettingsChanged && optimizerBackend.steamFriendsSettings && optimizerBackend.originalSteamFriendsSettings) {
                        if (optimizerBackend.originalSteamFriendsSettings["bRunOnStartup"] === true && optimizerBackend.steamFriendsSettings["bRunOnStartup"] === false) {
                            appsCount++;
                        }
                    }
                    progressOverlay.appsRemovedCount = appsCount;

                    var drivesCount = 0;
                    if (optimizerBackend.driveStates && optimizerBackend.originalDriveStates) {
                        var keys = Object.keys(optimizerBackend.driveStates);
                        for (var d = 0; d < keys.length; d++) {
                            var key = keys[d];
                            if (optimizerBackend.driveStates[key] !== optimizerBackend.originalDriveStates[key]) {
                                drivesCount++;
                            }
                        }
                    }
                    progressOverlay.drivesOptimizedCount = drivesCount;

                    progressOverlay.totalTasksCount = progressOverlay.settingsAppliedCount + progressOverlay.servicesDisabledCount + progressOverlay.appsRemovedCount + progressOverlay.drivesOptimizedCount;

                    progressOverlay.completedProgress = 0.0;
                    progressOverlay.showFinishedOverlay = true;
                } else {
                    var delta = window.optimizationPercentage - window.optimizationPercentageBeforeRun;
                    window.optimizationDelta = delta;
                    window.showDelta = true;
                    completedProgressAnim.start();
                }
            }
        }

        MouseArea {
            anchors.fill: parent
        }

        // Main modal container (820x520 side-by-side design)
        Rectangle {
            id: modalContainer
            width: 820
            height: 520
            anchors.centerIn: parent
            color: "#0F1015" // Sleek dark charcoal panel background
            radius: 16
            border.color: Qt.rgba(255, 255, 255, 0.08)
            border.width: 1

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

            // Split Layout
            Row {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 20

                // Left Panel: Side Card with purple-to-blue gradient
                Rectangle {
                    id: leftCard
                    width: 320
                    height: parent.height - 32 // accounts for Row margins
                    anchors.verticalCenter: parent.verticalCenter
                    color: "transparent"

                    // Gradient background card
                    Rectangle {
                        anchors.fill: parent
                        radius: 12
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#2B1E43" } // Vivid purple
                            GradientStop { position: 1.0; color: "#131A35" } // Deep blue/navy
                        }
                        border.color: Qt.rgba(255, 255, 255, 0.08)
                        border.width: 1
                    }

                    // 1. Running State (Is Optimizing)
                    Item {
                        anchors.fill: parent
                        visible: optimizerBackend.isOptimizingSystem

                        // Logo Container
                        Item {
                            id: logoContainer
                            width: 160
                            height: 160
                            anchors.centerIn: parent

                            Image {
                                source: "qrc:/MeguPackOptimizer/src/resources/megu_logo_transparent.png"
                                anchors.fill: parent
                                fillMode: Image.PreserveAspectFit
                                opacity: 0.85 + 0.15 * Math.sin(progressOverlay.pulseValue)
                            }
                        }

                        Text {
                            anchors.top: logoContainer.bottom
                            anchors.topMargin: 24
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: qsTr("OPTIMIZING SYSTEM")
                            color: "#FFFFFF"
                            font.family: Theme.fontFamily
                            font.pixelSize: 13
                            font.bold: true
                            font.letterSpacing: 1.5
                        }

                        // Progress indicator bar
                        Rectangle {
                            id: runningProgressBarBg
                            width: 200
                            height: 4
                            color: Qt.rgba(255, 255, 255, 0.1)
                            radius: 2
                            anchors.top: logoContainer.bottom
                            anchors.topMargin: 56
                            anchors.horizontalCenter: parent.horizontalCenter

                            Rectangle {
                                width: parent.width * optimizerBackend.systemProgress
                                height: parent.height
                                color: Theme.accent
                                radius: 2
                                Behavior on width {
                                    NumberAnimation { duration: 150 }
                                }
                            }
                        }

                        Text {
                            anchors.top: runningProgressBarBg.bottom
                            anchors.topMargin: 8
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: Math.round(optimizerBackend.systemProgress * 100) + "%"
                            color: Theme.accent
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                    }

                    // 2. Completed State
                    Item {
                        anchors.fill: parent
                        visible: !optimizerBackend.isOptimizingSystem

                        // Logo + Delta header row (matching BoosterX)
                        Row {
                            id: completedHeaderRow
                            anchors.top: parent.top
                            anchors.topMargin: 40
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 8

                            Image {
                                source: "qrc:/MeguPackOptimizer/src/resources/bolt.svg"
                                width: 22
                                height: 22
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                                anchors.verticalCenter: parent.verticalCenter
                                sourceSize.width: 22
                                sourceSize.height: 22
                            }

                            Text {
                                text: "MEGU BOOST"
                                color: "#FFFFFF"
                                font.family: Theme.fontFamily
                                font.pixelSize: 20
                                font.bold: true
                                font.italic: true
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                visible: window.showDelta && window.optimizationDelta !== 0
                                text: (window.optimizationDelta > 0 ? "+" : "") + window.optimizationDelta + "%"
                                color: window.optimizationDelta > 0 ? "#3b82f6" : Theme.error // Neon cyan-blue for positive, red for negative
                                font.family: Theme.fontFamily
                                font.pixelSize: 22
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                                opacity: progressOverlay.completedProgress
                            }
                        }

                        // Circular Speedometer Gauge
                        Item {
                            id: gaugeContainer
                            width: 180
                            height: 180
                            anchors.centerIn: parent

                            Shape {
                                anchors.fill: parent
                                layer.enabled: true
                                layer.samples: 4

                                // Track background arc
                                ShapePath {
                                    strokeColor: Qt.rgba(255, 255, 255, 0.05)
                                    strokeWidth: 8
                                    fillColor: "transparent"
                                    capStyle: ShapePath.RoundCap

                                    PathAngleArc {
                                        centerX: 90
                                        centerY: 90
                                        radiusX: 75
                                        radiusY: 75
                                        startAngle: -210
                                        sweepAngle: 240
                                    }
                                }

                                // Active progress arc
                                ShapePath {
                                    strokeColor: Theme.accent
                                    strokeWidth: 8
                                    fillColor: "transparent"
                                    capStyle: ShapePath.RoundCap

                                    PathAngleArc {
                                        centerX: 90
                                        centerY: 90
                                        radiusX: 75
                                        radiusY: 75
                                        startAngle: -210
                                        sweepAngle: (240 * (window.optimizationPercentage / 100)) * progressOverlay.completedProgress
                                    }
                                }
                            }

                            // Inner score text
                            Text {
                                text: Math.round(progressOverlay.completedProgress * window.optimizationPercentage) + "%"
                                color: Theme.accent
                                font.family: Theme.fontFamily
                                font.pixelSize: 32
                                font.bold: true
                                anchors.centerIn: parent
                            }
                        }

                        Text {
                            anchors.top: gaugeContainer.bottom
                            anchors.topMargin: 36
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: qsTr("Good luck in games!")
                            color: "#FFFFFF"
                            font.family: Theme.fontFamily
                            font.pixelSize: 18
                            font.bold: true
                        }
                    }
                }

                // Right Panel: Control and Log details
                Rectangle {
                    id: rightPanel
                    width: parent.width - leftCard.width - parent.spacing - 32 // fill width
                    height: parent.height - 32
                    anchors.verticalCenter: parent.verticalCenter
                    color: "transparent"

                    // Header Block
                    Column {
                        id: rightHeader
                        width: parent.width
                        spacing: 4

                        Text {
                            text: optimizerBackend.isOptimizingSystem ? qsTr("Optimization in Progress") : qsTr("Optimization Complete")
                            color: "#FFFFFF"
                            font.family: Theme.fontFamily
                            font.pixelSize: 20
                            font.bold: true
                        }

                        Text {
                            text: optimizerBackend.isOptimizingSystem ? qsTr("Applying chosen tweaks and configuring system modules...") : qsTr("Finished system modifications successfully.")
                            color: Theme.textMuted
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                        }
                    }

                    // 1. Running State: Scrollable logs ListView
                    Item {
                        anchors.top: rightHeader.bottom
                        anchors.topMargin: 20
                        anchors.bottom: runningStatusText.top
                        anchors.bottomMargin: 10
                        width: parent.width
                        visible: optimizerBackend.isOptimizingSystem

                        Rectangle {
                            anchors.fill: parent
                            color: "#090A0E"
                            radius: 12
                            border.color: Qt.rgba(255, 255, 255, 0.05)
                            border.width: 1
                            clip: true

                            ListView {
                                id: logListView
                                anchors.fill: parent
                                anchors.margins: 14
                                model: stepLogModel
                                spacing: 8
                                interactive: true
                                boundsBehavior: Flickable.StopAtBounds

                                Connections {
                                    target: stepLogModel
                                    function onCountChanged() {
                                        logListView.positionViewAtEnd();
                                    }
                                }

                                delegate: Row {
                                    width: logListView.width - 24
                                    spacing: 12

                                    Rectangle {
                                        width: 6
                                        height: 6
                                        radius: 3
                                        anchors.verticalCenter: parent.verticalCenter
                                        color: {
                                            if (model.type === "SUCCESS") return Theme.success;
                                            if (model.type === "ERROR") return Theme.error;
                                            if (model.type === "WARNING") return Theme.warning;
                                            return Theme.accent;
                                        }
                                    }

                                    Text {
                                        width: parent.width - 18
                                        text: model.message
                                        color: {
                                            if (model.type === "ERROR") return Theme.error;
                                            if (model.type === "WARNING") return Theme.warning;
                                            return "#E0E0E0";
                                        }
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 12
                                        wrapMode: Text.WordWrap
                                    }
                                }
                            }
                        }
                    }

                    // Running bottom status text
                    Text {
                        id: runningStatusText
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 8
                        width: parent.width
                        text: stepLogModel.count > 0 ? stepLogModel.get(stepLogModel.count - 1).message : qsTr("Analyzing system configuration...")
                        color: Theme.accent
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                        font.italic: true
                        elide: Text.ElideRight
                        visible: optimizerBackend.isOptimizingSystem
                    }

                    // 2. Completed State: Statistics Grid and bottom actions
                    Item {
                        anchors.top: rightHeader.bottom
                        anchors.topMargin: 20
                        anchors.bottom: parent.bottom
                        width: parent.width
                        visible: !optimizerBackend.isOptimizingSystem

                        Column {
                            width: parent.width
                            spacing: 16

                            Text {
                                text: qsTr("Breakdown of optimizations:")
                                color: "#FFFFFF"
                                font.family: Theme.fontFamily
                                font.pixelSize: 13
                                font.bold: true
                            }

                            Grid {
                                width: parent.width
                                columns: 2
                                spacing: 12

                                StatCard {
                                    width: (parent.width - 12) / 2
                                    title: qsTr("Settings Applied")
                                    value: progressOverlay.settingsAppliedCount.toString()
                                    iconSource: "qrc:/MeguPackOptimizer/src/resources/settings.svg"
                                    accentColor: Theme.accent
                                }

                                StatCard {
                                    width: (parent.width - 12) / 2
                                    title: qsTr("Services Disabled")
                                    value: progressOverlay.servicesDisabledCount.toString()
                                    iconSource: "qrc:/MeguPackOptimizer/src/resources/terminal.svg"
                                    accentColor: "#F44336" // Light red
                                }

                                StatCard {
                                    width: (parent.width - 12) / 2
                                    title: qsTr("Drives Configured")
                                    value: progressOverlay.drivesOptimizedCount.toString()
                                    iconSource: "qrc:/MeguPackOptimizer/src/resources/storage.svg"
                                    accentColor: "#00BCD4" // Teal/cyan
                                }

                                StatCard {
                                    width: (parent.width - 12) / 2
                                    title: qsTr("Apps & Startup")
                                    value: progressOverlay.appsRemovedCount.toString()
                                    iconSource: "qrc:/MeguPackOptimizer/src/resources/monitor.svg"
                                    accentColor: "#4CAF50" // Green
                                }
                            }

                            // Notice Banner (Explorer Restart)
                            Rectangle {
                                width: parent.width
                                height: visible ? 56 : 0
                                color: Qt.rgba(251, 140, 0, 0.1) // Soft orange warning
                                radius: 8
                                border.color: Qt.rgba(251, 140, 0, 0.15)
                                border.width: 1
                                visible: optimizerBackend.explorerNeedsRestart

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 10

                                    Item {
                                        width: 16
                                        height: 16
                                        anchors.verticalCenter: parent.verticalCenter

                                        Image {
                                            id: warnIcon
                                            source: "qrc:/MeguPackOptimizer/src/resources/warning.svg"
                                            anchors.fill: parent
                                            sourceSize.width: 16
                                            sourceSize.height: 16
                                            visible: false
                                        }

                                        ColorOverlay {
                                            anchors.fill: warnIcon
                                            source: warnIcon
                                            color: Theme.warning
                                        }
                                    }

                                    Text {
                                        width: parent.width - 32
                                        text: qsTr("A Windows Explorer restart is required to apply the taskbar/shell customizations.")
                                        color: Theme.warning
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 12
                                        wrapMode: Text.WordWrap
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                        }

                        // Bottom Actions Row
                        Row {
                            anchors.bottom: parent.bottom
                            anchors.right: parent.right
                            spacing: 12

                            MeguButton {
                                text: qsTr("Restart PC")
                                accented: false
                                height: 32
                                width: 110
                                onClicked: {
                                    optimizerBackend.rebootSystem();
                                }
                            }

                            MeguButton {
                                text: optimizerBackend.explorerNeedsRestart ? qsTr("Restart Explorer") : qsTr("Continue")
                                accented: true
                                height: 32
                                width: 140
                                onClicked: {
                                    if (optimizerBackend.explorerNeedsRestart) {
                                        optimizerBackend.restartExplorer();
                                        optimizerBackend.explorerNeedsRestart = false;
                                    } else {
                                        progressOverlay.showFinishedOverlay = false;
                                    }
                                }
                            }

                            MeguButton {
                                text: qsTr("Close")
                                accented: false
                                height: 32
                                width: 80
                                visible: optimizerBackend.explorerNeedsRestart
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



                        font.pixelSize: 16



                        font.bold: true



                        anchors.verticalCenter: parent.verticalCenter



                    }



                }







                Text {



                    text: qsTr("Discord is currently running. It must be closed to safely lock/unlock overlay files.\n\nWould you like to close Discord now and proceed?")



                    color: Theme.textSecondary



                    font.family: Theme.fontFamily



                    font.pixelSize: 12



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

