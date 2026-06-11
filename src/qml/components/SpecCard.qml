import QtQuick
import MeguPackOptimizer 1.0
import Qt5Compat.GraphicalEffects
import QtQuick.Shapes

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

    Item {
        anchors.fill: parent
        anchors.margins: 16
        
        Row {
            id: contentRow
            anchors.fill: parent
            spacing: 16
            
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
                width: 56
                height: 56
                radius: 28 // circular
                color: card.containsMouse ? Qt.rgba(progressBarColor.r, progressBarColor.g, progressBarColor.b, 0.15) : badgeColor
                border.color: card.showProgressBar ? "transparent" : (card.containsMouse ? progressBarColor : Theme.border)
                border.width: card.showProgressBar ? 0 : 1
                anchors.verticalCenter: parent.verticalCenter
                
                Behavior on color { ColorAnimation { duration: Theme.animFast } }
                Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                // Speedometer Progress Ring (Circular progress)
                Shape {
                    id: progressShape
                    anchors.fill: parent
                    visible: card.showProgressBar
                    antialiasing: true

                    // Background track ring
                    ShapePath {
                        strokeColor: Qt.rgba(progressBarColor.r, progressBarColor.g, progressBarColor.b, 0.1)
                        strokeWidth: 3.5
                        fillColor: "transparent"
                        capStyle: ShapePath.RoundCap
                        
                        PathAngleArc {
                            centerX: 28
                            centerY: 28
                            radiusX: 24
                            radiusY: 24
                            startAngle: -90
                            sweepAngle: 360
                        }
                    }
                    
                    // Active progress arc
                    ShapePath {
                        strokeColor: card.progressBarColor
                        strokeWidth: 3.5
                        fillColor: "transparent"
                        capStyle: ShapePath.RoundCap
                        
                        PathAngleArc {
                            centerX: 28
                            centerY: 28
                            radiusX: 24
                            radiusY: 24
                            startAngle: -90
                            sweepAngle: 360 * card.progressBarValue
                            
                            Behavior on sweepAngle {
                                NumberAnimation {
                                    duration: 300
                                    easing.type: Easing.OutQuad
                                }
                            }
                        }
                    }
                }

                Item {
                    width: 28
                    height: 28
                    anchors.centerIn: parent

                    Image {
                        id: img
                        source: card.iconSource
                        anchors.fill: parent
                        sourceSize.width: 28
                        sourceSize.height: 28
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
                spacing: 3

                Text {
                    text: card.showProgressBar ? card.category + " (" + Math.round(card.progressBarValue * 100) + "%)" : card.category
                    color: card.containsMouse ? progressBarColor : Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
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
                    font.pixelSize: 16
                    font.bold: true
                    elide: Text.ElideRight
                    width: parent.width
                }

                Text {
                    text: card.subValue
                    color: Theme.textMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    elide: Text.ElideRight
                    width: parent.width
                    visible: text !== ""
                }
            }
        }
    }
}
