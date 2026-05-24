import QtQuick
import QtQuick.Controls
import QtQuick.Shapes
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
    title: {
        var tabName = "";
        if (activeTab === 0) tabName = qsTr("Dashboard");
        else if (activeTab === 3) tabName = qsTr("Optimization");
        else if (activeTab === 1) tabName = qsTr("Settings");
        else if (activeTab === 2) tabName = qsTr("Real-Time Logs");
        return "Megu Pack Optimizer | " + tabName;
    }

    background: Rectangle {
        color: Theme.background
        
        // Large subtle glowing background sphere (glassmorphism peak!)
        Rectangle {
            width: 400
            height: 400
            radius: 200
            color: Theme.accent
            opacity: 0.05
            x: -100
            y: -100
            
            // Pulsing animation for ambient glow
            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { to: 0.08; duration: 4000; easing.type: Easing.InOutQuad }
                NumberAnimation { to: 0.05; duration: 4000; easing.type: Easing.InOutQuad }
            }
        }
        
        Rectangle {
            width: 500
            height: 500
            radius: 250
            color: Theme.yellowAccent
            opacity: 0.03
            x: parent.width - 300
            y: parent.height - 300
            
            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { to: 0.06; duration: 5000; easing.type: Easing.InOutQuad }
                NumberAnimation { to: 0.03; duration: 5000; easing.type: Easing.InOutQuad }
            }
        }
        
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

            // Logo & Title Brand Area (Premium Aggressive Geometric style)
            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 14

                // Aggressive geometric "M" custom vector shape
                Item {
                    width: 32
                    height: 32
                    anchors.verticalCenter: parent.verticalCenter
                    
                    // Soft glowing backing for the logo
                    Rectangle {
                        anchors.fill: parent
                        radius: 6
                        color: Theme.accent
                        opacity: 0.15
                        scale: 1.1
                    }
                    
                    Shape {
                        anchors.fill: parent
                        layer.enabled: true
                        
                        ShapePath {
                            strokeWidth: 0
                            strokeColor: "transparent"
                            fillGradient: LinearGradient {
                                x1: 0; y1: 0
                                x2: 32; y2: 32
                                GradientStop { position: 0.0; color: Theme.accentLight }
                                GradientStop { position: 1.0; color: Theme.accent }
                            }
                            
                            startX: 3; startY: 28
                            
                            PathLine { x: 7; y: 4 }      // left side outer slanted up
                            PathLine { x: 12; y: 4 }     // left peak horizontal cut
                            PathLine { x: 16; y: 15 }    // inner down to center
                            PathLine { x: 20; y: 4 }     // inner up to right peak
                            PathLine { x: 25; y: 4 }     // right peak horizontal cut
                            PathLine { x: 29; y: 28 }    // right side outer slanted down
                            PathLine { x: 23; y: 28 }    // right foot horizontal cut
                            PathLine { x: 21; y: 14 }    // right inner slanted up
                            PathLine { x: 16; y: 21 }    // center inner down
                            PathLine { x: 11; y: 14 }    // left inner slanted up
                            PathLine { x: 9; y: 28 }     // left foot left edge
                            PathLine { x: 3; y: 28 }     // close path
                        }
                    }
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 1
                    
                    Text {
                        text: "MEGU PACK"
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        font.bold: true
                        font.letterSpacing: 1.2
                    }
                    
                    Text {
                        text: "OPTIMIZER"
                        color: Theme.accent
                        font.family: Theme.fontFamily
                        font.pixelSize: 9
                        font.bold: true
                        font.letterSpacing: 2.5
                    }
                }
            }

            // Navigation Tab Container (Clean capsules style)
            Item {
                anchors.centerIn: parent
                height: parent.height
                width: tabsRow.width
                
                Row {
                    id: tabsRow
                    spacing: 16
                    height: parent.height
                    anchors.centerIn: parent
                    
                    MeguButton {
                        id: tab0
                        text: qsTr("Dashboard")
                        iconSource: "qrc:/MeguPackOptimizer/src/resources/monitor.svg"
                        accented: window.activeTab === 0
                        flat: !accented
                        enabled: !optimizerBackend.isOptimizingSystem
                        onClicked: window.activeTab = 0
                        anchors.verticalCenter: parent.verticalCenter
                        height: 34
                    }
                    
                    MeguButton {
                        id: tab3
                        text: qsTr("Optimization")
                        iconSource: "qrc:/MeguPackOptimizer/src/resources/bolt.svg"
                        accented: window.activeTab === 3
                        flat: !accented
                        enabled: !optimizerBackend.isOptimizingSystem
                        onClicked: window.activeTab = 3
                        anchors.verticalCenter: parent.verticalCenter
                        height: 34
                    }
                    
                    MeguButton {
                        id: tab1
                        text: qsTr("Settings")
                        iconSource: "qrc:/MeguPackOptimizer/src/resources/settings.svg"
                        accented: window.activeTab === 1
                        flat: !accented
                        enabled: !optimizerBackend.isOptimizingSystem
                        onClicked: window.activeTab = 1
                        anchors.verticalCenter: parent.verticalCenter
                        height: 34
                    }
                    
                    MeguButton {
                        id: tab2
                        text: qsTr("Real-Time Logs")
                        iconSource: "qrc:/MeguPackOptimizer/src/resources/terminal.svg"
                        accented: window.activeTab === 2
                        flat: !accented
                        enabled: !optimizerBackend.isOptimizingSystem
                        onClicked: window.activeTab = 2
                        anchors.verticalCenter: parent.verticalCenter
                        height: 34
                    }
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

    // Preloaded views container for buttery-smooth cross-fade tab switching
    Item {
        id: viewContainer
        anchors.fill: parent
        clip: true

        DashboardView {
            id: dashboardView
            anchors.fill: parent
            opacity: window.activeTab === 0 ? 1.0 : 0.0
            visible: opacity > 0.0
            enabled: opacity === 1.0
            
            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.animNormal
                    easing.type: Easing.OutCubic
                }
            }
        }

        SettingsView {
            id: settingsView
            anchors.fill: parent
            opacity: window.activeTab === 1 ? 1.0 : 0.0
            visible: opacity > 0.0
            enabled: opacity === 1.0
            
            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.animNormal
                    easing.type: Easing.OutCubic
                }
            }
        }

        OptimizationView {
            id: optimizationView
            anchors.fill: parent
            opacity: window.activeTab === 3 ? 1.0 : 0.0
            visible: opacity > 0.0
            enabled: opacity === 1.0
            
            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.animNormal
                    easing.type: Easing.OutCubic
                }
            }
        }

        LogViewer {
            id: logsView
            anchors.fill: parent
            anchors.margins: 20
            opacity: window.activeTab === 2 ? 1.0 : 0.0
            visible: opacity > 0.0
            enabled: opacity === 1.0
            
            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.animNormal
                    easing.type: Easing.OutCubic
                }
            }
        }
    }
}
