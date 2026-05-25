import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeguPackOptimizer 1.0
import Qt5Compat.GraphicalEffects
import "../components"

Item {
    id: root
    anchors.fill: parent

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

    // Reactive computation of changes between current live states and original states
    property bool hasChanges: {
        if (optimizerBackend.winSearchActive !== optimizerBackend.originalWinSearchActive) return true;
        if (optimizerBackend.hibernationActive !== optimizerBackend.originalHibernationActive) return true;
        if (optimizerBackend.gamingOverlayActive !== optimizerBackend.originalGamingOverlayActive) return true;
        if (optimizerBackend.coreIsolationActive !== optimizerBackend.originalCoreIsolationActive) return true;
        if (optimizerBackend.mouseAccelerationActive !== optimizerBackend.originalMouseAccelerationActive) return true;
        if (optimizerBackend.gameModeActive !== optimizerBackend.originalGameModeActive) return true;
        if (optimizerBackend.firewallActive !== optimizerBackend.originalFirewallActive) return true;
        if (optimizerBackend.printerActive !== optimizerBackend.originalPrinterActive) return true;
        if (optimizerBackend.bitlockerActive !== optimizerBackend.originalBitlockerActive) return true;
        if (optimizerBackend.discordOverlayActive !== optimizerBackend.originalDiscordOverlayActive) return true;
        if (optimizerBackend.notificationsActive !== optimizerBackend.originalNotificationsActive) return true;
        if (optimizerBackend.notifGlobalActive !== optimizerBackend.originalNotifGlobalActive) return true;
        if (optimizerBackend.notifAppActive !== optimizerBackend.originalNotifAppActive) return true;
        if (optimizerBackend.notifSoundsActive !== optimizerBackend.originalNotifSoundsActive) return true;
        if (optimizerBackend.notifLockscreenActive !== optimizerBackend.originalNotifLockscreenActive) return true;
        if (optimizerBackend.targetPowerSchemeGuid !== optimizerBackend.activePowerSchemeGuid) return true;
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
        if (optimizerBackend.windowsUpdateMode !== optimizerBackend.originalWindowsUpdateMode) return true;
        if (!optimizerBackend.driveStates || !optimizerBackend.originalDriveStates) return false;
        var keys = Object.keys(optimizerBackend.driveStates);
        for (var i = 0; i < keys.length; i++) {
            var key = keys[i];
            if (optimizerBackend.driveStates[key] !== optimizerBackend.originalDriveStates[key]) return true;
        }
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
    property bool printerChanged: optimizerBackend.printerActive !== optimizerBackend.originalPrinterActive
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
    property bool windowsUpdateChanged: optimizerBackend.windowsUpdateMode !== optimizerBackend.originalWindowsUpdateMode

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
        if (indexingChanged) count++;
        if (xboxChanged) count++;
        if (coreIsolationChanged) count++;
        if (mouseAccelerationChanged) count++;
        if (gameModeChanged) count++;
        if (firewallChanged) count++;
        if (printerChanged) count++;
        if (notificationsChanged) count++;
        if (hibernationChanged) count++;
        if (powerPlanChanged) count++;
        if (bitlockerChanged) count++;
        if (discordOverlayChanged) count++;
        if (defenderChanged) count++;
        if (usbPowerSavingChanged) count++;
        if (remoteAccessChanged) count++;
        if (telemetryChanged) count++;
        if (windowsUpdateChanged) count++;
        return count;
    }

    property var pendingChangesList: {
        var list = [];
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
        if (printerChanged) list.push({
            name: qsTr("Print Spooler (Printer)"),
            icon: "qrc:/MeguPackOptimizer/src/resources/monitor.svg",
            hasSidebar: true,
            revert: function() {
                optimizerBackend.printerActive = optimizerBackend.originalPrinterActive;
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
        if (powerPlanChanged) list.push({
            name: qsTr("Power Plan"),
            icon: "qrc:/MeguPackOptimizer/src/resources/bolt.svg",
            hasSidebar: true,
            revert: function() {
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
        if (defenderChanged) list.push({
            name: qsTr("Windows Defender"),
            icon: "qrc:/MeguPackOptimizer/src/resources/warning.svg",
            hasSidebar: true,
            revert: function() {
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
        if (windowsUpdateChanged) list.push({
            name: qsTr("Windows Update"),
            icon: "qrc:/MeguPackOptimizer/src/resources/settings.svg",
            hasSidebar: true,
            revert: function() {
                optimizerBackend.windowsUpdateMode = optimizerBackend.originalWindowsUpdateMode;
            }
        });
        return list;
    }

    property var pendingSubOptionsList: {
        var _idx = indexingChanged;
        var _ntf = notificationsChanged;
        var _xbc = xboxChanged;
        var _prn = printerChanged;
        var _pwr = powerPlanChanged;
        var _btl = bitlockerChanged;
        var _ws = optimizerBackend.winSearchActive;
        var _ds = optimizerBackend.driveStates;
        var _ga = optimizerBackend.gamingOverlayActive;
        var _pa = optimizerBackend.printerActive;
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
        if (category === qsTr("File Indexing")) {
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
        } else if (category === qsTr("Xbox App & Game Bar")) {
            if (optimizerBackend.gamingOverlayActive !== optimizerBackend.originalGamingOverlayActive) {
                subList.push({
                    name: qsTr("Disable Game Bar Popup") + ": " + (optimizerBackend.originalGamingOverlayActive ? qsTr("Disabled") : qsTr("Enabled")) + " -> " + (optimizerBackend.gamingOverlayActive ? qsTr("Disabled") : qsTr("Enabled")),
                    revert: function() {
                        optimizerBackend.gamingOverlayActive = optimizerBackend.originalGamingOverlayActive;
                    }
                });
            }
        } else if (category === qsTr("Print Spooler (Printer)")) {
            if (optimizerBackend.printerActive !== optimizerBackend.originalPrinterActive) {
                subList.push({
                    name: qsTr("Print Spooler") + ": " + (optimizerBackend.originalPrinterActive ? qsTr("Enabled") : qsTr("Disabled")) + " -> " + (optimizerBackend.printerActive ? qsTr("Enabled") : qsTr("Disabled")),
                    revert: function() {
                        optimizerBackend.printerActive = optimizerBackend.originalPrinterActive;
                    }
                });
            }
        } else if (category === qsTr("Windows Notifications")) {
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
        } else if (category === qsTr("Power Plan")) {
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
        } else if (category === qsTr("Windows Defender")) {
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
        } else if (category === qsTr("USB 3.0 Power Saving")) {
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
        } else if (category === qsTr("Telemetry")) {
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
        } else if (category === qsTr("Windows Update")) {
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
        }
        return subList;
    }

    function getParentCard(name) {
        if (name === qsTr("File Indexing")) return indexingPanel;
        if (name === qsTr("Xbox App & Game Bar")) return xboxPanel;
        if (name === qsTr("Core Isolation")) return coreIsolationPanel;
        if (name === qsTr("Mouse Acceleration")) return mouseAccelerationPanel;
        if (name === qsTr("Game Mode")) return gameModePanel;
        if (name === qsTr("Discord In-Game Overlay")) return discordOverlayPanel;
        if (name === qsTr("Windows Defender Firewall")) return firewallPanel;
        if (name === qsTr("Print Spooler (Printer)")) return printerPanel;
        if (name === qsTr("Windows Notifications")) return notificationsPanel;
        if (name === qsTr("System Hibernation")) return hibernationPanel;
        if (name === qsTr("Power Plan")) return powerPlanPanel;
        if (name === qsTr("BitLocker Drive Encryption")) return bitlockerPanel;
        if (name === qsTr("Windows Defender")) return defenderPanel;
        if (name === qsTr("USB 3.0 Power Saving")) return usbPanel;
        if (name === qsTr("Remote Access (RDP)")) return remoteAccessPanel;
        if (name === qsTr("Telemetry")) return telemetryPanel;
        if (name === qsTr("Windows Update")) return windowsUpdatePanel;
        return null;
    }

    function locateFunction(categoryName) {
        if (categoryName === qsTr("Telemetry") || categoryName === "Telemetry") {
            root.currentSection = "telemetry";
        } else {
            root.currentSection = "core";
        }

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

        Column {
            id: mainColumn
            width: mainScroll.width - 12
            spacing: 24

            Text {
                text: root.currentSection === "telemetry" ? qsTr("TELEMETRY SETTINGS") : qsTr("SYSTEM OPTIMIZATION")
                color: Theme.yellowAccent
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.bold: true
                font.letterSpacing: 1.5
            }

            // 1. DRIVES INDEXING CATEGORY
            Column {
                visible: root.currentSection === "core"
                width: parent.width
                spacing: 8

                Text {
                    text: qsTr("DRIVES & INDEXING")
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 1
                }

                AcrylicPanel {
                    id: indexingPanel
                    width: parent.width
                    height: 72

                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Item {
                            width: 28
                            height: 28
                            anchors.verticalCenter: parent.verticalCenter
                            Image {
                                id: storageIconImg
                                source: "qrc:/MeguPackOptimizer/src/resources/storage.svg"
                                anchors.fill: parent
                                sourceSize.width: 28
                                sourceSize.height: 28
                                visible: false
                            }
                            ColorOverlay {
                                anchors.fill: storageIconImg
                                source: storageIconImg
                                color: Theme.accent
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
                                    font.pixelSize: 13
                                    font.bold: true
                                }
                                Rectangle {
                                    visible: root.indexingChanged
                                    height: 16
                                    width: selectedText1.contentWidth + 10
                                    radius: 4
                                    color: Theme.accentDim
                                    border.color: Theme.accent
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        id: selectedText1
                                        text: qsTr("Selected for application")
                                        color: Theme.accent
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
                                font.pixelSize: 10
                            }
                        }
                    }

                    Row {
                        anchors.right: parent.right
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

                Text {
                    text: qsTr("LATENCY & MOUSE TWEAKS")
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 1
                    visible: root.currentSection === "core"
                }

                Text {
                    text: qsTr("TELEMETRY")
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 1
                    visible: root.currentSection === "telemetry"
                }

                // Xbox app Panel
                AcrylicPanel {
                    id: xboxPanel
                    visible: root.currentSection === "core"
                    width: parent.width
                    height: 72

                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Item {
                                width: 28
                                height: 28
                                anchors.verticalCenter: parent.verticalCenter
                                Image {
                                    id: settingsIconImg
                                    source: "qrc:/MeguPackOptimizer/src/resources/settings.svg"
                                    anchors.fill: parent
                                    sourceSize.width: 28
                                    sourceSize.height: 28
                                    visible: false
                                }
                                ColorOverlay {
                                    anchors.fill: settingsIconImg
                                    source: settingsIconImg
                                    color: Theme.accent
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
                                    font.pixelSize: 13
                                    font.bold: true
                                }
                                Rectangle {
                                    visible: root.xboxChanged
                                    height: 16
                                    width: selectedText2.contentWidth + 10
                                    radius: 4
                                    color: Theme.accentDim
                                    border.color: Theme.accent
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        id: selectedText2
                                        text: qsTr("Selected for application")
                                        color: Theme.accent
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
                                font.pixelSize: 10
                            }
                        }
                    }

                    Row {
                        anchors.right: parent.right
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
                    height: 72

                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Item {
                            width: 28
                            height: 28
                            anchors.verticalCenter: parent.verticalCenter
                            Image {
                                id: monitorIconImg
                                source: "qrc:/MeguPackOptimizer/src/resources/monitor.svg"
                                anchors.fill: parent
                                sourceSize.width: 28
                                sourceSize.height: 28
                                visible: false
                            }
                            ColorOverlay {
                                anchors.fill: monitorIconImg
                                source: monitorIconImg
                                color: Theme.accent
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                text: qsTr("Multi-Plane Overlay (MPO)")
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: 13
                                font.bold: true
                            }

                            Text {
                                text: qsTr("Configure DWM multi-plane overlay modes to optimize latency and eliminate game stuttering.")
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                            }
                        }
                    }

                    Row {
                        anchors.right: parent.right
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

                // Core Isolation Panel
                AcrylicPanel {
                    id: coreIsolationPanel
                    visible: root.currentSection === "core"
                    width: parent.width
                    height: 72

                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Item {
                            width: 28
                            height: 28
                            anchors.verticalCenter: parent.verticalCenter
                            Image {
                                id: coresIconImg
                                source: "qrc:/MeguPackOptimizer/src/resources/cores.svg"
                                anchors.fill: parent
                                sourceSize.width: 28
                                sourceSize.height: 28
                                visible: false
                            }
                            ColorOverlay {
                                anchors.fill: coresIconImg
                                source: coresIconImg
                                color: Theme.accent
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
                                    font.pixelSize: 13
                                    font.bold: true
                                }
                                Rectangle {
                                    visible: root.coreIsolationChanged
                                    height: 16
                                    width: selectedText3.contentWidth + 10
                                    radius: 4
                                    color: Theme.accentDim
                                    border.color: Theme.accent
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        id: selectedText3
                                        text: qsTr("Selected for application")
                                        color: Theme.accent
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
                                font.pixelSize: 10
                            }
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 16

                        Text {
                            text: qsTr("Show Path")
                            color: ciPathMouse.containsMouse ? Theme.accentLight : Theme.accent
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.bold: true
                            font.underline: true
                            anchors.verticalCenter: parent.verticalCenter
                            MouseArea {
                                id: ciPathMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: { optimizerBackend.showPath("coreisolation"); }
                            }
                        }

                        MeguSwitch {
                            checked: optimizerBackend.coreIsolationActive
                            anchors.verticalCenter: parent.verticalCenter
                            onToggled: (isChecked) => {
                                optimizerBackend.coreIsolationActive = isChecked;
                            }
                        }
                    }
                }

                // Mouse Acceleration Panel
                AcrylicPanel {
                    id: mouseAccelerationPanel
                    visible: root.currentSection === "core"
                    width: parent.width
                    height: 72

                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Item {
                            width: 28
                            height: 28
                            anchors.verticalCenter: parent.verticalCenter
                            Image {
                                id: mouseIconImg
                                source: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"
                                anchors.fill: parent
                                sourceSize.width: 28
                                sourceSize.height: 28
                                visible: false
                            }
                            ColorOverlay {
                                anchors.fill: mouseIconImg
                                source: mouseIconImg
                                color: Theme.accent
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
                                    font.pixelSize: 13
                                    font.bold: true
                                }
                                Rectangle {
                                    visible: root.mouseAccelerationChanged
                                    height: 16
                                    width: selectedText4.contentWidth + 10
                                    radius: 4
                                    color: Theme.accentDim
                                    border.color: Theme.accent
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        id: selectedText4
                                        text: qsTr("Selected for application")
                                        color: Theme.accent
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
                                font.pixelSize: 10
                            }
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 16

                        Text {
                            text: qsTr("Show Path")
                            color: mousePathMouse.containsMouse ? Theme.accentLight : Theme.accent
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.bold: true
                            font.underline: true
                            anchors.verticalCenter: parent.verticalCenter
                            MouseArea {
                                id: mousePathMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: { optimizerBackend.showPath("mouseacceleration"); }
                            }
                        }

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
                    height: 72

                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Item {
                            width: 28
                            height: 28
                            anchors.verticalCenter: parent.verticalCenter
                            Image {
                                id: gameModeIconImg
                                source: "qrc:/MeguPackOptimizer/src/resources/bolt.svg"
                                anchors.fill: parent
                                sourceSize.width: 28
                                sourceSize.height: 28
                                visible: false
                            }
                            ColorOverlay {
                                anchors.fill: gameModeIconImg
                                source: gameModeIconImg
                                color: Theme.accent
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
                                    font.pixelSize: 13
                                    font.bold: true
                                }
                                Rectangle {
                                    visible: root.gameModeChanged
                                    height: 16
                                    width: selectedText5.contentWidth + 10
                                    radius: 4
                                    color: Theme.accentDim
                                    border.color: Theme.accent
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        id: selectedText5
                                        text: qsTr("Selected for application")
                                        color: Theme.accent
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
                                font.pixelSize: 10
                            }
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 16

                        Text {
                            text: qsTr("Show Path")
                            color: gameModePathMouse.containsMouse ? Theme.accentLight : Theme.accent
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.bold: true
                            font.underline: true
                            anchors.verticalCenter: parent.verticalCenter
                            MouseArea {
                                id: gameModePathMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: { optimizerBackend.showPath("gamemode"); }
                            }
                        }

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
                    height: root.isDiscordOpen ? 84 : 72
                    Behavior on height { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.InOutQuad } }

                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Item {
                            width: 28
                            height: 28
                            anchors.verticalCenter: parent.verticalCenter
                            Image {
                                id: discordIconImg
                                source: "qrc:/MeguPackOptimizer/src/resources/folder.svg"
                                anchors.fill: parent
                                sourceSize.width: 28
                                sourceSize.height: 28
                                visible: false
                            }
                            ColorOverlay {
                                anchors.fill: discordIconImg
                                source: discordIconImg
                                color: Theme.accent
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
                                    font.pixelSize: 13
                                    font.bold: true
                                }
                                Rectangle {
                                    visible: root.discordOverlayChanged
                                    height: 16
                                    width: selectedTextDiscord.contentWidth + 10
                                    radius: 4
                                    color: Theme.accentDim
                                    border.color: Theme.accent
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        id: selectedTextDiscord
                                        text: qsTr("Selected for application")
                                        color: Theme.accent
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
                                font.pixelSize: 10
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
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 16

                        Text {
                            text: qsTr("Show Path")
                            color: discordPathMouse.containsMouse ? Theme.accentLight : Theme.accent
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.bold: true
                            font.underline: true
                            anchors.verticalCenter: parent.verticalCenter
                            MouseArea {
                                id: discordPathMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: { optimizerBackend.showPath("discord"); }
                            }
                        }

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
                    height: 72

                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Item {
                            width: 28
                            height: 28
                            anchors.verticalCenter: parent.verticalCenter
                            Image {
                                id: firewallIconImg
                                source: "qrc:/MeguPackOptimizer/src/resources/warning.svg"
                                anchors.fill: parent
                                sourceSize.width: 28
                                sourceSize.height: 28
                                visible: false
                            }
                            ColorOverlay {
                                anchors.fill: firewallIconImg
                                source: firewallIconImg
                                color: Theme.accent
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
                                    font.pixelSize: 13
                                    font.bold: true
                                }
                                Rectangle {
                                    visible: root.firewallChanged
                                    height: 16
                                    width: selectedText6.contentWidth + 10
                                    radius: 4
                                    color: Theme.accentDim
                                    border.color: Theme.accent
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        id: selectedText6
                                        text: qsTr("Selected for application")
                                        color: Theme.accent
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
                                font.pixelSize: 10
                            }
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 16

                        Text {
                            text: qsTr("Show Path")
                            color: firewallPathMouse.containsMouse ? Theme.accentLight : Theme.accent
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.bold: true
                            font.underline: true
                            anchors.verticalCenter: parent.verticalCenter
                            MouseArea {
                                id: firewallPathMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: { optimizerBackend.showPath("firewall"); }
                            }
                        }

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
                    height: 72

                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Item {
                            width: 28
                            height: 28
                            anchors.verticalCenter: parent.verticalCenter
                            Image {
                                id: remoteAccessIconImg
                                source: "qrc:/MeguPackOptimizer/src/resources/play.svg"
                                anchors.fill: parent
                                sourceSize.width: 28
                                sourceSize.height: 28
                                visible: false
                            }
                            ColorOverlay {
                                anchors.fill: remoteAccessIconImg
                                source: remoteAccessIconImg
                                color: Theme.accent
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
                                    font.pixelSize: 13
                                    font.bold: true
                                }
                                Rectangle {
                                    visible: root.remoteAccessChanged
                                    height: 16
                                    width: selectedTextRdp.contentWidth + 10
                                    radius: 4
                                    color: Theme.accentDim
                                    border.color: Theme.accent
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        id: selectedTextRdp
                                        text: qsTr("Selected for application")
                                        color: Theme.accent
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 8
                                        font.bold: true
                                        anchors.centerIn: parent
                                    }
                                }
                            }

                            Text {
                                text: qsTr("Enables or disables Remote Desktop connections (RDP) to securely connect and manage this computer from another device.")
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                            }
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 16

                        Text {
                            text: qsTr("Show Path")
                            color: remoteAccessPathMouse.containsMouse ? Theme.accentLight : Theme.accent
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.bold: true
                            font.underline: true
                            anchors.verticalCenter: parent.verticalCenter
                            MouseArea {
                                id: remoteAccessPathMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: { optimizerBackend.showPath("remoteaccess"); }
                            }
                        }

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
                    height: 72

                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Item {
                            width: 28
                            height: 28
                            anchors.verticalCenter: parent.verticalCenter
                            Image {
                                id: telemetryIconImg
                                source: "qrc:/MeguPackOptimizer/src/resources/folder.svg"
                                anchors.fill: parent
                                sourceSize.width: 28
                                sourceSize.height: 28
                                visible: false
                            }
                            ColorOverlay {
                                anchors.fill: telemetryIconImg
                                source: telemetryIconImg
                                color: Theme.accent
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
                                    font.pixelSize: 13
                                    font.bold: true
                                }
                                Rectangle {
                                    visible: root.telemetryChanged
                                    height: 16
                                    width: selectedTextTelemetry.contentWidth + 10
                                    radius: 4
                                    color: Theme.accentDim
                                    border.color: Theme.accent
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        id: selectedTextTelemetry
                                        text: qsTr("Selected for application")
                                        color: Theme.accent
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 8
                                        font.bold: true
                                        anchors.centerIn: parent
                                    }
                                }
                            }

                            Text {
                                text: qsTr("Disables system diagnostic data collection, CEIP telemetry policies, error reporting, and Connected User Experiences services.")
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                            }
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 16

                        Text {
                            text: qsTr("Show Path")
                            color: telemetryPathMouse.containsMouse ? Theme.accentLight : Theme.accent
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.bold: true
                            font.underline: true
                            anchors.verticalCenter: parent.verticalCenter
                            MouseArea {
                                id: telemetryPathMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: { optimizerBackend.showPath("telemetry"); }
                            }
                        }

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

                // Windows Update Panel
                AcrylicPanel {
                    id: windowsUpdatePanel
                    visible: root.currentSection === "core"
                    width: parent.width
                    height: 72

                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Item {
                            width: 28
                            height: 28
                            anchors.verticalCenter: parent.verticalCenter
                            Image {
                                id: wuIconImg
                                source: "qrc:/MeguPackOptimizer/src/resources/settings.svg"
                                anchors.fill: parent
                                sourceSize.width: 28
                                sourceSize.height: 28
                                visible: false
                            }
                            ColorOverlay {
                                anchors.fill: wuIconImg
                                source: wuIconImg
                                color: Theme.accent
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
                                    font.pixelSize: 13
                                    font.bold: true
                                }
                                Rectangle {
                                    visible: root.windowsUpdateChanged
                                    height: 16
                                    width: selectedTextWU.contentWidth + 10
                                    radius: 4
                                    color: Theme.accentDim
                                    border.color: Theme.accent
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        id: selectedTextWU
                                        text: qsTr("Selected for application")
                                        color: Theme.accent
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 8
                                        font.bold: true
                                        anchors.centerIn: parent
                                    }
                                }
                            }

                            Text {
                                text: qsTr("Configure system update modes: enable all, only security patches, manual check, or disable updates entirely.")
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                            }
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 16

                        Text {
                            text: qsTr("Show Path")
                            color: wuPathMouse.containsMouse ? Theme.accentLight : Theme.accent
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.bold: true
                            font.underline: true
                            anchors.verticalCenter: parent.verticalCenter
                            MouseArea {
                                id: wuPathMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: { optimizerBackend.showPath("windowsupdate"); }
                            }
                        }

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

                // Printer Panel
                AcrylicPanel {
                    id: printerPanel
                    visible: root.currentSection === "core"
                    width: parent.width
                    height: 72

                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Item {
                            width: 28
                            height: 28
                            anchors.verticalCenter: parent.verticalCenter
                            Image {
                                id: printerIconImg
                                source: "qrc:/MeguPackOptimizer/src/resources/settings.svg"
                                anchors.fill: parent
                                sourceSize.width: 28
                                sourceSize.height: 28
                                visible: false
                            }
                            ColorOverlay {
                                anchors.fill: printerIconImg
                                source: printerIconImg
                                color: Theme.accent
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Row {
                                spacing: 8
                                Text {
                                    text: qsTr("Print Spooler (Printer)")
                                    color: Theme.textPrimary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 13
                                    font.bold: true
                                }
                                Rectangle {
                                    visible: root.printerChanged
                                    height: 16
                                    width: selectedText7.contentWidth + 10
                                    radius: 4
                                    color: Theme.accentDim
                                    border.color: Theme.accent
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        id: selectedText7
                                        text: qsTr("Selected for application")
                                        color: Theme.accent
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 8
                                        font.bold: true
                                        anchors.centerIn: parent
                                    }
                                }
                            }

                            Text {
                                text: qsTr("Disabling the print spooler frees memory and reduces background latency for gaming.")
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                            }
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 16

                        Text {
                            text: qsTr("Show Path")
                            color: printerPathMouse.containsMouse ? Theme.accentLight : Theme.accent
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.bold: true
                            font.underline: true
                            anchors.verticalCenter: parent.verticalCenter
                            MouseArea {
                                id: printerPathMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: { optimizerBackend.showPath("printer"); }
                            }
                        }

                        MeguSwitch {
                            checked: optimizerBackend.printerActive
                            anchors.verticalCenter: parent.verticalCenter
                            onToggled: (isChecked) => {
                                optimizerBackend.printerActive = isChecked;
                            }
                        }

                        // Arrow button that slides right on hover & opens sidebar drawer for printers list
                        Rectangle {
                            width: 32
                            height: 32
                            radius: 16
                            color: printerArrowMouseArea.containsMouse ? Theme.accentDim : "transparent"
                            border.color: printerArrowMouseArea.containsMouse ? Theme.accent : Theme.border
                            border.width: 1
                            anchors.verticalCenter: parent.verticalCenter

                            Behavior on color { ColorAnimation { duration: Theme.animFast } }
                            Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                            Item {
                                width: 14
                                height: 14
                                anchors.centerIn: parent
                                x: printerArrowMouseArea.containsMouse ? (parent.width/2 - 5) : (parent.width/2 - 7)
                                Behavior on x { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }
                                Image {
                                    id: printerArrowImg
                                    source: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"
                                    anchors.fill: parent
                                    sourceSize.width: 14
                                    sourceSize.height: 14
                                    visible: false
                                }
                                ColorOverlay {
                                    anchors.fill: printerArrowImg
                                    source: printerArrowImg
                                    color: printerArrowMouseArea.containsMouse ? Theme.accent : Theme.textSecondary
                                }
                            }

                            MouseArea {
                                id: printerArrowMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.activeDrawer = "printer";
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
                    height: 72

                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Item {
                            width: 28
                            height: 28
                            anchors.verticalCenter: parent.verticalCenter
                            Image {
                                id: notificationsIconImg
                                source: "qrc:/MeguPackOptimizer/src/resources/info.svg"
                                anchors.fill: parent
                                sourceSize.width: 28
                                sourceSize.height: 28
                                visible: false
                            }
                            ColorOverlay {
                                anchors.fill: notificationsIconImg
                                source: notificationsIconImg
                                color: Theme.accent
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
                                    font.pixelSize: 13
                                    font.bold: true
                                }
                                Rectangle {
                                    visible: root.notificationsChanged
                                    height: 16
                                    width: selectedText8.contentWidth + 10
                                    radius: 4
                                    color: Theme.accentDim
                                    border.color: Theme.accent
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        id: selectedText8
                                        text: qsTr("Selected for application")
                                        color: Theme.accent
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
                                font.pixelSize: 10
                            }
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 16

                        Text {
                            text: qsTr("Show Path")
                            color: notificationsPathMouse.containsMouse ? Theme.accentLight : Theme.accent
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.bold: true
                            font.underline: true
                            anchors.verticalCenter: parent.verticalCenter
                            MouseArea {
                                id: notificationsPathMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: { optimizerBackend.showPath("notifications"); }
                            }
                        }

                        MeguSwitch {
                            checked: optimizerBackend.notificationsActive
                            anchors.verticalCenter: parent.verticalCenter
                            onToggled: (isChecked) => {
                                optimizerBackend.notificationsActive = isChecked;
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

            // 3. HIBERNATION CATEGORY
            Column {
                visible: root.currentSection === "core"
                width: parent.width
                spacing: 8

                Text {
                    text: qsTr("POWER & STORAGE")
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 1
                }

                AcrylicPanel {
                    id: hibernationPanel
                    width: parent.width
                    height: 72

                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Item {
                            width: 28
                            height: 28
                            anchors.verticalCenter: parent.verticalCenter
                            Image {
                                id: cpuIconImg
                                source: "qrc:/MeguPackOptimizer/src/resources/cpu.svg"
                                anchors.fill: parent
                                sourceSize.width: 28
                                sourceSize.height: 28
                                visible: false
                            }
                            ColorOverlay {
                                anchors.fill: cpuIconImg
                                source: cpuIconImg
                                color: Theme.accent
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
                                    font.pixelSize: 13
                                    font.bold: true
                                }
                                Rectangle {
                                    visible: root.hibernationChanged
                                    height: 16
                                    width: selectedText9.contentWidth + 10
                                    radius: 4
                                    color: Theme.accentDim
                                    border.color: Theme.accent
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        id: selectedText9
                                        text: qsTr("Selected for application")
                                        color: Theme.accent
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 8
                                        font.bold: true
                                        anchors.centerIn: parent
                                    }
                                }
                            }

                            Text {
                                text: qsTr("Enable or disable Windows hibernation mode to free up disk space.")
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                            }
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 16

                        Text {
                            text: qsTr("Show Path")
                            color: hibernationPathMouse.containsMouse ? Theme.accentLight : Theme.accent
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.bold: true
                            font.underline: true
                            anchors.verticalCenter: parent.verticalCenter
                            MouseArea {
                                id: hibernationPathMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: { optimizerBackend.showPath("hibernation"); }
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

                // BitLocker Card
                AcrylicPanel {
                    id: bitlockerPanel
                    width: parent.width
                    height: 80

                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Item {
                            width: 28
                            height: 28
                            anchors.verticalCenter: parent.verticalCenter
                            Image {
                                id: bitlockerIconImg
                                source: "qrc:/MeguPackOptimizer/src/resources/info.svg"
                                anchors.fill: parent
                                sourceSize.width: 28
                                sourceSize.height: 28
                                visible: false
                            }
                            ColorOverlay {
                                anchors.fill: bitlockerIconImg
                                source: bitlockerIconImg
                                color: Theme.accent
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
                                    font.pixelSize: 13
                                    font.bold: true
                                }
                                Rectangle {
                                    visible: root.bitlockerChanged
                                    height: 16
                                    width: selectedTextBitLocker.contentWidth + 10
                                    radius: 4
                                    color: Theme.accentDim
                                    border.color: Theme.accent
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        id: selectedTextBitLocker
                                        text: qsTr("Selected for application")
                                        color: Theme.accent
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 8
                                        font.bold: true
                                        anchors.centerIn: parent
                                    }
                                }
                            }

                            Text {
                                text: qsTr("Enable or disable the BitLocker drive encryption background manager service.")
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                            }

                            Text {
                                text: qsTr("Status: Service: %1 | Encryption (C:): %2")
                                      .arg(optimizerBackend.bitlockerActive ? qsTr("Active") : qsTr("Disabled"))
                                      .arg(optimizerBackend.bitlockerDriveEncrypted ? qsTr("Encrypted") : qsTr("Not Encrypted"))
                                color: Theme.accent
                                font.family: Theme.fontFamily
                                font.pixelSize: 9
                                font.bold: true
                            }
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 16

                        Text {
                            text: qsTr("Show Path")
                            color: bitlockerPathMouse.containsMouse ? Theme.accentLight : Theme.accent
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.bold: true
                            font.underline: true
                            anchors.verticalCenter: parent.verticalCenter
                            MouseArea {
                                id: bitlockerPathMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: { optimizerBackend.showPath("bitlocker"); }
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
                    height: !optimizerBackend.defenderActive ? 84 : 72
                    Behavior on height { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.InOutQuad } }

                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Item {
                            width: 28
                            height: 28
                            anchors.verticalCenter: parent.verticalCenter
                            Image {
                                id: defenderIconImg
                                source: "qrc:/MeguPackOptimizer/src/resources/warning.svg"
                                anchors.fill: parent
                                sourceSize.width: 28
                                sourceSize.height: 28
                                visible: false
                            }
                            ColorOverlay {
                                anchors.fill: defenderIconImg
                                source: defenderIconImg
                                color: Theme.accent
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
                                    font.pixelSize: 13
                                    font.bold: true
                                }
                                Rectangle {
                                    visible: root.defenderChanged
                                    height: 16
                                    width: selectedTextDefender.contentWidth + 10
                                    radius: 4
                                    color: Theme.accentDim
                                    border.color: Theme.accent
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        id: selectedTextDefender
                                        text: qsTr("Selected for application")
                                        color: Theme.accent
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
                                font.pixelSize: 10
                            }

                            Text {
                                visible: !optimizerBackend.defenderActive
                                text: qsTr("Note: Requires disabling Tamper Protection.")
                                color: Theme.warning
                                font.family: Theme.fontFamily
                                font.pixelSize: 9
                                font.bold: true
                            }
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 16

                        Text {
                            text: qsTr("Show Path")
                            color: defenderPathMouse.containsMouse ? Theme.accentLight : Theme.accent
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.bold: true
                            font.underline: true
                            anchors.verticalCenter: parent.verticalCenter
                            MouseArea {
                                id: defenderPathMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: { optimizerBackend.showPath("defender"); }
                            }
                        }

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
                            checked: optimizerBackend.defenderActive
                            anchors.verticalCenter: parent.verticalCenter
                            onToggled: (isChecked) => {
                                optimizerBackend.defenderActive = isChecked;
                            }
                        }
                    }
                }

                // Power Plan Card
                AcrylicPanel {
                    id: powerPlanPanel
                    width: parent.width
                    height: 72

                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Item {
                            width: 28
                            height: 28
                            anchors.verticalCenter: parent.verticalCenter
                            Image {
                                id: powerIconImg
                                source: "qrc:/MeguPackOptimizer/src/resources/bolt.svg"
                                anchors.fill: parent
                                sourceSize.width: 28
                                sourceSize.height: 28
                                visible: false
                            }
                            ColorOverlay {
                                anchors.fill: powerIconImg
                                source: powerIconImg
                                color: Theme.accent
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
                                    font.pixelSize: 13
                                    font.bold: true
                                }
                                Rectangle {
                                    visible: root.powerPlanChanged
                                    height: 16
                                    width: selectedText10.contentWidth + 10
                                    radius: 4
                                    color: Theme.accentDim
                                    border.color: Theme.accent
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        id: selectedText10
                                        text: qsTr("Selected for application")
                                        color: Theme.accent
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 8
                                        font.bold: true
                                        anchors.centerIn: parent
                                    }
                                }
                            }

                            Text {
                                text: qsTr("Select system power plans and unlock the hidden Ultimate Performance mode.")
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                            }
                        }
                    }

                    Row {
                        anchors.right: parent.right
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
                    height: 72

                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Item {
                            width: 28
                            height: 28
                            anchors.verticalCenter: parent.verticalCenter
                            Image {
                                id: usbIconImg
                                source: "qrc:/MeguPackOptimizer/src/resources/bolt.svg"
                                anchors.fill: parent
                                sourceSize.width: 28
                                sourceSize.height: 28
                                visible: false
                            }
                            ColorOverlay {
                                anchors.fill: usbIconImg
                                source: usbIconImg
                                color: Theme.accent
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
                                    font.pixelSize: 13
                                    font.bold: true
                                }
                                Rectangle {
                                    visible: root.usbPowerSavingChanged
                                    height: 16
                                    width: selectedTextUsb.contentWidth + 10
                                    radius: 4
                                    color: Theme.accentDim
                                    border.color: Theme.accent
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text {
                                        id: selectedTextUsb
                                        text: qsTr("Selected for application")
                                        color: Theme.accent
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
                                font.pixelSize: 10
                            }
                        }
                    }

                    Row {
                        anchors.right: parent.right
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
                            checked: optimizerBackend.usbPowerSavingActive
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
        width: 320
        height: parent.height
        anchors.right: parent.right
        anchors.rightMargin: root.sidebarOpen ? 0 : -width
        color: Theme.sidebarBg
        border.color: Theme.border
        border.width: 1
        z: 160

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
                            if (root.activeDrawer === "printer") return qsTr("PRINTER TWEAKS");
                            if (root.activeDrawer === "notifications") return qsTr("NOTIFICATION SETTINGS");
                            if (root.activeDrawer === "power") return qsTr("POWER PLANS");
                            if (root.activeDrawer === "defender") return qsTr("WINDOWS DEFENDER");
                            if (root.activeDrawer === "usb") return qsTr("USB 3.0 POWER SAVING");
                            if (root.activeDrawer === "telemetry") return qsTr("TELEMETRY SETTINGS");
                            if (root.activeDrawer === "windowsUpdate") return qsTr("WINDOWS UPDATE");
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
                    contentHeight: {
                        if (root.activeDrawer === "indexing") return indexingColumn.implicitHeight;
                        if (root.activeDrawer === "xbox") return xboxColumn.implicitHeight;
                        if (root.activeDrawer === "mpo") return mpoColumn.implicitHeight;
                        if (root.activeDrawer === "printer") return printerColumn.implicitHeight;
                        if (root.activeDrawer === "notifications") return notificationsColumn.implicitHeight;
                        if (root.activeDrawer === "power") return powerColumn.implicitHeight;
                        if (root.activeDrawer === "defender") return defenderColumn.implicitHeight;
                        if (root.activeDrawer === "usb") return usbColumn.implicitHeight;
                        if (root.activeDrawer === "telemetry") return telemetryColumn.implicitHeight;
                        if (root.activeDrawer === "windowsUpdate") return windowsUpdateColumn.implicitHeight;
                        return height;
                    }

                    // 1. Indexing Options Content
                    Column {
                        id: indexingColumn
                        width: parent.width
                        spacing: 20
                        visible: root.activeDrawer === "indexing"

                        // Search service
                        Row {
                            width: parent.width
                            spacing: 12
                            MeguSwitch {
                                text: qsTr("Windows Search service")
                                checked: optimizerBackend.winSearchActive
                                onToggled: (isChecked) => { optimizerBackend.winSearchActive = isChecked; }
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: qsTr("Show Path")
                                color: sidebarSearchMouse.containsMouse ? Theme.accentLight : Theme.accent
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                font.bold: true
                                font.underline: true
                                anchors.verticalCenter: parent.verticalCenter
                                MouseArea {
                                    id: sidebarSearchMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: { optimizerBackend.showPath("Windows Search service"); }
                                }
                            }
                        }

                        // Drive C
                        Row {
                            width: parent.width
                            spacing: 12
                            MeguSwitch {
                                text: qsTr("Drive C: indexing")
                                checked: !!optimizerBackend.driveStates["C:"]
                                onToggled: (isChecked) => {
                                    var states = optimizerBackend.driveStates;
                                    states["C:"] = isChecked;
                                    optimizerBackend.driveStates = states;
                                }
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: qsTr("Show Path")
                                color: sidebarCMouse.containsMouse ? Theme.accentLight : Theme.accent
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                font.bold: true
                                font.underline: true
                                anchors.verticalCenter: parent.verticalCenter
                                MouseArea {
                                    id: sidebarCMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: { optimizerBackend.showPath("C:"); }
                                }
                            }
                        }

                        // Fixed drives repeater
                        Repeater {
                            model: optimizerBackend.fixedDrives
                            delegate: Row {
                                width: parent.width
                                spacing: 12
                                MeguSwitch {
                                    text: qsTr("Drive %1 indexing").arg(modelData)
                                    checked: !!optimizerBackend.driveStates[modelData]
                                    onToggled: (isChecked) => {
                                        var states = optimizerBackend.driveStates;
                                        states[modelData] = isChecked;
                                        optimizerBackend.driveStates = states;
                                    }
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    text: qsTr("Show Path")
                                    color: sidebarDriveMouse.containsMouse ? Theme.accentLight : Theme.accent
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    font.bold: true
                                    font.underline: true
                                    anchors.verticalCenter: parent.verticalCenter
                                    MouseArea {
                                        id: sidebarDriveMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: { optimizerBackend.showPath(modelData); }
                                    }
                                }
                            }
                        }
                    }

                    // 2. Xbox Options Content
                    Column {
                        id: xboxColumn
                        width: parent.width
                        spacing: 16
                        visible: root.activeDrawer === "xbox"

                        // Global action header
                        Column {
                            width: parent.width
                            spacing: 8
                            Text {
                                text: qsTr("Xbox Suite (Bulk Actions)")
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                font.bold: true
                            }
                            Text {
                                text: qsTr("Purge or restore the entire Xbox app and telemetry suite for maximum performance.")
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 9
                                wrapMode: Text.Wrap
                                width: parent.width
                            }
                        }

                        Row {
                            spacing: 10
                            width: parent.width
                            MeguButton {
                                text: qsTr("Remove All")
                                iconSource: "qrc:/MeguPackOptimizer/src/resources/close.svg"
                                accented: optimizerBackend.xboxInstalled
                                enabled: optimizerBackend.xboxInstalled && !optimizerBackend.isOptimizingSystem
                                width: (parent.width - 10) / 2
                                height: 32
                                onClicked: {
                                    root.activeDrawer = "";
                                    stepLogModel.clear();
                                    optimizerBackend.removeXboxEntirely();
                                }
                            }
                            MeguButton {
                                text: qsTr("Restore All")
                                iconSource: "qrc:/MeguPackOptimizer/src/resources/play.svg"
                                accented: !optimizerBackend.xboxInstalled
                                enabled: !optimizerBackend.isOptimizingSystem
                                width: (parent.width - 10) / 2
                                height: 32
                                onClicked: {
                                    root.activeDrawer = "";
                                    stepLogModel.clear();
                                    optimizerBackend.restoreXboxEntirely();
                                }
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 1
                            color: Theme.border
                        }

                        // Individual component list title
                        Text {
                            text: qsTr("Individual Packages")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.bold: true
                        }

                        // Individual component list
                        Column {
                            width: parent.width
                            spacing: 12

                            // 1. Xbox App
                            Row {
                                width: parent.width
                                spacing: 6
                                Column {
                                    width: parent.width - 144
                                    spacing: 2
                                    Text {
                                        text: qsTr("Xbox App")
                                        color: Theme.textPrimary
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                    Text {
                                        text: qsTr("Get-AppxPackage XboxApp | ...")
                                        color: Theme.textMuted
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 8
                                        font.italic: true
                                    }
                                }
                                MeguButton {
                                    text: qsTr("Restore")
                                    accented: false
                                    enabled: !optimizerBackend.xboxAppInstalled && !optimizerBackend.isOptimizingSystem
                                    width: 66
                                    height: 26
                                    onClicked: {
                                        stepLogModel.clear();
                                        optimizerBackend.restoreXboxComponent("XboxApp");
                                    }
                                }
                                MeguButton {
                                    text: qsTr("Remove")
                                    accented: true
                                    enabled: optimizerBackend.xboxAppInstalled && !optimizerBackend.isOptimizingSystem
                                    width: 66
                                    height: 26
                                    onClicked: {
                                        stepLogModel.clear();
                                        optimizerBackend.removeXboxComponent("XboxApp");
                                    }
                                }
                            }

                            // 2. Xbox Gaming Overlay
                            Row {
                                width: parent.width
                                spacing: 6
                                Column {
                                    width: parent.width - 144
                                    spacing: 2
                                    Text {
                                        text: qsTr("Xbox Gaming Overlay")
                                        color: Theme.textPrimary
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                    Text {
                                        text: qsTr("Get-AppxPackage XboxGamingOverlay | ...")
                                        color: Theme.textMuted
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 8
                                        font.italic: true
                                    }
                                }
                                MeguButton {
                                    text: qsTr("Restore")
                                    accented: false
                                    enabled: !optimizerBackend.xboxGamingOverlayInstalled && !optimizerBackend.isOptimizingSystem
                                    width: 66
                                    height: 26
                                    onClicked: {
                                        stepLogModel.clear();
                                        optimizerBackend.restoreXboxComponent("XboxGamingOverlay");
                                    }
                                }
                                MeguButton {
                                    text: qsTr("Remove")
                                    accented: true
                                    enabled: optimizerBackend.xboxGamingOverlayInstalled && !optimizerBackend.isOptimizingSystem
                                    width: 66
                                    height: 26
                                    onClicked: {
                                        stepLogModel.clear();
                                        optimizerBackend.removeXboxComponent("XboxGamingOverlay");
                                    }
                                }
                            }

                            // 3. Xbox TCUI
                            Row {
                                width: parent.width
                                spacing: 6
                                Column {
                                    width: parent.width - 144
                                    spacing: 2
                                    Text {
                                        text: qsTr("Xbox TCUI Dialogue")
                                        color: Theme.textPrimary
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                    Text {
                                        text: qsTr("Get-AppxPackage XboxTCUI | ...")
                                        color: Theme.textMuted
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 8
                                        font.italic: true
                                    }
                                }
                                MeguButton {
                                    text: qsTr("Restore")
                                    accented: false
                                    enabled: !optimizerBackend.xboxTcuiInstalled && !optimizerBackend.isOptimizingSystem
                                    width: 66
                                    height: 26
                                    onClicked: {
                                        stepLogModel.clear();
                                        optimizerBackend.restoreXboxComponent("XboxTCUI");
                                    }
                                }
                                MeguButton {
                                    text: qsTr("Remove")
                                    accented: true
                                    enabled: optimizerBackend.xboxTcuiInstalled && !optimizerBackend.isOptimizingSystem
                                    width: 66
                                    height: 26
                                    onClicked: {
                                        stepLogModel.clear();
                                        optimizerBackend.removeXboxComponent("XboxTCUI");
                                    }
                                }
                            }

                            // 4. Xbox Game Speech Window
                            Row {
                                width: parent.width
                                spacing: 6
                                Column {
                                    width: parent.width - 144
                                    spacing: 2
                                    Text {
                                        text: qsTr("Xbox Game Speech Window")
                                        color: Theme.textPrimary
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                    Text {
                                        text: qsTr("Get-AppxPackage XboxGameSpeechWindow | ...")
                                        color: Theme.textMuted
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 8
                                        font.italic: true
                                    }
                                }
                                MeguButton {
                                    text: qsTr("Restore")
                                    accented: false
                                    enabled: !optimizerBackend.xboxSpeechWindowInstalled && !optimizerBackend.isOptimizingSystem
                                    width: 66
                                    height: 26
                                    onClicked: {
                                        stepLogModel.clear();
                                        optimizerBackend.restoreXboxComponent("XboxGameSpeechWindow");
                                    }
                                }
                                MeguButton {
                                    text: qsTr("Remove")
                                    accented: true
                                    enabled: optimizerBackend.xboxSpeechWindowInstalled && !optimizerBackend.isOptimizingSystem
                                    width: 66
                                    height: 26
                                    onClicked: {
                                        stepLogModel.clear();
                                        optimizerBackend.removeXboxComponent("XboxGameSpeechWindow");
                                    }
                                }
                            }

                            // 5. System Provisioned Packages
                            Row {
                                width: parent.width
                                spacing: 6
                                Column {
                                    width: parent.width - 144
                                    spacing: 2
                                    Text {
                                        text: qsTr("System Provisioned Packages")
                                        color: Theme.textPrimary
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                    Text {
                                        text: qsTr("Get-AppxProvisionedPackage -Online | ...")
                                        color: Theme.textMuted
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 8
                                        font.italic: true
                                    }
                                }
                                MeguButton {
                                    text: qsTr("Restore")
                                    accented: false
                                    enabled: !optimizerBackend.xboxInstalled && !optimizerBackend.isOptimizingSystem
                                    width: 66
                                    height: 26
                                    onClicked: {
                                        stepLogModel.clear();
                                        optimizerBackend.restoreXboxComponent("AllUsersAndProvisioned");
                                    }
                                }
                                MeguButton {
                                    text: qsTr("Remove")
                                    accented: true
                                    enabled: optimizerBackend.xboxInstalled && !optimizerBackend.isOptimizingSystem
                                    width: 66
                                    height: 26
                                    onClicked: {
                                        stepLogModel.clear();
                                        optimizerBackend.removeXboxComponent("AllUsersAndProvisioned");
                                    }
                                }
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 1
                            color: Theme.border
                        }

                        Column {
                            width: parent.width
                            spacing: 8
                            MeguSwitch {
                                text: qsTr("Disable Game Bar Popup")
                                checked: !optimizerBackend.gamingOverlayActive
                                onToggled: (isChecked) => {
                                    optimizerBackend.gamingOverlayActive = !isChecked;
                                }
                            }
                            Text {
                                text: qsTr("Neutralize ms-gamingoverlay triggers to stop 'You'll need a new app to open this link' errors when launching games.")
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 9
                                wrapMode: Text.Wrap
                                width: parent.width
                            }
                        }
                    }

                    // 3. MPO Options Content
                    Column {
                        id: mpoColumn
                        width: parent.width
                        spacing: 20
                        visible: root.activeDrawer === "mpo"

                        Column {
                            width: parent.width
                            spacing: 8
                            Text {
                                text: qsTr("Multi-Plane Overlay Value")
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                font.bold: true
                            }
                            Text {
                                text: qsTr("Choose any MPO overlay flag from 0 to 5. 5 disables MPO completely to resolve driver bugs, while 0 restores Windows default.")
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                                wrapMode: Text.Wrap
                                width: parent.width
                            }
                        }

                        Column {
                            id: mpoContainer
                            spacing: 16
                            width: parent.width
                            
                            property int selectedVal: optimizerBackend.mpoValue

                            Grid {
                                columns: 2
                                spacing: 10
                                width: parent.width

                                // Row 0
                                Row {
                                    spacing: 6
                                    width: (parent.width - 10) / 2
                                    MeguButton {
                                        text: "0"
                                        width: parent.width - 24
                                        height: 32
                                        accented: mpoContainer.selectedVal === 0
                                        onClicked: mpoContainer.selectedVal = 0
                                    }
                                    Image {
                                        source: "qrc:/MeguPackOptimizer/src/resources/help.svg"
                                        width: 18
                                        height: 18
                                        sourceSize.width: 18
                                        sourceSize.height: 18
                                        anchors.verticalCenter: parent.verticalCenter
                                        opacity: helpMouse0.containsMouse ? 1.0 : 0.6
                                        Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
                                        MouseArea {
                                            id: helpMouse0
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: mpoContainer.selectedVal = 0
                                        }
                                        ToolTip {
                                            id: tip0
                                            visible: helpMouse0.containsMouse
                                            delay: 150
                                            timeout: 5000
                                            contentItem: Text {
                                                text: qsTr("0 (Default): Dynamic overlays are fully active. Lowest latency in windowed games, but causes micro-stuttering, Chromium browser lags, or black screen flickering on modern GPU drivers.")
                                                color: Theme.textPrimary
                                                font.family: Theme.fontFamily
                                                font.pixelSize: 10
                                                wrapMode: Text.Wrap
                                            }
                                            background: Rectangle {
                                                color: Theme.sidebarBg
                                                border.color: Theme.accent
                                                border.width: 1
                                                radius: 6
                                            }
                                        }
                                    }
                                }

                                // Row 1
                                Row {
                                    spacing: 6
                                    width: (parent.width - 10) / 2
                                    MeguButton {
                                        text: "1"
                                        width: parent.width - 24
                                        height: 32
                                        accented: mpoContainer.selectedVal === 1
                                        onClicked: mpoContainer.selectedVal = 1
                                    }
                                    Image {
                                        source: "qrc:/MeguPackOptimizer/src/resources/help.svg"
                                        width: 18
                                        height: 18
                                        sourceSize.width: 18
                                        sourceSize.height: 18
                                        anchors.verticalCenter: parent.verticalCenter
                                        opacity: helpMouse1.containsMouse ? 1.0 : 0.6
                                        Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
                                        MouseArea {
                                            id: helpMouse1
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: mpoContainer.selectedVal = 1
                                        }
                                        ToolTip {
                                            id: tip1
                                            visible: helpMouse1.containsMouse
                                            delay: 150
                                            timeout: 5000
                                            contentItem: Text {
                                                text: qsTr("1: Disables hardware MPO overlay promotion. Direct GPU rendering is bypassed, which can fix dual-monitor desktop stuttering.")
                                                color: Theme.textPrimary
                                                font.family: Theme.fontFamily
                                                font.pixelSize: 10
                                                wrapMode: Text.Wrap
                                            }
                                            background: Rectangle {
                                                color: Theme.sidebarBg
                                                border.color: Theme.accent
                                                border.width: 1
                                                radius: 6
                                            }
                                        }
                                    }
                                }

                                // Row 2
                                Row {
                                    spacing: 6
                                    width: (parent.width - 10) / 2
                                    MeguButton {
                                        text: "2"
                                        width: parent.width - 24
                                        height: 32
                                        accented: mpoContainer.selectedVal === 2
                                        onClicked: mpoContainer.selectedVal = 2
                                    }
                                    Image {
                                        source: "qrc:/MeguPackOptimizer/src/resources/help.svg"
                                        width: 18
                                        height: 18
                                        sourceSize.width: 18
                                        sourceSize.height: 18
                                        anchors.verticalCenter: parent.verticalCenter
                                        opacity: helpMouse2.containsMouse ? 1.0 : 0.6
                                        Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
                                        MouseArea {
                                            id: helpMouse2
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: mpoContainer.selectedVal = 2
                                        }
                                        ToolTip {
                                            id: tip2
                                            visible: helpMouse2.containsMouse
                                            delay: 150
                                            timeout: 5000
                                            contentItem: Text {
                                                text: qsTr("2: Disables software-emulated MPO overlays, forcing DWM to only allocate native hardware paths.")
                                                color: Theme.textPrimary
                                                font.family: Theme.fontFamily
                                                font.pixelSize: 10
                                                wrapMode: Text.Wrap
                                            }
                                            background: Rectangle {
                                                color: Theme.sidebarBg
                                                border.color: Theme.accent
                                                border.width: 1
                                                radius: 6
                                            }
                                        }
                                    }
                                }

                                // Row 3
                                Row {
                                    spacing: 6
                                    width: (parent.width - 10) / 2
                                    MeguButton {
                                        text: "3"
                                        width: parent.width - 24
                                        height: 32
                                        accented: mpoContainer.selectedVal === 3
                                        onClicked: mpoContainer.selectedVal = 3
                                    }
                                    Image {
                                        source: "qrc:/MeguPackOptimizer/src/resources/help.svg"
                                        width: 18
                                        height: 18
                                        sourceSize.width: 18
                                        sourceSize.height: 18
                                        anchors.verticalCenter: parent.verticalCenter
                                        opacity: helpMouse3.containsMouse ? 1.0 : 0.6
                                        Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
                                        MouseArea {
                                            id: helpMouse3
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: mpoContainer.selectedVal = 3
                                        }
                                        ToolTip {
                                            id: tip3
                                            visible: helpMouse3.containsMouse
                                            delay: 150
                                            timeout: 5000
                                            contentItem: Text {
                                                text: qsTr("3: Disables both hardware and software overlays. Forces legacy composition limits.")
                                                color: Theme.textPrimary
                                                font.family: Theme.fontFamily
                                                font.pixelSize: 10
                                                wrapMode: Text.Wrap
                                            }
                                            background: Rectangle {
                                                color: Theme.sidebarBg
                                                border.color: Theme.accent
                                                border.width: 1
                                                radius: 6
                                            }
                                        }
                                    }
                                }

                                // Row 4
                                Row {
                                    spacing: 6
                                    width: (parent.width - 10) / 2
                                    MeguButton {
                                        text: "4"
                                        width: parent.width - 24
                                        height: 32
                                        accented: mpoContainer.selectedVal === 4
                                        onClicked: mpoContainer.selectedVal = 4
                                    }
                                    Image {
                                        source: "qrc:/MeguPackOptimizer/src/resources/help.svg"
                                        width: 18
                                        height: 18
                                        sourceSize.width: 18
                                        sourceSize.height: 18
                                        anchors.verticalCenter: parent.verticalCenter
                                        opacity: helpMouse4.containsMouse ? 1.0 : 0.6
                                        Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
                                        MouseArea {
                                            id: helpMouse4
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: mpoContainer.selectedVal = 4
                                        }
                                        ToolTip {
                                            id: tip4
                                            visible: helpMouse4.containsMouse
                                            delay: 150
                                            timeout: 5000
                                            contentItem: Text {
                                                text: qsTr("4: Forces complete DWM composition. Promotes zero window structures to independent planes.")
                                                color: Theme.textPrimary
                                                font.family: Theme.fontFamily
                                                font.pixelSize: 10
                                                wrapMode: Text.Wrap
                                            }
                                            background: Rectangle {
                                                color: Theme.sidebarBg
                                                border.color: Theme.accent
                                                border.width: 1
                                                radius: 6
                                            }
                                        }
                                    }
                                }

                                // Row 5
                                Row {
                                    spacing: 6
                                    width: (parent.width - 10) / 2
                                    MeguButton {
                                        text: "5"
                                        width: parent.width - 24
                                        height: 32
                                        accented: mpoContainer.selectedVal === 5
                                        onClicked: mpoContainer.selectedVal = 5
                                    }
                                    Image {
                                        source: "qrc:/MeguPackOptimizer/src/resources/help.svg"
                                        width: 18
                                        height: 18
                                        sourceSize.width: 18
                                        sourceSize.height: 18
                                        anchors.verticalCenter: parent.verticalCenter
                                        opacity: helpMouse5.containsMouse ? 1.0 : 0.6
                                        Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
                                        MouseArea {
                                            id: helpMouse5
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: mpoContainer.selectedVal = 5
                                        }
                                        ToolTip {
                                            id: tip5
                                            visible: helpMouse5.containsMouse
                                            delay: 150
                                            timeout: 5000
                                            contentItem: Text {
                                                text: qsTr("5 (Recommended): Completely disables all MPO modes. Official NVIDIA/AMD hotfix to eliminate stuttering, browser lag, and screen flickers.")
                                                color: Theme.textPrimary
                                                font.family: Theme.fontFamily
                                                font.pixelSize: 10
                                                wrapMode: Text.Wrap
                                            }
                                            background: Rectangle {
                                                color: Theme.sidebarBg
                                                border.color: Theme.accent
                                                border.width: 1
                                                radius: 6
                                            }
                                        }
                                    }
                                }
                            }

                            // Thin divider
                            Rectangle {
                                width: parent.width
                                height: 1
                                color: Theme.border
                            }

                            // Dynamic high-fidelity explanation text
                            Text {
                                text: {
                                    if (mpoContainer.selectedVal === 0) return qsTr("0 (Default): Dynamic overlays are fully active. Lowest latency in windowed games, but causes micro-stuttering, Chromium browser lags, or black screen flickering on modern GPU drivers.");
                                    if (mpoContainer.selectedVal === 1) return qsTr("1: Disables hardware MPO overlay promotion. Direct GPU rendering is bypassed, which can fix dual-monitor desktop stuttering.");
                                    if (mpoContainer.selectedVal === 2) return qsTr("2: Disables software-emulated MPO overlays, forcing DWM to only allocate native hardware paths.");
                                    if (mpoContainer.selectedVal === 3) return qsTr("3: Disables both hardware and software overlays. Forces legacy composition limits.");
                                    if (mpoContainer.selectedVal === 4) return qsTr("4: Forces complete DWM composition. Promotes zero window structures to independent planes.");
                                    if (mpoContainer.selectedVal === 5) return qsTr("5 (Recommended): Completely disables all MPO modes. Official NVIDIA/AMD hotfix to eliminate stuttering, browser lag, and screen flickers.");
                                    return "";
                                }
                                color: Theme.textSecondary
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                                wrapMode: Text.Wrap
                                width: parent.width
                            }

                            MeguButton {
                                text: qsTr("Apply")
                                iconSource: "qrc:/MeguPackOptimizer/src/resources/play.svg"
                                accented: true
                                enabled: mpoContainer.selectedVal !== optimizerBackend.mpoValue && !optimizerBackend.isOptimizingSystem
                                width: parent.width
                                height: 38
                                onClicked: {
                                    root.activeDrawer = "";
                                    stepLogModel.clear();
                                    optimizerBackend.applyMpoValue(mpoContainer.selectedVal);
                                }
                            }
                        }
                    }

                    // 4. Printer Options Content
                    Column {
                        id: printerColumn
                        width: parent.width
                        spacing: 20
                        visible: root.activeDrawer === "printer"

                        Text {
                            text: qsTr("Detected print queues in Device Manager:")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.bold: true
                        }

                        // Display the list of detected printers
                        Column {
                            width: parent.width
                            spacing: 10

                            Repeater {
                                model: optimizerBackend.detectedPrinters
                                delegate: AcrylicPanel {
                                    width: parent.width
                                    height: 50

                                    Row {
                                        anchors.left: parent.left
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.leftMargin: 12
                                        spacing: 12

                                        Item {
                                            width: 20
                                            height: 20
                                            anchors.verticalCenter: parent.verticalCenter
                                            Image {
                                                id: printerQueueIcon
                                                source: "qrc:/MeguPackOptimizer/src/resources/settings.svg"
                                                anchors.fill: parent
                                                sourceSize.width: 20
                                                sourceSize.height: 20
                                                visible: false
                                            }
                                            ColorOverlay {
                                                anchors.fill: printerQueueIcon
                                                source: printerQueueIcon
                                                color: Theme.accent
                                            }
                                        }

                                        Text {
                                            text: modelData
                                            color: Theme.textPrimary
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 12
                                            font.bold: true
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }
                                }
                            }
                            
                            // Fallback if no printers detected
                            Text {
                                text: qsTr("No print queues detected.")
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                visible: optimizerBackend.detectedPrinters.length === 0
                            }
                        }
                    }

                    // 5. Notifications Options Content
                    Column {
                        id: notificationsColumn
                        width: parent.width
                        spacing: 20
                        visible: root.activeDrawer === "notifications"

                        Text {
                            text: qsTr("Configure custom Windows notification and sound alert rules.")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.bold: true
                        }

                        Column {
                            width: parent.width
                            spacing: 12

                            MeguSwitch {
                                text: qsTr("Global Toast Notifications")
                                checked: optimizerBackend.notifGlobalActive
                                onToggled: (isChecked) => { optimizerBackend.notifGlobalActive = isChecked; }
                            }

                            MeguSwitch {
                                text: qsTr("App Notifications")
                                checked: optimizerBackend.notifAppActive
                                onToggled: (isChecked) => { optimizerBackend.notifAppActive = isChecked; }
                            }

                            MeguSwitch {
                                text: qsTr("Notification Sounds")
                                checked: optimizerBackend.notifSoundsActive
                                onToggled: (isChecked) => { optimizerBackend.notifSoundsActive = isChecked; }
                            }

                            MeguSwitch {
                                text: qsTr("Lock Screen Notifications")
                                checked: optimizerBackend.notifLockscreenActive
                                onToggled: (isChecked) => { optimizerBackend.notifLockscreenActive = isChecked; }
                            }
                        }
                    }

                    // 6. Power Plan Options Content
                    Column {
                        id: powerColumn
                        width: parent.width
                        spacing: 20
                        visible: root.activeDrawer === "power"

                        Column {
                            width: parent.width
                            spacing: 8
                            Text {
                                text: qsTr("Ultimate Performance Scheme")
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                font.bold: true
                            }
                            Text {
                                text: qsTr("Unlocks and enables the hidden Windows Ultimate Performance power scheme for zero latencies.")
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                                wrapMode: Text.Wrap
                                width: parent.width
                            }
                        }

                        MeguButton {
                            text: qsTr("Activate Ultimate Performance")
                            iconSource: "qrc:/MeguPackOptimizer/src/resources/bolt.svg"
                            accented: !optimizerBackend.ultimateSchemeUnlocked
                            enabled: !optimizerBackend.ultimateSchemeUnlocked && !optimizerBackend.isOptimizingSystem
                            width: parent.width
                            height: 38
                            onClicked: {
                                optimizerBackend.activateUltimatePerformance();
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 1
                            color: Theme.border
                        }

                        Text {
                            text: qsTr("Available Power Schemes:")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.bold: true
                        }

                        // Display the list of detected power schemes
                        Column {
                            width: parent.width
                            spacing: 10

                            Repeater {
                                model: optimizerBackend.powerSchemes
                                delegate: AcrylicPanel {
                                    id: schemePanel
                                    width: parent.width
                                    height: 50
                                    
                                    // Custom active border color
                                    border.color: modelData.isActive ? Theme.accent : (schemeMouse.containsMouse ? Theme.borderHover : Theme.border)
                                    color: modelData.isActive ? Theme.accentDim : (schemeMouse.containsMouse ? Theme.buttonBgHover : Theme.buttonBg)

                                    Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
                                    Behavior on color { ColorAnimation { duration: Theme.animFast } }

                                    Row {
                                        anchors.left: parent.left
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.leftMargin: 12
                                        spacing: 12

                                        Item {
                                            width: 20
                                            height: 20
                                            anchors.verticalCenter: parent.verticalCenter
                                            Image {
                                                id: planIcon
                                                source: "qrc:/MeguPackOptimizer/src/resources/bolt.svg"
                                                anchors.fill: parent
                                                sourceSize.width: 20
                                                sourceSize.height: 20
                                                visible: false
                                            }
                                            ColorOverlay {
                                                anchors.fill: planIcon
                                                source: planIcon
                                                color: modelData.isActive ? Theme.accent : Theme.textMuted
                                            }
                                        }

                                        Column {
                                            anchors.verticalCenter: parent.verticalCenter
                                            spacing: 1

                                            Text {
                                                text: {
                                                    var rawName = modelData.name;
                                                    // Clean up trailing translations from friendly name
                                                    return rawName.split(' (')[0];
                                                }
                                                color: Theme.textPrimary
                                                font.family: Theme.fontFamily
                                                font.pixelSize: 12
                                                font.bold: true
                                            }
                                            Text {
                                                text: modelData.guid
                                                color: Theme.textMuted
                                                font.family: Theme.fontFamily
                                                font.pixelSize: 8
                                            }
                                        }
                                    }

                                    MouseArea {
                                        id: schemeMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            optimizerBackend.selectPowerScheme(modelData.guid);
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // 7. Windows Defender Options Content
                    Column {
                        id: defenderColumn
                        width: parent.width
                        spacing: 20
                        visible: root.activeDrawer === "defender"

                        Text {
                            text: qsTr("Configure custom Windows Defender protection settings and services.")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.bold: true
                        }

                        // Informational warning box
                        AcrylicPanel {
                            width: parent.width
                            height: 60
                            border.color: Theme.warning
                            color: Theme.accentDim

                            Row {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 10

                                Item {
                                    width: 18
                                    height: 18
                                    anchors.verticalCenter: parent.verticalCenter
                                    Image {
                                        id: drawerWarningIcon
                                        source: "qrc:/MeguPackOptimizer/src/resources/warning.svg"
                                        anchors.fill: parent
                                        sourceSize.width: 18
                                        sourceSize.height: 18
                                        visible: false
                                    }
                                    ColorOverlay {
                                        anchors.fill: drawerWarningIcon
                                        source: drawerWarningIcon
                                        color: Theme.warning
                                    }
                                }

                                Text {
                                    text: qsTr("Disable the startup of WinDefend, Sense, WdFilter, and WdBoot services. Note: Requires disabling Tamper Protection.")
                                    color: Theme.warning
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 9
                                    font.bold: true
                                    wrapMode: Text.Wrap
                                    width: parent.width - 38
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: 12

                            MeguSwitch {
                                text: qsTr("Registry Disablement Policies")
                                checked: optimizerBackend.defenderRegistryActive
                                onToggled: (isChecked) => { optimizerBackend.defenderRegistryActive = isChecked; }
                            }

                            MeguSwitch {
                                text: qsTr("PowerShell Preference Adjustments")
                                checked: optimizerBackend.defenderCmdActive
                                onToggled: (isChecked) => { optimizerBackend.defenderCmdActive = isChecked; }
                            }

                            MeguSwitch {
                                text: qsTr("Antivirus Services & Drivers")
                                checked: optimizerBackend.defenderServiceActive
                                onToggled: (isChecked) => { optimizerBackend.defenderServiceActive = isChecked; }
                            }
                        }
                    }

                    // 8. USB Power Saving Options Content
                    Column {
                        id: usbColumn
                        width: parent.width
                        spacing: 20
                        visible: root.activeDrawer === "usb"

                        Text {
                            text: qsTr("Configure power saving settings for individual USB 3.0 ports.")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.bold: true
                        }

                        Column {
                            width: parent.width
                            spacing: 12

                            Repeater {
                                model: optimizerBackend.usbDevices
                                delegate: MeguSwitch {
                                    text: modelData.name
                                    checked: modelData.powerSavingActive
                                    onToggled: (isChecked) => {
                                        optimizerBackend.setDevicePowerSavingActive(modelData.subkeyPath, isChecked);
                                    }
                                }
                            }
                        }

                        // Fallback if no USB 3.0 ports found
                        Text {
                            text: qsTr("No USB 3.0 controllers or hubs found.")
                            color: Theme.textMuted
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            visible: optimizerBackend.usbDevices.length === 0
                        }
                    }

                    // Telemetry Options Content
                    Column {
                        id: telemetryColumn
                        width: parent.width
                        spacing: 20
                        visible: root.activeDrawer === "telemetry"

                        Text {
                            text: qsTr("Configure custom Windows telemetry and error reporting options.")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.bold: true
                        }

                        Column {
                            width: parent.width
                            spacing: 12

                            MeguSwitch {
                                text: qsTr("Connected User Experiences (DiagTrack)")
                                checked: !optimizerBackend.telemetryDiagTrackActive
                                onToggled: (isChecked) => { optimizerBackend.telemetryDiagTrackActive = !isChecked; }
                            }

                            MeguSwitch {
                                text: qsTr("Device Management WAP Service (dmwappushservice)")
                                checked: !optimizerBackend.telemetryWapPushActive
                                onToggled: (isChecked) => { optimizerBackend.telemetryWapPushActive = !isChecked; }
                            }

                            MeguSwitch {
                                text: qsTr("Customer Experience Improvement Program (CEIP)")
                                checked: !optimizerBackend.telemetryCeipActive
                                onToggled: (isChecked) => { optimizerBackend.telemetryCeipActive = !isChecked; }
                            }

                            MeguSwitch {
                                text: qsTr("Windows Error Reporting (WER)")
                                checked: !optimizerBackend.telemetryWerActive
                                onToggled: (isChecked) => { optimizerBackend.telemetryWerActive = !isChecked; }
                            }
                        }
                    }

                    // 9. Windows Update Options Content
                    Column {
                        id: windowsUpdateColumn
                        width: parent.width
                        spacing: 20
                        visible: root.activeDrawer === "windowsUpdate"

                        property var updateModesList: [
                            { modeId: 0, nameText: qsTr("Default"), descText: qsTr("Automatic updates, notifications, drivers, and upgrades are all enabled.") },
                            { modeId: 1, nameText: qsTr("Security Only"), descText: qsTr("Only cumulative security and quality patches will install. Driver and major version updates are blocked.") },
                            { modeId: 2, nameText: qsTr("Manual Check"), descText: qsTr("Automatic background updates are disabled. Check and install on your own schedule.") },
                            { modeId: 3, nameText: qsTr("Disabled"), descText: qsTr("Updates are completely blocked. Disables update services and Windows Update Medic.") }
                        ]

                        Text {
                            text: qsTr("Configure system update modes:")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.bold: true
                        }

                        Column {
                            width: parent.width
                            spacing: 10

                            Repeater {
                                model: windowsUpdateColumn.updateModesList
                                delegate: AcrylicPanel {
                                    id: modePanel
                                    width: parent.width
                                    height: 60
                                    
                                    property bool isActive: optimizerBackend.windowsUpdateMode === modelData.modeId

                                    border.color: isActive ? Theme.accent : (modeMouseArea.containsMouse ? Theme.borderHover : Theme.border)
                                    color: isActive ? Theme.accentDim : (modeMouseArea.containsMouse ? Theme.buttonBgHover : Theme.buttonBg)

                                    Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
                                    Behavior on color { ColorAnimation { duration: Theme.animFast } }

                                    Row {
                                        anchors.left: parent.left
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.leftMargin: 12
                                        spacing: 12

                                        Item {
                                            width: 20
                                            height: 20
                                            anchors.verticalCenter: parent.verticalCenter
                                            Image {
                                                id: modeIcon
                                                source: "qrc:/MeguPackOptimizer/src/resources/settings.svg"
                                                anchors.fill: parent
                                                sourceSize.width: 20
                                                sourceSize.height: 20
                                                visible: false
                                            }
                                            ColorOverlay {
                                                anchors.fill: modeIcon
                                                source: modeIcon
                                                color: modePanel.isActive ? Theme.accent : Theme.textMuted
                                            }
                                        }

                                        Column {
                                            anchors.verticalCenter: parent.verticalCenter
                                            spacing: 1
                                            width: modePanel.width - 56

                                            Text {
                                                text: modelData.nameText
                                                color: Theme.textPrimary
                                                font.family: Theme.fontFamily
                                                font.pixelSize: 11
                                                font.bold: true
                                            }

                                            Text {
                                                text: modelData.descText
                                                color: Theme.textMuted
                                                font.family: Theme.fontFamily
                                                font.pixelSize: 9
                                                wrapMode: Text.Wrap
                                                width: parent.width
                                            }
                                        }
                                    }

                                    MouseArea {
                                        id: modeMouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            optimizerBackend.windowsUpdateMode = modelData.modeId;
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
                    text: root.txtChangesPending.arg(root.pendingChangesCount)
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

        AcrylicPanel {
            width: 500
            height: 380
            anchors.centerIn: parent

            Item {
                anchors.fill: parent
                anchors.margins: 24

                Column {
                    anchors.fill: parent
                    spacing: 16

                    Text {
                        text: optimizerBackend.isOptimizingSystem ? qsTr("SYSTEM OPTIMIZATION IN PROGRESS") : qsTr("OPTIMIZATION COMPLETE")
                        color: Theme.yellowAccent
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        font.bold: true
                        font.letterSpacing: 1.5
                    }

                    MeguProgressBar {
                        width: parent.width
                        value: optimizerBackend.systemProgress
                        statusText: optimizerBackend.isOptimizingSystem ? qsTr("Applying disk indexing settings...") : qsTr("Finished system modifications.")
                    }

                    Rectangle {
                        width: parent.width
                        height: 180
                        color: "#080C14"
                        border.color: Theme.border
                        border.width: 1
                        radius: Theme.radiusSmall
                        clip: true

                        ListView {
                            id: logListView
                            anchors.fill: parent
                            anchors.margins: 10
                            model: stepLogModel
                            spacing: 4

                            delegate: Text {
                                width: logListView.width - 20
                                text: model.message
                                color: {
                                    if (model.type === "SUCCESS") return Theme.success;
                                    if (model.type === "ERROR") return Theme.error;
                                    if (model.type === "WARNING") return Theme.warning;
                                    return Theme.textSecondary;
                                }
                                font.family: "Consolas, monospace, " + Theme.fontFamily
                                font.pixelSize: 11
                                wrapMode: Text.Wrap
                            }

                            onCountChanged: {
                                Qt.callLater(logListView.positionViewAtEnd);
                            }
                        }
                    }

                    MeguButton {
                        text: qsTr("Close")
                        accented: true
                        anchors.horizontalCenter: parent.horizontalCenter
                        enabled: !optimizerBackend.isOptimizingSystem
                        width: 100
                        onClicked: {
                            progressOverlay.showFinishedOverlay = false;
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
