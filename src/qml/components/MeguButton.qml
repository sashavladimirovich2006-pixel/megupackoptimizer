import QtQuick
import MeguPackOptimizer 1.0

Item {
    id: control
    
    property string text: ""
    property string iconSource: ""
    property bool accented: false
    
    signal clicked()
    
    implicitWidth: Math.max(80, buttonLayout.implicitWidth + 28)
    implicitHeight: 36
    
    opacity: enabled ? 1.0 : 0.4
    Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
    
    // Background Fill
    Rectangle {
        id: bg
        anchors.fill: parent
        radius: Theme.radiusSmall
        
        color: {
            if (!control.enabled) {
                return control.accented ? Theme.accentDark : "transparent";
            }
            if (control.accented) {
                return "transparent"; // Managed by gradient
            } else {
                return mouseArea.pressed ? "#2A3958" : (mouseArea.containsMouse ? "#1E2A3E" : "#0EFFFFFF");
            }
        }
               
        border.color: {
            if (control.accented) return "transparent";
            return mouseArea.containsMouse ? Theme.accent : Theme.border;
        }
        border.width: 1
        
        gradient: (control.accented && control.enabled) ? accentGradient : null
        
        Gradient {
            id: accentGradient
            GradientStop { position: 0.0; color: Theme.accentLight }
            GradientStop { position: 1.0; color: Theme.accent }
        }
        
        Behavior on color { ColorAnimation { duration: Theme.animFast } }
        Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
        
        // Soft amber outer glow for accented buttons
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            border.color: Theme.accent
            border.width: 1.5
            opacity: (control.accented && mouseArea.containsMouse && control.enabled) ? 0.6 : 0.0
            Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
        }
    }
    
    // Row holding Icon and Text
    Row {
        id: buttonLayout
        anchors.centerIn: parent
        spacing: 6
        
        Image {
            id: btnIcon
            source: control.iconSource
            width: 14
            height: 14
            visible: control.iconSource !== ""
            anchors.verticalCenter: parent.verticalCenter
            sourceSize.width: 14
            sourceSize.height: 14
            opacity: control.accented ? 0.95 : 0.8
        }
        
        Text {
            text: control.text
            color: control.accented ? Theme.textInverse : Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
        }
    }
    
    // Micro-animation scale effect on press / hover
    scale: mouseArea.pressed && control.enabled ? 0.96 : (mouseArea.containsMouse && control.enabled ? 1.02 : 1.0)
    Behavior on scale {
        NumberAnimation {
            duration: 80
            easing.type: Easing.OutCubic
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
