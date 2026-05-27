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
}
