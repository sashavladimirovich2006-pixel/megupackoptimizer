import QtQuick
import QtQuick.Controls.Basic
import MeguPackOptimizer 1.0
import Qt5Compat.GraphicalEffects

Slider {
    id: control
    implicitWidth: 200
    implicitHeight: 36
    hoverEnabled: true

    readonly property bool activeState: hovered || pressed
    
    background: Rectangle {
        x: control.leftPadding
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: 200
        implicitHeight: 8
        width: control.availableWidth
        height: implicitHeight
        radius: 4
        color: Theme.buttonBg
        border.color: control.activeState ? Theme.borderHover : Theme.border
        border.width: 1

        Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
        
        Rectangle {
            x: 1
            y: 1
            width: Math.max(0, control.visualPosition * (parent.width - 2))
            height: parent.height - 2
            radius: 3
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: Theme.accentDark }
                GradientStop { position: 0.55; color: Theme.accent }
                GradientStop { position: 1.0; color: Theme.accentLight }
            }
            Behavior on width { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }
        }
    }
    
    handle: Rectangle {
        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: control.pressed ? 22 : 18
        implicitHeight: 18
        radius: 9
        color: control.pressed ? Theme.accentLight : Theme.panelBg
        border.color: control.activeState ? Theme.accentLight : Theme.accent
        border.width: 1
        
        Behavior on color { ColorAnimation { duration: Theme.animFast } }
        Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
        Behavior on implicitWidth { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }
        Behavior on scale {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }
        scale: control.pressed ? 1.08 : (control.hovered ? 1.04 : 1.0)
        
        // Add a soft glow behind the slider handle when active
        layer.enabled: control.activeState
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 0
            verticalOffset: 0
            radius: 10
            color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.5)
        }
    }
}
