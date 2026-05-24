import QtQuick
import MeguPackOptimizer 1.0

Item {
    id: control
    
    property double value: 0.0 // Range: 0.0 to 1.0
    property string statusText: ""
    
    implicitWidth: 300
    implicitHeight: 38
    
    Column {
        anchors.fill: parent
        spacing: 6
        
        // Progress Bar Track
        Rectangle {
            id: track
            width: parent.width
            height: 10
            radius: 5
            color: Theme.buttonBg
            border.color: Theme.border
            border.width: 1
            
            // Progress Fill
            Rectangle {
                id: fill
                height: parent.height - 2
                radius: 4
                color: Theme.accent
                anchors.left: parent.left
                anchors.leftMargin: 1
                anchors.verticalCenter: parent.verticalCenter
                
                // Animate fill width changes
                width: Math.max(0, (track.width - 2) * control.value)
                
                Behavior on width {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutQuad
                    }
                }
                
                // Pulsing light overlay for active animations
                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: "#FFFFFF"
                    opacity: pulseAnimation.running ? 0.15 : 0.0
                    
                    SequentialAnimation on opacity {
                        id: pulseAnimation
                        loops: Animation.Infinite
                        running: control.value > 0.0 && control.value < 1.0
                        
                        NumberAnimation { from: 0.0; to: 0.25; duration: 800; easing.type: Easing.InOutQuad }
                        NumberAnimation { from: 0.25; to: 0.0; duration: 800; easing.type: Easing.InOutQuad }
                    }
                }
            }
        }
        
        // Label Container (Status + Percentage)
        Item {
            width: parent.width
            height: 16
            
            Text {
                text: control.statusText
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.bold: false
                elide: Text.ElideRight
                anchors.left: parent.left
                anchors.right: percentageText.left
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
            }
            
            Text {
                id: percentageText
                text: Math.round(control.value * 100) + "%"
                color: Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
