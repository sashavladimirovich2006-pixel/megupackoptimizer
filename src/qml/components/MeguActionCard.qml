import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import MeguPackOptimizer 1.0

Item {
    id: control

    property string title: ""
    property string description: ""
    property string iconSource: ""
    property color accentColor: control.danger ? Theme.error : Theme.accent
    property bool danger: false
    property bool clickable: false

    readonly property bool hovered: hoverArea.containsMouse && control.enabled
    readonly property bool pressed: clickArea.pressed && control.enabled

    signal clicked()

    default property alias content: trailingContent.data

    implicitWidth: 360
    implicitHeight: Math.max(62, Math.max(iconTile.visible ? 40 : 0, textColumn.implicitHeight) + 24)
    height: implicitHeight

    opacity: enabled ? 1.0 : 0.45
    Behavior on opacity { NumberAnimation { duration: Theme.animFast } }

    AcrylicPanel {
        id: plate
        anchors.fill: parent
        accentColor: control.accentColor
        accented: true
        danger: control.danger
        pressed: control.pressed
        interactive: control.enabled
        compact: true
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 12

        Rectangle {
            id: iconTile
            visible: control.iconSource !== ""
            Layout.preferredWidth: visible ? 40 : 0
            Layout.preferredHeight: visible ? 40 : 0
            Layout.alignment: Qt.AlignVCenter
            radius: 11
            color: control.hovered
                ? Qt.rgba(control.accentColor.r, control.accentColor.g, control.accentColor.b, control.danger ? 0.18 : 0.16)
                : Qt.rgba(control.accentColor.r, control.accentColor.g, control.accentColor.b, control.danger ? 0.12 : 0.09)
            border.color: Qt.rgba(control.accentColor.r, control.accentColor.g, control.accentColor.b, control.hovered ? 0.45 : 0.22)
            border.width: 1

            Behavior on color { ColorAnimation { duration: Theme.animFast } }
            Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

            Image {
                id: iconImage
                source: control.iconSource
                anchors.centerIn: parent
                width: 20
                height: 20
                sourceSize.width: 20
                sourceSize.height: 20
                visible: false
            }

            ColorOverlay {
                anchors.fill: iconImage
                source: iconImage
                color: control.hovered ? Theme.accentLight : control.accentColor
                Behavior on color { ColorAnimation { duration: Theme.animFast } }
            }
        }

        ColumnLayout {
            id: textColumn
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            Text {
                text: control.title
                color: control.danger ? Theme.error : Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 13
                font.bold: true
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            Text {
                text: control.description
                visible: text !== ""
                color: control.hovered ? Theme.textSecondary : Theme.textMuted
                font.family: Theme.fontFamily
                font.pixelSize: 10
                lineHeight: 1.08
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
                Layout.fillWidth: true
                Behavior on color { ColorAnimation { duration: Theme.animFast } }
            }
        }

        Item {
            id: trailingContent
            visible: children.length > 0
            Layout.preferredWidth: visible ? Math.max(1, childrenRect.x + childrenRect.width) : 0
            Layout.minimumWidth: visible ? Math.min(120, Math.max(1, childrenRect.x + childrenRect.width)) : 0
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: control.enabled
        acceptedButtons: Qt.NoButton
        propagateComposedEvents: true
    }

    MouseArea {
        id: clickArea
        anchors.fill: parent
        enabled: control.clickable && control.enabled
        hoverEnabled: false
        cursorShape: Qt.PointingHandCursor
        onClicked: control.clicked()
    }
}
