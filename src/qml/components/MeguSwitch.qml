import QtQuick
import MeguPackOptimizer 1.0

Item {
    id: control
    
    property string text: ""
    property bool checked: false
    property bool indeterminate: false
    property bool steamStyle: false
    
    signal toggled(bool isChecked)
    
    implicitWidth: text !== "" ? 200 : 42
    // Height adapts dynamically to the wrapped text height or defaults to 28px
    implicitHeight: Math.max(28, labelText.visible ? labelText.height + 4 : 24)
    
    opacity: enabled ? 1.0 : 0.4
    Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
    
    // Soft outer neon glow behind the track when checked/active (subtle tech aura)
    Rectangle {
        anchors.centerIn: track
        width: track.width + 6
        height: track.height + 6
        radius: track.radius + 3
        color: Theme.accent
        opacity: (control.checked && !control.steamStyle) ? (mouseArea.containsMouse ? 0.25 : 0.12) : 0.0
        visible: opacity > 0.0
        Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }
    }

    Rectangle {
        id: track
        width: 42
        height: 22
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        radius: 5
        
        color: {
            if (control.steamStyle) {
                return "#10161f";
            }
            if (control.checked) {
                return Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.12);
            }
            return (Theme.currentTheme === "Белоснежная" || Theme.currentTheme === "Розовая") ? Theme.buttonBg : "#080C14";
        }
        border.color: {
            if (control.steamStyle) {
                return control.checked ? Theme.accent : (mouseArea.containsMouse ? Theme.borderHover : "#3c485c");
            }
            return (control.checked || control.indeterminate) ? Theme.accent : (mouseArea.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.4) : Qt.rgba(255, 255, 255, 0.08));
        }
        border.width: 1
        
        Behavior on color { ColorAnimation { duration: 180 } }
        Behavior on border.color { ColorAnimation { duration: 180 } }
        
        // Indeterminate fill
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            opacity: (control.indeterminate && !control.steamStyle) ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }
            color: Theme.accentDim
        }

        // Zero-overhead high-fidelity Drop Shadow under the thumb block
        Rectangle {
            width: thumb.width + 2
            height: thumb.height + 2
            radius: thumb.radius + 1
            color: "#000000"
            opacity: 0.35
            x: thumb.x - 1
            y: thumb.y + 1.2
            
            Behavior on x {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on width {
                NumberAnimation {
                    duration: 120
                    easing.type: Easing.OutQuad
                }
            }
            Behavior on height {
                NumberAnimation {
                    duration: 120
                    easing.type: Easing.OutQuad
                }
            }
        }

        // Custom Segmented LED Slider Thumb
        Rectangle {
            id: thumb
            width: mouseArea.pressed ? 20 : (mouseArea.containsMouse ? 18 : 16)
            height: 16
            radius: 4
            
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: {
                        if (control.steamStyle) return control.checked ? "#FFFFFF" : "#5d6d7e";
                        if (control.checked || control.indeterminate) return Theme.accentLight;
                        return "#64748B";
                    }
                }
                GradientStop {
                    position: 1.0
                    color: {
                        if (control.steamStyle) return control.checked ? "#E2E8F0" : "#4b5a6c";
                        if (control.checked || control.indeterminate) return Theme.accent;
                        return "#475569";
                    }
                }
            }
            
            border.color: "transparent"
            border.width: 0
            anchors.verticalCenter: parent.verticalCenter
            
            // Specular top highlight line for glossy 3D look
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 1
                height: 1
                radius: 0.5
                color: "#FFFFFF"
                opacity: 0.3
            }

            // Tiny LED-like status dot in the center of the block
            Rectangle {
                width: 4
                height: 4
                radius: 2
                color: {
                    if (control.steamStyle) return "transparent";
                    return control.checked ? "#FFFFFF" : Qt.rgba(255, 255, 255, 0.6)
                }
                anchors.centerIn: parent
                Behavior on color { ColorAnimation { duration: Theme.animFast } }
            }

            // Position animation (middle if indeterminate, right if checked, left if unchecked)
            x: control.indeterminate ? ((track.width - width) / 2) : (control.checked ? (track.width - width - 3) : 3)
            
            Behavior on x {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutCubic // Precise quick slide
                }
            }
            Behavior on width {
                NumberAnimation {
                    duration: 120
                    easing.type: Easing.OutQuad
                }
            }
            Behavior on height {
                NumberAnimation {
                    duration: 120
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
