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

    // Background color matching the Slate Blue Neo-Luna palette
    background: Rectangle {
        color: Theme.background
    }

    // Tab index tracker
    property int activeTab: 0

    // Top Header Control Bar
    header: Rectangle {
        id: header
        width: parent.width
        height: 54
        color: Theme.headerBg
        border.color: Theme.border
        border.width: 1

        Item {
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 20

            // Logo & Title Brand Area (Zune inspired)
            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10

                Rectangle {
                    width: 28
                    height: 28
                    radius: 14
                    color: Theme.accent

                    Text {
                        text: "M"
                        color: Theme.textInverse
                        font.family: Theme.fontFamily
                        font.pixelSize: 14
                        font.bold: true
                        anchors.centerIn: parent
                    }
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 1
                    
                    Text {
                        text: qsTr("MEGU PACK OPTIMIZER")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        font.bold: true
                        font.letterSpacing: 1.5
                    }
                    
                    Text {
                        text: qsTr("v1.0.0 Stable Build")
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: 9
                    }
                }
            }

            // Navigation Tab Buttons
            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                MeguButton {
                    text: qsTr("Dashboard")
                    iconSource: "qrc:/MeguPackOptimizer/src/resources/folder.svg"
                    accented: window.activeTab === 0
                    enabled: !optimizerBackend.isProcessing
                    onClicked: window.activeTab = 0
                }

                MeguButton {
                    text: qsTr("Settings")
                    iconSource: "qrc:/MeguPackOptimizer/src/resources/settings.svg"
                    accented: window.activeTab === 1
                    enabled: !optimizerBackend.isProcessing
                    onClicked: window.activeTab = 1
                }

                MeguButton {
                    text: qsTr("System Logs")
                    iconSource: "qrc:/MeguPackOptimizer/src/resources/terminal.svg"
                    accented: window.activeTab === 2
                    onClicked: window.activeTab = 2
                }
            }
        }
    }

    // Dynamic View Loader
    Loader {
        id: viewLoader
        anchors.fill: parent
        sourceComponent: {
            if (activeTab === 0) return dashboardComponent;
            if (activeTab === 1) return settingsComponent;
            return logsComponent;
        }
    }

    // Declared views
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
