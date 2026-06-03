import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeguPackOptimizer 1.0
import Qt5Compat.GraphicalEffects
import "../components"

Column {
    id: healthColumn
    width: parent.width
    spacing: 16

    Text {
        text: qsTr("Resolve common display, icon, and thumbnail rendering issues.")
        color: Theme.textSecondary
        font.family: Theme.fontFamily
        font.pixelSize: 11
        font.bold: true
        bottomPadding: 8
    }

    // 1. Graphics Driver Restart Card
    Rectangle {
        width: parent.width
        height: Math.max(56, graphicsCol.implicitHeight + 16)
        radius: 8
        color: "#05FFFFFF"
        border.color: Theme.border
        border.width: 1

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
                        id: gpuIconImg
                        source: "qrc:/MeguPackOptimizer/src/resources/gpu.svg"
                        anchors.fill: parent
                        sourceSize.width: 16
                        sourceSize.height: 16
                        visible: false
                    }
                    ColorOverlay {
                        anchors.fill: gpuIconImg
                        source: gpuIconImg
                        color: Theme.accent
                    }
                }
            }

            Column {
                id: graphicsCol
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 2

                Text {
                    text: qsTr("Graphics driver")
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    font.bold: true
                }
                Text {
                    text: qsTr("Restart the driver if your display has weird issues like freezing or flickering.")
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    width: parent.width
                    wrapMode: Text.WordWrap
                }
            }

            MeguButton {
                id: restartDriverBtn
                text: qsTr("Restart")
                height: 28
                Layout.alignment: Qt.AlignVCenter
                onClicked: {
                    optimizerBackend.restartGraphicsDriver();
                }
            }
        }
    }

    // 2. Rebuild Icons Cache Card
    Rectangle {
        width: parent.width
        height: Math.max(56, iconsCol.implicitHeight + 16)
        radius: 8
        color: "#05FFFFFF"
        border.color: Theme.border
        border.width: 1

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
                        id: iconCacheImg
                        source: "qrc:/MeguPackOptimizer/src/resources/monitor.svg"
                        anchors.fill: parent
                        sourceSize.width: 16
                        sourceSize.height: 16
                        visible: false
                    }
                    ColorOverlay {
                        anchors.fill: iconCacheImg
                        source: iconCacheImg
                        color: Theme.accent
                    }
                }
            }

            Column {
                id: iconsCol
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 2

                Text {
                    text: qsTr("Icons cache")
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    font.bold: true
                }
                Text {
                    text: qsTr("Rebuild the cache if your icons or thumbnails are blank, blurry or corrupted.")
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    width: parent.width
                    wrapMode: Text.WordWrap
                }
            }

            MeguButton {
                id: rebuildCacheBtn
                text: qsTr("Rebuild")
                height: 28
                Layout.alignment: Qt.AlignVCenter
                onClicked: {
                    optimizerBackend.rebuildIconCache();
                }
            }
        }
    }

    // 3. Memory Diagnostic Card
    Rectangle {
        width: parent.width
        height: Math.max(56, memCol.implicitHeight + 16)
        radius: 8
        color: "#05FFFFFF"
        border.color: Theme.border
        border.width: 1

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
                        id: ramIconImg
                        source: "qrc:/MeguPackOptimizer/src/resources/ram.svg"
                        anchors.fill: parent
                        sourceSize.width: 16
                        sourceSize.height: 16
                        visible: false
                    }
                    ColorOverlay {
                        anchors.fill: ramIconImg
                        source: ramIconImg
                        color: Theme.accent
                    }
                }
            }

            Column {
                id: memCol
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 2

                Text {
                    text: qsTr("Memory diagnostic")
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    font.bold: true
                }
                Text {
                    text: qsTr("Check your device for possible memory issues.")
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    width: parent.width
                    wrapMode: Text.WordWrap
                }
                Text {
                    text: qsTr("Note: Spawns the Windows Memory Diagnostic tool. Requires a restart to test RAM for hardware issues. Results will be shown in Windows Event Viewer after reboot.")
                    color: Theme.warning
                    font.family: Theme.fontFamily
                    font.pixelSize: 9
                    width: parent.width
                    wrapMode: Text.WordWrap
                }
            }

            // Diagnostic Status (Heart Icon)
            Item {
                width: 24
                height: 24
                Layout.alignment: Qt.AlignVCenter

                Image {
                    id: heartIconImg
                    source: (optimizerBackend.memoryDiagnosticStatus === 1 || optimizerBackend.memoryDiagnosticStatus === 2)
                            ? "qrc:/MeguPackOptimizer/src/resources/heart_filled.svg"
                            : "qrc:/MeguPackOptimizer/src/resources/heart_outline.svg"
                    anchors.fill: parent
                    sourceSize.width: 18
                    sourceSize.height: 18
                    visible: false
                }
                ColorOverlay {
                    anchors.fill: heartIconImg
                    source: heartIconImg
                    color: {
                        if (optimizerBackend.memoryDiagnosticStatus === 1) return Theme.success;
                        if (optimizerBackend.memoryDiagnosticStatus === 2) return Theme.error;
                        return Theme.textSecondary;
                    }
                }

                ToolTip {
                    visible: heartMouseArea.containsMouse
                    delay: 400
                    text: {
                        if (optimizerBackend.memoryDiagnosticStatus === 1) return qsTr("Diagnostic: healthy");
                        if (optimizerBackend.memoryDiagnosticStatus === 2) return qsTr("Diagnostic: errors found");
                        return qsTr("Diagnostic: not checked");
                    }
                }

                MouseArea {
                    id: heartMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                }
            }

            MeguButton {
                id: checkMemoryBtn
                text: qsTr("Check")
                height: 28
                Layout.alignment: Qt.AlignVCenter
                onClicked: {
                    optimizerBackend.runMemoryDiagnostic();
                }
            }
        }
    }

    // 4. Storage Sense Card
    Rectangle {
        width: parent.width
        height: Math.max(56, storageSenseCol.implicitHeight + 16)
        radius: 8
        color: "#05FFFFFF"
        border.color: Theme.border
        border.width: 1

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
                        id: storageSenseIconImg
                        source: "qrc:/MeguPackOptimizer/src/resources/storage.svg"
                        anchors.fill: parent
                        sourceSize.width: 16
                        sourceSize.height: 16
                        visible: false
                    }
                    ColorOverlay {
                        anchors.fill: storageSenseIconImg
                        source: storageSenseIconImg
                        color: Theme.accent
                    }
                }
            }

            Column {
                id: storageSenseCol
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 2

                Row {
                    spacing: 6
                    Text {
                        text: qsTr("Storage sense")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    ShowPathButton {
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: {
                            optimizerBackend.showPath("storagesense");
                        }
                    }
                }
                Text {
                    text: qsTr("Automatically cleans up some temporary system files.")
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    width: parent.width
                    wrapMode: Text.WordWrap
                }
            }

            MeguSwitch {
                id: storageSenseSwitch
                Layout.alignment: Qt.AlignVCenter
                checked: optimizerBackend.storageSenseActive
                onToggled: (isChecked) => {
                    optimizerBackend.storageSenseActive = isChecked;
                }
            }
        }
    }
}

