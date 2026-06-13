import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeguPackOptimizer 1.0
import Qt5Compat.GraphicalEffects
import "../components"

Column {
    id: cleanupColumn
    width: parent.width
    spacing: 16

    Text {
        text: qsTr("Free up storage space, clear cache, delete system restore points and more.")
        color: Theme.textSecondary
        font.family: Theme.fontFamily
        font.pixelSize: 11
        font.bold: true
        bottomPadding: 8
    }

    // Cleaning states
    property bool tempCleaning: false
    property bool tempSuccess: false

    property bool cacheCleaning: false
    property bool cacheSuccess: false

    property bool storageCleaning: false
    property bool storageSuccess: false

    property bool explorerCleaning: false
    property bool explorerSuccess: false

    property bool storeCleaning: false
    property bool storeSuccess: false

    property bool networkCleaning: false
    property bool networkSuccess: false

    property bool restoreCleaning: false
    property bool restoreSuccess: false

    // Timers to simulate premium feel and delay execution
    Timer {
        id: tempTimer
        interval: 1200
        onTriggered: {
            optimizerBackend.cleanTemp();
            cleanupColumn.tempCleaning = false;
            cleanupColumn.tempSuccess = true;
            resetSuccessTimer.start();
        }
    }

    Timer {
        id: cacheTimer
        interval: 2000
        onTriggered: {
            optimizerBackend.cleanLocalCache();
            cleanupColumn.cacheCleaning = false;
            cleanupColumn.cacheSuccess = true;
            resetSuccessTimer.start();
        }
    }

    Timer {
        id: storageTimer
        interval: 1200
        onTriggered: {
            optimizerBackend.cleanStorage();
            cleanupColumn.storageCleaning = false;
            cleanupColumn.storageSuccess = true;
            resetSuccessTimer.start();
        }
    }

    Timer {
        id: explorerTimer
        interval: 1000
        onTriggered: {
            optimizerBackend.cleanFileExplorer();
            cleanupColumn.explorerCleaning = false;
            cleanupColumn.explorerSuccess = true;
            resetSuccessTimer.start();
        }
    }

    Timer {
        id: storeTimer
        interval: 1500
        onTriggered: {
            optimizerBackend.cleanMicrosoftStore();
            cleanupColumn.storeCleaning = false;
            cleanupColumn.storeSuccess = true;
            resetSuccessTimer.start();
        }
    }

    Timer {
        id: networkTimer
        interval: 1500
        onTriggered: {
            optimizerBackend.cleanNetwork();
            cleanupColumn.networkCleaning = false;
            cleanupColumn.networkSuccess = true;
            resetSuccessTimer.start();
        }
    }

    Timer {
        id: restoreTimer
        interval: 1800
        onTriggered: {
            optimizerBackend.cleanSystemRestore();
            cleanupColumn.restoreCleaning = false;
            cleanupColumn.restoreSuccess = true;
            resetSuccessTimer.start();
        }
    }

    Timer {
        id: resetSuccessTimer
        interval: 3000
        repeat: false
        onTriggered: {
            cleanupColumn.tempSuccess = false;
            cleanupColumn.cacheSuccess = false;
            cleanupColumn.storageSuccess = false;
            cleanupColumn.explorerSuccess = false;
            cleanupColumn.storeSuccess = false;
            cleanupColumn.networkSuccess = false;
            cleanupColumn.restoreSuccess = false;
        }
    }

    // Helper component for cleaner rows
    Component {
        id: cleanerRowComponent
        
        Rectangle {
            id: cardBg
            width: parent.width
            height: expanded ? Math.max(56, mainCol.implicitHeight + 24) : 56
            radius: 8
            color: "#05FFFFFF"
            border.color: Theme.border
            border.width: 1
            clip: true

            property string title: ""
            property string description: ""
            property string cleanerName: ""
            property string icon: ""
            property string buttonIcon: ""
            property bool isCleaning: false
            property bool isSuccess: false
            property var cleanCallback
            
            property bool expanded: false
            property var detailsData: null

            function formatBytes(bytes) {
                if (bytes === 0 || bytes === undefined || bytes === null) return "0 B";
                var k = 1024;
                var sizes = ["B", "KB", "MB", "GB", "TB"];
                var i = Math.floor(Math.log(bytes) / Math.log(k));
                if (i < 0) i = 0;
                return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + " " + sizes[i];
            }

            Behavior on height {
                NumberAnimation { duration: 220; easing.type: Easing.InOutQuad }
            }

            ColumnLayout {
                id: mainCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: 12
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 12

                // Header Row
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    spacing: 12

                    // Icon Badge
                    Rectangle {
                        width: 32
                        height: 32
                        radius: 8
                        color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1)

                        Item {
                            width: 16
                            height: 16
                            anchors.centerIn: parent
                            Image {
                                id: badgeIconImg
                                source: cardBg.icon
                                anchors.fill: parent
                                sourceSize.width: 16
                                sourceSize.height: 16
                                visible: false
                            }
                            ColorOverlay {
                                anchors.fill: badgeIconImg
                                source: badgeIconImg
                                color: Theme.accent
                            }
                        }
                    }

                    // Title
                    Text {
                        text: cardBg.title
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                    }

                    // Expand Arrow Button
                    Rectangle {
                        width: 32
                        height: 32
                        radius: 6
                        color: arrowMouse.containsMouse ? "#15FFFFFF" : "transparent"
                        border.color: arrowMouse.containsMouse ? Theme.accent : "transparent"
                        border.width: 1
                        Layout.alignment: Qt.AlignVCenter
                        
                        Behavior on color { ColorAnimation { duration: Theme.animFast } }
                        Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                        Item {
                            width: 16
                            height: 16
                            anchors.centerIn: parent
                            
                            Image {
                                id: arrowIcon
                                source: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"
                                anchors.fill: parent
                                sourceSize.width: 16
                                sourceSize.height: 16
                                visible: false
                            }
                            ColorOverlay {
                                anchors.fill: arrowIcon
                                source: arrowIcon
                                color: arrowMouse.containsMouse ? Theme.accent : Theme.textSecondary
                                Behavior on color { ColorAnimation { duration: Theme.animFast } }
                            }
                        }
                        
                        rotation: cardBg.expanded ? 270 : 90
                        Behavior on rotation {
                            NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutQuad }
                        }

                        MouseArea {
                            id: arrowMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                cardBg.expanded = !cardBg.expanded
                                if (cardBg.expanded) {
                                    cardBg.detailsData = optimizerBackend.getCleanerDetails(cardBg.cleanerName);
                                }
                            }
                        }
                    }

                    // Action Area (Action Button / Busy / Check)
                    Item {
                        width: 32
                        height: 32
                        Layout.alignment: Qt.AlignVCenter

                        // 1. Loading state (spinning loop)
                        BusyIndicator {
                            anchors.fill: parent
                            visible: cardBg.isCleaning
                            
                            contentItem: Item {
                                implicitWidth: 32
                                implicitHeight: 32
                                
                                Canvas {
                                    id: canvas
                                    anchors.fill: parent
                                    onPaint: {
                                        var ctx = canvas.getContext("2d");
                                        ctx.reset();
                                        ctx.strokeStyle = Theme.accent;
                                        ctx.lineWidth = 2;
                                        ctx.beginPath();
                                        ctx.arc(16, 16, 10, 0, Math.PI * 1.5);
                                        ctx.stroke();
                                    }
                                }
                                
                                RotationAnimator {
                                    target: canvas
                                    running: cardBg.isCleaning
                                    from: 0
                                    to: 360
                                    loops: Animation.Infinite
                                    duration: 800
                                }
                            }
                        }

                        // 2. Success state (Checkmark with green color overlay)
                        Item {
                            anchors.fill: parent
                            visible: cardBg.isSuccess

                            Image {
                                id: checkMarkImg
                                source: "qrc:/MeguPackOptimizer/src/resources/check.svg"
                                anchors.fill: parent
                                anchors.margins: 8
                                sourceSize.width: 16
                                sourceSize.height: 16
                                visible: false
                            }
                            ColorOverlay {
                                anchors.fill: checkMarkImg
                                source: checkMarkImg
                                color: Theme.success
                            }
                        }

                        // 3. Cleaner Action Button
                        Rectangle {
                            id: actionBtn
                            anchors.fill: parent
                            radius: 6
                            color: actionBtnMouse.containsMouse ? "#15FFFFFF" : "#0AFFFFFF"
                            border.color: actionBtnMouse.containsMouse ? Theme.accent : Theme.border
                            border.width: 1
                            visible: !cardBg.isCleaning && !cardBg.isSuccess
                            
                            Behavior on color { ColorAnimation { duration: Theme.animFast } }
                            Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                            Item {
                                anchors.fill: parent
                                anchors.margins: 8
                                
                                Image {
                                    id: actIconImg
                                    source: cardBg.buttonIcon
                                    anchors.fill: parent
                                    sourceSize.width: 16
                                    sourceSize.height: 16
                                    visible: false
                                }
                                ColorOverlay {
                                    anchors.fill: actIconImg
                                    source: actIconImg
                                    color: actionBtnMouse.containsMouse ? Theme.accent : Theme.textSecondary
                                    Behavior on color { ColorAnimation { duration: Theme.animFast } }
                                }
                            }

                            MouseArea {
                                id: actionBtnMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    cardBg.cleanCallback();
                                }
                            }
                        }
                    }
                }

                // Collapsible Details block
                ColumnLayout {
                    id: detailsLayout
                    Layout.fillWidth: true
                    visible: cardBg.expanded
                    spacing: 8

                    // Thin separator
                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: "#15FFFFFF"
                    }

                    // Description Text (Premium look, slightly muted)
                    Text {
                        Layout.fillWidth: true
                        text: cardBg.description
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        wrapMode: Text.WordWrap
                    }

                    // Dynamic details information
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        // 1. Details for TEMPORARY FILES
                        ColumnLayout {
                            Layout.fillWidth: true
                            visible: cardBg.cleanerName === "temp" && cardBg.detailsData !== null
                            spacing: 4

                            RowLayout {
                                Layout.fillWidth: true
                                Text { text: qsTr("User Temp Files:"); color: Theme.textMuted; font.family: Theme.fontFamily; font.pixelSize: 10; Layout.fillWidth: true }
                                Text { text: cardBg.formatBytes(cardBg.detailsData ? cardBg.detailsData.userTempSize : 0) + " (" + (cardBg.detailsData ? cardBg.detailsData.userTempCount : 0) + " files)"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: 10; font.bold: true }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                Text { text: qsTr("System Temp Files:"); color: Theme.textMuted; font.family: Theme.fontFamily; font.pixelSize: 10; Layout.fillWidth: true }
                                Text { text: cardBg.formatBytes(cardBg.detailsData ? cardBg.detailsData.sysTempSize : 0) + " (" + (cardBg.detailsData ? cardBg.detailsData.sysTempCount : 0) + " files)"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: 10; font.bold: true }
                            }
                        }

                        // 2. Details for APPDATA LOCAL CACHE
                        ColumnLayout {
                            Layout.fillWidth: true
                            visible: cardBg.cleanerName === "cache" && cardBg.detailsData !== null
                            spacing: 4

                            RowLayout {
                                Layout.fillWidth: true
                                Text { text: qsTr("Web Browsers Cache:"); color: Theme.textMuted; font.family: Theme.fontFamily; font.pixelSize: 10; Layout.fillWidth: true }
                                Text { text: cardBg.formatBytes(cardBg.detailsData ? cardBg.detailsData.browserSize : 0) + " (" + (cardBg.detailsData ? cardBg.detailsData.browserCount : 0) + " files)"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: 10; font.bold: true }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                Text { text: qsTr("Apps Cache (Discord/Spotify/Steam):"); color: Theme.textMuted; font.family: Theme.fontFamily; font.pixelSize: 10; Layout.fillWidth: true }
                                Text { text: cardBg.formatBytes(cardBg.detailsData ? cardBg.detailsData.appSize : 0) + " (" + (cardBg.detailsData ? cardBg.detailsData.appCount : 0) + " files)"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: 10; font.bold: true }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                Text { text: qsTr("GPU Shader Cache (NVIDIA/AMD):"); color: Theme.textMuted; font.family: Theme.fontFamily; font.pixelSize: 10; Layout.fillWidth: true }
                                Text { text: cardBg.formatBytes(cardBg.detailsData ? cardBg.detailsData.shaderSize : 0) + " (" + (cardBg.detailsData ? cardBg.detailsData.shaderCount : 0) + " files)"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: 10; font.bold: true }
                            }
                        }

                        // 3. Details for STORAGE
                        ColumnLayout {
                            Layout.fillWidth: true
                            visible: cardBg.cleanerName === "storage" && cardBg.detailsData !== null
                            spacing: 4

                            RowLayout {
                                Layout.fillWidth: true
                                Text { text: qsTr("Temporary Files:"); color: Theme.textMuted; font.family: Theme.fontFamily; font.pixelSize: 10; Layout.fillWidth: true }
                                Text { text: cardBg.formatBytes(cardBg.detailsData ? cardBg.detailsData.tempSize : 0); color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: 10; font.bold: true }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                Text { text: qsTr("Windows Prefetch Cache:"); color: Theme.textMuted; font.family: Theme.fontFamily; font.pixelSize: 10; Layout.fillWidth: true }
                                Text { text: cardBg.formatBytes(cardBg.detailsData ? cardBg.detailsData.prefetchSize : 0); color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: 10; font.bold: true }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                Text { text: qsTr("Windows Update Download Cache:"); color: Theme.textMuted; font.family: Theme.fontFamily; font.pixelSize: 10; Layout.fillWidth: true }
                                Text { text: cardBg.formatBytes(cardBg.detailsData ? cardBg.detailsData.updateSize : 0); color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: 10; font.bold: true }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                Text { text: qsTr("Recycle Bin Items:"); color: Theme.textMuted; font.family: Theme.fontFamily; font.pixelSize: 10; Layout.fillWidth: true }
                                Text { text: cardBg.formatBytes(cardBg.detailsData ? cardBg.detailsData.recycleBinSize : 0) + " (" + (cardBg.detailsData ? cardBg.detailsData.recycleBinCount : 0) + " items)"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: 10; font.bold: true }
                            }
                        }

                        // 4. Details for FILE EXPLORER
                        ColumnLayout {
                            Layout.fillWidth: true
                            visible: cardBg.cleanerName === "explorer" && cardBg.detailsData !== null
                            spacing: 4

                            RowLayout {
                                Layout.fillWidth: true
                                Text { text: qsTr("Recent files links size:"); color: Theme.textMuted; font.family: Theme.fontFamily; font.pixelSize: 10; Layout.fillWidth: true }
                                Text { text: cardBg.formatBytes(cardBg.detailsData ? cardBg.detailsData.recentSize : 0) + " (" + (cardBg.detailsData ? cardBg.detailsData.recentCount : 0) + " files)"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: 10; font.bold: true }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                Text { text: qsTr("Registry MRU lists entries:"); color: Theme.textMuted; font.family: Theme.fontFamily; font.pixelSize: 10; Layout.fillWidth: true }
                                Text { text: (cardBg.detailsData ? cardBg.detailsData.registryCount : 0) + " entries"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: 10; font.bold: true }
                            }
                        }

                        // 5. Details for MICROSOFT STORE
                        ColumnLayout {
                            Layout.fillWidth: true
                            visible: cardBg.cleanerName === "store" && cardBg.detailsData !== null
                            spacing: 4

                            RowLayout {
                                Layout.fillWidth: true
                                Text { text: qsTr("Store Local Cache:"); color: Theme.textMuted; font.family: Theme.fontFamily; font.pixelSize: 10; Layout.fillWidth: true }
                                Text { text: cardBg.formatBytes(cardBg.detailsData ? cardBg.detailsData.storeSize : 0) + " (" + (cardBg.detailsData ? cardBg.detailsData.storeCount : 0) + " files)"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: 10; font.bold: true }
                            }
                        }

                        // 6. Details for NETWORK
                        ColumnLayout {
                            Layout.fillWidth: true
                            visible: cardBg.cleanerName === "network"
                            spacing: 4

                            RowLayout {
                                Layout.fillWidth: true
                                Text { text: qsTr("Operation details:"); color: Theme.textMuted; font.family: Theme.fontFamily; font.pixelSize: 10; Layout.fillWidth: true }
                                Text { text: qsTr("Flush DNS Cache & Winsock Reset"); color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: 10; font.bold: true }
                            }
                        }

                        // 7. Details for SYSTEM RESTORE
                        ColumnLayout {
                            Layout.fillWidth: true
                            visible: cardBg.cleanerName === "restore"
                            spacing: 4

                            RowLayout {
                                Layout.fillWidth: true
                                Text { text: qsTr("Operation details:"); color: Theme.textMuted; font.family: Theme.fontFamily; font.pixelSize: 10; Layout.fillWidth: true }
                                Text { text: qsTr("Deletes system recovery rollback points"); color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: 10; font.bold: true }
                            }
                        }

                        // Grand Total row
                        RowLayout {
                            Layout.fillWidth: true
                            visible: cardBg.detailsData !== null && cardBg.detailsData.totalSize !== undefined && cardBg.detailsData.totalSize > 0
                            spacing: 4
                            Rectangle { Layout.fillWidth: true; height: 1; color: "#0AFFFFFF" }
                            Text {
                                text: qsTr("Total Selected for Cleanup:") + " " + cardBg.formatBytes(cardBg.detailsData ? cardBg.detailsData.totalSize : 0)
                                color: Theme.accent
                                font.family: Theme.fontFamily; font.pixelSize: 10; font.bold: true
                            }
                        }
                    }
                }
            }
        }
    }

    // 1. Temporary Files Cleaner
    Loader {
        width: parent.width
        sourceComponent: cleanerRowComponent
        onLoaded: {
            item.title = qsTr("Temporary Files");
            item.cleanerName = "temp";
            item.description = qsTr("Clears temporary files generated by the operating system and installed software. Deleting these files is safe and helps resolve app crashes.");
            item.icon = "qrc:/MeguPackOptimizer/src/resources/folder.svg";
            item.buttonIcon = "qrc:/MeguPackOptimizer/src/resources/trash.svg";
            item.isCleaning = Qt.binding(function() { return cleanupColumn.tempCleaning; });
            item.isSuccess = Qt.binding(function() { return cleanupColumn.tempSuccess; });
            item.cleanCallback = function() {
                cleanupColumn.tempCleaning = true;
                tempTimer.start();
            };
        }
    }

    // 2. AppData Cache Cleaner
    Loader {
        width: parent.width
        sourceComponent: cleanerRowComponent
        onLoaded: {
            item.title = qsTr("AppData Local Cache");
            item.cleanerName = "cache";
            item.description = qsTr("Clears app caches, web browser history caches, Steam, Spotify, Discord caches, and shader cache. Speeds up app loading and frees significant space.");
            item.icon = "qrc:/MeguPackOptimizer/src/resources/settings.svg";
            item.buttonIcon = "qrc:/MeguPackOptimizer/src/resources/broom.svg";
            item.isCleaning = Qt.binding(function() { return cleanupColumn.cacheCleaning; });
            item.isSuccess = Qt.binding(function() { return cleanupColumn.cacheSuccess; });
            item.cleanCallback = function() {
                cleanupColumn.cacheCleaning = true;
                cacheTimer.start();
            };
        }
    }

    // 3. Storage Cleaner
    Loader {
        width: parent.width
        sourceComponent: cleanerRowComponent
        onLoaded: {
            item.title = qsTr("Storage");
            item.cleanerName = "storage";
            item.description = qsTr("Clears Windows temporary folders, Prefetch cache, Windows Update download cache, and empties the Recycle Bin to clean up disk storage.");
            item.icon = "qrc:/MeguPackOptimizer/src/resources/storage.svg";
            item.buttonIcon = "qrc:/MeguPackOptimizer/src/resources/trash.svg";
            item.isCleaning = Qt.binding(function() { return cleanupColumn.storageCleaning; });
            item.isSuccess = Qt.binding(function() { return cleanupColumn.storageSuccess; });
            item.cleanCallback = function() {
                cleanupColumn.storageCleaning = true;
                storageTimer.start();
            };
        }
    }

    // 4. File Explorer Cleaner
    Loader {
        width: parent.width
        sourceComponent: cleanerRowComponent
        onLoaded: {
            item.title = qsTr("File Explorer");
            item.cleanerName = "explorer";
            item.description = qsTr("Clears address bar TypedPaths history, Run dialog history list, and recent documents history links to improve private file system navigation privacy.");
            item.icon = "qrc:/MeguPackOptimizer/src/resources/folder.svg";
            item.buttonIcon = "qrc:/MeguPackOptimizer/src/resources/broom.svg";
            item.isCleaning = Qt.binding(function() { return cleanupColumn.explorerCleaning; });
            item.isSuccess = Qt.binding(function() { return cleanupColumn.explorerSuccess; });
            item.cleanCallback = function() {
                cleanupColumn.explorerCleaning = true;
                explorerTimer.start();
            };
        }
    }

    // 5. Microsoft Store Cleaner
    Loader {
        width: parent.width
        sourceComponent: cleanerRowComponent
        onLoaded: {
            item.title = qsTr("Microsoft Store");
            item.cleanerName = "store";
            item.description = qsTr("Resets Microsoft Store local configuration cache by executing wsreset.exe and clearing Store package cache folders to fix download errors.");
            item.icon = "qrc:/MeguPackOptimizer/src/resources/settings.svg";
            item.buttonIcon = "qrc:/MeguPackOptimizer/src/resources/broom.svg";
            item.isCleaning = Qt.binding(function() { return cleanupColumn.storeCleaning; });
            item.isSuccess = Qt.binding(function() { return cleanupColumn.storeSuccess; });
            item.cleanCallback = function() {
                cleanupColumn.storeCleaning = true;
                storeTimer.start();
            };
        }
    }

    // 6. Network Cleaner
    Loader {
        width: parent.width
        sourceComponent: cleanerRowComponent
        onLoaded: {
            item.title = qsTr("Network");
            item.cleanerName = "network";
            item.description = qsTr("Resets current network state, resets Winsock catalog, flushes the DNS resolver cache, and resets IP configurations to resolve internet issues.");
            item.icon = "qrc:/MeguPackOptimizer/src/resources/monitor.svg";
            item.buttonIcon = "qrc:/MeguPackOptimizer/src/resources/reset.svg";
            item.isCleaning = Qt.binding(function() { return cleanupColumn.networkCleaning; });
            item.isSuccess = Qt.binding(function() { return cleanupColumn.networkSuccess; });
            item.cleanCallback = function() {
                cleanupColumn.networkCleaning = true;
                networkTimer.start();
            };
        }
    }

    // 7. System Restore Cleaner
    Loader {
        width: parent.width
        sourceComponent: cleanerRowComponent
        onLoaded: {
            item.title = qsTr("System restore");
            item.cleanerName = "restore";
            item.description = qsTr("Clears old Windows shadow copy system restore points. WARNING: You will not be able to roll back your OS updates after running this.");
            item.icon = "qrc:/MeguPackOptimizer/src/resources/settings.svg";
            item.buttonIcon = "qrc:/MeguPackOptimizer/src/resources/trash.svg";
            item.isCleaning = Qt.binding(function() { return cleanupColumn.restoreCleaning; });
            item.isSuccess = Qt.binding(function() { return cleanupColumn.restoreSuccess; });
            item.cleanCallback = function() {
                cleanupColumn.restoreCleaning = true;
                restoreTimer.start();
            };
        }
    }
}
