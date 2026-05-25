import QtQuick
import QtQuick.Controls
import QtQuick.Shapes
import MeguPackOptimizer 1.0
import Qt5Compat.GraphicalEffects
import "components"
import "views"

ApplicationWindow {
    id: window
    visible: true
    width: 1024
    height: 680
    minimumWidth: 800
    minimumHeight: 560
    flags: Qt.Window | Qt.FramelessWindowHint
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
        border.color: Theme.border
        border.width: 1
        
        Behavior on color { ColorAnimation { duration: Theme.animNormal } }
    }

    property int activeTab: 1

    // Top Header Control Bar
    header: Rectangle {
        id: header
        width: parent.width
        height: 60
        color: Theme.headerBg
        border.width: 0

        // Custom bottom border for header
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: Theme.border
        }

        Behavior on color { ColorAnimation { duration: Theme.animNormal } }

        // Custom drag handler to move window when dragging empty areas of header
        MouseArea {
            anchors.fill: parent
            property point clickPos: "0,0"
            onPressed: (mouse) => {
                clickPos = Qt.point(mouse.x, mouse.y)
            }
            onPositionChanged: (mouse) => {
                if (window.visibility === Window.Maximized) return;
                var delta = Qt.point(mouse.x - clickPos.x, mouse.y - clickPos.y)
                window.x += delta.x
                window.y += delta.y
            }
            onDoubleClicked: {
                if (window.visibility === Window.Maximized) {
                    window.showNormal()
                } else {
                    window.showMaximized()
                }
            }
        }

        Item {
            anchors.fill: parent
            anchors.leftMargin: 24
            anchors.rightMargin: 24

            // Logo & Title Brand Area (Premium Aggressive Geometric style)
            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 14

                // Premium new transparent minimalist M logo
                Item {
                    width: 40
                    height: 40
                    anchors.verticalCenter: parent.verticalCenter
                    
                    // Soft glowing backing for the logo
                    Rectangle {
                        anchors.fill: parent
                        radius: 8
                        color: Theme.accent
                        opacity: 0.12
                        scale: 1.05
                    }
                    
                    Image {
                        source: "qrc:/MeguPackOptimizer/src/resources/megu_logo_transparent.png"
                        anchors.fill: parent
                        anchors.margins: 2 // elegant slight inset margin for perfect visual balance
                        smooth: true
                        mipmap: true
                        fillMode: Image.PreserveAspectFit
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

                // Circular Real-Time Logs button
                Item {
                    id: realTimeLogsRoundBtn
                    width: 32
                    height: 32
                    anchors.verticalCenter: parent.verticalCenter
                    opacity: !optimizerBackend.isOptimizingSystem ? 1.0 : 0.35
                    Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
                    
                    property bool isSelected: window.activeTab === 2
                    
                    Rectangle {
                        id: roundBtnBg
                        anchors.fill: parent
                        radius: 16 // fully circular
                        color: {
                            if (realTimeLogsRoundBtn.isSelected) {
                                return logsBtnMouse.pressed ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.30) : 
                                       (logsBtnMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.20) : 
                                        Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.12));
                            }
                            return logsBtnMouse.pressed ? Theme.buttonBgPressed : (logsBtnMouse.containsMouse ? Theme.buttonBgHover : "transparent");
                        }
                        
                        border.color: {
                            if (realTimeLogsRoundBtn.isSelected) {
                                return logsBtnMouse.pressed ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.50) : 
                                       (logsBtnMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.40) : 
                                        Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25));
                            }
                            return logsBtnMouse.containsMouse ? Theme.borderHover : Theme.border;
                        }
                        border.width: 1
                        
                        Behavior on color { ColorAnimation { duration: 100 } }
                        Behavior on border.color { ColorAnimation { duration: 100 } }
                    }
                    
                    Item {
                        width: 14
                        height: 14
                        anchors.centerIn: parent
                        
                        Image {
                            id: logsIcon
                            source: "qrc:/MeguPackOptimizer/src/resources/terminal.svg"
                            anchors.fill: parent
                            sourceSize.width: 14
                            sourceSize.height: 14
                            visible: false
                        }
                        
                        ColorOverlay {
                            anchors.fill: logsIcon
                            source: logsIcon
                            color: realTimeLogsRoundBtn.isSelected ? Theme.accent : (logsBtnMouse.containsMouse ? Theme.textPrimary : Theme.textSecondary)
                            opacity: realTimeLogsRoundBtn.isSelected ? 1.0 : (logsBtnMouse.containsMouse ? 0.95 : 0.65)
                            
                            Behavior on color { ColorAnimation { duration: 100 } }
                            Behavior on opacity { NumberAnimation { duration: 100 } }
                        }
                    }
                    
                    MouseArea {
                        id: logsBtnMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: !optimizerBackend.isOptimizingSystem ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: {
                            if (!optimizerBackend.isOptimizingSystem) {
                                window.activeTab = 2;
                            }
                        }
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
                        hasDropdown: true
                        dropdownOpen: optDropdown.opened
                        enabled: !optimizerBackend.isOptimizingSystem
                        onClicked: {
                            window.activeTab = 3;
                            optimizationView.currentSection = "core";
                        }
                        onDropdownClicked: {
                            optDropdown.open();
                        }
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
                }
            }

            // Version Label
            Text {
                anchors.right: parent.right
                anchors.rightMargin: 154
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("v1.0.0 Stable")
                color: Theme.textMuted
                font.family: Theme.fontFamily
                font.pixelSize: 11
            }
        }

        // Custom Window Control Buttons (Minimize, Maximize, Close)
        Row {
            id: windowControls
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            spacing: 0
            z: 10
            
            // Minimize Button
            Rectangle {
                width: 46
                height: parent.height
                color: minMouse.containsMouse ? (Theme.currentTheme === "Белоснежная" || Theme.currentTheme === "Розовая" ? "#0F000000" : "#1AFFFFFF") : "transparent"
                
                Rectangle {
                    width: 10
                    height: 1.5
                    color: Theme.textPrimary
                    anchors.centerIn: parent
                }
                
                MouseArea {
                    id: minMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: window.showMinimized()
                }
            }
            
            // Maximize / Restore Button
            Rectangle {
                width: 46
                height: parent.height
                color: maxMouse.containsMouse ? (Theme.currentTheme === "Белоснежная" || Theme.currentTheme === "Розовая" ? "#0F000000" : "#1AFFFFFF") : "transparent"
                
                Rectangle {
                    width: 10
                    height: 10
                    color: "transparent"
                    border.color: Theme.textPrimary
                    border.width: 1.5
                    anchors.centerIn: parent
                    
                    Rectangle {
                        visible: window.visibility === Window.Maximized
                        width: 8
                        height: 8
                        color: "transparent"
                        border.color: Theme.textPrimary
                        border.width: 1.5
                        x: 3
                        y: -3
                    }
                }
                
                MouseArea {
                    id: maxMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (window.visibility === Window.Maximized) {
                            window.showNormal()
                        } else {
                            window.showMaximized()
                        }
                    }
                }
            }
            
            // Close Button
            Rectangle {
                width: 46
                height: parent.height
                color: closeMouse.containsMouse ? "#E81123" : "transparent"
                
                Image {
                    source: "qrc:/MeguPackOptimizer/src/resources/close.svg"
                    width: 10
                    height: 10
                    anchors.centerIn: parent
                    sourceSize.width: 10
                    sourceSize.height: 10
                    opacity: closeMouse.containsMouse ? 1.0 : 0.8
                    Behavior on opacity { NumberAnimation { duration: 100 } }
                }
                
                MouseArea {
                    id: closeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: window.close()
                }
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

    // Custom Border Resize Gripper in Bottom-Right Corner for Frameless Window
    MouseArea {
        id: resizeArea
        width: 16
        height: 16
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        cursorShape: Qt.SizeFDiagCursor
        z: 100
        
        property point clickPos: "0,0"
        onPressed: (mouse) => {
            clickPos = Qt.point(mouse.x, mouse.y)
        }
        onPositionChanged: (mouse) => {
            var deltaX = mouse.x - clickPos.x
            var deltaY = mouse.y - clickPos.y
            
            var newW = window.width + deltaX
            var newH = window.height + deltaY
            
            if (newW >= window.minimumWidth) window.width = newW;
            if (newH >= window.minimumHeight) window.height = newH;
        }
    }

    Popup {
        id: optDropdown
        parent: tab3
        x: (parent.width - width) / 2
        y: parent.height + 6
        width: 180
        height: implicitHeight
        padding: 6
        
        background: Rectangle {
            color: "#F80D0E12"
            border.color: Theme.border
            border.width: 1
            radius: 8
            
            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: 0
                verticalOffset: 4
                radius: 12
                color: "#aa000000"
            }
        }
        
        contentItem: Column {
            spacing: 4
            width: parent.width
            
            MeguButton {
                width: parent.width
                height: 30
                text: qsTr("Telemetry")
                iconSource: "qrc:/MeguPackOptimizer/src/resources/folder.svg"
                accented: window.activeTab === 3 && optimizationView.currentSection === "telemetry"
                flat: !accented
                onClicked: {
                    window.activeTab = 3;
                    optimizationView.currentSection = "telemetry";
                    optDropdown.close();
                }
            }

            MeguButton {
                width: parent.width
                height: 30
                text: qsTr("Core Optimization")
                iconSource: "qrc:/MeguPackOptimizer/src/resources/bolt.svg"
                accented: window.activeTab === 3 && optimizationView.currentSection === "core"
                flat: !accented
                onClicked: {
                    window.activeTab = 3;
                    optimizationView.currentSection = "core";
                    optDropdown.close();
                }
            }
        }
    }
}
