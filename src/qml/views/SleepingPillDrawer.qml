import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeguPackOptimizer 1.0
import Qt5Compat.GraphicalEffects
import "../components"

Column {
    id: sleepingPillColumn
    width: parent.width
    spacing: 16

    Text {
        text: qsTr("Sleeping Pill prevents background scheduled tasks from waking your PC from sleep mode.")
        color: Theme.textSecondary
        font.family: Theme.fontFamily
        font.pixelSize: 11
        font.bold: true
        bottomPadding: 8
    }

    // Main Card
    Rectangle {
        width: parent.width
        height: Math.max(120, layout.implicitHeight + 24)
        radius: 8
        color: "#05FFFFFF"
        border.color: Theme.border
        border.width: 1

        Column {
            id: layout
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12

            RowLayout {
                width: parent.width
                spacing: 12

                // Icon Badge
                Rectangle {
                    width: 32
                    height: 32
                    radius: 8
                    color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1)
                    Layout.alignment: Qt.AlignVCenter

                    Item {
                        width: 16
                        height: 16
                        anchors.centerIn: parent
                        Image {
                            id: sleepIconImg
                            source: "qrc:/MeguPackOptimizer/src/resources/settings.svg"
                            anchors.fill: parent
                            sourceSize.width: 16
                            sourceSize.height: 16
                            visible: false
                        }
                        ColorOverlay {
                            anchors.fill: sleepIconImg
                            source: sleepIconImg
                            color: Theme.accent
                        }
                    }
                }

                Column {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 2

                    Text {
                        text: qsTr("Task Scheduler Wakeup Tasks")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }
                    Text {
                        text: qsTr("Scan and disable tasks in Windows Task Scheduler that are allowed to wake up the system.")
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        width: parent.width
                        wrapMode: Text.WordWrap
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.border
            }

            // Status display
            RowLayout {
                width: parent.width
                spacing: 8

                Text {
                    id: statusText
                    Layout.fillWidth: true
                    text: {
                        if (optimizerBackend.sleepingPillWakeCount < 0) {
                            return qsTr("Status: Not scanned yet");
                        } else if (optimizerBackend.sleepingPillWakeCount === 0) {
                            return qsTr("Status: No tasks configured to wake the computer.");
                        } else {
                            return qsTr("Status: Found %1 task(s) configured to wake the computer.").arg(optimizerBackend.sleepingPillWakeCount);
                        }
                    }
                    color: optimizerBackend.sleepingPillWakeCount > 0 ? Theme.warning : Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    font.bold: true
                }

                Text {
                    id: successLabel
                    text: qsTr("SUCCESS")
                    color: Theme.success
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    font.bold: true
                    visible: false
                }
            }

            // Action Buttons Row
            Row {
                spacing: 12
                width: parent.width

                MeguButton {
                    text: qsTr("Scan Tasks")
                    height: 28
                    width: (parent.width - 12) / 2
                    onClicked: {
                        successLabel.visible = false;
                        optimizerBackend.runSleepingPillScan();
                    }
                }

                MeguButton {
                    text: qsTr("Disable Wakeup")
                    accented: true
                    height: 28
                    width: (parent.width - 12) / 2
                    enabled: optimizerBackend.sleepingPillWakeCount > 0
                    onClicked: {
                        optimizerBackend.stopWakeTasks();
                        successLabel.visible = true;
                    }
                }
            }
        }
    }
}
