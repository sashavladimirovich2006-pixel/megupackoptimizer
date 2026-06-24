import QtQuick
import Qt5Compat.GraphicalEffects
import MeguPackOptimizer 1.0

Item {
    id: control

    property string iconSource: ""
    property real iconRotation: 0
    property bool accented: false
    property bool destructive: false
    property bool flat: false

    signal clicked()

    implicitWidth: 30
    implicitHeight: 30
    opacity: enabled ? 1.0 : 0.32
    scale: enabled ? (mouseArea.pressed ? 0.90 : (mouseArea.containsMouse ? 1.06 : 1.0)) : 1.0

    readonly property color activeColor: destructive ? Theme.error : Theme.accent
    readonly property color iconColor: {
        if (!enabled) return Theme.textMuted;
        if (mouseArea.containsMouse || accented) return activeColor;
        return Theme.textSecondary;
    }

    Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
    Behavior on scale { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }

    DropShadow {
        anchors.fill: bg
        horizontalOffset: 0
        verticalOffset: 0
        radius: mouseArea.containsMouse && control.enabled ? 10 : 0
        color: Qt.rgba(control.activeColor.r, control.activeColor.g, control.activeColor.b, mouseArea.containsMouse ? 0.35 : 0.0)
        source: bg
        visible: control.enabled && mouseArea.containsMouse
        Behavior on radius { NumberAnimation { duration: Theme.animFast } }
        Behavior on color { ColorAnimation { duration: Theme.animFast } }
    }

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: Math.min(width, height) / 2
        color: {
            if (control.flat && !mouseArea.containsMouse && !mouseArea.pressed) return "transparent";
            if (mouseArea.pressed) return Qt.rgba(control.activeColor.r, control.activeColor.g, control.activeColor.b, 0.22);
            if (mouseArea.containsMouse || control.accented) return Qt.rgba(control.activeColor.r, control.activeColor.g, control.activeColor.b, 0.12);
            return Theme.buttonBg;
        }
        border.color: {
            if (mouseArea.containsMouse || control.accented) return Qt.rgba(control.activeColor.r, control.activeColor.g, control.activeColor.b, 0.62);
            if (control.flat) return "transparent";
            return Theme.border;
        }
        border.width: 1

        Behavior on color { ColorAnimation { duration: Theme.animFast } }
        Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
    }

    Image {
        id: iconImage
        source: control.iconSource
        anchors.centerIn: parent
        width: 14
        height: 14
        sourceSize.width: 14
        sourceSize.height: 14
        rotation: control.iconRotation
        visible: false
    }

    ColorOverlay {
        anchors.fill: iconImage
        source: iconImage
        color: control.iconColor
        Behavior on color { ColorAnimation { duration: Theme.animFast } }
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
