import QtQuick
import MeguPackOptimizer 1.0
import Qt5Compat.GraphicalEffects

Rectangle {
    id: panel
    
    readonly property bool containsMouse: hoverArea.containsMouse

    property bool isFlashing: false
    property double flashOpacity: 0.0

    color: Theme.panelBg
    radius: 12 // Modernized rounded corners
    border.color: isFlashing ? Theme.success : (hoverArea.containsMouse ? Theme.borderHover : Theme.border)
    border.width: 1

    Behavior on border.color { enabled: !panel.isFlashing; ColorAnimation { duration: Theme.animNormal } }
    Behavior on color { ColorAnimation { duration: Theme.animNormal } }

    transform: Translate {
        y: (hoverArea.containsMouse && !panel.isFlashing) ? -2 : 0
        Behavior on y {
            NumberAnimation {
                duration: Theme.animNormal
                easing.type: Easing.OutCubic
            }
        }
    }

    // Dynamic soft drop shadow glow under panel
    DropShadow {
        anchors.fill: panel
        horizontalOffset: 0
        verticalOffset: hoverArea.containsMouse ? 8 : 4
        radius: hoverArea.containsMouse ? 16 : 8
        color: hoverArea.containsMouse ? Qt.rgba(0, 0, 0, 0.45) : Qt.rgba(0, 0, 0, 0.25)
        source: panel
        z: -1
        visible: Theme.currentTheme !== "Белоснежная"
        
        Behavior on verticalOffset { NumberAnimation { duration: Theme.animNormal } }
        Behavior on radius { NumberAnimation { duration: Theme.animNormal } }
        Behavior on color { ColorAnimation { duration: Theme.animNormal } }
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

    // Thin elegant inner border for that clean physical edge
    Rectangle {
        anchors.fill: parent
        radius: panel.radius
        color: "transparent"
        border.color: (Theme.currentTheme === "Белоснежная" || Theme.currentTheme === "Розовая") ? "#11FFFFFF" : "#05FFFFFF"
        border.width: 1
        anchors.margins: 1
    }

    // Premium highlighted outline border for locate/eye function (flashes and fades after 3 seconds)
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

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        propagateComposedEvents: true
    }

    default property alias content: container.data

    Item {
        id: container
        anchors.fill: parent
        anchors.margins: 16 // spacious and clean padding matching the reference design!
    }
}
