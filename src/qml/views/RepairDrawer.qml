import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeguPackOptimizer 1.0
import Qt5Compat.GraphicalEffects
import "../components"

Column {
    id: repairColumn
    width: parent.width
    spacing: 16

    property bool dismChecked: false
    property bool sfcChecked: false
    property bool chkdskChecked: false

    RowLayout {
        width: parent.width
        spacing: 8

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                text: qsTr("Scan and restore Windows system files, image, and filesystem integrity.")
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.bold: true
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
            }

            Text {
                text: qsTr("Recommendation: Run diagnostics in the following order: DISM ➜ SFC ➜ CHKDSK")
                color: Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: 10
                font.bold: true
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
            }
        }

        // Info Button with Tooltip
        Item {
            width: 20
            height: 20
            Layout.alignment: Qt.AlignVCenter

            Rectangle {
                anchors.fill: parent
                radius: 10
                color: infoMouseArea.containsMouse ? Theme.accentDim : "transparent"
                Behavior on color { ColorAnimation { duration: Theme.animFast } }
            }

            Item {
                width: 14
                height: 14
                anchors.centerIn: parent
                Image {
                    id: infoIconImg
                    source: "qrc:/MeguPackOptimizer/src/resources/info.svg"
                    anchors.fill: parent
                    sourceSize.width: 14
                    sourceSize.height: 14
                    visible: false
                }
                ColorOverlay {
                    anchors.fill: infoIconImg
                    source: infoIconImg
                    color: infoMouseArea.containsMouse ? Theme.accent : Theme.textSecondary
                }
            }

            ToolTip {
                id: infoTooltip
                visible: infoMouseArea.containsMouse
                delay: 200
                width: 320
                contentItem: Text {
                    text: qsTr("DISM: Repairs Windows system image, recovers files and preserves system integrity.\n\nSFC: Scans and recovers corrupted or missing system files.\n\nCHKDSK: Scans filesystem integrity and schedules logical errors / bad sectors repair on reboot.\n\nRecommendation: If scans and repairs do not solve your system problems, we recommend performing a clean install of Windows.")
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    wrapMode: Text.WordWrap
                    lineHeight: 1.3
                }
                background: Rectangle {
                    color: "#F0080B10"
                    border.color: Theme.accent
                    border.width: 1
                    radius: 6
                }
            }

            MouseArea {
                id: infoMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
            }
        }
    }

    // DISM Checkbox Row
    Rectangle {
        width: parent.width
        height: Math.max(56, dismCol.implicitHeight + 16)
        radius: 8
        color: dismMouseArea.containsMouse ? "#0AFFFFFF" : "#05FFFFFF"
        border.color: dismMouseArea.containsMouse ? Theme.accentDim : Theme.border
        border.width: 1

        Behavior on color { ColorAnimation { duration: Theme.animFast } }
        Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

        MouseArea {
            id: dismMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            enabled: !optimizerBackend.repairRunning
            onClicked: {
                repairColumn.dismChecked = !repairColumn.dismChecked;
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 12

            // Checkbox
            Rectangle {
                width: 18
                height: 18
                radius: 4
                color: repairColumn.dismChecked ? Theme.accent : "transparent"
                border.color: repairColumn.dismChecked ? Theme.accent : Theme.border
                border.width: 1
                Layout.alignment: Qt.AlignVCenter

                Text {
                    text: "✓"
                    color: "white"
                    font.pixelSize: 11
                    font.bold: true
                    anchors.centerIn: parent
                    visible: repairColumn.dismChecked
                }
            }

            Column {
                id: dismCol
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 2

                Text {
                    text: qsTr("DISM (Deployment Image Servicing and Management)")
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    font.bold: true
                }
                Text {
                    text: qsTr("Repairs Windows system image, recovers files and preserves system integrity.")
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    width: parent.width
                    wrapMode: Text.WordWrap
                }
            }
        }
    }

    // SFC Checkbox Row
    Rectangle {
        width: parent.width
        height: Math.max(56, sfcCol.implicitHeight + 16)
        radius: 8
        color: sfcMouseArea.containsMouse ? "#0AFFFFFF" : "#05FFFFFF"
        border.color: sfcMouseArea.containsMouse ? Theme.accentDim : Theme.border
        border.width: 1

        Behavior on color { ColorAnimation { duration: Theme.animFast } }
        Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

        MouseArea {
            id: sfcMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            enabled: !optimizerBackend.repairRunning
            onClicked: {
                repairColumn.sfcChecked = !repairColumn.sfcChecked;
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 12

            // Checkbox
            Rectangle {
                width: 18
                height: 18
                radius: 4
                color: repairColumn.sfcChecked ? Theme.accent : "transparent"
                border.color: repairColumn.sfcChecked ? Theme.accent : Theme.border
                border.width: 1
                Layout.alignment: Qt.AlignVCenter

                Text {
                    text: "✓"
                    color: "white"
                    font.pixelSize: 11
                    font.bold: true
                    anchors.centerIn: parent
                    visible: repairColumn.sfcChecked
                }
            }

            Column {
                id: sfcCol
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 2

                Text {
                    text: qsTr("SFC (System File Checker)")
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    font.bold: true
                }
                Text {
                    text: qsTr("Scans and recovers corrupted or missing system files.")
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    width: parent.width
                    wrapMode: Text.WordWrap
                }
            }
        }
    }

    // CHKDSK Checkbox Row
    Rectangle {
        width: parent.width
        height: Math.max(56, chkdskCol.implicitHeight + 16)
        radius: 8
        color: chkdskMouseArea.containsMouse ? "#0AFFFFFF" : "#05FFFFFF"
        border.color: chkdskMouseArea.containsMouse ? Theme.accentDim : Theme.border
        border.width: 1

        Behavior on color { ColorAnimation { duration: Theme.animFast } }
        Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

        MouseArea {
            id: chkdskMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            enabled: !optimizerBackend.repairRunning
            onClicked: {
                repairColumn.chkdskChecked = !repairColumn.chkdskChecked;
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 12

            // Checkbox
            Rectangle {
                width: 18
                height: 18
                radius: 4
                color: repairColumn.chkdskChecked ? Theme.accent : "transparent"
                border.color: repairColumn.chkdskChecked ? Theme.accent : Theme.border
                border.width: 1
                Layout.alignment: Qt.AlignVCenter

                Text {
                    text: "✓"
                    color: "white"
                    font.pixelSize: 11
                    font.bold: true
                    anchors.centerIn: parent
                    visible: repairColumn.chkdskChecked
                }
            }

            Column {
                id: chkdskCol
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 2

                Text {
                    text: qsTr("CHKDSK (Check Disk)")
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    font.bold: true
                }
                Text {
                    text: qsTr("Scans filesystem integrity and schedules logical errors / bad sectors repair on reboot.")
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    width: parent.width
                    wrapMode: Text.WordWrap
                }
            }
        }
    }

    // Progress Indicator & Status text
    Column {
        width: parent.width
        spacing: 8
        visible: optimizerBackend.repairRunning

        MeguProgressBar {
            id: repairProgressBar
            width: parent.width
            height: 6
            value: optimizerBackend.repairProgress
        }

        Text {
            text: optimizerBackend.repairStatusText
            color: Theme.textSecondary
            font.family: Theme.fontFamily
            font.pixelSize: 11
            width: parent.width
            elide: Text.ElideRight
        }
    }

    // Bottom Action Row
    RowLayout {
        width: parent.width
        spacing: 12

        // Validator Message
        Text {
            text: qsTr("Select at least one tool")
            color: Theme.warning // Orange/warning accent
            font.family: Theme.fontFamily
            font.pixelSize: 11
            font.bold: true
            Layout.fillWidth: true
            visible: !repairColumn.dismChecked && !repairColumn.sfcChecked && !repairColumn.chkdskChecked
        }

        // Dummy item to push buttons to the right if validator is hidden
        Item {
            Layout.fillWidth: true
            visible: repairColumn.dismChecked || repairColumn.sfcChecked || repairColumn.chkdskChecked
        }

        MeguButton {
            text: qsTr("Scan")
            height: 28
            width: 100
            enabled: (repairColumn.dismChecked || repairColumn.sfcChecked || repairColumn.chkdskChecked) && !optimizerBackend.repairRunning
            onClicked: {
                optimizerBackend.runRepairScan(repairColumn.dismChecked, repairColumn.sfcChecked, repairColumn.chkdskChecked);
            }
        }

        MeguButton {
            text: qsTr("Repair")
            accented: true
            height: 28
            width: 100
            enabled: (repairColumn.dismChecked || repairColumn.sfcChecked || repairColumn.chkdskChecked) && !optimizerBackend.repairRunning
            onClicked: {
                optimizerBackend.runRepairFix(repairColumn.dismChecked, repairColumn.sfcChecked, repairColumn.chkdskChecked);
            }
        }
    }
}
