import QtQuick
import QtQuick.Controls.Basic
import MeguPackOptimizer 1.0
import Qt5Compat.GraphicalEffects

ScrollBar {
    id: control
    implicitWidth: 16
    implicitHeight: 16
    z: 100
    interactive: true
    
    // Always show scrollbar when view is scrollable (i.e. size < 1.0)
    policy: control.size < 1.0 ? ScrollBar.AlwaysOn : ScrollBar.AsNeeded

    contentItem: Item {
        id: handleContainer
        
        DropShadow {
            anchors.fill: handleRect
            horizontalOffset: 0
            verticalOffset: 0
            radius: (control.hovered || control.pressed || control.active) ? 8 : 0
            color: (control.hovered || control.pressed || control.active) ? Theme.accent : "transparent"
            source: handleRect
            visible: (control.hovered || control.pressed || control.active)
            Behavior on radius { NumberAnimation { duration: Theme.animFast } }
            Behavior on color { ColorAnimation { duration: Theme.animFast } }
        }

        Rectangle {
            id: handleRect
            anchors.centerIn: parent
            width: control.orientation === Qt.Vertical 
                ? ((control.hovered || control.pressed || control.active) ? 10 : 6) 
                : parent.width
            height: control.orientation === Qt.Horizontal 
                ? ((control.hovered || control.pressed || control.active) ? 10 : 6) 
                : parent.height
            radius: Math.min(width, height) / 2
            
            color: {
                if (control.pressed) return Theme.accent;
                if (control.hovered) return Theme.accentLight;
                
                // Premium semi-transparent neutral handle colors adapting to the current theme
                var isLightTheme = (Theme.currentTheme === "Белоснежная" || Theme.currentTheme === "Розовая");
                return isLightTheme ? "#50000000" : "#40FFFFFF";
            }
            
            // Dynamic opacity: slightly softer when idle
            opacity: (control.hovered || control.pressed || control.active) ? 0.95 : 0.65
            
            Behavior on width { NumberAnimation { duration: Theme.animFast } }
            Behavior on height { NumberAnimation { duration: Theme.animFast } }
            Behavior on color { ColorAnimation { duration: Theme.animFast } }
            Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
        }
    }

    background: Rectangle {
        implicitWidth: control.orientation === Qt.Vertical ? 16 : 0
        implicitHeight: control.orientation === Qt.Horizontal ? 16 : 0
        radius: width / 2
        
        // Faint, premium background track always visible to guide interaction
        color: {
            var isLightTheme = (Theme.currentTheme === "Белоснежная" || Theme.currentTheme === "Розовая");
            if (control.hovered || control.pressed || control.active) {
                return isLightTheme ? "#1C000000" : "#1CFFFFFF";
            }
            return isLightTheme ? "#0A000000" : "#0AFFFFFF"; // 4% Light, 6% Dark opacity
        }
        
        // Very subtle border matching the panel borders
        border.color: {
            var isLightTheme = (Theme.currentTheme === "Белоснежная" || Theme.currentTheme === "Розовая");
            if (control.hovered || control.pressed || control.active) {
                return isLightTheme ? "#30000000" : "#30FFFFFF";
            }
            return isLightTheme ? "#15000000" : "#15FFFFFF";
        }
        border.width: 1
        
        Behavior on color { ColorAnimation { duration: Theme.animFast } }
        Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
    }
}

