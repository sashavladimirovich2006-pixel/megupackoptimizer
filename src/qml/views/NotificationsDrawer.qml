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

        // App Notifications collapsible group
        Column {
            width: parent.width
            spacing: 8

            Row {
                width: parent.width
                spacing: 12

                MeguSwitch {
                    id: appNotificationsSwitch
                    text: qsTr("App Notifications")
                    checked: optimizerBackend.notifAppActive
                    onToggled: (isChecked) => { optimizerBackend.notifAppActive = isChecked; }
                    width: parent.width - 44
                }

                // Expand/collapse arrow button next to the switch
                Rectangle {
                    width: 28
                    height: 28
                    radius: 6
                    color: expandArrowMouse.containsMouse ? Theme.buttonBgHover : "transparent"
                    border.color: expandArrowMouse.containsMouse ? Theme.borderHover : "transparent"
                    border.width: 1
                    anchors.verticalCenter: appNotificationsSwitch.verticalCenter

                    Behavior on color { ColorAnimation { duration: Theme.animFast } }

                    property bool expanded: false

                    Item {
                        anchors.fill: parent
                        
                        Image {
                            id: arrowIcon
                            source: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"
                            anchors.centerIn: parent
                            width: 12
                            height: 12
                            rotation: expandArrowMouse.parent.expanded ? 270 : 90 // Up (270) or Down (90)
                            Behavior on rotation { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }
                            visible: false
                        }

                        ColorOverlay {
                            anchors.fill: arrowIcon
                            source: arrowIcon
                            color: expandArrowMouse.containsMouse ? Theme.accent : Theme.textSecondary
                            rotation: arrowIcon.rotation
                        }
                    }

                    MouseArea {
                        id: expandArrowMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            parent.expanded = !parent.expanded;
                        }
                    }
                }
            }

            // Expandable container for app list
            Item {
                id: appsListContainer
                width: parent.width
                height: expandArrowMouse.parent.expanded ? appsListColumn.implicitHeight : 0
                opacity: expandArrowMouse.parent.expanded ? 1.0 : 0.0
                visible: opacity > 0.0
                clip: true

                Behavior on height { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }
                Behavior on opacity { NumberAnimation { duration: Theme.animFast } }

                Column {
                    id: appsListColumn
                    width: parent.width
                    spacing: 8
                    leftPadding: 24 // Indent sub-items to make hierarchy crystal clear

                    // Title for the sub-section
                    Text {
                        text: qsTr("Per-App Notification Permissions:")
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        font.bold: true
                        bottomPadding: 4
                    }

                    Repeater {
                        model: optimizerBackend.appNotificationSettings
                        delegate: MeguSwitch {
                            text: modelData.name
                            checked: modelData.enabled
                            enabled: optimizerBackend.notifAppActive // Disable sub-items if global App Notifications switch is off
                            opacity: enabled ? 1.0 : 0.5
                            onToggled: (isChecked) => {
                                optimizerBackend.setAppNotificationEnabled(modelData.key, isChecked);
                            }
                            
                            Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
                        }
                    }
                }
            }
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
