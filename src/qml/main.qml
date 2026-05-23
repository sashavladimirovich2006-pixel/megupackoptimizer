import QtQuick
import QtQuick.Controls
import MeguPackOptimizer 1.0
import "components"
import "views"

ApplicationWindow {
    id: window
    visible: true
    width: 1024
    height: 680
    minimumWidth: 800
    minimumHeight: 560
    title: qsTr("Megu Pack Optimizer")

    background: Rectangle {
        color: Theme.background
        Behavior on color { ColorAnimation { duration: Theme.animNormal } }
    }

    property int activeTab: 1

    // Top Header Control Bar
    header: Rectangle {
        id: header
        width: parent.width
        height: 60
        color: Theme.headerBg
        border.color: Theme.border
        border.width: 1

        Behavior on color { ColorAnimation { duration: Theme.animNormal } }
        Behavior on border.color { ColorAnimation { duration: Theme.animNormal } }

        Item {
            anchors.fill: parent
            anchors.leftMargin: 24
            anchors.rightMargin: 24

            // Logo & Title Brand Area (Zune inspired)
            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                Text {
                    text: "M"
                    color: Theme.accent
                    font.family: Theme.fontFamily
                    font.pixelSize: 28
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 1
                    
                    Text {
                        text: qsTr("MEGU PACK")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        font.bold: true
                        font.letterSpacing: 1.5
                    }
                    
                    Text {
                        text: qsTr("OPTIMIZER")
                        color: Theme.yellowAccent
                        font.family: Theme.fontFamily
                        font.pixelSize: 9
                        font.bold: true
                        font.letterSpacing: 2
                    }
                }
            }

            // Navigation Tab Buttons
            Row {
                anchors.centerIn: parent
                spacing: 16

                MeguButton {
                    text: qsTr("Dashboard")
                    iconSource: "qrc:/MeguPackOptimizer/src/resources/monitor.svg"
                    accented: window.activeTab === 0
                    enabled: !optimizerBackend.isProcessing && !optimizerBackend.isOptimizingSystem
                    onClicked: window.activeTab = 0
                }

                MeguButton {
                    text: qsTr("Optimization")
                    iconSource: "qrc:/MeguPackOptimizer/src/resources/storage.svg"
                    accented: window.activeTab === 3
                    enabled: !optimizerBackend.isProcessing && !optimizerBackend.isOptimizingSystem
                    onClicked: window.activeTab = 3
                }

                MeguButton {
                    text: qsTr("Settings")
                    iconSource: "qrc:/MeguPackOptimizer/src/resources/settings.svg"
                    accented: window.activeTab === 1
                    enabled: !optimizerBackend.isProcessing && !optimizerBackend.isOptimizingSystem
                    onClicked: window.activeTab = 1
                }

                MeguButton {
                    text: qsTr("Real-Time Logs")
                    iconSource: "qrc:/MeguPackOptimizer/src/resources/terminal.svg"
                    accented: window.activeTab === 2
                    enabled: !optimizerBackend.isProcessing && !optimizerBackend.isOptimizingSystem
                    onClicked: window.activeTab = 2
                }
            }

            // Version Label
            Text {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("v1.0.0 Stable")
                color: Theme.textMuted
                font.family: Theme.fontFamily
                font.pixelSize: 11
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
            if (activeTab === 3) return optimizationComponent;
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
        id: optimizationComponent
        OptimizationView {}
    }

    Component {
        id: logsComponent
        LogViewer {
            anchors.margins: 20
        }
    }
}
