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
            height: 56
            radius: 8
            color: "#05FFFFFF"
            border.color: Theme.border
            border.width: 1

            property string title: ""
            property string icon: ""
            property string buttonIcon: ""
            property bool isCleaning: false
            property bool isSuccess: false
            property var cleanCallback

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 12

                // Icon Badge
                Rectangle {
                    width: 32
                    height: 32
                    radius: 8
                    color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1)
                    Layout.alignment: Qt.AlignVCenter

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

                // Action Area
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
        }
    }

    // 1. Storage Cleaner
    Loader {
        width: parent.width
        sourceComponent: cleanerRowComponent
        onLoaded: {
            item.title = qsTr("Storage");
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

    // 2. File Explorer Cleaner
    Loader {
        width: parent.width
        sourceComponent: cleanerRowComponent
        onLoaded: {
            item.title = qsTr("File Explorer");
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

    // 3. Microsoft Store Cleaner
    Loader {
        width: parent.width
        sourceComponent: cleanerRowComponent
        onLoaded: {
            item.title = qsTr("Microsoft Store");
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

    // 4. Network Cleaner
    Loader {
        width: parent.width
        sourceComponent: cleanerRowComponent
        onLoaded: {
            item.title = qsTr("Network");
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

    // 5. System Restore Cleaner
    Loader {
        width: parent.width
        sourceComponent: cleanerRowComponent
        onLoaded: {
            item.title = qsTr("System restore");
            item.icon = "qrc:/MeguPackOptimizer/src/resources/settings.svg"; // standard settings/system icon
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
