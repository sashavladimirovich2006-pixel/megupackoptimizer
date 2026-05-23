import QtQuick
import QtQuick.Controls
import MeguPackOptimizer 1.0
import "../components"

Item {
    id: root

    // Center the Language Selection Panel in the screen
    AcrylicPanel {
        width: 320
        height: 120
        anchors.centerIn: parent

        Column {
            anchors.fill: parent
            spacing: 12

            Text {
                text: qsTr("Language Settings")
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 14
                font.bold: true
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.border
            }

            Row {
                spacing: 12
                anchors.horizontalCenter: parent.horizontalCenter

                Repeater {
                    model: [
                        { "code": "en", "name": qsTr("English") },
                        { "code": "uk", "name": qsTr("Ukrainian") }
                    ]

                    delegate: Rectangle {
                        width: 120
                        height: 32
                        radius: Theme.radiusSmall
                        color: settingsBackend.language === modelData.code ? Theme.accent : "#1E293B"
                        border.color: settingsBackend.language === modelData.code ? "transparent" : Theme.border
                        border.width: 1

                        Text {
                            text: modelData.name
                            color: settingsBackend.language === modelData.code ? Theme.textInverse : Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.bold: true
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: settingsBackend.language = modelData.code
                        }
                    }
                }
            }
        }
    }
}
