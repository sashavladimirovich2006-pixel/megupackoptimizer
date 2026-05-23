import QtQuick
import QtQuick.Controls
import MeguPackOptimizer 1.0
import "components"
import "views"

ApplicationWindow {
    id: window
    visible: true
    width: 960
    height: 640
    minimumWidth: 800
    minimumHeight: 560
    title: qsTr("Megu Pack Optimizer")

    background: Rectangle {
        color: Theme.background
    }

    property int activeTab: 0

    // Main layout wrapper
    Item {
        anchors.fill: parent

        // Left Sidebar
        Rectangle {
            id: sidebar
            width: 220
            height: parent.height
            anchors.left: parent.left
            anchors.top: parent.top
            color: Theme.sidebarBg

            Behavior on color { ColorAnimation { duration: Theme.animNormal } }

            // Right border separator line
            Rectangle {
                width: 1
                height: parent.height
                anchors.right: parent.right
                color: Theme.border
                Behavior on color { ColorAnimation { duration: Theme.animNormal } }
            }

            // Top section: Logo and Navigation
            Column {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 18
                spacing: 20

                // Brand Area
                Column {
                    spacing: 2
                    width: parent.width

                    Text {
                        text: qsTr("MEGU PACK")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 18
                        font.bold: true
                        font.letterSpacing: 2
                    }
                    Text {
                        text: qsTr("OPTIMIZER")
                        color: Theme.yellowAccent
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 3
                    }
                }

                // Divider
                Rectangle {
                    width: parent.width
                    height: 1
                    color: Theme.border
                    Behavior on color { ColorAnimation { duration: Theme.animNormal } }
                }

                // Vertical Navigation Buttons
                Column {
                    width: parent.width
                    spacing: 8

                    MeguButton {
                        width: parent.width
                        text: qsTr("Dashboard")
                        iconSource: "qrc:/MeguPackOptimizer/src/resources/monitor.svg"
                        accented: window.activeTab === 0
                        enabled: !optimizerBackend.isProcessing
                        onClicked: window.activeTab = 0
                    }

                    MeguButton {
                        width: parent.width
                        text: qsTr("Settings")
                        iconSource: "qrc:/MeguPackOptimizer/src/resources/settings.svg"
                        accented: window.activeTab === 1
                        enabled: !optimizerBackend.isProcessing
                        onClicked: window.activeTab = 1
                    }

                    MeguButton {
                        width: parent.width
                        text: qsTr("Real-Time Logs")
                        iconSource: "qrc:/MeguPackOptimizer/src/resources/terminal.svg"
                        accented: window.activeTab === 2
                        onClicked: window.activeTab = 2
                    }
                }
            }

            // Bottom section: Theme Switcher & Footer
            Column {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 18
                spacing: 16

                // Theme Switcher Section
                Column {
                    width: parent.width
                    spacing: 8

                    Text {
                        text: qsTr("THEME SWITCHER")
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 1.5
                    }

                    Row {
                        spacing: 10
                        anchors.horizontalCenter: parent.horizontalCenter

                        Repeater {
                            model: [
                                { name: "Light Mode", color: "#FFFFFF", border: "#CCCCCC" },
                                { name: "Dark", color: "#1E293B", border: "transparent" },
                                { name: "OLED Blackout", color: "#000000", border: "#444444" },
                                { name: "RGB Gamer", color: "#FF007F", border: "transparent" },
                                { name: "Sakura Pink", color: "#FF85A2", border: "transparent" }
                            ]

                            delegate: Rectangle {
                                width: 22
                                height: 22
                                radius: 11
                                color: modelData.color
                                border.color: Theme.currentTheme === modelData.name ? Theme.accent : modelData.border
                                border.width: Theme.currentTheme === modelData.name ? 2 : 1
                                
                                scale: Theme.currentTheme === modelData.name ? 1.15 : (mouseArea.containsMouse ? 1.1 : 1.0)
                                Behavior on scale { NumberAnimation { duration: 100 } }

                                MouseArea {
                                    id: mouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Theme.setTheme(modelData.name)
                                }
                            }
                        }
                    }

                    Text {
                        text: Theme.currentTheme
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        horizontalAlignment: Text.AlignHCenter
                        width: parent.width
                    }
                }

                // Divider
                Rectangle {
                    width: parent.width
                    height: 1
                    color: Theme.border
                    Behavior on color { ColorAnimation { duration: Theme.animNormal } }
                }

                // Footer Version
                Text {
                    text: qsTr("v1.0.0 Stable Build")
                    color: Theme.textMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    horizontalAlignment: Text.AlignHCenter
                    width: parent.width
                }
            }
        }

        // Right Content Area
        Item {
            id: contentArea
            anchors.left: sidebar.right
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            // Top Header Bar
            Rectangle {
                id: contentHeader
                width: parent.width
                height: 54
                color: "transparent"
                anchors.top: parent.top
                anchors.left: parent.left

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 24
                    anchors.verticalCenter: parent.verticalCenter
                    text: {
                        if (window.activeTab === 0) return qsTr("DASHBOARD");
                        if (window.activeTab === 1) return qsTr("SETTINGS");
                        return qsTr("REAL-TIME LOGS");
                    }
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 16
                    font.bold: true
                    font.letterSpacing: 1.5
                }

                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 24
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("SYSTEM SPECS ACTIVE")
                    color: Theme.yellowAccent
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 1
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    anchors.bottom: parent.bottom
                    color: Theme.border
                    Behavior on color { ColorAnimation { duration: Theme.animNormal } }
                }
            }

            // Dynamic view loader
            Loader {
                id: viewLoader
                anchors.top: contentHeader.bottom
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                
                sourceComponent: {
                    if (activeTab === 0) return dashboardComponent;
                    if (activeTab === 1) return settingsComponent;
                    return logsComponent;
                }
            }
        }
    }

    // Declared views components
    Component {
        id: dashboardComponent
        DashboardView {}
    }

    Component {
        id: settingsComponent
        SettingsView {}
    }

    Component {
        id: logsComponent
        LogViewer {
            anchors.margins: 20
        }
    }
}
