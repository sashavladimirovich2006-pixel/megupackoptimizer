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

            // 1. DRIVES INDEXING CATEGORY (Expandable Downwards Accordion)
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
                    height: expanded ? (indexingContentColumn.implicitHeight + 32) : 72
                    clip: true
                    
                    property bool expanded: false
                    
                    Behavior on height {
                        NumberAnimation {
                            duration: Theme.animNormal
                            easing.type: Easing.OutCubic
                        }
                    }

                    Column {
                        id: indexingContentColumn
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 16
                        spacing: 16

                        // Collapsed Header area (Height: 40)
                        Item {
                            width: parent.width
                            height: 40

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

                                // Arrow button that rotates downward when expanded
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

                                    Text {
                                        text: "→"
                                        color: Theme.accent
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 16
                                        font.bold: true
                                        anchors.centerIn: parent
                                        
                                        // satisfying Fluent rotation micro-animation
                                        rotation: indexingPanel.expanded ? 90 : 0
                                        Behavior on rotation { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }
                                    }

                                    MouseArea {
                                        id: arrowMouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            indexingPanel.expanded = !indexingPanel.expanded;
                                        }
                                    }
                                }
                            }
                        }

                        // Expanding downward sub-toggles
                        Column {
                            id: subContent
                            width: parent.width
                            spacing: 16
                            opacity: indexingPanel.expanded ? 1.0 : 0.0
                            visible: opacity > 0.0
                            
                            Behavior on opacity { NumberAnimation { duration: Theme.animFast } }

                            Rectangle {
                                width: parent.width
                                height: 1
                                color: Theme.border
                            }

                            // 1. Windows Search service
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
                                    color: showPathSearchMouse.containsMouse ? Theme.accentLight : Theme.accent
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    font.bold: true
                                    font.underline: true
                                    anchors.verticalCenter: parent.verticalCenter

                                    MouseArea {
                                        id: showPathSearchMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            optimizerBackend.showPath("Windows Search service");
                                        }
                                    }
                                }
                            }

                            // 2. Drive C: indexing
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
                                    color: showPathCMouse.containsMouse ? Theme.accentLight : Theme.accent
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    font.bold: true
                                    font.underline: true
                                    anchors.verticalCenter: parent.verticalCenter

                                    MouseArea {
                                        id: showPathCMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            optimizerBackend.showPath("C:");
                                        }
                                    }
                                }
                            }

                            // 3. Dynamic detected drives
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
                                        color: showPathMouse.containsMouse ? Theme.accentLight : Theme.accent
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 11
                                        font.bold: true
                                        font.underline: true
                                        anchors.verticalCenter: parent.verticalCenter

                                        MouseArea {
                                            id: showPathMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                optimizerBackend.showPath(modelData);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // 2. MOUSE CATEGORY (Xbox completely removal!)
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

                AcrylicPanel {
                    id: xboxPanel
                    width: parent.width
                    height: expanded ? (xboxContentColumn.implicitHeight + 32) : 72
                    clip: true
                    
                    property bool expanded: false
                    
                    Behavior on height {
                        NumberAnimation {
                            duration: Theme.animNormal
                            easing.type: Easing.OutCubic
                        }
                    }

                    Column {
                        id: xboxContentColumn
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 16
                        spacing: 16

                        // Collapsed Header area (Height: 40)
                        Item {
                            width: parent.width
                            height: 40

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

                                // Arrow button that rotates downward when expanded
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

                                    Text {
                                        text: "→"
                                        color: Theme.accent
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 16
                                        font.bold: true
                                        anchors.centerIn: parent
                                        
                                        // satisfying Fluent rotation micro-animation
                                        rotation: xboxPanel.expanded ? 90 : 0
                                        Behavior on rotation { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }
                                    }

                                    MouseArea {
                                        id: xboxArrowMouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            xboxPanel.expanded = !xboxPanel.expanded;
                                        }
                                    }
                                }
                            }
                        }

                        // Expanding downward sub-toggles (The Slidebar buttons!)
                        Column {
                            id: xboxSubContent
                            width: parent.width
                            spacing: 16
                            opacity: xboxPanel.expanded ? 1.0 : 0.0
                            visible: opacity > 0.0
                            
                            Behavior on opacity { NumberAnimation { duration: Theme.animFast } }

                            Rectangle {
                                width: parent.width
                                height: 1
                                color: Theme.border
                            }

                            Row {
                                width: parent.width
                                spacing: 20

                                Column {
                                    width: parent.width - 270
                                    spacing: 4
                                    anchors.verticalCenter: parent.verticalCenter

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
                                        font.pixelSize: 9
                                        wrapMode: Text.Wrap
                                        width: parent.width
                                    }
                                }

                                Row {
                                    spacing: 10
                                    anchors.verticalCenter: parent.verticalCenter

                                    MeguButton {
                                        id: xboxRemoveBtn
                                        text: optimizerBackend.xboxInstalled ? qsTr("Remove") : qsTr("Removed")
                                        iconSource: optimizerBackend.xboxInstalled ? "qrc:/MeguPackOptimizer/src/resources/close.svg" : "qrc:/MeguPackOptimizer/src/resources/check.svg"
                                        accented: optimizerBackend.xboxInstalled
                                        enabled: optimizerBackend.xboxInstalled && !optimizerBackend.isOptimizingSystem
                                        width: 120
                                        height: 36
                                        onClicked: {
                                            optimizerBackend.removeXboxEntirely();
                                        }
                                    }

                                    MeguButton {
                                        id: xboxRestoreBtn
                                        text: !optimizerBackend.xboxInstalled ? qsTr("Restore") : qsTr("Restored")
                                        iconSource: !optimizerBackend.xboxInstalled ? "qrc:/MeguPackOptimizer/src/resources/play.svg" : "qrc:/MeguPackOptimizer/src/resources/check.svg"
                                        accented: !optimizerBackend.xboxInstalled
                                        enabled: !optimizerBackend.xboxInstalled && !optimizerBackend.isOptimizingSystem
                                        width: 120
                                        height: 36
                                        onClicked: {
                                            optimizerBackend.restoreXboxEntirely();
                                        }
                                    }
                                }
                            }

                            // Divider line between Xbox package settings and the ms-gamingoverlay protocol block
                            Rectangle {
                                width: parent.width
                                height: 1
                                color: Theme.border
                            }

                            Row {
                                width: parent.width
                                spacing: 20

                                Column {
                                    width: parent.width - 70
                                    spacing: 4
                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        text: qsTr("Disable Game Bar Popup")
                                        color: Theme.textPrimary
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 12
                                        font.bold: true
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

                                MeguSwitch {
                                    checked: !optimizerBackend.gamingOverlayActive
                                    anchors.verticalCenter: parent.verticalCenter
                                    onToggled: {
                                        optimizerBackend.gamingOverlayActive = !isChecked;
                                    }
                                }
                            }
                        }
                    }
                }

                // 2.5 Multi-Plane Overlay (MPO) card
                AcrylicPanel {
                    id: mpoPanel
                    width: parent.width
                    height: expanded ? (mpoContentColumn.implicitHeight + 32) : 72
                    clip: true
                    
                    property bool expanded: false
                    
                    Behavior on height {
                        NumberAnimation {
                            duration: Theme.animNormal
                            easing.type: Easing.OutCubic
                        }
                    }

                    Column {
                        id: mpoContentColumn
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 16
                        spacing: 16

                        // Collapsed Header area (Height: 40)
                        Item {
                            width: parent.width
                            height: 40

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
                                    width: 100
                                    radius: 12
                                    color: (optimizerBackend.mpoValue === 5) ? Theme.accentDim : "#1A2536"
                                    border.color: (optimizerBackend.mpoValue === 5) ? Theme.accent : "#2B3F5C"
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        text: (optimizerBackend.mpoValue === 5) ? qsTr("MPO Disabled") : qsTr("MPO Default (0)")
                                        color: (optimizerBackend.mpoValue === 5) ? Theme.accent : Theme.textSecondary
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 10
                                        font.bold: true
                                        anchors.centerIn: parent
                                    }
                                }

                                // Arrow button that rotates downward when expanded
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

                                    Text {
                                        text: "→"
                                        color: Theme.accent
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 16
                                        font.bold: true
                                        anchors.centerIn: parent
                                        
                                        rotation: mpoPanel.expanded ? 90 : 0
                                        Behavior on rotation { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic } }
                                    }

                                    MouseArea {
                                        id: mpoArrowMouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            mpoPanel.expanded = !mpoPanel.expanded;
                                        }
                                    }
                                }
                            }
                        }

                        // Expanding downward sub-content
                        Column {
                            id: mpoSubContent
                            width: parent.width
                            spacing: 16
                            opacity: mpoPanel.expanded ? 1.0 : 0.0
                            visible: opacity > 0.0
                            
                            Behavior on opacity { NumberAnimation { duration: Theme.animFast } }

                            Rectangle {
                                width: parent.width
                                height: 1
                                color: Theme.border
                            }

                            Row {
                                width: parent.width
                                spacing: 20

                                Column {
                                    width: parent.width - 340
                                    spacing: 4
                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        text: qsTr("Multi-Plane Overlay Value")
                                        color: Theme.textPrimary
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 12
                                        font.bold: true
                                    }

                                    Text {
                                        text: qsTr("Select 5 to disable MPO completely (highly recommended for NVIDIA/AMD driver stutters) or 0 to restore default.")
                                        color: Theme.textMuted
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 9
                                        wrapMode: Text.Wrap
                                        width: parent.width
                                    }
                                }

                                Row {
                                    id: mpoSegmentRow
                                    spacing: 10
                                    anchors.verticalCenter: parent.verticalCenter
                                    
                                    property int selectedVal: optimizerBackend.mpoValue

                                    MeguButton {
                                        text: "0 (" + qsTr("Enabled") + ")"
                                        width: 100
                                        height: 36
                                        accented: mpoSegmentRow.selectedVal === 0
                                        onClicked: {
                                            mpoSegmentRow.selectedVal = 0;
                                        }
                                    }

                                    MeguButton {
                                        text: "5 (" + qsTr("Disabled") + ")"
                                        width: 100
                                        height: 36
                                        accented: mpoSegmentRow.selectedVal === 5
                                        onClicked: {
                                            mpoSegmentRow.selectedVal = 5;
                                        }
                                    }

                                    MeguButton {
                                        text: qsTr("Apply")
                                        iconSource: "qrc:/MeguPackOptimizer/src/resources/play.svg"
                                        accented: true
                                        enabled: mpoSegmentRow.selectedVal !== optimizerBackend.mpoValue && !optimizerBackend.isOptimizingSystem
                                        width: 100
                                        height: 36
                                        onClicked: {
                                            stepLogModel.clear();
                                            optimizerBackend.applyMpoValue(mpoSegmentRow.selectedVal);
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
