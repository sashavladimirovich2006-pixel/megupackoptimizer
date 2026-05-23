import QtQuick
import QtQuick.Controls
import MeguPackOptimizer 1.0
import "../components"

Item {
    id: root
    anchors.fill: parent

    // Main layout container spanning settings area
    Column {
        id: mainColumn
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 24
        spacing: 20

        // 1. THEME SETTINGS SECTION
        Column {
            width: parent.width
            spacing: 8

            Text {
                text: qsTr("THEME SETTINGS")
                color: Theme.yellowAccent
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.bold: true
                font.letterSpacing: 1.5
            }

            AcrylicPanel {
                width: parent.width
                height: 56

                // Horizontal Row layout for Choose Theme
                Item {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16

                    Text {
                        text: qsTr("Choose Interface Theme:")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    // Interactive Box displaying current theme
                    Rectangle {
                        id: themeSelectBtn
                        width: 160
                        height: 36
                        radius: Theme.radiusSmall
                        color: themeMouseArea.containsMouse ? Theme.accentDim : "transparent"
                        border.color: themeMouseArea.containsMouse ? Theme.accent : Theme.border
                        border.width: 1
                        anchors.right: parent.right
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
                                text: Theme.currentTheme
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
        }

        // 2. LANGUAGE SETTINGS SECTION
        Column {
            width: parent.width
            spacing: 8

            Text {
                text: qsTr("LANGUAGE SETTINGS")
                color: Theme.yellowAccent
                font.family: Theme.fontFamily
                font.pixelSize: 11
                font.bold: true
                font.letterSpacing: 1.5
            }

            AcrylicPanel {
                width: parent.width
                height: 56

                // Horizontal Row layout for Choose Language
                Item {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16

                    Text {
                        text: qsTr("Choose Interface Language:")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    // Row of Language Option Buttons
                    Row {
                        spacing: 10
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter

                        Repeater {
                            model: [
                                { "code": "en", "name": qsTr("English") },
                                { "code": "uk", "name": qsTr("Ukrainian") }
                            ]

                            delegate: Rectangle {
                                width: 100
                                height: 32
                                radius: Theme.radiusSmall
                                color: settingsBackend.language === modelData.code ? Theme.accent : "#1E293B"
                                border.color: settingsBackend.language === modelData.code ? "transparent" : Theme.border
                                border.width: 1

                                Text {
                                    text: modelData.name
                                    color: settingsBackend.language === modelData.code ? Theme.textInverse : Theme.textPrimary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    font.bold: true
                                    anchors.centerIn: parent
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: settingsBackend.language = modelData.code
                                }
                            }
                        }
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

    // Backdrop for theme sidebar
    Rectangle {
        id: backdrop
        anchors.fill: parent
        color: "#000000"
        opacity: themeSidebar.isOpen ? 0.5 : 0.0
        visible: opacity > 0.0
        
        Behavior on opacity {
            NumberAnimation { duration: Theme.animNormal }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                themeSidebar.isOpen = false;
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
                            model: [
                                { name: "Белоснежная", desc: qsTr("Pure snow white theme"), hasSub: false },
                                { name: "Темная", desc: qsTr("Classic deep slate dark theme"), hasSub: false },
                                { name: "Blackout полностью черная", desc: qsTr("Absolute black OLED theme"), hasSub: false },
                                { name: "Ргб", desc: qsTr("Glowing orange gaming theme"), hasSub: false },
                                { name: "Розовая", desc: qsTr("Vibrant soft pink theme"), hasSub: true }
                            ]

                            delegate: Rectangle {
                                width: parent.width
                                height: 46
                                radius: Theme.radiusSmall
                                color: Theme.currentTheme === modelData.name ? Theme.accentDim : (itemMouseArea.containsMouse ? "#0CFFFFFF" : "transparent")
                                border.color: Theme.currentTheme === modelData.name ? Theme.accent : Theme.border
                                border.width: 1

                                Behavior on color { ColorAnimation { duration: Theme.animFast } }
                                Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    spacing: 8

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: modelData.hasSub ? parent.width - 32 : parent.width

                                        Text {
                                            text: modelData.name
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

                                MouseArea {
                                    id: itemMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        Theme.setTheme(modelData.name);
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
                                text: "Black pink"
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
}
