import QtQuick
import MeguPackOptimizer 1.0

Rectangle {
    id: panel
    
    readonly property bool containsMouse: hoverArea.containsMouse

    property bool isFlashing: false

    color: Theme.panelBg
    radius: 8
    border.color: isFlashing ? Theme.accent : (hoverArea.containsMouse ? Theme.borderHover : Theme.border)
    border.width: 1

    Behavior on border.color { ColorAnimation { duration: Theme.animNormal } }
    Behavior on color { ColorAnimation { duration: Theme.animNormal } }

    // Thin elegant inner border for that clean physical edge
    Rectangle {
        anchors.fill: parent
        radius: panel.radius
        color: "transparent"
        border.color: (Theme.currentTheme === "Белоснежная" || Theme.currentTheme === "Розовая") ? "#11FFFFFF" : "#05FFFFFF"
        border.width: 1
        anchors.margins: 1
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
