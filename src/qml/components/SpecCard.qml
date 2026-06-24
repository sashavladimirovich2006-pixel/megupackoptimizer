import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import MeguPackOptimizer 1.0

AcrylicPanel {
    id: card

    property string category: ""
    property string value: ""
    property string subValue: ""
    property string iconSource: ""

    property bool showProgressBar: false
    property real progressBarValue: 0.0
    property color progressBarColor: Theme.accent
    property color badgeColor: Qt.rgba(progressBarColor.r, progressBarColor.g, progressBarColor.b, 0.08)
    property color iconColor: Theme.textSecondary

    accentColor: card.progressBarColor
    accented: true
    compact: true
    interactive: true

    Item {
        anchors.fill: parent

        ColumnLayout {
            anchors.fill: parent
            spacing: 9

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 12

                Rectangle {
                    id: iconBg
                    Layout.preferredWidth: 42
                    Layout.preferredHeight: 42
                    Layout.alignment: Qt.AlignVCenter
                    radius: 12
                    color: card.containsMouse
                        ? Qt.rgba(card.progressBarColor.r, card.progressBarColor.g, card.progressBarColor.b, 0.16)
                        : card.badgeColor
                    border.color: card.containsMouse
                        ? Qt.rgba(card.progressBarColor.r, card.progressBarColor.g, card.progressBarColor.b, 0.52)
                        : Qt.rgba(card.progressBarColor.r, card.progressBarColor.g, card.progressBarColor.b, 0.22)
                    border.width: 1

                    Behavior on color { ColorAnimation { duration: Theme.animFast } }
                    Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                    DropShadow {
                        anchors.fill: parent
                        horizontalOffset: 0
                        verticalOffset: 0
                        radius: card.containsMouse ? 12 : 0
                        samples: 16
                        color: Qt.rgba(card.progressBarColor.r, card.progressBarColor.g, card.progressBarColor.b, 0.28)
                        source: iconBg
                        visible: Theme.currentTheme !== "Белоснежная"
                        Behavior on radius { NumberAnimation { duration: Theme.animFast } }
                    }

                    Image {
                        id: img
                        source: card.iconSource
                        anchors.centerIn: parent
                        width: 22
                        height: 22
                        sourceSize.width: 22
                        sourceSize.height: 22
                        visible: false
                    }

                    ColorOverlay {
                        anchors.fill: img
                        source: img
                        color: card.containsMouse ? card.progressBarColor : card.iconColor
                        Behavior on color { ColorAnimation { duration: Theme.animFast } }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 2

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Text {
                            text: card.category
                            color: card.containsMouse ? card.progressBarColor : Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            font.bold: true
                            font.letterSpacing: 0.6
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            Behavior on color { ColorAnimation { duration: Theme.animFast } }
                        }

                        Rectangle {
                            visible: card.showProgressBar
                            Layout.preferredWidth: percentText.implicitWidth + 14
                            Layout.preferredHeight: 20
                            radius: 10
                            color: Qt.rgba(card.progressBarColor.r, card.progressBarColor.g, card.progressBarColor.b, 0.10)
                            border.color: Qt.rgba(card.progressBarColor.r, card.progressBarColor.g, card.progressBarColor.b, 0.25)
                            border.width: 1

                            Text {
                                id: percentText
                                anchors.centerIn: parent
                                text: Math.round(card.progressBarValue * 100) + "%"
                                color: card.progressBarColor
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                                font.bold: true
                            }
                        }
                    }

                    Text {
                        text: card.value ? card.value : qsTr("Detecting...")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 15
                        font.bold: true
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    Text {
                        text: card.subValue
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        visible: text !== ""
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                }
            }

            Rectangle {
                id: progressTrack
                visible: card.showProgressBar
                Layout.fillWidth: true
                Layout.preferredHeight: 3
                radius: 1.5
                color: Qt.rgba(card.progressBarColor.r, card.progressBarColor.g, card.progressBarColor.b, 0.13)

                Rectangle {
                    height: parent.height
                    width: parent.width * Math.max(0, Math.min(1, card.progressBarValue))
                    radius: parent.radius
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: card.progressBarColor }
                        GradientStop { position: 1.0; color: Theme.accentLight }
                    }
                    Behavior on width {
                        NumberAnimation {
                            duration: 280
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }
    }
}
