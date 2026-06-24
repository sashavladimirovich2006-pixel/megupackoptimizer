import QtQuick
import Qt5Compat.GraphicalEffects
import MeguPackOptimizer 1.0

Item {
    id: control

    property string title: ""
    property string description: ""
    property string iconSource: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"

    signal clicked()

    implicitWidth: 360
    implicitHeight: Math.max(58, titleText.implicitHeight + descText.implicitHeight + 24)
    height: implicitHeight

    readonly property bool hovered: mouseArea.containsMouse && control.enabled
    readonly property bool pressed: mouseArea.pressed && control.enabled

    opacity: enabled ? 1.0 : 0.45
    Behavior on opacity { NumberAnimation { duration: Theme.animFast } }

    DropShadow {
        anchors.fill: plate
        horizontalOffset: 0
        verticalOffset: control.hovered ? 8 : 3
        radius: control.hovered ? 18 : 8
        color: Qt.rgba(0, 0, 0, control.hovered ? 0.32 : 0.18)
        source: plate
        visible: Theme.currentTheme !== "Белоснежная" && control.enabled
        Behavior on verticalOffset { NumberAnimation { duration: Theme.animFast } }
        Behavior on radius { NumberAnimation { duration: Theme.animFast } }
        Behavior on color { ColorAnimation { duration: Theme.animFast } }
    }

    Rectangle {
        id: plate
        anchors.fill: parent
        anchors.leftMargin: control.hovered ? 3 : 0
        anchors.rightMargin: control.hovered ? -3 : 0
        radius: Theme.radiusNormal
        color: control.pressed
            ? Theme.buttonBgPressed
            : (control.hovered ? Theme.cardBgHover : Theme.cardBg)
        border.color: control.hovered ? Theme.cardStrokeHover : Theme.cardStroke
        border.width: 1

        Behavior on anchors.leftMargin { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }
        Behavior on anchors.rightMargin { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }
        Behavior on color { ColorAnimation { duration: Theme.animFast } }
        Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.leftMargin: 1
            anchors.rightMargin: 1
            anchors.topMargin: 1
            height: 1
            color: Theme.cardTopSheen
            opacity: control.hovered ? 0.65 : 0.32
            Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
        }

        Rectangle {
            width: control.hovered ? 4 : 2
            height: parent.height - 18
            radius: width / 2
            color: Theme.accent
            opacity: control.hovered ? 1.0 : 0.45
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            Behavior on width { NumberAnimation { duration: Theme.animFast } }
            Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
        }

        Column {
            anchors.left: parent.left
            anchors.leftMargin: 24
            anchors.right: arrowSlot.left
            anchors.rightMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            spacing: 3

            Text {
                id: titleText
                text: control.title
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
                elide: Text.ElideRight
                width: parent.width
            }

            Text {
                id: descText
                text: control.description
                color: control.hovered ? Theme.textSecondary : Theme.textMuted
                font.family: Theme.fontFamily
                font.pixelSize: 9
                lineHeight: 1.05
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
                width: parent.width
                Behavior on color { ColorAnimation { duration: Theme.animFast } }
            }
        }

        Item {
            id: arrowSlot
            width: 28
            height: 28
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                anchors.fill: parent
                radius: 14
                color: control.hovered ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.14) : Theme.buttonBg
                border.color: control.hovered ? Theme.accent : Theme.cardStroke
                border.width: 1
                Behavior on color { ColorAnimation { duration: Theme.animFast } }
                Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
            }

            Image {
                id: arrowIcon
                source: control.iconSource
                anchors.centerIn: parent
                width: 13
                height: 13
                sourceSize.width: 13
                sourceSize.height: 13
                visible: false
            }

            ColorOverlay {
                anchors.fill: arrowIcon
                source: arrowIcon
                color: control.hovered ? Theme.accentLight : Theme.accent
                Behavior on color { ColorAnimation { duration: Theme.animFast } }
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: control.enabled
        cursorShape: control.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            if (control.enabled) {
                control.clicked();
            }
        }
    }
}
