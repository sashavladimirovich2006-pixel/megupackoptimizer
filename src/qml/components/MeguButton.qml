import QtQuick
import MeguPackOptimizer 1.0
import Qt5Compat.GraphicalEffects

Item {
    id: control
    
    property string text: ""
    property string iconSource: ""
    property bool accented: false
    property bool flat: false
    
    signal clicked()
    
    implicitWidth: Math.max(90, buttonLayout.implicitWidth + 28)
    implicitHeight: 34 // Compact and extremely clean height matching modern UI standards
    
    opacity: enabled ? 1.0 : 0.35
    Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
    
    // Main Button Plate
    Rectangle {
        id: bg
        anchors.fill: parent
        radius: 6 // Clean minimal rounded corners
        
        color: {
            if (!control.enabled) {
                return control.accented ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.05) : "transparent";
            }
            if (control.accented) {
                return mouseArea.pressed ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.30) : 
                       (mouseArea.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.20) : 
                        Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.12));
            } else if (control.flat) {
                if (mouseArea.pressed) return Theme.buttonBgPressed;
                if (mouseArea.containsMouse) return Theme.buttonBgHover;
                return "transparent";
            } else {
                return mouseArea.pressed ? Theme.buttonBgPressed : (mouseArea.containsMouse ? Theme.buttonBgHover : Theme.buttonBg);
            }
        }
               
        border.color: {
            if (control.accented) {
                if (!control.enabled) return Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.10);
                return mouseArea.pressed ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.50) : 
                       (mouseArea.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.40) : 
                        Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25));
            }
            if (control.flat) {
                return (mouseArea.containsMouse && control.enabled) ? Theme.borderHover : "transparent";
            }
            return mouseArea.containsMouse ? Theme.borderHover : Theme.border;
        }
        border.width: 1
        
        Behavior on color { ColorAnimation { duration: 100 } }
        Behavior on border.color { ColorAnimation { duration: 100 } }
    }
    
    // Button Content (Icon & Label)
    Row {
        id: buttonLayout
        anchors.centerIn: parent
        spacing: 6
        
        // Color-Overlaid Icon Container
        Item {
            id: iconContainer
            width: 14
            height: 14
            visible: control.iconSource !== ""
            anchors.verticalCenter: parent.verticalCenter
            
            Image {
                id: btnIcon
                source: control.iconSource
                anchors.fill: parent
                sourceSize.width: 14
                sourceSize.height: 14
                visible: false // Hidden so ColorOverlay handles drawing
            }
            
            ColorOverlay {
                anchors.fill: btnIcon
                source: btnIcon
                color: {
                    if (control.accented) return Theme.accent;
                    if (control.flat) {
                        return mouseArea.containsMouse ? Theme.textPrimary : Theme.textSecondary;
                    }
                    return Theme.textPrimary;
                }
                
                opacity: {
                    if (control.accented) return 1.0;
                    if (control.flat) {
                        return mouseArea.containsMouse ? 0.95 : 0.65;
                    }
                    return 0.85;
                }
                
                Behavior on color { ColorAnimation { duration: 100 } }
                Behavior on opacity { NumberAnimation { duration: 100 } }
            }
        }
        
        Text {
            text: control.text
            color: {
                if (control.accented) return Theme.textPrimary;
                if (control.flat) {
                    return mouseArea.containsMouse ? Theme.textPrimary : Theme.textSecondary;
                }
                return Theme.textPrimary;
            }
            font.family: Theme.fontFamily
            font.pixelSize: 11 // Modern small typography
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
            font.letterSpacing: 0.2
            
            Behavior on color { ColorAnimation { duration: 100 } }
        }
    }
    
    // Subdued, premium physical press response
    scale: mouseArea.pressed && control.enabled ? 0.97 : 1.0
    Behavior on scale {
        NumberAnimation {
            duration: 80
            easing.type: Easing.OutQuad
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
