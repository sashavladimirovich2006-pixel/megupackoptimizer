import QtQuick
import MeguPackOptimizer 1.0

Item {
    id: control
    
    property string text: ""
    property string iconSource: ""
    property bool accented: false
    
    signal clicked()
    
    implicitWidth: Math.max(90, buttonLayout.implicitWidth + 32)
    implicitHeight: 38
    
    opacity: enabled ? 1.0 : 0.4
    Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
    
    // 1. High-End Ambient Backlight Glow (Expands and shines on hover!)
    Rectangle {
        id: glowEffect
        anchors.fill: parent
        radius: 10
        color: control.accented ? Theme.accent : "transparent"
        opacity: (control.accented && mouseArea.containsMouse && control.enabled) ? 0.35 : 0.0
        scale: mouseArea.containsMouse ? 1.08 : 1.0
        
        Behavior on opacity { NumberAnimation { duration: 150 } }
        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
    }
    
    // 2. Main Button Body
    Rectangle {
        id: bg
        anchors.fill: parent
        radius: 10
        
        // Premium slate-metallic background for normal buttons, gorgeous gradient for accented
        color: {
            if (!control.enabled) {
                return control.accented ? Theme.accentDark : "transparent";
            }
            if (control.accented) {
                return "transparent"; // Managed by gradient
            } else {
                return mouseArea.pressed ? Theme.buttonBgPressed : (mouseArea.containsMouse ? Theme.buttonBgHover : Theme.buttonBg);
            }
        }
               
        border.color: {
            if (control.accented) return "transparent";
            return mouseArea.containsMouse ? Theme.accent : Theme.border;
        }
        border.width: 1
        
        // Elite neon gradient for active buttons
        gradient: (control.accented && control.enabled) ? accentGradient : null
        
        Gradient {
            id: accentGradient
            GradientStop { position: 0.0; color: Theme.accentLight }
            GradientStop { position: 1.0; color: Theme.accent }
        }
        
        Behavior on color { ColorAnimation { duration: 120 } }
        Behavior on border.color { ColorAnimation { duration: 120 } }
        
        // 3. Inner Gloss Highlight (Fluent 3D Light Effect!)
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            border.color: "#1FFFFFFF" // subtle top-white light glow
            border.width: 1
            anchors.margins: 1
            opacity: control.accented ? 0.4 : 0.15
        }
    }
    
    // 4. Content Layout (Icon & Label)
    Row {
        id: buttonLayout
        anchors.centerIn: parent
        spacing: 8
        
        Image {
            id: btnIcon
            source: control.iconSource
            width: 16
            height: 16
            visible: control.iconSource !== ""
            anchors.verticalCenter: parent.verticalCenter
            sourceSize.width: 16
            sourceSize.height: 16
            opacity: control.accented ? 1.0 : 0.8
        }
        
        Text {
            text: control.text
            color: control.accented ? Theme.textInverse : Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
            font.letterSpacing: 0.5
        }
    }
    
    // 5. Snappy Physics Scale Feedback (feels "alive" and expensive!)
    scale: mouseArea.pressed && control.enabled ? 0.94 : (mouseArea.containsMouse && control.enabled ? 1.03 : 1.0)
    Behavior on scale {
        NumberAnimation {
            duration: 100
            easing.type: Easing.OutBack // springy modern click bounce!
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
    }
}
