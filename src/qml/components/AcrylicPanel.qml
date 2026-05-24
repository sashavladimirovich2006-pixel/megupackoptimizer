import QtQuick
import MeguPackOptimizer 1.0

Rectangle {
    id: panel
    
    readonly property bool containsMouse: hoverArea.containsMouse

    color: "transparent"
    radius: Theme.radiusNormal
    border.color: hoverArea.containsMouse ? Theme.accent : Theme.border
    border.width: 1

    Behavior on border.color { ColorAnimation { duration: Theme.animNormal } }

    // Premium translucent frosted glass layer
    Rectangle {
        anchors.fill: parent
        radius: panel.radius
        z: -1
        
        color: Theme.panelBg
        
        // Vertical specular highlight (ambient light sheen reflecting off the top edge)
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            gradient: Gradient {
                GradientStop { 
                    position: 0.0
                    color: (Theme.currentTheme === "Белоснежная" || Theme.currentTheme === "Розовая") ? "#22FFFFFF" : "#12FFFFFF" 
                }
                GradientStop { 
                    position: 0.3
                    color: "transparent" 
                }
            }
        }
        
        Behavior on color { ColorAnimation { duration: Theme.animNormal } }
    }

    // Inner highlight reflection ring (Glassmorphic style)
    Rectangle {
        anchors.fill: parent
        radius: panel.radius
        color: "transparent"
        border.color: hoverArea.containsMouse ? Theme.accentDim : ((Theme.currentTheme === "Белоснежная" || Theme.currentTheme === "Розовая") ? "#33FFFFFF" : "#0EFFFFFF")
        border.width: 1
        anchors.margins: 1
        
        Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
    }

    // Animated diagonal reflection sheen (блик)
    Rectangle {
        id: diagonalSheen
        width: 100
        height: parent.height * 2.5
        rotation: 25
        anchors.verticalCenter: parent.verticalCenter
        z: -1
        
        // High-end sweeping specular gradient
        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 0.5; color: (Theme.currentTheme === "Белоснежная" || Theme.currentTheme === "Розовая") ? "#44FFFFFF" : "#22FFFFFF" }
            GradientStop { position: 1.0; color: "transparent" }
        }

        x: -diagonalSheen.width - 50
        
        NumberAnimation on x {
            id: sheenAnimation
            from: -diagonalSheen.width - 50
            to: panel.width + diagonalSheen.width + 50
            duration: 1200
            easing.type: Easing.OutCubic
            running: false
        }
    }

    // High-Tech Cyber Corner Brackets (HUD style frames/borders)
    Item {
        anchors.fill: parent
        z: -1
        opacity: hoverArea.containsMouse ? 1.0 : 0.4
        
        Behavior on opacity { NumberAnimation { duration: Theme.animNormal } }

        // Top-Left Bracket
        Rectangle { x: 0; y: 0; width: 10; height: 1.5; color: Theme.accent; radius: 0.5 }
        Rectangle { x: 0; y: 0; width: 1.5; height: 10; color: Theme.accent; radius: 0.5 }
        
        // Top-Right Bracket
        Rectangle { x: parent.width - 10; y: 0; width: 10; height: 1.5; color: Theme.accent; radius: 0.5 }
        Rectangle { x: parent.width - 1.5; y: 0; width: 1.5; height: 10; color: Theme.accent; radius: 0.5 }
        
        // Bottom-Left Bracket
        Rectangle { x: 0; y: parent.height - 1.5; width: 10; height: 1.5; color: Theme.accent; radius: 0.5 }
        Rectangle { x: 0; y: parent.height - 10; width: 1.5; height: 10; color: Theme.accent; radius: 0.5 }
        
        // Bottom-Right Bracket
        Rectangle { x: parent.width - 10; y: parent.height - 1.5; width: 10; height: 1.5; color: Theme.accent; radius: 0.5 }
        Rectangle { x: parent.width - 1.5; y: parent.height - 10; width: 1.5; height: 10; color: Theme.accent; radius: 0.5 }
    }

    // Mouse area to trigger specular sweep without stealing events
    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        propagateComposedEvents: true
        
        onContainsMouseChanged: {
            if (containsMouse && !sheenAnimation.running) {
                sheenAnimation.from = -diagonalSheen.width - 50;
                sheenAnimation.to = panel.width + diagonalSheen.width + 50;
                sheenAnimation.start();
            }
        }
    }

    // Default property to host children controls inside the padded container
    default property alias content: container.data

    Item {
        id: container
        anchors.fill: parent
        anchors.margins: 14
    }
}
