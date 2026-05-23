import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeguPackOptimizer 1.0
import "../components"

Item {
    id: root
    anchors.fill: parent

    // Premium reactive entry transition (runs butter-smooth on every tab switch!)
    property bool isActive: opacity > 0.1
    property real yTranslation: isActive ? 0 : 15

    transform: Translate {
        y: root.yTranslation
    }

    Behavior on yTranslation {
        NumberAnimation {
            duration: Theme.animNormal
            easing.type: Easing.OutCubic
        }
    }

    // Tri-State derived logic for main switch based on live states in backend
    property bool allChecked: {
        if (!optimizerBackend.winSearchActive) return false;
        if (!optimizerBackend.driveStates || !optimizerBackend.driveStates["C:"]) return false;
        var drives = optimizerBackend.fixedDrives;
        for (var i = 0; i < drives.length; i++) {
            var letter = drives[i];
            if (!optimizerBackend.driveStates[letter]) return false;
        }
        return true;
    }
    property bool allUnchecked: {
        if (optimizerBackend.winSearchActive) return false;
        if (!optimizerBackend.driveStates || optimizerBackend.driveStates["C:"]) return false;
        var drives = optimizerBackend.fixedDrives;
        for (var i = 0; i < drives.length; i++) {
            var letter = drives[i];
            if (optimizerBackend.driveStates[letter]) return false;
        }
        return true;
    }
    property bool mainChecked: allChecked
    property bool mainIndeterminate: !allChecked && !allUnchecked

    // Reactive computation of changes between current live states and original states
    property bool hasChanges: {
        if (optimizerBackend.winSearchActive !== optimizerBackend.originalWinSearchActive) return true;
        if (optimizerBackend.hibernationActive !== optimizerBackend.originalHibernationActive) return true;
        if (optimizerBackend.gamingOverlayActive !== optimizerBackend.originalGamingOverlayActive) return true;
        if (!optimizerBackend.driveStates || !optimizerBackend.originalDriveStates) return false;
        var keys = Object.keys(optimizerBackend.driveStates);
        for (var i = 0; i < keys.length; i++) {
            var key = keys[i];
            if (optimizerBackend.driveStates[key] !== optimizerBackend.originalDriveStates[key]) return true;
        }
        return false;
    }

    // Active sidebar state
    property string activeDrawer: ""
    property bool sidebarOpen: activeDrawer !== ""

    // ListModel for live optimization steps
    ListModel {
        id: stepLogModel
    }

    Connections {
        target: optimizerBackend
        function onSystemStepReported(msg, type) {
            stepLogModel.append({ "message": msg, "type": type });
        }
    }

    function toggleMain() {
        var targetVal = (mainIndeterminate || !mainChecked);
        optimizerBackend.winSearchActive = targetVal;
        
        var newStates = {};
        newStates["C:"] = targetVal;
        for (var i = 0; i < optimizerBackend.fixedDrives.length; i++) {
            var letter = optimizerBackend.fixedDrives[i];
            newStates[letter] = targetVal;
        }
        optimizerBackend.driveStates = newStates;
    }

    ScrollView {
        id: mainScroll
        anchors.top: parent.top
        anchors.bottom: bottomActionBar.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 24
        clip: true
        contentHeight: mainColumn.implicitHeight

        Column {
            id: mainColumn
            width: mainScroll.width - 12
            spacing: 24

            Text {
                text: qsTr("SYSTEM OPTIMIZATION")
                color: Theme.yellowAccent
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.bold: true
                font.letterSpacing: 1.5
            }

            // 1. DRIVES INDEXING CATEGORY
            Column {
                width: parent.width
                spacing: 8

                Text {
                    text: qsTr("DRIVES & INDEXING")
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 1
                }

                AcrylicPanel {
                    id: indexingPanel
                    width: parent.width
                    height: 72
                    clip: true

                    Item {
                        anchors.fill: parent
                        anchors.margins: 16

                        // Collapsed Header area (Height: 40)
                        Item {
                            width: parent.width
                            height: 40
                            anchors.verticalCenter: parent.verticalCenter

                            Row {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 12

                                Image {
                                    source: "qrc:/MeguPackOptimizer/src/resources/storage.svg"
                                    width: 28
                                    height: 28
                                    sourceSize.width: 28
                                    sourceSize.height: 28
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 2

                                    Text {
                                        text: qsTr("File Indexing")
                                        color: Theme.textPrimary
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 13
                                        font.bold: true
                                    }

                                    Text {
                                        text: qsTr("Controls file search indexing services and drive index properties.")
                                        color: Theme.textMuted
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 10
                                    }
                                }
                            }

                            Row {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 16

                                MeguSwitch {
                                    id: mainIndexingSwitch
                                    checked: root.mainChecked
                                    indeterminate: root.mainIndeterminate
                                    anchors.verticalCenter: parent.verticalCenter
                                    onToggled: {
                                        root.toggleMain();
                                    }
                                }

                                // Arrow button that slides right on hover & opens sidebar drawer
                                Rectangle {
                                    width: 32
                                    height: 32
                                    radius: 16
                                    color: arrowMouseArea.containsMouse ? Theme.accentDim : "transparent"
                                    border.color: arrowMouseArea.containsMouse ? Theme.accent : Theme.border
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter

                                    Behavior on color { ColorAnimation { duration: Theme.animFast } }
                                    Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                                    Image {
                                        source: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"
                                        width: 14
                                        height: 14
                                        sourceSize.width: 14
                                        sourceSize.height: 14
                                        anchors.centerIn: parent

                                        // Premium sliding micro-animation
                                        x: arrowMouseArea.containsMouse ? (parent.width/2 - 5) : (parent.width/2 - 7)
                                        Behavior on x { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }
                                    }

                                    MouseArea {
                                        id: arrowMouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            root.activeDrawer = "indexing";
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // 2. LATENCY & MOUSE TWEAKS
            Column {
                width: parent.width
                spacing: 8

                Text {
                    text: qsTr("LATENCY & MOUSE TWEAKS")
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 1
                }

                // Xbox app Panel
                AcrylicPanel {
                    id: xboxPanel
                    width: parent.width
                    height: 72
                    clip: true

                    Item {
                        anchors.fill: parent
                        anchors.margins: 16

                        // Collapsed Header area (Height: 40)
                        Item {
                            width: parent.width
                            height: 40
                            anchors.verticalCenter: parent.verticalCenter

                            Row {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 12

                                Image {
                                    source: "qrc:/MeguPackOptimizer/src/resources/settings.svg"
                                    width: 28
                                    height: 28
                                    sourceSize.width: 28
                                    sourceSize.height: 28
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 2

                                    Text {
                                        text: qsTr("Xbox App & Game Bar")
                                        color: Theme.textPrimary
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 13
                                        font.bold: true
                                    }

                                    Text {
                                        text: qsTr("Completely remove all Xbox overlays, TCUI, and game bar apps to optimize mouse input latency.")
                                        color: Theme.textMuted
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 10
                                    }
                                }
                            }

                            Row {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 16

                                // Status text pill: Installed / Removed
                                Rectangle {
                                    height: 24
                                    width: 80
                                    radius: 12
                                    color: optimizerBackend.xboxInstalled ? "#1A2536" : Theme.accentDim
                                    border.color: optimizerBackend.xboxInstalled ? "#2B3F5C" : Theme.accent
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        text: optimizerBackend.xboxInstalled ? qsTr("Installed") : qsTr("Removed")
                                        color: optimizerBackend.xboxInstalled ? Theme.textSecondary : Theme.accent
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 10
                                        font.bold: true
                                        anchors.centerIn: parent
                                    }
                                }

                                // Arrow button
                                Rectangle {
                                    width: 32
                                    height: 32
                                    radius: 16
                                    color: xboxArrowMouseArea.containsMouse ? Theme.accentDim : "transparent"
                                    border.color: xboxArrowMouseArea.containsMouse ? Theme.accent : Theme.border
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter

                                    Behavior on color { ColorAnimation { duration: Theme.animFast } }
                                    Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                                    Image {
                                        source: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"
                                        width: 14
                                        height: 14
                                        sourceSize.width: 14
                                        sourceSize.height: 14
                                        anchors.centerIn: parent

                                        // Premium sliding micro-animation
                                        x: xboxArrowMouseArea.containsMouse ? (parent.width/2 - 5) : (parent.width/2 - 7)
                                        Behavior on x { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }
                                    }

                                    MouseArea {
                                        id: xboxArrowMouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            root.activeDrawer = "xbox";
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // MPO Panel
                AcrylicPanel {
                    id: mpoPanel
                    width: parent.width
                    height: 72
                    clip: true

                    Item {
                        anchors.fill: parent
                        anchors.margins: 16

                        // Collapsed Header area (Height: 40)
                        Item {
                            width: parent.width
                            height: 40
                            anchors.verticalCenter: parent.verticalCenter

                            Row {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 12

                                Image {
                                    source: "qrc:/MeguPackOptimizer/src/resources/monitor.svg"
                                    width: 28
                                    height: 28
                                    sourceSize.width: 28
                                    sourceSize.height: 28
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 2

                                    Text {
                                        text: qsTr("Multi-Plane Overlay (MPO)")
                                        color: Theme.textPrimary
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 13
                                        font.bold: true
                                    }

                                    Text {
                                        text: qsTr("Configure DWM multi-plane overlay modes to optimize latency and eliminate game stuttering.")
                                        color: Theme.textMuted
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 10
                                    }
                                }
                            }

                            Row {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 16

                                // Current Value indicator pill
                                Rectangle {
                                    height: 24
                                    width: {
                                        if (optimizerBackend.mpoValue === 0) return 90;
                                        if (optimizerBackend.mpoValue === 5) return 100;
                                        return 85;
                                    }
                                    radius: 12
                                    color: (optimizerBackend.mpoValue === 5) ? Theme.accentDim : "#1A2536"
                                    border.color: (optimizerBackend.mpoValue === 5) ? Theme.accent : "#2B3F5C"
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        text: {
                                            if (optimizerBackend.mpoValue === 5) return qsTr("Disabled (5)");
                                            if (optimizerBackend.mpoValue === 0) return qsTr("Default (0)");
                                            return qsTr("Mode %1").arg(optimizerBackend.mpoValue);
                                        }
                                        color: (optimizerBackend.mpoValue === 5) ? Theme.accent : Theme.textSecondary
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 10
                                        font.bold: true
                                        anchors.centerIn: parent
                                    }
                                }

                                // Arrow button
                                Rectangle {
                                    width: 32
                                    height: 32
                                    radius: 16
                                    color: mpoArrowMouseArea.containsMouse ? Theme.accentDim : "transparent"
                                    border.color: mpoArrowMouseArea.containsMouse ? Theme.accent : Theme.border
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter

                                    Behavior on color { ColorAnimation { duration: Theme.animFast } }
                                    Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                                    Image {
                                        source: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"
                                        width: 14
                                        height: 14
                                        sourceSize.width: 14
                                        sourceSize.height: 14
                                        anchors.centerIn: parent

                                        // Premium sliding micro-animation
                                        x: mpoArrowMouseArea.containsMouse ? (parent.width/2 - 5) : (parent.width/2 - 7)
                                        Behavior on x { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }
                                    }

                                    MouseArea {
                                        id: mpoArrowMouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            root.activeDrawer = "mpo";
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // 3. HIBERNATION CATEGORY
            Column {
                width: parent.width
                spacing: 8

                Text {
                    text: qsTr("POWER & STORAGE")
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 1
                }

                AcrylicPanel {
                    width: parent.width
                    height: 72

                    Item {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16

                        Row {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 12

                            Image {
                                source: "qrc:/MeguPackOptimizer/src/resources/cpu.svg"
                                width: 28
                                height: 28
                                sourceSize.width: 28
                                sourceSize.height: 28
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 2

                                Text {
                                    text: qsTr("System Hibernation")
                                    color: Theme.textPrimary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 13
                                    font.bold: true
                                }

                                Text {
                                    text: qsTr("Enable or disable Windows hibernation mode to free up disk space.")
                                    color: Theme.textMuted
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 10
                                }
                            }
                        }

                        MeguSwitch {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            checked: optimizerBackend.hibernationActive
                            onToggled: {
                                optimizerBackend.hibernationActive = isChecked;
                            }
                        }
                    }
                }
            }
        }
    }

    // Bottom Action Bar
    Item {
        id: bottomActionBar
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 80

        MeguButton {
            id: optimizeButton
            text: qsTr("Optimize")
            iconSource: "qrc:/MeguPackOptimizer/src/resources/play.svg"
            accented: true
            anchors.centerIn: parent
            width: 180
            height: 40
            enabled: !optimizerBackend.isOptimizingSystem && root.hasChanges
            onClicked: {
                stepLogModel.clear();
                optimizerBackend.startSystemOptimization();
            }
        }
    }

    // Backdrop for sidebar
    Rectangle {
        id: sidebarBackdrop
        anchors.fill: parent
        color: "#000000"
        opacity: root.sidebarOpen ? 0.5 : 0.0
        visible: opacity > 0.0
        z: 150
        
        Behavior on opacity {
            NumberAnimation { duration: Theme.animNormal }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                root.activeDrawer = "";
            }
        }
    }

    // Sliding Sidebar Drawer for Options
    Rectangle {
        id: optionsSidebar
        width: 320
        height: parent.height
        anchors.right: parent.right
        anchors.rightMargin: root.sidebarOpen ? 0 : -width
        color: Theme.sidebarBg
        border.color: Theme.border
        border.width: 1
        z: 160

        Behavior on color { ColorAnimation { duration: Theme.animNormal } }
        Behavior on border.color { ColorAnimation { duration: Theme.animNormal } }
        Behavior on anchors.rightMargin {
            NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
        }

        // Left highlight separator border
        Rectangle {
            width: 1
            height: parent.height
            anchors.left: parent.left
            color: Theme.border
            Behavior on color { ColorAnimation { duration: Theme.animNormal } }
        }

        Item {
            anchors.fill: parent
            anchors.margins: 20
            clip: true

            Column {
                anchors.fill: parent
                spacing: 20

                // Header with Title & Close button
                Item {
                    width: parent.width
                    height: 30

                    Text {
                        text: {
                            if (root.activeDrawer === "indexing") return qsTr("INDEXING OPTIONS");
                            if (root.activeDrawer === "xbox") return qsTr("XBOX APP & GAME BAR");
                            if (root.activeDrawer === "mpo") return qsTr("MPO LATENCY TWEAK");
                            return "";
                        }
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        font.bold: true
                        font.letterSpacing: 1.5
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    // Close Button
                    Rectangle {
                        width: 24
                        height: 24
                        radius: 12
                        color: closeMouseArea.containsMouse ? Theme.accentDim : "transparent"
                        border.color: closeMouseArea.containsMouse ? Theme.accent : "transparent"
                        border.width: 1
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter

                        Image {
                            source: "qrc:/MeguPackOptimizer/src/resources/close.svg"
                            width: 10
                            height: 10
                            sourceSize.width: 10
                            sourceSize.height: 10
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            id: closeMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.activeDrawer = "";
                            }
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Theme.border
                }

                // Dynamic options content
                Item {
                    width: parent.width
                    height: parent.height - 60
                    clip: true

                    // 1. Indexing Options Content
                    Column {
                        width: parent.width
                        spacing: 20
                        visible: root.activeDrawer === "indexing"

                        // Search service
                        Row {
                            width: parent.width
                            spacing: 12
                            MeguSwitch {
                                text: qsTr("Windows Search service")
                                checked: optimizerBackend.winSearchActive
                                onToggled: { optimizerBackend.winSearchActive = isChecked; }
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: qsTr("Show Path")
                                color: sidebarSearchMouse.containsMouse ? Theme.accentLight : Theme.accent
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                font.bold: true
                                font.underline: true
                                anchors.verticalCenter: parent.verticalCenter
                                MouseArea {
                                    id: sidebarSearchMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: { optimizerBackend.showPath("Windows Search service"); }
                                }
                            }
                        }

                        // Drive C
                        Row {
                            width: parent.width
                            spacing: 12
                            MeguSwitch {
                                text: qsTr("Drive C: indexing")
                                checked: !!optimizerBackend.driveStates["C:"]
                                onToggled: {
                                    var states = optimizerBackend.driveStates;
                                    states["C:"] = isChecked;
                                    optimizerBackend.driveStates = states;
                                }
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: qsTr("Show Path")
                                color: sidebarCMouse.containsMouse ? Theme.accentLight : Theme.accent
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                font.bold: true
                                font.underline: true
                                anchors.verticalCenter: parent.verticalCenter
                                MouseArea {
                                    id: sidebarCMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: { optimizerBackend.showPath("C:"); }
                                }
                            }
                        }

                        // Fixed drives repeater
                        Repeater {
                            model: optimizerBackend.fixedDrives
                            delegate: Row {
                                width: parent.width
                                spacing: 12
                                MeguSwitch {
                                    text: qsTr("Drive %1 indexing").arg(modelData)
                                    checked: !!optimizerBackend.driveStates[modelData]
                                    onToggled: {
                                        var states = optimizerBackend.driveStates;
                                        states[modelData] = isChecked;
                                        optimizerBackend.driveStates = states;
                                    }
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    text: qsTr("Show Path")
                                    color: sidebarDriveMouse.containsMouse ? Theme.accentLight : Theme.accent
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    font.bold: true
                                    font.underline: true
                                    anchors.verticalCenter: parent.verticalCenter
                                    MouseArea {
                                        id: sidebarDriveMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: { optimizerBackend.showPath(modelData); }
                                    }
                                }
                            }
                        }
                    }

                    // 2. Xbox Options Content
                    Column {
                        width: parent.width
                        spacing: 20
                        visible: root.activeDrawer === "xbox"

                        Column {
                            width: parent.width
                            spacing: 8
                            Text {
                                text: qsTr("Xbox App Integration")
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                font.bold: true
                            }
                            Text {
                                text: qsTr("Purge the entire Xbox package suite for maximum performance, or restore it back via Microsoft Store/PowerShell.")
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                                wrapMode: Text.Wrap
                                width: parent.width
                            }
                        }

                        Row {
                            spacing: 12
                            width: parent.width
                            MeguButton {
                                text: optimizerBackend.xboxInstalled ? qsTr("Remove") : qsTr("Removed")
                                iconSource: optimizerBackend.xboxInstalled ? "qrc:/MeguPackOptimizer/src/resources/close.svg" : "qrc:/MeguPackOptimizer/src/resources/check.svg"
                                accented: optimizerBackend.xboxInstalled
                                enabled: optimizerBackend.xboxInstalled && !optimizerBackend.isOptimizingSystem
                                width: 130
                                height: 36
                                onClicked: {
                                    root.activeDrawer = "";
                                    optimizerBackend.removeXboxEntirely();
                                }
                            }
                            MeguButton {
                                text: !optimizerBackend.xboxInstalled ? qsTr("Restore") : qsTr("Restored")
                                iconSource: !optimizerBackend.xboxInstalled ? "qrc:/MeguPackOptimizer/src/resources/play.svg" : "qrc:/MeguPackOptimizer/src/resources/check.svg"
                                accented: !optimizerBackend.xboxInstalled
                                enabled: !optimizerBackend.xboxInstalled && !optimizerBackend.isOptimizingSystem
                                width: 130
                                height: 36
                                onClicked: {
                                    root.activeDrawer = "";
                                    optimizerBackend.restoreXboxEntirely();
                                }
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 1
                            color: Theme.border
                        }

                        Column {
                            width: parent.width
                            spacing: 8
                            MeguSwitch {
                                text: qsTr("Disable Game Bar Popup")
                                checked: !optimizerBackend.gamingOverlayActive
                                onToggled: {
                                    optimizerBackend.gamingOverlayActive = !isChecked;
                                }
                            }
                            Text {
                                text: qsTr("Neutralize ms-gamingoverlay triggers to stop 'You'll need a new app to open this link' errors when launching games.")
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 9
                                wrapMode: Text.Wrap
                                width: parent.width
                            }
                        }
                    }

                    // 3. MPO Options Content
                    Column {
                        width: parent.width
                        spacing: 20
                        visible: root.activeDrawer === "mpo"

                        Column {
                            width: parent.width
                            spacing: 8
                            Text {
                                text: qsTr("Multi-Plane Overlay Value")
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                font.bold: true
                            }
                            Text {
                                text: qsTr("Choose any MPO overlay flag from 0 to 5. 5 disables MPO completely to resolve driver bugs, while 0 restores Windows default.")
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                                wrapMode: Text.Wrap
                                width: parent.width
                            }
                        }

                        Column {
                            id: mpoContainer
                            spacing: 16
                            width: parent.width
                            
                            property int selectedVal: optimizerBackend.mpoValue

                            Grid {
                                columns: 2
                                spacing: 10
                                width: parent.width

                                // Row 0
                                Row {
                                    spacing: 6
                                    width: (parent.width - 10) / 2
                                    MeguButton {
                                        text: "0"
                                        width: parent.width - 24
                                        height: 32
                                        accented: mpoContainer.selectedVal === 0
                                        onClicked: mpoContainer.selectedVal = 0
                                    }
                                    Image {
                                        source: "qrc:/MeguPackOptimizer/src/resources/help.svg"
                                        width: 18
                                        height: 18
                                        sourceSize.width: 18
                                        sourceSize.height: 18
                                        anchors.verticalCenter: parent.verticalCenter
                                        opacity: helpMouse0.containsMouse ? 1.0 : 0.6
                                        Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
                                        MouseArea {
                                            id: helpMouse0
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: mpoContainer.selectedVal = 0
                                        }
                                        ToolTip {
                                            id: tip0
                                            visible: helpMouse0.containsMouse
                                            delay: 150
                                            timeout: 5000
                                            contentItem: Text {
                                                text: qsTr("0 (Default): Dynamic overlays are fully active. Lowest latency in windowed games, but causes micro-stuttering, Chromium browser lags, or black screen flickering on modern GPU drivers.")
                                                color: Theme.textPrimary
                                                font.family: Theme.fontFamily
                                                font.pixelSize: 10
                                                wrapMode: Text.Wrap
                                            }
                                            background: Rectangle {
                                                color: Theme.sidebarBg
                                                border.color: Theme.accent
                                                border.width: 1
                                                radius: 6
                                            }
                                        }
                                    }
                                }

                                // Row 1
                                Row {
                                    spacing: 6
                                    width: (parent.width - 10) / 2
                                    MeguButton {
                                        text: "1"
                                        width: parent.width - 24
                                        height: 32
                                        accented: mpoContainer.selectedVal === 1
                                        onClicked: mpoContainer.selectedVal = 1
                                    }
                                    Image {
                                        source: "qrc:/MeguPackOptimizer/src/resources/help.svg"
                                        width: 18
                                        height: 18
                                        sourceSize.width: 18
                                        sourceSize.height: 18
                                        anchors.verticalCenter: parent.verticalCenter
                                        opacity: helpMouse1.containsMouse ? 1.0 : 0.6
                                        Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
                                        MouseArea {
                                            id: helpMouse1
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: mpoContainer.selectedVal = 1
                                        }
                                        ToolTip {
                                            id: tip1
                                            visible: helpMouse1.containsMouse
                                            delay: 150
                                            timeout: 5000
                                            contentItem: Text {
                                                text: qsTr("1: Disables hardware MPO overlay promotion. Direct GPU rendering is bypassed, which can fix dual-monitor desktop stuttering.")
                                                color: Theme.textPrimary
                                                font.family: Theme.fontFamily
                                                font.pixelSize: 10
                                                wrapMode: Text.Wrap
                                            }
                                            background: Rectangle {
                                                color: Theme.sidebarBg
                                                border.color: Theme.accent
                                                border.width: 1
                                                radius: 6
                                            }
                                        }
                                    }
                                }

                                // Row 2
                                Row {
                                    spacing: 6
                                    width: (parent.width - 10) / 2
                                    MeguButton {
                                        text: "2"
                                        width: parent.width - 24
                                        height: 32
                                        accented: mpoContainer.selectedVal === 2
                                        onClicked: mpoContainer.selectedVal = 2
                                    }
                                    Image {
                                        source: "qrc:/MeguPackOptimizer/src/resources/help.svg"
                                        width: 18
                                        height: 18
                                        sourceSize.width: 18
                                        sourceSize.height: 18
                                        anchors.verticalCenter: parent.verticalCenter
                                        opacity: helpMouse2.containsMouse ? 1.0 : 0.6
                                        Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
                                        MouseArea {
                                            id: helpMouse2
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: mpoContainer.selectedVal = 2
                                        }
                                        ToolTip {
                                            id: tip2
                                            visible: helpMouse2.containsMouse
                                            delay: 150
                                            timeout: 5000
                                            contentItem: Text {
                                                text: qsTr("2: Disables software-emulated MPO overlays, forcing DWM to only allocate native hardware paths.")
                                                color: Theme.textPrimary
                                                font.family: Theme.fontFamily
                                                font.pixelSize: 10
                                                wrapMode: Text.Wrap
                                            }
                                            background: Rectangle {
                                                color: Theme.sidebarBg
                                                border.color: Theme.accent
                                                border.width: 1
                                                radius: 6
                                            }
                                        }
                                    }
                                }

                                // Row 3
                                Row {
                                    spacing: 6
                                    width: (parent.width - 10) / 2
                                    MeguButton {
                                        text: "3"
                                        width: parent.width - 24
                                        height: 32
                                        accented: mpoContainer.selectedVal === 3
                                        onClicked: mpoContainer.selectedVal = 3
                                    }
                                    Image {
                                        source: "qrc:/MeguPackOptimizer/src/resources/help.svg"
                                        width: 18
                                        height: 18
                                        sourceSize.width: 18
                                        sourceSize.height: 18
                                        anchors.verticalCenter: parent.verticalCenter
                                        opacity: helpMouse3.containsMouse ? 1.0 : 0.6
                                        Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
                                        MouseArea {
                                            id: helpMouse3
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: mpoContainer.selectedVal = 3
                                        }
                                        ToolTip {
                                            id: tip3
                                            visible: helpMouse3.containsMouse
                                            delay: 150
                                            timeout: 5000
                                            contentItem: Text {
                                                text: qsTr("3: Disables both hardware and software overlays. Forces legacy composition limits.")
                                                color: Theme.textPrimary
                                                font.family: Theme.fontFamily
                                                font.pixelSize: 10
                                                wrapMode: Text.Wrap
                                            }
                                            background: Rectangle {
                                                color: Theme.sidebarBg
                                                border.color: Theme.accent
                                                border.width: 1
                                                radius: 6
                                            }
                                        }
                                    }
                                }

                                // Row 4
                                Row {
                                    spacing: 6
                                    width: (parent.width - 10) / 2
                                    MeguButton {
                                        text: "4"
                                        width: parent.width - 24
                                        height: 32
                                        accented: mpoContainer.selectedVal === 4
                                        onClicked: mpoContainer.selectedVal = 4
                                    }
                                    Image {
                                        source: "qrc:/MeguPackOptimizer/src/resources/help.svg"
                                        width: 18
                                        height: 18
                                        sourceSize.width: 18
                                        sourceSize.height: 18
                                        anchors.verticalCenter: parent.verticalCenter
                                        opacity: helpMouse4.containsMouse ? 1.0 : 0.6
                                        Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
                                        MouseArea {
                                            id: helpMouse4
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: mpoContainer.selectedVal = 4
                                        }
                                        ToolTip {
                                            id: tip4
                                            visible: helpMouse4.containsMouse
                                            delay: 150
                                            timeout: 5000
                                            contentItem: Text {
                                                text: qsTr("4: Forces complete DWM composition. Promotes zero window structures to independent planes.")
                                                color: Theme.textPrimary
                                                font.family: Theme.fontFamily
                                                font.pixelSize: 10
                                                wrapMode: Text.Wrap
                                            }
                                            background: Rectangle {
                                                color: Theme.sidebarBg
                                                border.color: Theme.accent
                                                border.width: 1
                                                radius: 6
                                            }
                                        }
                                    }
                                }

                                // Row 5
                                Row {
                                    spacing: 6
                                    width: (parent.width - 10) / 2
                                    MeguButton {
                                        text: "5"
                                        width: parent.width - 24
                                        height: 32
                                        accented: mpoContainer.selectedVal === 5
                                        onClicked: mpoContainer.selectedVal = 5
                                    }
                                    Image {
                                        source: "qrc:/MeguPackOptimizer/src/resources/help.svg"
                                        width: 18
                                        height: 18
                                        sourceSize.width: 18
                                        sourceSize.height: 18
                                        anchors.verticalCenter: parent.verticalCenter
                                        opacity: helpMouse5.containsMouse ? 1.0 : 0.6
                                        Behavior on opacity { NumberAnimation { duration: Theme.animFast } }
                                        MouseArea {
                                            id: helpMouse5
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: mpoContainer.selectedVal = 5
                                        }
                                        ToolTip {
                                            id: tip5
                                            visible: helpMouse5.containsMouse
                                            delay: 150
                                            timeout: 5000
                                            contentItem: Text {
                                                text: qsTr("5 (Recommended): Completely disables all MPO modes. Official NVIDIA/AMD hotfix to eliminate stuttering, browser lag, and screen flickers.")
                                                color: Theme.textPrimary
                                                font.family: Theme.fontFamily
                                                font.pixelSize: 10
                                                wrapMode: Text.Wrap
                                            }
                                            background: Rectangle {
                                                color: Theme.sidebarBg
                                                border.color: Theme.accent
                                                border.width: 1
                                                radius: 6
                                            }
                                        }
                                    }
                                }
                            }

                            // Thin divider
                            Rectangle {
                                width: parent.width
                                height: 1
                                color: Theme.border
                            }

                            // Dynamic high-fidelity explanation text
                            Text {
                                text: {
                                    if (mpoContainer.selectedVal === 0) return qsTr("0 (Default): Dynamic overlays are fully active. Lowest latency in windowed games, but causes micro-stuttering, Chromium browser lags, or black screen flickering on modern GPU drivers.");
                                    if (mpoContainer.selectedVal === 1) return qsTr("1: Disables hardware MPO overlay promotion. Direct GPU rendering is bypassed, which can fix dual-monitor desktop stuttering.");
                                    if (mpoContainer.selectedVal === 2) return qsTr("2: Disables software-emulated MPO overlays, forcing DWM to only allocate native hardware paths.");
                                    if (mpoContainer.selectedVal === 3) return qsTr("3: Disables both hardware and software overlays. Forces legacy composition limits.");
                                    if (mpoContainer.selectedVal === 4) return qsTr("4: Forces complete DWM composition. Promotes zero window structures to independent planes.");
                                    if (mpoContainer.selectedVal === 5) return qsTr("5 (Recommended): Completely disables all MPO modes. Official NVIDIA/AMD hotfix to eliminate stuttering, browser lag, and screen flickers.");
                                    return "";
                                }
                                color: Theme.textSecondary
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                                wrapMode: Text.Wrap
                                width: parent.width
                            }

                            MeguButton {
                                text: qsTr("Apply")
                                iconSource: "qrc:/MeguPackOptimizer/src/resources/play.svg"
                                accented: true
                                enabled: mpoContainer.selectedVal !== optimizerBackend.mpoValue && !optimizerBackend.isOptimizingSystem
                                width: parent.width
                                height: 38
                                onClicked: {
                                    root.activeDrawer = "";
                                    stepLogModel.clear();
                                    optimizerBackend.applyMpoValue(mpoContainer.selectedVal);
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Progress Overlay Modal for System Optimization
    Rectangle {
        id: progressOverlay
        anchors.fill: parent
        color: "#E0000000"
        visible: optimizerBackend.isOptimizingSystem || showFinishedOverlay
        z: 200

        property bool showFinishedOverlay: false

        Connections {
            target: optimizerBackend
            function onIsOptimizingSystemChanged(val) {
                if (val) {
                    progressOverlay.showFinishedOverlay = true;
                }
            }
        }

        MouseArea {
            anchors.fill: parent
        }

        AcrylicPanel {
            width: 500
            height: 380
            anchors.centerIn: parent

            Item {
                anchors.fill: parent
                anchors.margins: 24

                Column {
                    anchors.fill: parent
                    spacing: 16

                    Text {
                        text: optimizerBackend.isOptimizingSystem ? qsTr("SYSTEM OPTIMIZATION IN PROGRESS") : qsTr("OPTIMIZATION COMPLETE")
                        color: Theme.yellowAccent
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        font.bold: true
                        font.letterSpacing: 1.5
                    }

                    MeguProgressBar {
                        width: parent.width
                        value: optimizerBackend.systemProgress
                        statusText: optimizerBackend.isOptimizingSystem ? qsTr("Applying disk indexing settings...") : qsTr("Finished system modifications.")
                    }

                    Rectangle {
                        width: parent.width
                        height: 180
                        color: "#080C14"
                        border.color: Theme.border
                        border.width: 1
                        radius: Theme.radiusSmall
                        clip: true

                        ListView {
                            id: logListView
                            anchors.fill: parent
                            anchors.margins: 10
                            model: stepLogModel
                            spacing: 4

                            delegate: Text {
                                width: logListView.width - 20
                                text: model.message
                                color: {
                                    if (model.type === "SUCCESS") return Theme.success;
                                    if (model.type === "ERROR") return Theme.error;
                                    if (model.type === "WARNING") return Theme.warning;
                                    return Theme.textSecondary;
                                }
                                font.family: "Consolas, monospace, " + Theme.fontFamily
                                font.pixelSize: 11
                                wrapMode: Text.Wrap
                            }

                            onCountChanged: {
                                Qt.callLater(logListView.positionViewAtEnd);
                            }
                        }
                    }

                    MeguButton {
                        text: qsTr("Close")
                        accented: true
                        anchors.horizontalCenter: parent.horizontalCenter
                        enabled: !optimizerBackend.isOptimizingSystem
                        width: 100
                        onClicked: {
                            progressOverlay.showFinishedOverlay = false;
                        }
                    }
                }
            }
        }
    }
}
