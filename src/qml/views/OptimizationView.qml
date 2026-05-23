import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeguPackOptimizer 1.0
import "../components"

Item {
    id: root
    anchors.fill: parent

    // Target States (synced from backend initially, then edited locally before Optimize is clicked)
    property bool subSearch: optimizerBackend.winSearchActive
    property bool subC: optimizerBackend.driveCActive
    property bool subDetected: optimizerBackend.detectedDriveActive

    // Tri-State derived logic for main switch
    property bool mainChecked: subSearch && subC && subDetected
    property bool mainIndeterminate: (subSearch || subC || subDetected) && !(subSearch && subC && subDetected)

    // Sync sub-toggles with backend when backend values update
    Connections {
        target: optimizerBackend
        function onWinSearchActiveChanged(val) { subSearch = val; }
        function onDriveCActiveChanged(val) { subC = val; }
        function onDetectedDriveActiveChanged(val) { subDetected = val; }
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
        if (mainIndeterminate || !mainChecked) {
            subSearch = true;
            subC = true;
            subDetected = true;
        } else {
            subSearch = false;
            subC = false;
            subDetected = false;
        }
    }

    Column {
        id: mainColumn
        anchors.top: parent.top
        anchors.bottom: bottomActionBar.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 24
        spacing: 20

        Text {
            text: qsTr("SYSTEM OPTIMIZATION")
            color: Theme.yellowAccent
            font.family: Theme.fontFamily
            font.pixelSize: 11
            font.bold: true
            font.letterSpacing: 1.5
        }

        // DRIVES CATEGORY
        Column {
            width: parent.width
            spacing: 8

            Text {
                text: qsTr("DRIVES")
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

                    // Drive Icon & Title
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

                    // Toggles & Drawer Arrow on the right
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

                        // Arrow button to open slidebar
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
                            }

                            MouseArea {
                                id: arrowMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    indexingSidebar.isOpen = true;
                                }
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
            enabled: !optimizerBackend.isOptimizingSystem && 
                     ((root.subSearch !== optimizerBackend.winSearchActive) || 
                      (root.subC !== optimizerBackend.driveCActive) || 
                      (root.subDetected !== optimizerBackend.detectedDriveActive))
            onClicked: {
                stepLogModel.clear();
                optimizerBackend.startSystemOptimization(root.subSearch, root.subC, root.subDetected);
            }
        }
    }

    // Backdrop for sidebar
    Rectangle {
        id: backdrop
        anchors.fill: parent
        color: "#000000"
        opacity: indexingSidebar.isOpen ? 0.6 : 0.0
        visible: opacity > 0.0
        z: 99

        Behavior on opacity {
            NumberAnimation { duration: Theme.animNormal }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: indexingSidebar.isOpen = false
        }
    }

    // Sliding Sidebar Drawer for Indexing Sub-toggles
    Rectangle {
        id: indexingSidebar
        width: 360
        height: parent.height
        anchors.right: parent.right
        anchors.rightMargin: isOpen ? 0 : -width
        color: Theme.sidebarBg
        border.color: Theme.border
        border.width: 1
        z: 100

        property bool isOpen: false

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

            Column {
                anchors.fill: parent
                spacing: 20

                // Header
                Row {
                    width: parent.width
                    spacing: 12

                    MeguButton {
                        text: qsTr("Back")
                        iconSource: "qrc:/MeguPackOptimizer/src/resources/close.svg"
                        width: 70
                        onClicked: indexingSidebar.isOpen = false
                    }

                    Text {
                        text: qsTr("INDEXING PATHS")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        font.bold: true
                        font.letterSpacing: 1.5
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Theme.border
                    Behavior on color { ColorAnimation { duration: Theme.animNormal } }
                }

                ScrollView {
                    id: subScroll
                    width: parent.width
                    height: parent.height - 80
                    clip: true

                    Column {
                        width: subScroll.width - 12
                        spacing: 24

                        // 1. Windows Search service
                        Column {
                            width: parent.width
                            spacing: 6

                            MeguSwitch {
                                text: qsTr("Windows Search service")
                                checked: root.subSearch
                                onToggled: { root.subSearch = isChecked; }
                                width: parent.width
                            }

                            // Show Path link
                            Text {
                                text: qsTr("Show Path")
                                color: showPathSearchMouse.containsMouse ? Theme.accentLight : Theme.accent
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                font.bold: true
                                font.underline: true
                                font.letterSpacing: 0.5

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
                        Column {
                            width: parent.width
                            spacing: 6

                            MeguSwitch {
                                text: qsTr("Drive C: indexing")
                                checked: root.subC
                                onToggled: { root.subC = isChecked; }
                                width: parent.width
                            }

                            Text {
                                text: qsTr("Show Path")
                                color: showPathCMouse.containsMouse ? Theme.accentLight : Theme.accent
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                font.bold: true
                                font.underline: true
                                font.letterSpacing: 0.5

                                MouseArea {
                                    id: showPathCMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        optimizerBackend.showPath("Drive C: indexing");
                                    }
                                }
                            }
                        }

                        // 3. Indexing of drive detected by program
                        Column {
                            width: parent.width
                            spacing: 6

                            MeguSwitch {
                                text: qsTr("Indexing of drive %1").arg(optimizerBackend.detectedDriveLetter)
                                checked: root.subDetected
                                onToggled: { root.subDetected = isChecked; }
                                width: parent.width
                            }

                            Text {
                                text: qsTr("Show Path")
                                color: showPathDetMouse.containsMouse ? Theme.accentLight : Theme.accent
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                font.bold: true
                                font.underline: true
                                font.letterSpacing: 0.5

                                MouseArea {
                                    id: showPathDetMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        optimizerBackend.showPath("Detected Drive indexing");
                                    }
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
