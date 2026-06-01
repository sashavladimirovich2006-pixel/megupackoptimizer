import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeguPackOptimizer 1.0
import Qt5Compat.GraphicalEffects
import "../components"

Column {
    id: indexingColumn
    width: parent.width
    spacing: 20
    

    // Search service
    Row {
        width: parent.width
        spacing: 12
        MeguSwitch {
            text: qsTr("Windows Search service")
            checked: optimizerBackend.winSearchActive
            onToggled: (isChecked) => { optimizerBackend.winSearchActive = isChecked; }
            anchors.verticalCenter: parent.verticalCenter
        }
        ShowPathButton {
            anchors.verticalCenter: parent.verticalCenter
            onClicked: { optimizerBackend.showPath("Windows Search service"); }
        }
    }

    // Drive C
    Row {
        width: parent.width
        spacing: 12
        MeguSwitch {
            text: qsTr("Drive C: indexing")
            checked: !!optimizerBackend.driveStates["C:"]
            onToggled: (isChecked) => {
                var states = optimizerBackend.driveStates;
                states["C:"] = isChecked;
                optimizerBackend.driveStates = states;
            }
            anchors.verticalCenter: parent.verticalCenter
        }
        ShowPathButton {
            anchors.verticalCenter: parent.verticalCenter
            onClicked: { optimizerBackend.showPath("C:"); }
        }
    }

    // Fixed drives repeater
    Repeater {
        model: optimizerBackend.fixedDrives
        delegate: Row {
            width: parent.width
            spacing: 12
            MeguSwitch {
                text: qsTr("Drive %1 indexing").arg(modelData)
                checked: !!optimizerBackend.driveStates[modelData]
                onToggled: (isChecked) => {
                    var states = optimizerBackend.driveStates;
                    states[modelData] = isChecked;
                    optimizerBackend.driveStates = states;
                }
                anchors.verticalCenter: parent.verticalCenter
            }
            ShowPathButton {
                anchors.verticalCenter: parent.verticalCenter
                onClicked: { optimizerBackend.showPath(modelData); }
            }
        }
    }

    // Thin separator line
    Rectangle {
        width: parent.width
        height: 1
        color: Theme.border
    }

    // Expandable Deep Indexing Section
    Column {
        width: parent.width
        spacing: 12
        
        property bool expanded: false
        
        // Collapsible Header Row
        Item {
            width: parent.width
            height: 24
            
            MouseArea {
                id: headerMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: { parent.parent.expanded = !parent.parent.expanded; }
            }
            
            Row {
                spacing: 8
                anchors.verticalCenter: parent.verticalCenter
                
                // Down arrow (rotating to point downwards or rightward)
                Item {
                    width: 12
                    height: 12
                    anchors.verticalCenter: parent.verticalCenter
                    rotation: parent.parent.parent.expanded ? 90 : 0
                    Behavior on rotation { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutQuad } }
                    
                    Image {
                        id: headerArrowImg
                        source: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"
                        anchors.fill: parent
                        sourceSize.width: 12
                        sourceSize.height: 12
                        visible: false
                    }
                    ColorOverlay {
                        anchors.fill: headerArrowImg
                        source: headerArrowImg
                        color: headerMouseArea.containsMouse ? Theme.accent : Theme.textSecondary
                        Behavior on color { ColorAnimation { duration: Theme.animFast } }
                    }
                }
                
                Text {
                    text: qsTr("Deep Indexing Options")
                    color: headerMouseArea.containsMouse ? Theme.accent : Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on color { ColorAnimation { duration: Theme.animFast } }
                }
            }
        }
        
        // Collapsible Content
        Column {
            width: parent.width
            spacing: 12
            visible: parent.expanded
            
            Text {
                text: qsTr("Recursively disables content indexing for all files and folders across all active drives. This process runs in the background (takes 10-15 minutes) and completely frees up drive I/O overhead.")
                color: Theme.textMuted
                font.family: Theme.fontFamily
                font.pixelSize: 10
                wrapMode: Text.Wrap
                width: parent.width
            }
            
            MeguButton {
                text: qsTr("Disable indexing on all files/folders (10-15 mins)")
                width: parent.width
                height: 38
                accented: true
                enabled: !optimizerBackend.isOptimizingSystem
                onClicked: {
                    // 1. Turn off all drive toggles in the UI immediately
                    var states = optimizerBackend.driveStates;
                    states["C:"] = false;
                    for (var i = 0; i < optimizerBackend.fixedDrives.length; i++) {
                        states[optimizerBackend.fixedDrives[i]] = false;
                    }
                    optimizerBackend.driveStates = states;
                    
                    // 2. Call the C++ backend to run the background deep index removal
                    optimizerBackend.runDeepIndexingRemoval();
                }
            }
        }
    }
}
