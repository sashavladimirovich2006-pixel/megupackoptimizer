import QtQuick
import MeguPackOptimizer 1.0

Rectangle {
    id: panel
    
    color: "transparent"
    radius: Theme.radiusNormal
    border.color: Theme.border
    border.width: 1

    // Add behavior for smooth state animations
    Behavior on border.color { ColorAnimation { duration: Theme.animNormal } }

    // Premium translucent frosted glass layer with vertical specular gloss reflection
    Rectangle {
        anchors.fill: parent
        radius: panel.radius
        z: -1
        
        color: Theme.panelBg
        
        // Vertical specular highlight (light sheen reflecting off the top edge)
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            gradient: Gradient {
                GradientStop { 
                    position: 0.0
                    color: (Theme.currentTheme === "Белоснежная" || Theme.currentTheme === "Розовая") ? "#33FFFFFF" : "#1AFFFFFF" 
                }
                GradientStop { 
                    position: 0.4
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
        border.color: (Theme.currentTheme === "Белоснежная" || Theme.currentTheme === "Розовая") ? "#33FFFFFF" : "#0EFFFFFF"
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
