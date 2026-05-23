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
            width: 38
            height: 20
            radius: 10
            anchors.verticalCenter: parent.verticalCenter
            
            color: control.checked ? Theme.accent : (control.indeterminate ? Theme.accentDim : "#232F44")
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
                opacity: ((control.checked || control.indeterminate) && mouseArea.containsMouse && control.enabled) ? 0.3 : 0.0
                Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
            }
            
            // Thumb
            Rectangle {
                id: thumb
                width: 14
                height: 14
                radius: 7
                color: (control.checked || control.indeterminate) ? Theme.textPrimary : Theme.textSecondary
                anchors.verticalCenter: parent.verticalCenter
                
                // Position animation (middle if indeterminate, right if checked, left if unchecked)
                x: control.indeterminate ? ((track.width - width) / 2) : (control.checked ? (track.width - width - 3) : 3)
                
                Behavior on x {
                    NumberAnimation {
                        duration: Theme.animFast
                        easing.type: Easing.InOutQuad
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
                // If it was indeterminate, toggling should turn it ON (checked=true, indeterminate=false)
                if (control.indeterminate) {
                    control.indeterminate = false;
                    control.checked = true;
                } else {
                    control.checked = !control.checked;
                }
                control.toggled(control.checked);
            }
        }
    }
}
