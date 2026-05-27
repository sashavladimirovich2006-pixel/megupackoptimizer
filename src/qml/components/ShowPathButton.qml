import QtQuick
import Qt5Compat.GraphicalEffects
import MeguPackOptimizer 1.0

Item {
    id: control
    
    property string text: qsTr("Show Path")
    property string iconSource: "qrc:/MeguPackOptimizer/src/resources/folder.svg"
    
    signal clicked()
    
    implicitWidth: buttonLayout.implicitWidth + 20
    implicitHeight: 24
    
    opacity: control.enabled ? 1.0 : 0.35
    Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
    
    Rectangle {
        id: bg
        anchors.fill: parent
        radius: 6
        color: mouseArea.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15) : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.05)
        border.color: mouseArea.containsMouse ? Theme.accent : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3)
        border.width: 1
        
        Behavior on color { ColorAnimation { duration: Theme.animFast } }
        Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
        
        Row {
            id: buttonLayout
            anchors.centerIn: parent
            spacing: 5
            
            Item {
                width: 12
                height: 12
                anchors.verticalCenter: parent.verticalCenter
                
                Image {
                    id: btnIcon
                    source: control.iconSource
                    anchors.fill: parent
                    sourceSize.width: 12
                    sourceSize.height: 12
                    visible: false
                }
                
                ColorOverlay {
                    anchors.fill: btnIcon
                    source: btnIcon
                    color: mouseArea.containsMouse ? Theme.accentLight : Theme.accent
                    Behavior on color { ColorAnimation { duration: Theme.animFast } }
                }
            }
            
            Text {
                text: control.text
                color: mouseArea.containsMouse ? Theme.accentLight : Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: 10
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
                Behavior on color { ColorAnimation { duration: Theme.animFast } }
            }
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: control.enabled
        cursorShape: control.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            if (control.enabled) {
                control.clicked();
            }
        }
    }
}
