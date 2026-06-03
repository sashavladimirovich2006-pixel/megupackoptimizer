import QtQuick
import MeguPackOptimizer 1.0
import Qt5Compat.GraphicalEffects

AcrylicPanel {
    id: card
    
    property string category: ""
    property string value: ""
    property string subValue: ""
    property string iconSource: ""
    
    // Progress bar and styling customizations
    property bool showProgressBar: false
    property real progressBarValue: 0.0
    property color progressBarColor: Theme.accent
    property color badgeColor: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.05)
    property color iconColor: Theme.textSecondary

    radius: showProgressBar ? height / 2 : 8

    Item {
        anchors.fill: parent
        anchors.leftMargin: card.showProgressBar ? 22 : 12
        anchors.rightMargin: card.showProgressBar ? 22 : 12
        anchors.topMargin: 12
        anchors.bottomMargin: 12
        
        Row {
            id: contentRow
            anchors.fill: parent
            spacing: 12
            
            // Subdued, clean elevation adjustment on hover
            y: card.containsMouse ? -1 : 0
            Behavior on y {
                NumberAnimation {
                    duration: Theme.animNormal
                    easing.type: Easing.OutCubic
                }
            }

            // Icon Container with clean, premium badge background
            Rectangle {
                id: iconBg
                width: 40
                height: 40
                radius: 10
                color: card.containsMouse ? Qt.rgba(progressBarColor.r, progressBarColor.g, progressBarColor.b, 0.2) : badgeColor
                border.color: card.containsMouse ? progressBarColor : Theme.border
                border.width: 1
                anchors.verticalCenter: parent.verticalCenter
                
                Behavior on color { ColorAnimation { duration: Theme.animFast } }
                Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                Item {
                    width: 20
                    height: 20
                    anchors.centerIn: parent

                    Image {
                        id: img
                        source: card.iconSource
                        anchors.fill: parent
                        sourceSize.width: 20
                        sourceSize.height: 20
                        visible: false
                    }
                    
                    ColorOverlay {
                        anchors.fill: img
                        source: img
                        color: card.containsMouse ? progressBarColor : iconColor
                        Behavior on color { ColorAnimation { duration: Theme.animNormal } }
                    }
                }
            }

            // Info Text Column
            Column {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - iconBg.width - parent.spacing - 10
                spacing: 1

                Text {
                    text: card.category
                    color: card.containsMouse ? progressBarColor : Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
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

                Text {
                    text: card.subValue
                    color: Theme.textMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    elide: Text.ElideRight
                    width: parent.width
                    visible: text !== ""
                }

                // Mini-bar loading indicator
                Rectangle {
                    width: parent.width - 10
                    height: 4
                    radius: 2
                    color: Qt.rgba(progressBarColor.r, progressBarColor.g, progressBarColor.b, 0.1)
                    visible: card.showProgressBar
                    
                    Rectangle {
                        width: parent.width * card.progressBarValue
                        height: parent.height
                        radius: 2
                        color: card.progressBarColor

                        Behavior on width {
                            NumberAnimation { duration: 300; easing.type: Easing.OutQuad }
                        }
                    }
                }
            }
        }
    }
}
