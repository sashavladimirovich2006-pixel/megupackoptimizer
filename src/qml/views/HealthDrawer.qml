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
}
