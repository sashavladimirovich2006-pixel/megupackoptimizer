import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeguPackOptimizer 1.0
import Qt5Compat.GraphicalEffects
import "../components"

Column {
    id: windowsUpdateColumn
    width: parent.width
    spacing: 20
    

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
                compact: true
                contentMargins: 0
                accentColor: isActive ? Theme.accent : Theme.info
                pressed: modeMouseArea.pressed

                property bool isActive: optimizerBackend.windowsUpdateMode === modelData.modeId

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

    Text {
        text: qsTr("Additional update settings:")
        color: Theme.textSecondary
        font.family: Theme.fontFamily
        font.pixelSize: 11
        font.bold: true
        topPadding: 10
    }

    // Driver updates
    AcrylicPanel {
        width: parent.width
        height: Math.max(56, driverRow.implicitHeight + 16)
        compact: true
        contentMargins: 0

        RowLayout {
            id: driverRow
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
                        id: driverIconImg
                        source: "qrc:/MeguPackOptimizer/src/resources/monitor.svg"
                        anchors.fill: parent
                        sourceSize.width: 16
                        sourceSize.height: 16
                        visible: false
                    }
                    ColorOverlay {
                        anchors.fill: driverIconImg
                        source: driverIconImg
                        color: Theme.accent
                    }
                }
            }

            Column {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 2

                Row {
                    spacing: 8
                    Text {
                        text: qsTr("Driver updates")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    ShowPathButton {
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: { optimizerBackend.showPath("driverupdates"); }
                    }
                }
                Text {
                    text: qsTr("Automatically update or search drivers as part of cumulative updates or when connecting new hardware")
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    width: parent.width
                    wrapMode: Text.WordWrap
                }
            }

            MeguSwitch {
                id: driverSwitch
                Layout.alignment: Qt.AlignVCenter
                checked: optimizerBackend.driverUpdatesEnabled
                enabled: optimizerBackend.windowsUpdateMode !== 3
                onToggled: (isChecked) => { optimizerBackend.driverUpdatesEnabled = isChecked; }
            }
        }
    }

    // App updates
    AcrylicPanel {
        width: parent.width
        height: Math.max(56, appRow.implicitHeight + 16)
        compact: true
        contentMargins: 0

        RowLayout {
            id: appRow
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
                        id: appIconImg
                        source: "qrc:/MeguPackOptimizer/src/resources/bolt.svg"
                        anchors.fill: parent
                        sourceSize.width: 16
                        sourceSize.height: 16
                        visible: false
                    }
                    ColorOverlay {
                        anchors.fill: appIconImg
                        source: appIconImg
                        color: Theme.accent
                    }
                }
            }

            Column {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 2

                Row {
                    spacing: 8
                    Text {
                        text: qsTr("App updates")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    ShowPathButton {
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: { optimizerBackend.showPath("appupdates"); }
                    }
                }
                Text {
                    text: qsTr("Automatically download and install app updates")
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    width: parent.width
                    wrapMode: Text.WordWrap
                }
            }

            MeguSwitch {
                id: appSwitch
                Layout.alignment: Qt.AlignVCenter
                checked: optimizerBackend.appUpdatesEnabled
                onToggled: (isChecked) => { optimizerBackend.appUpdatesEnabled = isChecked; }
            }
        }
    }
}
