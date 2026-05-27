import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeguPackOptimizer 1.0
import Qt5Compat.GraphicalEffects
import "../components"

Column {
    id: defenderColumn
    width: parent.width
    spacing: 20
    

    Text {
        text: qsTr("Configure custom Windows Defender protection settings and services.")
        color: Theme.textSecondary
        font.family: Theme.fontFamily
        font.pixelSize: 11
        font.bold: true
    }

    // Informational warning box
    AcrylicPanel {
        width: parent.width
        height: 60
        border.color: Theme.warning
        color: Theme.accentDim

        Row {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            Item {
                width: 18
                height: 18
                anchors.verticalCenter: parent.verticalCenter
                Image {
                    id: drawerWarningIcon
                    source: "qrc:/MeguPackOptimizer/src/resources/warning.svg"
                    anchors.fill: parent
                    sourceSize.width: 18
                    sourceSize.height: 18
                    visible: false
                }
                ColorOverlay {
                    anchors.fill: drawerWarningIcon
                    source: drawerWarningIcon
                    color: Theme.warning
                }
            }

            Text {
                text: qsTr("Disable the startup of WinDefend, Sense, WdFilter, and WdBoot services. Note: Requires disabling Tamper Protection.")
                color: Theme.warning
                font.family: Theme.fontFamily
                font.pixelSize: 9
                font.bold: true
                wrapMode: Text.Wrap
                width: parent.width - 38
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    Column {
        width: parent.width
        spacing: 12

        MeguSwitch {
            text: qsTr("Registry Disablement Policies")
            checked: optimizerBackend.defenderRegistryActive
            onToggled: (isChecked) => { optimizerBackend.defenderRegistryActive = isChecked; }
        }

        MeguSwitch {
            text: qsTr("PowerShell Preference Adjustments")
            checked: optimizerBackend.defenderCmdActive
            onToggled: (isChecked) => { optimizerBackend.defenderCmdActive = isChecked; }
        }

        MeguSwitch {
            text: qsTr("Antivirus Services & Drivers")
            checked: optimizerBackend.defenderServiceActive
            onToggled: (isChecked) => { optimizerBackend.defenderServiceActive = isChecked; }
        }
    }

    Rectangle {
        width: parent.width
        height: 1
        color: Theme.border
    }

    Column {
        width: parent.width
        spacing: 8

        Text {
            text: qsTr("Complete Defender Deletion:")
            color: Theme.textSecondary
            font.family: Theme.fontFamily
            font.pixelSize: 11
            font.bold: true
        }

        Text {
            text: qsTr("Removes, unregisters, and disables all Defender services, drivers, components, and scheduled tasks just like BoosterX.")
            color: Theme.textMuted
            font.family: Theme.fontFamily
            font.pixelSize: 9
            wrapMode: Text.Wrap
            width: parent.width
        }
    }

    MeguButton {
        text: {
            if (optimizerBackend.deleteDefenderStaged) {
                return qsTr("Cancel Deletion");
            }
            return qsTr("Completely Delete Windows Defender");
        }
        iconSource: "qrc:/MeguPackOptimizer/src/resources/warning.svg"
        accented: !optimizerBackend.deleteDefenderStaged
        enabled: !optimizerBackend.isOptimizingSystem
        width: parent.width
        height: 38
        onClicked: {
            optimizerBackend.deleteDefenderStaged = !optimizerBackend.deleteDefenderStaged;
            if (optimizerBackend.deleteDefenderStaged) {
                optimizerBackend.defenderActive = false;
                optimizerBackend.defenderRegistryActive = false;
                optimizerBackend.defenderCmdActive = false;
                optimizerBackend.defenderServiceActive = false;
            } else {
                optimizerBackend.defenderActive = optimizerBackend.originalDefenderActive;
                optimizerBackend.defenderRegistryActive = optimizerBackend.originalDefenderRegistryActive;
                optimizerBackend.defenderCmdActive = optimizerBackend.originalDefenderCmdActive;
                optimizerBackend.defenderServiceActive = optimizerBackend.originalDefenderServiceActive;
            }
        }
    }
}
