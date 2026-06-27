import QtQuick
import MeguPackOptimizer 1.0

Item {
    id: control
    
    property string text: ""
    property bool checked: false
    property bool indeterminate: false
    property bool steamStyle: false
    
    signal toggled(bool isChecked)
    
    implicitWidth: text !== "" ? 200 : 40
    // Height adapts dynamically to the wrapped text height or defaults to 28px
    implicitHeight: Math.max(28, labelText.visible ? labelText.height + 4 : 22)
    
    opacity: enabled ? 1.0 : 0.4
    Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
    
    // Track and Thumb (The Switch)
    // Soft outer neon glow behind the track when checked/active
    Rectangle {
        anchors.centerIn: track
        width: track.width + 6
        height: track.height + 6
        radius: track.radius + 3
        color: Theme.accent
        opacity: (control.checked && !control.steamStyle) ? (mouseArea.containsMouse ? 0.3 : 0.15) : 0.0
        visible: opacity > 0.0
        Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }
    }

    Rectangle {
        id: track
        width: 40
        height: 22
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        radius: 11
        
        color: {
            if (control.steamStyle) {
                return "#10161f";
            }
            return (Theme.currentTheme === "Белоснежная" || Theme.currentTheme === "Розовая") ? Theme.buttonBg : "#121A26";
        }
        border.color: {
            if (control.steamStyle) {
                return control.checked ? Theme.accent : (mouseArea.containsMouse ? Theme.borderHover : "#3c485c");
            }
            return (control.checked || control.indeterminate) ? Theme.accent : (mouseArea.containsMouse ? Theme.borderHover : Qt.rgba(255, 255, 255, 0.12));
        }
        border.width: (control.steamStyle && control.checked) ? 2 : 1
        
        Behavior on color { ColorAnimation { duration: Theme.animFast } }
        Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
        
        // Gradient fill when checked
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            opacity: (control.checked && !control.steamStyle) ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }
            gradient: Gradient {
                GradientStop { position: 0.0; color: Theme.accent }
                GradientStop { position: 1.0; color: Theme.accentLight }
            }

            // Top sheen for checked track 3D inset look
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 1
                height: 1
                radius: 0.5
                color: "#FFFFFF"
                opacity: 0.22
            }
        }

        // Indeterminate fill
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            opacity: (control.indeterminate && !control.steamStyle) ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }
            color: Theme.accentDim
        }

        // Subtle glow around track when checked/indeterminate and hovered
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            border.color: Theme.accent
            border.width: 1.5
            opacity: (!control.steamStyle && (control.checked || control.indeterminate) && mouseArea.containsMouse && control.enabled) ? 0.5 : 0.0
            Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
        }
        
        // Thumb capsule
        Rectangle {
            id: thumb
            width: mouseArea.pressed ? 20 : (mouseArea.containsMouse ? 18 : 16)
            height: mouseArea.pressed ? 14 : 16
            radius: height / 2
            
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: {
                        if (control.steamStyle) return control.checked ? "#FFFFFF" : "#5d6d7e";
                        return (control.checked || control.indeterminate) ? "#FFFFFF" : "#F8FAFC"
                    }
                }
                GradientStop {
                    position: 1.0
                    color: {
                        if (control.steamStyle) return control.checked ? "#E2E8F0" : "#4b5a6c";
                        return (control.checked || control.indeterminate) ? "#E2E8F0" : "#CBD5E1"
                    }
                }
            }
            
            border.color: "transparent"
            border.width: 0
            anchors.verticalCenter: parent.verticalCenter
            
            // Top sheen for thumb 3D outset look
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 1
                height: 1
                radius: 0.5
                color: "#FFFFFF"
                opacity: 0.5
            }

            // Tiny vertical tactile slot/line in the center for high-end instrument feel
            Rectangle {
                width: 2
                height: parent.height - 8
                radius: 1
                color: {
                    if (control.steamStyle) return "transparent";
                    return control.checked ? Theme.accent : Qt.rgba(0, 0, 0, 0.22)
                }
                anchors.centerIn: parent
                Behavior on color { ColorAnimation { duration: Theme.animFast } }
            }

            // Position animation (middle if indeterminate, right if checked, left if unchecked)
            x: control.indeterminate ? ((track.width - width) / 2) : (control.checked ? (track.width - width - 3) : 3)
            
            Behavior on x {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.OutBack // satisfying spring bounce!
                }
            }
            Behavior on width {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutQuad
                }
            }
            Behavior on height {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutQuad
                }
            }
        }
    }
    
    // Label Text (Word-wrapped and constrained horizontally)
    Text {
        id: labelText
        text: control.text
        color: Theme.textPrimary
        font.family: Theme.fontFamily
        font.pixelSize: 13
        font.bold: false
        
        anchors.left: track.right
        anchors.leftMargin: 10
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        
        wrapMode: Text.WordWrap
        visible: control.text !== ""
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
