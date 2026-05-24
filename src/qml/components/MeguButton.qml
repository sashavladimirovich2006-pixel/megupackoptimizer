import QtQuick
import MeguPackOptimizer 1.0

Item {
    id: control
    
    property string text: ""
    property string iconSource: ""
    property bool accented: false
    property bool flat: false
    
    signal clicked()
    
    implicitWidth: Math.max(95, buttonLayout.implicitWidth + 34)
    implicitHeight: 38
    
    opacity: enabled ? 1.0 : 0.35
    Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
    
    // 1. High-Tech Holographic Ambient Glow Backing
    Rectangle {
        id: glowEffect
        anchors.fill: parent
        radius: 8
        color: control.accented ? Theme.accent : (control.flat ? "transparent" : Theme.accentDim)
        opacity: (control.enabled && mouseArea.containsMouse) ? (control.accented ? 0.45 : 0.25) : 0.0
        scale: mouseArea.containsMouse ? 1.08 : 1.0
        
        Behavior on opacity { NumberAnimation { duration: 150 } }
        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
    }
    
    // 2. Main High-Tech Button Plate
    Rectangle {
        id: bg
        anchors.fill: parent
        radius: 8
        
        // Translucent backing adapted to the theme
        color: {
            if (!control.enabled) {
                return control.accented ? Theme.accentDark : "transparent";
            }
            if (control.accented) {
                return "transparent"; // managed by gradient
            } else if (control.flat) {
                if (mouseArea.pressed) return Theme.buttonBgPressed;
                if (mouseArea.containsMouse) return Theme.buttonBgHover;
                return "transparent";
            } else {
                return mouseArea.pressed ? Theme.buttonBgPressed : (mouseArea.containsMouse ? Theme.buttonBgHover : Theme.buttonBg);
            }
        }
               
        border.color: {
            if (control.accented) return "transparent";
            if (control.flat) {
                return (mouseArea.containsMouse && control.enabled) ? Theme.accent : "transparent";
            }
            return mouseArea.containsMouse ? Theme.accentLight : Theme.border;
        }
        border.width: 1
        
        // Premium vertical gradient for accented state
        gradient: (control.accented && control.enabled) ? accentGradient : null
        
        Gradient {
            id: accentGradient
            GradientStop { position: 0.0; color: Theme.accentLight }
            GradientStop { position: 1.0; color: Theme.accent }
        }
        
        Behavior on color { ColorAnimation { duration: 120 } }
        Behavior on border.color { ColorAnimation { duration: 120 } }
        
        // 3. Diagonal spec-sheen sweeping across the button (Блик)
        Rectangle {
            id: buttonSheen
            width: 30
            height: parent.height * 2
            rotation: 20
            anchors.verticalCenter: parent.verticalCenter
            z: 1
            
            gradient: Gradient {
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.5; color: (control.accented) ? "#55FFFFFF" : "#22FFFFFF" }
                GradientStop { position: 1.0; color: "transparent" }
            }
            
            x: -buttonSheen.width - 20
            
            NumberAnimation on x {
                id: sheenAnim
                from: -buttonSheen.width - 20
                to: bg.width + buttonSheen.width + 20
                duration: 800
                easing.type: Easing.OutQuad
                running: false
            }
        }

        // 4. Subtle cybernetic corner ticks inside button
        Item {
            anchors.fill: parent
            visible: !control.flat
            opacity: mouseArea.containsMouse ? 1.0 : 0.35
            Behavior on opacity { NumberAnimation { duration: Theme.animNormal } }

            // Top-Left corner tick
            Rectangle { x: 2; y: 2; width: 4; height: 1; color: control.accented ? Theme.textInverse : Theme.accent }
            Rectangle { x: 2; y: 2; width: 1; height: 4; color: control.accented ? Theme.textInverse : Theme.accent }

            // Top-Right corner tick
            Rectangle { x: parent.width - 6; y: 2; width: 4; height: 1; color: control.accented ? Theme.textInverse : Theme.accent }
            Rectangle { x: parent.width - 3; y: 2; width: 1; height: 4; color: control.accented ? Theme.textInverse : Theme.accent }

            // Bottom-Left corner tick
            Rectangle { x: 2; y: parent.height - 3; width: 4; height: 1; color: control.accented ? Theme.textInverse : Theme.accent }
            Rectangle { x: 2; y: parent.height - 6; width: 1; height: 4; color: control.accented ? Theme.textInverse : Theme.accent }

            // Bottom-Right corner tick
            Rectangle { x: parent.width - 6; y: parent.height - 3; width: 4; height: 1; color: control.accented ? Theme.textInverse : Theme.accent }
            Rectangle { x: parent.width - 3; y: parent.height - 6; width: 1; height: 4; color: control.accented ? Theme.textInverse : Theme.accent }
        }
    }
    
    // 5. Button Content
    Row {
        id: buttonLayout
        anchors.centerIn: parent
        spacing: 8
        z: 2
        
        Image {
            id: btnIcon
            source: control.iconSource
            width: 16
            height: 16
            visible: control.iconSource !== ""
            anchors.verticalCenter: parent.verticalCenter
            sourceSize.width: 16
            sourceSize.height: 16
            
            // Icon glows and pulses slightly on hover
            scale: mouseArea.containsMouse ? 1.08 : 1.0
            opacity: {
                if (control.accented) return 1.0;
                if (control.flat) {
                    return mouseArea.containsMouse ? 0.95 : 0.65;
                }
                return 0.85;
            }
            
            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
            Behavior on opacity { NumberAnimation { duration: 120 } }
        }
        
        Text {
            text: control.text
            color: {
                if (control.accented) return Theme.textInverse;
                if (control.flat) {
                    return mouseArea.containsMouse ? Theme.textPrimary : Theme.textSecondary;
                }
                return Theme.textPrimary;
            }
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
            font.letterSpacing: 0.6
            
            Behavior on color { ColorAnimation { duration: 120 } }
        }
    }
    
    // 6. Snappy Micro-Spring Bounce scale effect
    scale: mouseArea.pressed && control.enabled ? 0.94 : (mouseArea.containsMouse && control.enabled ? 1.04 : 1.0)
    
    Behavior on scale {
        NumberAnimation {
            duration: 100
            easing.type: Easing.OutBack
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: control.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        
        onClicked: {
            if (control.enabled) {
                control.clicked();
            }
        }
        
        onContainsMouseChanged: {
            if (containsMouse && control.enabled && !sheenAnim.running) {
                sheenAnim.from = -buttonSheen.width - 20;
                sheenAnim.to = bg.width + buttonSheen.width + 20;
                sheenAnim.start();
            }
        }
    }
}
