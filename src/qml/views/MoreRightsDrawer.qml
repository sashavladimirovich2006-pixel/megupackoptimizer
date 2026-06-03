import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeguPackOptimizer 1.0
import Qt5Compat.GraphicalEffects
import "../components"

Column {
    id: moreRightsColumn
    width: parent.width
    spacing: 16

    Text {
        text: qsTr("Advanced system privilege and security settings.")
        color: Theme.textSecondary
        font.family: Theme.fontFamily
        font.pixelSize: 11
        font.bold: true
        bottomPadding: 8
    }

    // 1. God Mode Card
    Rectangle {
        width: parent.width
        height: Math.max(56, godModeCol.implicitHeight + 16)
        radius: 8
        color: "#05FFFFFF"
        border.color: Theme.border
        border.width: 1

        Column {
            id: godModeCol
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.right: godModeSwitch.left
            anchors.rightMargin: 12
            spacing: 2

            Text {
                text: qsTr("God Mode")
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
            }
            Text {
                text: qsTr("Creates a special folder with all Windows settings shortcuts on the desktop.")
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: 10
                width: parent.width
                wrapMode: Text.WordWrap
            }
        }

        MeguSwitch {
            id: godModeSwitch
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            checked: optimizerBackend.superuserGodModeActive
            onToggled: (isChecked) => { optimizerBackend.superuserGodModeActive = isChecked; }
        }
    }

    // 2. Developer Mode Card
    Rectangle {
        width: parent.width
        height: Math.max(56, devModeCol.implicitHeight + 16) + (devWarning.visible ? devWarning.implicitHeight + 8 : 0)
        radius: 8
        color: "#05FFFFFF"
        border.color: Theme.border
        border.width: 1

        Column {
            id: devModeCol
            anchors.top: parent.top
            anchors.topMargin: 8
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.right: devModeSwitch.left
            anchors.rightMargin: 12
            spacing: 2

            Text {
                text: qsTr("Developer Mode")
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
            }
            Text {
                text: qsTr("Enables installation and running of applications from any sources (sideloading) without signatures.")
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: 10
                width: parent.width
                wrapMode: Text.WordWrap
            }

            Text {
                id: devWarning
                visible: devModeSwitch.checked
                text: qsTr("⚠️ Enabling developer mode can reduce system security.")
                color: "#ffc107"
                font.family: Theme.fontFamily
                font.pixelSize: 9
                font.bold: true
                width: parent.width
                wrapMode: Text.WordWrap
                topPadding: 4
            }
        }

        MeguSwitch {
            id: devModeSwitch
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.top: parent.top
            anchors.topMargin: 8
            checked: optimizerBackend.superuserDeveloperModeActive
            onToggled: (isChecked) => { optimizerBackend.superuserDeveloperModeActive = isChecked; }
        }
    }

    // 3. User Account Control (UAC) Card
    Rectangle {
        width: parent.width
        height: Math.max(56, uacCol.implicitHeight + 16) + (uacRebootInfo.visible ? uacRebootInfo.implicitHeight + 8 : 0)
        radius: 8
        color: "#05FFFFFF"
        border.color: Theme.border
        border.width: 1

        Column {
            id: uacCol
            anchors.top: parent.top
            anchors.topMargin: 8
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.right: uacDropdown.left
            anchors.rightMargin: 12
            spacing: 2

            Text {
                text: qsTr("User Account Control (UAC)")
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
            }
            Text {
                text: qsTr("The warning level for programs attempting to make changes to your computer.")
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: 10
                width: parent.width
                wrapMode: Text.WordWrap
            }

            Text {
                id: uacRebootInfo
                visible: optimizerBackend.superuserUacLevel !== optimizerBackend.originalSuperuserUacLevel
                text: qsTr("🔄 A system reboot is required to apply UAC changes.")
                color: Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: 9
                font.bold: true
                width: parent.width
                wrapMode: Text.WordWrap
                topPadding: 4
            }
        }

        // Styled Premium ComboBox Dropdown
        Rectangle {
            id: uacDropdown
            width: 140
            height: 32
            radius: 6
            color: "#05FFFFFF"
            border.color: Theme.border
            border.width: 1
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.top: parent.top
            anchors.topMargin: 8

            property int currentVal: optimizerBackend.superuserUacLevel

            readonly property var options: [
                { id: 0, label: qsTr("Always notify") },
                { id: 1, label: qsTr("With dimming") },
                { id: 2, label: qsTr("Without dimming") },
                { id: 3, label: qsTr("Never notify") }
            ]

            function getLabelForVal(v) {
                for (var i = 0; i < options.length; i++) {
                    if (options[i].id === v) return options[i].label;
                }
                return qsTr("With dimming");
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                text: uacDropdown.getLabelForVal(uacDropdown.currentVal)
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 11
            }

            Text {
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                text: "⌵"
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    uacMenu.open();
                }
                onEntered: uacDropdown.border.color = Theme.accent
                onExited: uacDropdown.border.color = Theme.border
            }

            Menu {
                id: uacMenu
                y: uacDropdown.height + 4
                width: uacDropdown.width
                
                background: Rectangle {
                    color: Theme.sidebarBg
                    border.color: Theme.border
                    border.width: 1
                    radius: 6
                }

                Instantiator {
                    model: uacDropdown.options
                    onObjectAdded: (index, object) => uacMenu.insertItem(index, object)
                    onObjectRemoved: (index, object) => uacMenu.removeItem(object)

                    delegate: MenuItem {
                        text: modelData.label
                        width: uacMenu.width
                        height: 32
                        
                        contentItem: Text {
                            text: parent.text
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            color: parent.highlighted ? Theme.accent : Theme.textPrimary
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 12
                        }

                        background: Rectangle {
                            color: parent.highlighted ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1) : "transparent"
                        }

                        onTriggered: {
                            optimizerBackend.superuserUacLevel = modelData.id;
                        }
                    }
                }
            }
        }
    }

    // 4. User Choice Protection Driver (UCPD) Card
    Rectangle {
        width: parent.width
        height: Math.max(56, ucpdCol.implicitHeight + 16) + (ucpdRebootInfo.visible ? ucpdRebootInfo.implicitHeight + 8 : 0)
        radius: 8
        color: "#05FFFFFF"
        border.color: Theme.border
        border.width: 1

        Column {
            id: ucpdCol
            anchors.top: parent.top
            anchors.topMargin: 8
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.right: ucpdSwitch.left
            anchors.rightMargin: 12
            spacing: 2

            Text {
                text: qsTr("User Choice Protection Driver (UCPD)")
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
            }
            Text {
                text: qsTr("Blocks the bypass of Windows protection, resetting file associations and default changes by other utilities.")
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: 10
                width: parent.width
                wrapMode: Text.WordWrap
            }

            Text {
                id: ucpdRebootInfo
                visible: optimizerBackend.superuserUcpdActive !== optimizerBackend.originalSuperuserUcpdActive
                text: qsTr("🔄 A system reboot is required to apply UCPD changes.")
                color: Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: 9
                font.bold: true
                width: parent.width
                wrapMode: Text.WordWrap
                topPadding: 4
            }
        }

        MeguSwitch {
            id: ucpdSwitch
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.top: parent.top
            anchors.topMargin: 8
            checked: optimizerBackend.superuserUcpdActive
            onToggled: (isChecked) => { optimizerBackend.superuserUcpdActive = isChecked; }
        }
    }
}
