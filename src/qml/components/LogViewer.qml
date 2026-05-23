import QtQuick
import QtQuick.Controls
import MeguPackOptimizer 1.0

AcrylicPanel {
    id: root
    
    implicitWidth: 500
    implicitHeight: 300
    
    // Auto-scroll property
    property bool autoScroll: true
    
    Column {
        anchors.fill: parent
        spacing: 10
        
        // Terminal Header
        Row {
            width: parent.width
            height: 24
            
            Row {
                spacing: 6
                anchors.verticalCenter: parent.verticalCenter
                
                Image {
                    source: "qrc:/MeguPackOptimizer/src/resources/terminal.svg"
                    width: 14; height: 14
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                Text {
                    text: qsTr("System Terminal Log")
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            
            // Log Operations Bar
            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8
                
                MeguButton {
                    text: qsTr("Clear")
                    iconSource: "qrc:/MeguPackOptimizer/src/resources/close.svg"
                    anchors.verticalCenter: parent.verticalCenter
                    implicitHeight: 22
                    implicitWidth: 60
                    onClicked: {
                        loggerBackend.clearLog();
                        logText.text = "";
                    }
                }
            }
        }
        
        // Log Terminal Output Area
        Rectangle {
            width: parent.width
            height: parent.height - 34
            color: "#0B1019" // Terminal background
            radius: Theme.radiusSmall
            border.color: Theme.border
            border.width: 1
            
            ScrollView {
                id: logScroll
                anchors.fill: parent
                anchors.margins: 8
                clip: true
                
                ScrollBar.vertical: ScrollBar {
                    id: vBar
                    policy: ScrollBar.AsNeeded
                }
                
                TextArea {
                    id: logText
                    readOnly: true
                    selectByMouse: true
                    color: Theme.textSecondary
                    font.family: "Consolas, Courier New, monospace"
                    font.pixelSize: 11
                    background: null
                    wrapMode: TextEdit.Wrap
                    text: ""
                }
            }
        }
    }
    
    // Connect to Logger signals
    Connections {
        target: loggerBackend
        
        function onLogAdded(line) {
            logText.append(line);
            if (root.autoScroll) {
                scrollTimer.restart();
            }
        }
    }
    
    Timer {
        id: scrollTimer
        interval: 30
        repeat: false
        onTriggered: {
            logScroll.ScrollBar.vertical.position = 1.0 - logScroll.ScrollBar.vertical.size;
        }
    }
    
    Component.onCompleted: {
        // Load initial logs
        logText.text = loggerBackend.getFullLog();
        if (root.autoScroll) {
            scrollTimer.restart();
        }
    }
}
