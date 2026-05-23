import QtQuick
import MeguPackOptimizer 1.0
import Qt5Compat.GraphicalEffects

AcrylicPanel {
    id: card
    
    property string title: ""
    property string value: ""
    property string iconSource: ""

    // Hover effect for the card
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.ArrowCursor
    }

    border.color: mouseArea.containsMouse ? Theme.borderHover : Theme.border
    
    Row {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 14

        // Icon Container with colored background glow
        Rectangle {
            id: iconBg
            width: 42
            height: 42
            radius: Theme.radiusSmall
            color: mouseArea.containsMouse ? Theme.accentDim : "transparent"
            border.color: mouseArea.containsMouse ? Theme.accent : Theme.border
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
                    color: Theme.yellowAccent
                    Behavior on color { ColorAnimation { duration: Theme.animNormal } }
                }
            }
        }

        // Info Text Column
        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - iconBg.width - parent.spacing - 28
            spacing: 4

            Text {
                text: card.title
                color: Theme.yellowAccent
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.bold: true
                font.letterSpacing: 0.5
                elide: Text.ElideRight
                width: parent.width
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
