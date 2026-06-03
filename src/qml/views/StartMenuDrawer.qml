import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeguPackOptimizer 1.0
import Qt5Compat.GraphicalEffects
import "../components"

Column {
    id: startMenuColumn
    width: parent.width
    spacing: 16

    Text {
        text: qsTr("Customization of the Windows Start Menu search, notifications, and power options.")
        color: Theme.textSecondary
        font.family: Theme.fontFamily
        font.pixelSize: 11
        font.bold: true
        bottomPadding: 8
    }

    // 1. Include web results when searching
    Rectangle {
        width: parent.width
        height: Math.max(56, webCol.implicitHeight + 16)
        radius: 8
        color: "#05FFFFFF"
        border.color: Theme.border
        border.width: 1

        Column {
            id: webCol
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.right: webSwitch.left
            anchors.rightMargin: 12
            spacing: 2

            Text {
                text: qsTr("Include web results when searching")
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
            }
            Text {
                text: qsTr("Disable this to stop Bing search from showing web results in the Start Menu search bar.")
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: 10
                width: parent.width
                wrapMode: Text.WordWrap
            }
        }

        MeguSwitch {
            id: webSwitch
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            checked: optimizerBackend.startMenuWebResults
            onToggled: (isChecked) => { optimizerBackend.startMenuWebResults = isChecked; }
        }
    }

    // 2. Autoinstall suggestions
    Rectangle {
        width: parent.width
        height: Math.max(56, suggestionsCol.implicitHeight + 16)
        radius: 8
        color: "#05FFFFFF"
        border.color: Theme.border
        border.width: 1

        Column {
            id: suggestionsCol
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.right: suggestionsSwitch.left
            anchors.rightMargin: 12
            spacing: 2

            Text {
                text: qsTr("Autoinstall suggestions")
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
            }
            Text {
                text: qsTr("Disable this to prevent Windows from silently installing recommended apps and sponsored shortcuts.")
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: 10
                width: parent.width
                wrapMode: Text.WordWrap
            }
        }

        MeguSwitch {
            id: suggestionsSwitch
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            checked: optimizerBackend.startMenuAutoinstall
            onToggled: (isChecked) => { optimizerBackend.startMenuAutoinstall = isChecked; }
        }
    }

    // 3. Account notifications
    Rectangle {
        width: parent.width
        height: Math.max(56, accountCol.implicitHeight + 16)
        radius: 8
        color: "#05FFFFFF"
        border.color: Theme.border
        border.width: 1

        Column {
            id: accountCol
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.right: accountSwitch.left
            anchors.rightMargin: 12
            spacing: 2

            Text {
                text: qsTr("Account notifications")
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
            }
            Text {
                text: qsTr("Disable notifications and badges related to your Microsoft account on the Start Menu.")
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: 10
                width: parent.width
                wrapMode: Text.WordWrap
            }
        }

        MeguSwitch {
            id: accountSwitch
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            checked: optimizerBackend.startMenuAccountNotifications
            onToggled: (isChecked) => { optimizerBackend.startMenuAccountNotifications = isChecked; }
        }
    }

    // 4. Show hibernate in power menu
    Rectangle {
        width: parent.width
        height: Math.max(56, hibernateCol.implicitHeight + 16)
        radius: 8
        color: "#05FFFFFF"
        border.color: Theme.border
        border.width: 1
        enabled: optimizerBackend.hibernationActive
        opacity: enabled ? 1.0 : 0.5

        Behavior on opacity { NumberAnimation { duration: Theme.animFast } }

        Column {
            id: hibernateCol
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.right: hibernateSwitch.left
            anchors.rightMargin: 12
            spacing: 2

            Text {
                text: qsTr("Show hibernate in power menu")
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
            }
            Text {
                text: enabled ? qsTr("Show or hide the Hibernate option in the Start Menu power options menu.")
                              : qsTr("Show or hide the Hibernate option in the Start Menu. (Requires Hibernation to be enabled in Power Plan settings)")
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: 10
                width: parent.width
                wrapMode: Text.WordWrap
            }
        }

        MeguSwitch {
            id: hibernateSwitch
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            checked: optimizerBackend.startMenuShowHibernate
            enabled: parent.enabled
            onToggled: (isChecked) => { optimizerBackend.startMenuShowHibernate = isChecked; }
        }
    }
}
