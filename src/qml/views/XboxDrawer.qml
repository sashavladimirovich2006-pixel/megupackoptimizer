import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeguPackOptimizer 1.0
import Qt5Compat.GraphicalEffects
import "../components"

Column {
    id: xboxColumn
    width: parent.width
    spacing: 16
    

    // Global action header
    Column {
        width: parent.width
        spacing: 8
        Text {
            text: qsTr("Xbox Suite (Bulk Actions)")
            color: Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.bold: true
        }
        Text {
            text: qsTr("Purge or restore the entire Xbox app and telemetry suite for maximum performance.")
            color: Theme.textMuted
            font.family: Theme.fontFamily
            font.pixelSize: 9
            wrapMode: Text.Wrap
            width: parent.width
        }
    }

    Row {
        spacing: 10
        width: parent.width
        MeguButton {
            text: qsTr("Remove All")
            iconSource: "qrc:/MeguPackOptimizer/src/resources/close.svg"
            accented: optimizerBackend.xboxInstalled
            enabled: optimizerBackend.xboxInstalled && !optimizerBackend.isOptimizingSystem
            width: (parent.width - 10) / 2
            height: 32
            onClicked: {
                root.activeDrawer = "";
                stepLogModel.clear();
                optimizerBackend.removeXboxEntirely();
            }
        }
        MeguButton {
            text: qsTr("Restore All")
            iconSource: "qrc:/MeguPackOptimizer/src/resources/play.svg"
            accented: !optimizerBackend.xboxInstalled
            enabled: !optimizerBackend.isOptimizingSystem
            width: (parent.width - 10) / 2
            height: 32
            onClicked: {
                root.activeDrawer = "";
                stepLogModel.clear();
                optimizerBackend.restoreXboxEntirely();
            }
        }
    }

    Rectangle {
        width: parent.width
        height: 1
        color: Theme.border
    }

    // Individual component list title
    Text {
        text: qsTr("Individual Packages")
        color: Theme.textPrimary
        font.family: Theme.fontFamily
        font.pixelSize: 11
        font.bold: true
    }

    // Individual component list
    Column {
        width: parent.width
        spacing: 12

        // 1. Xbox App
        Row {
            width: parent.width
            spacing: 6
            Column {
                width: parent.width - 144
                spacing: 2
                Text {
                    text: qsTr("Xbox App")
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    font.bold: true
                }
                Text {
                    text: qsTr("Get-AppxPackage XboxApp | ...")
                    color: Theme.textMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: 8
                    font.italic: true
                }
            }
            MeguButton {
                text: qsTr("Restore")
                accented: false
                enabled: !optimizerBackend.xboxAppInstalled && !optimizerBackend.isOptimizingSystem
                width: 66
                height: 26
                onClicked: {
                    stepLogModel.clear();
                    optimizerBackend.restoreXboxComponent("XboxApp");
                }
            }
            MeguButton {
                text: qsTr("Remove")
                accented: true
                enabled: optimizerBackend.xboxAppInstalled && !optimizerBackend.isOptimizingSystem
                width: 66
                height: 26
                onClicked: {
                    stepLogModel.clear();
                    optimizerBackend.removeXboxComponent("XboxApp");
                }
            }
        }

        // 2. Xbox Gaming Overlay
        Row {
            width: parent.width
            spacing: 6
            Column {
                width: parent.width - 144
                spacing: 2
                Text {
                    text: qsTr("Xbox Gaming Overlay")
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    font.bold: true
                }
                Text {
                    text: qsTr("Get-AppxPackage XboxGamingOverlay | ...")
                    color: Theme.textMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: 8
                    font.italic: true
                }
            }
            MeguButton {
                text: qsTr("Restore")
                accented: false
                enabled: !optimizerBackend.xboxGamingOverlayInstalled && !optimizerBackend.isOptimizingSystem
                width: 66
                height: 26
                onClicked: {
                    stepLogModel.clear();
                    optimizerBackend.restoreXboxComponent("XboxGamingOverlay");
                }
            }
            MeguButton {
                text: qsTr("Remove")
                accented: true
                enabled: optimizerBackend.xboxGamingOverlayInstalled && !optimizerBackend.isOptimizingSystem
                width: 66
                height: 26
                onClicked: {
                    stepLogModel.clear();
                    optimizerBackend.removeXboxComponent("XboxGamingOverlay");
                }
            }
        }

        // 3. Xbox TCUI
        Row {
            width: parent.width
            spacing: 6
            Column {
                width: parent.width - 144
                spacing: 2
                Text {
                    text: qsTr("Xbox TCUI Dialogue")
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    font.bold: true
                }
                Text {
                    text: qsTr("Get-AppxPackage XboxTCUI | ...")
                    color: Theme.textMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: 8
                    font.italic: true
                }
            }
            MeguButton {
                text: qsTr("Restore")
                accented: false
                enabled: !optimizerBackend.xboxTcuiInstalled && !optimizerBackend.isOptimizingSystem
                width: 66
                height: 26
                onClicked: {
                    stepLogModel.clear();
                    optimizerBackend.restoreXboxComponent("XboxTCUI");
                }
            }
            MeguButton {
                text: qsTr("Remove")
                accented: true
                enabled: optimizerBackend.xboxTcuiInstalled && !optimizerBackend.isOptimizingSystem
                width: 66
                height: 26
                onClicked: {
                    stepLogModel.clear();
                    optimizerBackend.removeXboxComponent("XboxTCUI");
                }
            }
        }

        // 4. Xbox Game Speech Window
        Row {
            width: parent.width
            spacing: 6
            Column {
                width: parent.width - 144
                spacing: 2
                Text {
                    text: qsTr("Xbox Game Speech Window")
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    font.bold: true
                }
                Text {
                    text: qsTr("Get-AppxPackage XboxGameSpeechWindow | ...")
                    color: Theme.textMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: 8
                    font.italic: true
                }
            }
            MeguButton {
                text: qsTr("Restore")
                accented: false
                enabled: !optimizerBackend.xboxSpeechWindowInstalled && !optimizerBackend.isOptimizingSystem
                width: 66
                height: 26
                onClicked: {
                    stepLogModel.clear();
                    optimizerBackend.restoreXboxComponent("XboxGameSpeechWindow");
                }
            }
            MeguButton {
                text: qsTr("Remove")
                accented: true
                enabled: optimizerBackend.xboxSpeechWindowInstalled && !optimizerBackend.isOptimizingSystem
                width: 66
                height: 26
                onClicked: {
                    stepLogModel.clear();
                    optimizerBackend.removeXboxComponent("XboxGameSpeechWindow");
                }
            }
        }

        // 5. System Provisioned Packages
        Row {
            width: parent.width
            spacing: 6
            Column {
                width: parent.width - 144
                spacing: 2
                Text {
                    text: qsTr("System Provisioned Packages")
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    font.bold: true
                }
                Text {
                    text: qsTr("Get-AppxProvisionedPackage -Online | ...")
                    color: Theme.textMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: 8
                    font.italic: true
                }
            }
            MeguButton {
                text: qsTr("Restore")
                accented: false
                enabled: !optimizerBackend.xboxInstalled && !optimizerBackend.isOptimizingSystem
                width: 66
                height: 26
                onClicked: {
                    stepLogModel.clear();
                    optimizerBackend.restoreXboxComponent("AllUsersAndProvisioned");
                }
            }
            MeguButton {
                text: qsTr("Remove")
                accented: true
                enabled: optimizerBackend.xboxInstalled && !optimizerBackend.isOptimizingSystem
                width: 66
                height: 26
                onClicked: {
                    stepLogModel.clear();
                    optimizerBackend.removeXboxComponent("AllUsersAndProvisioned");
                }
            }
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
        MeguSwitch {
            text: qsTr("Disable Game Bar Popup")
            checked: !optimizerBackend.gamingOverlayActive
            onToggled: (isChecked) => {
                optimizerBackend.gamingOverlayActive = !isChecked;
            }
        }
        Text {
            text: qsTr("Neutralize ms-gamingoverlay triggers to stop 'You'll need a new app to open this link' errors when launching games.")
            color: Theme.textMuted
            font.family: Theme.fontFamily
            font.pixelSize: 9
            wrapMode: Text.Wrap
            width: parent.width
        }
    }
}
