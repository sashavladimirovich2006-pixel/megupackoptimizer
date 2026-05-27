import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeguPackOptimizer 1.0
import Qt5Compat.GraphicalEffects
import "../components"

Column {
    id: usbColumn
    width: parent.width
    spacing: 20
    

    Text {
        text: qsTr("Configure power saving settings for individual USB 3.0 ports.")
        color: Theme.textSecondary
        font.family: Theme.fontFamily
        font.pixelSize: 11
        font.bold: true
    }

    Column {
        width: parent.width
        spacing: 12

        Repeater {
            model: optimizerBackend.usbDevices
            delegate: MeguSwitch {
                text: modelData.name
                checked: modelData.powerSavingActive
                onToggled: (isChecked) => {
                    optimizerBackend.setDevicePowerSavingActive(modelData.subkeyPath, isChecked);
                }
            }
        }
    }

    // Fallback if no USB 3.0 ports found
    Text {
        text: qsTr("No USB 3.0 controllers or hubs found.")
        color: Theme.textMuted
        font.family: Theme.fontFamily
        font.pixelSize: 11
        visible: optimizerBackend.usbDevices.length === 0
    }
}
