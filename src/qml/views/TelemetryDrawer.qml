import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeguPackOptimizer 1.0
import Qt5Compat.GraphicalEffects
import "../components"

Column {
    id: telemetryColumn
    width: parent.width
    spacing: 20
    

    Text {
        text: qsTr("Configure custom Windows telemetry and error reporting options.")
        color: Theme.textSecondary
        font.family: Theme.fontFamily
        font.pixelSize: 11
        font.bold: true
    }

    Column {
        width: parent.width
        spacing: 12

        MeguSwitch {
            text: qsTr("Connected User Experiences (DiagTrack)")
            checked: !optimizerBackend.telemetryDiagTrackActive
            onToggled: (isChecked) => { optimizerBackend.telemetryDiagTrackActive = !isChecked; }
        }

        MeguSwitch {
            text: qsTr("Device Management WAP Service (dmwappushservice)")
            checked: !optimizerBackend.telemetryWapPushActive
            onToggled: (isChecked) => { optimizerBackend.telemetryWapPushActive = !isChecked; }
        }

        MeguSwitch {
            text: qsTr("Customer Experience Improvement Program (CEIP)")
            checked: !optimizerBackend.telemetryCeipActive
            onToggled: (isChecked) => { optimizerBackend.telemetryCeipActive = !isChecked; }
        }

        MeguSwitch {
            text: qsTr("Windows Error Reporting (WER)")
            checked: !optimizerBackend.telemetryWerActive
            onToggled: (isChecked) => { optimizerBackend.telemetryWerActive = !isChecked; }
        }
    }
}
