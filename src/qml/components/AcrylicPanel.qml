import QtQuick
import MeguPackOptimizer 1.0

Rectangle {
    id: panel
    
    color: Theme.panelBg
    radius: Theme.radiusNormal
    border.color: Theme.border
    border.width: 1

    // Add behavior for smooth state animations
    Behavior on color { ColorAnimation { duration: Theme.animNormal } }
    Behavior on border.color { ColorAnimation { duration: Theme.animNormal } }

    // Inner highlight reflection ring (Glassmorphic style)
    Rectangle {
        anchors.fill: parent
        radius: panel.radius
        color: "transparent"
        border.color: "#0EFFFFFF" // Extremely subtle white highlight inside the border
        border.width: 1
        anchors.margins: 1
    }

    // Default property to host children controls inside the padded container
    default property alias content: container.data

    Item {
        id: container
        anchors.fill: parent
        anchors.margins: 14
    }
}
