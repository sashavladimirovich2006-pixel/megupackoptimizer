import QtQuick
import MeguPackOptimizer 1.0
import Qt5Compat.GraphicalEffects

Rectangle {
    id: panel

    readonly property bool containsMouse: hoverArea.containsMouse
    readonly property bool hovered: panel.interactive && hoverArea.containsMouse

    property bool isFlashing: false
    property double flashOpacity: 0.0
    property color accentColor: panel.danger ? Theme.error : Theme.accent
    property bool accented: true
    property bool danger: false
    property bool pressed: false
    property bool interactive: true
    property bool compact: false
    property int contentMargins: compact ? 12 : 14

    color: "transparent"
    radius: Theme.radiusNormal
    border.color: isFlashing ? Theme.success : (hovered || pressed ? Theme.cardStrokeHover : Theme.cardStroke)
    border.width: 1
    clip: false

    Behavior on border.color { enabled: !panel.isFlashing; ColorAnimation { duration: Theme.animFast } }

    transform: Translate {
        y: (panel.hovered && !panel.isFlashing) ? -1 : 0
        Behavior on y {
            NumberAnimation {
                duration: Theme.animFast
                easing.type: Easing.OutCubic
            }
        }
    }

    DropShadow {
        cached: true
        anchors.fill: backgroundPlate
        horizontalOffset: 0
        verticalOffset: panel.hovered ? 10 : 4
        radius: panel.hovered ? 22 : 12
        samples: 24
        color: panel.hovered
            ? Qt.rgba(panel.accentColor.r, panel.accentColor.g, panel.accentColor.b, panel.danger ? 0.22 : 0.16)
            : Theme.cardShadow
        source: backgroundPlate
        z: -2
        visible: Theme.currentTheme !== "Белоснежная"

        Behavior on verticalOffset { NumberAnimation { duration: Theme.animFast } }
        Behavior on radius { NumberAnimation { duration: Theme.animFast } }
        Behavior on color { ColorAnimation { duration: Theme.animFast } }
    }

    Rectangle {
        id: backgroundPlate
        anchors.fill: parent
        radius: panel.radius
        border.width: 0
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: panel.pressed
                    ? Theme.buttonBgPressed
                    : (panel.hovered ? Theme.cardBgHover : Theme.cardBg)
            }
            GradientStop {
                position: 1.0
                color: panel.hovered
                    ? Qt.rgba(panel.accentColor.r, panel.accentColor.g, panel.accentColor.b, panel.danger ? 0.10 : 0.075)
                    : Qt.rgba(panel.accentColor.r, panel.accentColor.g, panel.accentColor.b, panel.danger ? 0.055 : 0.028)
            }
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 1
        anchors.rightMargin: 1
        anchors.topMargin: 1
        height: 1
        radius: 0.5
        color: Theme.cardTopSheen
        opacity: panel.hovered ? 0.72 : 0.38
        Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
    }

    Rectangle {
        width: panel.hovered || panel.pressed || panel.danger ? 4 : 2
        height: Math.max(18, parent.height - 24)
        radius: width / 2
        color: panel.accentColor
        opacity: (panel.accented || panel.danger || panel.hovered || panel.pressed) ? (panel.hovered || panel.pressed ? 0.95 : 0.55) : 0.0
        anchors.left: parent.left
        anchors.leftMargin: 9
        anchors.verticalCenter: parent.verticalCenter

        Behavior on width { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
        Behavior on color { ColorAnimation { duration: Theme.animFast } }
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        radius: Math.max(0, panel.radius - 1)
        color: "transparent"
        border.color: Qt.rgba(1, 1, 1, panel.hovered ? 0.10 : 0.055)
        border.width: 1
        Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
    }

    Rectangle {
        anchors.fill: parent
        radius: panel.radius
        color: "transparent"
        border.color: Theme.success
        border.width: 2
        opacity: panel.flashOpacity
        visible: opacity > 0.0
        anchors.margins: -1
    }

    function triggerLocateFlash() {
        locateFlashAnim.stop();
        locateFlashAnim.start();
    }

    SequentialAnimation {
        id: locateFlashAnim

        ScriptAction {
            script: {
                flashOpacityAnim.stop();
                panel.flashOpacity = 1.0;
            }
        }
        PauseAnimation { duration: 3000 }
        NumberAnimation {
            id: flashOpacityAnim
            target: panel
            property: "flashOpacity"
            to: 0.0
            duration: 1000
            easing.type: Easing.OutQuad
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: panel.interactive
        acceptedButtons: Qt.NoButton
        propagateComposedEvents: true
    }

    default property alias content: container.data

    Item {
        id: container
        anchors.fill: parent
        anchors.margins: panel.contentMargins
    }
}
