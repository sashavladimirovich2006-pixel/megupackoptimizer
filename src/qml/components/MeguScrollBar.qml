import QtQuick
import QtQuick.Controls
import MeguPackOptimizer 1.0

ScrollBar {
    id: control
    implicitWidth: 8
    implicitHeight: 8
    policy: ScrollBar.AsNeeded

    contentItem: Rectangle {
        implicitWidth: (control.hovered || control.pressed || control.active) ? 8 : 4
        implicitHeight: (control.hovered || control.pressed || control.active) ? 8 : 4
        radius: width / 2
        
        color: {
            if (control.pressed) return Theme.accent;
            if (control.hovered) return Theme.accentLight;
            return Theme.currentTheme === "Белоснежная" ? "#40000000" : "#30FFFFFF";
        }
        
        opacity: (control.hovered || control.pressed || control.active) ? 0.8 : 0.3
        
        Behavior on color { ColorAnimation { duration: Theme.animFast } }
        Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
    }

    background: Rectangle {
        color: "transparent"
    }
}
