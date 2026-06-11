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
    width: 940
    height: 620
    minimumWidth: 800
    minimumHeight: 560
    flags: Qt.Window | Qt.FramelessWindowHint
    color: "transparent"
    title: {
        var tabName = "";
        if (activeTab === 0) tabName = qsTr("Dashboard");
        else if (activeTab === 3) tabName = qsTr("Optimization");
        else if (activeTab === 1) tabName = qsTr("Settings");
        else if (activeTab === 2) tabName = qsTr("Real-Time Logs");
        return "Megu Pack Optimizer | " + tabName;
    }

    background: Rectangle {
        radius: window.visibility === Window.Maximized ? 0 : 12
        border.color: Theme.border
        border.width: 1
        
        color: Theme.currentTheme === "Blackout полностью черная" ? Theme.background : "transparent"
        gradient: Theme.currentTheme === "Blackout полностью черная" ? null : mainGradient
        
        Gradient {
            id: mainGradient
            GradientStop {
                position: 0.0
                color: Theme.gradientStart
                Behavior on color { ColorAnimation { duration: Theme.animNormal } }
            }
            GradientStop {
                position: 1.0
                color: Theme.gradientEnd
                Behavior on color { ColorAnimation { duration: Theme.animNormal } }
            }
        }
        
        Behavior on color { ColorAnimation { duration: Theme.animNormal } }
        Behavior on border.color { ColorAnimation { duration: Theme.animNormal } }
    }

    property int activeTab: 1
    property bool steamIsRunning: false
    property string steamActiveUserId: ""

    property int optimizationPercentage: {
        if (typeof optimizerBackend === "undefined" || !optimizerBackend) return 0;
        var count = 0;
        var total = 0;
        
        function checkOff(val) {
            total++;
            if (!val) count++;
        }
        function checkOn(val) {
            total++;
            if (val) count++;
        }
        
        // Bindings to all optimization toggles in the program
        checkOff(optimizerBackend.telemetryActive);
        checkOff(optimizerBackend.telemetryDiagTrackActive);
        checkOff(optimizerBackend.telemetryWapPushActive);
        checkOff(optimizerBackend.telemetryCeipActive);
        checkOff(optimizerBackend.telemetryWerActive);

        checkOff(optimizerBackend.defenderRegistryActive);
        checkOff(optimizerBackend.defenderCmdActive);
        checkOff(optimizerBackend.defenderServiceActive);

        checkOff(optimizerBackend.adsTailoredExperiencesActive);
        checkOff(optimizerBackend.adsAdvertisingIdActive);
        checkOff(optimizerBackend.adsSuggestedContentActive);
        checkOff(optimizerBackend.adsSettingsHomeActive);
        checkOff(optimizerBackend.adsSuggestedNotificationsActive);
        checkOff(optimizerBackend.adsLockScreenTipsActive);
        checkOff(optimizerBackend.adsWindowsTipsActive);
        checkOff(optimizerBackend.adsWelcomeExperienceActive);
        checkOff(optimizerBackend.adsFinishSetupActive);

        checkOff(optimizerBackend.privacyLocationActive);
        checkOff(optimizerBackend.privacyTelemetryActive);
        checkOff(optimizerBackend.privacyCeipActive);
        checkOff(optimizerBackend.privacyAppsTelemetryActive);
        checkOff(optimizerBackend.privacyAppLaunchesActive);
        checkOff(optimizerBackend.privacyImproveInkingActive);
        checkOff(optimizerBackend.privacyPersonalizeInkingActive);
        checkOff(optimizerBackend.privacyErrorReportingActive);
        checkOff(optimizerBackend.privacyLockScreenCameraActive);
        checkOff(optimizerBackend.privacyOnlineSpeechActive);

        checkOn(optimizerBackend.classicContextMenuActive);
        checkOff(optimizerBackend.shortcutArrowsActive);
        checkOff(optimizerBackend.hibernationActive);
        checkOff(optimizerBackend.gamingOverlayActive);
        checkOff(optimizerBackend.mouseAccelerationActive);
        checkOn(optimizerBackend.gameModeActive);
        checkOff(optimizerBackend.discordOverlayActive);
        checkOff(optimizerBackend.superuserUcpdActive);
        checkOff(optimizerBackend.startMenuWebResults);
        checkOff(optimizerBackend.startMenuAutoinstall);
        checkOff(optimizerBackend.startMenuAccountNotifications);
        checkOff(optimizerBackend.desktopShowWidgets);
        checkOff(optimizerBackend.desktopAeroShake);
        checkOff(optimizerBackend.coinstallersActive);
        checkOff(optimizerBackend.driverUpdatesEnabled);
        checkOff(optimizerBackend.appUpdatesEnabled);
        checkOn(optimizerBackend.storageSenseActive);
        
        return total > 0 ? Math.round((count / total) * 100) : 0;
    }

    property int optimizationPercentageBeforeRun: 0
    property int optimizationDelta: 0
    property bool showDelta: false


    onVisibilityChanged: {
        if (visibility !== Window.Maximized) {
            headerDragArea.isRestoring = false;
        }
    }

    Timer {
        id: globalSteamRunningTimer
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var isRunning = optimizerBackend.isSteamRunning();
            var activeUser = optimizerBackend.getSteamActiveUserId();
            if (isRunning !== steamIsRunning || activeUser !== steamActiveUserId) {
                steamIsRunning = isRunning;
                steamActiveUserId = activeUser;
                optimizerBackend.loadSystemStates();
            }
        }
    }

    // Top Header Control Bar
    header: Item {
        id: header
        width: parent.width
        height: 88

        Item {
            id: headerContent
            anchors.fill: parent
            anchors.leftMargin: 0
            anchors.rightMargin: 0
            anchors.topMargin: 0
            anchors.bottomMargin: 0

            // Custom drag handler to move window when dragging empty areas of header
            MouseArea {
                id: headerDragArea
                anchors.fill: parent
                
                onPressed: {
                    if (window.visibility !== Window.Maximized) {
                        window.startSystemMove();
                    }
                }
                
                onPositionChanged: (mouse) => {
                    if (window.visibility === Window.Maximized) {
                        var dragX = mouse.x;
                        var dragY = mouse.y;
                        window.showNormal();
                        window.x = dragX - window.width / 2;
                        window.y = dragY - 20;
                        window.startSystemMove();
                    }
                }
                
                onDoubleClicked: {
                    if (window.visibility === Window.Maximized) {
                        window.showNormal();
                    } else {
                        window.showMaximized();
                    }
                }
            }

        // Left Island (Brand Logo + Real-Time Logs button)
        Rectangle {
            id: leftIsland
            height: 72
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.top: parent.top
            anchors.topMargin: leftIslandHover.containsMouse ? 7 : 8
            width: leftIslandRow.width + 24
            color: Theme.panelBg
            border.color: leftIslandHover.containsMouse ? Theme.borderHover : Theme.border
            border.width: 1
            radius: 10

            Behavior on anchors.topMargin { NumberAnimation { duration: Theme.animFast } }
            Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: 0
                verticalOffset: leftIslandHover.containsMouse ? 8 : 5
                radius: leftIslandHover.containsMouse ? 14 : 10
                color: leftIslandHover.containsMouse ? "#C0000000" : "#80000000"
                Behavior on verticalOffset { NumberAnimation { duration: Theme.animFast } }
                Behavior on radius { NumberAnimation { duration: Theme.animFast } }
                Behavior on color { ColorAnimation { duration: Theme.animFast } }
            }

            MouseArea {
                id: leftIslandHover
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.NoButton
                propagateComposedEvents: true
            }

            Row {
                id: leftIslandRow
                anchors.centerIn: parent
                spacing: 12

                // Premium transparent minimalist logo
                Item {
                    width: 32
                    height: 32
                    anchors.verticalCenter: parent.verticalCenter
                    
                    // Soft glowing backing for the logo
                    Rectangle {
                        anchors.fill: parent
                        radius: 6
                        color: Theme.accent
                        opacity: 0.12
                        scale: 1.05
                    }
                    
                    Image {
                        source: "qrc:/MeguPackOptimizer/src/resources/megu_logo_transparent.png"
                        anchors.fill: parent
                        anchors.margins: 1
                        smooth: true
                        mipmap: true
                        fillMode: Image.PreserveAspectFit
                    }
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 0
                    
                    Text {
                        text: "MEGU PACK"
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                        font.letterSpacing: 1.0
                    }
                    
                    Text {
                        text: "OPTIMIZER"
                        color: Theme.accent
                        font.family: Theme.fontFamily
                        font.pixelSize: 9
                        font.bold: true
                        font.letterSpacing: 2.0
                    }
                }

                // Vertical Divider 1
                Rectangle {
                    width: 1
                    height: 16
                    color: Theme.border
                    anchors.verticalCenter: parent.verticalCenter
                    opacity: 0.5
                }

                // Optimization Speedometer Widget
                Row {
                    spacing: 8
                    anchors.verticalCenter: parent.verticalCenter

                    Item {
                        id: speedometerCircle
                        width: 40
                        height: 40
                        anchors.verticalCenter: parent.verticalCenter

                        property real percentage: window.optimizationPercentage
                        property real animPercentage: 0
                        
                        Behavior on animPercentage {
                            NumberAnimation {
                                duration: Theme.animSlow
                                easing.type: Easing.OutCubic
                            }
                        }
                        
                        onPercentageChanged: {
                            animPercentage = percentage;
                        }
                        
                        Component.onCompleted: {
                            animPercentage = percentage;
                        }

                        property color levelColor: {
                            if (percentage < 45) return Theme.error;
                            if (percentage < 75) return Theme.warning;
                            return Theme.success;
                        }

                        // Background track
                        Shape {
                            anchors.fill: parent
                            smooth: true
                            ShapePath {
                                fillColor: "transparent"
                                strokeColor: Theme.currentTheme === "Blackout полностью черная" ? "#222" : Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.25)
                                strokeWidth: 2
                                PathAngleArc {
                                    centerX: 20
                                    centerY: 20
                                    radiusX: 18
                                    radiusY: 18
                                    startAngle: 0
                                    sweepAngle: 360
                                }
                            }
                        }

                        // Active arc with glow
                        Shape {
                            anchors.fill: parent
                            smooth: true
                            layer.enabled: true
                            layer.effect: DropShadow {
                                transparentBorder: true
                                horizontalOffset: 0
                                verticalOffset: 0
                                radius: 4
                                color: speedometerCircle.levelColor
                            }
                            ShapePath {
                                fillColor: "transparent"
                                strokeColor: speedometerCircle.levelColor
                                strokeWidth: 2
                                capStyle: ShapePath.RoundCap
                                PathAngleArc {
                                    centerX: 20
                                    centerY: 20
                                    radiusX: 18
                                    radiusY: 18
                                    startAngle: -90
                                    sweepAngle: (speedometerCircle.animPercentage / 100) * 360
                                }
                            }
                        }

                        // Inner Percentage Text
                        Text {
                            text: Math.round(speedometerCircle.animPercentage) + "%"
                            color: speedometerCircle.levelColor
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.bold: true
                            anchors.centerIn: parent
                        }
                    }

                    // Delta badge (change from last optimization)
                    Rectangle {
                        visible: window.showDelta && window.optimizationDelta !== 0
                        height: 18
                        width: deltaTextTop.implicitWidth + 10
                        radius: 9
                        color: window.optimizationDelta > 0 ? Qt.rgba(Theme.success.r, Theme.success.g, Theme.success.b, 0.15) : Qt.rgba(Theme.error.r, Theme.error.g, Theme.error.b, 0.15)
                        border.color: window.optimizationDelta > 0 ? Qt.rgba(Theme.success.r, Theme.success.g, Theme.success.b, 0.3) : Qt.rgba(Theme.error.r, Theme.error.g, Theme.error.b, 0.3)
                        border.width: 1
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            id: deltaTextTop
                            anchors.centerIn: parent
                            text: (window.optimizationDelta > 0 ? "+" : "") + window.optimizationDelta + "%"
                            color: window.optimizationDelta > 0 ? Theme.success : Theme.error
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            font.bold: true
                        }
                    }

                    // Level status text
                    Text {
                        id: levelLabel
                        visible: window.width >= 900
                        text: {
                            var pct = window.optimizationPercentage;
                            if (pct < 45) return qsTr("Poor Level");
                            if (pct < 75) return qsTr("Average Level");
                            return qsTr("Optimal Level");
                        }
                        color: speedometerCircle.levelColor
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // Vertical Divider 2
                Rectangle {
                    width: 1
                    height: 16
                    color: Theme.border
                    anchors.verticalCenter: parent.verticalCenter
                    opacity: 0.5
                }

                // Circular Real-Time Logs button inside left island
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
                        radius: 16
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
        }

        // Center Island (Navigation Tab Container)
        Rectangle {
            id: centerIsland
            height: 72
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: centerIslandHover.containsMouse ? 7 : 8
            width: tabsRow.width + 24
            color: Theme.panelBg
            border.color: centerIslandHover.containsMouse ? Theme.borderHover : Theme.border
            border.width: 1
            radius: 10

            Behavior on anchors.topMargin { NumberAnimation { duration: Theme.animFast } }
            Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: 0
                verticalOffset: centerIslandHover.containsMouse ? 8 : 5
                radius: centerIslandHover.containsMouse ? 14 : 10
                color: centerIslandHover.containsMouse ? "#C0000000" : "#80000000"
                Behavior on verticalOffset { NumberAnimation { duration: Theme.animFast } }
                Behavior on radius { NumberAnimation { duration: Theme.animFast } }
                Behavior on color { ColorAnimation { duration: Theme.animFast } }
            }

            MouseArea {
                id: centerIslandHover
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.NoButton
                propagateComposedEvents: true
            }

            Row {
                id: tabsRow
                spacing: 12
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
                    height: 48
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
                    height: 48
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
                    height: 48
                }
            }
        }

        // Right Island (Version Label + Window Custom Controls)
        Rectangle {
            id: rightIsland
            height: 72
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.top: parent.top
            anchors.topMargin: rightIslandHover.containsMouse ? 7 : 8
            width: rightInfoRow.implicitWidth + 32 + windowControls.implicitWidth
            color: Theme.panelBg
            border.color: rightIslandHover.containsMouse ? Theme.borderHover : Theme.border
            border.width: 1
            radius: 10
            clip: true
            z: 10

            Behavior on anchors.topMargin { NumberAnimation { duration: Theme.animFast } }
            Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: 0
                verticalOffset: rightIslandHover.containsMouse ? 8 : 5
                radius: rightIslandHover.containsMouse ? 14 : 10
                color: rightIslandHover.containsMouse ? "#C0000000" : "#80000000"
                Behavior on verticalOffset { NumberAnimation { duration: Theme.animFast } }
                Behavior on radius { NumberAnimation { duration: Theme.animFast } }
                Behavior on color { ColorAnimation { duration: Theme.animFast } }
            }

            MouseArea {
                id: rightIslandHover
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.NoButton
                propagateComposedEvents: true
            }

            Row {
                id: rightInfoRow
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12
                
                Text {
                    text: qsTr("v1.0.0 Stable")
                    color: Theme.textMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    width: 1
                    height: 16
                    color: Theme.border
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Custom Window Control Buttons (Minimize, Maximize, Close)
            Row {
                id: windowControls
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                spacing: 0
                
                // Minimize Button
                Rectangle {
                    width: 38
                    height: 72
                    color: minMouse.containsMouse ? (Theme.currentTheme === "Белоснежная" || Theme.currentTheme === "Розовая" ? "#0F000000" : "#1AFFFFFF") : "transparent"
                    
                    Rectangle {
                        width: 10
                        height: 1
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
                    width: 38
                    height: 72
                    color: maxMouse.containsMouse ? (Theme.currentTheme === "Белоснежная" || Theme.currentTheme === "Розовая" ? "#0F000000" : "#1AFFFFFF") : "transparent"
                    
                    // Maximize Icon (when not maximized)
                    Rectangle {
                        visible: window.visibility !== Window.Maximized
                        width: 10
                        height: 10
                        color: "transparent"
                        border.color: Theme.textPrimary
                        border.width: 1
                        radius: 1.5
                        anchors.centerIn: parent
                    }

                    // Restore Icon (when maximized)
                    Item {
                        visible: window.visibility === Window.Maximized
                        width: 12
                        height: 12
                        anchors.centerIn: parent

                        // Background rounded L-shape representing the background square
                        Shape {
                            anchors.fill: parent
                            smooth: true
                            ShapePath {
                                fillColor: "transparent"
                                strokeColor: Theme.textPrimary
                                strokeWidth: 1
                                capStyle: ShapePath.FlatCap
                                
                                PathMove { x: 4.5; y: 4.5 }
                                PathLine { x: 4.5; y: 1.5 }
                                PathArc {
                                    x: 5.5; y: 0.5
                                    radiusX: 1
                                    radiusY: 1
                                    direction: PathArc.Clockwise
                                }
                                PathLine { x: 10.5; y: 0.5 }
                                PathArc {
                                    x: 11.5; y: 1.5
                                    radiusX: 1
                                    radiusY: 1
                                    direction: PathArc.Clockwise
                                }
                                PathLine { x: 11.5; y: 6.5 }
                                PathArc {
                                    x: 10.5; y: 7.5
                                    radiusX: 1
                                    radiusY: 1
                                    direction: PathArc.Clockwise
                                }
                                PathLine { x: 7.5; y: 7.5 }
                            }
                        }

                        // Foreground square with a solid background color to mask the background square's lines
                        Rectangle {
                            width: 8
                            height: 8
                            x: 0
                            y: 4
                            color: {
                                if (Theme.currentTheme === "Белоснежная" || Theme.currentTheme === "Розовая") {
                                    return maxMouse.containsMouse ? "#F0F0F0" : "#FFFFFF"
                                } else if (Theme.currentTheme === "Blackout полностью черная") {
                                    return maxMouse.containsMouse ? "#1A1A1A" : "#080808"
                                } else {
                                    return maxMouse.containsMouse ? "#252629" : "#0D0E12"
                                }
                            }
                            border.color: Theme.textPrimary
                            border.width: 1
                            radius: 1.5
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
                    width: 42
                    height: 72
                    color: closeMouse.containsMouse ? "#E81123" : "transparent"
                    
                    Item {
                        width: 10
                        height: 10
                        anchors.centerIn: parent
                        opacity: closeMouse.containsMouse ? 1.0 : 0.8
                        Behavior on opacity { NumberAnimation { duration: 100 } }
                        
                        Rectangle {
                            width: 12
                            height: 1
                            color: closeMouse.containsMouse ? "#FFFFFF" : Theme.textPrimary
                            rotation: 45
                            transformOrigin: Item.Center
                            anchors.centerIn: parent
                            antialiasing: true
                        }
                        Rectangle {
                            width: 12
                            height: 1
                            color: closeMouse.containsMouse ? "#FFFFFF" : Theme.textPrimary
                            rotation: -45
                            transformOrigin: Item.Center
                            anchors.centerIn: parent
                            antialiasing: true
                        }
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
        }
    }

    // Preloaded views container for buttery-smooth cross-fade tab switching
    Item {
        id: viewContainer
        anchors.fill: parent
        clip: true

        DashboardView {
            id: dashboardView
            x: 0
            y: 0
            width: visible ? parent.width : 800
            height: visible ? parent.height : 560
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
            x: 0
            y: 0
            width: visible ? parent.width : 800
            height: visible ? parent.height : 560
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
            x: 0
            y: 0
            width: visible ? parent.width : 800
            height: visible ? parent.height : 560
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
            x: 24
            y: 128
            width: visible ? (parent.width - 48) : 752
            height: visible ? (parent.height - 128 - 24) : 408
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
        x: 0
        y: parent.height - 1
        width: parent.width
        height: implicitHeight
        padding: 6
        
        enter: Transition {
            ParallelAnimation {
                NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 150; easing.type: Easing.OutQuad }
                NumberAnimation { property: "y"; from: tab3.height - 5; to: tab3.height - 1; duration: 150; easing.type: Easing.OutQuad }
            }
        }
        
        exit: Transition {
            ParallelAnimation {
                NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 120; easing.type: Easing.OutQuad }
                NumberAnimation { property: "y"; to: tab3.height - 5; duration: 120; easing.type: Easing.OutQuad }
            }
        }        
        background: Rectangle {
            color: Theme.panelBg
            border.color: Theme.border
            border.width: 1
            radius: 8
            
            // Seamless merge overlay for top corners and top border when open
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.leftMargin: 1
                anchors.rightMargin: 1
                anchors.topMargin: -1
                height: 8
                color: Theme.panelBg
            }
            
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
                text: qsTr("Video Games")
                iconSource: "qrc:/MeguPackOptimizer/src/resources/play.svg"
                accented: window.activeTab === 3 && optimizationView.currentSection === "games"
                flat: !accented
                onClicked: {
                    window.activeTab = 3;
                    optimizationView.currentSection = "games";
                    optDropdown.close();
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.border
                opacity: 0.6
            }

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

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.border
                opacity: 0.6
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

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.border
                opacity: 0.6
            }

            MeguButton {
                width: parent.width
                height: 30
                text: qsTr("Customization")
                iconSource: "qrc:/MeguPackOptimizer/src/resources/settings.svg"
                accented: window.activeTab === 3 && optimizationView.currentSection === "customization"
                flat: !accented
                onClicked: {
                    window.activeTab = 3;
                    optimizationView.currentSection = "customization";
                    optDropdown.close();
                }
            }
        }
    }
}
