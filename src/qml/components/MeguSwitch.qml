import QtQuick
import MeguPackOptimizer 1.0

Item {
    id: control
    
    property string text: ""
    property bool checked: false
    property bool indeterminate: false
    
    signal toggled(bool isChecked)
    
    implicitWidth: switchLayout.implicitWidth
    implicitHeight: 28
    
    opacity: enabled ? 1.0 : 0.4
    Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
    
    Row {
        id: switchLayout
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10
        
        // Track and Thumb (The Switch)
        Rectangle {
            id: track
            width: 40
            height: 22
            radius: 11
            anchors.verticalCenter: parent.verticalCenter
            
            color: {
                if (control.checked) return Theme.accent;
                if (control.indeterminate) return Theme.accentDim;
                return (Theme.currentTheme === "Белоснежная" || Theme.currentTheme === "Розовая") ? Theme.buttonBg : "#121A26";
            }
            border.color: (control.checked || control.indeterminate) ? Theme.accent : (mouseArea.containsMouse ? Theme.borderHover : Theme.border)
            border.width: 1
            
            Behavior on color { ColorAnimation { duration: Theme.animFast } }
            Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
            
            // Subtle glow around track when checked/indeterminate and hovered
            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color: "transparent"
                border.color: Theme.accent
                border.width: 1.5
                opacity: ((control.checked || control.indeterminate) && mouseArea.containsMouse && control.enabled) ? 0.4 : 0.0
                Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
            }
            
            // Thumb capsule
            Rectangle {
                id: thumb
                width: 16
                height: 16
                radius: 8
                color: (control.checked || control.indeterminate) ? Theme.textInverse : Theme.textPrimary
                anchors.verticalCenter: parent.verticalCenter
                
                // Satisfying scale change when hovered or pressed
                scale: mouseArea.pressed ? 1.2 : (mouseArea.containsMouse ? 1.1 : 1.0)
                Behavior on scale { NumberAnimation { duration: 100 } }
                
                // Position animation (middle if indeterminate, right if checked, left if unchecked)
                x: control.indeterminate ? ((track.width - width) / 2) : (control.checked ? (track.width - width - 3) : 3)
                
                Behavior on x {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutBack // удовлетворяющий пружинный отскок
                    }
                }
                Behavior on color { ColorAnimation { duration: Theme.animFast } }
            }
        }
        
        // Label Text
        Text {
            text: control.text
            color: Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: 13
            font.bold: false
            anchors.verticalCenter: parent.verticalCenter
            visible: control.text !== ""
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: control.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            if (control.enabled) {
                // If it was indeterminate, toggling should turn it ON (checked=true)
                var nextState = control.indeterminate ? true : !control.checked;
                control.toggled(nextState);
            }
        }
    }
}
