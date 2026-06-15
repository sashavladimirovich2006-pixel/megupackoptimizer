import QtQuick
import QtQuick.Controls
import MeguPackOptimizer 1.0

ScrollBar {
    id: control
    implicitWidth: 14
    implicitHeight: 14
    
    // Always show scrollbar when view is scrollable (i.e. size < 1.0)
    policy: control.size < 1.0 ? ScrollBar.AlwaysOn : ScrollBar.AsNeeded

    contentItem: Rectangle {
        // Wider handles (6px normally, 10px when hovered/active) for better visibility and easier dragging
        implicitWidth: (control.hovered || control.pressed || control.active) ? 10 : 6
        implicitHeight: (control.hovered || control.pressed || control.active) ? 10 : 6
        radius: width / 2
        
        color: {
            if (control.pressed) return Theme.accent;
            if (control.hovered) return Theme.accentLight;
            return Theme.currentTheme === "Белоснежная" ? "#60000000" : "#50FFFFFF";
        }
        
        // Higher default opacity (0.5 instead of 0.3) so it's clearly visible
        opacity: (control.hovered || control.pressed || control.active) ? 0.95 : 0.5
        
        Behavior on color { ColorAnimation { duration: Theme.animFast } }
        Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
        Behavior on implicitWidth { NumberAnimation { duration: Theme.animFast } }
        Behavior on implicitHeight { NumberAnimation { duration: Theme.animFast } }
    }

    background: Rectangle {
        color: "transparent"
    }
}
