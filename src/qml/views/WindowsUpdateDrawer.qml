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
