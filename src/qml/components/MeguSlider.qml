import QtQuick
import QtQuick.Controls.Basic
import MeguPackOptimizer 1.0
import Qt5Compat.GraphicalEffects

Slider {
    id: control
    implicitWidth: 200
    implicitHeight: 32
    
    background: Rectangle {
        x: control.leftPadding
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: 200
        implicitHeight: 4
        width: control.availableWidth
        height: implicitHeight
        radius: 2
        color: Theme.border
        
        Rectangle {
            width: control.visualPosition * parent.width
            height: parent.height
            color: Theme.accent
            radius: 2
        }
    }
    
    handle: Rectangle {
        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: 16
        implicitHeight: 16
        radius: 8
        color: control.pressed ? Theme.accent : Theme.textPrimary
        border.color: Theme.accent
        border.width: control.hovered ? 2 : 0
        
        Behavior on color { ColorAnimation { duration: Theme.animFast } }
        Behavior on scale {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }
        scale: control.pressed ? 1.25 : (control.hovered ? 1.15 : 1.0)
        
        // Add a soft glow behind the slider handle when active
        layer.enabled: control.hovered || control.pressed
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 0
            verticalOffset: 0
            radius: 4
            color: Theme.accent
        }
    }
}
