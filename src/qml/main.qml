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
        
        // Large subtle glowing background sphere (glassmorphism peak!)
        Rectangle {
            width: 450
            height: 450
            radius: 225
            color: Theme.accent
            opacity: 0.12
            x: -50
            y: -50
            
            // Pulsing animation for ambient glow
            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { to: 0.18; duration: 4000; easing.type: Easing.InOutQuad }
                NumberAnimation { to: 0.12; duration: 4000; easing.type: Easing.InOutQuad }
            }
        }
        
        Rectangle {
            width: 550
            height: 550
            radius: 275
            color: Theme.yellowAccent
            opacity: 0.08
            x: parent.width - 250
            y: parent.height - 250
            
            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { to: 0.14; duration: 5000; easing.type: Easing.InOutQuad }
                NumberAnimation { to: 0.08; duration: 5000; easing.type: Easing.InOutQuad }
            }
        }
        
        Behavior on color { ColorAnimation { duration: Theme.animNormal } }
    }

    property int activeTab: 0 // Default to Dashboard for a gorgeous first look!

    // Custom window dragging zone spanning the entire window background
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

    // 1. Left Floating Vertical Sidebar (High-Tech Diagnostic Capsule)
    Rectangle {
        id: sidebar
        width: 76
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: 12
        radius: Theme.radiusNormal
        color: Theme.sidebarBg
        border.color: Theme.border
        border.width: 1

        Behavior on color { ColorAnimation { duration: Theme.animNormal } }
        Behavior on border.color { ColorAnimation { duration: Theme.animNormal } }

        // Sidebar Specular Gloss Highlight
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            z: -1
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#1AFFFFFF" }
                GradientStop { position: 0.4; color: "transparent" }
            }
        }

        // Top Branding Area: Interactive Pulsing Logo
        Item {
            id: logoArea
            width: parent.width
            height: 64
            anchors.top: parent.top

            Rectangle {
                width: 34
                height: 34
                radius: 17
                color: Theme.accent
                opacity: 0.12
                anchors.centerIn: parent
                scale: logoMouse.containsMouse ? 1.2 : 1.0
                Behavior on scale { NumberAnimation { duration: 200 } }

                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.22; duration: 2500; easing.type: Easing.InOutQuad }
                    NumberAnimation { to: 0.12; duration: 2500; easing.type: Easing.InOutQuad }
                }
            }

            Image {
                source: "qrc:/MeguPackOptimizer/src/resources/bolt.svg"
                width: 20
                height: 20
                sourceSize.width: 20
                sourceSize.height: 20
                anchors.centerIn: parent
                scale: logoMouse.containsMouse ? 1.15 : 1.0
                Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
            }

            MouseArea {
                id: logoMouse
                anchors.fill: parent
                hoverEnabled: true
            }
        }

        // Divider
        Rectangle {
            id: logoDivider
            anchors.top: logoArea.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            height: 1
            color: Theme.border
        }

        // Vertical Tab Buttons Column
        Column {
            anchors.top: logoDivider.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 24
            anchors.bottomMargin: 24
            spacing: 18

            // Tab 0: Dashboard
            Item {
                width: 52
                height: 52
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    anchors.fill: parent
                    radius: Theme.radiusSmall
                    color: window.activeTab === 0 ? Theme.accentDim : "transparent"
                    border.color: window.activeTab === 0 ? Theme.accent : (mouse0.containsMouse ? Theme.borderHover : "transparent")
                    border.width: 1

                    Behavior on color { ColorAnimation { duration: Theme.animFast } }
                    Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
                }

                // Left active strip
                Rectangle {
                    width: 3
                    height: window.activeTab === 0 ? 20 : 0
                    radius: 1.5
                    color: Theme.accent
                    anchors.left: parent.left
                    anchors.leftMargin: -6
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on height { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                }

                Image {
                    source: "qrc:/MeguPackOptimizer/src/resources/monitor.svg"
                    width: 20; height: 20
                    sourceSize.width: 20; sourceSize.height: 20
                    anchors.centerIn: parent
                    opacity: (window.activeTab === 0 || mouse0.containsMouse) ? 1.0 : 0.65
                    scale: mouse0.containsMouse ? 1.12 : 1.0
                    Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
                    Behavior on scale { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }
                }

                MouseArea {
                    id: mouse0
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: window.activeTab = 0
                }

                ToolTip {
                    visible: mouse0.containsMouse
                    text: qsTr("Dashboard")
                    delay: 250
                }
            }

            // Tab 3: Optimization
            Item {
                width: 52
                height: 52
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    anchors.fill: parent
                    radius: Theme.radiusSmall
                    color: window.activeTab === 3 ? Theme.accentDim : "transparent"
                    border.color: window.activeTab === 3 ? Theme.accent : (mouse3.containsMouse ? Theme.borderHover : "transparent")
                    border.width: 1

                    Behavior on color { ColorAnimation { duration: Theme.animFast } }
                    Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
                }

                // Left active strip
                Rectangle {
                    width: 3
                    height: window.activeTab === 3 ? 20 : 0
                    radius: 1.5
                    color: Theme.accent
                    anchors.left: parent.left
                    anchors.leftMargin: -6
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on height { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                }

                Image {
                    source: "qrc:/MeguPackOptimizer/src/resources/bolt.svg"
                    width: 20; height: 20
                    sourceSize.width: 20; sourceSize.height: 20
                    anchors.centerIn: parent
                    opacity: (window.activeTab === 3 || mouse3.containsMouse) ? 1.0 : 0.65
                    scale: mouse3.containsMouse ? 1.12 : 1.0
                    Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
                    Behavior on scale { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }
                }

                MouseArea {
                    id: mouse3
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: window.activeTab = 3
                }

                ToolTip {
                    visible: mouse3.containsMouse
                    text: qsTr("Optimization")
                    delay: 250
                }
            }

            // Tab 1: Settings
            Item {
                width: 52
                height: 52
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    anchors.fill: parent
                    radius: Theme.radiusSmall
                    color: window.activeTab === 1 ? Theme.accentDim : "transparent"
                    border.color: window.activeTab === 1 ? Theme.accent : (mouse1.containsMouse ? Theme.borderHover : "transparent")
                    border.width: 1

                    Behavior on color { ColorAnimation { duration: Theme.animFast } }
                    Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
                }

                // Left active strip
                Rectangle {
                    width: 3
                    height: window.activeTab === 1 ? 20 : 0
                    radius: 1.5
                    color: Theme.accent
                    anchors.left: parent.left
                    anchors.leftMargin: -6
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on height { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                }

                Image {
                    source: "qrc:/MeguPackOptimizer/src/resources/settings.svg"
                    width: 20; height: 20
                    sourceSize.width: 20; sourceSize.height: 20
                    anchors.centerIn: parent
                    opacity: (window.activeTab === 1 || mouse1.containsMouse) ? 1.0 : 0.65
                    scale: mouse1.containsMouse ? 1.12 : 1.0
                    Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
                    Behavior on scale { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }
                }

                MouseArea {
                    id: mouse1
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: window.activeTab = 1
                }

                ToolTip {
                    visible: mouse1.containsMouse
                    text: qsTr("Settings")
                    delay: 250
                }
            }

            // Tab 2: Logs
            Item {
                width: 52
                height: 52
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    anchors.fill: parent
                    radius: Theme.radiusSmall
                    color: window.activeTab === 2 ? Theme.accentDim : "transparent"
                    border.color: window.activeTab === 2 ? Theme.accent : (mouse2.containsMouse ? Theme.borderHover : "transparent")
                    border.width: 1

                    Behavior on color { ColorAnimation { duration: Theme.animFast } }
                    Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
                }

                // Left active strip
                Rectangle {
                    width: 3
                    height: window.activeTab === 2 ? 20 : 0
                    radius: 1.5
                    color: Theme.accent
                    anchors.left: parent.left
                    anchors.leftMargin: -6
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on height { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                }

                Image {
                    source: "qrc:/MeguPackOptimizer/src/resources/terminal.svg"
                    width: 20; height: 20
                    sourceSize.width: 20; sourceSize.height: 20
                    anchors.centerIn: parent
                    opacity: (window.activeTab === 2 || mouse2.containsMouse) ? 1.0 : 0.65
                    scale: mouse2.containsMouse ? 1.12 : 1.0
                    Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
                    Behavior on scale { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }
                }

                MouseArea {
                    id: mouse2
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: window.activeTab = 2
                }

                ToolTip {
                    visible: mouse2.containsMouse
                    text: qsTr("Real-Time Logs")
                    delay: 250
                }
            }
        }
    }

    // 2. Main Content Viewport Area (Floating Glass Pane on the right)
    Rectangle {
        id: mainViewport
        anchors.left: sidebar.right
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: 12
        radius: Theme.radiusNormal
        color: Theme.panelBg
        border.color: Theme.border
        border.width: 1

        Behavior on color { ColorAnimation { duration: Theme.animNormal } }
        Behavior on border.color { ColorAnimation { duration: Theme.animNormal } }

        // Specular reflection gradient
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            z: -1
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#1AFFFFFF" }
                GradientStop { position: 0.25; color: "transparent" }
            }
        }

        // Viewport Header Bar
        Item {
            id: viewHeader
            width: parent.width
            height: 48
            anchors.top: parent.top

            // High-Tech view title tag
            Text {
                text: {
                    if (window.activeTab === 0) return qsTr("SYSTEM CORE STATUS");
                    if (window.activeTab === 3) return qsTr("SYSTEM OPTIMIZATION ENGINE");
                    if (window.activeTab === 1) return qsTr("SETTINGS & STYLES");
                    if (window.activeTab === 2) return qsTr("DIAGNOSTIC TELEMETRY LOGS");
                    return "";
                }
                color: Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.bold: true
                font.letterSpacing: 2.2
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.verticalCenter: parent.verticalCenter
                Behavior on color { ColorAnimation { duration: Theme.animNormal } }
            }

            // High-tech version tag
            Text {
                text: "v1.0.0 Stable"
                color: Theme.textMuted
                font.family: Theme.fontFamily
                font.pixelSize: 9
                font.bold: true
                font.letterSpacing: 1
                anchors.right: parent.right
                anchors.rightMargin: 160 // Leave space for window control buttons!
                anchors.verticalCenter: parent.verticalCenter
            }

            // Header bottom border
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: Theme.border
            }
        }

        // View container with smooth clipping
        Item {
            id: viewContainer
            anchors.top: viewHeader.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
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
                anchors.margins: 14
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

    // 3. Compact Floating Window Controls (Minimize, Maximize, Close)
    Row {
        id: windowControls
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 20
        anchors.topMargin: 20
        spacing: 4
        z: 100

        // Minimize Button
        Rectangle {
            width: 32
            height: 28
            radius: 6
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

        // Maximize Button
        Rectangle {
            width: 32
            height: 28
            radius: 6
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
                    x: 2
                    y: -2
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
            width: 32
            height: 28
            radius: 6
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
}
