import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import MeguPackOptimizer 1.0
import "../components"

Item {
    id: root
    anchors.fill: parent

    // Premium reactive entry transition (runs butter-smooth on every tab switch!)
    property bool isActive: opacity > 0.1
    property real yTranslation: isActive ? 0 : 15
 
    function getTranslatedThemeName(themeName) {
        if (themeName === "Белоснежная") return qsTr("Snow White");
        if (themeName === "Темная") return qsTr("Dark");
        if (themeName === "Blackout полностью черная") return qsTr("OLED Blackout");
        if (themeName === "Ргб") return qsTr("RGB Gamer");
        if (themeName === "Розовая") return qsTr("Sakura Pink");
        if (themeName === "Black pink") return qsTr("Black Pink");
        return themeName;
    }

    transform: Translate {
        y: root.yTranslation
    }

    Behavior on yTranslation {
        NumberAnimation {
            duration: Theme.animNormal
            easing.type: Easing.OutCubic
        }
    }

    ScrollView {
        id: mainScroll
        anchors.fill: parent
        anchors.margins: 24
        clip: true
        contentHeight: mainColumn.implicitHeight

        ScrollBar.vertical: MeguScrollBar { }
        ScrollBar.horizontal: MeguScrollBar { }

        // Main layout container spanning settings area
        Column {
            id: mainColumn
            width: mainScroll.width - 12
            spacing: 20

            // 1. THEME SETTINGS SECTION
            Column {
                width: parent.width
                spacing: 8

                Row {
                    spacing: 8
                    height: 16

                    Rectangle {
                        width: 4
                        height: 16
                        radius: 2
                        color: Theme.accent
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: qsTr("Theme Settings")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                AcrylicPanel {
                    width: parent.width
                    height: 84

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 10
                            color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                            anchors.verticalCenter: parent.verticalCenter

                            Item {
                                width: 20
                                height: 20
                                anchors.centerIn: parent
                                Image {
                                    id: themeIconImg
                                    source: "qrc:/MeguPackOptimizer/src/resources/settings.svg"
                                    anchors.fill: parent
                                    sourceSize.width: 20
                                    sourceSize.height: 20
                                    visible: false
                                }
                                ColorOverlay {
                                    anchors.fill: themeIconImg
                                    source: themeIconImg
                                    color: Theme.accent
                                }
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                text: qsTr("Choose Interface Theme:")
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: 14
                                font.bold: true
                            }

                            Text {
                                text: qsTr("Select your preferred visual style and color accents for the interface.")
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                            }
                        }
                    }

                    // Interactive Box displaying current theme
                    Rectangle {
                        id: themeSelectBtn
                        width: 160
                        height: 32
                        radius: Theme.radiusSmall
                        color: themeMouseArea.containsMouse ? Theme.accentDim : "transparent"
                        border.color: themeMouseArea.containsMouse ? Theme.accent : Theme.border
                        border.width: 1
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter

                        Behavior on color { ColorAnimation { duration: Theme.animFast } }
                        Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                        Row {
                            anchors.centerIn: parent
                            spacing: 8

                            // Indicator circle showing active theme's primary color representation
                            Rectangle {
                                width: 10
                                height: 10
                                radius: 5
                                color: {
                                    if (Theme.currentTheme === "Белоснежная") return "#FFFFFF";
                                    if (Theme.currentTheme === "Темная") return "#1E293B";
                                    if (Theme.currentTheme === "Blackout полностью черная") return "#000000";
                                    if (Theme.currentTheme === "Ргб") return Theme.rgbAccent;
                                    if (Theme.currentTheme === "Розовая") return "#FF85A2";
                                    return "#FF85A2"; // Black pink
                                }
                                border.color: "#66FFFFFF"
                                border.width: 1
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: (settingsBackend.language, getTranslatedThemeName(Theme.currentTheme))
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: ">"
                                color: Theme.textSecondary
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            id: themeMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: themeSidebar.isOpen = true
                        }
                    }
                }
            }

            // 2. LANGUAGE SETTINGS SECTION
            Column {
                width: parent.width
                spacing: 8

                Row {
                    spacing: 8
                    height: 16

                    Rectangle {
                        width: 4
                        height: 16
                        radius: 2
                        color: Theme.accent
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: qsTr("Language Settings")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                AcrylicPanel {
                    width: parent.width
                    height: 84

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 10
                            color: Qt.rgba(Theme.textSecondary.r, Theme.textSecondary.g, Theme.textSecondary.b, 0.15)
                            anchors.verticalCenter: parent.verticalCenter

                            Item {
                                width: 20
                                height: 20
                                anchors.centerIn: parent
                                Image {
                                    id: langIconImg
                                    source: "qrc:/MeguPackOptimizer/src/resources/info.svg"
                                    anchors.fill: parent
                                    sourceSize.width: 20
                                    sourceSize.height: 20
                                    visible: false
                                }
                                ColorOverlay {
                                    anchors.fill: langIconImg
                                    source: langIconImg
                                    color: Theme.textSecondary
                                }
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                text: qsTr("Choose Interface Language:")
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: 14
                                font.bold: true
                            }

                            Text {
                                text: qsTr("Change the primary localization used across all application screens.")
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                            }
                        }
                    }

                    // Row of Language Option Buttons
                    Row {
                        spacing: 10
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter

                        Repeater {
                            model: ["en", "uk"]

                            delegate: MeguButton {
                                width: 100
                                height: 32
                                text: modelData === "en" ? qsTr("English") : qsTr("Ukrainian")
                                accented: settingsBackend.language === modelData
                                onClicked: {
                                    console.log("[QML] Language button clicked for code:", modelData);
                                    settingsBackend.language = modelData;
                                    console.log("[QML] After setting, backend language is:", settingsBackend.language);
                                }
                            }
                        }
                    }
                }
            }

            // 3. BACKUP SETTINGS SECTION
            Column {
                width: parent.width
                spacing: 8

                Row {
                    spacing: 8
                    height: 16

                    Rectangle {
                        width: 4
                        height: 16
                        radius: 2
                        color: Theme.accent
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: qsTr("Backup Settings")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                AcrylicPanel {
                    width: parent.width
                    height: 84

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 10
                            color: Qt.rgba(0.9, 0.3, 0.1, 0.15)
                            anchors.verticalCenter: parent.verticalCenter

                            Item {
                                width: 20
                                height: 20
                                anchors.centerIn: parent
                                Image {
                                    id: backupIconImg
                                    source: "qrc:/MeguPackOptimizer/src/resources/warning.svg"
                                    anchors.fill: parent
                                    sourceSize.width: 20
                                    sourceSize.height: 20
                                    visible: false
                                }
                                ColorOverlay {
                                    anchors.fill: backupIconImg
                                    source: backupIconImg
                                    color: "#FF5722"
                                }
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                text: qsTr("Do not create Backup (not recommended):")
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: 14
                                font.bold: true
                            }

                            Text {
                                text: qsTr("Skip system restore point creation before executing optimizations.")
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                            }
                        }
                    }

                    MeguSwitch {
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        checked: !settingsBackend.createBackup
                        onToggled: (isChecked) => {
                            settingsBackend.createBackup = !isChecked;
                        }
                    }
                }

                AcrylicPanel {
                    width: parent.width
                    height: 84

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 10
                            color: Qt.rgba(0.1, 0.8, 0.5, 0.15)
                            anchors.verticalCenter: parent.verticalCenter

                            Item {
                                width: 20
                                height: 20
                                anchors.centerIn: parent
                                Image {
                                    id: restoreIconImg
                                    source: "qrc:/MeguPackOptimizer/src/resources/storage.svg"
                                    anchors.fill: parent
                                    sourceSize.width: 20
                                    sourceSize.height: 20
                                    visible: false
                                }
                                ColorOverlay {
                                    anchors.fill: restoreIconImg
                                    source: restoreIconImg
                                    color: "#00C853"
                                }
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                text: qsTr("Restore system to a previous state:")
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: 14
                                font.bold: true
                            }

                            Text {
                                text: qsTr("Open Windows System Restore (rstrui.exe) to revert changes.")
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                            }
                        }
                    }

                    MeguButton {
                        width: 160
                        height: 32
                        text: qsTr("Restore System")
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: {
                            optimizerBackend.restoreFromBackup("");
                        }
                    }
                }
            }

            // 4. DANGEROUS ZONE SECTION
            Column {
                width: parent.width
                spacing: 8

                Row {
                    spacing: 8
                    height: 16

                    Rectangle {
                        width: 4
                        height: 16
                        radius: 2
                        color: Theme.error
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: qsTr("Dangerous Zone")
                        color: Theme.error
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                AcrylicPanel {
                    width: parent.width
                    height: 84

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 10
                            color: Qt.rgba(Theme.error.r, Theme.error.g, Theme.error.b, 0.15)
                            anchors.verticalCenter: parent.verticalCenter

                            Item {
                                width: 20
                                height: 20
                                anchors.centerIn: parent
                                Image {
                                    id: dangerIconImg
                                    source: "qrc:/MeguPackOptimizer/src/resources/warning.svg"
                                    anchors.fill: parent
                                    sourceSize.width: 20
                                    sourceSize.height: 20
                                    visible: false
                                }
                                ColorOverlay {
                                    anchors.fill: dangerIconImg
                                    source: dangerIconImg
                                    color: Theme.error
                                }
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                text: qsTr("Advanced and risky configurations:")
                                color: Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: 14
                                font.bold: true
                            }

                            Text {
                                text: qsTr("Show or hide advanced features intended only for experienced users.")
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                            }
                        }
                    }

                    MeguButton {
                        width: 160
                        height: 32
                        text: qsTr("Configure")
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: {
                            dangerousZoneSidebar.isOpen = true;
                        }
                    }
                }
            }

            // Footnote tag
            Text {
                text: qsTr("* Changes are automatically applied and saved to config in real-time.")
                color: Theme.textMuted
                font.family: Theme.fontFamily
                font.pixelSize: 10
                font.italic: true
            }
        }
    }

    // Backdrop for sidebars
    Rectangle {
        id: backdrop
        anchors.fill: parent
        color: "#000000"
        opacity: (themeSidebar.isOpen || dangerousZoneSidebar.isOpen) ? 0.5 : 0.0
        visible: opacity > 0.0
        
        Behavior on opacity {
            NumberAnimation { duration: Theme.animNormal }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                themeSidebar.isOpen = false;
                dangerousZoneSidebar.isOpen = false;
                slidingPages.showSubPage = false;
            }
        }
    }

    // Sliding Sidebar Drawer for Theme Selection
    Rectangle {
        id: themeSidebar
        width: 320
        height: parent.height
        anchors.right: parent.right
        anchors.rightMargin: isOpen ? 0 : -width
        color: Theme.sidebarBg
        border.color: Theme.border
        border.width: 1

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
            clip: true

            // Row containing the sliding pages
            Row {
                id: slidingPages
                height: parent.height
                width: 560
                
                x: showSubPage ? -280 : 0
                Behavior on x {
                    NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
                }

                property bool showSubPage: false

                // Page 1: Main Theme List
                Column {
                    width: 280
                    height: parent.height
                    spacing: 16

                    Text {
                        text: qsTr("THEME SELECTION")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        font.bold: true
                        font.letterSpacing: 1.5
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Theme.border
                        Behavior on color { ColorAnimation { duration: Theme.animNormal } }
                    }

                    // Main Themes
                    Column {
                        width: parent.width
                        spacing: 8

                        Repeater {
                            model: {
                                var lang = settingsBackend.language;
                                return [
                                    { name: "Белоснежная", desc: qsTr("Pure snow white theme"), hasSub: false },
                                    { name: "Темная", desc: qsTr("Classic deep slate dark theme"), hasSub: false },
                                    { name: "Blackout полностью черная", desc: qsTr("Absolute black OLED theme"), hasSub: false },
                                    { name: "Ргб", desc: qsTr("Glowing orange gaming theme"), hasSub: false },
                                    { name: "Розовая", desc: qsTr("Vibrant soft pink theme"), hasSub: true }
                                ];
                            }

                            delegate: Rectangle {
                                width: parent.width
                                height: 46
                                radius: Theme.radiusSmall
                                color: Theme.currentTheme === modelData.name ? Theme.accentDim : (itemMouseArea.containsMouse ? "#0CFFFFFF" : "transparent")
                                border.color: Theme.currentTheme === modelData.name ? Theme.accent : Theme.border
                                border.width: 1

                                Behavior on color { ColorAnimation { duration: Theme.animFast } }
                                Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                                MouseArea {
                                    id: itemMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        Theme.setTheme(modelData.name);
                                    }
                                }

                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    spacing: 8

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: modelData.hasSub ? parent.width - 32 : parent.width

                                        Text {
                                            text: (settingsBackend.language, getTranslatedThemeName(modelData.name))
                                            color: Theme.currentTheme === modelData.name ? Theme.accent : Theme.textPrimary
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 12
                                            font.bold: true
                                        }
                                        Text {
                                            text: modelData.desc
                                            color: Theme.textMuted
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 9
                                        }
                                    }

                                    // Interactive arrow circle (overlayed via z-order)
                                    Rectangle {
                                        width: 24
                                        height: 24
                                        radius: 12
                                        color: arrowMouseArea.containsMouse ? Theme.accentDim : "transparent"
                                        border.color: arrowMouseArea.containsMouse ? Theme.accent : "transparent"
                                        border.width: 1
                                        visible: modelData.hasSub
                                        anchors.verticalCenter: parent.verticalCenter
                                        z: 10 // Puts arrow on top of parent item mouseArea!

                                        Behavior on color { ColorAnimation { duration: Theme.animFast } }

                                        Text {
                                            text: "→"
                                            color: Theme.accent
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 14
                                            font.bold: true
                                            anchors.centerIn: parent
                                        }

                                        MouseArea {
                                            id: arrowMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                Theme.setTheme("Розовая");
                                                slidingPages.showSubPage = true;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Page 2: Sub-Theme Selector
                Column {
                    width: 280
                    height: parent.height
                    spacing: 16

                    Row {
                        spacing: 10
                        width: parent.width

                        MeguButton {
                            text: qsTr("Back")
                            iconSource: "qrc:/MeguPackOptimizer/src/resources/close.svg"
                            width: 70
                            onClicked: slidingPages.showSubPage = false
                        }

                        Text {
                            text: qsTr("SPECIAL THEME")
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

                    Rectangle {
                        width: parent.width
                        height: 46
                        radius: Theme.radiusSmall
                        color: Theme.currentTheme === "Black pink" ? Theme.accentDim : (subMouseArea.containsMouse ? "#0CFFFFFF" : "transparent")
                        border.color: Theme.currentTheme === "Black pink" ? Theme.accent : Theme.border
                        border.width: 1

                        Behavior on color { ColorAnimation { duration: Theme.animFast } }
                        Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                        Column {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 2
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                text: (settingsBackend.language, getTranslatedThemeName("Black pink"))
                                color: Theme.currentTheme === "Black pink" ? Theme.accent : Theme.textPrimary
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                font.bold: true
                            }
                            Text {
                                text: qsTr("High contrast black and glowing pink accents")
                                color: Theme.textMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 9
                            }
                        }

                        MouseArea {
                            id: subMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Theme.setTheme("Black pink")
                        }
                    }
                }
            }
        }
    }

    // Sliding Sidebar Drawer for Dangerous Zone Settings
    Rectangle {
        id: dangerousZoneSidebar
        width: 320
        height: parent.height
        anchors.right: parent.right
        anchors.rightMargin: isOpen ? 0 : -width
        color: Theme.sidebarBg
        border.color: Theme.border
        border.width: 1
        z: 200

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
            clip: true

            Column {
                width: parent.width
                spacing: 16

                Row {
                    spacing: 10
                    width: parent.width

                    MeguButton {
                        text: qsTr("Back")
                        iconSource: "qrc:/MeguPackOptimizer/src/resources/close.svg"
                        width: 70
                        onClicked: dangerousZoneSidebar.isOpen = false
                    }

                    Text {
                        text: qsTr("DANGEROUS ZONE")
                        color: Theme.error
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

                // Description warning box
                Rectangle {
                    width: parent.width
                    height: Math.max(50, warningTextCol.implicitHeight + 16)
                    radius: 8
                    color: Qt.rgba(Theme.error.r, Theme.error.g, Theme.error.b, 0.1)
                    border.color: Qt.rgba(Theme.error.r, Theme.error.g, Theme.error.b, 0.2)
                    border.width: 1

                    Column {
                        id: warningTextCol
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        spacing: 4

                        Text {
                            text: qsTr("⚠️ WARNING:")
                            color: Theme.error
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.bold: true
                        }
                        Text {
                            text: qsTr("Enabling expert settings can expose critical system controls. Ensure you know the consequences before activating them.")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                }

                // Card with Toggle
                Rectangle {
                    width: parent.width
                    height: Math.max(72, expertToggleCol.implicitHeight + 16)
                    radius: 8
                    color: "#05FFFFFF"
                    border.color: Theme.border
                    border.width: 1

                    Column {
                        id: expertToggleCol
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.right: expertSwitch.left
                        anchors.rightMargin: 12
                        spacing: 2

                        Text {
                            text: qsTr("Show expert features")
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                        }
                        Text {
                            text: qsTr("Toggle visibility of advanced features like More Privileges card in the optimization view.")
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }

                    MeguSwitch {
                        id: expertSwitch
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        checked: settingsBackend.showExpertFeatures
                        onToggled: (isChecked) => {
                            settingsBackend.showExpertFeatures = isChecked;
                        }
                    }
                }
            }
        }
    }
}
