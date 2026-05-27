import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeguPackOptimizer 1.0
import Qt5Compat.GraphicalEffects
import "../components"

Column {
    id: notificationsColumn
    width: parent.width
    spacing: 20
    

    Text {
        text: qsTr("Configure custom Windows notification and sound alert rules.")
        color: Theme.textSecondary
        font.family: Theme.fontFamily
        font.pixelSize: 11
        font.bold: true
    }

    Column {
        width: parent.width
        spacing: 12

        MeguSwitch {
            text: qsTr("Global Toast Notifications")
            checked: optimizerBackend.notifGlobalActive
            onToggled: (isChecked) => { optimizerBackend.notifGlobalActive = isChecked; }
        }

        MeguSwitch {
            text: qsTr("App Notifications")
            checked: optimizerBackend.notifAppActive
            onToggled: (isChecked) => { optimizerBackend.notifAppActive = isChecked; }
        }

        MeguSwitch {
            text: qsTr("Notification Sounds")
            checked: optimizerBackend.notifSoundsActive
            onToggled: (isChecked) => { optimizerBackend.notifSoundsActive = isChecked; }
        }

        MeguSwitch {
            text: qsTr("Lock Screen Notifications")
            checked: optimizerBackend.notifLockscreenActive
            onToggled: (isChecked) => { optimizerBackend.notifLockscreenActive = isChecked; }
        }
    }
}
