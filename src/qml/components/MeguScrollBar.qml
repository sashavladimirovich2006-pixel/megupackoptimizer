import QtQuick
import QtQuick.Controls.Basic
import MeguPackOptimizer 1.0

ScrollBar {
    id: control
    implicitWidth: 14
    implicitHeight: 14
    z: 100
    interactive: true
    
    // Always show scrollbar when view is scrollable (i.e. size < 1.0)
    policy: control.size < 1.0 ? ScrollBar.AlwaysOn : ScrollBar.AsNeeded

    contentItem: Rectangle {
        // Sleek handle (4px normally, 8px when hovered/pressed/active) centered in the track
        implicitWidth: control.orientation === Qt.Vertical ? ((control.hovered || control.pressed || control.active) ? 8 : 4) : undefined
        implicitHeight: control.orientation === Qt.Horizontal ? ((control.hovered || control.pressed || control.active) ? 8 : 4) : undefined
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
        
        Behavior on color { ColorAnimation { duration: Theme.animFast } }
        Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
        Behavior on implicitWidth { NumberAnimation { duration: Theme.animFast } }
        Behavior on implicitHeight { NumberAnimation { duration: Theme.animFast } }
    }

    background: Rectangle {
        implicitWidth: control.orientation === Qt.Vertical ? 14 : undefined
        implicitHeight: control.orientation === Qt.Horizontal ? 14 : undefined
        radius: width / 2
        
        // Faint, premium background track visible when hovered/active to guide interaction
        color: {
            if (control.hovered || control.pressed || control.active) {
                var isLightTheme = (Theme.currentTheme === "Белоснежная" || Theme.currentTheme === "Розовая");
                return isLightTheme ? "#10000000" : "#10FFFFFF"; // 6% opacity
            }
            return "transparent";
        }
        
        // Very subtle border matching the panel borders
        border.color: {
            if (control.hovered || control.pressed || control.active) {
                var isLightTheme = (Theme.currentTheme === "Белоснежная" || Theme.currentTheme === "Розовая");
                return isLightTheme ? "#15000000" : "#15FFFFFF"; // Faint border
            }
            return "transparent";
        }
        border.width: 1
        
        Behavior on color { ColorAnimation { duration: Theme.animFast } }
        Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
    }
}
