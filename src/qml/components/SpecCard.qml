import QtQuick
import MeguPackOptimizer 1.0
import Qt5Compat.GraphicalEffects

AcrylicPanel {
    id: card
    
    property string title: ""
    property string value: ""
    property string iconSource: ""

    Item {
        anchors.fill: parent
        anchors.margins: 14
        
        Row {
            id: contentRow
            anchors.fill: parent
            spacing: 14
            
            // Subdued, clean elevation adjustment on hover
            y: card.containsMouse ? -1 : 0
            Behavior on y {
                NumberAnimation {
                    duration: Theme.animNormal
                    easing.type: Easing.OutCubic
                }
            }

            // Icon Container with clean, non-glowing background
            Rectangle {
                id: iconBg
                width: 42
                height: 42
                radius: Theme.radiusSmall
                color: card.containsMouse ? Theme.buttonBgHover : "transparent"
                border.color: card.containsMouse ? Theme.borderHover : Theme.border
                border.width: 1
                anchors.verticalCenter: parent.verticalCenter
                
                Behavior on color { ColorAnimation { duration: Theme.animFast } }
                Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                Item {
                    width: 22
                    height: 22
                    anchors.centerIn: parent

                    Image {
                        id: img
                        source: card.iconSource
                        anchors.fill: parent
                        sourceSize.width: 22
                        sourceSize.height: 22
                        visible: false
                    }
                    
                    ColorOverlay {
                        anchors.fill: img
                        source: img
                        color: card.containsMouse ? Theme.accent : Theme.textSecondary
                        Behavior on color { ColorAnimation { duration: Theme.animNormal } }
                    }
                }
            }

            // Info Text Column
            Column {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - iconBg.width - parent.spacing - 10
                spacing: 4

                Text {
                    text: card.title
                    color: card.containsMouse ? Theme.accent : Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    font.bold: true
                    font.letterSpacing: 0.5
                    elide: Text.ElideRight
                    width: parent.width
                    
                    Behavior on color { ColorAnimation { duration: Theme.animFast } }
                }

                Text {
                    text: card.value ? card.value : qsTr("Detecting...")
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                    font.bold: true
                    elide: Text.ElideRight
                    width: parent.width
                }
            }
        }
    }
}
