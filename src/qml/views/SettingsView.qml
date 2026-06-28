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
        if (themeName === "Blackout полностью черная") return qsTr("Blackout");
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
        anchors.topMargin: 128
        anchors.bottomMargin: 24
        anchors.leftMargin: 24
        anchors.rightMargin: 24
        clip: true
        contentHeight: mainColumn.implicitHeight

        ScrollBar.vertical: MeguScrollBar { }
        ScrollBar.horizontal: MeguScrollBar { }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            onWheel: (wheel) => {
                var speedMultiplier = 2.5;
                var angle = wheel.angleDelta.y;
                if (angle !== 0) {
                    var newY = mainScroll.contentItem.contentY - (angle * speedMultiplier);
                    mainScroll.contentItem.contentY = Math.max(mainScroll.contentItem.originY, 
                        Math.min(newY, mainScroll.contentItem.contentHeight - mainScroll.contentItem.height));
                }
            }
        }

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

                MeguActionCard {
                    width: parent.width
                    title: qsTr("Choose Interface Theme:")
                    description: qsTr("Select your preferred visual style and color accents for the interface.")
                    iconSource: "qrc:/MeguPackOptimizer/src/resources/settings.svg"
                    accentColor: Theme.accent

                    // Interactive Box displaying current theme
                    Rectangle {
                        id: themeSelectBtn
                        width: 160
                        height: 32
                        radius: Theme.radiusSmall
                        color: themeMouseArea.containsMouse ? Theme.accentDim : "transparent"
                        border.color: themeMouseArea.containsMouse ? Theme.accent : Theme.border
                        border.width: 1
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
                                font.pixelSize: 15
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

                MeguActionCard {
                    width: parent.width
                    title: qsTr("Choose Interface Language:")
                    description: qsTr("Change the primary localization used across all application screens.")
                    iconSource: "qrc:/MeguPackOptimizer/src/resources/info.svg"
                    accentColor: Theme.info

                    MeguDropdown {
                        id: languageDropdown
                        width: 160
                        height: 32
                        anchors.verticalCenter: parent.verticalCenter
                        model: ["en", "uk", "ru", "de", "es", "fr", "it", "pl", "sv", "cs"]
                        currentIndex: model.indexOf(settingsBackend.language) !== -1 ? model.indexOf(settingsBackend.language) : 0
                        
                        displayText: (settingsBackend.language, textFormatter(model[currentIndex]))
                        
                        textFormatter: function(item) {
                            if (item === "en") return qsTr("English");
                            if (item === "uk") return qsTr("Ukrainian");
                            if (item === "ru") return qsTr("Russian");
                            if (item === "de") return qsTr("German");
                            if (item === "es") return qsTr("Spanish");
                            if (item === "fr") return qsTr("French");
                            if (item === "it") return qsTr("Italian");
                            if (item === "pl") return qsTr("Polish");
                            if (item === "sv") return qsTr("Swedish");
                            if (item === "cs") return qsTr("Czech");
                            return item;
                        }
                        
                        onActivated: (index) => {
                            var code = model[index];
                            console.log("[QML] Language dropdown selected code:", code);
                            Qt.callLater(() => {
                                settingsBackend.language = code;
                            });
                        }

                        // Update current index if backend language changes externally
                        Connections {
                            target: settingsBackend
                            function onLanguageChanged() {
                                var idx = languageDropdown.model.indexOf(settingsBackend.language);
                                languageDropdown.currentIndex = idx !== -1 ? idx : 0;
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

                MeguActionCard {
                    width: parent.width
                    title: qsTr("Do not create Backup (not recommended):")
                    description: qsTr("Skip system restore point creation before executing optimizations.")
                    iconSource: "qrc:/MeguPackOptimizer/src/resources/warning.svg"
                    accentColor: Theme.warning

                    MeguSwitch {
                        width: 40
                        height: 22
                        anchors.verticalCenter: parent.verticalCenter
                        checked: !settingsBackend.createBackup
                        onToggled: (isChecked) => {
                            settingsBackend.createBackup = !isChecked;
                        }
                    }
                }

                MeguActionCard {
                    width: parent.width
                    title: qsTr("Restore system to a previous state:")
                    description: qsTr("Open Windows System Restore (rstrui.exe) to revert changes.")
                    iconSource: "qrc:/MeguPackOptimizer/src/resources/storage.svg"
                    accentColor: Theme.success

                    MeguButton {
                        width: 150
                        height: 32
                        text: qsTr("Restore System")
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

                MeguActionCard {
                    width: parent.width
                    title: qsTr("Advanced and risky configurations:")
                    description: qsTr("Show or hide advanced features intended only for experienced users.")
                    iconSource: "qrc:/MeguPackOptimizer/src/resources/warning.svg"
                    accentColor: Theme.error
                    danger: true

                    MeguButton {
                        width: 132
                        height: 32
                        text: qsTr("Configure")
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
                font.pixelSize: 12
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
                                    { name: "Темная", desc: qsTr("Glacier Mint & Obsidian theme"), hasSub: false },
                                    { name: "Blackout полностью черная", desc: qsTr("Absolute black theme"), hasSub: false },
                                    { name: "Ргб", desc: qsTr("Dynamic RGB gaming theme"), hasSub: false },
                                    { name: "Розовая", desc: qsTr("Cyber Rose-Gold soft theme"), hasSub: true }
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
                                            font.pixelSize: 15
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
                                    MeguIconButton {
                                        width: 24
                                        height: 24
                                        iconSource: "qrc:/MeguPackOptimizer/src/resources/arrow.svg"
                                        flat: true
                                        visible: modelData.hasSub
                                        anchors.verticalCenter: parent.verticalCenter
                                        z: 10 // Puts arrow on top of parent item mouseArea!
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
                                font.pixelSize: 15
                                font.bold: true
                            }
                            Text {
                                text: qsTr("High contrast black and hot pink accents")
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
                            font.pixelSize: 12
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                }

                MeguActionCard {
                    width: parent.width
                    title: qsTr("Show expert features")
                    description: qsTr("Toggle visibility of advanced features like More Privileges card in the optimization view.")
                    iconSource: "qrc:/MeguPackOptimizer/src/resources/warning.svg"
                    accentColor: Theme.error
                    danger: true

                    MeguSwitch {
                        id: expertSwitch
                        width: 40
                        height: 22
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
