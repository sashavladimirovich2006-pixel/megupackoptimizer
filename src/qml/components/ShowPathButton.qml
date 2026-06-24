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
    
    implicitWidth: isIconOnly ? 20 : buttonLayout.implicitWidth + 20
    implicitHeight: isIconOnly ? 20 : 24
    
    opacity: control.enabled ? 1.0 : 0.35
    scale: control.enabled ? (mouseArea.pressed ? 0.95 : (mouseArea.containsMouse ? 1.08 : 1.0)) : 1.0
    
    Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
    Behavior on scale { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }

    DropShadow {
        anchors.fill: bg
        horizontalOffset: 0
        verticalOffset: 0
        radius: mouseArea.containsMouse ? 8 : 0
        color: Theme.accent
        source: bg
        visible: mouseArea.containsMouse && control.enabled
        Behavior on radius { NumberAnimation { duration: Theme.animFast } }
        Behavior on color { ColorAnimation { duration: Theme.animFast } }
    }
    
    Rectangle {
        id: bg
        anchors.fill: parent
        radius: isIconOnly ? 10 : 6 // Fully circular if icon-only
        
        color: mouseArea.containsMouse 
            ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
            : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.05)
            
        border.color: mouseArea.containsMouse
            ? Theme.accent
            : (isIconOnly ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.2) : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3))
            
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
            rotation: -45 // Point up-right! This rotates both the image and the color overlay together!
            
            Image {
                id: arrowIcon
                source: control.iconSource
                anchors.fill: parent
                anchors.margins: 3 // Balanced padding inside 20x20 circle
                sourceSize.width: 14
                sourceSize.height: 14
                visible: false
            }
            
            ColorOverlay {
                anchors.fill: arrowIcon
                source: arrowIcon
                color: mouseArea.containsMouse ? Theme.accent : Theme.textSecondary // Highly visible colors!
                Behavior on color { ColorAnimation { duration: Theme.animFast } }
            }
        }
    }
    
    Timer {
        id: hoverTimer
        interval: 1000 // 1.0 second delay for a true "long hover"
        repeat: false
        onTriggered: {
            if (mouseArea.containsMouse && control.isIconOnly) {
                customTooltip.visible = true;
            }
        }
    }
    
    ToolTip {
        id: customTooltip
        text: control.text
        background: Rectangle {
            color: Theme.cardBg
            border.color: Theme.cardStroke
            border.width: 1
            radius: 4
        }
        contentItem: Text {
            text: customTooltip.text
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
        onEntered: {
            if (control.isIconOnly) {
                hoverTimer.start();
            }
        }
        onExited: {
            hoverTimer.stop();
            customTooltip.visible = false;
        }
        onClicked: {
            hoverTimer.stop();
            customTooltip.visible = false;
            if (control.enabled) {
                control.clicked();
            }
        }
    }
}
