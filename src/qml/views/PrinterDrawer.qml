import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeguPackOptimizer 1.0
import Qt5Compat.GraphicalEffects
import "../components"

Column {
    id: printerColumn
    width: parent.width
    spacing: 20
    

    Text {
        text: qsTr("Detected print queues in Device Manager:")
        color: Theme.textSecondary
        font.family: Theme.fontFamily
        font.pixelSize: 11
        font.bold: true
    }

    // Display the list of detected printers
    Column {
        width: parent.width
        spacing: 10

        Repeater {
            model: optimizerBackend.detectedPrinters
            delegate: AcrylicPanel {
                width: parent.width
                height: 50

                Row {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 12
                    spacing: 12

                    Item {
                        width: 20
                        height: 20
                        anchors.verticalCenter: parent.verticalCenter
                        Image {
                            id: printerQueueIcon
                            source: "qrc:/MeguPackOptimizer/src/resources/settings.svg"
                            anchors.fill: parent
                            sourceSize.width: 20
                            sourceSize.height: 20
                            visible: false
                        }
                        ColorOverlay {
                            anchors.fill: printerQueueIcon
                            source: printerQueueIcon
                            color: Theme.accent
                        }
                    }

                    Text {
                        text: modelData
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
        
        // Fallback if no printers detected
        Text {
            text: qsTr("No print queues detected.")
            color: Theme.textMuted
            font.family: Theme.fontFamily
            font.pixelSize: 11
            visible: optimizerBackend.detectedPrinters.length === 0
        }
    }
}
