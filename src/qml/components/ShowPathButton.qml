import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import MeguPackOptimizer 1.0

Item {
    id: control
    
    property string text: qsTr("Show Path")
    property string iconSource: text === qsTr("Show Path") ? "qrc:/MeguPackOptimizer/src/resources/arrow.svg" : "qrc:/MeguPackOptimizer/src/resources/folder.svg"
    
    property bool isIconOnly: text === qsTr("Show Path")
    
    signal clicked()
    
    implicitWidth: isIconOnly ? 18 : buttonLayout.implicitWidth + 20
    implicitHeight: isIconOnly ? 18 : 24
    
    opacity: control.enabled ? 1.0 : 0.35
    scale: mouseArea.containsMouse ? 1.08 : 1.0
    
    Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
    Behavior on scale { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }
    
    Rectangle {
        id: bg
        anchors.fill: parent
        radius: isIconOnly ? 9 : 6 // Fully circular if icon-only
        
        color: isIconOnly 
            ? (mouseArea.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15) : "transparent")
            : (mouseArea.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15) : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.05))
            
        border.color: isIconOnly
            ? (mouseArea.containsMouse ? Theme.accent : "transparent")
            : (mouseArea.containsMouse ? Theme.accent : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3))
            
        border.width: 1
        
        Behavior on color { ColorAnimation { duration: Theme.animFast } }
        Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
        
        Row {
            id: buttonLayout
            anchors.centerIn: parent
            spacing: 5
            visible: !control.isIconOnly
            
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
        
        // Icon-only mode container for diagonal arrow (↗)
        Item {
            anchors.fill: parent
            visible: control.isIconOnly
            
            Image {
                id: arrowIcon
                source: control.iconSource
                anchors.fill: parent
                anchors.margins: 4
                sourceSize.width: 10
                sourceSize.height: 10
                rotation: -45 // Point up-right
                visible: false
            }
            
            ColorOverlay {
                anchors.fill: arrowIcon
                source: arrowIcon
                color: mouseArea.containsMouse ? Theme.accentLight : Theme.textMuted
                Behavior on color { ColorAnimation { duration: Theme.animFast } }
            }
        }
    }
    
    ToolTip {
        visible: control.isIconOnly && mouseArea.containsMouse
        delay: 500
        text: control.text
        background: Rectangle {
            color: Theme.panelBg
            border.color: Theme.border
            border.width: 1
            radius: 4
        }
        contentItem: Text {
            text: parent.text
            color: Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: 10
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
