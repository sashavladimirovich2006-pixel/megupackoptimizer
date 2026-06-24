import QtQuick
import QtQuick.Controls
import MeguPackOptimizer 1.0

ScrollBar {
    id: control
    implicitWidth: 14
    implicitHeight: 14
    z: 100
    
    // Always show scrollbar when view is scrollable (i.e. size < 1.0)
    policy: control.size < 1.0 ? ScrollBar.AlwaysOn : ScrollBar.AsNeeded

    contentItem: Rectangle {
        // Wider handles (6px normally, 10px when hovered/active) for better visibility and easier dragging
        implicitWidth: control.orientation === Qt.Vertical ? ((control.hovered || control.pressed || control.active) ? 10 : 6) : undefined
        implicitHeight: control.orientation === Qt.Horizontal ? ((control.hovered || control.pressed || control.active) ? 10 : 6) : undefined
        radius: Math.min(width, height) / 2
        
        color: {
            if (control.pressed) return Theme.accent;
            if (control.hovered) return Theme.accentLight;
            // High-contrast, clean semi-transparent handle for both themes
            return Theme.currentTheme === "Белоснежная" ? "#A0000000" : "#A0FFFFFF";
        }
        
        // Clearly visible opacity when idle, solid when active
        opacity: (control.hovered || control.pressed || control.active) ? 0.95 : 0.6
        
        Behavior on color { ColorAnimation { duration: Theme.animFast } }
        Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
        Behavior on implicitWidth { NumberAnimation { duration: Theme.animFast } }
        Behavior on implicitHeight { NumberAnimation { duration: Theme.animFast } }
    }

    background: Rectangle {
        color: "transparent"
    }
}
